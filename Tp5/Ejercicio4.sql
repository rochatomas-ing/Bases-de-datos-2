/*
Para cada una de las siguientes consultas sobre el esquema de Películas:
Nota: Si con el volumen disponible el optimizador no elige el índice espontáneamente, usar SET enable_seqscan = off; (ver nota inicial) para comparar el plan con y sin índice.
 */

--a) Analizar y justificar la creación o no de índices considerando que cada consulta es muy frecuente en el contexto planteado. Considere también la creación de índices que sirvan para más de una de las consultas.

--b) Conociendo que las opciones de estructuras de índices en PostgreSQL son árboles B+ y Hash, analizar cuál de ellas resulta más eficiente en cada situación y por qué.

--b.1)
set enable_seqscan =off;
EXPLAIN analyse
SELECT * FROM entrega
WHERE fecha_entrega <
CURRENT_DATE - INTERVAL '100 months';
reset enable_seqscan;
/*
 Se responden a y b juntas:
 Como la condicion de la query tiene que ver con un rango, lo mejor en ese caso seria crear un indice utilizando el metodo b-tree seria lo correcto ya que cuando tenemos un rango, y matchea uno, como estan ordenados, los valores anteriores leidos cumpliran con la condicion o en caso contrario, los siguientes, el ultimo que matchea es la frontera donde comienzan o terminan los datos correctos. En cambio un indice con metodo hash, las filas se mapean aleatoriamente por lo tanto sirve para igualaciones, no para rangos. El indice se justificaria solo si las filas que cumplen la condicion son relativamente bajas, ya que si la consulta devuelve mas del 25% de las filas de la tabla, seria mas eficiente utilizar un seq scan.
 Como la query devuelve 5003 filas, y solo filtra 3000, está devolviendo 5003 filas de un total de 8003, es aproximadamente un 55% del total, por lo tanto para este caso no seria recomendable un indice.
 */

--b.2)
EXPLAIN ANALYZE
SELECT * FROM distribuidor
WHERE id_distribuidor > 50;
/*
 Para esta query igual que la anterior, estamos calculando un rango, en caso de utilizar un indice lo mejor seria utilizar un B+, ya que tendriamos los valores ordenados en el arbol, y en caso de matchear, los valores anteriores al ultimo match, o los valores siguientes al primer match, serian todos correctos, es decir, cumplirian con la condicion, un hash en cambio no seria correcto.
 En este caso luego de ejecutar la query, vemos que devuelve 1000 filas y solo  se filtraron 50, es decir, se devolvieron el 95% de las filas de la tabla, por lo tanto crear un indice B+ seria muy ineficiente, solo seria correcto, en caso de que las filas devueltas correspondan a menos de un 25% de los datos.
 */

--b.3)
EXPLAIN ANALYZE
SELECT * FROM distribuidor
WHERE tipo = 'N';
/*
 En este caso estamos en una condicion de igualacion, por lo tanto, si pensaramos en crear un indice lo mejor seria utilizar un hash, ya que para la igualacion es lo mejor. En cambio con un B+ no nos serviria ya que no nos sirve tener los valores ordenados.
 Vemos que la query nos devuelve 694 filas y el total son unas 1050 filas, por lo tanto nos está devolviendo casi un 70% de todas las filas. Por lo tanto en este caso no seria recomendable crear un indice para la columna tipo.
 */

--b.4)
EXPLAIN ANALYZE
SELECT * FROM empleado
WHERE nombre = 'Juan Lucas'
AND e_mail = 'Pla@gmail.com';
/*
 En este caso estamos utilizando filtros de igualacion para todas las columnas del filtro, por lo tanto, lo mejor seria utilizar un inidice hash para nombre e e_mail, además, en el explain analyze vemos que de un total de 35080 filas, la query nos devuelve solo una, entonces estamos en el caso ideal para realizar la creacion del indice, ya que nos devuelve menos del 1% de los datos.
 */

--b.5)
EXPLAIN ANALYZE
SELECT * FROM empleado
WHERE nombre LIKE 'An%'
AND e_mail = 'Marise@gmail.com';
/*
 En este caso estamos filtrando el e_mail con una igualdad pero el nombre con un like con prefijo por lo tanto en caso de utilizar un indice seria con B+ para la columna nombre, y para la columna e_mail lo mismo, ya que no tendria sentido tener un hash y un b-tree. Aunque se devuelven menos del 1% de las filas, es decir, se filtra muchisimas, en caso de utilizar un indice lo mejor seria un B+.
 */

--b.6)
EXPLAIN ANALYZE
SELECT * FROM empleado
WHERE nombre LIKE '%Maria'
AND e_mail = 'Marise@gmail.com';
/*
 En este caso realizamos lo mismo que el ejercicio anterior pero el like es con sufijo, y un indice B+ no puede resolver las comparaciones con sufijo por lo tanto no se podria crear un indice para la columna nombre en este caso, por lo tanto no serviria para nada.
 */

 /*
  Para b.4, b.5 y b.6 lo mejor seria utilizar un indice hash para la columna e_mail, y ya.
  */
