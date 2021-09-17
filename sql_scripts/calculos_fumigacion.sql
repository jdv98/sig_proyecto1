CREATE OR REPLACE FUNCTION calculos_fumigacion(id_drone INT,id_configuracion INT,area_fumigar FLOAT)
RETURNS TABLE(
	total_descarga_hectarea FLOAT,
	total_llenadas_tanque_hectarea FLOAT,
	total_litros_descargar_area_total FLOAT,
	total_llenadas_tanque_area_total FLOAT
)
AS $$
DECLARE
    v_volumen_descarga FLOAT;
	v_duracion_bateria FLOAT;
	v_capacidad_tanque FLOAT;
	
	total_descarga_hectarea FLOAT;
	total_llenadas_tanque_hectarea FLOAT;
	total_litros_descargar_area_total FLOAT;
	total_llenadas_tanque_area_total FLOAT;
BEGIN
	SELECT  d.duracion_bateria,
			d.capacidad_tanque,
			c.volumen_descarga 
			into v_duracion_bateria, v_capacidad_tanque, v_volumen_descarga
			FROM drones as d
			JOIN configuraciones as c ON c.drone=d.id
			WHERE d.id=id_drone and c.id=id_configuracion;
	
	total_descarga_hectarea:= (v_volumen_descarga*v_duracion_bateria);
	total_llenadas_tanque_hectarea:= (total_descarga_hectarea/v_capacidad_tanque);
	total_litros_descargar_area_total:=(total_descarga_hectarea * area_fumigar);
	total_llenadas_tanque_area_total:=(total_llenadas_tanque_hectarea* area_fumigar);
	
	RETURN QUERY (
		select total_descarga_hectarea,
		total_llenadas_tanque_hectarea,
		total_litros_descargar_area_total,
		total_llenadas_tanque_area_total);
		
	
END $$
LANGUAGE plpgsql;

--SELECT * FROM calculos_fumigacion(1,2,10.0)
