"""remove classroom ownership

Revision ID: 287e55d1799c
Revises: 2d162ce3cec5
Create Date: 2026-06-18 14:50:07.449187

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '287e55d1799c'
down_revision: Union[str, None] = '2d162ce3cec5'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:

    op.drop_constraint(
        "classrooms_faculty_id_fkey",
        "classrooms",
        type_="foreignkey",
    )

    op.drop_column(
        "classrooms",
        "faculty_id",
    )


def downgrade() -> None:

    op.add_column(
        "classrooms",
        sa.Column(
            "faculty_id",
            sa.Integer(),
            nullable=True,
        ),
    )

    op.create_foreign_key(
        "classrooms_faculty_id_fkey",
        "classrooms",
        "users",
        ["faculty_id"],
        ["id"],
    )