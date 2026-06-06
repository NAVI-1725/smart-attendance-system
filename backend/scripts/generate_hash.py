# backend\scripts\generate_hash.py
# backend/scripts/generate_hash.py

from app.core.security import get_password_hash

print(get_password_hash("Password@123"))