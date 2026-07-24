"""
Assignment and Submission Schemas
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from app.models.enums import AssignmentType, SubmissionStatus


class AssignmentBase(BaseModel):
    title: str = Field(..., min_length=3, max_length=300)
    description: str
    course_id: int
    assignment_type: AssignmentType = AssignmentType.PRACTICAL
    max_score: int = Field(100, ge=1, le=1000)
    due_date: Optional[datetime] = None


class AssignmentCreate(AssignmentBase):
    is_published: bool = False


class AssignmentUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    max_score: Optional[int] = None
    due_date: Optional[datetime] = None
    is_published: Optional[bool] = None
    assignment_type: Optional[AssignmentType] = None


class AssignmentResponse(AssignmentBase):
    id: int
    attachment_path: Optional[str] = None
    attachment_name: Optional[str] = None
    attachment_size: Optional[int] = None
    attachment_mime_type: Optional[str] = None
    is_published: bool
    created_at: datetime
    submission_count: Optional[int] = 0

    class Config:
        from_attributes = True


class SubmissionBase(BaseModel):
    assignment_id: int
    submission_text: Optional[str] = None


class SubmissionCreate(SubmissionBase):
    pass


class SubmissionResponse(BaseModel):
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


class GradeSubmissionRequest(BaseModel):
    score: int = Field(..., ge=0, le=1000)
    feedback: Optional[str] = None