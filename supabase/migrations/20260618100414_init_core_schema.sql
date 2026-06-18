-- Core ingestion schema: tickets, their messages, and KB articles.
-- pgvector extension enabled now (the `chunks` table that uses it comes in a later migration).

create extension if not exists vector;

create table tickets (
  id          uuid primary key default gen_random_uuid(),
  zendesk_id  bigint not null unique,
  subject     text,
  status      text,
  created_at  timestamptz,
  raw         jsonb,
  ingested_at timestamptz default now()
);

create table ticket_messages (
  id           uuid primary key default gen_random_uuid(),
  ticket_id    uuid not null references tickets(id) on delete cascade,
  author_role  text not null check (author_role in ('customer', 'agent')),
  is_public    boolean not null,
  body         text not null,
  created_at   timestamptz
);

-- Supports the gold query: WHERE ticket_id=$1 AND is_public=true AND author_role='agent'
-- Column order = selectivity: ticket_id narrows to one ticket first.
create index on ticket_messages (ticket_id, is_public, author_role);

create table kb_articles (
  id                  uuid primary key default gen_random_uuid(),
  zendesk_article_id  bigint not null unique,
  title               text,
  body                text,
  updated_at          timestamptz,
  raw                 jsonb,
  ingested_at         timestamptz default now()
);
