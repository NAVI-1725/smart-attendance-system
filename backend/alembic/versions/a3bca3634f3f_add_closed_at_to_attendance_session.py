# backend\alembic\versions\a3bca3634f3f_add_closed_at_to_attendance_session.py
"""add closed_at to attendance session

Revision ID: a3bca3634f3f
Revises: 7ce84c7cd422
Create Date: 2026-05-31 17:12:43.173736

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = "a3bca3634f3f"
down_revision: Union[str, None] = "7ce84c7cd422"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "attendance_sessions",
        sa.Column(
            "closed_at",
            sa.DateTime(timezone=True),
            nullable=True,
        ),
    )


def downgrade() -> None:
    op.drop_column(
        "attendance_sessions",
        "closed_at",
    )
