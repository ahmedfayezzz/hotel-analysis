# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hotel Gap Analysis Dashboard - a Streamlit application that identifies missing hotel coverage periods (date gaps, board gaps, occupancy gaps) for Makkah and Madinah hotels.

## Commands

```bash
# Install dependencies
pip install -r requirements.txt

# Run the application
streamlit run app.py

# Run on specific port
streamlit run app.py --server.port 8503
```

## Architecture

Three-layer structure:

- **app.py** - Streamlit dashboard with authentication, caching, and multi-tab UI (Gap Report, By Supplier, Summary, Visualizations, Fill Gaps)
- **db.py** - PostgreSQL connection layer using context managers; queries join 6 tables (hotels, room_types, hotel_rates, suppliers, meal_types)
- **gap_analyzer.py** - Business logic using Polars DataFrames for gap detection
- **graphql_client.py** - Hasura GraphQL client for creating new hotel rates

**Key entry points:**
- `generate_all_hotel_gaps()` - Main gap detection function, returns Polars DataFrame
- `expand_date_ranges()` - Converts rate periods to daily rows for precise analysis
- `get_supplier_summary()` - Aggregates gaps by supplier for outreach
- `prepare_csv_export_template()` - Prepares gap data with rate creation columns for Excel export
- `insert_hotel_rate()` - Creates new rate via Hasura GraphQL mutation

**Database tables:** hotels → room_types → hotel_rates ← suppliers, meal_types. Query filters by `hotel_rates.status = 'active'` and `hotels.giata_city_id`.

## Key Domain Concepts

**Gap Types:**
- Date gaps: Periods with no hotel availability
- Board gaps: Missing meal plans for available dates
- Occupancy gaps: Missing room capacities (Double/Triple/Quad)

**Board Equivalents:** Flexible meal plan matching system where:
- Breakfast = "Breakfast Included" OR "Sohour Included"
- Lunch = "Lunch Included" OR "Iftar Included"
- Dinner = "Dinner Included" OR "Iftar Included"

**City IDs:** Makkah (20300), Madinah (20299)

## Configuration

Requires two files (both gitignored):
- `.env` - Contains DATABASE_URL for PostgreSQL, and optionally Hasura credentials
- `config.yaml` - Authentication credentials with bcrypt password hashes

**.env variables:**
```
DATABASE_URL=postgresql://user:password@host:port/database
HASURA_GRAPHQL_URL=https://your-hasura-endpoint/v1/graphql
HASURA_ADMIN_SECRET=your-admin-secret
```

Generate password hash for local setup:
```bash
python -c "import bcrypt; print(bcrypt.hashpw('your_password'.encode(), bcrypt.gensalt()).decode())"
```

See `config.yaml.example` for auth template. Supports environment variables for production deployment (AUTH_USERNAME, AUTH_PASSWORD_HASH, etc.).

## Data Flow

1. DB queries fetch active hotel_rates with related data
2. Data cached with `@st.cache_data` to reduce DB load (cleared via "Refresh Data" button)
3. Filters applied client-side on cached Polars DataFrames
4. Gap analyzer expands date ranges to daily records for precise gap detection
5. User-defined exclusion periods (Ramadan, Hajj) are respected in analysis

## Rate Filling Feature

Two ways to fill identified gaps:

1. **Excel Template Export** - Downloads multi-sheet Excel with:
   - Gaps_Template: Gap data with empty rate columns to fill
   - Suppliers, Room_Types, Meal_Types, Occupancy_Codes: Reference sheets

2. **Fill Gaps Tab** - In-app form to create rates directly:
   - Select gap → fill supplier, room type, occupancy, rates, meal type
   - Submits via Hasura GraphQL to insert into hotel_rates table
   - Requires HASURA_GRAPHQL_URL and HASURA_ADMIN_SECRET in .env

**Occupancy codes:** Double=DBL, Triple=TRP, Quad=QAD
