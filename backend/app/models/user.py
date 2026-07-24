"""
User Model
Handles authentication and role-based access control
"""

from sqlalchemy import Column, Integer, String, Boolean, Enum as SQLEnum, ForeignKey
from sqlalchemy.orm import relationship
from app.models.base import BaseModel
from app.models.enums import UserRole, AcademicLevel


class User(BaseModel):
    """
    Universal user model for Admin, Tutor, and Student
    Role determines access permissions and dashboard
    """
    __tablename__ = "users"
    
    # Authentication fields
    email = Column(
        String(255),
        unique=True,
        index=True,
        nullable=True,
        comment="User email address (optional for students)"
    )
    
    matric_number = Column(
        String(20),
        unique=True,
        index=True,
        nullable=True,
        comment="Student matriculation number (login username for students)"
    )
    
    hashed_password = Column(
        String(255),
        nullable=False,
        comment="Bcrypt hashed password"
    )
    
    # Role and status
    role = Column(
        SQLEnum(UserRole),
        nullable=False,
        default=UserRole.STUDENT,
        index=True,
        comment="User role: admin, tutor, or student"
    )
    
    is_active = Column(
        Boolean,
        default=True,
        nullable=False,
        comment="Account activation status"
    )
    
    is_approved = Column(
        Boolean,
        default=False,
        nullable=False,
        comment="Tutor approval status (admin must approve)"
    )
    
    must_change_password = Column(
        Boolean,
        default=True,
        nullable=False,
        comment="Force password change on first login"
    )
    
    # Profile fields
    first_name = Column(
        String(100),
        nullable=False,
        comment="User first name"
    )
    
    last_name = Column(
        String(100),
        nullable=False,
        comment="User last name"
    )
    
    phone_number = Column(
        String(20),
        nullable=True,
        comment="Contact phone number"
    )
    
    profile_picture = Column(
        String(500),
        nullable=True,
        comment="Profile picture URL/path"
    )
    
    # Student-specific fields
    department_id = Column(
        Integer,
        ForeignKey("departments.id", ondelete="SET NULL"),
        nullable=True,
        comment="Student department (ND/HND program)"
    )
    
    academic_level = Column(
        SQLEnum(AcademicLevel),
        nullable=True,
        comment="Student academic level (ND1, ND2, HND1, HND2)"
    )
    
    vocation_id = Column(
        Integer,
        ForeignKey("vocations.id", ondelete="SET NULL"),
        nullable=True,
        comment="Selected vocational skill program"
    )
    
    # Tutor-specific fields
    bio = Column(
        String(1000),
        nullable=True,
        comment="Tutor biography/qualifications"
    )
    
    specialization = Column(
        String(200),
        nullable=True,
        comment="Tutor area of expertise"
    )
    
    # Relationships
    department = relationship(
        "Department",
        back_populates="students",
        foreign_keys=[department_id]
    )
    
    vocation = relationship(
        "Vocation",
        back_populates="students",
        foreign_keys=[vocation_id]
    )
    
    # Courses created by tutor
    courses_created = relationship(
        "Course",
        back_populates="tutor",
        cascade="all, delete-orphan"
    )
    
    # Student submissions
    submissions = relationship(
        "Submission",
        back_populates="student",
        cascade="all, delete-orphan"
    )
    
    # Student enrollments
    enrollments = relationship(
        "Enrollment",
        back_populates="student",
        cascade="all, delete-orphan"
    )
    
    def __repr__(self):
        return f"<User {self.role.value}: {self.email or self.matric_number}>"