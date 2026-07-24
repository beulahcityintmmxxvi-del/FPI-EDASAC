"""
User Schemas
User profile request/response models
"""

from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime
from app.models.enums import UserRole, AcademicLevel


class UserBase(BaseModel):
    """Base user fields"""
    first_name: str
    last_name: str
    phone_number: Optional[str] = None


class UserResponse(UserBase):
    """User profile response"""
    id: int
    email: Optional[str] = None
    matric_number: Optional[str] = None
    role: UserRole
    is_active: bool
    is_approved: bool
    profile_picture: Optional[str] = None
    department_id: Optional[int] = None
    academic_level: Optional[AcademicLevel] = None
    vocation_id: Optional[int] = None
    bio: Optional[str] = None
    specialization: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class UserActivationResponse(BaseModel):
    """Response after activating or deactivating a user"""
    user_id: int
    is_active: bool
    message: str


class StudentProfile(UserResponse):
    """Student-specific profile"""
    department_name: Optional[str] = None
    vocation_name: Optional[str] = None


class TutorProfile(UserResponse):
    """Tutor-specific profile"""
    courses_count: int = 0
    students_count: int = 0