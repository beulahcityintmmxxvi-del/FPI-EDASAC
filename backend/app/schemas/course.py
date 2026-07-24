"""
Course, Module, and Multimedia Schemas
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from app.models.enums import MediaType


class CourseBase(BaseModel):
    title: str = Field(..., min_length=3, max_length=300)
    description: Optional[str] = None
    vocation_id: int


class CourseCreate(CourseBase):
    is_published: bool = False


class CourseUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    vocation_id: Optional[int] = None
    is_published: Optional[bool] = None
    order: Optional[int] = None


class CourseResponse(CourseBase):
    id: int
    slug: str
    tutor_id: int
    thumbnail: Optional[str] = None
    is_published: bool
    order: int
    created_at: datetime
    module_count: Optional[int] = 0
    enrollment_count: Optional[int] = 0

    class Config:
        from_attributes = True


class ModuleBase(BaseModel):
    title: str = Field(..., min_length=3, max_length=300)
    description: Optional[str] = None
    course_id: int
    order: int = 0
    duration_minutes: Optional[int] = None


class ModuleCreate(ModuleBase):
    is_published: bool = False


class ModuleUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    order: Optional[int] = None
    duration_minutes: Optional[int] = None
    is_published: Optional[bool] = None


class ModuleResponse(ModuleBase):
    id: int
    is_published: bool
    created_at: datetime
    multimedia_count: Optional[int] = 0

    class Config:
        from_attributes = True


class MultimediaResponse(BaseModel):
    id: int
    title: str
    description: Optional[str] = None
    media_type: MediaType
    file_path: str
    file_name: str
    file_size: Optional[int] = None
    mime_type: Optional[str] = None
    duration_seconds: Optional[int] = None
    thumbnail: Optional[str] = None
    module_id: int
    order: int
    created_at: datetime

    class Config:
        from_attributes = True