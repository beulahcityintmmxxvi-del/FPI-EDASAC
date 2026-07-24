"""
Multimedia Model
Videos, PDFs, images, and documents
"""

from sqlalchemy import Column, String, Text, Integer, ForeignKey, Enum as SQLEnum, BigInteger
from sqlalchemy.orm import relationship
from app.models.base import BaseModel
from app.models.enums import MediaType


class Multimedia(BaseModel):
    """
    Multimedia content (videos, PDFs, images, documents)
    """
    __tablename__ = "multimedia"
    
    title = Column(
        String(300),
        nullable=False,
        comment="Media title"
    )
    
    description = Column(
        Text,
        nullable=True,
        comment="Media description"
    )
    
    media_type = Column(
        SQLEnum(MediaType),
        nullable=False,
        index=True,
        comment="Type of media (video, pdf, image, document)"
    )
    
    file_path = Column(
        String(500),
        nullable=False,
        comment="Storage path or URL"
    )
    
    file_name = Column(
        String(300),
        nullable=False,
        comment="Original file name"
    )
    
    file_size = Column(
        BigInteger,
        nullable=True,
        comment="File size in bytes"
    )
    
    mime_type = Column(
        String(100),
        nullable=True,
        comment="MIME type (e.g., video/mp4)"
    )
    
    duration_seconds = Column(
        Integer,
        nullable=True,
        comment="Media duration for videos (in seconds)"
    )
    
    thumbnail = Column(
        String(500),
        nullable=True,
        comment="Thumbnail image for videos"
    )
    
    module_id = Column(
        Integer,
        ForeignKey("modules.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
        comment="Parent module"
    )
    
    order = Column(
        Integer,
        default=0,
        comment="Display order within module"
    )
    
    # Relationships
    module = relationship(
        "Module",
        back_populates="multimedia_items"
    )
    
    def __repr__(self):
        return f"<Multimedia {self.media_type.value}: {self.title}>"