-- Library Book Finder database schema
-- Run in Supabase Dashboard > SQL Editor. This script is safe to re-run.
create extension if not exists pgcrypto;

create table if not exists public.books (
  id uuid primary key default gen_random_uuid(),
  title varchar(180) not null check (char_length(trim(title)) > 0),
  author varchar(140) not null check (char_length(trim(author)) > 0),
  category varchar(80) not null check (char_length(trim(category)) > 0),
  publication_year integer check (publication_year is null or publication_year between 1000 and 2100),
  isbn varchar(20) unique,
  description varchar(1000),
  available boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists books_title_idx on public.books using btree (title);
create index if not exists books_author_idx on public.books using btree (author);
create index if not exists books_category_idx on public.books using btree (category);
create index if not exists books_available_idx on public.books using btree (available);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists books_set_updated_at on public.books;
create trigger books_set_updated_at
before update on public.books
for each row execute function public.set_updated_at();

alter table public.books enable row level security;

-- No anon/authenticated policies are created intentionally. Browser clients cannot
-- read/write directly. The Express API uses a server-only secret key and performs
-- validation. For a real multi-user deployment, add authentication, authorization,
-- rate limiting, and audit logging before exposing catalog management publicly.
revoke all on table public.books from anon, authenticated;
grant select, insert, update, delete on table public.books to service_role;

-- Optional starter records for a fresh demo catalog; these are real database rows,
-- not frontend mock data. Remove this block if you want an initially empty catalog.
insert into public.books (title, author, category, publication_year, isbn, description, available)
values
 ('Clean Code', 'Robert C. Martin', 'Computer Science', 2008, '9780132350884', 'A practical guide to writing readable and maintainable software.', true),
 ('The Pragmatic Programmer', 'Andrew Hunt and David Thomas', 'Computer Science', 1999, '9780201616224', 'Timeless techniques for becoming a more effective programmer.', true),
 ('Atomic Habits', 'James Clear', 'Personal Development', 2018, '9780735211292', 'A guide to building good habits through small, consistent changes.', false),
 ('The Design of Everyday Things', 'Don Norman', 'Design', 2013, '9780465050659', 'An introduction to human-centered design and usability.', true),
 ('A Brief History of Time', 'Stephen Hawking', 'Science', 1988, '9780553380163', 'An accessible introduction to big questions about the universe.', true),
 ('Wings of Fire', 'A. P. J. Abdul Kalam and Arun Tiwari', 'Biography', 1999, '9788173711466', 'The autobiography of scientist and former Indian president A. P. J. Abdul Kalam.', true)
on conflict (isbn) do nothing;
