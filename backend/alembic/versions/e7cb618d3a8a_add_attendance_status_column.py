"""add attendance status column

Revision ID: e7cb618d3a8a
Revises: 80e96a088133
Create Date: 2026-01-21 21:47:09.252030
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'e7cb618d3a8a'
down_revision: Union[str, None] = '80e96a088133'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "attendance",
        sa.Column("status", sa.String(), nullable=False),
    )


def downgrade() -> None:
    op.drop_column("attendance", "status")
