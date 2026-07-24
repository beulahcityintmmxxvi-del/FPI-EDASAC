"""
Module Model
Course modules containing multimedia content
"""

from sqlalchemy import Column, String, Text, Integer, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class Module(BaseModel):
    """
    Learning modules within courses
    Contains multimedia educational content
    """
    __tablename__ = "modules"
    
    title = Column(
        String(300),
        nullable=False,
        comment="Module title"
    )
    
    description = Column(
        Text,
        nullable=True,
        comment="Module description"
    )
    
    course_id = Column(
        Integer,
        ForeignKey("courses.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Parent course"
    )
    
    order = Column(
        Integer,
        default=0,
        comment="Display order within course"
    )
    
    is_published = Column(
        Boolean,
        default=False,
        nullable=False,
        comment="Publication status"
    )
    
    duration_minutes = Column(
        Integer,
        nullable=True,
        comment="Estimated completion time in minutes"
    )
    
    # Relationships
    course = relationship(
        "Course",
        back_populates="modules"
    )
    
    multimedia_items = relationship(
        "Multimedia",
        back_populates="module",
        cascade="all, delete-orphan",
        order_by="Multimedia.order"
    )
    
    def __repr__(self):
        return f"<Module {self.title}>"