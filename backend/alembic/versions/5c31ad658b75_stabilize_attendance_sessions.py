"""stabilize_attendance_sessions

Revision ID: 5c31ad658b75
Revises: 96580a6105c4
Create Date: 2026-06-03 13:54:12.527996

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = '5c31ad658b75'
down_revision: Union[str, None] = '96580a6105c4'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        'attendance_sessions',
        sa.Column(
            'started_at',
            sa.DateTime(timezone=True),
            server_default=sa.text('now()'),
            nullable=True,
        ),
    )

    op.add_column(
        'attendance_sessions',
        sa.Column(
            'expires_at',
            sa.DateTime(timezone=True),
            nullable=True,
        ),
    )

    op.add_column(
        'attendance_sessions',
        sa.Column(
            'duration_minutes',
            sa.Integer(),
            server_default='10',
            nullable=True,
        ),
    )

    op.alter_column(
        'attendance_sessions',
        'is_active',
        existing_type=sa.BOOLEAN(),
        nullable=False,
    )

    op.create_index(
        op.f('ix_attendance_sessions_id'),
        'attendance_sessions',
        ['id'],
        unique=False,
    )

    op.drop_column('attendance_sessions', 'created_at')


def downgrade() -> None:
    op.add_column(
        'attendance_sessions',
        sa.Column(
            'created_at',
            postgresql.TIMESTAMP(timezone=True),
            server_default=sa.text('now()'),
            autoincrement=False,
            nullable=True,
        ),
    )

    op.drop_index(
        op.f('ix_attendance_sessions_id'),
        table_name='attendance_sessions',
    )

    op.alter_column(
        'attendance_sessions',
        'is_active',
        existing_type=sa.BOOLEAN(),
        nullable=True,
    )

    op.drop_column('attendance_sessions', 'duration_minutes')

    op.drop_column('attendance_sessions', 'expires_at')

    op.drop_column('attendance_sessions', 'started_at')