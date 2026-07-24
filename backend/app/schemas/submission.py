"""
Submission Schemas
Student submission request/response models
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from app.models.enums import SubmissionStatus


class SubmissionResponse(BaseModel):
    """Full submission record response"""
    id: int
    assignment_id: int
    student_id: int
    submission_text: Optional[str] = None
    file_path: Optional[str] = None
    file_name: Optional[str] = None
    status: SubmissionStatus
    score: Optional[int] = None
    feedback: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class StudentSubmissionView(BaseModel):
    """
    Student-facing view of their own submission
    Includes feedback and score after grading
    """
    id: int
    assignment_id: int
    assignment_title: Optional[str] = None
    submission_text: Optional[str] = None
    file_name: Optional[str] = None
    status: SubmissionStatus
    score: Optional[int] = None
    max_score: Optional[int] = None
    feedback: Optional[str] = None
    submitted_at: datetime
    graded_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class GradeSubmissionRequest(BaseModel):
    """Tutor grading request"""
    score: int = Field(..., ge=0, le=1000)
    feedback: Optional[str] = None