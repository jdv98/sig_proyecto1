-- Si se inserta o modifica una geometria de SRID 3857 la transforma a 5367 y viceversa
CREATE OR REPLACE FUNCTION f_trigger_terrazas() 
RETURNS TRIGGER 
AS 
$$
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
$$
LANGUAGE plpgsql;

CREATE TRIGGER trigger_terrazas
AFTER INSERT OR UPDATE OR DELETE ON terrazas
	FOR EACH ROW EXECUTE FUNCTION f_trigger_terrazas();