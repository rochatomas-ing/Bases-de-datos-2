--Ejercicio 7

--Vista1: nro_voluntario, nombre, apellido, horas aportadas y datos completos de la tarea que realiza
CREATE VIEW V_VOLUNTARIO_TAREA AS
    SELECT v.nro_voluntario,
           v.nombre,
           v.apellido,
           v.horas_aportadas,
           v.id_tarea,
           --Separacion de tablas
           t.nombre_tarea,
           t.min_horas,
           t.max_horas
    FROM unc_esq_voluntario.voluntario v JOIN unc_esq_voluntario.tarea t using(id_tarea);
--No es automaticamente actualizable por lo tanto necesita trigger
--La tabla que contiene la preserved key es voluntario, y la preserved key es nro_voluntario

CREATE OR REPLACE FUNCTION FN_ACTUALIZACION_V_VOLUNTARIO_TAREA()
    RETURNS TRIGGER AS $$
    begin
        IF tg_op='UPDATE' then
            IF (old.nombre_tarea IS DISTINCT FROM new.nombre_tarea or
               old.min_horas IS DISTINCT FROM new.min_horas or
               old.max_horas IS DISTINCT FROM new.max_horas) then
                RAISE EXCEPTION 'Se está intentando actualizar datos de la tabla que no contiene la preserved key(tarea)';
            end if;
            UPDATE unc_esq_voluntario.voluntario set nombre=new.nombre, apellido=new.apellido, horas_aportadas=new.horas_aportadas,id_tarea=new.id_tarea WHERE nro_voluntario=old.nro_voluntario;
            RETURN NEW;

        ELSIF tg_op='INSERT' then
            IF (new.nombre_tarea is not null or
                new.min_horas  is not null or
                new.max_horas is not null)then
                RAISE EXCEPTION 'Se está intentando insertar datos de la tabla tarea, la tabla de la preserved key es voluntario';
            end if;
            INSERT INTO unc_esq_voluntario.voluntario (nro_voluntario, nombre, apellido, horas_aportadas, id_tarea) VALUES (new.nro_voluntario, new.nombre, new.apellido, new.horas_aportadas, new.id_tarea);
            RETURN NEW;

        ELSIF tg_op='DELETE' then
            DELETE FROM unc_esq_voluntario.voluntario WHERE nro_voluntario=old.nro_voluntario;
            RETURN OLD;
        end if;
    end;
    $$ language 'plpgsql';

CREATE OR REPLACE TRIGGER TG_ACTUALIZACION_V_VOLUNTARIO_TAREA
    INSTEAD OF UPDATE OR INSERT OR DELETE ON V_VOLUNTARIO_TAREA
    FOR EACH ROW
    EXECUTE FUNCTION FN_ACTUALIZACION_V_VOLUNTARIO_TAREA();

--Vista2: datos de las instituciones ubicadas en el país US junto con la cantidad de tareas que se han realizado en ellas
CREATE VIEW V_INSTITUCIONES_US_CANT_TAREAS AS
    SELECT i.id_institucion, i.nombre_institucion, -- (listar campos necesarios)
           COUNT(h.id_tarea) AS cant_tareas_por_institucion
    FROM unc_esq_voluntario.institucion i
    JOIN unc_esq_voluntario.direccion d USING(id_direccion)
    LEFT JOIN unc_esq_voluntario.historico h USING(id_institucion)
    WHERE d.id_pais = 'US'
    GROUP BY i.id_institucion, i.nombre_institucion;

--Vista3: identificador y nombre de todas las instituciones existentes, con la cantidad de voluntarios que están trabajando en cada una
CREATE VIEW V_INSTITUCION_CANT_VOLUNTARIOS AS
    SELECT i.id_institucion, i.nombre_institucion, count(v.nro_voluntario)
    FROM unc_esq_voluntario.institucion i LEFT JOIN unc_esq_voluntario.voluntario v using(id_institucion)
    GROUP BY i.id_institucion, i.nombre_institucion;