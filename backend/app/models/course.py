"""
Course Model
Learning courses for vocational programs
"""

from sqlalchemy import Column, String, Text, Integer, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class Course(BaseModel):
    """
    Courses within vocational programs
    """
    __tablename__ = "courses"
    
    title = Column(
        String(300),
        nullable=False,
        index=True,
        comment="Course title"
    )
    
    slug = Column(
        String(300),
        unique=True,
        nullable=False,
        index=True,
        comment="URL-friendly slug"
    )
    
    description = Column(
        Text,
        nullable=True,
        comment="Course description and objectives"
    )
    
    vocation_id = Column(
        Integer,
        ForeignKey("vocations.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Associated vocational program"
    )
    
    tutor_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Course instructor"
    )
    
    thumbnail = Column(
        String(500),
        nullable=True,
        comment="Course thumbnail image"
    )
    
    is_published = Column(
        Boolean,
        default=False,
        nullable=False,
        comment="Publication status"
    )
    
    order = Column(
        Integer,
        default=0,
        comment="Display order within vocation"
    )
    
    # Relationships
    vocation = relationship(
        "Vocation",
        back_populates="courses"
    )
    
    tutor = relationship(
        "User",
        back_populates="courses_created",
        foreign_keys=[tutor_id]
    )
    
    modules = relationship(
        "Module",
        back_populates="course",
        cascade="all, delete-orphan",
        order_by="Module.order"
    )
    
    assignments = relationship(
        "Assignment",
        back_populates="course",
        cascade="all, delete-orphan"
    )
    
    enrollments = relationship(
        "Enrollment",
        back_populates="course",
        cascade="all, delete-orphan"
    )
    
    def __repr__(self):
        return f"<Course {self.title}>"