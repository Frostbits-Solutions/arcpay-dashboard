-- Enable pg_partman extension
CREATE EXTENSION IF NOT EXISTS pg_partman SCHEMA partman;

-- Set up pg_partman for hourly partitioning
-- This will create partitions based on the created_at column with hourly intervals
SELECT partman.create_parent(
    p_parent_table => 'public.transactions',
    p_control_column => 'created_at',
    p_type => 'range',
    p_interval => 'hourly'
);

-- Configure automatic maintenance
UPDATE partman.part_config 
SET infinite_time_partitions = true, automatic_maintenance = 'on'
WHERE parent_table = 'public.transactions';


-- Create a cron job to automatically create new partitions
SELECT cron.schedule('@hourly', $$SELECT partman.run_maintenance()$$);