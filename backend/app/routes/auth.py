"""
Authentication Routes
Login, registration, and password management endpoints
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.auth import (
    LoginRequest, TokenResponse, StudentRegistrationRequest,
    TutorRegistrationRequest, PasswordChangeRequest
)
from app.schemas.user import UserResponse
from app.services.auth_service import AuthService
from app.middleware.auth_middleware import get_current_active_user
from app.models.user import User

router = APIRouter()


@router.post("/login", response_model=TokenResponse, tags=["Authentication"])
def login(
    credentials: LoginRequest,
    db: Session = Depends(get_db)
):
    """
    **User Login**
    
    Authenticate using email (tutor/admin) or matric number (student)
    
    - **Students**: Login with matric number and password
    - **Tutors/Admin**: Login with email and password
    
    Returns JWT access token for subsequent requests
    """
    user, token = AuthService.authenticate_user(
        db=db,
        username=credentials.username,
        password=credentials.password
    )
    
    return TokenResponse(
        access_token=token,
        role=user.role,
        must_change_password=user.must_change_password
    )


@router.post("/register/student", response_model=UserResponse, status_code=status.HTTP_201_CREATED, tags=["Authentication"])
def register_student(
    data: StudentRegistrationRequest,
    db: Session = Depends(get_db)
):
    """
    **Student Registration**
    
    Register new student account
    
    - Default password: `12345678`
    - Must change password on first login
    - Requires department, academic level, and vocation selection
    """
    student = AuthService.register_student(db, data.dict())
    
    return UserResponse.from_orm(student)


@router.post("/register/tutor", response_model=UserResponse, status_code=status.HTTP_201_CREATED, tags=["Authentication"])
def register_tutor(
    data: TutorRegistrationRequest,
    db: Session = Depends(get_db)
):
    """
    **Tutor Registration**
    
    Register new tutor account
    
    - Requires admin approval before access granted
    - Must provide strong password meeting requirements
    - Account pending until approved by administrator
    """
    tutor = AuthService.register_tutor(db, data.dict())
    
    return UserResponse.from_orm(tutor)


@router.post("/change-password", tags=["Authentication"])
def change_password(
    data: PasswordChangeRequest,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """
    **Change Password**
    
    Change current user's password
    
    - Requires old password verification
    - New password must meet strength requirements
    - Clears must_change_password flag for students
    """
    AuthService.change_password(
        db=db,
        user=current_user,
        old_password=data.old_password,
        new_password=data.new_password
    )
    
    return {"message": "Password changed successfully"}


@router.get("/me", response_model=UserResponse, tags=["Authentication"])
def get_current_user_profile(
    current_user: User = Depends(get_current_active_user)
):
    """
    **Get Current User Profile**
    
    Retrieve authenticated user's profile information
    
    Requires valid JWT token in Authorization header
    """
    return UserResponse.from_orm(current_user)