"""session_user_device_identity

Revision ID: cf6b9c80dc6d
Revises: a194d92fdfd0
Create Date: 2026-02-02 22:35:20.851389

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'cf6b9c80dc6d'
down_revision: Union[str, None] = 'a194d92fdfd0'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Add new columns
    op.add_column("sessions", sa.Column("user_id", sa.Integer(), nullable=False))
    op.add_column("sessions", sa.Column("device_id", sa.Integer(), nullable=False))

    # Create foreign keys
    op.create_foreign_key(
        "fk_sessions_user",
        "sessions",
        "users",
        ["user_id"],
        ["id"],
    )

    op.create_foreign_key(
        "fk_sessions_device",
        "sessions",
        "devices",
        ["device_id"],
        ["id"],
    )

    # Remove old faculty_id column
    op.drop_column("sessions", "faculty_id")


def downgrade() -> None:
    # Restore faculty_id
    op.add_column("sessions", sa.Column("faculty_id", sa.Integer(), nullable=False))

    # Drop foreign keys
    op.drop_constraint("fk_sessions_device", "sessions", type_="foreignkey")
    op.drop_constraint("fk_sessions_user", "sessions", type_="foreignkey")

    # Drop new columns
    op.drop_column("sessions", "device_id")
    op.drop_column("sessions", "user_id")
