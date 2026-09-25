--a) Ningún voluntario puede aportar más horas que las de su coordinador.

CREATE OR REPLACE FUNCTION FN_HORAS_VOLUNTARIO_MENORQUE_COORD()
    RETURNS TRIGGER AS $$
    BEGIN
        -- 1. Si el voluntario tiene un coordinador asignado, verificar que no supere sus horas:
    IF NEW.id_coordinador IS NOT NULL THEN
        IF EXISTS (
            SELECT 1
            FROM unc_esq_voluntario.voluntario c
            WHERE c.nro_voluntario = NEW.id_coordinador
              AND NEW.horas_aportadas > c.horas_aportadas
        ) THEN
            RAISE EXCEPTION 'El voluntario % no puede aportar más horas (%) que su coordinador %',
                NEW.nro_voluntario, NEW.horas_aportadas, NEW.id_coordinador;
        END IF;
    END IF;

    -- 2. Si el voluntario modificado coordina a otros, verificar que sus nuevas horas no queden por debajo de sus subordinados:
    IF EXISTS (
        SELECT 1
        FROM unc_esq_voluntario.voluntario sub
        WHERE sub.id_coordinador = NEW.nro_voluntario
          AND sub.horas_aportadas > NEW.horas_aportadas
    ) THEN
        RAISE EXCEPTION 'Las horas del coordinador % (%) no pueden quedar por debajo de las de sus subordinados',
            NEW.nro_voluntario, NEW.horas_aportadas;
    END IF;
    RETURN NEW;
    end;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER  TG_HORAS_VOLUNTARIO_MENORQUE_COORD
    BEFORE INSERT OR UPDATE OF horas_aportadas,id_coordinador ON unc_esq_voluntario.voluntario
    FOR EACH ROW
    EXECUTE FUNCTION FN_HORAS_VOLUNTARIO_MENORQUE_COORD();

--b)Las horas aportadas por un voluntario deben estar dentro de los valores máximos y mínimos consignados en la tarea que realiza.
CREATE OR REPLACE FUNCTION FN_HORAS_VOLUNTARIO_ENTRE_MIN_MAX()
    RETURNS TRIGGER AS $$
    BEGIN
        --Si un nuevo usuario se inserta, y si un usuario actualiza el valor de sus horas_aportadas
        IF EXISTS(
            SELECT 1
            FROM unc_esq_voluntario.tarea t
            WHERE t.id_tarea=new.id_tarea AND(t.min_horas>new.horas_aportadas OR t.max_horas<new.horas_aportadas)
        ) then
            RAISE EXCEPTION 'Las horas aportadas del voluntario % no estan dentro del rango de la tarea %',
                NEW.nro_voluntario,new.id_tarea;
        end if;
    RETURN NEW;
        --Si se modifica una tarea que tiene voluntarios, sus valores min y max deben coincidir con las horas_aportadas de todos
        --sus voluntarios. Esto se debe resolver en otro trigger, o utilizando TG_TABLE_NAME
    END
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER TR_HORAS_VOLUNTARIO_ENTRE_MIN_MAX
    BEFORE INSERT OR UPDATE OF horas_aportadas ON unc_esq_voluntario.voluntario
    FOR EACH ROW
    EXECUTE FUNCTION FN_HORAS_VOLUNTARIO_ENTRE_MIN_MAX();

CREATE OR REPLACE FUNCTION FN_HORAS_TAREA_ENTRE_MIN_MAX()
    RETURNS TRIGGER AS $$
    BEGIN
        --Si se modifica una tarea que tiene voluntarios, sus valores min y max deben ser aceptados para los mismos
        IF EXISTS(
            SELECT 1
            FROM unc_esq_voluntario.voluntario v
            WHERE NEW.id_tarea=v.id_tarea AND (new.min_horas>v.horas_aportadas AND new.max_horas<v.horas_aportadas)
        ) then
            RAISE EXCEPTION 'La tarea no cumple con valores correctos min_horas o max_horas';
        end if;
    RETURN NEW;
    END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER TG_HORAS_TAREA_ENTRE_MIN_MAX
    BEFORE INSERT OR UPDATE OF min_horas, max_horas ON unc_esq_voluntario.tarea
    FOR EACH ROW
    EXECUTE FUNCTION FN_HORAS_TAREA_ENTRE_MIN_MAX();

--c)Todos los voluntarios de instituciones de Canadá (CA) deben realizar la misma tarea que su coordinador.

CREATE OR REPLACE FUNCTION FN_VOLUNTARIO_INSTITUCION_CANADA_MISMATAREA_COORDINADOR()
RETURNS TRIGGER AS $$
    BEGIN
    --Si existe un voluntario de CA cuya tarea es distinta a su coordinador
        IF EXISTS(
            SELECT 1
            FROM unc_esq_voluntario.institucion i
            JOIN unc_esq_voluntario.direccion d USING(id_direccion)
            JOIN unc_esq_voluntario.voluntario coord ON (new.id_coordinador=coord.nro_voluntario)
            WHERE new.id_institucion=i.id_institucion AND d.id_pais='CA' AND (new.id_tarea!=coord.id_tarea)
        ) THEN
            RAISE EXCEPTION 'El voluntario % de CA no realiza la misma tarea de su coordinador',new.nro_voluntario;
        end if;
    RETURN NEW;
    end;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER TG_FN_VOLUNTARIO_INSTITUCION_CANADA_MISMATAREA_COORDINADOR
    BEFORE INSERT OR UPDATE OF id_tarea ON unc_esq_voluntario.voluntario
    FOR EACH ROW
    EXECUTE FUNCTION FN_VOLUNTARIO_INSTITUCION_CANADA_MISMATAREA_COORDINADOR();

--d)Los voluntarios no pueden cambiar de institución más de tres veces en un año.

CREATE OR REPLACE FUNCTION FN_VOLUNTARIO_LIMITE_CAMBIO_INSTITUCION_MAX()
RETURNS TRIGGER AS $$
    BEGIN
        IF (SELECT count(*)
            FROM unc_esq_voluntario.historico h
            WHERE h.nro_voluntario=new.nro_voluntario AND
                  extract(year from h.fecha_inicio)=extract(year from current_date)
            group by h.nro_voluntario,h.id_institucion
        )>=3 then
            RAISE EXCEPTION 'El voluntario % ha exedido el limite de cambios de institucion por año',new.nro_voluntario;
        end if;
        RETURN new;
    end;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER TG_VOLUNTARIO_LIMITE_CAMBIO_INSTITUCION_MAX
    BEFORE UPDATE OF id_institucion ON unc_esq_voluntario.voluntario
    FOR EACH ROW
    EXECUTE FUNCTION FN_VOLUNTARIO_LIMITE_CAMBIO_INSTITUCION_MAX();