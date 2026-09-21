--Ejercicio 5.

--Primero creo la tabla historico_empleado_departamento

CREATE TABLE unc_45782957.historico_empleado_departamento (
    id SERIAL PRIMARY KEY,
    id_empleado NUMERIC(6,0) NOT NULL,
    id_departamento NUMERIC(4,0) NOT NULL,
    fecha_desde DATE NOT NULL,
    fecha_hasta DATE,
    promedio_empleado_departamento NUMERIC(2,2)
);

CREATE OR REPLACE PROCEDURE crear_historico_empleado_departamento(fecha_parametro DATE)
LANGUAGE 'plpgsql' AS $$
    begin
        INSERT INTO unc_45782957.historico_empleado_departamento (id_empleado,id_departamento,fecha_desde)
        SELECT id_empleado, id_departamento, fecha_parametro
        FROM unc_esq_peliculas.empleado;
    end;
    $$;


--Contemplamos en esta funcion y este trigger, cuando un usuario modifica su id_departamento
CREATE OR REPLACE FUNCTION FN_ACTUALIZAR_PROMEDIO_HISTORICO_EMPLEADO_DEPARTAMENTO()
RETURNS TRIGGER AS $$
    BEGIN
        --En caso de que sea una actualizacion, hay que cambiar el fecha_hasta y luego actualizar el promedio_empleado_departamento
        IF tg_op='UPDATE' then
            --Primero debemos modificar el fecha_hasta del empleado que acaba de cambiar de departamento
            UPDATE unc_45782957.historico_empleado_departamento
                set fecha_hasta=CURRENT_DATE where id_empleado=new.id_empleado
                                               AND id_departamento = OLD.id_departamento
                                               AND fecha_hasta IS NULL;

            --Recalculamos el promedio de horas trabajadas en ese departamento del empleado.
            UPDATE  unc_45782957.historico_empleado_departamento h
                set promedio_empleado_departamento = sub.promedio_calculado
                    FROM(SELECT id_empleado, id_departamento,
                                avg(fecha_hasta-fecha_desde) AS promedio_calculado
                        FROM unc_45782957.historico_empleado_departamento
                        WHERE  fecha_hasta IS NOT NULL
                        GROUP BY id_empleado, id_departamento) AS sub WHERE h.id_empleado=sub.id_empleado;
        end if;

        --Insertamos una nueva fila por el empleado que acaba de cambiar de departamento
        INSERT INTO unc_45782957.historico_empleado_departamento (id_empleado, id_departamento, fecha_desde)
            VALUES (NEW.id_empleado, NEW.id_departamento, CURRENT_DATE);

        RETURN new;
    end;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER TG_ACTUALIZAR_PROMEDIO_HISTORICO_EMPLEADO_DEPARTAMENTO
    AFTER INSERT OR UPDATE OF id_departamento ON unc_esq_peliculas.empleado
    FOR EACH ROW
    EXECUTE FUNCTION FN_ACTUALIZAR_PROMEDIO_HISTORICO_EMPLEADO_DEPARTAMENTO();