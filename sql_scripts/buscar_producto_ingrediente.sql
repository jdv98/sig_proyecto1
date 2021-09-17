CREATE OR REPLACE FUNCTION info_productos(v_cultivo VARCHAR,ingredientes VARCHAR[])
RETURNS TABLE(
	id integer,
	tipo varchar,
	ingrediente varchar,
	cultivo varchar,
	dosis_min float,
	dosis_max float,
	dosis_media float,
	metrica varchar
)
AS $$
BEGIN	
    RETURN QUERY
	SELECT p.*
	FROM unnest(ingredientes) as ing
	INNER JOIN productos as p
	ON ing=p.ingrediente
	WHERE p.cultivo=v_cultivo;
	
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION info_productos(v_cultivo VARCHAR)
RETURNS TABLE (
	id integer,
	tipo varchar,
	ingrediente varchar,
	cultivo varchar,
	dosis_min float,
	dosis_max float,
	dosis_media float,
	metrica varchar
)
AS $$
DECLARE
BEGIN
	RETURN QUERY
	SELECT *
	FROM productos
	WHERE cultivo=v_cultivo;
END $$
LANGUAGE plpgsql;

--SELECT * from info_productos('Piña',ARRAY ['Carbaryl','Oxamyl']);
--SELECT * from info_productos('Piña')