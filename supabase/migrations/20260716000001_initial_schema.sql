-- TripLog — Initial cloud schema
-- Mirrors the local Drift database. All primary keys are UUIDs generated
-- on-device so that sync operations stay idempotent (upsert by id).

-- Optional: PostGIS. The schema does not depend on it, but if the extension
-- is available the geography columns below can be added later.
-- create extension if not exists postgis;

create extension if not exists "uuid-ossp";

-- ---------------------------------------------------------------------------
-- profiles: one row per auth user. Created automatically via trigger.
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- trips
-- ---------------------------------------------------------------------------
create table if not exists public.trips (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  status text not null default 'finished',
  started_at timestamptz not null,
  ended_at timestamptz,
  start_latitude double precision,
  start_longitude double precision,
  end_latitude double precision,
  end_longitude double precision,
  start_address text,
  end_address text,
  distance_meters double precision not null default 0,
  elapsed_duration_seconds integer not null default 0,
  moving_duration_seconds integer not null default 0,
  stopped_duration_seconds integer not null default 0,
  average_speed_kmh double precision not null default 0,
  moving_average_speed_kmh double precision not null default 0,
  maximum_speed_kmh double precision not null default 0,
  detected_vehicle_type text not null default 'unknown',
  confirmed_vehicle_type text,
  vehicle_confidence double precision,
  vehicle_confirmed_at timestamptz,
  vehicle_prediction_changed boolean,
  stop_count integer not null default 0,
  summary_algorithm_version integer not null default 1,
  device_model text,
  operating_system text,
  operating_system_version text,
  app_version text,
  phone_mount_position text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists trips_user_id_started_at_idx
  on public.trips (user_id, started_at desc);

-- ---------------------------------------------------------------------------
-- trip_points
-- ---------------------------------------------------------------------------
create table if not exists public.trip_points (
  id uuid primary key,
  trip_id uuid not null references public.trips (id) on delete cascade,
  recorded_at timestamptz not null,
  latitude double precision not null,
  longitude double precision not null,
  altitude double precision,
  horizontal_accuracy double precision,
  vertical_accuracy double precision,
  speed double precision,
  speed_accuracy double precision,
  heading double precision,
  heading_accuracy double precision,
  sequence_number integer not null,
  source text,
  is_mocked boolean,
  battery_level double precision
);

create index if not exists trip_points_trip_id_seq_idx
  on public.trip_points (trip_id, sequence_number);

-- ---------------------------------------------------------------------------
-- activity_events
-- ---------------------------------------------------------------------------
create table if not exists public.activity_events (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  trip_id uuid references public.trips (id) on delete set null,
  recorded_at timestamptz not null,
  activity_type text not null,
  transition_type text,
  confidence double precision,
  platform_source text not null,
  raw_payload text
);

create index if not exists activity_events_user_id_recorded_at_idx
  on public.activity_events (user_id, recorded_at desc);

-- ---------------------------------------------------------------------------
-- sensor_samples
-- ---------------------------------------------------------------------------
create table if not exists public.sensor_samples (
  id uuid primary key,
  trip_id uuid not null references public.trips (id) on delete cascade,
  recorded_at timestamptz not null,
  accelerometer_x double precision,
  accelerometer_y double precision,
  accelerometer_z double precision,
  gyroscope_x double precision,
  gyroscope_y double precision,
  gyroscope_z double precision,
  magnetometer_x double precision,
  magnetometer_y double precision,
  magnetometer_z double precision,
  device_orientation text,
  sampling_rate_hz double precision,
  speed double precision,
  activity_state text
);

create index if not exists sensor_samples_trip_id_recorded_at_idx
  on public.sensor_samples (trip_id, recorded_at);

-- ---------------------------------------------------------------------------
-- Trigger: create profile row when a user signs up.
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name)
  values (new.id, new.email, new.raw_user_meta_data ->> 'display_name')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- updated_at maintenance
-- ---------------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trips_set_updated_at on public.trips;
create trigger trips_set_updated_at
  before update on public.trips
  for each row execute function public.set_updated_at();

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();
