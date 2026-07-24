"""
Database Enums and Constants
Defines role types, academic levels, and system constants
"""

from enum import Enum


class UserRole(str, Enum):
    """
    User role types for RBAC
    """
    ADMIN = "admin"
    TUTOR = "tutor"
    STUDENT = "student"


class AcademicLevel(str, Enum):
    """
    Academic levels for students
    """
    ND1 = "ND1"
    ND2 = "ND2"
    HND1 = "HND1"
    HND2 = "HND2"


class SubmissionStatus(str, Enum):
    """
    Assignment submission statuses
    """
    PENDING = "pending"
    SUBMITTED = "submitted"
    GRADED = "graded"
    RETURNED = "returned"


class MediaType(str, Enum):
    """
    Multimedia content types
    """
    VIDEO = "video"
    PDF = "pdf"
    IMAGE = "image"
    DOCUMENT = "document"


class AssignmentType(str, Enum):
    """
    Types of assignments
    """
    PRACTICAL = "practical"
    THEORY = "theory"
    PROJECT = "project"
    QUIZ = "quiz"


# Department constants
DEPARTMENTS = [
    "Computer Science",
    "Food Technology",
    "Hospitality Management",
    "Leisure and Tourism",
    "Nutrition and Dietetics",
    "Science Laboratory Technology",
    "Mathematics and Statistics"
]

# Vocational trade constants
VOCATIONS = [
    "Barbing and Hair Dressing",
    "Venue Decoration",
    "Beads Making",
    "Shoe Making",
    "Phone Repairs",
    "ICT/Computer Repair",
    "ICT/Web Design",
    "Welding and Fabrication",
    "Aluminium Works",
    "Soap Making",
    "Block Making",
    "Fashion Designing",
    "Bag Making",
    "Catering Services",
    "Tie & Dye",
    "Water Production",
    "Poultry",
    "Plumbing",
    "Solar and CCTV",
    "Carpentry",
    "Cosmetology"
]