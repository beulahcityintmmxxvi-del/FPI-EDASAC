"""
Department Model
Academic departments for student classification
"""

from sqlalchemy import Column, String, Text
from sqlalchemy.orm import relationship
from app.models.base import BaseModel


class Department(BaseModel):
    """
    Academic departments (ND/HND programs)
    """
    __tablename__ = "departments"
    
    name = Column(
        String(200),
        unique=True,
        nullable=False,
        index=True,
        comment="Department name"
    )
    
    code = Column(
        String(20),
        unique=True,
        nullable=False,
        comment="Department code (e.g., CSC, FDT)"
    )
    
    description = Column(
        Text,
        nullable=True,
        comment="Department description"
    )
    
    # Relationships
    students = relationship(
        "User",
        back_populates="department",
        foreign_keys="User.department_id"
    )
    
    def __repr__(self):
        return f"<Department {self.code}: {self.name}>"