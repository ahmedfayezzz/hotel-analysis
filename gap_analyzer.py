"""
Gap detection logic for hotel coverage analysis.
"""

import polars as pl
from datetime import date, timedelta
from typing import Optional


# Board equivalence mapping - having any of these satisfies the requirement
BOARD_EQUIVALENTS = {
    "Room Only": ["Room Only"],
    "Breakfast": ["Breakfast Included", "Sohour Included"],
    "Lunch": ["Lunch Included", "Iftar Included"],
    "Dinner": ["Dinner Included", "Iftar Included"],
    "Half Board": ["Half Board"],
    "Full Board": ["Full Board"],
}

# Required occupancies (capacity)
REQUIRED_OCCUPANCIES = {
    "Double": 2,
    "Triple": 3,
    "Quad": 4,
}

# Occupancy codes for rate creation (maps display name to DB code)
OCCUPANCY_CODES = {
    "Double": "DBL",
    "Triple": "TRP",
    "Quad": "QAD",
}

# Board name to meal type code mapping for rate creation
BOARD_TO_MEAL_CODE = {
    "Room Only": "ROOM_ONLY",
    "Breakfast": "BREAKFAST_INCLUDED",
    "Lunch": "LUNCH_INCLUDED",
    "Dinner": "DINNER_INCLUDED",
    "Half Board": "HALF_BOARD",
    "Full Board": "FULL_BOARD",
}


def rates_to_dataframe(rates: list) -> pl.DataFrame:
    """Convert database rates to Polars DataFrame."""
    if not rates:
        return pl.DataFrame({
            "hotel_id": [],
            "organization_id": [],
            "hotel_name": [],
            "city": [],
            "star_rating": [],
            "room_type_id": [],
            "room_name": [],
            "capacity": [],
            "start_date": [],
            "end_date": [],
            "board": [],
            "supplier_id": [],
            "supplier_name": [],
        })

    return pl.DataFrame([dict(r) for r in rates])


def expand_date_ranges(df: pl.DataFrame) -> pl.DataFrame:
    """Expand start_date/end_date into individual daily rows."""
    if len(df) == 0:
        return pl.DataFrame({
            "date": [],
            "hotel_id": [],
            "organization_id": [],
            "hotel_name": [],
            "city": [],
            "star_rating": [],
            "room_name": [],
            "board": [],
            "capacity": [],
            "supplier_id": [],
            "supplier_name": [],
        })

    expanded_rows = []

    for row in df.iter_rows(named=True):
        start_date = row["start_date"]
        end_date = row["end_date"]
        current_date = start_date

        while current_date <= end_date:
            expanded_rows.append({
                "date": current_date,
                "hotel_id": str(row["hotel_id"]),
                "organization_id": str(row["organization_id"]) if row.get("organization_id") else None,
                "hotel_name": row["hotel_name"],
                "city": row["city"],
                "star_rating": row["star_rating"],
                "room_name": row.get("room_name", ""),
                "board": row["board"],
                "capacity": row["capacity"],
                "supplier_id": str(row["supplier_id"]) if row.get("supplier_id") else None,
                "supplier_name": row.get("supplier_name", ""),
            })
            current_date += timedelta(days=1)

    return pl.DataFrame(expanded_rows)


def is_date_excluded(check_date: date, exclusions: list) -> bool:
    """Check if a date falls within any exclusion period."""
    for excl in exclusions:
        if excl["start"] <= check_date <= excl["end"]:
            return True
    return False


def group_consecutive_dates(dates: list) -> list:
    """Group consecutive dates into periods."""
    if not dates:
        return []

    dates = sorted(dates)
    periods = []
    period_start = dates[0]
    prev_date = dates[0]

    for current_date in dates[1:]:
        if (current_date - prev_date).days > 1:
            periods.append({
                "gap_start": period_start,
                "gap_end": prev_date,
                "duration_days": (prev_date - period_start).days + 1,
            })
            period_start = current_date
        prev_date = current_date

    periods.append({
        "gap_start": period_start,
        "gap_end": prev_date,
        "duration_days": (prev_date - period_start).days + 1,
    })

    return periods


def find_hotel_date_gaps(
    daily_df: pl.DataFrame,
    hotel_id: str,
    organization_id: str,
    hotel_name: str,
    city: str,
    star_rating: int,
    suppliers: list,
    start_date: date,
    end_date: date,
    exclusions: list,
) -> list:
    """Find periods where hotel has no availability at all."""
    hotel_data = daily_df.filter(pl.col("hotel_id") == hotel_id)
    hotel_dates = set(hotel_data["date"].to_list())

    gap_dates = []
    current = start_date
    while current <= end_date:
        if not is_date_excluded(current, exclusions):
            if current not in hotel_dates:
                gap_dates.append(current)
        current += timedelta(days=1)

    periods = group_consecutive_dates(gap_dates)
    supplier_names = ", ".join(sorted(suppliers))

    return [
        {
            "hotel_id": hotel_id,
            "organization_id": organization_id,
            "hotel_name": hotel_name,
            "city": city,
            "star_rating": star_rating,
            "supplier_name": supplier_names,
            "gap_type": "date",
            "detail": "No availability",
            "gap_start": p["gap_start"],
            "gap_end": p["gap_end"],
            "duration_days": p["duration_days"],
        }
        for p in periods
    ]


def find_hotel_board_gaps(
    daily_df: pl.DataFrame,
    hotel_id: str,
    organization_id: str,
    hotel_name: str,
    city: str,
    star_rating: int,
    suppliers: list,
    required_boards: list,
    start_date: date,
    end_date: date,
    exclusions: list,
) -> list:
    """Find periods missing required board types."""
    hotel_data = daily_df.filter(pl.col("hotel_id") == hotel_id)
    hotel_dates_set = set(hotel_data["date"].to_list())
    supplier_names = ", ".join(sorted(suppliers))

    all_gaps = []

    for board_name in required_boards:
        equivalent_boards = BOARD_EQUIVALENTS.get(board_name, [board_name])

        # Get dates that have any of the equivalent boards
        board_dates = set(
            hotel_data.filter(pl.col("board").is_in(equivalent_boards))["date"].to_list()
        )

        # Find dates without this board (only where hotel has coverage)
        gap_dates = []
        current = start_date
        while current <= end_date:
            if not is_date_excluded(current, exclusions):
                if current in hotel_dates_set and current not in board_dates:
                    gap_dates.append(current)
            current += timedelta(days=1)

        periods = group_consecutive_dates(gap_dates)

        for p in periods:
            all_gaps.append({
                "hotel_id": hotel_id,
                "organization_id": organization_id,
                "hotel_name": hotel_name,
                "city": city,
                "star_rating": star_rating,
                "supplier_name": supplier_names,
                "gap_type": "board",
                "detail": f"Missing: {board_name}",
                "gap_start": p["gap_start"],
                "gap_end": p["gap_end"],
                "duration_days": p["duration_days"],
            })

    return all_gaps


def find_hotel_occupancy_gaps(
    daily_df: pl.DataFrame,
    hotel_id: str,
    organization_id: str,
    hotel_name: str,
    city: str,
    star_rating: int,
    suppliers: list,
    required_capacities: list,
    start_date: date,
    end_date: date,
    exclusions: list,
) -> list:
    """Find periods missing required occupancies."""
    hotel_data = daily_df.filter(pl.col("hotel_id") == hotel_id)
    hotel_dates_set = set(hotel_data["date"].to_list())
    supplier_names = ", ".join(sorted(suppliers))

    all_gaps = []

    for cap_name, cap_value in REQUIRED_OCCUPANCIES.items():
        if cap_name not in required_capacities:
            continue

        # Get dates that have this capacity
        cap_dates = set(
            hotel_data.filter(pl.col("capacity") == cap_value)["date"].to_list()
        )

        # Find dates without this capacity (only where hotel has coverage)
        gap_dates = []
        current = start_date
        while current <= end_date:
            if not is_date_excluded(current, exclusions):
                if current in hotel_dates_set and current not in cap_dates:
                    gap_dates.append(current)
            current += timedelta(days=1)

        periods = group_consecutive_dates(gap_dates)

        for p in periods:
            all_gaps.append({
                "hotel_id": hotel_id,
                "organization_id": organization_id,
                "hotel_name": hotel_name,
                "city": city,
                "star_rating": star_rating,
                "supplier_name": supplier_names,
                "gap_type": "occupancy",
                "detail": f"Missing: {cap_name} ({cap_value})",
                "gap_start": p["gap_start"],
                "gap_end": p["gap_end"],
                "duration_days": p["duration_days"],
            })

    return all_gaps


def generate_all_hotel_gaps(
    daily_df: pl.DataFrame,
    start_date: date,
    end_date: date,
    exclusions: list,
    required_boards: list,
    required_occupancies: list,
    hotel_filter: Optional[str] = None,
    city_filter: Optional[str] = None,
) -> pl.DataFrame:
    """Generate comprehensive gap report for all hotels."""
    # Get unique hotels and aggregate all their suppliers into a list
    hotels = daily_df.group_by(["hotel_id", "organization_id", "hotel_name", "city", "star_rating"]).agg([
        pl.col("supplier_name").unique().alias("suppliers")
    ])

    # Apply city filter
    if city_filter and city_filter != "All":
        hotels = hotels.filter(pl.col("city") == city_filter)

    # Apply hotel filter
    if hotel_filter:
        hotels = hotels.filter(pl.col("hotel_id") == hotel_filter)

    all_gaps = []

    for row in hotels.iter_rows(named=True):
        hotel_id = row["hotel_id"]
        organization_id = row["organization_id"]
        hotel_name = row["hotel_name"]
        city = row["city"]
        star_rating = row["star_rating"]
        suppliers = row["suppliers"]

        # Date gaps
        date_gaps = find_hotel_date_gaps(
            daily_df, hotel_id, organization_id, hotel_name, city, star_rating, suppliers,
            start_date, end_date, exclusions
        )
        all_gaps.extend(date_gaps)

        # Board gaps
        if required_boards:
            board_gaps = find_hotel_board_gaps(
                daily_df, hotel_id, organization_id, hotel_name, city, star_rating, suppliers,
                required_boards, start_date, end_date, exclusions
            )
            all_gaps.extend(board_gaps)

        # Occupancy gaps
        if required_occupancies:
            occ_gaps = find_hotel_occupancy_gaps(
                daily_df, hotel_id, organization_id, hotel_name, city, star_rating, suppliers,
                required_occupancies, start_date, end_date, exclusions
            )
            all_gaps.extend(occ_gaps)

    if not all_gaps:
        return pl.DataFrame({
            "hotel_id": [],
            "organization_id": [],
            "hotel_name": [],
            "city": [],
            "star_rating": [],
            "supplier_name": [],
            "gap_type": [],
            "detail": [],
            "gap_start": [],
            "gap_end": [],
            "duration_days": [],
        })

    return pl.DataFrame(all_gaps).sort(["hotel_name", "gap_type", "gap_start"])


def get_supplier_summary(gaps_df: pl.DataFrame) -> pl.DataFrame:
    """Group gaps by supplier for easy outreach."""
    if len(gaps_df) == 0:
        return pl.DataFrame({
            "supplier_name": [],
            "hotels_affected": [],
            "total_gaps": [],
            "total_gap_days": [],
        })

    return gaps_df.group_by("supplier_name").agg([
        pl.col("hotel_name").n_unique().alias("hotels_affected"),
        pl.len().alias("total_gaps"),
        pl.col("duration_days").sum().alias("total_gap_days"),
    ]).sort("total_gap_days", descending=True)


def prepare_csv_export_template(gaps_df: pl.DataFrame) -> pl.DataFrame:
    """
    Prepare gap data for CSV export with rate creation template columns.

    Adds empty columns that product team needs to fill:
    - supplier_id, room_type_id, occupancy
    - weekday_rate, weekend_rate, currency, rate_type
    - min_booking_days_in_advance, num_of_rooms, included_meal_type_code
    """
    if len(gaps_df) == 0:
        return gaps_df

    # Format dates for export
    export_df = gaps_df.with_columns([
        pl.col("gap_start").dt.strftime("%Y-%m-%d").alias("start_date"),
        pl.col("gap_end").dt.strftime("%Y-%m-%d").alias("end_date"),
    ])

    # Add empty columns for rate creation (user fills these)
    export_df = export_df.with_columns([
        pl.lit("").alias("supplier_id_to_fill"),
        pl.lit("").alias("room_type_id_to_fill"),
        pl.lit("").alias("occupancy"),
        pl.lit("").alias("weekday_rate"),
        pl.lit("").alias("weekend_rate"),
        pl.lit("SAR").alias("currency"),
        pl.lit("subject_to_availability").alias("rate_type"),
        pl.lit("").alias("min_booking_days_in_advance"),
        pl.lit("").alias("num_of_rooms"),
        pl.lit("").alias("included_meal_type_code"),
    ])

    # Select and order columns for export
    return export_df.select([
        "hotel_id",
        "organization_id",
        "hotel_name",
        "city",
        "star_rating",
        "gap_type",
        "detail",
        "start_date",
        "end_date",
        "duration_days",
        "supplier_name",
        "supplier_id_to_fill",
        "room_type_id_to_fill",
        "occupancy",
        "weekday_rate",
        "weekend_rate",
        "currency",
        "rate_type",
        "min_booking_days_in_advance",
        "num_of_rooms",
        "included_meal_type_code",
    ])
