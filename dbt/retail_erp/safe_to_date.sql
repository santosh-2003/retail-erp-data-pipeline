CREATE OR REPLACE FUNCTION safe_to_date(txt text)
RETURNS date AS $$
BEGIN
    RETURN txt::date;
EXCEPTION WHEN others THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
