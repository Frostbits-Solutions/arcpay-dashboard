CREATE TABLE public.mailing_wait_list (
    email text NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT mailing_wait_list_pkey PRIMARY KEY (email)
) TABLESPACE pg_default;

ALTER TABLE public.mailing_wait_list ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public insert on mailing_wait_list" ON public.mailing_wait_list
    FOR INSERT
    TO public
    WITH CHECK (true);

GRANT INSERT ON TABLE public.mailing_wait_list TO anon;
ALTER TABLE public.mailing_wait_list OWNER TO postgres;