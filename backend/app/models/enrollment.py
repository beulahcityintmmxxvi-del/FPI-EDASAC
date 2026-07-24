"""
Enrollment Model
Tracks student vocation and course enrollments
"""

from sqlalchemy import Column, Integer, ForeignKey, Boolean, Float, UniqueConstraint
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class Enrollment(BaseModel):
    """
    Student course enrollments
    Tracks progress and completion status
    """
    __tablename__ = "enrollments"

    __table_args__ = (
        UniqueConstraint(
            'student_id',
            'course_id',
            name='uq_enrollment_student_course'
        ),
    )

    student_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Enrolled student"
    )

    course_id = Column(
        Integer,
        ForeignKey("courses.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Enrolled course"
    )

    progress_percentage = Column(
        Float,
        default=0.0,
        nullable=False,
        comment="Course completion percentage (0-100)"
    )

    is_completed = Column(
        Boolean,
        default=False,
        nullable=False,
        comment="Course completion status"
    )

    # Relationships
    student = relationship(
        "User",
        back_populates="enrollments",
        foreign_keys=[student_id]
    )

    course = relationship(
        "Course",
        back_populates="enrollments"
    )

    def __repr__(self):
        return (
            f"<Enrollment Student {self.student_id}"
            f" - Course {self.course_id}>"
        )