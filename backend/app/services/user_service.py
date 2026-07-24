"""
User Service
Business logic for user management including
account activation and deactivation
"""

from sqlalchemy.orm import Session
from sqlalchemy import and_
from fastapi import HTTPException, status

from app.models.user import User
from app.models.enums import UserRole
from app.utils.security import get_password_hash


class UserService:

    @staticmethod
    def get_user_by_id(db: Session, user_id: int) -> User:
        """Fetch a user by ID. Raises 404 if not found."""
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )
        return user

    @staticmethod
    def activate_user(db: Session, user_id: int) -> User:
        """Activate a deactivated user account."""
        user = UserService.get_user_by_id(db, user_id)
        if user.is_active:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User account is already active"
            )
        user.is_active = True
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def deactivate_user(
        db: Session,
        user_id: int,
        requesting_admin_id: int
    ) -> User:
        """
        Deactivate a user account.
        Admin cannot deactivate their own account.
        """
        user = UserService.get_user_by_id(db, user_id)

        if user.id == requesting_admin_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Cannot deactivate your own admin account"
            )

        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User account is already inactive"
            )

        user.is_active = False
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def toggle_user_active(
        db: Session,
        user_id: int,
        requesting_admin_id: int
    ) -> User:
        """
        Toggle user active/inactive status.
        Admin cannot toggle their own account.
        """
        user = UserService.get_user_by_id(db, user_id)

        if user.id == requesting_admin_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Cannot deactivate your own admin account"
            )

        user.is_active = not user.is_active
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def reset_user_password(
        db: Session,
        user_id: int,
        new_password: str
    ) -> User:
        """Reset a user's password and force change on next login."""
        user = UserService.get_user_by_id(db, user_id)
        user.hashed_password = get_password_hash(new_password)
        user.must_change_password = True
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def get_all_users(
        db: Session,
        role: str = None,
        is_active: bool = None,
        search: str = None,
        skip: int = 0,
        limit: int = 100,
    ):
        """
        Retrieve users with optional filters.
        Supports role, active status, and name/matric search.
        """
        query = db.query(User)

        if role and role != "all":
            try:
                role_enum = UserRole(role)
                query = query.filter(User.role == role_enum)
            except ValueError:
                pass

        if is_active is not None:
            query = query.filter(User.is_active == is_active)

        if search:
            pattern = f"%{search}%"
            query = query.filter(
                (User.first_name.ilike(pattern)) |
                (User.last_name.ilike(pattern)) |
                (User.matric_number.ilike(pattern)) |
                (User.email.ilike(pattern))
            )

        return query.offset(skip).limit(limit).all()

    @staticmethod
    def get_students(
        db: Session,
        department_id: int = None,
        vocation_id: int = None,
        academic_level=None,
    ):
        """Return all students with optional filters."""
        query = db.query(User).filter(User.role == UserRole.STUDENT)

        if department_id:
            query = query.filter(User.department_id == department_id)
        if vocation_id:
            query = query.filter(User.vocation_id == vocation_id)
        if academic_level:
            query = query.filter(User.academic_level == academic_level)

        return query.all()

    @staticmethod
    def get_pending_tutors(db: Session):
        """Return tutors awaiting admin approval."""
        return db.query(User).filter(
            and_(
                User.role == UserRole.TUTOR,
                User.is_approved == False
            )
        ).all()

    @staticmethod
    def approve_tutor(db: Session, tutor_id: int) -> User:
        """Approve a tutor account."""
        tutor = db.query(User).filter(
            and_(
                User.id == tutor_id,
                User.role == UserRole.TUTOR
            )
        ).first()

        if not tutor:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Tutor not found"
            )

        tutor.is_approved = True
        tutor.is_active = True
        db.commit()
        db.refresh(tutor)
        return tutor

    @staticmethod
    def reject_tutor(db: Session, tutor_id: int) -> User:
        """Reject and deactivate a tutor application."""
        tutor = db.query(User).filter(
            and_(
                User.id == tutor_id,
                User.role == UserRole.TUTOR
            )
        ).first()

        if not tutor:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Tutor not found"
            )

        tutor.is_active = False
        tutor.is_approved = False
        db.commit()
        db.refresh(tutor)
        return tutor