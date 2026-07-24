"""
Enrollment Schemas
Vocation and course enrollment request/response models
"""

from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class VocationEnrollRequest(BaseModel):
    """Request to enroll student in a vocation"""
    vocation_id: int


class EnrollmentResponse(BaseModel):
    """Single enrollment record response"""
    id: int
    student_id: int
    course_id: int
    progress_percentage: float
    is_completed: bool
    created_at: datetime

    class Config:
        from_attributes = True


class VocationEnrollResponse(BaseModel):
    """Response after enrolling in a vocation"""
    vocation_id: int
    vocation_name: str
    courses_enrolled: int
    message: str