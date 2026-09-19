--a.1)Cada proveedor puede proveer hasta 20 productos a una misma sucursal.

/*Ejemplo a hacer con triggers:
create assertion chk_localidades check not exists (
  select 1 from proveedor p
    	join provee pr on (pr.nro_prov = p.nro_prov)
    	join sucursal s on (s.cod_suc = pr.cod_suc)
	where p.localidad <> s.localidad );
*/

CREATE OR REPLACE FUNCTION FN_MAX_PRODUCTOS_PROVEEDOR_SUCURSAL()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS(
        SELECT 1
        FROM provee
        WHERE cod_suc = NEW.cod_suc AND nro_prov=NEW.nro_prov
        HAVING count(*)>20
    ) THEN
        RAISE EXCEPTION 'El proveedor % ya posee mas de 20 productos en la sucursal %',NEW.nro_prov,NEW.cod_suc;
    END IF;

    RETURN NEW;

END; $$ LANGUAGE 'plpgsql';

CREATE OR REPLACE TRIGGER TR_MAX_PRODUCTOS_PROVEEDOR_SUCURSAL
    BEFORE INSERT OR UPDATE ON provee
    FOR EACH ROW
    EXECUTE FUNCTION FN_MAX_PRODUCTOS_PROVEEDOR_SUCURSAL();

--a.2)Cada proveedor sólo puede proveer productos a sucursales de su misma localidad

CREATE OR REPLACE FUNCTION FN_PROV_MISMA_LOCALIDAD_SUCURSAL()
    RETURNS TRIGGER AS $$
    BEGIN
       IF EXISTS(
           SELECT 1
           FROM proveedor p, sucursal s
           WHERE p.nro_prov=NEW.nro_prov AND
                 s.cod_suc=NEW.cod_suc AND
                 p.localidad IS DISTINCT FROM s.localidad
       ) THEN
           RAISE EXCEPTION 'El proveedor % tiene localidad distinta a la sucursal %',new.nro_prov,new.cod_suc;
       end if;

       RETURN new;

    END; $$

CREATE OR REPLACE TRIGGER TG_PROV_MISMA_LOCALIDAD_SUCURSAL
    BEFORE INSERT OR UPDATE ON provee
    FOR EACH ROW
    EXECUTE FUNCTION FN_PROV_MISMA_LOCALIDAD_SUCURSAL()