"""
Base Model with Common Fields
Provides timestamp tracking for all models
"""

from sqlalchemy import Column, Integer, DateTime
from sqlalchemy.sql import func
from app.database import Base


class TimestampMixin:
    """
    Mixin that adds timestamp fields to models
    """
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
        comment="Record creation timestamp"
    )
    
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False,
        comment="Record last update timestamp"
    )


class BaseModel(Base, TimestampMixin):
    """
    Abstract base model with ID and timestamps
    """
    __abstract__ = True
    
    id = Column(
        Integer,
        primary_key=True,
        index=True,
        autoincrement=True,
        comment="Primary key"
    )