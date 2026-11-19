-- Schéma Supabase pour Dortoirs d’étourneaux
-- Publier uniquement les lignes validées ; les écritures de modération nécessitent un utilisateur authentifié.
create table if not exists public.sites (
  id text primary key,
  statut text not null default 'en_attente' check (statut in ('en_attente','valide','refuse')),
  data jsonb not null,
  geometry jsonb,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);
create table if not exists public.observations (
  id text primary key,
  statut text not null default 'en_attente' check (statut in ('en_attente','valide','refuse')),
  data jsonb not null,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);
create index if not exists sites_statut_idx on public.sites(statut);
create index if not exists observations_statut_idx on public.observations(statut);
create index if not exists observations_rs_fid_idx on public.observations ((data->>'rs_fid'));
create index if not exists sites_data_gin_idx on public.sites using gin(data);
create index if not exists observations_data_gin_idx on public.observations using gin(data);
alter table public.sites enable row level security;
alter table public.observations enable row level security;
drop policy if exists "lecture publique sites valides" on public.sites;
create policy "lecture publique sites valides" on public.sites for select to anon, authenticated using (statut='valide');
drop policy if exists "lecture publique observations valides" on public.observations;
create policy "lecture publique observations valides" on public.observations for select to anon, authenticated using (statut='valide');
drop policy if exists "moderation sites authentifies" on public.sites;
create policy "moderation sites authentifies" on public.sites for all to authenticated using (true) with check (true);
drop policy if exists "moderation observations authentifies" on public.observations;
create policy "moderation observations authentifies" on public.observations for all to authenticated using (true) with check (true);
drop policy if exists "insertion publique sites en attente" on public.sites;
create policy "insertion publique sites en attente" on public.sites for insert to anon, authenticated with check (statut='en_attente');
drop policy if exists "insertion publique observations en attente" on public.observations;
create policy "insertion publique observations en attente" on public.observations for insert to anon, authenticated with check (statut='en_attente');
drop policy if exists "mise a jour sites attente publique" on public.sites;
create policy "mise a jour sites attente publique" on public.sites for update to anon using (statut='en_attente') with check (statut='en_attente');
drop policy if exists "mise a jour observations attente publique" on public.observations;
create policy "mise a jour observations attente publique" on public.observations for update to anon using (statut='en_attente') with check (statut='en_attente');
drop policy if exists "suppression sites attente publique" on public.sites;
create policy "suppression sites attente publique" on public.sites for delete to anon using (statut='en_attente');
drop policy if exists "suppression observations attente publique" on public.observations;
create policy "suppression observations attente publique" on public.observations for delete to anon using (statut='en_attente');
-- Ne jamais désactiver RLS. L’index/import initial doit être exécuté avec le SQL Editor ou une clé service_role gardée locale.
