"""
Tutor API Routes
Course management, content upload, and grading
"""

from fastapi import (
    APIRouter, Depends, HTTPException, status,
    UploadFile, File, Form, Query
)
from sqlalchemy.orm import Session
from sqlalchemy import and_
from typing import List, Optional

from app.database import get_db
from app.middleware.rbac_middleware import require_tutor
from app.models.user import User
from app.models.course import Course
from app.models.module import Module
from app.models.assignment import Assignment
from app.models.submission import Submission
from app.models.enrollment import Enrollment
from app.models.vocation import Vocation
from app.models.enums import SubmissionStatus, AssignmentType
from app.schemas.course import (
    CourseCreate, CourseUpdate, CourseResponse,
    ModuleCreate, ModuleUpdate, ModuleResponse,
    MultimediaResponse,
)
from app.schemas.assignment import (
    AssignmentCreate, AssignmentUpdate, AssignmentResponse,
    SubmissionResponse, GradeSubmissionRequest,
)
from app.services.course_service import CourseService
from app.services.assignment_service import AssignmentService
from app.services.multimedia_service import MultimediaService
from app.utils.file_handler import save_upload_file, detect_media_type

router = APIRouter()


# ============================================================================
# TUTOR DASHBOARD
# ============================================================================

@router.get(
    "/dashboard/stats",
    tags=["Tutor - Dashboard"],
)
def get_tutor_dashboard(
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """
    **Tutor Dashboard Statistics**

    Returns teaching metrics for the mobile dashboard.
    """
    total_courses = db.query(Course).filter(
        Course.tutor_id == tutor.id
    ).count()

    published_courses = db.query(Course).filter(
        and_(
            Course.tutor_id == tutor.id,
            Course.is_published.is_(True),
        )
    ).count()

    course_ids = [
        c.id for c in db.query(Course)
        .filter(Course.tutor_id == tutor.id).all()
    ]

    total_assignments = db.query(Assignment).filter(
        Assignment.course_id.in_(course_ids)
    ).count() if course_ids else 0

    pending_submissions = db.query(Submission).join(Assignment).filter(
        and_(
            Assignment.course_id.in_(course_ids),
            Submission.status == SubmissionStatus.SUBMITTED,
        )
    ).count() if course_ids else 0

    total_modules = db.query(Module).filter(
        Module.course_id.in_(course_ids)
    ).count() if course_ids else 0

    return {
        "courses": {
            "total": total_courses,
            "published": published_courses,
            "draft": total_courses - published_courses,
        },
        "content": {
            "total_modules": total_modules,
        },
        "assignments": {
            "total": total_assignments,
            "pending_grading": pending_submissions,
        },
    }


# ============================================================================
# COURSE MANAGEMENT
# ============================================================================

@router.post(
    "/courses",
    response_model=CourseResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Tutor - Courses"],
)
def create_course(
    data: CourseCreate,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """
    **Create New Course**

    Creates a course under the selected vocation.
    Validates that the vocation exists and is active.
    """
    course = CourseService.create_course(
        db=db,
        title=data.title,
        description=data.description,
        vocation_id=data.vocation_id,
        tutor_id=tutor.id,
        is_published=data.is_published,
    )

    response = CourseResponse.from_orm(course)
    response.module_count = 0
    response.enrollment_count = 0
    return response


@router.get(
    "/courses",
    response_model=List[CourseResponse],
    tags=["Tutor - Courses"],
)
def get_my_courses(
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """
    **Get Tutor's Courses**

    Returns all courses created by the authenticated tutor.
    """
    courses = CourseService.get_tutor_courses(db, tutor.id)

    result = []
    for course in courses:
        response = CourseResponse.from_orm(course)
        response.module_count = len(course.modules)
        response.enrollment_count = len(course.enrollments)
        result.append(response)

    return result


@router.get(
    "/courses/{course_id}",
    response_model=CourseResponse,
    tags=["Tutor - Courses"],
)
def get_course_detail(
    course_id: int,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """**Get Course Details**"""
    course = CourseService.get_course_by_id(db, course_id, tutor.id)
    response = CourseResponse.from_orm(course)
    response.module_count = len(course.modules)
    response.enrollment_count = len(course.enrollments)
    return response


@router.put(
    "/courses/{course_id}",
    response_model=CourseResponse,
    tags=["Tutor - Courses"],
)
def update_course(
    course_id: int,
    data: CourseUpdate,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """
    **Update Course**

    Supports updating title, description, vocation,
    publication status, and display order.
    """
    update_data = data.dict(exclude_unset=True)
    course = CourseService.update_course(
        db=db,
        course_id=course_id,
        tutor_id=tutor.id,
        update_data=update_data,
    )
    response = CourseResponse.from_orm(course)
    response.module_count = len(course.modules)
    response.enrollment_count = len(course.enrollments)
    return response


@router.delete(
    "/courses/{course_id}",
    tags=["Tutor - Courses"],
)
def delete_course(
    course_id: int,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """**Delete Course**"""
    CourseService.delete_course(db, course_id, tutor.id)
    return {"message": "Course deleted successfully"}


# ============================================================================
# VOCATION LISTING (for course creation dropdown)
# ============================================================================

@router.get(
    "/vocations",
    tags=["Tutor - Vocations"],
)
def get_vocations(
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """
    **Get Active Vocations**

    Returns all active vocations for the course creation
    dropdown in the tutor interface.
    """
    vocations = db.query(Vocation).filter(
        Vocation.is_active.is_(True)
    ).all()

    return [
        {
            "id": v.id,
            "name": v.name,
            "slug": v.slug,
            "description": v.description,
        }
        for v in vocations
    ]


# ============================================================================
# MODULE MANAGEMENT
# ============================================================================

@router.post(
    "/modules",
    response_model=ModuleResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Tutor - Modules"],
)
def create_module(
    data: ModuleCreate,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """**Create Module in Course**"""
    course = db.query(Course).filter(
        and_(
            Course.id == data.course_id,
            Course.tutor_id == tutor.id,
        )
    ).first()

    if not course:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Course not found",
        )

    module = Module(
        title=data.title,
        description=data.description,
        course_id=data.course_id,
        order=data.order,
        duration_minutes=data.duration_minutes,
        is_published=data.is_published,
    )

    db.add(module)
    db.commit()
    db.refresh(module)

    response = ModuleResponse.from_orm(module)
    response.multimedia_count = 0
    return response


@router.get(
    "/courses/{course_id}/modules",
    response_model=List[ModuleResponse],
    tags=["Tutor - Modules"],
)
def get_course_modules(
    course_id: int,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """**Get All Modules in Course**"""
    course = db.query(Course).filter(
        and_(
            Course.id == course_id,
            Course.tutor_id == tutor.id,
        )
    ).first()

    if not course:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Course not found",
        )

    modules = (
        db.query(Module)
        .filter(Module.course_id == course_id)
        .order_by(Module.order)
        .all()
    )

    result = []
    for module in modules:
        response = ModuleResponse.from_orm(module)
        response.multimedia_count = len(module.multimedia_items)
        result.append(response)

    return result


@router.put(
    "/modules/{module_id}",
    response_model=ModuleResponse,
    tags=["Tutor - Modules"],
)
def update_module(
    module_id: int,
    data: ModuleUpdate,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """**Update Module**"""
    module = (
        db.query(Module)
        .join(Course)
        .filter(
            and_(
                Module.id == module_id,
                Course.tutor_id == tutor.id,
            )
        )
        .first()
    )

    if not module:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Module not found",
        )

    update_data = data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(module, key, value)

    db.commit()
    db.refresh(module)

    response = ModuleResponse.from_orm(module)
    response.multimedia_count = len(module.multimedia_items)
    return response


@router.delete(
    "/modules/{module_id}",
    tags=["Tutor - Modules"],
)
def delete_module(
    module_id: int,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """**Delete Module**"""
    module = (
        db.query(Module)
        .join(Course)
        .filter(
            and_(
                Module.id == module_id,
                Course.tutor_id == tutor.id,
            )
        )
        .first()
    )

    if not module:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Module not found",
        )

    db.delete(module)
    db.commit()
    return {"message": "Module deleted successfully"}


# ============================================================================
# MULTIMEDIA UPLOAD
# ============================================================================

@router.post(
    "/modules/{module_id}/upload",
    response_model=MultimediaResponse,
    tags=["Tutor - Multimedia"],
)
async def upload_multimedia(
    module_id: int,
    title: str = Form(...),
    description: Optional[str] = Form(None),
    order: int = Form(0),
    file: UploadFile = File(...),
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """
    **Upload Multimedia Content**

    Upload video, PDF, image, or document to a module.

    Supported types:
    - Videos: mp4, avi, mov, mkv (max 500MB)
    - Images: jpg, jpeg, png, gif, webp (max 10MB)
    - PDFs: pdf (max 50MB)
    - Documents: doc, docx (max 25MB)
    """
    media_type = detect_media_type(file.filename)
    if not media_type:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported file type",
        )

    file_path, unique_filename, file_size = await save_upload_file(
        file, media_type
    )

    multimedia = MultimediaService.create_multimedia(
        db=db,
        module_id=module_id,
        tutor_id=tutor.id,
        title=title,
        description=description,
        media_type=media_type,
        file_path=file_path,
        file_name=file.filename,
        file_size=file_size,
        mime_type=file.content_type,
        order=order,
    )

    return MultimediaResponse.from_orm(multimedia)


@router.get(
    "/modules/{module_id}/multimedia",
    response_model=List[MultimediaResponse],
    tags=["Tutor - Multimedia"],
)
def get_module_multimedia(
    module_id: int,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """**Get All Multimedia in Module**"""
    return MultimediaService.get_module_multimedia(
        db, module_id, tutor.id
    )


@router.delete(
    "/multimedia/{multimedia_id}",
    tags=["Tutor - Multimedia"],
)
def delete_multimedia(
    multimedia_id: int,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """**Delete Multimedia Content**"""
    MultimediaService.delete_multimedia(db, multimedia_id, tutor.id)
    return {"message": "Multimedia deleted successfully"}


# ============================================================================
# ASSIGNMENT MANAGEMENT
# ============================================================================

@router.post(
    "/assignments",
    response_model=AssignmentResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Tutor - Assignments"],
)
def create_assignment(
    data: AssignmentCreate,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """Create an assignment (no attachment)."""
    assignment = AssignmentService.create_assignment(
        db=db,
        course_id=data.course_id,
        tutor_id=tutor.id,
        title=data.title,
        description=data.description,
        assignment_type=data.assignment_type,
        max_score=data.max_score,
        due_date=data.due_date,
        is_published=data.is_published,
    )
    response = AssignmentResponse.from_orm(assignment)
    response.submission_count = 0
    return response


@router.post(
    "/assignments/with-attachment",
    response_model=AssignmentResponse,
    status_code=status.HTTP_201_CREATED,
    tags=["Tutor - Assignments"],
)
async def create_assignment_with_attachment(
    course_id: int = Form(...),
    title: str = Form(...),
    description: str = Form(...),
    assignment_type: str = Form("practical"),
    max_score: int = Form(100),
    is_published: bool = Form(True),
    file: Optional[UploadFile] = File(None),
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """
    Create an assignment WITH an optional file attachment
    (PDF, DOC, DOCX, image, or video).
    """
    attach_path = attach_name = None
    attach_size = attach_mime = None

    if file and file.filename:
        media_type = detect_media_type(file.filename)
        if not media_type:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Unsupported file type for attachment",
            )
        attach_path, _, attach_size = await save_upload_file(file, media_type)
        attach_name = file.filename
        attach_mime = file.content_type

    try:
        atype = AssignmentType(assignment_type.lower())
    except ValueError:
        atype = AssignmentType.PRACTICAL

    assignment = AssignmentService.create_assignment(
        db=db,
        course_id=course_id,
        tutor_id=tutor.id,
        title=title,
        description=description,
        assignment_type=atype,
        max_score=max_score,
        is_published=is_published,
        attachment_path=attach_path,
        attachment_name=attach_name,
        attachment_size=attach_size,
        attachment_mime_type=attach_mime,
    )
    response = AssignmentResponse.from_orm(assignment)
    response.submission_count = 0
    return response


@router.get(
    "/assignments",
    response_model=List[AssignmentResponse],
    tags=["Tutor - Assignments"],
)
def get_my_assignments(
    course_id: Optional[int] = Query(None),
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """Get all assignments created by the tutor, optionally filtered by course."""
    assignments = AssignmentService.get_tutor_assignments(
        db, tutor.id, course_id
    )
    result = []
    for a in assignments:
        r = AssignmentResponse.from_orm(a)
        r.submission_count = len(a.submissions)
        result.append(r)
    return result


@router.put(
    "/assignments/{assignment_id}",
    response_model=AssignmentResponse,
    tags=["Tutor - Assignments"],
)
def update_assignment(
    assignment_id: int,
    data: AssignmentUpdate,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """Update assignment fields (title, description, score, type, publication)."""
    update_data = data.dict(exclude_unset=True)
    assignment = AssignmentService.update_assignment(
        db=db,
        assignment_id=assignment_id,
        tutor_id=tutor.id,
        update_data=update_data,
    )
    response = AssignmentResponse.from_orm(assignment)
    response.submission_count = len(assignment.submissions)
    return response


@router.delete(
    "/assignments/{assignment_id}",
    tags=["Tutor - Assignments"],
)
def delete_assignment(
    assignment_id: int,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """Delete an assignment along with all its submissions."""
    AssignmentService.delete_assignment(db, assignment_id, tutor.id)
    return {"message": "Assignment deleted successfully"}


@router.post(
    "/assignments/{assignment_id}/attachment",
    response_model=AssignmentResponse,
    tags=["Tutor - Assignments"],
)
async def upload_assignment_attachment(
    assignment_id: int,
    file: UploadFile = File(...),
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """Upload or replace an assignment's attachment file."""
    media_type = detect_media_type(file.filename)
    if not media_type:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported file type",
        )
    file_path, _, file_size = await save_upload_file(file, media_type)

    assignment = AssignmentService.set_attachment(
        db=db,
        assignment_id=assignment_id,
        tutor_id=tutor.id,
        file_path=file_path,
        file_name=file.filename,
        file_size=file_size,
        mime_type=file.content_type,
    )
    response = AssignmentResponse.from_orm(assignment)
    response.submission_count = len(assignment.submissions)
    return response


@router.delete(
    "/assignments/{assignment_id}/attachment",
    response_model=AssignmentResponse,
    tags=["Tutor - Assignments"],
)
def remove_assignment_attachment(
    assignment_id: int,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """Remove an assignment's attachment file."""
    assignment = AssignmentService.remove_attachment(
        db, assignment_id, tutor.id
    )
    response = AssignmentResponse.from_orm(assignment)
    response.submission_count = len(assignment.submissions)
    return response


# ============================================================================
# STUDENT ASSESSMENT (Submissions & Grading)
# ============================================================================

@router.get(
    "/assignments/{assignment_id}/submissions",
    response_model=List[SubmissionResponse],
    tags=["Tutor - Grading"],
)
def get_assignment_submissions(
    assignment_id: int,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """
    **Get All Submissions for Assignment**

    Returns all student submissions for assessment.
    """
    return AssignmentService.get_assignment_submissions(
        db, assignment_id, tutor.id
    )


@router.get(
    "/courses/{course_id}/students",
    tags=["Tutor - Student Assessment"],
)
def get_course_students(
    course_id: int,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """
    **Get All Students Enrolled in Course**

    Returns student list with submission and progress data
    for tutor assessment view.
    """
    course = db.query(Course).filter(
        and_(
            Course.id == course_id,
            Course.tutor_id == tutor.id,
        )
    ).first()

    if not course:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Course not found",
        )

    enrollments = (
        db.query(Enrollment)
        .filter(Enrollment.course_id == course_id)
        .all()
    )

    result = []
    for enrollment in enrollments:
        student = enrollment.student
        submissions = (
            db.query(Submission)
            .join(Assignment)
            .filter(
                and_(
                    Submission.student_id == student.id,
                    Assignment.course_id == course_id,
                )
            )
            .all()
        )

        graded = [s for s in submissions if s.status == SubmissionStatus.GRADED]
        avg_score = (
            sum(s.score for s in graded if s.score is not None) / len(graded)
            if graded else None
        )

        result.append({
            "student_id": student.id,
            "name": f"{student.first_name} {student.last_name}",
            "matric_number": student.matric_number,
            "progress_percentage": enrollment.progress_percentage,
            "is_completed": enrollment.is_completed,
            "total_submissions": len(submissions),
            "graded_submissions": len(graded),
            "average_score": round(avg_score, 2) if avg_score else None,
        })

    return result


@router.post(
    "/submissions/{submission_id}/grade",
    response_model=SubmissionResponse,
    tags=["Tutor - Grading"],
)
def grade_submission(
    submission_id: int,
    data: GradeSubmissionRequest,
    tutor: User = Depends(require_tutor),
    db: Session = Depends(get_db),
):
    """
    **Grade Student Submission**

    Award score and provide written feedback to student.
    """
    submission = AssignmentService.grade_submission(
        db=db,
        submission_id=submission_id,
        tutor_id=tutor.id,
        score=data.score,
        feedback=data.feedback,
    )
    return SubmissionResponse.from_orm(submission)