"""
Authentication Service
Business logic for authentication operations
"""

from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from typing import Optional, Tuple
from app.models.user import User
from app.models.enums import UserRole
from app.utils.security import verify_password, get_password_hash
from app.utils.jwt import create_token_for_user
from app.config import settings


class AuthService:
    """Authentication service class"""
    
    @staticmethod
    def authenticate_user(db: Session, username: str, password: str) -> Tuple[User, str]:
        """
        Authenticate user with username/password
        
        Args:
            db: Database session
            username: Email or matric number
            password: Plain text password
            
        Returns:
            Tuple of (User object, JWT token)
            
        Raises:
            HTTPException: If credentials are invalid
        """
        # Try to find user by email or matric number
        user = db.query(User).filter(
            (User.email == username) | (User.matric_number == username)
        ).first()
        
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect username or password"
            )
        
        # Verify password
        if not verify_password(password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect username or password"
            )
        
        # Check if account is active
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Your account has been deactivated"
            )
        
        # Check if tutor is approved
        if user.role == UserRole.TUTOR and not user.is_approved:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Your tutor account is pending admin approval"
            )
        
        # Generate JWT token
        token = create_token_for_user(
            user_id=user.id,
            role=user.role.value,
            email=user.email,
            matric_number=user.matric_number
        )
        
        return user, token
    
    @staticmethod
    def register_student(db: Session, data: dict) -> User:
        """
        Register new student
        
        Args:
            db: Database session
            data: Student registration data
            
        Returns:
            Created user object
            
        Raises:
            HTTPException: If matric number already exists
        """
        # Check if matric number already exists
        existing = db.query(User).filter(
            User.matric_number == data['matric_number']
        ).first()
        
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Matric number already registered"
            )
        
        # Create student user with default password
        student = User(
            matric_number=data['matric_number'],
            hashed_password=get_password_hash(settings.DEFAULT_STUDENT_PASSWORD),
            role=UserRole.STUDENT,
            is_active=True,
            is_approved=True,
            must_change_password=True,
            first_name=data['first_name'],
            last_name=data['last_name'],
            phone_number=data.get('phone_number'),
            department_id=data['department_id'],
            academic_level=data['academic_level'],
            vocation_id=data['vocation_id']
        )
        
        db.add(student)
        db.commit()
        db.refresh(student)
        
        return student
    
    @staticmethod
    def register_tutor(db: Session, data: dict) -> User:
        """
        Register new tutor (requires admin approval)
        
        Args:
            db: Database session
            data: Tutor registration data
            
        Returns:
            Created user object
            
        Raises:
            HTTPException: If email already exists
        """
        # Check if email already exists
        existing = db.query(User).filter(User.email == data['email']).first()
        
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
        
        # Create tutor user (not approved by default)
        tutor = User(
            email=data['email'],
            hashed_password=get_password_hash(data['password']),
            role=UserRole.TUTOR,
            is_active=True,
            is_approved=False,  # Requires admin approval
            must_change_password=False,
            first_name=data['first_name'],
            last_name=data['last_name'],
            phone_number=data.get('phone_number'),
            specialization=data['specialization'],
            bio=data.get('bio')
        )
        
        db.add(tutor)
        db.commit()
        db.refresh(tutor)
        
        return tutor
    
    @staticmethod
    def change_password(db: Session, user: User, old_password: str, new_password: str) -> None:
        """
        Change user password
        
        Args:
            db: Database session
            user: User object
            old_password: Current password
            new_password: New password
            
        Raises:
            HTTPException: If old password is incorrect
        """
        # Verify old password
        if not verify_password(old_password, user.hashed_password):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Incorrect current password"
            )
        
        # Update password
        user.hashed_password = get_password_hash(new_password)
        user.must_change_password = False
        
        db.commit()