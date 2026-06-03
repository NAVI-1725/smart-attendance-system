"""add_ble_evidence_forensics_fields

Revision ID: 96580a6105c4
Revises: fc6e3c8e5970
Create Date: 2026-06-03 12:58:03.033140

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = '96580a6105c4'
down_revision: Union[str, None] = 'fc6e3c8e5970'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:

    op.add_column(
        "attendance_ble_evidence",
        sa.Column(
            "device_id",
            sa.Integer(),
            nullable=True,
        ),
    )

    op.add_column(
        "attendance_ble_evidence",
        sa.Column(
            "client_timestamp",
            sa.DateTime(timezone=True),
            nullable=True,
        ),
    )

    op.add_column(
        "attendance_ble_evidence",
        sa.Column(
            "server_received_timestamp",
            sa.DateTime(timezone=True),
            nullable=True,
        ),
    )


def downgrade() -> None:

    op.drop_column(
        "attendance_ble_evidence",
        "server_received_timestamp",
    )

    op.drop_column(
        "attendance_ble_evidence",
        "client_timestamp",
    )

    op.drop_column(
        "attendance_ble_evidence",
        "device_id",
    )