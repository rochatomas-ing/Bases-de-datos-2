--Ejercicio 2.
/*
a)Escriba las sentencias de creación de las vistas solicitadas en cada caso.
b) Indique si para el estándar SQL dicha vista es actualizable o no. Justifique cada respuesta.
c) Idem b) en PostgreSQL, teniendo en cuenta de construir vistas que resulten automáticamente actualizables, siempre que sea posible.
 */

--1. Cree una vista EMPLEADO_DIST_20 que liste el id_empleado, nombre, apellido, sueldo y fecha_nacimiento de los empleados que corresponden al distribuidor con identificador 20.

CREATE VIEW V_EMPLEADO_DIST_20 AS
    SELECT id_empleado, nombre, apellido, sueldo, fecha_nacimiento
    FROM unc_esq_peliculas.empleado
    WHERE id_distribuidor=20;
--Es automaticamente actualizable.

--2. Sobre la vista anterior defina otra vista EMPLEADO_DIST_2000 con el id, nombre, apellido y sueldo de los empleados con sueldo mayor a 2000.

CREATE VIEW V_EMPLEADO_DIST_20_SUELDOMAYORA_2000 AS
    SELECT id_empleado,nombre,apellido,sueldo
    FROM V_EMPLEADO_DIST_20
    WHERE sueldo>2000;
--Es automaticamente actualizable.

--3. Sobre la vista EMPLEADO_DIST_20 cree la vista EMPLEADO_DIST_20_70 con aquellos empleados que han nacido en la década del 70 (entre los años 1970 y 1979).

CREATE VIEW V_EMPLEADO_DIST_20_NACIDO_DECADA_70 AS
    SELECT *
    FROM V_EMPLEADO_DIST_20
    WHERE EXTRACT(YEAR FROM fecha_nacimiento) BETWEEN 1970 AND 1979;
--Es automaticamente actualizable.

--4. Cree una vista PELICULAS_ENTREGADAS que contenga el código de cada película y la cantidad de unidades entregadas.

CREATE VIEW V_PELICULAS_ENTREGADAS AS
    SELECT codigo_pelicula, sum(cantidad) AS cantidad_entregas
    FROM unc_esq_peliculas.renglon_entrega
    GROUP BY codigo_pelicula;
--No es automaticamente actualizable ya que utiliza GROUP BY.

--5. Cree una vista DISTRIB_NAC con los id de las distribuidoras nacionales, nro_incripcion y encargado, con distribuidor mayorista del país AR

CREATE VIEW V_DISTRIB_NAC AS
    SELECT n.id_distribuidor, nro_inscripcion, encargado
    FROM unc_esq_peliculas.nacional n JOIN unc_esq_peliculas.internacional i ON (n.id_distrib_mayorista=i.id_distribuidor)
    WHERE i.codigo_pais='AR';
--Para postgre no es automaticamente actualizable ya que utiliza JOIN, para SQL estandar si es actualizable.

--6. Usando la vista anterior, cree la vista DISTRIB_NAC_MAS2EMP con las distribuidoras nacionales cuyos departamentos tengan más de 2 empleados.
CREATE VIEW V_DISTRIB_NAC_MAS2EMP AS
    SELECT id_distribuidor, nro_inscripcion, encargado
    FROM V_DISTRIB_NAC
    WHERE id_distribuidor IN (
        SELECT id_distribuidor
        FROM unc_esq_peliculas.empleado
        GROUP BY id_distribuidor, id_departamento
        HAVING COUNT(id_empleado) > 2
    );
--Es automaticamente actualizable.