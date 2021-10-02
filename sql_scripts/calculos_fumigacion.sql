--Recibe el id del dron, id de la configuracion, area en hectareas y un arreglo con las dosis en litros
CREATE OR REPLACE FUNCTION calculos_fumigacion(id_drone INT,id_configuracion INT,area_fumigar FLOAT,v_dosis FLOAT[])
RETURNS TABLE(
	total_descarga_hectarea FLOAT,--'Total de descarga por Ha en litros por hectárea',
	total_llenadas_tanque_hectarea FLOAT, --'Total de llenadas de tanque por hectárea',
	total_litros_descargar_area_total FLOAT,--'Total litros a descargar por área total en litros',
	total_llenadas_tanque_area_total FLOAT,--'Total de llenadas de tanque por área total',
	total_producto_N_por_tanque FLOAT[],--'Total de Producto N por Tanque en litros por tanque',
	total_de_agua_x_tanque_LTanque FLOAT,--'Total de agua por tanque en litros por tanque',	
	total_producto_N_x_ha_litros_x_ha FLOAT[],--'Total de Producto N por hectárea en litros por hectárea',
	total_agua_x_ha_en_LHa FLOAT,--'Total de Agua por hectárea en litros por hectárea',
	total_descarga_x_ha_en_LHa FLOAT,--'Total de descarga por hectárea en litros por hectárea',
	total_Producto_N_x_area_total_en_LTotalHa FLOAT[],--'Total de Producto N x área total en litros por total de total de hectáreas',
	total_agua_x_area_total_en_LTotalHa FLOAT,--'Total de Agua por área total en Litros por total de hectáreas',
	total_descarga_x_area_total_en_LTotalHa FLOAT,--'Total de descarga por área total en Litros por total de hectáreas'
	area_a_fumigar FLOAT
) 
AS $$
DECLARE
    v_volumen_descarga FLOAT;
	v_duracion_bateria FLOAT;
	v_capacidad_tanque FLOAT;
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
	
	--arreglo de dosis
	SELECT tpt INTO total_producto_N_por_tanque 
	FROM total_producto_por_tanque_litros(v_dosis,total_llenadas_tanque_hectarea) as tpt;
	
	--'Total de agua por tanque en litros por tanque'
	--A la capacidad del tanque le resta todas las dosis
	--Nota: 'Total Descarga x Tanque en L/Tanque' es al que se le resta pero es igual a la capacidad del tanque
	total_de_agua_x_tanque_LTanque:=v_capacidad_tanque;
	FOR i IN 1..ARRAY_LENGTH(total_producto_N_por_tanque,1) loop
		total_de_agua_x_tanque_LTanque:=(total_de_agua_x_tanque_LTanque-total_producto_N_por_tanque[i]);
	END LOOP;
	
	--crea un arreglo para 'Total de Producto 1 por hectárea en litros por hectárea'
	FOR i IN 1..ARRAY_LENGTH(total_producto_N_por_tanque,1) loop
		total_producto_N_x_ha_litros_x_ha:=array_append(total_producto_N_x_ha_litros_x_ha,( total_llenadas_tanque_hectarea * total_producto_N_por_tanque[i] ));
	END LOOP;
	
	--'Total de Agua por hectárea en litros por hectárea'
	total_agua_x_ha_en_LHa:=(total_de_agua_x_tanque_LTanque*total_llenadas_tanque_hectarea);
	
	--'Total de descarga por hectárea en litros por hectárea'
	--Recorre 'Total de Producto N por hectárea en litros por hectárea' y lo suma con el total de agua x hectarea en L/HA
	total_descarga_x_ha_en_LHa:=total_agua_x_ha_en_LHa;
	FOR i IN 1..ARRAY_LENGTH(total_producto_N_x_ha_litros_x_ha,1) loop
		total_descarga_x_ha_en_LHa:=(total_descarga_x_ha_en_LHa+total_producto_N_x_ha_litros_x_ha[i]);
	END LOOP;
	
	--'Total de Producto N x área total en litros por total de total de hectáreas'
	FOR i IN 1..ARRAY_LENGTH(total_producto_N_x_ha_litros_x_ha,1) loop
		total_Producto_N_x_area_total_en_LTotalHa:=
		array_append(total_Producto_N_x_area_total_en_LTotalHa,
					 ( area_fumigar * total_producto_N_x_ha_litros_x_ha[i] ));
	END LOOP;
	
	--'Total de Agua por área total en Litros por total de hectáreas'
	total_agua_x_area_total_en_LTotalHa:=(total_agua_x_ha_en_LHa*area_fumigar);
	
	--'Total de descarga por área total en Litros por total de hectáreas'
	total_descarga_x_area_total_en_LTotalHa:=total_agua_x_area_total_en_LTotalHa;
	FOR i IN 1..ARRAY_LENGTH(total_Producto_N_x_area_total_en_LTotalHa,1) loop
		total_descarga_x_area_total_en_LTotalHa:=
		( total_descarga_x_area_total_en_LTotalHa + total_Producto_N_x_area_total_en_LTotalHa[i] );
	END LOOP;
	
	RETURN QUERY (
		select total_descarga_hectarea,
		total_llenadas_tanque_hectarea,
		total_litros_descargar_area_total,
		total_llenadas_tanque_area_total,
		total_producto_N_por_tanque,
		total_de_agua_x_tanque_LTanque,
		total_producto_N_x_ha_litros_x_ha,
		total_agua_x_ha_en_LHa,
		total_descarga_x_ha_en_LHa,
		total_Producto_N_x_area_total_en_LTotalHa,
		total_agua_x_area_total_en_LTotalHa,
		total_descarga_x_area_total_en_LTotalHa,
		area_fumigar);
END $$
LANGUAGE plpgsql;

--SELECT * FROM
--calculos_fumigacion(1,1,10,ARRAY[1,0.4]);
--                                 ^^^^^
--                                 dosis