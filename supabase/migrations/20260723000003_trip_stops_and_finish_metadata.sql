-- Ruteku — trip stops + automatic-finish metadata.
-- Additive only: existing rows are never touched.

alter table public.trips
  add column if not exists finished_automatically boolean not null default false,
  add column if not exists finish_reason text,
  add column if not exists arrival_time_corrected_by_user boolean not null default false;

create table if not exists public.trip_stops (
  id uuid primary key,
  trip_id uuid not null references public.trips (id) on delete cascade,
  arrival_time timestamptz not null,
  departure_time timestamptz,
  duration_seconds integer not null default 0,
  latitude double precision not null,
  longitude double precision not null,
  radius_meters double precision,
  address text,
  stop_type text not null default 'unconfirmed',
  stop_note text,
  is_destination boolean not null default false,
  confirmed_by_user boolean not null default false,
  notification_sent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists trip_stops_trip_id_idx
  on public.trip_stops (trip_id, arrival_time);

alter table public.trip_stops enable row level security;

-- Stops are only reachable through the owning trip.
drop policy if exists "trip_stops_select_own" on public.trip_stops;
create policy "trip_stops_select_own"
  on public.trip_stops for select
  using (exists (
    select 1 from public.trips t
    where t.id = trip_stops.trip_id and t.user_id = auth.uid()
  ));

drop policy if exists "trip_stops_insert_own" on public.trip_stops;
create policy "trip_stops_insert_own"
  on public.trip_stops for insert
  with check (exists (
    select 1 from public.trips t
    where t.id = trip_stops.trip_id and t.user_id = auth.uid()
  ));

drop policy if exists "trip_stops_update_own" on public.trip_stops;
create policy "trip_stops_update_own"
  on public.trip_stops for update
  using (exists (
    select 1 from public.trips t
    where t.id = trip_stops.trip_id and t.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.trips t
    where t.id = trip_stops.trip_id and t.user_id = auth.uid()
  ));

drop policy if exists "trip_stops_delete_own" on public.trip_stops;
create policy "trip_stops_delete_own"
  on public.trip_stops for delete
  using (exists (
    select 1 from public.trips t
    where t.id = trip_stops.trip_id and t.user_id = auth.uid()
  ));
