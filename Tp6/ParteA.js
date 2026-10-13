//1. Muestre el id, nombre y apellido de los empleados que no poseen jefe. Considere tanto los empleados cuyo idJefe es nulo como los que no tienen ese campo.
db.empleado.find({
  $or: [{idJefe: null},
        {idJefe:{$exists: false}}]},
    {nombre: 1, apellido: 1});

//2. Determine cuántos empleados reciben un sueldo superior a 1000 y tienen un porcentaje de comisión mayor al 10%.
db.empleado.countDocuments(
  {sueldo:{$gt: 1000},
    porcComision:{$gt: 10}}
);

//3. Liste el número, la fecha y el video de las entregas que tengan algún renglón con cantidad mayor a 10.
db.entrega.find(
    {renglonEntregas:{cantidad:{$gt:10}}},
    {nroEntrega:1, fechaEntrega:1, idVideo:1}
)
db.entrega.find(
  { "renglonEntregas.cantidad": { $gt: 10 } },
  { nroEntrega: 1, fechaEntrega: 1, idVideo: 1 }
)

//4. Liste los empleados (id, apellido, sueldo y nombre del departamento) que trabajan en un departamento ubicado en la ciudad con id 41570, ordenados por apellido.
db.empleado.find(
    { "departamento.ciudad.idCiudad": 41570},
    { _id: 1, apellido: 1, sueldo: 1, "departamento.nombre": 1}
).sort({apellido: 1});