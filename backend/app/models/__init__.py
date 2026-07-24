"""
Database Models Package
Exports all SQLAlchemy ORM models
"""

from app.models.base import BaseModel, TimestampMixin
from app.models.enums import (
    UserRole,
    AcademicLevel,
    SubmissionStatus,
    MediaType,
    AssignmentType,
    DEPARTMENTS,
    VOCATIONS
)
from app.models.user import User
from app.models.department import Department
from app.models.vocation import Vocation
from app.models.course import Course
from app.models.module import Module
from app.models.multimedia import Multimedia
from app.models.assignment import Assignment
from app.models.submission import Submission
from app.models.enrollment import Enrollment

__all__ = [
    "BaseModel",
    "TimestampMixin",
    "UserRole",
    "AcademicLevel",
    "SubmissionStatus",
    "MediaType",
    "AssignmentType",
    "DEPARTMENTS",
    "VOCATIONS",
    "User",
    "Department",
    "Vocation",
    "Course",
    "Module",
    "Multimedia",
    "Assignment",
    "Submission",
    "Enrollment",
]