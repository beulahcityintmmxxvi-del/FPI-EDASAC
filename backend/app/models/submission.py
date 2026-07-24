"""
Submission Model
Student assignment submissions
"""

from sqlalchemy import Column, String, Text, Integer, ForeignKey, Enum as SQLEnum
from sqlalchemy.orm import relationship
from app.models.base import BaseModel
from app.models.enums import SubmissionStatus


class Submission(BaseModel):
    """
    Student assignment submissions
    """
    __tablename__ = "submissions"
    
    assignment_id = Column(
        Integer,
        ForeignKey("assignments.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Associated assignment"
    )
    
    student_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Submitting student"
    )
    
    submission_text = Column(
        Text,
        nullable=True,
        comment="Text-based submission content"
    )
    
    file_path = Column(
        String(500),
        nullable=True,
        comment="Submitted file path"
    )
    
    file_name = Column(
        String(300),
        nullable=True,
        comment="Original file name"
    )
    
    status = Column(
        SQLEnum(SubmissionStatus),
        default=SubmissionStatus.SUBMITTED,
        nullable=False,
        index=True,
        comment="Submission status"
    )
    
    score = Column(
        Integer,
        nullable=True,
        comment="Awarded score"
    )
    
    feedback = Column(
        Text,
        nullable=True,
        comment="Tutor feedback"
    )
    
    # Relationships
    assignment = relationship(
        "Assignment",
        back_populates="submissions"
    )
    
    student = relationship(
        "User",
        back_populates="submissions",
        foreign_keys=[student_id]
    )
    
    def __repr__(self):
        return f"<Submission by Student {self.student_id} for Assignment {self.assignment_id}>"