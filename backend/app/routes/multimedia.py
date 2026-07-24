"""
Multimedia Streaming Routes
Video streaming with range-request support,
PDF and image serving for mobile & web clients
"""

from fastapi import APIRouter, Depends, HTTPException, Request, Query, status
from fastapi.responses import FileResponse, StreamingResponse
from sqlalchemy.orm import Session
from typing import Optional
import os
import re

from app.database import get_db
from app.models.user import User
from app.services.multimedia_service import MultimediaService
from app.utils.jwt import decode_access_token


def _resolve_user_from_token_or_header(
    request: Request,
    token: Optional[str],
    db: Session,
) -> User:
    """
    Resolve the current user from either:
      - Authorization: Bearer <jwt>  (mobile/desktop)
      - ?token=<jwt> query parameter (browser <video> tag)
    """
    raw_token: Optional[str] = None

    if token:
        raw_token = token
    else:
        auth = request.headers.get("Authorization") or request.headers.get(
            "authorization"
        )
        if auth and auth.lower().startswith("bearer "):
            raw_token = auth.split(" ", 1)[1].strip()

    if not raw_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authentication token",
        )

    payload = decode_access_token(raw_token)
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token payload",
        )

    user = db.query(User).filter(User.id == int(user_id)).first()
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or inactive",
        )
    return user


router = APIRouter()


def range_requests_response(
    request: Request,
    file_path: str,
    content_type: str,
):
    """
    Handle HTTP range requests for video streaming.
    Supports partial content delivery for browser and mobile players.
    """
    file_size = os.path.getsize(file_path)
    range_header = request.headers.get("range") or request.headers.get("Range")

    if range_header:
        m = re.match(r"bytes=(\d+)-(\d*)", range_header)
        if m:
            start = int(m.group(1))
            end = int(m.group(2)) if m.group(2) else file_size - 1

            if start >= file_size:
                raise HTTPException(status_code=416, detail="Range not satisfiable")

            end = min(end, file_size - 1)
            content_length = end - start + 1

            def iterfile():
                with open(file_path, "rb") as f:
                    f.seek(start)
                    remaining = content_length
                    chunk_size = 1024 * 1024
                    while remaining > 0:
                        data = f.read(min(chunk_size, remaining))
                        if not data:
                            break
                        remaining -= len(data)
                        yield data

            headers = {
                "Content-Range": f"bytes {start}-{end}/{file_size}",
                "Accept-Ranges": "bytes",
                "Content-Length": str(content_length),
                "Content-Type": content_type,
            }
            return StreamingResponse(iterfile(), status_code=206, headers=headers)

    return FileResponse(
        file_path,
        media_type=content_type,
        headers={"Accept-Ranges": "bytes"},
    )


@router.get("/stream/{multimedia_id}", tags=["Multimedia Streaming"])
def stream_multimedia(
    multimedia_id: int,
    request: Request,
    token: Optional[str] = Query(None, description="JWT token (browser fallback)"),
    db: Session = Depends(get_db),
):
    """
    Stream a multimedia file.
    Accepts token via `Authorization: Bearer` header OR `?token=` query.
    """
    user = _resolve_user_from_token_or_header(request, token, db)

    multimedia = MultimediaService.get_multimedia_for_streaming(
        db=db,
        multimedia_id=multimedia_id,
        user_id=user.id,
        user_role=user.role.value,
    )

    content_type = multimedia.mime_type or "application/octet-stream"

    if multimedia.media_type.value == "video":
        return range_requests_response(request, multimedia.file_path, content_type)

    return FileResponse(
        multimedia.file_path,
        media_type=content_type,
        filename=multimedia.file_name,
    )


@router.get("/download/{multimedia_id}", tags=["Multimedia Streaming"])
def download_multimedia(
    multimedia_id: int,
    request: Request,
    token: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """
    Force download for offline access. Same auth rules as streaming.
    """
    user = _resolve_user_from_token_or_header(request, token, db)

    multimedia = MultimediaService.get_multimedia_for_streaming(
        db=db,
        multimedia_id=multimedia_id,
        user_id=user.id,
        user_role=user.role.value,
    )

    return FileResponse(
        multimedia.file_path,
        media_type="application/octet-stream",
        filename=multimedia.file_name,
        headers={
            "Content-Disposition": f'attachment; filename="{multimedia.file_name}"'
        },
    )


@router.get("/info/{multimedia_id}", tags=["Multimedia Streaming"])
def get_multimedia_info(
    multimedia_id: int,
    request: Request,
    token: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """Return file metadata without streaming content."""
    user = _resolve_user_from_token_or_header(request, token, db)

    multimedia = MultimediaService.get_multimedia_for_streaming(
        db=db,
        multimedia_id=multimedia_id,
        user_id=user.id,
        user_role=user.role.value,
    )

    return {
        "id": multimedia.id,
        "title": multimedia.title,
        "description": multimedia.description,
        "media_type": multimedia.media_type.value,
        "file_name": multimedia.file_name,
        "file_size": multimedia.file_size,
        "file_size_mb": (
            round(multimedia.file_size / (1024 * 1024), 2)
            if multimedia.file_size else 0
        ),
        "mime_type": multimedia.mime_type,
        "duration_seconds": multimedia.duration_seconds,
        "stream_url": f"/api/media/stream/{multimedia.id}",
        "download_url": f"/api/media/download/{multimedia.id}",
    }

# ============================================================================
# ASSIGNMENT ATTACHMENT SERVING
# ============================================================================

@router.get(
    "/assignment-attachment/{assignment_id}",
    tags=["Multimedia Streaming"],
)
def get_assignment_attachment(
    assignment_id: int,
    request: Request,
    token: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """
    Serve/download an assignment's attachment file.
    Accessible to:
     - tutor who owns the course
     - students enrolled in the course
     - admins
    """
    from app.models.assignment import Assignment
    from app.models.enrollment import Enrollment
    from app.models.course import Course

    user = _resolve_user_from_token_or_header(request, token, db)

    assignment = db.query(Assignment).filter(
        Assignment.id == assignment_id
    ).first()

    if not assignment or not assignment.attachment_path:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Attachment not found",
        )

    role = user.role.value
    if role == "admin":
        pass
    elif role == "tutor":
        course = db.query(Course).filter(
            Course.id == assignment.course_id
        ).first()
        if not course or course.tutor_id != user.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not own this assignment",
            )
    else:  # student
        enrollment = db.query(Enrollment).filter(
            Enrollment.student_id == user.id,
            Enrollment.course_id == assignment.course_id,
        ).first()
        if not enrollment:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You are not enrolled in this course",
            )

    if not os.path.exists(assignment.attachment_path):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="File missing on server",
        )

    content_type = assignment.attachment_mime_type or "application/octet-stream"

    # Serve videos with range support, others as normal file
    if content_type.startswith("video/"):
        return range_requests_response(
            request, assignment.attachment_path, content_type
        )

    return FileResponse(
        assignment.attachment_path,
        media_type=content_type,
        filename=assignment.attachment_name,
    )