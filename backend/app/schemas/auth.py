"""
Authentication Schemas
Request/response models for auth endpoints
"""

from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional
from app.models.enums import UserRole, AcademicLevel


class TokenResponse(BaseModel):
    """JWT token response"""
    access_token: str
    token_type: str = "bearer"
    role: UserRole
    must_change_password: bool = False


class LoginRequest(BaseModel):
    """Login credentials"""
    username: str = Field(..., description="Email or matric number")
    password: str = Field(..., min_length=8)


class StudentRegistrationRequest(BaseModel):
    """Student registration data"""
    matric_number: str = Field(..., min_length=10, max_length=20)
    first_name: str = Field(..., min_length=2, max_length=100)
    last_name: str = Field(..., min_length=2, max_length=100)
    phone_number: Optional[str] = Field(None, max_length=20)
    department_id: int
    academic_level: AcademicLevel
    vocation_id: int
    
    @validator('matric_number')
    def validate_matric_number(cls, v):
        """Validate matric number format (numeric only)"""
        if not v.isdigit():
            raise ValueError('Matric number must contain only digits')
        return v


class TutorRegistrationRequest(BaseModel):
    """Tutor registration data"""
    email: EmailStr
    first_name: str = Field(..., min_length=2, max_length=100)
    last_name: str = Field(..., min_length=2, max_length=100)
    phone_number: Optional[str] = Field(None, max_length=20)
    specialization: str = Field(..., max_length=200)
    bio: Optional[str] = Field(None, max_length=1000)
    password: str = Field(..., min_length=8)
    
    @validator('password')
    def validate_password_strength(cls, v):
        """Validate password strength"""
        if not any(c.isupper() for c in v):
            raise ValueError('Password must contain at least one uppercase letter')
        if not any(c.islower() for c in v):
            raise ValueError('Password must contain at least one lowercase letter')
        if not any(c.isdigit() for c in v):
            raise ValueError('Password must contain at least one digit')
        if not any(c in '!@#$%^&*()_+-=[]{}|;:,.<>?' for c in v):
            raise ValueError('Password must contain at least one special character')
        return v


class PasswordChangeRequest(BaseModel):
    """Password change data"""
    old_password: str
    new_password: str = Field(..., min_length=8)
    
    @validator('new_password')
    def validate_new_password(cls, v):
        """Validate new password strength"""
        if not any(c.isupper() for c in v):
            raise ValueError('Password must contain at least one uppercase letter')
        if not any(c.islower() for c in v):
            raise ValueError('Password must contain at least one lowercase letter')
        if not any(c.isdigit() for c in v):
            raise ValueError('Password must contain at least one digit')
        if not any(c in '!@#$%^&*()_+-=[]{}|;:,.<>?' for c in v):
            raise ValueError('Password must contain at least one special character')
        return v


class PasswordResetRequest(BaseModel):
    """Admin password reset"""
    user_id: int
    new_password: str = Field(..., min_length=8)