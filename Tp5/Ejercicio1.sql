--Ejercicio 1 — Práctico 5: Optimización de consultas
--Enunciado: docs/Tps/Practico 5 - Optimiz_Consultas.pdf
--
--Con el comando EXPLAIN explique la heurística que utiliza para el query plan
--el optimizador de PostgreSQL en cada una de las sentencias:
--
--a) Listado de las entregas que poseen las películas de terror (esquema Películas)
--
--b) Listado de los datos de contacto (nombre, apellido, email y teléfono) de todos
--    los voluntarios que hayan desarrollado tareas de hasta 5000 hs
--    (max_horas - min_horas) y que las hayan finalizado antes del 01/01/2024
--    (esquema Voluntario).
--
--NOTA: el enunciado escribe las tablas sin calificar. Acá van con el prefijo de esquema,
--porque el rol unc_45782957 no tiene search_path configurado en el servidor.


--a)
EXPLAIN ANALYSE
SELECT p.titulo, e.nro_entrega
FROM unc_esq_peliculas.pelicula p,
     unc_esq_peliculas.renglon_entrega re,
     unc_esq_peliculas.entrega e
WHERE p.codigo_pelicula = re.codigo_pelicula
  AND re.nro_entrega = e.nro_entrega
  AND p.genero = 'Terror';
/*
    Cabe recalcar que por heuristica primero se intentaron realizar los filtrados(que es lo unico que se hace en esta consulta, no se hace proyeccion pero si hay joins aunque son en los filtros), por lo tanto lo heuristicamente mas restrictivo fue filtrar el genero de pelicula, y luego los productos cruz o joins.
    En el EXPLAIN podemos visualizar que el costo total de la query es de 729,46 y la operacion que mayor costo tiene es recorrer la tabla pelicula filtrando por genero='Terror', para esta operacion se usó Seq Scan, es decir, se recorrió toda la tabla y esto tiene un costo de 713,25, esta fue la unica alternativa ya que la columna genero no posee indice. Para encontrar las filas que conectan renglo_entrega con pelicula cuyo codigo_pelicula es igual se utilizó un bitmap index Scan y un bitmap heap scan, es decir, se utilizó un indice, dentro de las diferentes alternativas, postgre encontró que la que mejor costo estimado tenia era esta forma, y no realizar el recorrido completo de la tabla. Para hacer el join con entrega utilizando nro_entrega tambien se utilizó un indice de esa columna en la tabla entrega(Index Only Scan), por lo que el costo de esta operacion tambien es bajo, no se leyó la tabla completa ya que postgre vio que tenia mayor costo que al utilizar el indice. Luego se juntaron las filas encontradas en una misma tabla para retornar el resultado(Nested loop), como nested loop escala con cantidad de filas cruzadas, y se estiman pocas, se eligio esta alternativa para ambos nested loop. Cabe recalcar que con explain analyse no se encontraron filas para esa query.

    La ejecucion fue: en paralelo se filtró seq scan del genero de pelicula(#3), bitmap index scan de codigo_pelicula de la tabla pelicula(#5) y index only scan de nro_entrega de la tabla entrega(#6), luego se ejecutó el bitmap heap scan de codigo pelicula de la tabla renglon_entrega(#4), luego se unieron los resultados de #4 y #3 (Nested loop)(#2) y por ultimo se unieron #2 y #6 en nesteed loopo(#1)  */

--b)
EXPLAIN
SELECT V.nombre, V.apellido, V.e_mail, V.telefono
FROM unc_esq_voluntario.voluntario V
WHERE V.nro_voluntario IN (
    SELECT H.nro_voluntario
    FROM unc_esq_voluntario.historico H
    WHERE H.fecha_fin < to_date('2024-01-01', 'yyyy-mm-dd')
      AND H.id_tarea IN (
          SELECT T.id_tarea
          FROM unc_esq_voluntario.tarea T
          WHERE (T.max_horas - T.min_horas) <= 5000
      )
);
/*
 En la consulta vemos que tenemos una consulta dentro de otra, dentro de otra, heuristicamente se van a realizar primero los filtrados, luego las proyecciones y por ultimo los joins, y en este caso va a ser asi, pero primero resolviendo la subconsulta de la subconsulta, luego los de la subconsulta y por ultimo lo de la consulta principal(la mas exterior).
 Vemos que las primeras 2 operaciones que se realizan son calcular el max_horas-min_horas de la tabla tarea con un SEQ SCAN, probablemente estas columnas no tengan indice por lo tanto esta debe ser la unica alternativa que exista para recorrer la tabla(#8), luego se genera un hash de estas filas registradas para mas tarde unirlas con otras filas. De la tabla historico(primer subconsulta)
 Se filtran las filas cuya fecha_fin<to_date(...) con un seq scan porque probablemente esta columna no tiene indice o si tuviera es menos costoso recorrerla toda(#6), veamos que heuristicamente se resuelven los filtros que chocan con solo una tabla para ejecutarlos en paralelo aunque sean de consultas distintas, en comparacion a las otras operaciones, esta fue la que mas costo tuvo, un 17,61 de un total de 29,09.
 Luego se juntan las filas filtradas de historico con las filas filtradas de tarea con un hash join, uniendolas por id_tarea, seguro se estimó que el menor costo seria utilizando un hash join ya que las filas que se estiman para unir no deben ser pocas, y por eso no se utilizo un nested loop(#5).
 Con un HashAggregate se agrupan las filas para generar nodos los cuales se ordenaran mas facilmente con otras filas de la query(#4).
 El Hash(#3) genera una tabla de los registros para utilizarlos en el hash join.
 El seq  scan(#2) fue de los primeros que se ejecutó, si bien no filtra datos, recopila los datos de las columnas que son requeridos por la query, los cuales se filtraran con el hash join del final, probablemente el sgbd estimó que mientras se ejecutaba este seq scan se ejecutarian las operaciones de la subconsulta, ademas de que se necesitan todos los nro_voluntario para comparar con los nro_voluntario resultantes de las subconsultas.
 Por ultimo se realiza un hash join entre el hash de los registros de las subconsultas, con los nro_voluntario de la tabla voluntario, al ordenar los registros de la subconsulta en un hash, el join se estima que será mas eficiente que un nested loop.

 El orden de ejecucion para esta query seria:
 En paralelo se ejecutan #2, #6 y #8. Luego se ejecutan secuencialmente #7, #5, #4, #3, y #1
 */