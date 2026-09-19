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
    BEFORE INSERT OR UPDATE ON unc_esq_voluntario.voluntario
    FOR EACH ROW
    EXECUTE FUNCTION FN_HORAS_VOLUNTARIO_MENORQUE_COORD();