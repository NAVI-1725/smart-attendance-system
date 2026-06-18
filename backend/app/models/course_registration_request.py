# backend/app/models/course_registration_request.py

from sqlalchemy import (
    Column,
    Integer,
    ForeignKey,
    DateTime,
    UniqueConstraint,
    Index,
)
from sqlalchemy import Enum as SqlEnum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base_class import Base
from app.models.enums import RegistrationRequestStatus


class CourseRegistrationRequest(Base):
    __tablename__ = "course_registration_requests"

    __table_args__ = (
        UniqueConstraint(
            "session_id",
            "student_id",
            name="uq_registration_request",
        ),
        Index(
            "ix_registration_request_session_id",
            "session_id",
        ),
        Index(
            "ix_registration_request_student_id",
            "student_id",
        ),
    )

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    session_id = Column(
        Integer,
        ForeignKey("course_registration_sessions.id"),
        nullable=False,
    )

    student_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
    )

    status = Column(
        SqlEnum(RegistrationRequestStatus),
        nullable=False,
        default=RegistrationRequestStatus.PENDING,
    )

    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )

    reviewed_at = Column(
        DateTime(timezone=True),
        nullable=True,
    )

    reviewed_by = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=True,
    )

    session = relationship(
        "CourseRegistrationSession",
        back_populates="requests",
    )

    student = relationship(
        "User",
        foreign_keys=[student_id],
        back_populates="registration_requests",
    )

    reviewer = relationship(
        "User",
        foreign_keys=[reviewed_by],
    )

    