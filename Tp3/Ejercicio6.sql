--Ejercicio 6.

--a)Ante un cambio de tarea de un voluntario, coloque en 0 la cantidad de horas aportadas, independientemente de si el valor de horas_aportadas de la sentencia update es diferente.
--b)Cuando se actualice la cantidad de horas aportadas, el nuevo valor no puede ser ni menor, ni superior al 10 % del valor que tenía anteriormente.
CREATE OR REPLACE FUNCTION FN_VOLUNTARIO_SET_0_HORAS_APORTADAS()
RETURNS TRIGGER AS $$
    BEGIN

    --inciso a
    IF OLD.id_tarea != NEW.id_tarea THEN
        NEW.horas_aportadas := 0;
    END IF;

    --inciso b
    IF old.horas_aportadas != new.horas_aportadas then
        if new.horas_aportadas>old.horas_aportadas+old.horas_aportadas*0.1 OR new.horas_aportadas<old.horas_aportadas-old.horas_aportadas*0.1 then
            RAISE EXCEPTION 'Las horas nuevas horas aportadas son mayores en un 10% que las horas anteriores, esto no es posible';
        end if;
    end if;
    RETURN NEW;
    end;
    $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER TG_VOLUNTARIO_SET_0_HORAS_APORTADAS
    BEFORE UPDATE OF id_tarea ON unc_esq_voluntario.voluntario
    FOR EACH ROW
    EXECUTE FUNCTION FN_VOLUNTARIO_SET_0_HORAS_APORTADAS();