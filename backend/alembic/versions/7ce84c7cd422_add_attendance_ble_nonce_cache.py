"""add attendance ble nonce cache

Revision ID: 7ce84c7cd422
Revises: 06107eaf9a47
Create Date: 2026-05-31 16:27:43.106175

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = "7ce84c7cd422"
down_revision: Union[str, None] = "06107eaf9a47"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "attendance_ble_nonce_cache",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("session_id", sa.Integer(), nullable=False),
        sa.Column("nonce", sa.String(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=True,
        ),
        sa.ForeignKeyConstraint(
            ["session_id"],
            ["attendance_sessions.id"],
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint(
            "session_id",
            "nonce",
            name="uq_ble_nonce_session",
        ),
    )

    op.create_index(
        op.f("ix_attendance_ble_nonce_cache_nonce"),
        "attendance_ble_nonce_cache",
        ["nonce"],
        unique=False,
    )

    op.create_index(
        op.f("ix_attendance_ble_nonce_cache_session_id"),
        "attendance_ble_nonce_cache",
        ["session_id"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index(
        op.f("ix_attendance_ble_nonce_cache_session_id"),
        table_name="attendance_ble_nonce_cache",
    )

    op.drop_index(
        op.f("ix_attendance_ble_nonce_cache_nonce"),
        table_name="attendance_ble_nonce_cache",
    )

    op.drop_table("attendance_ble_nonce_cache")
