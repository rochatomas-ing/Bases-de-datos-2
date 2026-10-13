/*
Ejercicio 5 — Practico 5 "Optimizacion de Consultas" (docs/Tps/Practico 5 - Optimiz_Consultas.pdf)

El resto del practico trabaja con tablas de pocas filas, asi que el optimizador va a elegir Seq Scan casi siempre,
tenga o no un indice disponible. Este ejercicio permite ver el efecto real de un indice: cada alumno crea su
propia tabla con volumen suficiente, la usa para comparar planes con y sin indice, y la elimina al terminar para
no ocupar espacio en el servidor compartido.

Nota: la tabla es propia, asi que va calificada con unc_45782957 (el rol no tiene search_path en el server).
*/

--a) Crear una tabla propia y cargarla con datos sinteticos (no depende de ninguna otra tabla del practico)
CREATE TABLE unc_45782957.ejercicio5_ventas (
    id_venta    serial PRIMARY KEY,
    id_producto integer,
    fecha_venta date,
    monto       numeric(10,2)
);

INSERT INTO unc_45782957.ejercicio5_ventas (id_producto, fecha_venta, monto)
SELECT (random() * 500 + 1)::int,
       CURRENT_DATE - (random() * 1825)::int,
       (random() * 10000)::numeric(10,2)
FROM generate_series(1, 50000);

ANALYZE unc_45782957.ejercicio5_ventas;

--b) Sin crear ningun indice, ejecutar y conservar el resultado de:
--Que tipo de nodo de acceso aparece? Cuantas filas descarta (Rows Removed by Filter)? Cual es el Execution Time?
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM unc_45782957.ejercicio5_ventas WHERE id_producto = 37;
/*
 En esta query, vemos que de un total de 50000 filas, se estan filtrando 49908 filas y solo se  retornan 96, el nodo de acceso es un seq scan, es decir, se recorre toda la tabla para filtrar ya que no existe indice. Esta es la unica alternativa. El execution time es de 2.063 ms.
 */

--c) Crear un indice sobre la columna filtrada y repetir la misma consulta:
--Cambio el tipo de nodo? Como cambiaron los Buffers (shared hit / read)? En que proporcion bajo el
--Execution Time respecto del punto b?
CREATE INDEX idx_ventas_producto ON unc_45782957.ejercicio5_ventas (id_producto);

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM unc_45782957.ejercicio5_ventas WHERE id_producto = 37;
/*
 En este caso, como ahora poseemos un indice, primero se realizó un bitmap Index Scan, en donde se encontraron las paginas relevantes que poseen alguna fila la cual cumple con la condicion, y luego se realizó un Bitmap Heap Scan, en donde para cada pagina se buscó la fila que coincidia con el filtro.
 El tiempo de ejecucion en este caso fue de 0,259ms. Unas 10 veces menos que sin el indice.
 */

--d) Repetir b) y c), pero ahora con una condicion mucho menos selectiva:
--El optimizador usa el indice o vuelve a un Seq Scan? Justificar la respuesta en terminos de selectividad,
--retomando la seccion del material de EXPLAIN ANALYZE que explica por que "Seq Scan = malo, indice = bueno"
--es falso.
BEGIN;
DROP INDEX unc_45782957.idx_ventas_producto;
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM unc_45782957.ejercicio5_ventas WHERE id_producto <= 250;
ROLLBACK;
/*
 En el caso de que no utilizaramos indices, se realiza un seq scan de toda la tabla ejercicio5_ventas, se filtran 25103 filas y se recuperan 24836 filas, la ejecucion de esta query con este metodo tarda 3.751ms
 */

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM unc_45782957.ejercicio5_ventas WHERE id_producto <= 250;
 /*
  En el caso de que si utilizamos un indice, se realiza primero un bitmap index scan buscando las paginas donde hayan filas que cumplan la condicion, y luego con un bitmap heap scan se revisa cada fila de las paginas obtenidas en el paso anterior, verificando que cumplan la condicion y quedandose con ellas, en este caso la ejecucion tarda entre 3.481ms y 4.0ms, lo cual no es mucho ya que el volumen de datos no es grande, pero vemos que se traen el 50% de los datos de la tabla original, por lo tanto usar indice para esta consulta menos restrictiva terminaria siendo peor
  */

--e) Al finalizar, eliminar la tabla para liberar el espacio en el servidor compartido:
DROP TABLE unc_45782957.ejercicio5_ventas;