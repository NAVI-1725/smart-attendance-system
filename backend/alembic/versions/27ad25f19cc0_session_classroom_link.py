"""session classroom link

Revision ID: 27ad25f19cc0
Revises: 729d4c99f52c
Create Date: 2026-02-03 21:24:52.780903

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '27ad25f19cc0'
down_revision: Union[str, None] = '729d4c99f52c'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ONLY Session → Classroom link (attendance ENUM intentionally excluded)

    op.add_column('sessions', sa.Column('classroom_id', sa.Integer(), nullable=True))
    op.create_foreign_key(
        'sessions_classroom_id_fkey',
        'sessions',
        'classrooms',
        ['classroom_id'],
        ['id']
    )


def downgrade() -> None:
    op.drop_constraint('sessions_classroom_id_fkey', 'sessions', type_='foreignkey')
    op.drop_column('sessions', 'classroom_id')
