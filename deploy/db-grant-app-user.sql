-- Run once as doadmin against sailing_plans after Terraform creates the cluster.
-- Required on Postgres 15+ so the app user can own migrations in schema public.
GRANT CONNECT ON DATABASE sailing_plans TO sailing;
GRANT USAGE, CREATE ON SCHEMA public TO sailing;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO sailing;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO sailing;
ALTER DATABASE sailing_plans OWNER TO sailing;
