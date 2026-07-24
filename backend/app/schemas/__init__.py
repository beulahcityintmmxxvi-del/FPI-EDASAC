"""
Pydantic Schemas Package
"""

from app.schemas.auth import (
    TokenResponse, LoginRequest, StudentRegistrationRequest,
    TutorRegistrationRequest, PasswordChangeRequest, PasswordResetRequest
)
from app.schemas.user import UserResponse, StudentProfile, TutorProfile
from app.schemas.course import (
    CourseCreate, CourseUpdate, CourseResponse,
    ModuleCreate, ModuleResponse, MultimediaResponse
)
from app.schemas.assignment import (
    AssignmentCreate, AssignmentUpdate, AssignmentResponse,
    SubmissionCreate, SubmissionResponse, GradeSubmissionRequest
)

__all__ = [
    # Auth
    "TokenResponse", "LoginRequest", "StudentRegistrationRequest",
    "TutorRegistrationRequest", "PasswordChangeRequest", "PasswordResetRequest",
    # User
    "UserResponse", "StudentProfile", "TutorProfile",
    # Course
    "CourseCreate", "CourseUpdate", "CourseResponse",
    "ModuleCreate", "ModuleResponse", "MultimediaResponse",
    # Assignment
    "AssignmentCreate", "AssignmentUpdate", "AssignmentResponse",
    "SubmissionCreate", "SubmissionResponse", "GradeSubmissionRequest",
]