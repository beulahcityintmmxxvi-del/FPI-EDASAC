"""
Multimedia Service
Business logic for multimedia upload, retrieval,
and streaming authorization
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_
from fastapi import HTTPException, status
import os

from app.models.multimedia import Multimedia
from app.models.module import Module
from app.models.course import Course
from app.models.enrollment import Enrollment
from app.models.enums import MediaType
from app.utils.file_handler import delete_file


class MultimediaService:

    @staticmethod
    def create_multimedia(
        db: Session,
        module_id: int,
        tutor_id: int,
        title: str,
        description: str,
        media_type: MediaType,
        file_path: str,
        file_name: str,
        file_size: int,
        mime_type: str,
        order: int = 0,
        duration_seconds: int = None,
    ) -> Multimedia:
        """
        Create a multimedia record after file upload.
        Verifies tutor owns the module's course.
        """
        module = (
            db.query(Module)
            .join(Course)
            .filter(
                and_(
                    Module.id == module_id,
                    Course.tutor_id == tutor_id
                )
            )
            .first()
        )

        if not module:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Module not found or you do not own it"
            )

        multimedia = Multimedia(
            title=title,
            description=description,
            media_type=media_type,
            file_path=file_path,
            file_name=file_name,
            file_size=file_size,
            mime_type=mime_type,
            module_id=module_id,
            order=order,
            duration_seconds=duration_seconds,
        )

        db.add(multimedia)
        db.commit()
        db.refresh(multimedia)
        return multimedia

    @staticmethod
    def get_module_multimedia(
        db: Session,
        module_id: int,
        tutor_id: int,
    ):
        """
        Return all multimedia items in a module.
        Verifies tutor owns the course.
        """
        module = (
            db.query(Module)
            .join(Course)
            .filter(
                and_(
                    Module.id == module_id,
                    Course.tutor_id == tutor_id
                )
            )
            .first()
        )

        if not module:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Module not found"
            )

        return (
            db.query(Multimedia)
            .filter(Multimedia.module_id == module_id)
            .order_by(Multimedia.order)
            .all()
        )

    @staticmethod
    def delete_multimedia(
        db: Session,
        multimedia_id: int,
        tutor_id: int,
    ) -> None:
        """
        Delete a multimedia record and its file from disk.
        Verifies tutor owns the course.
        """
        multimedia = (
            db.query(Multimedia)
            .join(Module)
            .join(Course)
            .filter(
                and_(
                    Multimedia.id == multimedia_id,
                    Course.tutor_id == tutor_id
                )
            )
            .first()
        )

        if not multimedia:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Multimedia not found"
            )

        delete_file(multimedia.file_path)
        db.delete(multimedia)
        db.commit()

    @staticmethod
    def get_multimedia_for_streaming(
        db: Session,
        multimedia_id: int,
        user_id: int,
        user_role: str,
    ) -> Multimedia:
        """
        Retrieve multimedia record for streaming.
        Students must be enrolled in the course.
        Tutors must own the course.
        Admins have full access.
        """
        multimedia = db.query(Multimedia).filter(
            Multimedia.id == multimedia_id
        ).first()

        if not multimedia:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Content not found"
            )

        if not os.path.exists(multimedia.file_path):
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="File not found on server"
            )

        # Admins bypass access checks
        if user_role == "admin":
            return multimedia

        module = multimedia.module
        course = module.course

        # Tutors: must own the course
        if user_role == "tutor":
            if course.tutor_id != user_id:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="You do not have access to this content"
                )
            return multimedia

        # Students: must be enrolled
        enrollment = db.query(Enrollment).filter(
            and_(
                Enrollment.student_id == user_id,
                Enrollment.course_id == course.id
            )
        ).first()

        if not enrollment:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You are not enrolled in this course"
            )

        return multimedia