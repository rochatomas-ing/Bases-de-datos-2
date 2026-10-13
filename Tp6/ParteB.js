//5. Liste, sin repetir, las tareas (id y nombre) que están siendo ejecutadas por los empleados.

db.empleado.aggregate([
    {$group: {_id: "$tarea.idTarea",nombre: {$first: "$tarea.nombreTarea"}}}
]
)

//6. Liste, sin repetir, las tareas que tienen sueldo mínimo mayor a 1000 y sueldo máximo menor a 10000. ¿Por qué hace falta agrupar si solo se pide filtrar? Relaciónelo con cómo está modelada la tarea en la Figura 1.

db.empleado.aggregate([
  { $match: { "tarea.sueldoMinimo": { $gt: 1000 },
              "tarea.sueldoMaximo": { $lt: 10000 } } },
  { $group: { _id: "$tarea.idTarea" } }
]);

//Como empleados distintos pueden tener la misma tarea, esto desemboca en que una misma tarea que cumple la condicion de filtro esté repetida en los documentos resultantes, el $group filtra las repetidas y las hace unicas.
//No existen tareas que cumplan ambas condiciones: el valor mínimo de tarea.sueldoMaximo en toda la colección es X, que ya supera los 10000 del enunciado. Por lo tanto el resultado es una lista vacía.

//7. Liste el identificador de cada video y la cantidad de entregas que se le han realizado, ordenados de mayor a menor cantidad.

db.entrega.aggregate([
    { $group: {_id: "$idVideo", cantidadEntregas:{ $sum: 1}}}
    ,
    { $sort: {cantidadEntregas: -1}}
])

//8. Determine la cantidad de películas producidas por cada empresa productora (código, nombre y cantidad).

db.pelicula.aggregate([
    { $group: {_id: "$codigoProductora", nombre: {$first: "$empresaProductora.nombreProductora"}, cantidad: {$sum: 1}}}
])

//9. Liste las 5 ciudades con más películas de género Infantil, considerando solo las ciudades con más de 5 películas de ese género. Muestre el nombre de la ciudad y la cantidad, de mayor a menor. (La ciudad de una película es la de su empresa productora.)

db.pelicula.aggregate([
    { $match: { genero: "Infantil " }},

    { $group: {_id: "$empresaProductora.idCiudad", nombreCiudad: { $first: "$empresaProductora.ciudad.nombreCiudad"}, cantidad: { $sum: 1 }}},

    { $match: { cantidad: { $gt: 5}}},

    { $sort: {cantidad: -1}},

    { $project: {_id: 0}},

    { $limit: 5}
])

//10. Modifique la consulta del ejercicio 7 para que muestre también la razón social de cada video. Utilice $lookup.
//"//7. Liste el identificador de cada video y la cantidad de entregas que se le han realizado, ordenados de mayor a menor cantidad."
db.entrega.aggregate([
    {$lookup: {
            from: "video",
            localField: "idVideo",
            foreignField: "idVideo",
            as: "video"
        }},

    { $unwind: "$video" },

    {$group: { _id: "$idVideo", cantidadEntregas: { $sum: 1}, razonSocial: {$first: "$video.razonSocial"}}},

    { $sort: {cantidadEntregas: -1}}
])

//11. Obtenga las 10 películas con más unidades entregadas (suma de cantidad en todos los renglones de todas las entregas), mostrando código, título y unidades. Utilice $unwind y $lookup.

db.entrega.aggregate([
    { $unwind: "$renglonEntregas"},

    { $lookup: {
        from: "pelicula",
        localField: "renglonEntregas.codigoPelicula",
        foreignField: "codigoPelicula",
        as: "pelicula"
    }},

    { $unwind: "$pelicula"},

    { $group: { _id: "$pelicula.codigoPelicula", titulo: {$first: "$pelicula.titulo"}, unidades: { $sum: "$renglonEntregas.cantidad"}}},

    { $sort: {unidades: -1}},

    { $limit: 10}
])