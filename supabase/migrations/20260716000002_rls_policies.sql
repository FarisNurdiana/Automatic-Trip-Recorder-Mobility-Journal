-- TripLog — Row Level Security
-- Every table is locked down so users can only ever touch their own rows.
-- trip_points and sensor_samples are guarded through their parent trip.

alter table public.profiles enable row level security;
alter table public.trips enable row level security;
alter table public.trip_points enable row level security;
alter table public.activity_events enable row level security;
alter table public.sensor_samples enable row level security;

-- ---------------------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------------------
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- ---------------------------------------------------------------------------
-- trips: full CRUD, own rows only
-- ---------------------------------------------------------------------------
drop policy if exists "trips_select_own" on public.trips;
create policy "trips_select_own"
  on public.trips for select
  using (auth.uid() = user_id);

drop policy if exists "trips_insert_own" on public.trips;
create policy "trips_insert_own"
  on public.trips for insert
  with check (auth.uid() = user_id);

drop policy if exists "trips_update_own" on public.trips;
create policy "trips_update_own"
  on public.trips for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "trips_delete_own" on public.trips;
create policy "trips_delete_own"
  on public.trips for delete
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- trip_points: access only through owned trips
-- ---------------------------------------------------------------------------
drop policy if exists "trip_points_select_own" on public.trip_points;
create policy "trip_points_select_own"
  on public.trip_points for select
  using (exists (
    select 1 from public.trips t
    where t.id = trip_points.trip_id and t.user_id = auth.uid()
  ));

drop policy if exists "trip_points_insert_own" on public.trip_points;
create policy "trip_points_insert_own"
  on public.trip_points for insert
  with check (exists (
    select 1 from public.trips t
    where t.id = trip_points.trip_id and t.user_id = auth.uid()
  ));

drop policy if exists "trip_points_update_own" on public.trip_points;
create policy "trip_points_update_own"
  on public.trip_points for update
  using (exists (
    select 1 from public.trips t
    where t.id = trip_points.trip_id and t.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.trips t
    where t.id = trip_points.trip_id and t.user_id = auth.uid()
  ));

drop policy if exists "trip_points_delete_own" on public.trip_points;
create policy "trip_points_delete_own"
  on public.trip_points for delete
  using (exists (
    select 1 from public.trips t
    where t.id = trip_points.trip_id and t.user_id = auth.uid()
  ));

-- ---------------------------------------------------------------------------
-- activity_events: own rows only
-- ---------------------------------------------------------------------------
drop policy if exists "activity_events_select_own" on public.activity_events;
create policy "activity_events_select_own"
  on public.activity_events for select
  using (auth.uid() = user_id);

drop policy if exists "activity_events_insert_own" on public.activity_events;
create policy "activity_events_insert_own"
  on public.activity_events for insert
  with check (auth.uid() = user_id);

drop policy if exists "activity_events_update_own" on public.activity_events;
create policy "activity_events_update_own"
  on public.activity_events for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "activity_events_delete_own" on public.activity_events;
create policy "activity_events_delete_own"
  on public.activity_events for delete
  using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- sensor_samples: access only through owned trips
-- ---------------------------------------------------------------------------
drop policy if exists "sensor_samples_select_own" on public.sensor_samples;
create policy "sensor_samples_select_own"
  on public.sensor_samples for select
  using (exists (
    select 1 from public.trips t
    where t.id = sensor_samples.trip_id and t.user_id = auth.uid()
  ));

drop policy if exists "sensor_samples_insert_own" on public.sensor_samples;
create policy "sensor_samples_insert_own"
  on public.sensor_samples for insert
  with check (exists (
    select 1 from public.trips t
    where t.id = sensor_samples.trip_id and t.user_id = auth.uid()
  ));

drop policy if exists "sensor_samples_update_own" on public.sensor_samples;
create policy "sensor_samples_update_own"
  on public.sensor_samples for update
  using (exists (
    select 1 from public.trips t
    where t.id = sensor_samples.trip_id and t.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from public.trips t
    where t.id = sensor_samples.trip_id and t.user_id = auth.uid()
  ));

drop policy if exists "sensor_samples_delete_own" on public.sensor_samples;
create policy "sensor_samples_delete_own"
  on public.sensor_samples for delete
  using (exists (
    select 1 from public.trips t
    where t.id = sensor_samples.trip_id and t.user_id = auth.uid()
  ));
