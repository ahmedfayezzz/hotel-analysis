-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."activity_duration_unit_enum";
CREATE TYPE "public"."activity_duration_unit_enum" AS ENUM ('minutes', 'hours', 'days');
DROP TYPE IF EXISTS "public"."activity_capacity_type_enum";
CREATE TYPE "public"."activity_capacity_type_enum" AS ENUM ('limited', 'unlimited');

-- Table Definition
CREATE TABLE "public"."activities" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "category_id" uuid NOT NULL,
    "supplier_id" uuid NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "location" text NOT NULL,
    "duration" int4 NOT NULL,
    "duration_unit" "public"."activity_duration_unit_enum" NOT NULL,
    "capacity_type" "public"."activity_capacity_type_enum" NOT NULL DEFAULT 'limited'::activity_capacity_type_enum,
    "max_capacity" int4,
    "min_participants" int4 DEFAULT 1,
    "includes" _text,
    "excludes" _text,
    "requirements" text,
    "terms_and_conditions" text,
    "cancellation_policy" text,
    "is_active" bool NOT NULL DEFAULT true,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "activities_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."activity_categories"("id"),
    CONSTRAINT "activities_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "activities_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."activity_booking_options" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "activity_booking_id" uuid NOT NULL,
    "activity_option_id" uuid NOT NULL,
    "quantity" int4 NOT NULL DEFAULT 1,
    "price" numeric NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "activity_booking_options_activity_booking_id_fkey" FOREIGN KEY ("activity_booking_id") REFERENCES "public"."activity_bookings"("id") ON DELETE CASCADE,
    CONSTRAINT "activity_booking_options_activity_option_id_fkey" FOREIGN KEY ("activity_option_id") REFERENCES "public"."activity_options"("id"),
    CONSTRAINT "activity_booking_options_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX activity_booking_options_booking_option_key ON public.activity_booking_options USING btree (activity_booking_id, activity_option_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."activity_booking_status_enum";
CREATE TYPE "public"."activity_booking_status_enum" AS ENUM ('draft', 'confirmed', 'in_progress', 'completed', 'cancelled');

-- Table Definition
CREATE TABLE "public"."activity_bookings" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "booking_id" uuid NOT NULL,
    "activity_id" uuid NOT NULL,
    "activity_rate_id" uuid NOT NULL,
    "activity_inventory_id" uuid,
    "date" date NOT NULL,
    "start_time" time,
    "adults" int4 NOT NULL DEFAULT 0,
    "children" int4 NOT NULL DEFAULT 0,
    "infants" int4 NOT NULL DEFAULT 0,
    "total_price" numeric NOT NULL,
    "sequence_number" int4 NOT NULL,
    "status" "public"."activity_booking_status_enum" NOT NULL DEFAULT 'draft'::activity_booking_status_enum,
    "confirmation_number" text,
    "special_requests" text,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "activity_bookings_activity_id_fkey" FOREIGN KEY ("activity_id") REFERENCES "public"."activities"("id"),
    CONSTRAINT "activity_bookings_activity_inventory_id_fkey" FOREIGN KEY ("activity_inventory_id") REFERENCES "public"."activity_inventory"("id"),
    CONSTRAINT "activity_bookings_activity_rate_id_fkey" FOREIGN KEY ("activity_rate_id") REFERENCES "public"."activity_rates"("id"),
    CONSTRAINT "activity_bookings_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE,
    CONSTRAINT "activity_bookings_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."activity_categories" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid,
    "name" text NOT NULL,
    "description" text,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "activity_categories_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX activity_categories_organization_id_name_key ON public.activity_categories USING btree (organization_id, name);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."activity_inventory" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "activity_id" uuid NOT NULL,
    "date" date NOT NULL,
    "start_time" time,
    "available_slots" int4,
    "booked_slots" int4 NOT NULL DEFAULT 0,
    "stop_sale" bool NOT NULL DEFAULT false,
    "notes" text,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "activity_inventory_activity_id_fkey" FOREIGN KEY ("activity_id") REFERENCES "public"."activities"("id") ON DELETE CASCADE,
    CONSTRAINT "activity_inventory_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX activity_inventory_org_activity_date_time_key ON public.activity_inventory USING btree (organization_id, activity_id, date, start_time);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."activity_options" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "activity_id" uuid NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "price" numeric NOT NULL,
    "is_required" bool NOT NULL DEFAULT false,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "activity_options_activity_id_fkey" FOREIGN KEY ("activity_id") REFERENCES "public"."activities"("id") ON DELETE CASCADE,
    CONSTRAINT "activity_options_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX activity_options_organization_id_activity_id_name_key ON public.activity_options USING btree (organization_id, activity_id, name);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."activity_rates" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "activity_id" uuid NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "start_date" date NOT NULL,
    "end_date" date NOT NULL,
    "adult_price" numeric NOT NULL,
    "child_price" numeric,
    "infant_price" numeric,
    "currency" text NOT NULL,
    "min_booking_days_in_advance" int4,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "activity_rates_activity_id_fkey" FOREIGN KEY ("activity_id") REFERENCES "public"."activities"("id") ON DELETE CASCADE,
    CONSTRAINT "activity_rates_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX activity_rates_organization_id_activity_id_name_dates_key ON public.activity_rates USING btree (organization_id, activity_id, name, start_date, end_date);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."addon_items" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "name" varchar(255) NOT NULL,
    "description" text,
    "image_url" text,
    "price" numeric,
    "currency" varchar(3),
    "is_active" bool DEFAULT true,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "addon_items_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Comments
COMMENT ON TABLE "public"."addon_items" IS 'Stores reusable add-on items (optional extras) that can be offered with itineraries.';


-- Indices
CREATE INDEX idx_addon_items_organization_id ON public.addon_items USING btree (organization_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."agencies" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "name" text NOT NULL,
    "code" text NOT NULL,
    "agency_group_id" uuid,
    "default_currency" text NOT NULL,
    "status" text NOT NULL DEFAULT 'active'::text,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "account_manager_id" uuid,
    "type" text,
    "country" text,
    "city" text,
    "address" text,
    "postal_code" text,
    "website" text,
    "main_phone" text,
    "main_email" text,
    "payment_terms" text,
    "credit_limit" numeric,
    "market_segment" text,
    CONSTRAINT "agencies_account_manager_id_fkey" FOREIGN KEY ("account_manager_id") REFERENCES "public"."users"("id"),
    CONSTRAINT "agencies_agency_group_id_fkey" FOREIGN KEY ("agency_group_id") REFERENCES "public"."agency_groups"("id"),
    CONSTRAINT "agencies_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."agencies"."account_manager_id" IS 'Reference to the user who manages this agency relationship';
COMMENT ON COLUMN "public"."agencies"."type" IS 'Agency business type: wholesaler, retail, etc.';
COMMENT ON COLUMN "public"."agencies"."credit_limit" IS 'Maximum credit amount allowed for this agency';
COMMENT ON COLUMN "public"."agencies"."market_segment" IS 'Market segment or niche the agency specializes in';


-- Indices
CREATE UNIQUE INDEX agencies_org_code_key ON public.agencies USING btree (organization_id, code);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."agency_contacts" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "agency_id" uuid NOT NULL,
    "position" text,
    "email" text NOT NULL,
    "phone" text,
    "is_primary" bool NOT NULL DEFAULT false,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "name" text,
    CONSTRAINT "agency_contacts_agency_id_fkey" FOREIGN KEY ("agency_id") REFERENCES "public"."agencies"("id") ON DELETE CASCADE,
    CONSTRAINT "agency_contacts_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX agency_contacts_agency_primary_key ON public.agency_contacts USING btree (agency_id) WHERE (is_primary = true)
CREATE UNIQUE INDEX agency_contacts_organization_email_key ON public.agency_contacts USING btree (organization_id, email);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."agency_groups" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "agency_groups_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX agency_groups_org_name_key ON public.agency_groups USING btree (organization_id, name);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."agency_interactions" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "agency_id" uuid NOT NULL,
    "contact_id" uuid,
    "user_id" uuid NOT NULL,
    "interaction_type" text NOT NULL,
    "subject" text NOT NULL,
    "description" text,
    "followup_date" date,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "agency_interactions_agency_id_fkey" FOREIGN KEY ("agency_id") REFERENCES "public"."agencies"("id") ON DELETE CASCADE,
    CONSTRAINT "agency_interactions_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "public"."agency_contacts"("id") ON DELETE SET NULL,
    CONSTRAINT "agency_interactions_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "agency_interactions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."auth_sessions" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "token_hash" text NOT NULL,
    "user_id" uuid,
    "client_id" uuid,
    "organization_id" uuid NOT NULL,
    "platform" text NOT NULL,
    "ip_address" inet,
    "user_agent" text,
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "last_activity_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "expires_at" timestamp NOT NULL,
    CONSTRAINT "auth_sessions_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."website_clients"("id") ON DELETE CASCADE,
    CONSTRAINT "auth_sessions_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "auth_sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX auth_sessions_token_hash_key ON public.auth_sessions USING btree (token_hash);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."booking_component_prices" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "booking_id" uuid NOT NULL,
    "component_type" text NOT NULL,
    "component_id" uuid NOT NULL,
    "cost_price" numeric NOT NULL,
    "base_markup_amount" numeric NOT NULL,
    "manual_markup_adjustment" numeric DEFAULT 0,
    "final_markup_amount" numeric NOT NULL,
    "selling_price" numeric NOT NULL,
    "markup_rule_id" uuid,
    "manual_markup_reason" text,
    "applied_by" uuid,
    "currency" text NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "booking_component_prices_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE,
    CONSTRAINT "booking_component_prices_markup_rule_id_fkey" FOREIGN KEY ("markup_rule_id") REFERENCES "public"."markup_rules"("id"),
    CONSTRAINT "booking_component_prices_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."visibility_enum";
CREATE TYPE "public"."visibility_enum" AS ENUM ('public', 'internal', 'supplier');

-- Table Definition
CREATE TABLE "public"."booking_notes" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "booking_id" uuid NOT NULL,
    "note_type" text NOT NULL,
    "note" text NOT NULL,
    "visibility" "public"."visibility_enum" NOT NULL DEFAULT 'internal'::visibility_enum,
    "created_by" uuid NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "booking_notes_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "booking_notes_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE,
    CONSTRAINT "booking_notes_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."payment_status_enum";
CREATE TYPE "public"."payment_status_enum" AS ENUM ('pending', 'paid', 'partially_paid', 'refunded', 'cancelled');
DROP TYPE IF EXISTS "public"."booking_status_enum";
CREATE TYPE "public"."booking_status_enum" AS ENUM ('draft', 'confirmed', 'in_progress', 'completed', 'cancelled');

-- Table Definition
CREATE TABLE "public"."bookings" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "user_id" uuid NOT NULL,
    "reference_number" text NOT NULL,
    "total_price" numeric NOT NULL,
    "payment_status" "public"."payment_status_enum" NOT NULL DEFAULT 'pending'::payment_status_enum,
    "booking_status" "public"."booking_status_enum" NOT NULL DEFAULT 'draft'::booking_status_enum,
    "currency" text NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "total_paid" numeric NOT NULL DEFAULT 0,
    "deposit_percentage" numeric,
    "balance_due_date" date,
    "agency_id" uuid,
    "website_client_id" uuid,
    "crm_agency_id" uuid,
    "booking_source" text DEFAULT 'portal'::text,
    CONSTRAINT "bookings_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "bookings_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id"),
    CONSTRAINT "bookings_agency_id_fkey" FOREIGN KEY ("agency_id") REFERENCES "public"."agencies"("id"),
    CONSTRAINT "bookings_website_client_id_fkey" FOREIGN KEY ("website_client_id") REFERENCES "public"."website_clients"("id"),
    CONSTRAINT "bookings_crm_agency_id_fkey" FOREIGN KEY ("crm_agency_id") REFERENCES "public"."crm_agencies"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX bookings_reference_number_key ON public.bookings USING btree (reference_number);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."cancellation_policies" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "hotel_rate_id" uuid NOT NULL,
    "policy_type" text NOT NULL,
    "refund_conditions" text NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "cancellation_policies_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "cancellation_policies_hotel_rate_id_fkey" FOREIGN KEY ("hotel_rate_id") REFERENCES "public"."hotel_rates"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."cities" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "geoname_id" int4 NOT NULL,
    "name" varchar(255) NOT NULL,
    "ascii_name" varchar(255),
    "alternate_names" text,
    "feature_class" bpchar(1),
    "feature_code" varchar(10),
    "country_code" varchar(2),
    "country_name" varchar(255),
    "admin1_code" varchar(20),
    "admin2_code" varchar(80),
    "admin3_code" varchar(20),
    "admin4_code" varchar(20),
    "population" int8,
    "elevation" int4,
    "dem" int4,
    "timezone" varchar(40),
    "modification_date" date,
    "label_en" varchar(255),
    "coordinates" point,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX cities_geoname_id_key ON public.cities USING btree (geoname_id)
CREATE INDEX idx_cities_geoname_id ON public.cities USING btree (geoname_id)
CREATE INDEX idx_cities_name ON public.cities USING btree (name)
CREATE INDEX idx_cities_country_code ON public.cities USING btree (country_code)
CREATE INDEX idx_cities_population ON public.cities USING btree (population)
CREATE INDEX idx_cities_coordinates ON public.cities USING gist (coordinates);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."cities_staging" (
    "geoname_id" int4,
    "name" varchar(255),
    "ascii_name" varchar(255),
    "alternate_names" text,
    "feature_class" bpchar(1),
    "feature_code" varchar(10),
    "country_code" varchar(2),
    "country_name" varchar(255),
    "country_code2" varchar(2),
    "admin1_code" varchar(20),
    "admin2_code" varchar(80),
    "admin3_code" varchar(20),
    "admin4_code" varchar(20),
    "population" int8,
    "elevation" int4,
    "dem" int4,
    "timezone" varchar(40),
    "modification_date" date,
    "label_en" varchar(255),
    "coordinates" text
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."client_preferences" (
    "client_id" uuid NOT NULL,
    "preferred_currency" text,
    "preferred_language" text,
    "newsletter_subscribed" bool DEFAULT true,
    "updated_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "client_preferences_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."website_clients"("id") ON DELETE CASCADE,
    PRIMARY KEY ("client_id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."client_wishlists" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "client_id" uuid NOT NULL,
    "item_type" text NOT NULL,
    "item_id" uuid NOT NULL,
    "notes" text,
    "added_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "client_wishlists_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."website_clients"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX client_wishlists_client_id_item_type_item_id_key ON public.client_wishlists USING btree (client_id, item_type, item_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."contact_info" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "contact_name" text NOT NULL,
    "email" text NOT NULL,
    "phone" text NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "booking_id" uuid NOT NULL,
    "website_client_id" uuid,
    "crm_agency_id" uuid,
    CONSTRAINT "contact_info_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "contact_info_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "contact_info_website_client_id_fkey" FOREIGN KEY ("website_client_id") REFERENCES "public"."website_clients"("id"),
    CONSTRAINT "contact_info_crm_agency_id_fkey" FOREIGN KEY ("crm_agency_id") REFERENCES "public"."crm_agencies"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."crm_agencies" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "email" text NOT NULL,
    "first_name" text,
    "last_name" text,
    "phone" text,
    "country" text,
    "is_active" bool DEFAULT true,
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "crm_agencies_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX crm_agencies_organization_id_email_key ON public.crm_agencies USING btree (organization_id, email)
CREATE INDEX idx_crm_agencies_email ON public.crm_agencies USING btree (email)
CREATE INDEX idx_crm_agencies_organization_id ON public.crm_agencies USING btree (organization_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."dmc_websites" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "domain" text NOT NULL,
    "subdomain" text,
    "website_name" text NOT NULL,
    "logo_url" text,
    "favicon_url" text,
    "primary_color" text DEFAULT '#1976d2'::text,
    "secondary_color" text DEFAULT '#dc004e'::text,
    "meta_title" text,
    "meta_description" text,
    "google_analytics_id" text,
    "contact_email" text,
    "contact_phone" text,
    "contact_address" text,
    "is_active" bool DEFAULT true,
    "maintenance_mode" bool DEFAULT false,
    "maintenance_message" text,
    "default_language" text DEFAULT 'en'::text,
    "supported_languages" _text DEFAULT ARRAY['en'::text],
    "default_currency" text DEFAULT 'USD'::text,
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "dmc_websites_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX dmc_websites_organization_id_key ON public.dmc_websites USING btree (organization_id)
CREATE UNIQUE INDEX dmc_websites_domain_key ON public.dmc_websites USING btree (domain)
CREATE UNIQUE INDEX dmc_websites_subdomain_key ON public.dmc_websites USING btree (subdomain);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."email_verification_tokens" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "token_hash" text NOT NULL,
    "client_id" uuid NOT NULL,
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "expires_at" timestamp NOT NULL,
    "verified_at" timestamp,
    CONSTRAINT "email_verification_tokens_client_id_fkey" FOREIGN KEY ("client_id") REFERENCES "public"."website_clients"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX email_verification_tokens_token_hash_key ON public.email_verification_tokens USING btree (token_hash);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."faq_items" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "question" text NOT NULL,
    "answer" text NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "faq_items_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Comments
COMMENT ON TABLE "public"."faq_items" IS 'Stores reusable Frequently Asked Questions content items.';


-- Indices
CREATE INDEX idx_faq_items_organization_id ON public.faq_items USING btree (organization_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."guest_type_enum";
CREATE TYPE "public"."guest_type_enum" AS ENUM ('adult', 'child', 'infant');

-- Table Definition
CREATE TABLE "public"."guests" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "first_name" text NOT NULL,
    "last_name" text NOT NULL,
    "passport_number" text,
    "nationality" text,
    "guest_type" "public"."guest_type_enum" NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "booking_id" uuid NOT NULL,
    CONSTRAINT "guests_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "guests_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."booking_status_enum";
CREATE TYPE "public"."booking_status_enum" AS ENUM ('draft', 'confirmed', 'in_progress', 'completed', 'cancelled');

-- Table Definition
CREATE TABLE "public"."hotel_bookings" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "booking_id" uuid NOT NULL,
    "hotel_id" uuid NOT NULL,
    "room_type_id" uuid NOT NULL,
    "check_in" date NOT NULL,
    "check_out" date NOT NULL,
    "occupancy" text NOT NULL,
    "room_rate" numeric NOT NULL,
    "meal_plan" text,
    "sequence_number" int4 NOT NULL,
    "status" "public"."booking_status_enum" NOT NULL DEFAULT 'draft'::booking_status_enum,
    "special_requests" text,
    CONSTRAINT "hotel_bookings_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "hotel_bookings_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE,
    CONSTRAINT "hotel_bookings_hotel_id_fkey" FOREIGN KEY ("hotel_id") REFERENCES "public"."hotels"("id"),
    CONSTRAINT "hotel_bookings_room_type_id_fkey" FOREIGN KEY ("room_type_id") REFERENCES "public"."room_types"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."hotel_rate_meal_supplements" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "hotel_rate_id" uuid NOT NULL,
    "meal_type_code" text NOT NULL,
    "supplement_price" numeric NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "hotel_rate_meal_supplements_hotel_rate_id_fkey" FOREIGN KEY ("hotel_rate_id") REFERENCES "public"."hotel_rates"("id") ON DELETE CASCADE,
    CONSTRAINT "hotel_rate_meal_supplements_meal_type_code_fkey" FOREIGN KEY ("meal_type_code") REFERENCES "public"."meal_types"("code") ON DELETE CASCADE,
    CONSTRAINT "hotel_rate_meal_supplements_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."hotel_rate_meal_supplements"."supplement_price" IS 'The additional price to upgrade to the specified meal type from the base rate.';


-- Comments
COMMENT ON TABLE "public"."hotel_rate_meal_supplements" IS 'Stores the supplementary charges for upgrading meal plans for a given hotel rate.';


-- Indices
CREATE UNIQUE INDEX hotel_rate_meal_supplements_unique_rate_meal ON public.hotel_rate_meal_supplements USING btree (hotel_rate_id, meal_type_code)
CREATE INDEX idx_hotel_rate_meal_supplements_hotel_rate_id ON public.hotel_rate_meal_supplements USING btree (hotel_rate_id)
CREATE INDEX idx_hotel_rate_meal_supplements_meal_type_code ON public.hotel_rate_meal_supplements USING btree (meal_type_code);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."rate_status_enum";
CREATE TYPE "public"."rate_status_enum" AS ENUM ('draft', 'pending_approval', 'active', 'inactive', 'rejected');

-- Table Definition
CREATE TABLE "public"."hotel_rates" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "hotel_id" uuid NOT NULL,
    "room_type_id" uuid NOT NULL,
    "supplier_id" uuid NOT NULL,
    "start_date" date NOT NULL,
    "end_date" date NOT NULL,
    "occupancy" text NOT NULL,
    "weekday_rate" numeric NOT NULL,
    "weekend_rate" numeric NOT NULL,
    "currency" text NOT NULL,
    "rate_type" text NOT NULL,
    "min_booking_days_in_advance" int4,
    "num_of_rooms" int4,
    "included_meal_type_code" text NOT NULL DEFAULT 'BREAKFAST_INCLUDED'::text,
    "status" "public"."rate_status_enum" NOT NULL DEFAULT 'pending_approval'::rate_status_enum,
    CONSTRAINT "hotel_rates_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "hotel_rates_hotel_id_fkey" FOREIGN KEY ("hotel_id") REFERENCES "public"."hotels"("id"),
    CONSTRAINT "hotel_rates_room_type_id_fkey" FOREIGN KEY ("room_type_id") REFERENCES "public"."room_types"("id"),
    CONSTRAINT "hotel_rates_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id"),
    CONSTRAINT "hotel_rates_included_meal_type_code_fkey" FOREIGN KEY ("included_meal_type_code") REFERENCES "public"."meal_types"("code") ON DELETE SET NULL,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."hotel_rates"."included_meal_type_code" IS 'The code for the meal plan included in the base rate price. NULL indicates a Room Only rate.';
COMMENT ON COLUMN "public"."hotel_rates"."status" IS 'The approval status of the hotel rate. Controls whether the rate is live and bookable.';


-- Indices
CREATE UNIQUE INDEX hotel_rates_organization_id_hotel_id_room_type_id_supplier__key ON public.hotel_rates USING btree (organization_id, hotel_id, room_type_id, supplier_id, start_date, end_date, occupancy)
CREATE INDEX idx_hotel_rates_included_meal_type_code ON public.hotel_rates USING btree (included_meal_type_code)
CREATE INDEX idx_hotel_rates_status ON public.hotel_rates USING btree (status);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."hotels" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "name" text NOT NULL,
    "location" text NOT NULL,
    "description" text,
    "star_rating" int4,
    "amenities" jsonb,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "hotel_code" text,
    "giata_city_id" text,
    CONSTRAINT "hotels_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."inquiries" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "reference_number" text NOT NULL,
    "agency_id" uuid NOT NULL,
    "contact_id" uuid,
    "assigned_to" uuid NOT NULL,
    "travel_date_start" date,
    "travel_date_end" date,
    "number_of_travelers" int4,
    "adults" int4 DEFAULT 0,
    "children" int4 DEFAULT 0,
    "infants" int4 DEFAULT 0,
    "requirements" text,
    "special_requests" text,
    "destination" text,
    "status" text NOT NULL DEFAULT 'new'::text,
    "response_deadline" timestamp,
    "currency" text NOT NULL,
    "estimated_budget" numeric,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "inquiries_agency_id_fkey" FOREIGN KEY ("agency_id") REFERENCES "public"."agencies"("id"),
    CONSTRAINT "inquiries_assigned_to_fkey" FOREIGN KEY ("assigned_to") REFERENCES "public"."users"("id"),
    CONSTRAINT "inquiries_contact_id_fkey" FOREIGN KEY ("contact_id") REFERENCES "public"."agency_contacts"("id") ON DELETE SET NULL,
    CONSTRAINT "inquiries_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itineraries" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "name" varchar(255) NOT NULL,
    "description" text,
    "start_date" date,
    "end_date" date,
    "status" varchar(50) DEFAULT 'draft'::character varying,
    "is_template" bool DEFAULT false,
    "valid_from" date,
    "valid_to" date,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "duration_in_days" int4 NOT NULL DEFAULT 0,
    "features" jsonb,
    CONSTRAINT "itineraries_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Comments
COMMENT ON TABLE "public"."itineraries" IS 'Core table for all itineraries. general_content holds rich text/media. is_template indicates if it is a reusable template. start_date/end_date are for scheduled trips. valid_from/valid_to define the booking window for templates.';

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itinerary_available_addons" (
    "itinerary_id" uuid NOT NULL,
    "addon_item_id" uuid NOT NULL,
    CONSTRAINT "itinerary_available_addons_addon_item_id_fkey" FOREIGN KEY ("addon_item_id") REFERENCES "public"."addon_items"("id") ON DELETE CASCADE,
    CONSTRAINT "itinerary_available_addons_itinerary_id_fkey" FOREIGN KEY ("itinerary_id") REFERENCES "public"."itineraries"("id") ON DELETE CASCADE,
    PRIMARY KEY ("itinerary_id","addon_item_id")
);


-- Comments
COMMENT ON TABLE "public"."itinerary_available_addons" IS 'Links itineraries to the add-on items that are available for selection with them.';


-- Indices
CREATE INDEX idx_itinerary_available_addons_itinerary_id ON public.itinerary_available_addons USING btree (itinerary_id)
CREATE INDEX idx_itinerary_available_addons_addon_item_id ON public.itinerary_available_addons USING btree (addon_item_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itinerary_cities" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "itinerary_id" uuid NOT NULL,
    "duration_days" int4 NOT NULL,
    "display_order" int4 NOT NULL,
    "description" text,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "city_id" uuid NOT NULL,
    "custom_notes" text,
    CONSTRAINT "itinerary_cities_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "public"."cities"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "itinerary_cities_itinerary_id_fkey" FOREIGN KEY ("itinerary_id") REFERENCES "public"."itineraries"("id") ON DELETE CASCADE,
    CONSTRAINT "itinerary_cities_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itinerary_day_images" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "day_id" uuid NOT NULL,
    "media_asset_id" uuid NOT NULL,
    "display_order" int4 NOT NULL,
    "is_cover" bool DEFAULT false,
    "caption" text,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "itinerary_day_images_day_id_fkey" FOREIGN KEY ("day_id") REFERENCES "public"."itinerary_days"("id") ON DELETE CASCADE,
    CONSTRAINT "itinerary_day_images_media_asset_id_fkey" FOREIGN KEY ("media_asset_id") REFERENCES "public"."media_assets"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX itinerary_day_images_day_id_media_asset_id_key ON public.itinerary_day_images USING btree (day_id, media_asset_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itinerary_days" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "itinerary_id" uuid NOT NULL,
    "day_number" int4 NOT NULL,
    "title" varchar(255),
    "description" text,
    "day_content" text,
    CONSTRAINT "itinerary_days_itinerary_id_fkey" FOREIGN KEY ("itinerary_id") REFERENCES "public"."itineraries"("id") ON DELETE CASCADE,
    CONSTRAINT "itinerary_days_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Comments
COMMENT ON TABLE "public"."itinerary_days" IS 'Represents logical days in an itinerary. day_content holds rich text/media specific to the day. day_number is a sequential counter starting from 1';


-- Indices
CREATE UNIQUE INDEX itinerary_days_itinerary_id_day_number_key ON public.itinerary_days USING btree (itinerary_id, day_number)
CREATE INDEX idx_itinerary_days_itinerary_id ON public.itinerary_days USING btree (itinerary_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itinerary_faqs" (
    "itinerary_id" uuid NOT NULL,
    "faq_item_id" uuid NOT NULL,
    "display_order" int4,
    CONSTRAINT "itinerary_faqs_faq_item_id_fkey" FOREIGN KEY ("faq_item_id") REFERENCES "public"."faq_items"("id") ON DELETE CASCADE,
    CONSTRAINT "itinerary_faqs_itinerary_id_fkey" FOREIGN KEY ("itinerary_id") REFERENCES "public"."itineraries"("id") ON DELETE CASCADE,
    PRIMARY KEY ("itinerary_id","faq_item_id")
);


-- Comments
COMMENT ON TABLE "public"."itinerary_faqs" IS 'Links itineraries to their associated reusable FAQs.';


-- Indices
CREATE INDEX idx_itinerary_faqs_itinerary_id ON public.itinerary_faqs USING btree (itinerary_id)
CREATE INDEX idx_itinerary_faqs_faq_item_id ON public.itinerary_faqs USING btree (faq_item_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itinerary_images" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "itinerary_id" uuid NOT NULL,
    "media_asset_id" uuid NOT NULL,
    "display_order" int4 NOT NULL,
    "is_cover" bool DEFAULT false,
    "caption" text,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "itinerary_images_itinerary_id_fkey" FOREIGN KEY ("itinerary_id") REFERENCES "public"."itineraries"("id") ON DELETE CASCADE,
    CONSTRAINT "itinerary_images_media_asset_id_fkey" FOREIGN KEY ("media_asset_id") REFERENCES "public"."media_assets"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX itinerary_images_itinerary_id_media_asset_id_key ON public.itinerary_images USING btree (itinerary_id, media_asset_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itinerary_inquiries" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "website_client_id" uuid,
    "reference_number" text,
    "itinerary_id" uuid NOT NULL,
    "departure_date" date,
    "end_date" date,
    "adults" int4 NOT NULL DEFAULT 0,
    "children" int4 NOT NULL DEFAULT 0,
    "infants" int4 NOT NULL DEFAULT 0,
    "total_travelers" int4,
    "contact_first_name" text NOT NULL,
    "contact_last_name" text NOT NULL,
    "contact_email" text NOT NULL,
    "contact_phone" text,
    "special_requests" text,
    "pricing_data" jsonb,
    "total_price" numeric,
    "price_per_person" numeric,
    "currency" text DEFAULT 'GBP'::text,
    "status" text NOT NULL DEFAULT 'new'::text,
    "source" text DEFAULT 'website'::text,
    "assigned_to" uuid,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "itinerary_inquiries_assigned_to_fkey" FOREIGN KEY ("assigned_to") REFERENCES "public"."users"("id") ON DELETE SET NULL,
    CONSTRAINT "itinerary_inquiries_itinerary_id_fkey" FOREIGN KEY ("itinerary_id") REFERENCES "public"."itineraries"("id") ON DELETE CASCADE,
    CONSTRAINT "itinerary_inquiries_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE CASCADE,
    CONSTRAINT "itinerary_inquiries_website_client_id_fkey" FOREIGN KEY ("website_client_id") REFERENCES "public"."website_clients"("id") ON DELETE SET NULL,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."itinerary_inquiries"."website_client_id" IS 'Reference to the website client who made the inquiry';
COMMENT ON COLUMN "public"."itinerary_inquiries"."reference_number" IS 'Auto-generated unique reference number per organization (format: ITN-YYYYMMDD-XXXXX)';
COMMENT ON COLUMN "public"."itinerary_inquiries"."special_requests" IS 'Customer notes, special requirements, dietary restrictions, etc.';
COMMENT ON COLUMN "public"."itinerary_inquiries"."pricing_data" IS 'Complete pricing breakdown and details from the pricing service (PricingResult object)';
COMMENT ON COLUMN "public"."itinerary_inquiries"."total_price" IS 'Total price extracted from pricing_data for quick access and filtering';
COMMENT ON COLUMN "public"."itinerary_inquiries"."price_per_person" IS 'Price per person extracted from pricing_data for quick access and filtering';
COMMENT ON COLUMN "public"."itinerary_inquiries"."status" IS 'Status of the inquiry: new, contacted, quoted, booked, cancelled';
COMMENT ON COLUMN "public"."itinerary_inquiries"."source" IS 'Source of the inquiry: website, admin_portal, api';


-- Comments
COMMENT ON TABLE "public"."itinerary_inquiries" IS 'Stores customer inquiries for specific itineraries from the booking system';


-- Indices
CREATE UNIQUE INDEX itinerary_inquiries_reference_number_org_unique ON public.itinerary_inquiries USING btree (organization_id, reference_number)
CREATE INDEX itinerary_inquiries_organization_id_idx ON public.itinerary_inquiries USING btree (organization_id)
CREATE INDEX itinerary_inquiries_website_client_id_idx ON public.itinerary_inquiries USING btree (website_client_id)
CREATE INDEX itinerary_inquiries_itinerary_id_idx ON public.itinerary_inquiries USING btree (itinerary_id)
CREATE INDEX itinerary_inquiries_status_idx ON public.itinerary_inquiries USING btree (status)
CREATE INDEX itinerary_inquiries_departure_date_idx ON public.itinerary_inquiries USING btree (departure_date)
CREATE INDEX itinerary_inquiries_total_price_idx ON public.itinerary_inquiries USING btree (total_price)
CREATE INDEX itinerary_inquiries_reference_number_idx ON public.itinerary_inquiries USING btree (reference_number)
CREATE INDEX itinerary_inquiries_created_at_idx ON public.itinerary_inquiries USING btree (created_at);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itinerary_item_activities" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "item_id" uuid NOT NULL,
    "activity_id" uuid NOT NULL,
    "start_time" time,
    "end_time" time,
    "booking_reference" varchar(255),
    "booking_status" varchar(50) DEFAULT 'not_booked'::character varying,
    "participant_count" int4,
    "special_requests" text,
    CONSTRAINT "itinerary_item_activities_activity_id_fkey" FOREIGN KEY ("activity_id") REFERENCES "public"."activities"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "itinerary_item_activities_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."itinerary_items"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX itinerary_item_activities_item_id_key ON public.itinerary_item_activities USING btree (item_id)
CREATE INDEX idx_item_activities_item_id ON public.itinerary_item_activities USING btree (item_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itinerary_item_custom" (
    "id" uuid NOT NULL,
    "item_id" uuid NOT NULL,
    "start_time" time,
    "end_time" time,
    "location" varchar(255),
    "details" text,
    CONSTRAINT "itinerary_item_custom_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."itinerary_items"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX itinerary_item_custom_item_id_key ON public.itinerary_item_custom USING btree (item_id)
CREATE INDEX idx_item_custom_item_id ON public.itinerary_item_custom USING btree (item_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itinerary_item_days" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "item_id" uuid NOT NULL,
    "day_id" uuid,
    "display_order" int4 NOT NULL,
    "day_number" int4,
    CONSTRAINT "itinerary_item_days_day_id_fkey" FOREIGN KEY ("day_id") REFERENCES "public"."itinerary_days"("id") ON DELETE CASCADE,
    CONSTRAINT "itinerary_item_days_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."itinerary_items"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);


-- Comments
COMMENT ON TABLE "public"."itinerary_item_days" IS 'Junction table that maps items to the specific logical days they belong to, allowing different display orders on each day. Implicitly defines item duration.';


-- Indices
CREATE UNIQUE INDEX itinerary_item_days_item_id_day_id_key ON public.itinerary_item_days USING btree (item_id, day_id)
CREATE INDEX idx_itinerary_item_days_item_id ON public.itinerary_item_days USING btree (item_id)
CREATE INDEX idx_itinerary_item_days_day_id ON public.itinerary_item_days USING btree (day_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itinerary_item_hotels" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "item_id" uuid NOT NULL,
    "hotel_id" uuid NOT NULL,
    "check_in_time" time,
    "check_out_time" time,
    "special_requests" text,
    CONSTRAINT "itinerary_item_hotels_hotel_id_fkey" FOREIGN KEY ("hotel_id") REFERENCES "public"."hotels"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "itinerary_item_hotels_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."itinerary_items"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."itinerary_item_hotels"."check_in_time" IS 'Optional: Specific time for check-in on the first day defined in itinerary_item_days';
COMMENT ON COLUMN "public"."itinerary_item_hotels"."check_out_time" IS 'Optional: Specific time for check-out on the last day defined in itinerary_item_days';


-- Indices
CREATE UNIQUE INDEX itinerary_item_hotels_item_id_key ON public.itinerary_item_hotels USING btree (item_id)
CREATE INDEX idx_item_hotels_item_id ON public.itinerary_item_hotels USING btree (item_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itinerary_item_transfers" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "item_id" uuid NOT NULL,
    "transfer_id" uuid NOT NULL,
    "departure_time" time,
    "pickup_location" varchar(255),
    "dropoff_location" varchar(255),
    "booking_reference" varchar(255),
    "booking_status" varchar(50) DEFAULT 'not_booked'::character varying,
    "special_requests" text,
    CONSTRAINT "itinerary_item_transfers_item_id_fkey" FOREIGN KEY ("item_id") REFERENCES "public"."itinerary_items"("id") ON DELETE CASCADE,
    CONSTRAINT "itinerary_item_transfers_transfer_id_fkey" FOREIGN KEY ("transfer_id") REFERENCES "public"."transfers"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX itinerary_item_transfers_item_id_key ON public.itinerary_item_transfers USING btree (item_id)
CREATE INDEX idx_item_transfers_item_id ON public.itinerary_item_transfers USING btree (item_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."itinerary_items" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "itinerary_id" uuid NOT NULL,
    "item_type" varchar(50) NOT NULL,
    "title" varchar(255) NOT NULL,
    "description" text,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "start_day" int4 NOT NULL DEFAULT 0,
    "end_day" int4 NOT NULL DEFAULT 0,
    CONSTRAINT "itinerary_items_itinerary_id_fkey" FOREIGN KEY ("itinerary_id") REFERENCES "public"."itineraries"("id") ON DELETE CASCADE,
    CONSTRAINT "itinerary_items_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."itinerary_items"."item_type" IS 'Determines which type-specific table will contain the details for this item';


-- Comments
COMMENT ON TABLE "public"."itinerary_items" IS 'Generic container for scheduled items (hotels, activities, etc.) in an itinerary, with type-specific details in child tables. Association with specific days and order is handled via the itinerary_item_days table.';


-- Indices
CREATE INDEX idx_itinerary_items_itinerary_id ON public.itinerary_items USING btree (itinerary_id)
CREATE INDEX idx_itinerary_items_item_type ON public.itinerary_items USING btree (item_type);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."login_history" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "email" text NOT NULL,
    "organization_id" uuid,
    "platform" text NOT NULL,
    "success" bool NOT NULL,
    "ip_address" inet,
    "user_agent" text,
    "failure_reason" text,
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "login_history_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE INDEX idx_login_history_email ON public.login_history USING btree (email)
CREATE INDEX idx_login_history_created_at ON public.login_history USING btree (created_at);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."markup_audit_logs" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "profile_id" uuid NOT NULL,
    "rule_id" uuid,
    "user_id" uuid NOT NULL,
    "action" text NOT NULL,
    "previous_data" jsonb,
    "new_data" jsonb,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "markup_audit_logs_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "markup_audit_logs_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."markup_profiles"("id"),
    CONSTRAINT "markup_audit_logs_rule_id_fkey" FOREIGN KEY ("rule_id") REFERENCES "public"."markup_rules"("id") ON DELETE SET NULL,
    CONSTRAINT "markup_audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."markup_conditions" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "rule_id" uuid NOT NULL,
    "condition_type" text NOT NULL,
    "condition_value" jsonb NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "markup_conditions_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "markup_conditions_rule_id_fkey" FOREIGN KEY ("rule_id") REFERENCES "public"."markup_rules"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."markup_profiles" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "profile_type" text NOT NULL DEFAULT 'standard'::text,
    "agency_id" uuid,
    "agency_group_id" uuid,
    "is_default" bool NOT NULL DEFAULT false,
    "created_by" uuid NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "markup_profiles_agency_group_id_fkey" FOREIGN KEY ("agency_group_id") REFERENCES "public"."agency_groups"("id"),
    CONSTRAINT "markup_profiles_agency_id_fkey" FOREIGN KEY ("agency_id") REFERENCES "public"."agencies"("id"),
    CONSTRAINT "markup_profiles_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id"),
    CONSTRAINT "markup_profiles_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX markup_profiles_org_default_key ON public.markup_profiles USING btree (organization_id) WHERE (is_default = true)
CREATE UNIQUE INDEX markup_profiles_org_name_key ON public.markup_profiles USING btree (organization_id, name)
CREATE UNIQUE INDEX markup_profiles_agency_key ON public.markup_profiles USING btree (agency_id) WHERE (agency_id IS NOT NULL)
CREATE UNIQUE INDEX markup_profiles_agency_group_key ON public.markup_profiles USING btree (agency_group_id) WHERE (agency_group_id IS NOT NULL);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."markup_type_enum";
CREATE TYPE "public"."markup_type_enum" AS ENUM ('percentage', 'fixed');

-- Table Definition
CREATE TABLE "public"."markup_rules" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "profile_id" uuid NOT NULL,
    "markup_target" text NOT NULL,
    "entity_id" uuid,
    "supplier_id" uuid,
    "markup_type" "public"."markup_type_enum" NOT NULL,
    "markup_value" numeric NOT NULL,
    "min_markup" numeric,
    "max_markup" numeric,
    "currency" text,
    "priority" int4 NOT NULL DEFAULT 0,
    "start_date" date NOT NULL,
    "end_date" date NOT NULL,
    "is_active" bool NOT NULL DEFAULT true,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "markup_rules_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "markup_rules_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."markup_profiles"("id") ON DELETE CASCADE,
    CONSTRAINT "markup_rules_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE INDEX markup_rules_profile_target_idx ON public.markup_rules USING btree (profile_id, markup_target, entity_id)
CREATE INDEX markup_rules_dates_idx ON public.markup_rules USING btree (start_date, end_date);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."meal_types" (
    "code" text NOT NULL,
    "name" text NOT NULL,
    PRIMARY KEY ("code")
);


-- Comments
COMMENT ON TABLE "public"."meal_types" IS 'Global lookup table for standard meal types (e.g., Breakfast, Half Board).';

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."media_assets" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "file_name" varchar(255) NOT NULL,
    "file_path" text NOT NULL,
    "file_type" varchar(50) NOT NULL,
    "file_size" int4 NOT NULL,
    "alt_text" varchar(255),
    "title" varchar(255),
    "width" int4,
    "height" int4,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "media_assets_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."organization_sequences" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "table_name" text NOT NULL,
    "prefix" text NOT NULL,
    "last_value" int8 NOT NULL DEFAULT 0,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "organization_sequences_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);

-- Column Comments
COMMENT ON COLUMN "public"."organization_sequences"."table_name" IS 'Name of the table this sequence is for';
COMMENT ON COLUMN "public"."organization_sequences"."prefix" IS 'Prefix to use in the reference number (e.g., INQ for inquiries)';


-- Comments
COMMENT ON TABLE "public"."organization_sequences" IS 'Stores organization-specific sequences for reference numbers';


-- Indices
CREATE UNIQUE INDEX organization_sequences_org_table_prefix_key ON public.organization_sequences USING btree (organization_id, table_name, prefix);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."organizations" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "code" text NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX organizations_code_key ON public.organizations USING btree (code);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."password_reset_tokens" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "token_hash" text NOT NULL,
    "email" text NOT NULL,
    "organization_id" uuid,
    "platform" text NOT NULL,
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "expires_at" timestamp NOT NULL,
    "used_at" timestamp,
    CONSTRAINT "password_reset_tokens_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX password_reset_tokens_token_hash_key ON public.password_reset_tokens USING btree (token_hash);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."payment_method_type_enum";
CREATE TYPE "public"."payment_method_type_enum" AS ENUM ('cash', 'bank_transfer', 'credit_card', 'check', 'other');
DROP TYPE IF EXISTS "public"."payment_channel_enum";
CREATE TYPE "public"."payment_channel_enum" AS ENUM ('offline', 'online');

-- Table Definition
CREATE TABLE "public"."payment_methods" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "name" text NOT NULL,
    "type" "public"."payment_method_type_enum" NOT NULL,
    "channel" "public"."payment_channel_enum" NOT NULL DEFAULT 'offline'::payment_channel_enum,
    "is_active" bool NOT NULL DEFAULT true,
    "description" text,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "payment_methods_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."schedule_item_type_enum";
CREATE TYPE "public"."schedule_item_type_enum" AS ENUM ('deposit', 'installment', 'final_payment');
DROP TYPE IF EXISTS "public"."schedule_item_status_enum";
CREATE TYPE "public"."schedule_item_status_enum" AS ENUM ('scheduled', 'due', 'paid', 'partially_paid', 'overdue', 'cancelled');

-- Table Definition
CREATE TABLE "public"."payment_schedule_items" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "payment_schedule_id" uuid NOT NULL,
    "item_type" "public"."schedule_item_type_enum" NOT NULL,
    "amount" numeric NOT NULL,
    "due_date" date NOT NULL,
    "description" text,
    "status" "public"."schedule_item_status_enum" NOT NULL DEFAULT 'scheduled'::schedule_item_status_enum,
    "amount_paid" numeric NOT NULL DEFAULT 0,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "payment_schedule_items_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "payment_schedule_items_payment_schedule_id_fkey" FOREIGN KEY ("payment_schedule_id") REFERENCES "public"."payment_schedules"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."payment_schedule_status_enum";
CREATE TYPE "public"."payment_schedule_status_enum" AS ENUM ('active', 'completed', 'cancelled');

-- Table Definition
CREATE TABLE "public"."payment_schedules" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "booking_id" uuid NOT NULL,
    "status" "public"."payment_schedule_status_enum" NOT NULL DEFAULT 'active'::payment_schedule_status_enum,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "payment_schedules_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE,
    CONSTRAINT "payment_schedules_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."payment_transaction_type_enum";
CREATE TYPE "public"."payment_transaction_type_enum" AS ENUM ('payment', 'refund');
DROP TYPE IF EXISTS "public"."payment_status_detail_enum";
CREATE TYPE "public"."payment_status_detail_enum" AS ENUM ('pending', 'completed', 'failed', 'cancelled');

-- Table Definition
CREATE TABLE "public"."payment_transactions" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "booking_id" uuid NOT NULL,
    "payment_schedule_item_id" uuid,
    "payment_method_id" uuid NOT NULL,
    "transaction_type" "public"."payment_transaction_type_enum" NOT NULL DEFAULT 'payment'::payment_transaction_type_enum,
    "amount" numeric NOT NULL,
    "currency" text NOT NULL,
    "status" "public"."payment_status_detail_enum" NOT NULL DEFAULT 'completed'::payment_status_detail_enum,
    "reference_number" text,
    "receipt_number" text,
    "transaction_date" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "notes" text,
    "received_by" uuid NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "payment_transactions_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE,
    CONSTRAINT "payment_transactions_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "payment_transactions_payment_method_id_fkey" FOREIGN KEY ("payment_method_id") REFERENCES "public"."payment_methods"("id"),
    CONSTRAINT "payment_transactions_payment_schedule_item_id_fkey" FOREIGN KEY ("payment_schedule_item_id") REFERENCES "public"."payment_schedule_items"("id"),
    CONSTRAINT "payment_transactions_received_by_fkey" FOREIGN KEY ("received_by") REFERENCES "public"."users"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."quotations" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "inquiry_id" uuid NOT NULL,
    "reference_number" text NOT NULL,
    "version" int4 NOT NULL DEFAULT 1,
    "created_by" uuid NOT NULL,
    "status" text NOT NULL DEFAULT 'draft'::text,
    "validity_date" date NOT NULL,
    "payment_terms" text,
    "cancellation_policy" text,
    "additional_notes" text,
    "sent_at" timestamp,
    "responded_at" timestamp,
    "response_notes" text,
    "booking_id" uuid,
    "markup_profile_id" uuid,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "quotations_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id"),
    CONSTRAINT "quotations_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."users"("id"),
    CONSTRAINT "quotations_inquiry_id_fkey" FOREIGN KEY ("inquiry_id") REFERENCES "public"."inquiries"("id"),
    CONSTRAINT "quotations_markup_profile_id_fkey" FOREIGN KEY ("markup_profile_id") REFERENCES "public"."markup_profiles"("id"),
    CONSTRAINT "quotations_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."refund_reason_enum";
CREATE TYPE "public"."refund_reason_enum" AS ENUM ('booking_cancellation', 'service_issue', 'customer_request', 'overbooking', 'price_adjustment', 'other');
DROP TYPE IF EXISTS "public"."refund_request_status_enum";
CREATE TYPE "public"."refund_request_status_enum" AS ENUM ('pending', 'approved', 'rejected', 'processed', 'cancelled');

-- Table Definition
CREATE TABLE "public"."refunds" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "booking_id" uuid NOT NULL,
    "amount" numeric NOT NULL,
    "currency" text NOT NULL,
    "reason" "public"."refund_reason_enum" NOT NULL,
    "reason_details" text,
    "status" "public"."refund_request_status_enum" NOT NULL DEFAULT 'pending'::refund_request_status_enum,
    "requested_by" uuid NOT NULL,
    "reviewed_by" uuid,
    "review_date" timestamp,
    "review_notes" text,
    "transaction_id" uuid,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "refunds_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE,
    CONSTRAINT "refunds_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "refunds_requested_by_fkey" FOREIGN KEY ("requested_by") REFERENCES "public"."users"("id"),
    CONSTRAINT "refunds_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "public"."users"("id"),
    CONSTRAINT "refunds_transaction_id_fkey" FOREIGN KEY ("transaction_id") REFERENCES "public"."payment_transactions"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."room_allocations" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "supplier_id" uuid NOT NULL,
    "room_type_id" uuid NOT NULL,
    "start_date" date NOT NULL,
    "end_date" date NOT NULL,
    "allocated_rooms" int4 NOT NULL,
    "release_days" int4 NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "room_allocations_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "room_allocations_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id"),
    CONSTRAINT "room_allocations_room_type_id_fkey" FOREIGN KEY ("room_type_id") REFERENCES "public"."room_types"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."room_inventory" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "room_type_id" uuid NOT NULL,
    "date" date NOT NULL,
    "total_rooms" int4 NOT NULL,
    "sold_rooms" int4 NOT NULL DEFAULT 0,
    "available_rooms" int4 NOT NULL,
    "stop_sale" bool NOT NULL DEFAULT false,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "hotel_rate_id" uuid NOT NULL,
    CONSTRAINT "room_inventory_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "room_inventory_room_type_id_fkey" FOREIGN KEY ("room_type_id") REFERENCES "public"."room_types"("id") ON DELETE CASCADE,
    CONSTRAINT "room_inventory_hotel_rate_id_fkey" FOREIGN KEY ("hotel_rate_id") REFERENCES "public"."hotel_rates"("id") ON DELETE CASCADE ON UPDATE RESTRICT,
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX room_inventory_date_room_type_id_organization_id_hotel_rate_id_ ON public.room_inventory USING btree (date, room_type_id, organization_id, hotel_rate_id);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."room_supplements" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "room_type_id" uuid NOT NULL,
    "name" text NOT NULL,
    "price" numeric NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "room_supplements_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "room_supplements_room_type_id_fkey" FOREIGN KEY ("room_type_id") REFERENCES "public"."room_types"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."room_types" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "hotel_id" uuid NOT NULL,
    "name" text NOT NULL,
    "max_occupancy" int4 NOT NULL,
    "base_capacity" int4 NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "room_types_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "room_types_hotel_id_fkey" FOREIGN KEY ("hotel_id") REFERENCES "public"."hotels"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."spatial_ref_sys" (
    "srid" int4 NOT NULL,
    "auth_name" varchar(256),
    "auth_srid" int4,
    "srtext" varchar(2048),
    "proj4text" varchar(2048),
    PRIMARY KEY ("srid")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."suppliers" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "name" text NOT NULL,
    "contact_email" text,
    "contract_terms" jsonb,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "suppliers_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."booking_status_enum";
CREATE TYPE "public"."booking_status_enum" AS ENUM ('draft', 'confirmed', 'in_progress', 'completed', 'cancelled');

-- Table Definition
CREATE TABLE "public"."transfer_bookings" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "booking_id" uuid NOT NULL,
    "transfer_id" uuid NOT NULL,
    "vehicle_id" uuid NOT NULL,
    "pickup_time" time NOT NULL,
    "pickup_location" text NOT NULL,
    "dropoff_location" text NOT NULL,
    "flight_number" text,
    "sequence_number" int4 NOT NULL,
    "status" "public"."booking_status_enum" NOT NULL DEFAULT 'draft'::booking_status_enum,
    "transfer_notes" text,
    CONSTRAINT "transfer_bookings_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "transfer_bookings_booking_id_fkey" FOREIGN KEY ("booking_id") REFERENCES "public"."bookings"("id") ON DELETE CASCADE,
    CONSTRAINT "transfer_bookings_transfer_id_fkey" FOREIGN KEY ("transfer_id") REFERENCES "public"."transfers"("id"),
    CONSTRAINT "transfer_bookings_vehicle_id_fkey" FOREIGN KEY ("vehicle_id") REFERENCES "public"."vehicles"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."transfer_rates" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "transfer_id" uuid NOT NULL,
    "vehicle_id" uuid NOT NULL,
    "supplier_id" uuid,
    "cost_price" numeric NOT NULL,
    "available_from" date NOT NULL,
    "available_to" date NOT NULL,
    "currency" text NOT NULL,
    CONSTRAINT "transfer_rates_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "transfer_rates_transfer_id_fkey" FOREIGN KEY ("transfer_id") REFERENCES "public"."transfers"("id"),
    CONSTRAINT "transfer_rates_vehicle_id_fkey" FOREIGN KEY ("vehicle_id") REFERENCES "public"."vehicles"("id"),
    CONSTRAINT "transfer_rates_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX transfer_rates_organization_id_transfer_id_vehicle_id_suppl_key ON public.transfer_rates USING btree (organization_id, transfer_id, vehicle_id, supplier_id, available_from, available_to);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

DROP TYPE IF EXISTS "public"."transfer_type_enum";
CREATE TYPE "public"."transfer_type_enum" AS ENUM ('airport', 'point_to_point', 'hourly');

-- Table Definition
CREATE TABLE "public"."transfers" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "name" text NOT NULL,
    "origin" text NOT NULL,
    "destination" text NOT NULL,
    "estimated_duration" int4 NOT NULL,
    "transfer_type" "public"."transfer_type_enum" NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "transfers_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."users" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "email" text NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "password_hash" text NOT NULL,
    "is_active" bool DEFAULT true,
    "role" text NOT NULL DEFAULT 'admin'::text,
    "last_login_at" timestamp,
    "failed_login_attempts" int4 DEFAULT 0,
    "locked_until" timestamp,
    "first_name" text NOT NULL,
    "last_name" text NOT NULL,
    "name" text,
    CONSTRAINT "users_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email)
CREATE INDEX idx_users_email ON public.users USING btree (email)
CREATE INDEX idx_users_organization_id ON public.users USING btree (organization_id)
CREATE INDEX idx_users_name ON public.users USING btree (name);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."vehicle_inventory" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "supplier_id" uuid NOT NULL,
    "vehicle_id" uuid NOT NULL,
    "date" date NOT NULL,
    "total_vehicles" int4 NOT NULL,
    "available_vehicles" int4 NOT NULL,
    "allocated_vehicles" int4 NOT NULL,
    "stop_sale" bool NOT NULL DEFAULT false,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "vehicle_inventory_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    CONSTRAINT "vehicle_inventory_supplier_id_fkey" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id"),
    CONSTRAINT "vehicle_inventory_vehicle_id_fkey" FOREIGN KEY ("vehicle_id") REFERENCES "public"."vehicles"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX vehicle_inventory_organization_id_supplier_id_vehicle_id_da_key ON public.vehicle_inventory USING btree (organization_id, supplier_id, vehicle_id, date);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."vehicles" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "name" text NOT NULL,
    "capacity" int4 NOT NULL,
    "luggage_capacity" int4 NOT NULL,
    "created_at" timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "vehicles_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. Do not use it as a backup.

-- Table Definition
CREATE TABLE "public"."website_clients" (
    "id" uuid NOT NULL DEFAULT gen_random_uuid(),
    "organization_id" uuid NOT NULL,
    "crm_agency_id" uuid,
    "email" text NOT NULL,
    "password_hash" text NOT NULL,
    "first_name" text,
    "last_name" text,
    "phone" text,
    "country" text,
    "is_email_verified" bool DEFAULT false,
    "is_active" bool DEFAULT true,
    "created_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp DEFAULT CURRENT_TIMESTAMP,
    "last_login_at" timestamp,
    "failed_login_attempts" int4 DEFAULT 0,
    "locked_until" timestamp,
    "name" text,
    CONSTRAINT "website_clients_crm_agency_id_fkey" FOREIGN KEY ("crm_agency_id") REFERENCES "public"."crm_agencies"("id"),
    CONSTRAINT "website_clients_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id"),
    PRIMARY KEY ("id")
);


-- Indices
CREATE UNIQUE INDEX website_clients_organization_id_email_key ON public.website_clients USING btree (organization_id, email)
CREATE INDEX idx_website_clients_email ON public.website_clients USING btree (email)
CREATE INDEX idx_website_clients_organization_id ON public.website_clients USING btree (organization_id)
CREATE INDEX idx_website_clients_crm_agency_id ON public.website_clients USING btree (crm_agency_id);

