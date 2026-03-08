library(DBI)
library(RPostgres)

con <- dbConnect(
  RPostgres::Postgres(),
  host = Sys.getenv("SUPABASE_HOST"),
  port = as.integer(Sys.getenv("SUPABASE_PORT")),
  dbname = Sys.getenv("SUPABASE_DB"),
  user = Sys.getenv("SUPABASE_USER"),
  password = Sys.getenv("SUPABASE_PASSWORD"),
  sslmode = "require"
)

dbExecute(
  con,
  "
  CREATE TABLE IF NOT EXISTS public.quality_reports (
    id BIGSERIAL PRIMARY KEY,
    park_name TEXT NOT NULL,
    issue_type TEXT NOT NULL,
    severity INTEGER NOT NULL CHECK (severity BETWEEN 1 AND 5),
    notes TEXT,
    reported_by TEXT NOT NULL,
    reported_at TIMESTAMP DEFAULT NOW()
  );
  "
)

dbDisconnect(con)
