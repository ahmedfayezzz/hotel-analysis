# Hotel Gap Analysis Dashboard

Streamlit dashboard for identifying missing hotel coverage periods in Makkah and Madinah. Connects directly to the PostgreSQL extranet database.

Username: product_team
Password: yuusr@Gaps2025

## Features

- **Direct DB Integration**: Real-time data from PostgreSQL
- **Gap Detection**: Identifies missing dates, boards, and occupancies
- **Filters**: City, star rating, supplier, hotel, date range
- **Supplier View**: Gaps grouped by supplier for easy outreach
- **CSV Export**: Download gaps with dd-mm-yyyy date format
- **Authentication**: Password-protected access

## Quick Start

### 1. Install Dependencies

```bash
cd gap-analysis
pip install -r requirements.txt
```

### 2. Configure Database

Copy `.env.example` to `.env` and add your database connection string:

```bash
cp .env.example .env
```

Edit `.env`:
```
DATABASE_URL=postgresql://user:password@host:port/database
```

### 3. Configure Authentication

Copy `config.yaml.example` to `config.yaml`:

```bash
cp config.yaml.example config.yaml
```

Generate a password hash:
```bash
python -c "import bcrypt; print(bcrypt.hashpw('your_password'.encode(), bcrypt.gensalt()).decode())"
```

Update `config.yaml` with the hash:
```yaml
credentials:
  usernames:
    product_team:
      email: product@tripon.com
      name: Product Team
      password: $2b$12$YOUR_GENERATED_HASH
```

### 4. Run the App

```bash
streamlit run app.py
```

Or with specific port:
```bash
streamlit run app.py --server.port 8503
```

## Usage

### Gap Report Tab

1. Set analysis date range in sidebar
2. (Optional) Add exclusion periods (Ramadan, Hajj, etc.)
3. Select required boards and occupancies
4. Click "Generate Gap Report"
5. Download CSV for supplier communication

### Gap Types

| Type              | Description                                        |
|-------------------|----------------------------------------------------|
| **Date Gap**      | Hotel has no rates at all for the period           |
| **Board Gap**     | Hotel has rates but missing required meal plan     |
| **Occupancy Gap** | Hotel has rates but missing required room capacity |

### Board Equivalents

- **Breakfast**: "Breakfast Included" or "Sohour Included"
- **Lunch**: "Lunch Included" or "Iftar Included"
- **Dinner**: "Dinner Included" or "Iftar Included"

### By Supplier Tab

View gaps grouped by supplier for easy outreach:
- Total gap days per supplier
- Hotels affected
- Download supplier-specific CSV

## Data Source

The dashboard queries these tables from the extranet database:
- `hotels` - Hotel information (filtered by `giata_city_id`)
- `room_types` - Room types with capacity
- `hotel_rates` - Rates with dates and meal types (status = 'approved')
- `suppliers` - Supplier names
- `meal_types` - Meal type lookup

### City IDs

- **Makkah**: `20300`
- **Madinah**: `20299`

## Files

```
gap-analysis/
├── app.py              # Main Streamlit app with auth
├── db.py               # Database connection & queries
├── gap_analyzer.py     # Gap detection logic
├── config.yaml         # Auth credentials (gitignored)
├── config.yaml.example # Auth config template
├── .env                # Database URL (gitignored)
├── .env.example        # Database config template
├── requirements.txt    # Python dependencies
└── README.md           # This file
```

## Security Notes

- `config.yaml` and `.env` should be gitignored
- Cookie key in `config.yaml` should be changed from default
- Password is stored as bcrypt hash
