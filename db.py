"""
Database connection and query functions for hotel gap analysis.
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv
from datetime import date
from contextlib import contextmanager

load_dotenv()

# City ID mapping
CITY_IDS = {
    "Makkah": "20300",
    "Madinah": "20299",
}

CITY_NAMES = {v: k for k, v in CITY_IDS.items()}


@contextmanager
def get_connection():
    """Context manager for database connections."""
    conn = psycopg2.connect(os.getenv("DATABASE_URL"))
    try:
        yield conn
    finally:
        conn.close()


def get_hotels(city_filter: str = None) -> list:
    """Get all hotels in Makkah/Madinah."""
    query = """
        SELECT DISTINCT
            h.id as hotel_id,
            h.name as hotel_name,
            CASE h.giata_city_id
                WHEN '20300' THEN 'Makkah'
                WHEN '20299' THEN 'Madinah'
            END as city,
            h.star_rating
        FROM hotels h
        WHERE h.giata_city_id IN ('20300', '20299')
    """
    params = []

    if city_filter and city_filter != "All":
        city_id = CITY_IDS.get(city_filter)
        if city_id:
            query += " AND h.giata_city_id = %s"
            params.append(city_id)

    query += " ORDER BY h.name"

    with get_connection() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(query, params)
            return cur.fetchall()


def get_suppliers() -> list:
    """Get all suppliers with hotel rates."""
    query = """
        SELECT DISTINCT s.id, s.name
        FROM suppliers s
        JOIN hotel_rates hr ON hr.supplier_id = s.id
        JOIN room_types rt ON rt.id = hr.room_type_id
        JOIN hotels h ON h.id = rt.hotel_id
        WHERE hr.status = 'active'
          AND h.giata_city_id IN ('20300', '20299')
        ORDER BY s.name
    """

    with get_connection() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(query)
            return cur.fetchall()


def get_meal_types() -> list:
    """Get all meal types."""
    query = "SELECT code, name FROM meal_types ORDER BY name"

    with get_connection() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(query)
            return cur.fetchall()


def get_hotel_rates(
    start_date: date = None,
    end_date: date = None,
    city_filter: str = None,
    hotel_filter: str = None,
    supplier_filter: str = None,
) -> list:
    """
    Get all approved hotel rates with related data.

    Args:
        start_date: Filter rates that overlap with this start date
        end_date: Filter rates that overlap with this end date
        city_filter: Filter by city name ("Makkah" or "Madinah")
        hotel_filter: Filter by hotel ID
        supplier_filter: Filter by supplier ID
    """
    query = """
        SELECT
            h.id as hotel_id,
            h.name as hotel_name,
            CASE h.giata_city_id
                WHEN '20300' THEN 'Makkah'
                WHEN '20299' THEN 'Madinah'
            END as city,
            h.star_rating,
            rt.id as room_type_id,
            rt.name as room_name,
            rt.max_occupancy as capacity,
            hr.start_date,
            hr.end_date,
            COALESCE(mt.name, 'Room Only') as board,
            s.id as supplier_id,
            s.name as supplier_name
        FROM hotels h
        JOIN room_types rt ON rt.hotel_id = h.id
        JOIN hotel_rates hr ON hr.room_type_id = rt.id
        JOIN suppliers s ON s.id = hr.supplier_id
        LEFT JOIN meal_types mt ON mt.code = hr.included_meal_type_code
        WHERE hr.status = 'active'
          AND h.giata_city_id IN ('20300', '20299')
          AND hr.end_date >= CURRENT_DATE
    """
    params = []

    if start_date:
        query += " AND hr.end_date >= %s"
        params.append(start_date)

    if end_date:
        query += " AND hr.start_date <= %s"
        params.append(end_date)

    if city_filter and city_filter != "All":
        city_id = CITY_IDS.get(city_filter)
        if city_id:
            query += " AND h.giata_city_id = %s"
            params.append(city_id)

    if hotel_filter:
        query += " AND h.id = %s"
        params.append(hotel_filter)

    if supplier_filter:
        query += " AND s.id = %s"
        params.append(supplier_filter)

    query += " ORDER BY h.name, hr.start_date"

    with get_connection() as conn:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(query, params)
            return cur.fetchall()


def test_connection() -> bool:
    """Test database connection."""
    try:
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
                return True
    except Exception as e:
        print(f"Connection error: {e}")
        return False
