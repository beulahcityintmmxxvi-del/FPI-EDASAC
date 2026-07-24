"""
Admin API Routes
User management, analytics, and system administration
"""

from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from typing import List, Optional
from datetime import datetime, timedelta

from app.database import get_db
from app.middleware.rbac_middleware import require_admin
from app.models.user import User
from app.models.department import Department
from app.models.vocation import Vocation
from app.models.course import Course
from app.models.assignment import Assignment
from app.models.submission import Submission
from app.models.enrollment import Enrollment
from app.models.enums import UserRole, AcademicLevel
from app.schemas.user import UserResponse, UserActivationResponse
from app.schemas.auth import PasswordResetRequest, StudentRegistrationRequest
from app.services.auth_service import AuthService
from app.services.user_service import UserService

router = APIRouter()


# ============================================================================
# DASHBOARD STATISTICS
# ============================================================================

@router.get("/dashboard/stats", tags=["Admin - Analytics"])
def get_dashboard_statistics(
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """
    **Admin Dashboard Statistics**

    Returns real-time platform metrics:
    - Total users by role
    - Active/inactive user counts
    - Course and assignment statistics
    - Enrollment statistics
    - Recent activity
    """
    total_students = db.query(User).filter(
        User.role == UserRole.STUDENT
    ).count()

    active_students = db.query(User).filter(
        and_(User.role == UserRole.STUDENT, User.is_active == True)
    ).count()

    total_tutors = db.query(User).filter(
        User.role == UserRole.TUTOR
    ).count()

    active_tutors = db.query(User).filter(
        and_(User.role == UserRole.TUTOR, User.is_active == True)
    ).count()

    pending_tutors = db.query(User).filter(
        and_(
            User.role == UserRole.TUTOR,
            User.is_approved == False
        )
    ).count()

    total_courses = db.query(Course).count()
    published_courses = db.query(Course).filter(
        Course.is_published == True
    ).count()

    total_assignments = db.query(Assignment).count()

    pending_submissions = db.query(Submission).filter(
        Submission.status == "submitted"
    ).count()

    total_enrollments = db.query(Enrollment).count()
    completed_courses = db.query(Enrollment).filter(
        Enrollment.is_completed == True
    ).count()

    week_ago = datetime.utcnow() - timedelta(days=7)
    new_students_this_week = db.query(User).filter(
        and_(
            User.role == UserRole.STUDENT,
            User.created_at >= week_ago
        )
    ).count()

    return {
        "users": {
            "total_students": total_students,
            "active_students": active_students,
            "inactive_students": total_students - active_students,
            "total_tutors": total_tutors,
            "active_tutors": active_tutors,
            "inactive_tutors": total_tutors - active_tutors,
            "pending_tutor_approvals": pending_tutors,
            "new_students_this_week": new_students_this_week,
        },
        "courses": {
            "total": total_courses,
            "published": published_courses,
            "draft": total_courses - published_courses,
        },
        "assignments": {
            "total": total_assignments,
            "pending_grading": pending_submissions,
        },
        "enrollments": {
            "total": total_enrollments,
            "completed": completed_courses,
            "in_progress": total_enrollments - completed_courses,
        },
    }


# ============================================================================
# USER MANAGEMENT
# ============================================================================

@router.get(
    "/users",
    response_model=List[UserResponse],
    tags=["Admin - User Management"]
)
def get_all_users(
    role: Optional[str] = Query(None),
    department_id: Optional[int] = Query(None),
    academic_level: Optional[AcademicLevel] = Query(None),
    is_active: Optional[bool] = Query(None),
    search: Optional[str] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, le=500),
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """
    **Get All Users (with Filtering)**

    Supports filtering by role, department, level, status,
    and search by name, matric, or email.
    """
    return UserService.get_all_users(
        db=db,
        role=role,
        is_active=is_active,
        search=search,
        skip=skip,
        limit=limit,
    )


@router.get(
    "/users/students",
    response_model=List[UserResponse],
    tags=["Admin - User Management"]
)
def get_all_students(
    department_id: Optional[int] = None,
    academic_level: Optional[AcademicLevel] = None,
    vocation_id: Optional[int] = None,
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """**Get All Students**"""
    return UserService.get_students(
        db=db,
        department_id=department_id,
        vocation_id=vocation_id,
        academic_level=academic_level,
    )


@router.get(
    "/users/tutors/pending",
    response_model=List[UserResponse],
    tags=["Admin - User Management"]
)
def get_pending_tutors(
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """**Get Pending Tutor Approvals**"""
    return UserService.get_pending_tutors(db)


@router.post(
    "/users/tutors/{tutor_id}/approve",
    tags=["Admin - User Management"]
)
def approve_tutor(
    tutor_id: int,
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """**Approve Tutor Account**"""
    tutor = UserService.approve_tutor(db, tutor_id)
    return {
        "message": "Tutor approved successfully",
        "tutor_id": tutor_id,
        "tutor_name": f"{tutor.first_name} {tutor.last_name}",
    }


@router.post(
    "/users/tutors/{tutor_id}/reject",
    tags=["Admin - User Management"]
)
def reject_tutor(
    tutor_id: int,
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """**Reject Tutor Account**"""
    tutor = UserService.reject_tutor(db, tutor_id)
    return {
        "message": "Tutor rejected and deactivated",
        "tutor_id": tutor_id,
    }


@router.post(
    "/users/{user_id}/activate",
    response_model=UserActivationResponse,
    tags=["Admin - User Management"]
)
def activate_user(
    user_id: int,
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """
    **Activate User Account**

    Restores access for a previously deactivated account.
    """
    user = UserService.activate_user(db, user_id)
    return UserActivationResponse(
        user_id=user.id,
        is_active=True,
        message=f"User {user.first_name} {user.last_name} activated successfully",
    )


@router.post(
    "/users/{user_id}/deactivate",
    response_model=UserActivationResponse,
    tags=["Admin - User Management"]
)
def deactivate_user(
    user_id: int,
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """
    **Deactivate User Account**

    Blocks login access for the specified user.
    Admin cannot deactivate their own account.
    """
    user = UserService.deactivate_user(db, user_id, admin.id)
    return UserActivationResponse(
        user_id=user.id,
        is_active=False,
        message=f"User {user.first_name} {user.last_name} deactivated successfully",
    )


@router.post(
    "/users/{user_id}/toggle-active",
    tags=["Admin - User Management"]
)
def toggle_user_active_status(
    user_id: int,
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """
    **Toggle User Active Status**

    Activate or deactivate a user account in one call.
    Admin cannot toggle their own account.
    """
    user = UserService.toggle_user_active(db, user_id, admin.id)
    return {
        "message": (
            f"User {'activated' if user.is_active else 'deactivated'}"
            " successfully"
        ),
        "user_id": user_id,
        "is_active": user.is_active,
    }


@router.post(
    "/users/students/bulk-create",
    tags=["Admin - User Management"]
)
def bulk_create_students(
    students: List[StudentRegistrationRequest],
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """
    **Bulk Student Registration**

    Create multiple student accounts at once.
    Returns success count and any errors.
    """
    created_students = []
    errors = []

    for student_data in students:
        try:
            student = AuthService.register_student(
                db, student_data.dict()
            )
            created_students.append({
                "matric_number": student.matric_number,
                "name": f"{student.first_name} {student.last_name}",
            })
        except HTTPException as e:
            errors.append({
                "matric_number": student_data.matric_number,
                "error": e.detail,
            })
        except Exception as e:
            errors.append({
                "matric_number": student_data.matric_number,
                "error": str(e),
            })

    return {
        "created_count": len(created_students),
        "error_count": len(errors),
        "created_students": created_students,
        "errors": errors,
    }


@router.post(
    "/users/{user_id}/reset-password",
    tags=["Admin - User Management"]
)
def admin_reset_user_password(
    user_id: int,
    data: PasswordResetRequest,
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """**Admin Password Reset**"""
    user = UserService.reset_user_password(db, user_id, data.new_password)
    return {
        "message": "Password reset successfully",
        "user_id": user_id,
        "username": user.email or user.matric_number,
    }


# ============================================================================
# SYSTEM ACTIVITY MANAGEMENT
# ============================================================================

@router.get(
    "/activities/submissions",
    tags=["Admin - System Activity"]
)
def get_all_submissions(
    status_filter: Optional[str] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, le=500),
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """
    **Get All Submissions (System-wide)**

    Admin view of all assignment submissions across all courses.
    Supports filtering by status: submitted, graded, returned.
    """
    query = db.query(Submission)

    if status_filter:
        query = query.filter(
            Submission.status == status_filter
        )

    submissions = query.offset(skip).limit(limit).all()

    return [
        {
            "submission_id": s.id,
            "student_id": s.student_id,
            "student_name": (
                f"{s.student.first_name} {s.student.last_name}"
            ),
            "assignment_id": s.assignment_id,
            "assignment_title": s.assignment.title,
            "course_title": s.assignment.course.title,
            "status": s.status.value,
            "score": s.score,
            "submitted_at": s.created_at.isoformat(),
        }
        for s in submissions
    ]


@router.get(
    "/activities/enrollments",
    tags=["Admin - System Activity"]
)
def get_all_enrollments(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, le=500),
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """
    **Get All Enrollments (System-wide)**

    Admin view of all student course enrollments.
    """
    enrollments = (
        db.query(Enrollment)
        .offset(skip)
        .limit(limit)
        .all()
    )

    return [
        {
            "enrollment_id": e.id,
            "student_id": e.student_id,
            "student_name": (
                f"{e.student.first_name} {e.student.last_name}"
            ),
            "course_id": e.course_id,
            "course_title": e.course.title,
            "progress_percentage": e.progress_percentage,
            "is_completed": e.is_completed,
            "enrolled_at": e.created_at.isoformat(),
        }
        for e in enrollments
    ]


@router.get(
    "/activities/courses",
    tags=["Admin - System Activity"]
)
def get_all_courses(
    is_published: Optional[bool] = Query(None),
    vocation_id: Optional[int] = Query(None),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, le=500),
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """
    **Get All Courses (System-wide)**

    Admin view of all courses across all tutors and vocations.
    """
    query = db.query(Course)

    if is_published is not None:
        query = query.filter(Course.is_published == is_published)
    if vocation_id:
        query = query.filter(Course.vocation_id == vocation_id)

    courses = query.offset(skip).limit(limit).all()

    return [
        {
            "course_id": c.id,
            "title": c.title,
            "vocation_id": c.vocation_id,
            "vocation_name": c.vocation.name if c.vocation else None,
            "tutor_id": c.tutor_id,
            "tutor_name": (
                f"{c.tutor.first_name} {c.tutor.last_name}"
            ),
            "is_published": c.is_published,
            "module_count": len(c.modules),
            "enrollment_count": len(c.enrollments),
            "created_at": c.created_at.isoformat(),
        }
        for c in courses
    ]


# ============================================================================
# SYSTEM DATA
# ============================================================================

@router.get("/departments", tags=["Admin - System Data"])
def get_all_departments(
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """**Get All Departments**"""
    departments = db.query(Department).all()
    return [
        {
            "id": dept.id,
            "name": dept.name,
            "code": dept.code,
            "description": dept.description,
            "student_count": len(dept.students),
        }
        for dept in departments
    ]


@router.get("/vocations", tags=["Admin - System Data"])
def get_all_vocations(
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """**Get All Vocations**"""
    vocations = db.query(Vocation).all()
    return [
        {
            "id": voc.id,
            "name": voc.name,
            "slug": voc.slug,
            "description": voc.description,
            "is_active": voc.is_active,
            "student_count": len(voc.students),
            "course_count": len(voc.courses),
        }
        for voc in vocations
    ]


# ============================================================================
# ANALYTICS
# ============================================================================

@router.get(
    "/analytics/enrollment-by-vocation",
    tags=["Admin - Analytics"]
)
def get_enrollment_by_vocation(
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """**Enrollment Analytics by Vocation**"""
    results = db.query(
        Vocation.name,
        func.count(User.id).label('student_count')
    ).join(
        User, Vocation.id == User.vocation_id
    ).group_by(Vocation.name).all()

    return [
        {"vocation": name, "student_count": count}
        for name, count in results
    ]


@router.get(
    "/analytics/enrollment-by-department",
    tags=["Admin - Analytics"]
)
def get_enrollment_by_department(
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db)
):
    """**Enrollment Analytics by Department**"""
    results = db.query(
        Department.name,
        func.count(User.id).label('student_count')
    ).join(
        User, Department.id == User.department_id
    ).group_by(Department.name).all()

    return [
        {"department": name, "student_count": count}
        for name, count in results
    ]