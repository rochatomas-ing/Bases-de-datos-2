--Ejercicio 6, Triggers para las vistas ciudad_kp_2 y entregas_kp_3

CREATE OR REPLACE FUNCTION FN_ACTUALIZACION_CIUDAD_KP_2()
    RETURNS TRIGGER AS $$
    begin
        IF tg_op='UPDATE' then
            -- Chequeamos si intentaron modificar la columna prohibida
            IF NEW.nombre_pais IS DISTINCT FROM OLD.nombre_pais THEN
                RAISE EXCEPTION 'Operación rechazada: no se puede actualizar nombre_pais porque pertenece a la tabla pais (no preservadora de clave).';
            END IF;
            UPDATE unc_esq_peliculas.ciudad set id_pais=new.id_pais, nombre_ciudad=new.nombre_ciudad, id_ciudad=new.id_ciudad WHERE id_ciudad=old.id_ciudad;
            RETURN NEW;
        elsif  tg_op='INSERT' then
            -- Chequeamos si intentaron modificar la columna prohibida
            IF NEW.nombre_pais IS NOT NULL THEN
                RAISE EXCEPTION 'Operación rechazada: no se puede actualizar nombre_pais porque pertenece a la tabla pais (no preservadora de clave).';
            END IF;
            INSERT INTO unc_esq_peliculas.ciudad (id_ciudad,nombre_ciudad,id_pais) VALUES (new.id_ciudad,new.nombre_ciudad,new.id_pais);
            RETURN NEW;
        elsif tg_op='DELETE' then
            DELETE FROM unc_esq_peliculas.ciudad WHERE id_ciudad=old.id_ciudad;

            RETURN OLD;
        end if;
        RETURN NEW;
    end;
    $$ language 'plpgsql';

CREATE OR REPLACE TRIGGER TG_ACTUALIZACION_CIUDAD_KP_2
    INSTEAD OF INSERT OR UPDATE OR DELETE ON ciudad_kp_2
    FOR EACH ROW
    EXECUTE FUNCTION FN_ACTUALIZACION_CIUDAD_KP_2();

CREATE OR REPLACE FUNCTION FN_ACTUALIZACION_ENTREGAS_KP_3()
    RETURNS TRIGGER AS $$
    begin
        IF tg_op='UPDATE' then
            -- Chequeamos si intentaron modificar el título
            IF NEW.titulo IS DISTINCT FROM OLD.titulo THEN
            RAISE EXCEPTION 'Operación rechazada: no se puede actualizar "titulo" porque pertenece a la tabla pelicula (no preservadora de clave).';
            END IF;

            UPDATE unc_esq_peliculas.renglon_entrega set cantidad=new.cantidad, nro_entrega=new.nro_entrega, codigo_pelicula=new.codigo_pelicula WHERE nro_entrega=old.nro_entrega AND codigo_pelicula=old.codigo_pelicula;
            RETURN NEW;

        ELSIF tg_op='INSERT' then
            -- Chequeamos si intentaron enviarle un título al INSERT
            IF NEW.titulo IS NOT NULL THEN
                RAISE EXCEPTION 'Operación rechazada: no se puede insertar un valor en "titulo" a través de esta vista.';
            END IF;

            INSERT INTO unc_esq_peliculas.renglon_entrega (nro_entrega, codigo_pelicula, cantidad) VALUES (new.nro_entrega, new.codigo_pelicula, new.cantidad);
            RETURN NEW;

        ELSIF tg_op='DELETE' then
            DELETE FROM unc_esq_peliculas.renglon_entrega WHERE nro_entrega=old.nro_entrega and codigo_pelicula=old.codigo_pelicula;
            RETURN OLD;
        end if;
    end;
    $$ language 'plpgsql';

CREATE OR REPLACE TRIGGER TG_ACTUALIZACION_ENTREGAS_KP_3
    INSTEAD OF INSERT OR UPDATE OR DELETE ON entregas_kp_3
    FOR EACH ROW
    EXECUTE FUNCTION FN_ACTUALIZACION_ENTREGAS_KP_3();

--Ejercicio c):
--....