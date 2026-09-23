--1.
SELECT v.nro_voluntario, v.nombre, v.apellido, v.e_mail, v.id_institucion, v.horas_aportadas,
       SUM(horas_aportadas) OVER (PARTITION BY id_institucion) horas_aportadas_por_institucion
FROM unc_esq_voluntario.voluntario v
ORDER BY horas_aportadas_por_institucion DESC;

--2.
SELECT v.nro_voluntario, v.nombre, v.apellido, v.id_tarea,
       dense_rank() OVER (PARTITION BY v.id_tarea ORDER BY horas_aportadas DESC) rank_voluntario
FROM unc_esq_voluntario.voluntario v;

--3.
WITH voluntarios_ordenados_por_horas_aportadas_por_tarea AS(
    SELECT v.nro_voluntario, v.nombre, v.apellido, v.id_tarea,
        dense_rank() OVER (PARTITION BY v.id_tarea ORDER BY horas_aportadas DESC) rank_voluntario
    FROM unc_esq_voluntario.voluntario v
)
SELECT *
FROM voluntarios_ordenados_por_horas_aportadas_por_tarea
WHERE rank_voluntario=1;

--4.
SELECT c.id_continente, pais.id_pais, dir.ciudad,count(nro_voluntario) AS "cantidad_voluntarios"
FROM unc_esq_voluntario.voluntario v JOIN unc_esq_voluntario.institucion ins USING(id_institucion)
        JOIN unc_esq_voluntario.direccion dir USING(id_direccion)
        JOIN unc_esq_voluntario.pais pais USING(id_pais)
        JOIN unc_esq_voluntario.continente c USING(id_continente)
GROUP BY GROUPING SETS (
        c.id_continente, pais.id_pais, dir.ciudad
    );

--Usando ROLLUP: El orden de las columnas dentro del rollup cambia el resultado debido al agrupamiento de izq a der.
SELECT c.id_continente, pais.id_pais, dir.ciudad,count(nro_voluntario) AS "cantidad_voluntarios"
FROM unc_esq_voluntario.voluntario v JOIN unc_esq_voluntario.institucion ins USING(id_institucion)
        JOIN unc_esq_voluntario.direccion dir USING(id_direccion)
        JOIN unc_esq_voluntario.pais pais USING(id_pais)
        JOIN unc_esq_voluntario.continente c USING(id_continente)
GROUP BY ROLLUP (
    c.id_continente, pais.id_pais, dir.ciudad
    );
/*
 Equivale a:
    GROUP BY GROUPING SETS (
        (c.id_continente, pais.id_pais, dir.ciudad),
        (c.id_continente, pais.id_pais)
        (c.id_continente)
    );
 */

 --Usando CUBE: Se agrupa mediante todas las variaciones posibles de columnas.
SELECT c.id_continente, pais.id_pais, dir.ciudad,count(nro_voluntario) AS "cantidad_voluntarios"
FROM unc_esq_voluntario.voluntario v JOIN unc_esq_voluntario.institucion ins USING(id_institucion)
        JOIN unc_esq_voluntario.direccion dir USING(id_direccion)
        JOIN unc_esq_voluntario.pais pais USING(id_pais)
        JOIN unc_esq_voluntario.continente c USING(id_continente)
GROUP BY CUBE (
    c.id_continente, pais.id_pais, dir.ciudad
    );
/*
 Equivale a:
    GROUP BY GROUPING SETS (
        (c.id_continente, pais.id_pais, dir.ciudad),
        (c.id_continente, pais.id_pais),
        (c.id_continente, dir.ciudad),
        (pais.id_pais, dir.ciudad),
        (c.id_continente),
        (pais.id_pais),
        (dir.ciudad)
    );
 */

--5.
--Solucion 1, con CTE, menos eficiente ya que se recorre la tabla voluntario 2 veces.
WITH promedio_horas_por_tarea AS (
    SELECT nro_voluntario , avg(horas_aportadas) OVER (PARTITION BY id_tarea) promedio_horas_tarea
    FROM unc_esq_voluntario.voluntario
)
SELECT v.nro_voluntario, v.id_tarea, v.horas_aportadas,
        prom.promedio_horas_tarea,
        abs(v.horas_aportadas - prom.promedio_horas_tarea) AS "diferencia_al_promedio"
FROM unc_esq_voluntario.voluntario v, promedio_horas_por_tarea prom
WHERE v.nro_voluntario = prom.nro_voluntario;

--Solucion 2, volviendo a hacer la misma ventana, mas eficiente que la anterior, se recorre solo 1 vez la tabla voluntario
SELECT
    v.nro_voluntario,
    v.id_tarea,
    v.horas_aportadas,
    AVG(v.horas_aportadas) OVER (PARTITION BY v.id_tarea) AS promedio_horas_tarea,
    ABS(v.horas_aportadas - AVG(v.horas_aportadas) OVER (PARTITION BY v.id_tarea)) AS diferencia_al_promedio
FROM unc_esq_voluntario.voluntario v;

--WINDOW w AS (PARTITION BY id_tarea); Forma de abstraer el PARTITION BY a una "variable" que lo contiene

--6.
WITH promedios_horas_tareas AS(
    SELECT nro_voluntario, avg(horas_aportadas) OVER (PARTITION BY id_tarea) promedio_horas_tarea
    FROM unc_esq_voluntario.voluntario
    )
SELECT v.nro_voluntario, v.horas_aportadas, v.id_tarea
FROM unc_esq_voluntario.voluntario v JOIN promedios_horas_tareas using(nro_voluntario)
WHERE v.horas_aportadas > promedio_horas_tarea+100

--7.
--MAL
WITH rank_peliculas_y_totales AS(
SELECT pe.codigo_pelicula, pe.titulo, extract(MONTH FROM e.fecha_entrega) AS mes, extract(YEAR FROM e.fecha_entrega) AS anio,
       re.cantidad,
    rank() OVER(PARTITION BY extract(MONTH FROM e.fecha_entrega), extract(YEAR FROM e.fecha_entrega) ORDER BY SUM(re.cantidad) DESC) ranking_pel,
       extract(MONTH FROM e.fecha_entrega) AS mes, extract(YEAR FROM e.fecha_entrega) AS anio
FROM unc_esq_peliculas.pelicula pe JOIN unc_esq_peliculas.renglon_entrega re USING (codigo_pelicula)
        JOIN unc_esq_peliculas.entrega e USING(nro_entrega)
GROUP BY pe.codigo_pelicula,pe.titulo
)
SELECT *
FROM rank_peliculas_y_totales
WHERE ranking_pel=1;

--MAL
SELECT pe.codigo_pelicula, pe.titulo, extract(MONTH FROM e.fecha_entrega) AS mes, extract(YEAR FROM e.fecha_entrega) AS anio,
       re.cantidad,
       rank() OVER(PARTITION BY extract(MONTH FROM e.fecha_entrega), extract(YEAR FROM e.fecha_entrega) ORDER BY re.cantidad DESC) rank
FROM unc_esq_peliculas.pelicula pe JOIN unc_esq_peliculas.renglon_entrega re USING (codigo_pelicula)
        JOIN unc_esq_peliculas.entrega e USING(nro_entrega);

--MAL
SELECT pe.codigo_pelicula, pe.titulo, re.cantidad, extract(MONTH FROM e.fecha_entrega) AS mes, extract(YEAR FROM e.fecha_entrega) AS anio
FROM unc_esq_peliculas.pelicula pe JOIN unc_esq_peliculas.renglon_entrega re USING (codigo_pelicula)
        JOIN unc_esq_peliculas.entrega e USING(nro_entrega);

--Consulta generada por gemini, supuestamente la mas eficiente utilizando ventanas:
    WITH ranking_peliculas AS (
        SELECT
            re.codigo_pelicula,
            EXTRACT(MONTH FROM e.fecha_entrega) AS mes,
            EXTRACT(YEAR FROM e.fecha_entrega) AS anio,
            SUM(re.cantidad) AS cantidad_total,
            RANK() OVER (
                PARTITION BY EXTRACT(YEAR FROM e.fecha_entrega), EXTRACT(MONTH FROM e.fecha_entrega)
                ORDER BY SUM(re.cantidad) DESC
            ) AS ranking_pel
        FROM unc_esq_peliculas.renglon_entrega re
        JOIN unc_esq_peliculas.entrega e USING (nro_entrega)
        GROUP BY re.codigo_pelicula, EXTRACT(YEAR FROM e.fecha_entrega), EXTRACT(MONTH FROM e.fecha_entrega)
    )
    SELECT r.codigo_pelicula, p.titulo, r.mes, r.anio, r.cantidad_total
    FROM ranking_peliculas r
    JOIN unc_esq_peliculas.pelicula p USING (codigo_pelicula) -- <- JOIN realizado solo a las filas ganadoras
    WHERE r.ranking_pel = 1
    ORDER BY r.anio, r.mes;


--8.
WITH ranking_peliculas AS (
    SELECT codigo_pelicula,
           extract(MONTH FROM fecha_entrega) AS mes,
           extract(YEAR FROM  fecha_entrega) AS anio,
           cantidad,
           max(sum(cantidad))AS maximo
    FROM unc_esq_peliculas.pelicula JOIN unc_esq_peliculas.renglon_entrega USING(codigo_pelicula)
        JOIN unc_esq_peliculas.entrega USING(nro_entrega)
    GROUP BY (
        mes,anio,codigo_pelicula,cantidad
        )

)
SELECT *
FROM ranking_peliculas
WHERE cantidad=maximo
ORDER BY mes,anio;


--8.
WITH RECURSIVE jerarquia_empleados AS(
    SELECT 1 n, id_empleado, apellido, nombre, sueldo, age(fecha_nacimiento) AS edad
    FROM unc_esq_peliculas.empleado
    WHERE id_jefe IS NULL

    UNION ALL

    SELECT n + 1,e.id_empleado, e.apellido,e.nombre,e.sueldo,age(e.fecha_nacimiento) AS edad
    FROM jerarquia_empleados je JOIN unc_esq_peliculas.empleado e ON(e.id_jefe=je.id_empleado)
    WHERE n<=3
)
SELECT *
FROM jerarquia_empleados;

SELECT id_empleado
FROM unc_esq_peliculas.empleado