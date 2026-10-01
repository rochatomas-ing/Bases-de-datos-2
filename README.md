# Bases de Datos 2 — Ingeniería en Sistemas (UNC)

Resoluciones de los trabajos prácticos de la materia **Bases de Datos 2**, más el material de la
cátedra. Es un repositorio de registro y consulta: no hay build, tests ni dependencias, sólo SQL y
PDFs.

## Estructura

```
Tp1/ … Tp6/     soluciones, un archivo por ejercicio
docs/
  Material/     apuntes de la cátedra (clase teórica)
  Tps/          enunciados de los 6 trabajos prácticos
```

Cada `TpN/` corresponde al `docs/Tps/Practico N*.pdf` correspondiente. La numeración de ejercicios se
reinicia en cada TP. Tp6 (MongoDB) todavía no tiene carpeta.

## Los 6 prácticos

| TP | Tema | PDF del enunciado | Qué usa |
|---|---|---|---|
| 1 | Consultas SQL · funciones de ventana · recursión | `Práctico 1 - P1_Consultas_SQL.pdf` (25 consultas) + `Práctico 1 - P2_Func_Ventana.pdf` (8 ejercicios) | PostgreSQL |
| 2 | Restricciones de integridad declarativas (FK, *match types*) | `Practico 2 - Restr_Integ_Declarat.pdf` (4 ejercicios) | PostgreSQL |
| 3 | Acciones procedurales: triggers, funciones y *stored procedures* | `Practico 3 - SQL Procedural (1).pdf` (8 ejercicios) | PostgreSQL |
| 4 | Vistas: actualizabilidad, clave preservada, `WITH CHECK OPTION` | `Practico 4 - Vistas.pdf` (7 ejercicios) | PostgreSQL |
| 5 | Optimización de consultas: planes, índices, B+ vs Hash | `Practico 5 - Optimiz_Consultas.pdf` (5 ejercicios) | PostgreSQL |
| 6 | NoSQL: MongoDB (consultas, agregaciones, índices, modelado) | `Practico 6 - BD NoSQL (version revisada).pdf` (17 ejercicios, partes A–E) | MongoDB |

El material de `docs/Material/` sigue la misma numeración: `BD2_01_Consultas SQL.pdf`,
`BD2_01_SQL Avanzado (ventanas)`, `BD2_02 (Restricciones declarativas)`, `BD2_03 (SQL Procedural)`,
`BD2_04 (Vistas)`, `BD2_05_Optimizacion`, `BD2_06_NoSQL` y `Mongodb - Conexión`.

## Bases de datos

Ambas son servidores de la cátedra, remotos y **compartidos con el resto del curso**.

**PostgreSQL 17.9** — esquemas `unc_esq_voluntario`, `unc_esq_peliculas`, `unc_esq_libreria`, más el
esquema personal `unc_45782957` (tu usuario). Se accede desde DataGrip, configurado como data source
en `.idea/dataSources.xml`:

```
jdbc:postgresql://dbases.exa.unicen.edu.ar:6432/Ing26    usuario: unc_45782957
```

**MongoDB** — base `Peliculas`, desde la sección *Datos de Conexión* del enunciado del Práctico 6:

```
mongosh "mongodb://unc_DNI:DNI@dbases.exa.unicen.edu.ar:29017/Peliculas?authSource=admin"
```

## Estado

- **Tp1** — consultas 1–24 resueltas; falta la 20 (salteada) y la 25.
- **Tp2** — completo, con una duda sin resolver en el 4.a.
- **Tp3** — ejercicios 1–6 resueltos; faltan el 7 y el 8.
- **Tp4** — completo, salvo el inciso c) del ejercicio 6.
- **Tp5** — sin empezar.
- **Tp6** — sin empezar.

Las convenciones de estilo y las trampas de la base están en [`AGENTS.md`](AGENTS.md).
