--Ejercicios Esquema VOLUNTARIO
--1.
SELECT v.apellido, v.nombre, v.horas_aportadas, v.fecha_nacimiento
FROM unc_esq_voluntario.voluntario v
WHERE id_tarea IN('IT_PROG', 'ST_CLERK') AND v.horas_aportadas <=7000
ORDER BY v.apellido, v.nombre;

--2.
SELECT v.nro_voluntario AS "Numero", v.nombre || ' ' ||v.apellido AS "Nombre y apellido", v.e_mail AS "Contacto"
FROM unc_esq_voluntario.voluntario v
WHERE v.horas_aportadas < 10000
ORDER BY v.nro_voluntario ASC;

--3.
SELECT DISTINCT id_coordinador
FROM unc_esq_voluntario.voluntario
WHERE id_coordinador IS NOT NULL;

--4.
SELECT DISTINCT v.id_tarea
FROM unc_esq_voluntario.voluntario v JOIN unc_esq_voluntario.tarea t ON (v.id_tarea = t.id_tarea)
WHERE v.porcentaje IS NULL OR v.porcentaje = 0;
-- Se podria NO haber utilizado el JOIN ya que no necesitamos otra columna de esas tareas encontradas

--5.
SELECT nro_voluntario, nombre, apellido, horas_aportadas
FROM unc_esq_voluntario.voluntario
WHERE extract(YEAR FROM fecha_nacimiento) > 1995
ORDER BY horas_aportadas DESC
LIMIT 5;

--6.
SELECT nro_voluntario, apellido, nombre, age(fecha_nacimiento) AS Edad
FROM unc_esq_voluntario.voluntario
WHERE extract(MONTH FROM fecha_nacimiento) = extract(MONTH FROM current_date)
AND EXTRACT(YEAR FROM age(fecha_nacimiento)) BETWEEN 40 and 50
ORDER BY age(fecha_nacimiento) DESC
LIMIT 3;

--7.
SELECT max(horas_aportadas), min(horas_aportadas), avg(horas_aportadas)
FROM unc_esq_voluntario.voluntario
WHERE EXTRACT(YEAR FROM age(fecha_nacimiento))>30;

--8.
SELECT i.id_institucion, count(nro_voluntario) AS "Cantidad de voluntarios", SUM(horas_aportadas) AS "Cantidad horas aportadas"
FROM unc_esq_voluntario.institucion i JOIN unc_esq_voluntario.voluntario v ON (i.id_institucion = v.id_institucion)
WHERE v.id_institucion IS NOT NULL
GROUP BY  i.id_institucion

--9.
SELECT v.id_institucion, count(v.nro_voluntario) AS "Voluntarios que trabajan en la institucion"
FROM unc_esq_voluntario.voluntario v
WHERE v.id_institucion IS NOT NULL
GROUP BY v.id_institucion
HAVING count(v.nro_voluntario)>10;

--10.
SELECT id_coordinador, id_institucion, count(nro_voluntario) AS cantidad_voluntarios
FROM unc_esq_voluntario.voluntario
WHERE id_institucion IS NOT NULL AND id_coordinador IS NOT NULL
GROUP BY id_coordinador, id_institucion
HAVING count(nro_voluntario)>3;

--11.
SELECT e.id_empleado, e.nombre, e.apellido, t.nombre_tarea
FROM unc_esq_peliculas.empleado e INNER JOIN unc_esq_peliculas.tarea t ON(e.id_tarea = t.id_tarea)
WHERE e.id_jefe IS NULL AND t.sueldo_maximo>14800;

--12.
SELECT 1
FROM unc_esq_peliculas.empleado e JOIN unc_esq_peliculas.empleado j ON (e.id_jefe = j.id_empleado)
WHERE e.sueldo > j.sueldo
LIMIT 1;

--13.
SELECT DISTINCT d.id_distribuidor, d.nombre, d.tipo, count(p.codigo_pelicula)
FROM unc_esq_peliculas.distribuidor d JOIN unc_esq_peliculas.entrega e USING(id_distribuidor)
JOIN unc_esq_peliculas.renglon_entrega USING(nro_entrega)
JOIN unc_esq_peliculas.pelicula p USING(codigo_pelicula)
WHERE p.idioma = 'Español' AND extract(YEAR FROM e.fecha_entrega)>2010
GROUP BY d.id_distribuidor;

--14.
SELECT e.apellido, COALESCE(j.apellido, 'No posee')
FROM unc_esq_peliculas.empleado e LEFT JOIN unc_esq_peliculas.empleado j ON(e.id_jefe = j.id_empleado)
ORDER BY e.apellido;

--15.
SELECT d.id_distribuidor, d.nombre, count(DISTINCT  e.id_video) AS "Cantidad de videos"
FROM unc_esq_peliculas.distribuidor d LEFT JOIN unc_esq_peliculas.entrega e USING(id_distribuidor)
GROUP BY d.id_distribuidor
ORDER BY count(e.id_video) DESC;

--16.
SELECT *
FROM unc_esq_peliculas.pelicula
WHERE codigo_pelicula NOT IN (
    SELECT re.codigo_pelicula
    FROM unc_esq_peliculas.renglon_entrega re
    JOIN unc_esq_peliculas.entrega e ON (re.nro_entrega = e.nro_entrega)
    JOIN unc_esq_peliculas.nacional n ON (e.id_distribuidor = n.id_distribuidor)
);

--17.
SELECT d.nombre, d.id_departamento, count(e.id_empleado)
FROM unc_esq_peliculas.departamento d JOIN unc_esq_peliculas.empleado e ON(d.id_departamento=e.id_departamento AND d.id_distribuidor=e.id_distribuidor)
WHERE e.id_empleado NOT IN(
    SELECT id_empleado
    FROM unc_esq_peliculas.empleado
    WHERE sueldo<6000
    )
GROUP BY d.nombre,d.id_departamento
HAVING count(e.id_empleado)>3
ORDER BY d.id_departamento;

--18.
SELECT *
FROM unc_esq_peliculas.departamento d JOIN unc_esq_peliculas.empleado e ON (d.id_departamento=e.id_departamento AND d.id_distribuidor=e.id_distribuidor)
GROUP BY d.id_distribuidor,d.id_departamento,e.id_empleado
HAVING count(d.id_distribuidor)<(
    SELECT count(*)*0.1
    FROM unc_esq_peliculas.empleado
    )

--19.
SELECT d.id_distribuidor,d.id_departamento, count(e.id_empleado)
FROM unc_esq_peliculas.departamento d JOIN unc_esq_peliculas.empleado e ON (d.id_departamento=e.id_departamento AND d.id_distribuidor=e.id_distribuidor)
GROUP BY d.id_distribuidor,d.id_departamento
HAVING count(*)=(
    SELECT count(e.id_empleado)
    FROM unc_esq_peliculas.departamento d JOIN unc_esq_peliculas.empleado e ON (d.id_departamento=e.id_departamento AND d.id_distribuidor=e.id_distribuidor)
    GROUP BY d.id_distribuidor,d.id_departamento
    ORDER BY count(*) DESC
    LIMIT 1
    )

--20 Alta paja.

--21.
SELECT id_distribuidor
FROM unc_esq_peliculas.distribuidor
EXCEPT
SELECT id_distribuidor
FROM unc_esq_peliculas.entrega

--22.
SELECT j.id_empleado
FROM unc_esq_peliculas.empleado e JOIN unc_esq_peliculas.empleado j ON(e.id_jefe=j.id_empleado)
INTERSECT
SELECT jefe_departamento
FROM unc_esq_peliculas.departamento

--23.
SELECT d.*, n.encargado
FROM unc_esq_peliculas.nacional n JOIN unc_esq_peliculas.distribuidor d USING(id_distribuidor)
UNION
SELECT d.*, NULL AS "encargado"
FROM unc_esq_peliculas.internacional i JOIN unc_esq_peliculas.distribuidor d USING(id_distribuidor)

--24.(No la entendi asique la hizo la ia)
SELECT p.*
FROM unc_esq_peliculas.pelicula p
WHERE NOT EXISTS (
    -- Todos los videos registrados
    SELECT id_video
    FROM unc_esq_peliculas.video

    EXCEPT

    -- Videos a los que se les entregó ESTA película específica
    SELECT e.id_video
    FROM unc_esq_peliculas.entrega e
    JOIN unc_esq_peliculas.renglon_entrega re ON (e.nro_entrega = re.nro_entrega)
    WHERE re.codigo_pelicula = p.codigo_pelicula
);