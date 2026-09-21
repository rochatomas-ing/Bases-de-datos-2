--Tabla para cumplir requerimientos de uso del Ejercicio 4.
CREATE TABLE unc_45782957.HIS_ENTREGA (
   nro_registro SERIAL PRIMARY KEY,
   fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   operacion VARCHAR(10) NOT NULL,
   cant_reg_afectados INT NOT NULL,
   usuario VARCHAR(128) DEFAULT CURRENT_USER,
   tabla_afectada VARCHAR(50) -- Opcional, pero muy útil y sin restricciones FK
);

--Trigger para mantener actualizada
CREATE OR REPLACE FUNCTION FN_AUDITORIA_ENTREGA()
RETURNS TRIGGER AS $$
    BEGIN
        INSERT INTO HIS_ENTREGA (operacion, cant_reg_afectados, tabla_afectada) VALUES (TG_OP, 1,
        TG_TABLE_NAME);
        IF tg_op='DELETE' then
            RETURN old;
        ELSE
            RETURN new;
        end if;
    end;
$$ LANGUAGE 'plpgsql';

-- Trigger para la tabla ENTREGA
CREATE TRIGGER TG_AUDITORIA_ENTREGA
    AFTER INSERT OR UPDATE OR DELETE ON unc_esq_peliculas.entrega
    FOR EACH ROW
EXECUTE FUNCTION FN_AUDITORIA_ENTREGA();

-- Trigger para la tabla RENGLON_ENTREGA (reutiliza la misma función)
CREATE TRIGGER TG_AUDITORIA_RENGLON_ENTREGA
    AFTER INSERT OR UPDATE OR DELETE ON unc_esq_peliculas.renglon_entrega
    FOR EACH ROW
EXECUTE FUNCTION FN_AUDITORIA_ENTREGA();

/*Basicamente la diferencia es que en FOR EACH ROW cada vez que se elimina una fila cuyo id_video=3582, primero se borrará
  en cascada las filas de renglon_entrega, entonces por cada fila borrada se cargara una nueva fila en his_entrega y luego
  se disparará el trigger por cada fila borrada en entrega y se guardará la informacion de quien la borró, asi por
  cada fila borrada en la tabla entrega

  En cambio si utilizamos FOR EACH STATEMENT, el trigger se disparará una vez sola, por lo tanto aunque se hayan borrado
  muchas filas en la tabla entrega, solo tendremos una fila con la informacion del borrado en la tabla HIS_ENTREGA.
  */