--Recibe los identificadores de los bloques y las terrazas
--Aplica un diferencia entre los bloques y las terrazas, eliminando las areas de los bloques
--que esten en contacto las terrazas
CREATE OR REPLACE FUNCTION filtro2(b_id INT[],t_id INT[])
RETURNS FLOAT
AS $$
DECLARE
	t_geom geometry;
	b_geom geometry;
BEGIN
	--Transforma el geom3857 a 4326, en este punto se es indiferente si se transformara el 3857 o el 5367
	--la transformacion es necesaria por temas de compatibilidad con las funciones utilizadas
	t_geom=(SELECT ST_Union(ARRAY_AGG(ST_Transform(t.geom3857,4326))) FROM terrazas as t
	JOIN UNNEST(t_id) as n ON t.id=n);
	
	b_geom=(SELECT ST_Union(ARRAY_AGG(ST_Transform(b.geom3857,4326))) FROM bloques as b
	JOIN UNNEST(b_id) as n ON b.id=n);
	
	--Retorna las hectareas
	RETURN (SELECT ST_Area(ST_Difference(b_geom,t_geom),true)/10000);
END $$
LANGUAGE plpgsql;

--SELECT * FROM filtro2(ARRAY[1],ARRAY[1,2]);