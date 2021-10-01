--Retorna solo los que tienen asociados productos con ingredientes en ml y litros
CREATE OR REPLACE FUNCTION cultivos()
RETURNS TABLE(
	cultivo VARCHAR
)
AS $$
BEGIN
RETURN QUERY
SELECT p.cultivo FROM productos p 
WHERE (p.metrica ILIKE 'ml/Ha' OR p.metrica ILIKE 'L/Ha')
GROUP BY p.cultivo ORDER BY p.cultivo asc;
END $$
LANGUAGE plpgsql;

--Devuelve solo los productos que esten en ml y litros de un respectivo cultivo
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

--devuelve el tipo de medida y las dosis de un ingrediente
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

--Informacion basica sobre los drones
CREATE OR REPLACE FUNCTION drones()
RETURNS TABLE(
    id int,
	duracion_bateria FLOAT,
	capacidad_tanque FLOAT
)
AS $$
BEGIN
RETURN QUERY
SELECT d.id,d.duracion_bateria,d.capacidad_tanque FROM drones d;
END $$
LANGUAGE plpgsql;


--recibe el id de un drone y retorna todas las configuraciones relacionadas
CREATE OR REPLACE FUNCTION dron_configuraciones(v_id INT)
RETURNS TABLE(
	id INT,
	ancho_cobertura FLOAT,
	volumen_descarga FLOAT,
	baterias_x_ha FLOAT
)
AS $$
BEGIN
RETURN QUERY
SELECT c.id,c.ancho_cobertura,c.volumen_descarga,c.baterias_x_ha FROM configuraciones c
WHERE c.drone=v_id;
END $$
LANGUAGE plpgsql;
