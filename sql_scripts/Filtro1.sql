--Recibe los identificadores de las terrazas
CREATE OR REPLACE FUNCTION filtro1(g_id INT[])
RETURNS FLOAT
AS $$
DECLARE
	v_geom geometry[];
BEGIN
	--Transforma el 3857 a 4326 (pero da igual si es el 3857 o el 5367) por problemas de compatibilidad
	--Ademas genera un arreglo de geometrias para posteriormente realizar la union
	v_geom=(SELECT ARRAY_AGG( ST_Transform(t.geom3857,4326) ) FROM terrazas as t
	JOIN UNNEST(g_id) as n ON t.id=n);
	
	--Retorna las hectareas
	RETURN (SELECT (resul/10000) from ST_Area(ST_Union(v_geom),true) as resul);
END $$
LANGUAGE plpgsql;

--SELECT * FROM filtro1(ARRAY[1,2]);