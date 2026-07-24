"""
Vocation Model
Vocational skill programs offered by EDSAC
"""

from sqlalchemy import Column, String, Text, Boolean
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class Vocation(BaseModel):
    """
    Vocational skill acquisition programs
    """
    __tablename__ = "vocations"
    
    name = Column(
        String(200),
        unique=True,
        nullable=False,
        index=True,
        comment="Vocation name"
    )
    
    slug = Column(
        String(200),
        unique=True,
        nullable=False,
        index=True,
        comment="URL-friendly slug"
    )
    
    description = Column(
        Text,
        nullable=True,
        comment="Vocation description and learning outcomes"
    )
    
    icon = Column(
        String(500),
        nullable=True,
        comment="Vocation icon/image URL"
    )
    
    is_active = Column(
        Boolean,
        default=True,
        nullable=False,
        comment="Whether vocation is currently offered"
    )
    
    duration_weeks = Column(
        String(50),
        nullable=True,
        comment="Expected completion duration"
    )
    
    # Relationships
    students = relationship(
        "User",
        back_populates="vocation",
        foreign_keys="User.vocation_id"
    )
    
    courses = relationship(
        "Course",
        back_populates="vocation",
        cascade="all, delete-orphan"
    )
    
    def __repr__(self):
        return f"<Vocation {self.name}>"