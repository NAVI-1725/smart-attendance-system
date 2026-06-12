# backend/app/services/gps_service.py

from datetime import datetime, timezone
from math import asin, cos, radians, sin, sqrt

from app.core.constants.gps import (
    GPS_ACCURACY_THRESHOLD_METERS,
    GPS_MAX_AGE_SECONDS,
)
from app.models.classroom import Classroom
from app.models.enums import GPSValidationResult


EARTH_RADIUS_METERS = 6371000.0


def calculate_distance(
    classroom_lat: float,
    classroom_lon: float,
    student_lat: float,
    student_lon: float,
) -> float:
    """
    Calculate distance between two GPS coordinates using the
    Haversine formula.

    Returns:
        Distance in meters.
    """

    lat1 = radians(float(classroom_lat))
    lon1 = radians(float(classroom_lon))
    lat2 = radians(float(student_lat))
    lon2 = radians(float(student_lon))

    delta_lat = lat2 - lat1
    delta_lon = lon2 - lon1

    haversine = (
        sin(delta_lat / 2) ** 2
        + cos(lat1)
        * cos(lat2)
        * sin(delta_lon / 2) ** 2
    )

    arc = 2 * asin(sqrt(haversine))

    return EARTH_RADIUS_METERS * arc


def validate_accuracy(
    accuracy_meters: float,
) -> bool:
    """
    Validate GPS accuracy.

    Returns:
        True if accuracy is acceptable.
        False otherwise.
    """

    if accuracy_meters is None:
        return False

    return accuracy_meters <= GPS_ACCURACY_THRESHOLD_METERS


def validate_freshness(
    captured_at: datetime,
) -> bool:
    """
    Validate GPS timestamp freshness.

    Returns:
        True if location age is within threshold.
        False otherwise.
    """

    if captured_at is None:
        return False

    now = datetime.now(timezone.utc)

    if captured_at.tzinfo is None:
        captured_at = captured_at.replace(
            tzinfo=timezone.utc,
        )

    age_seconds = (
        now - captured_at
    ).total_seconds()

    if age_seconds < 0:
        return False

    return age_seconds <= GPS_MAX_AGE_SECONDS


def validate_location(
    classroom: Classroom,
    latitude: float,
    longitude: float,
    accuracy_meters: float,
    captured_at: datetime,
) -> tuple[
    GPSValidationResult,
    float | None,
    str | None,
]:
    """
    Main GPS validation entry point.

    Validation Order:
        1. Missing location
        2. Accuracy
        3. Freshness
        4. Distance
        5. Geofence

    Returns:
        (
            GPSValidationResult,
            distance_meters,
            reason,
        )
    """

    if latitude is None or longitude is None:
        return (
            GPSValidationResult.MISSING_LOCATION,
            None,
            "GPS coordinates were not provided.",
        )

    if not validate_accuracy(accuracy_meters):
        return (
            GPSValidationResult.LOW_ACCURACY,
            None,
            (
                f"GPS accuracy {accuracy_meters}m "
                f"exceeds allowed threshold "
                f"{GPS_ACCURACY_THRESHOLD_METERS}m."
            ),
        )

    if not validate_freshness(captured_at):
        return (
            GPSValidationResult.STALE_LOCATION,
            None,
            (
                f"GPS location exceeds maximum age of "
                f"{GPS_MAX_AGE_SECONDS} seconds."
            ),
        )

    distance_meters = calculate_distance(
        classroom_lat=float(classroom.latitude),
        classroom_lon=float(classroom.longitude),
        student_lat=float(latitude),
        student_lon=float(longitude),
    )

    if distance_meters > classroom.gps_radius_meters:
        return (
            GPSValidationResult.OUTSIDE_GEOFENCE,
            distance_meters,
            (
                f"Distance {distance_meters:.2f}m exceeds "
                f"classroom geofence radius "
                f"{classroom.gps_radius_meters}m."
            ),
        )

    return (
        GPSValidationResult.VALID,
        distance_meters,
        (
            f"Location validated within classroom "
            f"geofence radius "
            f"{classroom.gps_radius_meters}m."
        ),
    )