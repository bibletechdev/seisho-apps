-- 聖書であそぼう: オンラインランキング（エデンの園）と いいね集計 のテーブル
-- Supabase ダッシュボード → SQL Editor に貼り付けて Run する

-- ---- ランキング（eden/index.html の RANK_CFG が使う） ----
create table if not exists public.scores (
  id bigint generated always as identity primary key,
  name text not null check (char_length(name) between 1 and 10),
  score integer not null check (score between 0 and 1000000),
  created_at timestamptz not null default now()
);
create index if not exists scores_rank_idx on public.scores (score desc, created_at asc);
alter table public.scores enable row level security;
drop policy if exists "scores are readable" on public.scores;
create policy "scores are readable" on public.scores for select to anon, authenticated using (true);
drop policy if exists "anyone can add a score" on public.scores;
create policy "anyone can add a score" on public.scores for insert to anon, authenticated with check (true);
grant select, insert on public.scores to anon, authenticated;

-- ---- いいね（index.html の LIKE_CFG が使う） ----
create table if not exists public.likes (
  id bigint generated always as identity primary key,
  app text not null check (app in ('supple', 'eden', 'noah', 'quiz')),
  created_at timestamptz not null default now()
);
alter table public.likes enable row level security;
drop policy if exists "anyone can like" on public.likes;
create policy "anyone can like" on public.likes for insert to anon, authenticated with check (true);
grant insert on public.likes to anon, authenticated;

-- アプリごとのいいね数（集計値だけを公開する）
create or replace view public.like_counts as
  select app, count(*)::int as n from public.likes group by app;
grant select on public.like_counts to anon, authenticated;
