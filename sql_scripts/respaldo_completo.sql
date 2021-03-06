PGDMP     8    9            	    y            Proyecto1GIS     12.8 (Ubuntu 12.8-1.pgdg21.04+1)    13.3 (Debian 13.3-1) 8    4           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            5           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            6           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            7           1262    232372    Proyecto1GIS    DATABASE     c   CREATE DATABASE "Proyecto1GIS" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_US.UTF-8';
    DROP DATABASE "Proyecto1GIS";
                postgres    false                        3079    232402    postgis 	   EXTENSION     ;   CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;
    DROP EXTENSION postgis;
                   false            8           0    0    EXTENSION postgis    COMMENT     ^   COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';
                        false    2            ?           1255    233458 K   calculos_fumigacion(integer, integer, double precision, double precision[])    FUNCTION     ?  CREATE FUNCTION public.calculos_fumigacion(id_drone integer, id_configuracion integer, area_fumigar double precision, v_dosis double precision[]) RETURNS TABLE(total_descarga_hectarea double precision, total_llenadas_tanque_hectarea double precision, total_litros_descargar_area_total double precision, total_llenadas_tanque_area_total double precision, total_producto_n_por_tanque double precision[], total_de_agua_x_tanque_ltanque double precision, total_producto_n_x_ha_litros_x_ha double precision[], total_agua_x_ha_en_lha double precision, total_descarga_x_ha_en_lha double precision, total_producto_n_x_area_total_en_ltotalha double precision[], total_agua_x_area_total_en_ltotalha double precision, total_descarga_x_area_total_en_ltotalha double precision, area_a_fumigar double precision)
    LANGUAGE plpgsql
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
END $$;
 ?   DROP FUNCTION public.calculos_fumigacion(id_drone integer, id_configuracion integer, area_fumigar double precision, v_dosis double precision[]);
       public          postgres    false            ?           1255    233451 
   cultivos()    FUNCTION       CREATE FUNCTION public.cultivos() RETURNS TABLE(cultivo character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT p.cultivo FROM productos p 
WHERE (p.metrica ILIKE 'ml/Ha' OR p.metrica ILIKE 'L/Ha')
GROUP BY p.cultivo ORDER BY p.cultivo asc;
END $$;
 !   DROP FUNCTION public.cultivos();
       public          postgres    false            ?           1255    233453 8   dosis_ingredientes(character varying, character varying)    FUNCTION     ?  CREATE FUNCTION public.dosis_ingredientes(v_cultivo character varying, v_ingrediente character varying) RETURNS TABLE(dosis_min double precision, dosis_media double precision, dosis_max double precision, metrica character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT p.dosis_min,p.dosis_media,p.dosis_max,p.metrica FROM productos p
WHERE p.cultivo=v_cultivo AND p.ingrediente=v_ingrediente;
END $$;
 g   DROP FUNCTION public.dosis_ingredientes(v_cultivo character varying, v_ingrediente character varying);
       public          postgres    false            ?           1255    233455    dron_configuraciones(integer)    FUNCTION     _  CREATE FUNCTION public.dron_configuraciones(v_id integer) RETURNS TABLE(id integer, ancho_cobertura double precision, volumen_descarga double precision, baterias_x_ha double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT c.id,c.ancho_cobertura,c.volumen_descarga,c.baterias_x_ha FROM configuraciones c
WHERE c.drone=v_id;
END $$;
 9   DROP FUNCTION public.dron_configuraciones(v_id integer);
       public          postgres    false            ?           1255    233454    drones()    FUNCTION     ?   CREATE FUNCTION public.drones() RETURNS TABLE(id integer, duracion_bateria double precision, capacidad_tanque double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT d.id,d.duracion_bateria,d.capacidad_tanque FROM drones d;
END $$;
    DROP FUNCTION public.drones();
       public          postgres    false            ?           1255    233446    f_trigger_bloques()    FUNCTION     ?  CREATE FUNCTION public.f_trigger_bloques() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            DELETE FROM public.bloques WHERE id=old.id;			
        ELSIF (TG_OP = 'UPDATE') THEN
				IF NEW.geom5367 IS NULL THEN
						UPDATE public.bloques SET geom3857=NEW.geom3857,
						geom5367=(SELECT ST_Transform(NEW.geom3857,5367))
						WHERE id=OLD.id;
				ELSIF NEW.geom3857 IS NULL THEN
						UPDATE public.bloques SET geom5367=NEW.geom5367,
						geom3857=(SELECT ST_Transform(NEW.geom5367,3857))
						WHERE id=OLD.id;
				END IF;
        ELSIF (TG_OP = 'INSERT') THEN
				IF NEW.geom5367 IS NULL THEN
					UPDATE public.bloques SET geom3857=NEW.geom3857,
						geom5367=(SELECT ST_Transform(NEW.geom3857,5367))
						WHERE id=NEW.id;
				ELSIF NEW.geom3857 IS NULL THEN
					UPDATE public.bloques SET geom5367=NEW.geom5367,
						geom3857=(SELECT ST_Transform(NEW.geom5367,3857))
						WHERE id=NEW.id;
				END IF;
		END IF;
		RETURN NULL;
END;
$$;
 *   DROP FUNCTION public.f_trigger_bloques();
       public          postgres    false            ?           1255    233448    f_trigger_terrazas()    FUNCTION     ?  CREATE FUNCTION public.f_trigger_terrazas() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            DELETE FROM public.terrazas WHERE id=old.id;			
        ELSIF (TG_OP = 'UPDATE') THEN
				IF NEW.geom5367 IS NULL THEN
						UPDATE public.terrazas SET geom3857=NEW.geom3857,
						geom5367=(SELECT ST_Transform(NEW.geom3857,5367))
						WHERE id=OLD.id;
				ELSIF NEW.geom3857 IS NULL THEN
						UPDATE public.terrazas SET geom5367=NEW.geom5367,
						geom3857=(SELECT ST_Transform(NEW.geom5367,3857))
						WHERE id=OLD.id;
				END IF;
        ELSIF (TG_OP = 'INSERT') THEN
				IF NEW.geom5367 IS NULL THEN
					UPDATE public.terrazas SET geom3857=NEW.geom3857,
						geom5367=(SELECT ST_Transform(NEW.geom3857,5367))
						WHERE id=NEW.id;
				ELSIF NEW.geom3857 IS NULL THEN
					UPDATE public.terrazas SET geom5367=NEW.geom5367,
						geom3857=(SELECT ST_Transform(NEW.geom5367,3857))
						WHERE id=NEW.id;
				END IF;
		END IF;
		RETURN NULL;
END;
$$;
 +   DROP FUNCTION public.f_trigger_terrazas();
       public          postgres    false            ?           1255    233457    filtro1(integer[])    FUNCTION        CREATE FUNCTION public.filtro1(g_id integer[]) RETURNS double precision
    LANGUAGE plpgsql
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
END $$;
 .   DROP FUNCTION public.filtro1(g_id integer[]);
       public          postgres    false            ?           1255    233456    filtro2(integer[], integer[])    FUNCTION     ?  CREATE FUNCTION public.filtro2(b_id integer[], t_id integer[]) RETURNS double precision
    LANGUAGE plpgsql
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
END $$;
 >   DROP FUNCTION public.filtro2(b_id integer[], t_id integer[]);
       public          postgres    false            ?           1255    233452    ingredientes(character varying)    FUNCTION     ;  CREATE FUNCTION public.ingredientes(v_cultivo character varying) RETURNS TABLE(ingrediente character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
RETURN QUERY
SELECT p.ingrediente FROM productos p
WHERE p.cultivo=v_cultivo AND (p.metrica ILIKE 'ml/Ha' OR p.metrica ILIKE 'L/Ha')
ORDER BY p.ingrediente asc;
END$$;
 @   DROP FUNCTION public.ingredientes(v_cultivo character varying);
       public          postgres    false            ?           1255    233450 F   total_producto_por_tanque_litros(double precision[], double precision)    FUNCTION        CREATE FUNCTION public.total_producto_por_tanque_litros(dosis double precision[], total_llenadas_tanque_hectarea double precision) RETURNS double precision[]
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN
	(SELECT ARRAY_AGG(d/total_llenadas_tanque_hectarea)
	FROM UNNEST(dosis) d);
END $$;
 ?   DROP FUNCTION public.total_producto_por_tanque_litros(dosis double precision[], total_llenadas_tanque_hectarea double precision);
       public          postgres    false            ?            1259    233419    bloques    TABLE     ?   CREATE TABLE public.bloques (
    id integer NOT NULL,
    geom3857 public.geometry(Polygon,3857),
    geom5367 public.geometry(Polygon,5367)
);
    DROP TABLE public.bloques;
       public         heap    postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            ?            1259    233417    bloques_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.bloques_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.bloques_id_seq;
       public          postgres    false    215            9           0    0    bloques_id_seq    SEQUENCE OWNED BY     A   ALTER SEQUENCE public.bloques_id_seq OWNED BY public.bloques.id;
          public          postgres    false    214            ?            1259    232373    configuraciones    TABLE     ?  CREATE TABLE public.configuraciones (
    id integer NOT NULL,
    drone integer NOT NULL,
    altitud double precision NOT NULL,
    ancho_cobertura double precision NOT NULL,
    velocidad_drone double precision NOT NULL,
    volumen_descarga double precision NOT NULL,
    baterias_x_ha double precision NOT NULL
);
 #   DROP TABLE public.configuraciones;
       public         heap    postgres    false            ?            1259    232376    configuraciones_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.configuraciones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.configuraciones_id_seq;
       public          postgres    false    203            :           0    0    configuraciones_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.configuraciones_id_seq OWNED BY public.configuraciones.id;
          public          postgres    false    204            ?            1259    232378    drones    TABLE     ?   CREATE TABLE public.drones (
    id integer NOT NULL,
    marca character varying(100),
    modelo character varying(100),
    duracion_bateria double precision NOT NULL,
    capacidad_tanque double precision NOT NULL
);
    DROP TABLE public.drones;
       public         heap    postgres    false            ?            1259    232381    drones_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.drones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.drones_id_seq;
       public          postgres    false    205            ;           0    0    drones_id_seq    SEQUENCE OWNED BY     ?   ALTER SEQUENCE public.drones_id_seq OWNED BY public.drones.id;
          public          postgres    false    206            ?            1259    232383 	   productos    TABLE     O  CREATE TABLE public.productos (
    id integer NOT NULL,
    tipo character varying(50) NOT NULL,
    ingrediente character varying(200) NOT NULL,
    cultivo character varying(50) NOT NULL,
    dosis_min double precision,
    dosis_max double precision,
    dosis_media double precision,
    metrica character varying(50) NOT NULL
);
    DROP TABLE public.productos;
       public         heap    postgres    false            ?            1259    232386    productos_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.productos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.productos_id_seq;
       public          postgres    false    207            <           0    0    productos_id_seq    SEQUENCE OWNED BY     E   ALTER SEQUENCE public.productos_id_seq OWNED BY public.productos.id;
          public          postgres    false    208            ?            1259    233430    terrazas    TABLE     ?   CREATE TABLE public.terrazas (
    id integer NOT NULL,
    geom3857 public.geometry(Polygon,3857),
    geom5367 public.geometry(Polygon,5367)
);
    DROP TABLE public.terrazas;
       public         heap    postgres    false    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2    2            ?            1259    233428    terrazas_id_seq    SEQUENCE     ?   CREATE SEQUENCE public.terrazas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.terrazas_id_seq;
       public          postgres    false    217            =           0    0    terrazas_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.terrazas_id_seq OWNED BY public.terrazas.id;
          public          postgres    false    216            ?           2604    233422 
   bloques id    DEFAULT     h   ALTER TABLE ONLY public.bloques ALTER COLUMN id SET DEFAULT nextval('public.bloques_id_seq'::regclass);
 9   ALTER TABLE public.bloques ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    214    215    215            ?           2604    232388    configuraciones id    DEFAULT     x   ALTER TABLE ONLY public.configuraciones ALTER COLUMN id SET DEFAULT nextval('public.configuraciones_id_seq'::regclass);
 A   ALTER TABLE public.configuraciones ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    204    203            ?           2604    232389 	   drones id    DEFAULT     f   ALTER TABLE ONLY public.drones ALTER COLUMN id SET DEFAULT nextval('public.drones_id_seq'::regclass);
 8   ALTER TABLE public.drones ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    206    205            ?           2604    232390    productos id    DEFAULT     l   ALTER TABLE ONLY public.productos ALTER COLUMN id SET DEFAULT nextval('public.productos_id_seq'::regclass);
 ;   ALTER TABLE public.productos ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    208    207            ?           2604    233433    terrazas id    DEFAULT     j   ALTER TABLE ONLY public.terrazas ALTER COLUMN id SET DEFAULT nextval('public.terrazas_id_seq'::regclass);
 :   ALTER TABLE public.terrazas ALTER COLUMN id DROP DEFAULT;
       public          postgres    false    216    217    217            /          0    233419    bloques 
   TABLE DATA           9   COPY public.bloques (id, geom3857, geom5367) FROM stdin;
    public          postgres    false    215   8a       (          0    232373    configuraciones 
   TABLE DATA           ?   COPY public.configuraciones (id, drone, altitud, ancho_cobertura, velocidad_drone, volumen_descarga, baterias_x_ha) FROM stdin;
    public          postgres    false    203   Ua       *          0    232378    drones 
   TABLE DATA           W   COPY public.drones (id, marca, modelo, duracion_bateria, capacidad_tanque) FROM stdin;
    public          postgres    false    205   ?a       ,          0    232383 	   productos 
   TABLE DATA           o   COPY public.productos (id, tipo, ingrediente, cultivo, dosis_min, dosis_max, dosis_media, metrica) FROM stdin;
    public          postgres    false    207   !b       ?          0    232709    spatial_ref_sys 
   TABLE DATA           X   COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
    public          postgres    false    210   ?r       1          0    233430    terrazas 
   TABLE DATA           :   COPY public.terrazas (id, geom3857, geom5367) FROM stdin;
    public          postgres    false    217   s       >           0    0    bloques_id_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.bloques_id_seq', 1, false);
          public          postgres    false    214            ?           0    0    configuraciones_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.configuraciones_id_seq', 13, true);
          public          postgres    false    204            @           0    0    drones_id_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.drones_id_seq', 3, true);
          public          postgres    false    206            A           0    0    productos_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.productos_id_seq', 398, true);
          public          postgres    false    208            B           0    0    terrazas_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.terrazas_id_seq', 1, false);
          public          postgres    false    216            ?           2606    233427    bloques bloques_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.bloques
    ADD CONSTRAINT bloques_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.bloques DROP CONSTRAINT bloques_pkey;
       public            postgres    false    215            ?           2606    232392 $   configuraciones configuraciones_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.configuraciones
    ADD CONSTRAINT configuraciones_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.configuraciones DROP CONSTRAINT configuraciones_pkey;
       public            postgres    false    203            ?           2606    232394    drones drones_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.drones
    ADD CONSTRAINT drones_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.drones DROP CONSTRAINT drones_pkey;
       public            postgres    false    205            ?           2606    232396    productos productos_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.productos DROP CONSTRAINT productos_pkey;
       public            postgres    false    207            ?           2606    233438    terrazas terrazas_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.terrazas
    ADD CONSTRAINT terrazas_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.terrazas DROP CONSTRAINT terrazas_pkey;
       public            postgres    false    217            ?           2620    233447    bloques trigger_bloques    TRIGGER     ?   CREATE TRIGGER trigger_bloques AFTER INSERT OR DELETE OR UPDATE ON public.bloques FOR EACH ROW EXECUTE FUNCTION public.f_trigger_bloques();
 0   DROP TRIGGER trigger_bloques ON public.bloques;
       public          postgres    false    927    215            ?           2620    233449    terrazas trigger_terrazas    TRIGGER     ?   CREATE TRIGGER trigger_terrazas AFTER INSERT OR DELETE OR UPDATE ON public.terrazas FOR EACH ROW EXECUTE FUNCTION public.f_trigger_terrazas();
 2   DROP TRIGGER trigger_terrazas ON public.terrazas;
       public          postgres    false    217    928            ?           2606    232397 *   configuraciones configuraciones_drone_fkey    FK CONSTRAINT     ?   ALTER TABLE ONLY public.configuraciones
    ADD CONSTRAINT configuraciones_drone_fkey FOREIGN KEY (drone) REFERENCES public.drones(id);
 T   ALTER TABLE ONLY public.configuraciones DROP CONSTRAINT configuraciones_drone_fkey;
       public          postgres    false    205    203    3737            /      x?????? ? ?      (   ?   x?%??E!??b??c/??:?.?q????I;n1????]?Y?&ٴe?70?e;??tc?rs^?CD?*?j}?q-?,??m???&~.??`e?KR??;ў#S?Ed/?u???????? ??+"X      *   )   x?3???42??Գ?21M9M?L???LcSNCS?=... V??      ,      x????r?6???S?hL?=??z????ƮڪT.Ј??p???????>J?{?!??^?b???o?#?D??? ?@w`?}?;?????X??m?q<VǇ?<???~w??ټ^?p?G?ې???,_???C???????/?????f^?-?????S???q?˫^_?gv?6??????={??Gս??Olw70??"?
????폼 ?S?yVT??o?%T??k????R????G34?\????50??2?ܰ=Ð*??????q???<|??.,:!?MuZ??vl7e4׿?o?#????U??T??>M???UY??kh	:???x???g?|?|?4W}?H????I?)?C?y8ݳ$???~<2_?%??Q?M?4??a?4?~~?F?yR?aH??????4f?Pe??#??4?G,Z??????zkP,mqD)%????`(S?	????s?*pJ?q'ـ(q?5??pBU????MVp?XZ>?G=?jaSz?n';??JJ???N3U??<c??2,?(1?B}?(1Bh
%FD?BC?8????S?أ?5i@?3DL???E,?D/?|`?~???qf??lK??????G6???`ǌ?????|??W}?????}!G???iBܚ?xa?>?v???*٨?X9?f?????????.j?]?r????g???yT3?g(}?ƵD???6????1
P?vS?Dд?"8%??X????c?+\ޙ`?y??o??)n??j?Hw?s?2?t?c???Z?Q???????f???pw)?????o?p?&疾? ?k?(?zh9,?~Q!??B?ylL9??^.,hTZM???K??????(??s???`
?hR^?1??᳅v??2]8???????1?_l?\?!\7?%?L?????HXv?9?ꡇ??9TM?ٝ#a??Y?&????`h?x6߲?fg)?1z/r???"MqieS\??ҍ?.qimQ?\??P%??B?:Q?	\?̨X#???!??????|:?#;?l?d?G?B]?Ť??a? c5?нT?(?u#?t??????
$R??? ?Zod@?^?&?r@?ܴS?)?:??$??DD?$lTA]
?}????u9H
pRk!CS?Y?"$?XWJ?h????qoa/???IqE،N?^p?b?D?[p	?h
?"??w??$ ;e??M<???:+????4?}h&f?????4?P??鮃91b??G??ŜF?If?\??ZA+????1??i??
܈w??"?U?<?J?d??"?T??S????_E????_?q?IVɉS? q?U?'?l0I???b??zO0H<hA??J?`?u??iE?w????P?????6+?@tk???<?	t*?_??e˔?~]? ??d?.??F?e?qW?$?燁???+?{?x?&?撻g?[?2? Y?Qz扡"?u}??"ė? m?դ^???ߦ&k??&????^?f?;9:{-m?5E??DS?z?ȗ???~|?k?0 ]a?2?ƼE]#?Q??dަ?cB	??֢????%`?!?{>????`???=M?H??ww?iؚ?0Ս?`I??5P??p?,??????g?Mt?,R???BD ?$D?A?6?.???7?Ku?U???(????ca?n?R%???@?uU???Vξ?%??????B??	_???m??nb-]洂D?T?PN[[[??P?#V-c?2???I=???<<@6gH??!Uz&??G*??y?F3?5????<??]?i???!??C??E?D?&@Q?@쪅??1?7]????k*ұZ?,??g??<L?w?Hu'1L?0?/(Ժ???R?OQZ??EL?Z?????ؓ???L;?+\?,??D$z-oSI?C??Y?r????z?
/???ӡ?>?????v????(?ʟ?H޽?$=_Q9	?=?"e!0(???I<?y?L;?SrS??$??IA?H"?&M??m?VvQ'E????	\ݾ?p????W6T??kҘ?%@?2W???tL%?&	!?e?P`?k?\%*?PY???[U?X?K?Y?J??w??6VK?M?`????`\??R????v?t??1?h7??ύ???<?
?dA??[m??@??yOܵ????/=?~%v͜?*8[@h??%?B?e.???j?e???a??2???X?Ti?=?=2??k??1?i\???U?#???????_?r??t??)m????????/]?/Ϩ;?~??h;? ??;R pgn??C?r5~?4}}<??6HW;/?H??1.s??9?c?N??!
???6??6?gy??1?:K;?+?U???,?`?s?????Hզ???C	W??=??[?O?¬M?T?,?1@0?????)&?uK???JJD?&l?;}???f??i0Ƅf?x?v??y⨒`???d?}W?EI?:????G2"?jf?H??ϧ?_?qo??oO?7[???m?"?p?~?)??~:p??7??6U?ED??Q7kE?t?G]????J??b
+Z??/????=??A?????T?[??l 04?>03?
??3a0?_V?n?χa?q?L??HA?x	??i?????e?9???W?ᛞ???Y???	Fg?ypA???9^O
T?@?k
0	k?????י3T?D?n?(?7*HT4????.?t֨H??SZ\?V?~;p?s:??k/9_k?(]4???S/e?}?h?5`??F}T???R?N???6???o??Qhb?)???;???'?u??:?σD8????o?R???v?t?)*??m?????;????˩+٠?7lܲ??,???;Wِ'?????Y?c???+?*????;??5?ЂD??V=??Z???o???=??+-[E?p?????4?Մ09??6??)?hi?o???x?,ΰ?pZ?d	?n?ް???Ď?????_?䨼LOF?*??:????#}?v?_?B??!?H?F?=??@?8??fU?d)??z?D?hwۑ?Lޤ?#qTA???/?*??8?c??q?FZc?zWO????1????(m?_?N???ᚸ??AK???O?D8??????a???EÆ`?? Z????p?u???:Lw?d\???Mq6lT????L?#?%?T???C ??J??Vy8#^~???r6gv??V?4?į?y#?l
[ ?hW?7?q??)????a?7?U?ۙ?T?a???v??G?
?-]1-??k??~'ɧ?K??3???B?.??3F?|????4??	?O?GI`?y??	?Mj?D??^??W??qX?:Z?-?u9?4\?a???vU??矧ቍӗi????5=?}F^l?h???C???>щ?D?L???v???9?f???8Ϝ?r???;t??u	?l	6fh!?mhoZ䮾?d??j?? ??URq?<?N??q?M?Ï??;?ռ?j??d???{vX?????qR?\?Y?C(82A?"?#:T=	0I??:S4A???ZׅE?bu??v@y????d?n?.ƪ^l]5?O?kPHz?^T'_???Y???v???.SਆX???;qgG?<???dKC?X?????2؏?f:b???E?\H??r???ч?E"B?Y?{?$]Q????iGi??R??O????ƪѯeԯ/?l?#ŵ?/???D_???z?0C5??D?? ?CM?s?>??×6?KΧ?>ǿ?P?Hӹ8?>?l?D>JP?18rCu?V?P??????????k??????n+??:?/????q{???Y?xԾ=8?????}??K!?]?f?]??0 ?ea????_kn?8*I?)WM?8e??7z}?N?????WZ?`????p?O?ӽk?x??Wߍq?>y????Rɻov???E6?3K?=?J?ǁDlx9)}????>??ol????M?5??"?5??ܫ?*????3??hNt?"????5????? ???}׭?vh?S?
+??????.???O?z[?b?I??۶?G
???w?@?!>w??$???`??j?3????kXP????;83?R?V?8???xzG7?m??=x? ??9w??F??A??Vsr{?i???\? ?   ?n3wg
(s?o?v?&=??x???1w$??|?ŌG?D%?Ǣ?Toe?̗Qj?M1????j???A?Է?j?c?呝o???o7?0?i%???? ?ܺf??n??d??3^f]'`?#jY?d`??????*?@79g#NN6	?| L??H??n?????X??K?'???(????????P";?      ?      x?????? ? ?      1      x?????? ? ?     