CREATE OR REPLACE FUNCTION info_productos(cultivos VARCHAR[],ingredientes VARCHAR[])
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
DECLARE
    arr_size INTEGER;
BEGIN	
	arr_size := array_length(cultivos, 1);
	raise notice '%',arr_size;

    FOR i IN 1..arr_size LOOP
		RETURN QUERY
		SELECT * FROM productos as p
		WHERE p.cultivo=cultivos[i] AND p.ingrediente=ingredientes[i];
    END LOOP;
	
END $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION info_productos(cultivos VARCHAR[])
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
	SELECT p.*
	FROM unnest(cultivos) as c
	INNER JOIN productos as p
	ON c=p.cultivo;
END $$
LANGUAGE plpgsql;

SELECT * from info_productos(ARRAY ['Piña','Papa'],ARRAY ['Carbaryl','Clorpirifos']);
SELECT * from info_productos(ARRAY ['Piña','Papa'])
