"""add trusted ble beacons

Revision ID: dbcc8b91aaee
Revises: a3bca3634f3f
Create Date: 2026-05-31 17:48:12.780087

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = "dbcc8b91aaee"
down_revision: Union[str, None] = "a3bca3634f3f"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "trusted_ble_beacons",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("classroom_id", sa.Integer(), nullable=False),
        sa.Column("beacon_uuid", sa.String(), nullable=False),
        sa.Column("beacon_name", sa.String(), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False, server_default=sa.true()),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("now()"),
            nullable=True,
        ),
        sa.ForeignKeyConstraint(
            ["classroom_id"],
            ["classrooms.id"],
        ),
        sa.PrimaryKeyConstraint("id"),
    )

    op.create_index(
        op.f("ix_trusted_ble_beacons_beacon_uuid"),
        "trusted_ble_beacons",
        ["beacon_uuid"],
        unique=True,
    )

    op.create_index(
        op.f("ix_trusted_ble_beacons_classroom_id"),
        "trusted_ble_beacons",
        ["classroom_id"],
        unique=False,
    )


def downgrade() -> None:
    op.drop_index(
        op.f("ix_trusted_ble_beacons_classroom_id"),
        table_name="trusted_ble_beacons",
    )

    op.drop_index(
        op.f("ix_trusted_ble_beacons_beacon_uuid"),
        table_name="trusted_ble_beacons",
    )

    op.drop_table("trusted_ble_beacons")
