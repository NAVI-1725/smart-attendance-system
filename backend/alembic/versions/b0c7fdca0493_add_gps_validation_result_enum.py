"""add_gps_validation_result_enum

Revision ID: b0c7fdca0493
Revises: 581304ef2f16
Create Date: 2026-06-07 13:44:51.027095

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'b0c7fdca0493'
down_revision: Union[str, None] = '581304ef2f16'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    gps_validation_result = sa.Enum(
        "VALID",
        "OUTSIDE_GEOFENCE",
        "LOW_ACCURACY",
        "STALE_LOCATION",
        "MISSING_LOCATION",
        name="gps_validation_result",
    )

    gps_validation_result.create(
        op.get_bind(),
        checkfirst=True,
    )

    op.alter_column(
        "attendance_gps_evidence",
        "validation_result",
        existing_type=sa.VARCHAR(length=50),
        type_=gps_validation_result,
        existing_nullable=True,
        postgresql_using=(
            "validation_result::gps_validation_result"
        ),
    )


def downgrade() -> None:
    gps_validation_result = sa.Enum(
        "VALID",
        "OUTSIDE_GEOFENCE",
        "LOW_ACCURACY",
        "STALE_LOCATION",
        "MISSING_LOCATION",
        name="gps_validation_result",
    )

    op.alter_column(
        "attendance_gps_evidence",
        "validation_result",
        existing_type=gps_validation_result,
        type_=sa.VARCHAR(length=50),
        existing_nullable=True,
    )

    gps_validation_result.drop(
        op.get_bind(),
        checkfirst=True,
    )