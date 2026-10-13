--Con el comando EXPLAIN ANALYZE, explique la heurística que utiliza para la query plan del optimizador de PostgreSQL en cada una de las sentencias siguientes:


--a)Listar los datos de los empleados investigadores que trabajan en algún proyecto
EXPLAIN ANALYZE
SELECT  DISTINCT E.*
FROM	EMPLEADO E  	,
    	TRABAJA_EN T	,
    	PROYECTO P
WHERE E.id_empleado = T.id_empleado
AND P.cod_proyecto = T.cod_proyecto
AND E.cargo = 'investigador';
/*
 La heuristica de postgre propone lo siguiente: La forma de resolver esta consulta es: recorrer toda la tabla trabaja_en con un Seq Scan(#4), las cuales se obtuvieron 11 filas, luego recorrer la tabla empleado tambien con un seq scan(#6), filtrando los cargos 'investigador', las cuales se obtuvieron 4 filas, y a las filas de empleado generarles una tabla de hash(#5) para poder unir con un hash join. Probablemente el sgbd estimó que esto sería lo mejor ya que la tabla trabaja_en tiene mas filas que la tabla empleado, por lo tanto, generar un hash para esta seria menos eficiente que generarla para la tabla empleado, que tiene menos tuplas(#3), ademas hay que saber que se prefirió primero filtar primero los investigadores y luego el join ya que heuristicamente y relacionalmente esto es lo mejor.
 Para  la tabla proyecto se recorrío con seq scan(#8) y luego se generó una tabla hash de las filas de esta tabla para proximamente unirlas con el join que se generó en el parrafo anterior(#3), como la fila proyecto se estimó que tendria menos filas que las obtenidas en el hash join(#3), se prefirió generar una tabla hash para las filas de proyecto(#7).
 Luego se generó un hash join(#2) entre las filas obtenidas en #3 y en #7, probablemente se prefirió utilizar un hash join antes que un nested loop, para  no leer la tabla entera empleado, aunque en este caso es una tabla con pocos datos y no se si tendria mucho sentido generar una tabla hash.
 Por ultimo el HashAggregate(#1) se encargó de filtar las filas repetidas, las cuales fueron 3, esta probablemente era la unica forma de cumplir con el Distinct de la consulta.
 Como las tablas tiene muy pocos datos el seq scan no penaliza, si se tuviera algun tipo de indice y el volumen de datos seria enorme, lo mejor probablemente seria utilizar esos indices, y no recorrer toda la tabla(seq scan).

 En palabras simples, lo que se hizo fue primero filtrar por investigador de la tabla empleado, luego juntar las filas filtradas con las tuplas de la tabla trabaja_en y por ultimo juntar estas filas, con las obtenidas de la tabla proyecto.

 --a.1)El ensamble con empleado si es necesario ya que se deben listar los datos de cada empleado.
 --a.2)El ensamble con proyecto no es necesario ya que en trabaja_en ya podemos verificar si el empleado trabaja en un proyecto o no.
 --a.3)El distinct lo unico que implica es recorrer toda la tabla resultado denuevo, ya que se realiza al final, luego de cumplir con todos los filtros del where. Es decir, no implica demasiado trabajo si los datos resultantes no son muchos, crece con el volumen resultado de datos.
 */

--b)Listar los datos de los proyectos de IA que tienen empleados trabajando

EXPLAIN ANALYZE
SELECT DISTINCT P.*
FROM	TRABAJA_EN T	,
    	PROYECTO P
WHERE P.cod_proyecto = T.cod_proyecto
AND P.nombre = 'IA';
/*
 La forma de resolver esta consulta segun postrgre y el sgbd, fue:
 Primero se realiza un seq scan(#3) de la tabla trabaja_en, se necesitan traer todas las tuplas de esta tabla para luego realizar un join con las tablas obtenidas de protecto.
 Se realiza un Seq Scan(#5) en la tabla proyecto, y heuristicamente el sgbd sabe que lo mejor es realizar el filtro que solo le pega a la tabla proyecto, es decir, p.nombre='IA', esta condicion filtrará las tablas y esto permitirá que se unan menos filas cuando se unan las tuplas de proyecto con las de trabaja_en, segun el sgbd y el algebra relacional esto es lo mas optimo. Siempre llevar las condiciones que abarcan solo a una tabla a las hojas del arbol.
 De #5, se realiza una tabla de hash para poder unir las filas esas, con las filas obtenidas en #3, en #3 hay mayor cantidad de filas obtenidas(11) que en el filtro del seq Scan#5(1), lo mejor es realizar la tabla de hash al que menos filas tenga, asi el filtro es mas rapido.
 Se realiza un hash join(#2) entre las filas obtenidas en #3 y las de #5 utilizando la tabla de hash de #4, en este join se obtienen sol 3 filas que matchean.
 Por ultimo se realiza el HashAggregate(#1) el cual se utiliza para abarcar la operacion DISTINCT, se observan los valores repetidos y se eliminan de la tabla resultado, el hashaggregate es la unica opcion para el sgbd por lo que no existen distintas alternativas con mejor costo para abarcar la operacion.

 b.1) Analizar para la restricción de clave primaria establecida como (id_empleado, cod_proyecto)
 b.2) Analizar para la restricción de clave primaria establecida como (cod_proyecto, id_empleado)
 En ambos casos b.1 y b.2, es indistinto el orden de la clave primaria, ya que la clave primaria es compuesta, es indistinto el orden, semanticamente representan lo mismo en el diagrama.

 Es la regla del prefijo izquierdo: un índice compuesto solo se usa eficientemente igualando un prefijo desde la izquierda. Buscar por la segunda columna sola es como buscar en la guía telefónica por nombre cuando está ordenada por apellido.
Qué pasa con la consulta de b) entonces:
- Con b.2), el planner podría usar el índice de la PK de TRABAJA_EN para encontrar las filas de un proyecto dado (Index Scan con cod_proyecto = ? como condición del join).
- Con b.1), ese índice no le sirve para el join → le queda Seq Scan sobre TRABAJA_EN + hash join, o nested loop con el índice de PROYECTO.
Matiz importante que va en tu favor (mencionalo): con 11 filas, en la práctica el planner probablemente elige Seq Scan en ambos casos, porque leer 1 página entera es más barato que índice + heap. O sea: conceptualmente b.2) habilita un camino que b.1) no, pero a este volumen el EXPLAIN te puede dar el mismo plan. Esa es la justificación honesta — y conecta con el ejercicio 5, donde con 50.000 filas sí se ve la diferencia.
 */

