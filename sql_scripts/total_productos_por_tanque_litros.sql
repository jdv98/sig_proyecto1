--Dosis del producto (en litros)/Total de Llenadas de tanque por hectárea (números de vuelos por hectárea)
--Devuelte un arreglo con los litros
DROP FUNCTION total_producto_por_tanque_litros(dosis FLOAT[],total_llenadas_tanque_hectarea FLOAT);
CREATE OR REPLACE FUNCTION total_producto_por_tanque_litros(dosis FLOAT[],total_llenadas_tanque_hectarea FLOAT)
RETURNS FLOAT[]
AS $$
BEGIN
	RETURN
	(SELECT ARRAY_AGG(d/total_llenadas_tanque_hectarea)
	FROM UNNEST(dosis) d);
END $$
LANGUAGE plpgsql;


--SELECT * FROM total_producto_por_tanque_litros(ARRAY[2.92,10],(SELECT total_llenadas_tanque_hectarea FROM calculos_fumigacion(1,1,50)))
--												^^^^^^^^^^^^^^
--												(dosis_media)