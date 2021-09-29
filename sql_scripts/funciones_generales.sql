CREATE OR REPLACE FUNCTION cultivos()
RETURNS TABLE(
	cultivo VARCHAR
)
AS $$
BEGIN
RETURN QUERY
SELECT p.cultivo FROM productos p GROUP BY p.cultivo ORDER BY p.cultivo asc;
END $$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION ingredientes(v_cultivo VARCHAR)
RETURNS TABLE (
	ingrediente VARCHAR
)
AS $$
BEGIN
RETURN QUERY
SELECT p.ingrediente FROM productos p
WHERE p.cultivo=v_cultivo AND (p.metrica ILIKE 'ml/Ha' OR p.metrica ILIKE 'L/Ha')
ORDER BY p.ingrediente asc;
END$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION dosis_ingredientes(v_cultivo VARCHAR,v_ingrediente VARCHAR)
RETURNS TABLE(
    dosis_min FLOAT,
    dosis_media FLOAT,
    dosis_max FLOAT,
    metrica VARCHAR
)
AS $$
BEGIN
RETURN QUERY
SELECT p.dosis_min,p.dosis_media,p.dosis_max,p.metrica FROM productos p
WHERE p.cultivo=v_cultivo AND p.ingrediente=v_ingrediente;
END $$
LANGUAGE plpgsql;

