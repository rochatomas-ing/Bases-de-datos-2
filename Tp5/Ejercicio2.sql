--Ejercicio 2

--Dada la siguiente consulta sobre el esquema de voluntarios, analice su plan de ejecución (con EXPLAIN ANALYZE). ¿Cómo es posible mejorarla?
EXPLAIN ANALYZE
SELECT *
FROM unc_esq_voluntario.tarea
WHERE id_tarea IN (
    SELECT t.id_tarea
    FROM tarea t inner join unc_esq_voluntario.voluntario v  on (t.id_tarea = v.id_tarea)
    GROUP BY t.id_tarea
    HAVING COUNT(v.nro_voluntario) > 5);
/*
 Heuristicamente el sgbd va a priorizar primeros los filtros, luego las proyecciones y por ultimo los joins. Vemos en este caso que la tabla tarea no se filtran datos, solo se recuperan y se compara el id_tarea con las columnas resultantes de la subconsulta.
 Seq Scan(#6): de la tabla voluntario se recuperan todas las tareas para luego se comparadas con las tareas de la tabla tarea, probablemente esta columna no tenga indice y lo unico para hacer era un seq scan, es decir, recorrer toda la tabla, esta operacion tuvo un costo medianamente alto, en comparacion a todas las otras operaciones.
 Seq Scan(#8): Mismo analisis de #6 para la columna id_tarea de la tabla tarea, costo bajo.
 Hash(#7): De las filas recuperadas (id_tarea) de tarea, se generaró una tabla hash que referencia a esas filas, para luego utilizar un hash join, este hasheo tuvo costo bajo.
 Hash join(#5): Entre la tabla de hash de #7 y las filas recuperadas de #6, se unieron las filas recuperadas de voluntario y de tarea, comparandose por id_tarea, seguramente el sgbd utilizó un hash para generar mas eficientemente la comparacion entre filas, al estimar una considerable cantidad de filas, se prefirio esta tecnica seguramente antes que un nested loop, costo bajo aunque tiempo de ejecucion alto.
 Hash aggregate(#4): Luego de #5, se debió agrupar por id_tarea y realizar el filtro de count(v.nro_voluntario)... , esta operacion no se pudo realizar antes ya que se debia agrupar por id_tarea, y ademas es una operacion de grupos por lo tanto el hashaggregate fue la mejor opcion, tuvo un costo bajo.
 Hash #3: Se genera una tabla hash para luego hacer un join de las filas resultantes de la ejecucion de la subconsulta, la subconsulta se debe unir mediante un join con los valores correspondientes obtenidos en la tabla tarea, el  sgbd determinó que esta seria la operacion mas eficiente para unir las filas de la tabla tarea con las filas de la subconsulta, el costo de esta operacion es practicamente cero.d
 Seq Scan(#2): Seq Scan (#2): En la consulta principal, se obtienen todos los datos de todas las columnas de la tabla tarea, y luego se filtra por id_tarea, como se necesitan todos, el sgbd probablemente debe interpretar que la mejor forma es recorrer toda la tabla con un seq scan ya que utilizar algun indice seria contraproducente ya que se deberian referenciar todas las filas, el costo de esta operacion es medio-bajo.
 Hash join #1: Por ultimo se realiza un join entre las filas obtenidas de #2 y el hash de #3(subconsulta), si bien lo que se hace es un filtro IN en el where, el sgbd interpreta que lo mas eficiente es realizar un join entre las filas de #2 y #3, el costo es considerablemente alto.

 El orden de ejecucion es:  En paralelo se ejecuta: #2, #6 y #8, luego secuencialmente lo siguiente: #7, #5, #4, #3, #1.

 Se puede mejorar realizando solo la subconsulta y pidiendo todas las columnas (SELECT *). Luego se agrupa sol por id_tarea, aunque en postgre se debe agrupar por todas las columnas que estan en el select, asique se agrupa por *, y se tiene el mismo HAVING. Asi no se recorreria 2 veces la tabla tarea, y seria mas eficiente.
 */
--Ejemplo:
SELECT nombre_tarea,min_horas,t.id_tarea,max_horas
    FROM tarea t inner join unc_esq_voluntario.voluntario v  on (t.id_tarea = v.id_tarea)
    GROUP BY nombre_tarea, min_horas, t.id_tarea, max_horas
    HAVING COUNT(v.nro_voluntario) > 5;
