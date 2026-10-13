-- Ejercicio 3 - Tp5: esquema de empleados de grupos de investigación
-- Enunciado: docs/Tps/Practico 5 - Optimiz_Consultas.pdf

DROP TABLE IF EXISTS unc_45782957.TRABAJA_EN;
DROP TABLE IF EXISTS unc_45782957.PROYECTO;
DROP TABLE IF EXISTS unc_45782957.EMPLEADO;

CREATE TABLE unc_45782957.EMPLEADO (
    id_empleado integer PRIMARY KEY,
    nombre      varchar(50),
    apellido    varchar(50),
    cargo       varchar(80)
);

CREATE TABLE unc_45782957.PROYECTO (
    cod_proyecto integer PRIMARY KEY,
    nombre       varchar(80),
    fecha_desde  date,
    fecha_hasta  date
);

CREATE TABLE unc_45782957.TRABAJA_EN (
    id_empleado  integer NOT NULL,
    cod_proyecto integer NOT NULL,
    cant_horas   integer,
    PRIMARY KEY (id_empleado, cod_proyecto),
    FOREIGN KEY (id_empleado) REFERENCES unc_45782957.EMPLEADO (id_empleado),
    FOREIGN KEY (cod_proyecto) REFERENCES unc_45782957.PROYECTO (cod_proyecto)
);

INSERT INTO unc_45782957.EMPLEADO VALUES
(1, 'Juan', 'Perez', 'investigador'),
(2, 'Rosa', 'Gomez', 'investigador'),
(3, 'Bruno', 'Fernandez', 'becario'),
(4, 'Ignacio', 'Rodriguez', 'becario'),
(5, 'Alejandro', 'Perez', 'investigador'),
(6, 'Sebastian', 'Solano', 'investigador');

INSERT INTO unc_45782957.PROYECTO VALUES
(1, 'ROBOTICS', '2018-01-01', '2020-01-01'),
(2, 'IA', '2017-01-01', '2020-01-01'),
(3, 'IMAGE', '2015-01-01', '2017-01-01');

INSERT INTO unc_45782957.TRABAJA_EN VALUES
(1, 1, 40), (2, 1, 40), (3, 1, 20), (4, 1, 20), (5, 1, 40), (6, 1, 40),
(1, 2, 40), (3, 2, 20), (6, 2, 20), (3, 3, 10), (6, 3, 10);

ANALYZE unc_45782957.EMPLEADO;
ANALYZE unc_45782957.PROYECTO;
ANALYZE unc_45782957.TRABAJA_EN;
