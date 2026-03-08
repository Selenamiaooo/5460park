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
  INSERT INTO public.quality_reports
  (park_name, issue_type, severity, notes, reported_by)
  VALUES
  ('Central Park', 'Trash Overflow', 3, 'Trash bin full near entrance', 'Staff A'),
  ('Prospect Park', 'Trail Flooding', 4, 'Water on trail after rain', 'Ranger B'),
  ('Bryant Park', 'Playground Damage', 2, 'Loose bolt on slide', 'Staff C'),
  ('Central Park', 'Injury', 5, 'Visitor slipped on wet ground', 'Staff D'),
  ('Riverside Park', 'Restroom Cleanliness', 3, 'Restroom needs cleaning', 'Staff E');
  "
)

dbDisconnect(con)
