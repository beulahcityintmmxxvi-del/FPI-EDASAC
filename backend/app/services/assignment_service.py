"""
Assignment Service
Business logic for assignment creation, submission, and grading.
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_
from fastapi import HTTPException, status
from typing import Optional

from app.models.assignment import Assignment
from app.models.submission import Submission
from app.models.course import Course
from app.models.enrollment import Enrollment
from app.models.enums import SubmissionStatus, AssignmentType
from app.utils.file_handler import delete_file


class AssignmentService:

    # ============================================================
    # CREATE / UPDATE / DELETE (Tutor)
    # ============================================================

    @staticmethod
    def create_assignment(
        db: Session,
        course_id: int,
        tutor_id: int,
        title: str,
        description: str,
        assignment_type: AssignmentType = AssignmentType.PRACTICAL,
        max_score: int = 100,
        due_date=None,
        is_published: bool = False,
        attachment_path: Optional[str] = None,
        attachment_name: Optional[str] = None,
        attachment_size: Optional[int] = None,
        attachment_mime_type: Optional[str] = None,
    ) -> Assignment:
        course = db.query(Course).filter(
            and_(Course.id == course_id, Course.tutor_id == tutor_id)
        ).first()

        if not course:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Course not found or you do not own it",
            )

        assignment = Assignment(
            title=title,
            description=description,
            course_id=course_id,
            assignment_type=assignment_type,
            max_score=max_score,
            due_date=due_date,
            is_published=is_published,
            attachment_path=attachment_path,
            attachment_name=attachment_name,
            attachment_size=attachment_size,
            attachment_mime_type=attachment_mime_type,
        )
        db.add(assignment)
        db.commit()
        db.refresh(assignment)
        return assignment

    @staticmethod
    def get_assignment_for_tutor(
        db: Session, assignment_id: int, tutor_id: int
    ) -> Assignment:
        assignment = (
            db.query(Assignment)
            .join(Course)
            .filter(
                and_(Assignment.id == assignment_id, Course.tutor_id == tutor_id)
            )
            .first()
        )
        if not assignment:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Assignment not found",
            )
        return assignment

    @staticmethod
    def update_assignment(
        db: Session,
        assignment_id: int,
        tutor_id: int,
        update_data: dict,
    ) -> Assignment:
        assignment = AssignmentService.get_assignment_for_tutor(
            db, assignment_id, tutor_id
        )
        for key, value in update_data.items():
            setattr(assignment, key, value)
        db.commit()
        db.refresh(assignment)
        return assignment

    @staticmethod
    def delete_assignment(
        db: Session, assignment_id: int, tutor_id: int
    ) -> None:
        assignment = AssignmentService.get_assignment_for_tutor(
            db, assignment_id, tutor_id
        )
        # Cleanup attachment file
        if assignment.attachment_path:
            delete_file(assignment.attachment_path)
        db.delete(assignment)
        db.commit()

    @staticmethod
    def set_attachment(
        db: Session,
        assignment_id: int,
        tutor_id: int,
        file_path: str,
        file_name: str,
        file_size: int,
        mime_type: str,
    ) -> Assignment:
        assignment = AssignmentService.get_assignment_for_tutor(
            db, assignment_id, tutor_id
        )
        # Remove old attachment if present
        if assignment.attachment_path:
            delete_file(assignment.attachment_path)

        assignment.attachment_path = file_path
        assignment.attachment_name = file_name
        assignment.attachment_size = file_size
        assignment.attachment_mime_type = mime_type
        db.commit()
        db.refresh(assignment)
        return assignment

    @staticmethod
    def remove_attachment(
        db: Session, assignment_id: int, tutor_id: int
    ) -> Assignment:
        assignment = AssignmentService.get_assignment_for_tutor(
            db, assignment_id, tutor_id
        )
        if assignment.attachment_path:
            delete_file(assignment.attachment_path)
        assignment.attachment_path = None
        assignment.attachment_name = None
        assignment.attachment_size = None
        assignment.attachment_mime_type = None
        db.commit()
        db.refresh(assignment)
        return assignment

    # ============================================================
    # LISTS
    # ============================================================

    @staticmethod
    def get_tutor_assignments(
        db: Session, tutor_id: int, course_id: int = None
    ):
        query = (
            db.query(Assignment)
            .join(Course)
            .filter(Course.tutor_id == tutor_id)
        )
        if course_id:
            query = query.filter(Assignment.course_id == course_id)
        return query.all()

    @staticmethod
    def get_assignment_submissions(
        db: Session, assignment_id: int, tutor_id: int
    ):
        AssignmentService.get_assignment_for_tutor(db, assignment_id, tutor_id)
        return (
            db.query(Submission)
            .filter(Submission.assignment_id == assignment_id)
            .all()
        )

    @staticmethod
    def get_student_assignments(db: Session, student_id: int):
        enrollments = (
            db.query(Enrollment)
            .filter(Enrollment.student_id == student_id)
            .all()
        )
        course_ids = [e.course_id for e in enrollments]
        if not course_ids:
            return []
        return (
            db.query(Assignment)
            .filter(
                and_(
                    Assignment.course_id.in_(course_ids),
                    Assignment.is_published == True,
                )
            )
            .all()
        )

    @staticmethod
    def get_assignment_for_student(
        db: Session, assignment_id: int, student_id: int
    ) -> Assignment:
        """Assignment + enrollment guard, used for attachment access."""
        assignment = db.query(Assignment).filter(
            and_(
                Assignment.id == assignment_id,
                Assignment.is_published == True,
            )
        ).first()
        if not assignment:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Assignment not found",
            )
        enrollment = db.query(Enrollment).filter(
            and_(
                Enrollment.student_id == student_id,
                Enrollment.course_id == assignment.course_id,
            )
        ).first()
        if not enrollment:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You are not enrolled in this course",
            )
        return assignment

    # ============================================================
    # GRADING
    # ============================================================

    @staticmethod
    def grade_submission(
        db: Session,
        submission_id: int,
        tutor_id: int,
        score: int,
        feedback: str = None,
    ) -> Submission:
        submission = (
            db.query(Submission)
            .join(Assignment)
            .join(Course)
            .filter(
                and_(
                    Submission.id == submission_id,
                    Course.tutor_id == tutor_id,
                )
            )
            .first()
        )
        if not submission:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Submission not found",
            )
        if score > submission.assignment.max_score:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=(
                    f"Score cannot exceed max score of "
                    f"{submission.assignment.max_score}"
                ),
            )
        submission.score = score
        submission.feedback = feedback
        submission.status = SubmissionStatus.GRADED
        db.commit()
        db.refresh(submission)
        return submission

    # ============================================================
    # STUDENT SUBMISSIONS
    # ============================================================

    @staticmethod
    def submit_assignment(
        db: Session,
        assignment_id: int,
        student_id: int,
        submission_text: str = None,
        file_path: str = None,
        file_name: str = None,
    ) -> Submission:
        """
        Create a new submission OR update the existing one.
        Rejects updates if the submission has already been graded.
        """
        assignment = db.query(Assignment).filter(
            and_(
                Assignment.id == assignment_id,
                Assignment.is_published == True,
            )
        ).first()
        if not assignment:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Assignment not found",
            )

        enrollment = db.query(Enrollment).filter(
            and_(
                Enrollment.student_id == student_id,
                Enrollment.course_id == assignment.course_id,
            )
        ).first()
        if not enrollment:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You are not enrolled in this course",
            )

        existing = db.query(Submission).filter(
            and_(
                Submission.assignment_id == assignment_id,
                Submission.student_id == student_id,
            )
        ).first()

        if existing:
            if existing.status == SubmissionStatus.GRADED:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="This submission has already been graded and cannot be edited",
                )
            existing.submission_text = submission_text
            if file_path:
                # Replace old file
                if existing.file_path:
                    delete_file(existing.file_path)
                existing.file_path = file_path
                existing.file_name = file_name
            existing.status = SubmissionStatus.SUBMITTED
            db.commit()
            db.refresh(existing)
            return existing

        submission = Submission(
            assignment_id=assignment_id,
            student_id=student_id,
            submission_text=submission_text,
            file_path=file_path,
            file_name=file_name,
            status=SubmissionStatus.SUBMITTED,
        )
        db.add(submission)
        db.commit()
        db.refresh(submission)
        return submission

    @staticmethod
    def get_student_submissions(db: Session, student_id: int):
        return (
            db.query(Submission)
            .filter(Submission.student_id == student_id)
            .all()
        )