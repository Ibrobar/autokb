-- Enable Row-Level Security on all core tables.
-- No policies are defined on purpose: RLS-on + zero policies = deny-all through the
-- public REST API (anon/authenticated roles). Our ingestion worker connects as the
-- table owner (postgres role), which bypasses RLS, so server-side access is unaffected.
-- This closes the "anon key can read PII via the auto API" hole (spec principle #6).
--
-- `enable row level security` is idempotent — safe to re-run if it was already toggled
-- on in the dashboard.

alter table tickets         enable row level security;
alter table ticket_messages enable row level security;
alter table kb_articles     enable row level security;
