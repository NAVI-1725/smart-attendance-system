# backend/app/core/constants/security_constants.py

"""
BLE + Attendance Security Constants

Single source of truth for:
- BLE freshness policy
- RSSI trust thresholds
- Replay protection
- Beacon validation requirements
- Packet expiry rules
"""

# =========================================================
# BLE Freshness
# =========================================================

# Maximum acceptable BLE packet age in milliseconds
MAX_BLE_AGE_MS = 45000


# =========================================================
# RSSI Security Thresholds
# =========================================================

# Weak signal warning threshold
RSSI_FLAG_THRESHOLD = -90

# Hard reject threshold
RSSI_REJECT_THRESHOLD = -100


# =========================================================
# Replay Protection
# =========================================================

# Minimum nonce length required
MIN_NONCE_LENGTH = 8


# =========================================================
# Statistical Validation
# =========================================================

# Minimum RSSI variance required to avoid spoof/static replay
MIN_ACCEPTABLE_VARIANCE = 15

# Minimum BLE samples required for validation
MIN_SAMPLE_COUNT = 2

# Minimum unique beacons required
MIN_REQUIRED_BEACONS = 2


# =========================================================
# Allowed BLE Proximity Values
# =========================================================

VALID_PROXIMITIES = {
    "IMMEDIATE",
    "NEAR",
    "MEDIUM",
}


# =========================================================
# BLE Packet Expiry
# =========================================================

# Packet validity duration
BLE_PACKET_EXPIRY_SECONDS = 30

# =========================================================
# Cryptographic Security
# =========================================================

SIGNATURE_HASH_ALGORITHM = "sha256"

MIN_SIGNATURE_LENGTH = 64
