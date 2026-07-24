"""
Assignment Model
Assignments and projects for students
"""

from sqlalchemy import (
    Column, String, Text, Integer, ForeignKey,
    DateTime, Enum as SQLEnum, Boolean,
)
from sqlalchemy.orm import relationship
from app.models.base import BaseModel
from app.models.enums import AssignmentType


class Assignment(BaseModel):
    __tablename__ = "assignments"

    title = Column(String(300), nullable=False, index=True)
    description = Column(Text, nullable=False)

    assignment_type = Column(
        SQLEnum(AssignmentType),
        nullable=False,
        default=AssignmentType.PRACTICAL,
    )

    course_id = Column(
        Integer,
        ForeignKey("courses.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    max_score = Column(Integer, default=100, nullable=False)
    due_date = Column(DateTime(timezone=True), nullable=True)

    # ── Attachment (optional file the tutor gives to students) ──
    attachment_path = Column(String(500), nullable=True)
    attachment_name = Column(String(300), nullable=True)
    attachment_size = Column(Integer, nullable=True)
    attachment_mime_type = Column(String(150), nullable=True)

    is_published = Column(Boolean, default=False, nullable=False)

    course = relationship("Course", back_populates="assignments")
    submissions = relationship(
        "Submission",
        back_populates="assignment",
        cascade="all, delete-orphan",
    )

    def __repr__(self):
        return f"<Assignment {self.title}>"