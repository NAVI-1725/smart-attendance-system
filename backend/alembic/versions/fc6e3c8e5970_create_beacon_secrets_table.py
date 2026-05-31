"""create beacon secrets table

Revision ID: fc6e3c8e5970
Revises: dbcc8b91aaee
Create Date: 2026-05-31 21:24:51.543699

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = "fc6e3c8e5970"
down_revision: Union[str, None] = "dbcc8b91aaee"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:

    op.create_table(
        "beacon_secrets",
        sa.Column(
            "id",
            sa.Integer(),
            primary_key=True,
        ),
        sa.Column(
            "beacon_id",
            sa.Integer(),
            sa.ForeignKey("trusted_ble_beacons.id"),
            nullable=False,
        ),
        sa.Column(
            "secret_key",
            sa.String(),
            nullable=False,
        ),
        sa.Column(
            "is_active",
            sa.Boolean(),
            nullable=False,
            server_default=sa.true(),
        ),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
        ),
        sa.UniqueConstraint(
            "beacon_id",
            "secret_key",
            name="uq_beacon_secret",
        ),
    )

    op.create_index(
        "ix_beacon_secrets_beacon_id",
        "beacon_secrets",
        ["beacon_id"],
    )


def downgrade() -> None:

    op.drop_index(
        "ix_beacon_secrets_beacon_id",
        table_name="beacon_secrets",
    )

    op.drop_table("beacon_secrets")
