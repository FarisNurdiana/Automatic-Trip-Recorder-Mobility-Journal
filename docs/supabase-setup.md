# Setup Supabase

## 1. Buat project

1. Buka [supabase.com](https://supabase.com) → **New project**.
2. Catat **Project URL** dan **anon key** dari *Project Settings → API*.

> ⚠️ Jangan pernah memakai **service role key** di aplikasi mobile. Aplikasi
> hanya menggunakan anon key + Row Level Security.

## 2. Jalankan migration

Urut di **SQL Editor** (atau `supabase db push` bila memakai CLI):

1. `supabase/migrations/20260716000001_initial_schema.sql`
   — tabel `profiles`, `trips`, `trip_points`, `activity_events`,
   `sensor_samples`, index, trigger auto-create profile & `updated_at`.
2. `supabase/migrations/20260716000002_rls_policies.sql`
   — mengaktifkan RLS dan seluruh policy.

## 3. Konfigurasi auth

- *Authentication → Providers → Email*: aktif (default).
- *Confirm email*: jika aktif (default), pengguna harus mengklik tautan
  konfirmasi sebelum bisa login. Untuk pengembangan boleh dimatikan.
- Reset password memakai email bawaan Supabase (`resetPasswordForEmail`).

## 4. Isi `.env`

```bash
cp .env.example .env
```

```
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...
```

`.env` masuk `.gitignore` — jangan pernah di-commit.

## 5. Model keamanan (RLS)

| Tabel | Aturan |
|---|---|
| `profiles` | select/update hanya baris milik `auth.uid()` |
| `trips` | select/insert/update/delete hanya jika `user_id = auth.uid()` |
| `trip_points` | seluruh operasi hanya jika trip induknya milik pengguna |
| `activity_events` | seluruh operasi hanya jika `user_id = auth.uid()` |
| `sensor_samples` | seluruh operasi hanya jika trip induknya milik pengguna |

Artinya: pengguna hanya dapat membaca perjalanan miliknya, hanya dapat membuat
perjalanan untuk dirinya sendiri, dan hanya dapat mengubah/menghapus datanya
sendiri — ditegakkan di server, bukan di aplikasi.

## 6. Cara kerja sinkronisasi

- Primary key seluruh tabel adalah **UUID yang dibuat di perangkat**, sehingga
  upload memakai `upsert` dan **idempotent** — retry tidak menduplikasi data.
- Trip points dan sensor samples di-upload **batch 500 baris**.
- `trip_points` dan `sensor_samples` ikut terhapus otomatis ketika trip
  dihapus (`on delete cascade`).
- "Hapus semua data cloud" di halaman Privasi menghapus `activity_events` dan
  `trips` milik pengguna (points/samples ikut lewat cascade).

## 7. PostGIS (opsional)

Skema tidak bergantung pada PostGIS. Jika ingin query geografis lanjutan,
aktifkan extension lalu tambahkan kolom `geography` terpisah:

```sql
create extension if not exists postgis;
alter table public.trip_points
  add column if not exists geom geography(Point, 4326)
  generated always as (st_setsrid(st_makepoint(longitude, latitude), 4326)::geography) stored;
```
