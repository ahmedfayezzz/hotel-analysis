"""
GraphQL client for Hasura mutations - hotel rate creation.
"""

import os
import requests
from typing import Optional
from dotenv import load_dotenv

load_dotenv()

HASURA_URL = os.getenv("HASURA_GRAPHQL_URL")
HASURA_ADMIN_SECRET = os.getenv("HASURA_ADMIN_SECRET")


def get_headers() -> dict:
    """Get headers for Hasura GraphQL requests."""
    return {
        "Content-Type": "application/json",
        "x-hasura-admin-secret": HASURA_ADMIN_SECRET,
    }


def insert_hotel_rate(
    organization_id: str,
    hotel_id: str,
    room_type_id: str,
    supplier_id: str,
    start_date: str,
    end_date: str,
    occupancy: str,
    weekday_rate: float,
    weekend_rate: float,
    currency: str,
    rate_type: str,
    included_meal_type_code: str,
    min_booking_days_in_advance: Optional[int] = None,
    num_of_rooms: Optional[int] = None,
    status: str = "pending_approval",
) -> dict:
    """
    Insert a new hotel rate via Hasura GraphQL.

    Args:
        organization_id: UUID of the organization
        hotel_id: UUID of the hotel
        room_type_id: UUID of the room type
        supplier_id: UUID of the supplier
        start_date: Start date (YYYY-MM-DD format)
        end_date: End date (YYYY-MM-DD format)
        occupancy: Occupancy code (DBL, TRP, QAD)
        weekday_rate: Rate for weekdays
        weekend_rate: Rate for weekends
        currency: Currency code (e.g., SAR)
        rate_type: Rate type (e.g., subject_to_availability)
        included_meal_type_code: Meal type code (e.g., BREAKFAST_INCLUDED)
        min_booking_days_in_advance: Optional minimum booking days
        num_of_rooms: Optional number of rooms
        status: Rate status (default: pending_approval)

    Returns:
        dict with 'data' on success or 'errors' on failure
    """
    if not HASURA_URL or not HASURA_ADMIN_SECRET:
        return {"errors": [{"message": "Hasura configuration missing. Set HASURA_GRAPHQL_URL and HASURA_ADMIN_SECRET in .env"}]}

    mutation = """
    mutation InsertHotelRate($object: hotel_rates_insert_input!) {
        insert_hotel_rates_one(object: $object) {
            id
            status
            start_date
            end_date
            hotel_id
            supplier_id
        }
    }
    """

    # Build the rate object
    rate_object = {
        "organization_id": organization_id,
        "hotel_id": hotel_id,
        "room_type_id": room_type_id,
        "supplier_id": supplier_id,
        "start_date": start_date,
        "end_date": end_date,
        "occupancy": occupancy,
        "weekday_rate": weekday_rate,
        "weekend_rate": weekend_rate,
        "currency": currency,
        "rate_type": rate_type,
        "included_meal_type_code": included_meal_type_code,
        "status": status,
    }

    # Add optional fields if provided
    if min_booking_days_in_advance is not None:
        rate_object["min_booking_days_in_advance"] = min_booking_days_in_advance
    if num_of_rooms is not None:
        rate_object["num_of_rooms"] = num_of_rooms

    variables = {"object": rate_object}

    try:
        response = requests.post(
            HASURA_URL,
            json={"query": mutation, "variables": variables},
            headers=get_headers(),
            timeout=30,
        )
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        return {"errors": [{"message": f"Request failed: {str(e)}"}]}


def insert_meal_supplement(
    organization_id: str,
    hotel_rate_id: str,
    meal_type_code: str,
    supplement_price: float,
) -> dict:
    """
    Insert a meal supplement for a hotel rate.

    Args:
        organization_id: UUID of the organization
        hotel_rate_id: UUID of the hotel rate
        meal_type_code: Meal type code (e.g., LUNCH_INCLUDED)
        supplement_price: Additional price for the meal upgrade

    Returns:
        dict with 'data' on success or 'errors' on failure
    """
    if not HASURA_URL or not HASURA_ADMIN_SECRET:
        return {"errors": [{"message": "Hasura configuration missing"}]}

    mutation = """
    mutation InsertMealSupplement($object: hotel_rate_meal_supplements_insert_input!) {
        insert_hotel_rate_meal_supplements_one(object: $object) {
            id
            meal_type_code
            supplement_price
        }
    }
    """

    variables = {
        "object": {
            "organization_id": organization_id,
            "hotel_rate_id": hotel_rate_id,
            "meal_type_code": meal_type_code,
            "supplement_price": supplement_price,
        }
    }

    try:
        response = requests.post(
            HASURA_URL,
            json={"query": mutation, "variables": variables},
            headers=get_headers(),
            timeout=30,
        )
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        return {"errors": [{"message": f"Request failed: {str(e)}"}]}


def test_hasura_connection() -> bool:
    """Test if Hasura connection is configured and working."""
    if not HASURA_URL or not HASURA_ADMIN_SECRET:
        return False

    query = """
    query TestConnection {
        __typename
    }
    """

    try:
        response = requests.post(
            HASURA_URL,
            json={"query": query},
            headers=get_headers(),
            timeout=10,
        )
        response.raise_for_status()
        result = response.json()
        return "data" in result and "errors" not in result
    except Exception:
        return False
