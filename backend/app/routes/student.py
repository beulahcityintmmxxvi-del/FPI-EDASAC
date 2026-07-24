"""
Student API Routes
Learning dashboard, content access, vocation enrollment,
and assignment submissions.
"""

from fastapi import (
    APIRouter, Depends, HTTPException, status,
    UploadFile, File, Form
)
from sqlalchemy.orm import Session
from sqlalchemy import and_
from typing import List, Optional

from app.database import get_db
from app.middleware.rbac_middleware import require_student
from app.models.user import User
from app.models.course import Course
from app.models.module import Module
from app.models.multimedia import Multimedia
from app.models.assignment import Assignment
from app.models.submission import Submission
from app.models.enrollment import Enrollment
from app.models.department import Department
from app.models.vocation import Vocation
from app.models.enums import SubmissionStatus
from app.schemas.course import CourseResponse, ModuleResponse, MultimediaResponse
from app.schemas.assignment import AssignmentResponse, SubmissionResponse
from app.schemas.enrollment import VocationEnrollRequest, VocationEnrollResponse
from app.schemas.user import UserResponse
from app.services.enrollment_service import EnrollmentService
from app.services.assignment_service import AssignmentService
from app.utils.file_handler import save_upload_file, detect_media_type

router = APIRouter()


# ============================================================================
# STUDENT DASHBOARD
# ============================================================================

@router.get("/dashboard", tags=["Student - Dashboard"])
def get_student_dashboard(
    student: User = Depends(require_student),
    db: Session = Depends(get_db),
):
    """
    Student dashboard.
    NOTE: Does NOT auto-enroll the student in any courses.
    """
    department = db.query(Department).filter(
        Department.id == student.department_id
    ).first()

    vocation = db.query(Vocation).filter(
        Vocation.id == student.vocation_id
    ).first()

    enrollments = db.query(Enrollment).filter(
        Enrollment.student_id == student.id
    ).all()

    completed_count = sum(1 for e in enrollments if e.is_completed)
    enrolled_course_ids = [e.course_id for e in enrollments]

    available_courses = db.query(Course).filter(
        and_(
            Course.vocation_id == student.vocation_id,
            Course.is_published == True,
        )
    ).count() if student.vocation_id else 0

    pending_assignments = 0
    if enrolled_course_ids:
        submitted_ids = [
            s.assignment_id for s in db.query(Submission)
            .filter(Submission.student_id == student.id)
            .all()
        ]
        pending_assignments = db.query(Assignment).filter(
            and_(
                Assignment.course_id.in_(enrolled_course_ids),
                Assignment.is_published == True,
                ~Assignment.id.in_(submitted_ids) if submitted_ids else True,
            )
        ).count()

    total_submissions = db.query(Submission).filter(
        Submission.student_id == student.id
    ).count()

    graded_submissions = db.query(Submission).filter(
        and_(
            Submission.student_id == student.id,
            Submission.status == SubmissionStatus.GRADED,
        )
    ).count()

    return {
        "student": {
            "id": student.id,
            "name": f"{student.first_name} {student.last_name}",
            "matric_number": student.matric_number,
            "department": department.name if department else None,
            "level": student.academic_level.value if student.academic_level else None,
            "vocation": vocation.name if vocation else None,
            "vocation_id": student.vocation_id,
        },
        "enrollments": {
            "total": len(enrollments),
            "completed": completed_count,
            "in_progress": len(enrollments) - completed_count,
        },
        "courses": {"available": available_courses},
        "assignments": {
            "pending": pending_assignments,
            "submitted": total_submissions,
            "graded": graded_submissions,
        },
    }


# ============================================================================
# VOCATION
# ============================================================================

@router.post(
    "/vocations/enroll",
    response_model=VocationEnrollResponse,
    tags=["Student - Vocation"],
)
def enroll_in_vocation(
    data: VocationEnrollRequest,
    student: User = Depends(require_student),
    db: Session = Depends(get_db),
):
    """
    Sets the student's vocation on their profile.
    Does NOT auto-enroll them in any courses.
    """
    result = EnrollmentService.enroll_in_vocation(
        db=db,
        student=student,
        vocation_id=data.vocation_id,
    )
    return VocationEnrollResponse(**result)


@router.post("/vocations/sync", tags=["Student - Vocation"])
def sync_vocation_courses(
    student: User = Depends(require_student),
    db: Session = Depends(get_db),
):
    """
    Deprecated no-op. Retained for older mobile clients.
    Auto-enrollment has been disabled — students must enroll
    in each course explicitly.
    """
    if not student.vocation_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You are not enrolled in any vocation",
        )

    available = db.query(Course).filter(
        and_(
            Course.vocation_id == student.vocation_id,
            Course.is_published == True,
        )
    ).count()

    return {
        "new_courses_enrolled": 0,
        "available_courses": available,
        "message": "Please enroll in each course manually from Available Courses.",
    }


# ============================================================================
# COURSES
# ============================================================================

@router.get(
    "/courses/available",
    response_model=List[CourseResponse],
    tags=["Student - Courses"],
)
def get_available_courses(
    student: User = Depends(require_student),
    db: Session = Depends(get_db),
):
    if not student.vocation_id:
        return []

    courses = db.query(Course).filter(
        and_(
            Course.vocation_id == student.vocation_id,
            Course.is_published == True,
        )
    ).all()

    result = []
    for course in courses:
        r = CourseResponse.from_orm(course)
        r.module_count = len(course.modules)
        r.enrollment_count = len(course.enrollments)
        result.append(r)
    return result


@router.get(
    "/courses/enrolled",
    response_model=List[CourseResponse],
    tags=["Student - Courses"],
)
def get_enrolled_courses(
    student: User = Depends(require_student),
    db: Session = Depends(get_db),
):
    enrollments = db.query(Enrollment).filter(
        Enrollment.student_id == student.id
    ).all()

    result = []
    for e in enrollments:
        course = e.course
        if not course:
            continue
        r = CourseResponse.from_orm(course)
        r.module_count = len(course.modules)
        r.enrollment_count = len(course.enrollments)
        result.append(r)
    return result


@router.post("/courses/{course_id}/enroll", tags=["Student - Courses"])
def enroll_in_course(
    course_id: int,
    student: User = Depends(require_student),
    db: Session = Depends(get_db),
):
    EnrollmentService.enroll_in_course(db, student.id, course_id)
    return {"message": "Enrolled successfully", "course_id": course_id}


# ============================================================================
# LEARNING MATERIALS
# ============================================================================

@router.get(
    "/courses/{course_id}/modules",
    response_model=List[ModuleResponse],
    tags=["Student - Learning"],
)
def get_course_modules(
    course_id: int,
    student: User = Depends(require_student),
    db: Session = Depends(get_db),
):
    if not EnrollmentService.check_enrollment(db, student.id, course_id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not enrolled in this course",
        )

    modules = db.query(Module).filter(
        and_(
            Module.course_id == course_id,
            Module.is_published == True,
        )
    ).order_by(Module.order).all()

    result = []
    for m in modules:
        r = ModuleResponse.from_orm(m)
        r.multimedia_count = len(m.multimedia_items)
        result.append(r)
    return result


@router.get(
    "/modules/{module_id}/multimedia",
    response_model=List[MultimediaResponse],
    tags=["Student - Learning"],
)
def get_module_content(
    module_id: int,
    student: User = Depends(require_student),
    db: Session = Depends(get_db),
):
    module = db.query(Module).filter(Module.id == module_id).first()
    if not module:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Module not found",
        )

    if not EnrollmentService.check_enrollment(db, student.id, module.course_id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not enrolled in this course",
        )

    return (
        db.query(Multimedia)
        .filter(Multimedia.module_id == module_id)
        .order_by(Multimedia.order)
        .all()
    )


# ============================================================================
# ASSIGNMENTS & SUBMISSIONS
# ============================================================================

@router.get(
    "/assignments",
    response_model=List[AssignmentResponse],
    tags=["Student - Assignments"],
)
def get_my_assignments(
    student: User = Depends(require_student),
    db: Session = Depends(get_db),
):
    assignments = AssignmentService.get_student_assignments(db, student.id)
    result = []
    for a in assignments:
        r = AssignmentResponse.from_orm(a)
        r.submission_count = len(a.submissions)
        result.append(r)
    return result


@router.post(
    "/assignments/{assignment_id}/submit",
    response_model=SubmissionResponse,
    tags=["Student - Assignments"],
)
async def submit_assignment(
    assignment_id: int,
    submission_text: Optional[str] = Form(None),
    file: Optional[UploadFile] = File(None),
    student: User = Depends(require_student),
    db: Session = Depends(get_db),
):
    file_path = None
    file_name = None

    if file and file.filename:
        media_type = detect_media_type(file.filename)
        if media_type:
            file_path, _, _ = await save_upload_file(file, media_type)
            file_name = file.filename

    submission = AssignmentService.submit_assignment(
        db=db,
        assignment_id=assignment_id,
        student_id=student.id,
        submission_text=submission_text,
        file_path=file_path,
        file_name=file_name,
    )
    return SubmissionResponse.from_orm(submission)


@router.get(
    "/submissions",
    response_model=List[SubmissionResponse],
    tags=["Student - Assignments"],
)
def get_my_submissions(
    student: User = Depends(require_student),
    db: Session = Depends(get_db),
):
    return AssignmentService.get_student_submissions(db, student.id)


@router.get(
    "/submissions/{submission_id}/review",
    response_model=SubmissionResponse,
    tags=["Student - Reviews"],
)
def get_submission_review(
    submission_id: int,
    student: User = Depends(require_student),
    db: Session = Depends(get_db),
):
    submission = db.query(Submission).filter(
        and_(
            Submission.id == submission_id,
            Submission.student_id == student.id,
        )
    ).first()
    if not submission:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Submission not found",
        )
    return SubmissionResponse.from_orm(submission)


@router.get("/reviews", tags=["Student - Reviews"])
def get_all_reviews(
    student: User = Depends(require_student),
    db: Session = Depends(get_db),
):
    graded = db.query(Submission).filter(
        and_(
            Submission.student_id == student.id,
            Submission.status == SubmissionStatus.GRADED,
        )
    ).all()

    return [
        {
            "submission_id": s.id,
            "assignment_id": s.assignment_id,
            "assignment_title": s.assignment.title,
            "score": s.score,
            "max_score": s.assignment.max_score,
            "feedback": s.feedback,
            "status": s.status.value,
            "graded_at": s.updated_at.isoformat(),
        }
        for s in graded
    ]


# ============================================================================
# PROFILE & METADATA
# ============================================================================

@router.get(
    "/profile",
    response_model=UserResponse,
    tags=["Student - Profile"],
)
def get_my_profile(student: User = Depends(require_student)):
    return UserResponse.from_orm(student)


@router.get("/departments", tags=["Student - Metadata"])
def get_departments_list(db: Session = Depends(get_db)):
    departments = db.query(Department).all()
    return [
        {"id": d.id, "name": d.name, "code": d.code}
        for d in departments
    ]


@router.get("/vocations", tags=["Student - Metadata"])
def get_vocations_list(db: Session = Depends(get_db)):
    vocations = db.query(Vocation).filter(Vocation.is_active == True).all()
    return [
        {
            "id": v.id,
            "name": v.name,
            "slug": v.slug,
            "description": v.description,
        }
        for v in vocations
    ]