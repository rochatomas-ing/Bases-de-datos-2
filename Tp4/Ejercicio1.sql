--Ejercicio 1.

-- a.1) ENVIOS500 con los envíos de 500 o más unidades (a partir de ENVIO)

CREATE VIEW V_ENVIOS_500 AS
    SELECT *
    FROM unc_45782957.envio
    WHERE cantidad>=500;
--Es automaticamente actualizable.

--a.2) ENVIOS500M con los envíos de entre 500 y 1000 unidades (a partir de ENVIOS500)

CREATE VIEW V_ENVIOS_500_1000 AS
    SELECT *
    FROM V_ENVIOS_500
    WHERE cantidad<=1000;
--Es automaticamente actualizable.

--a.3) RUBROS_PROV con los diferentes rubros que poseen los proveedores ubicados en Tandil

CREATE VIEW V_PROVEEDORES_RUBROS_PROV AS
    SELECT distinct rubro
    FROM unc_45782957.proveedor
    WHERE ciudad='Tandil';
--No es automaticamente actualizable ya que posee un distinct.

--a.4) ENVIOS_PROV con los diferentes id y nombre de proveedor y la cantidad total de unidades enviadas

CREATE VIEW V_ENVIOS_PROV AS
    SELECT DISTINCT id_proveedor, nombre, SUM(cantidad)
    FROM unc_45782957.envio JOIN unc_45782957.proveedor USING(id_proveedor)
    GROUP BY id_proveedor;s
--No es automaticamente actualizable ya que utiliza una funcion de agregacion y ademas utiliza un group by y join(el cual no es aceptado para postgre).

--c)La proxima!