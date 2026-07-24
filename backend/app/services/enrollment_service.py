"""
Enrollment Service
Business logic for vocation and course enrollment.

Policy: enrolling in a vocation ONLY sets the student's vocation profile.
Students must explicitly enroll in each individual course themselves.
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_
from fastapi import HTTPException, status

from app.models.enrollment import Enrollment
from app.models.course import Course
from app.models.vocation import Vocation
from app.models.user import User


class EnrollmentService:

    @staticmethod
    def enroll_in_vocation(
        db: Session,
        student: User,
        vocation_id: int,
    ) -> dict:
        """
        Register the student's vocation on their profile.
        Does NOT auto-enroll them in any courses.
        The student must explicitly enroll in each course from the
        'Available Courses' list.
        """
        vocation = db.query(Vocation).filter(
            and_(
                Vocation.id == vocation_id,
                Vocation.is_active == True,
            )
        ).first()

        if not vocation:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Vocation not found or inactive",
            )

        student.vocation_id = vocation_id
        db.commit()

        available_courses = db.query(Course).filter(
            and_(
                Course.vocation_id == vocation_id,
                Course.is_published == True,
            )
        ).count()

        return {
            "vocation_id": vocation_id,
            "vocation_name": vocation.name,
            "courses_enrolled": 0,
            "available_courses": available_courses,
            "message": (
                f"Vocation set to {vocation.name}. "
                f"{available_courses} course(s) available for enrollment."
            ),
        }

    @staticmethod
    def enroll_in_course(
        db: Session,
        student_id: int,
        course_id: int,
    ) -> Enrollment:
        """
        Enroll a student in a single published course explicitly.
        Raises 400 if already enrolled.
        """
        course = db.query(Course).filter(
            and_(
                Course.id == course_id,
                Course.is_published == True,
            )
        ).first()

        if not course:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Course not found or not published",
            )

        existing = db.query(Enrollment).filter(
            and_(
                Enrollment.student_id == student_id,
                Enrollment.course_id == course_id,
            )
        ).first()

        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Already enrolled in this course",
            )

        enrollment = Enrollment(
            student_id=student_id,
            course_id=course_id,
            progress_percentage=0.0,
            is_completed=False,
        )
        db.add(enrollment)
        db.commit()
        db.refresh(enrollment)
        return enrollment

    @staticmethod
    def get_student_enrollments(db: Session, student_id: int):
        return (
            db.query(Enrollment)
            .filter(Enrollment.student_id == student_id)
            .all()
        )

    @staticmethod
    def check_enrollment(db: Session, student_id: int, course_id: int) -> bool:
        return db.query(Enrollment).filter(
            and_(
                Enrollment.student_id == student_id,
                Enrollment.course_id == course_id,
            )
        ).first() is not None

    # Kept for backward compatibility but is now a no-op.
    @staticmethod
    def sync_vocation_enrollments(db: Session, student_id: int, vocation_id: int) -> int:
        """Deprecated. Auto-enrollment removed. Returns 0."""
        return 0