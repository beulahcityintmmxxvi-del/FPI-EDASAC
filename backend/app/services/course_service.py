"""
Course Service
Business logic for course and module management
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_
from fastapi import HTTPException, status
from slugify import slugify

from app.models.course import Course
from app.models.module import Module
from app.models.vocation import Vocation
from app.models.user import User


class CourseService:

    @staticmethod
    def create_course(
        db: Session,
        title: str,
        description: str,
        vocation_id: int,
        tutor_id: int,
        is_published: bool = False,
    ) -> Course:
        """
        Create a new course under a vocation.
        Validates vocation exists before creating.
        """
        vocation = db.query(Vocation).filter(
            and_(
                Vocation.id == vocation_id,
                Vocation.is_active == True
            )
        ).first()

        if not vocation:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Vocation not found or inactive"
            )

        # Generate unique slug
        base_slug = slugify(f"{title}-{tutor_id}")
        slug = base_slug
        counter = 1
        while db.query(Course).filter(Course.slug == slug).first():
            slug = f"{base_slug}-{counter}"
            counter += 1

        course = Course(
            title=title,
            slug=slug,
            description=description,
            vocation_id=vocation_id,
            tutor_id=tutor_id,
            is_published=is_published,
        )

        db.add(course)
        db.commit()
        db.refresh(course)
        return course

    @staticmethod
    def get_tutor_courses(db: Session, tutor_id: int):
        """Return all courses created by a specific tutor."""
        return (
            db.query(Course)
            .filter(Course.tutor_id == tutor_id)
            .order_by(Course.order)
            .all()
        )

    @staticmethod
    def get_course_by_id(
        db: Session,
        course_id: int,
        tutor_id: int
    ) -> Course:
        """Return a single course owned by the tutor."""
        course = db.query(Course).filter(
            and_(
                Course.id == course_id,
                Course.tutor_id == tutor_id
            )
        ).first()

        if not course:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Course not found"
            )
        return course

    @staticmethod
    def update_course(
        db: Session,
        course_id: int,
        tutor_id: int,
        update_data: dict,
    ) -> Course:
        """Update a course owned by the tutor."""
        course = CourseService.get_course_by_id(db, course_id, tutor_id)

        # Validate new vocation if being changed
        if "vocation_id" in update_data and update_data["vocation_id"]:
            vocation = db.query(Vocation).filter(
                and_(
                    Vocation.id == update_data["vocation_id"],
                    Vocation.is_active == True
                )
            ).first()
            if not vocation:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Vocation not found or inactive"
                )

        for key, value in update_data.items():
            setattr(course, key, value)

        db.commit()
        db.refresh(course)
        return course

    @staticmethod
    def delete_course(
        db: Session,
        course_id: int,
        tutor_id: int
    ) -> None:
        """Delete a course owned by the tutor."""
        course = CourseService.get_course_by_id(db, course_id, tutor_id)
        db.delete(course)
        db.commit()

    @staticmethod
    def get_vocation_courses(
        db: Session,
        vocation_id: int,
        published_only: bool = True
    ):
        """Return all courses under a vocation."""
        query = db.query(Course).filter(
            Course.vocation_id == vocation_id
        )
        if published_only:
            query = query.filter(Course.is_published == True)
        return query.order_by(Course.order).all()