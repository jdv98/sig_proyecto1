CREATE OR REPLACE FUNCTION filtro1(g_id INT[])
RETURNS TABLE(
	area_total_terrazas FLOAT
)
AS $$
BEGIN
	SELECT area_terrazas,
       ST_Union(terrazas.g_id) as singlegeom
	FROM UNNEST(g_id) terrazas
	GROUP BY area_terrazas;
	
	RETURN QUERY
	SELECT st_astext(area_terrazas), st_area(area_terrazas) from UNNEST(area_terrazas) area_total_terrazas
	
	
END $$
LANGUAGE plpgsql;

