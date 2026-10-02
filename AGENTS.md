# AGENTS.md — Bases de Datos 2 (UNC)

## Qué es este repo

Colección de SQL escrito a mano para los TP de la materia, más el material de la cátedra en `docs/`.
**No es un proyecto de software**: no hay build, tests, linter, CI, ni package manager. No instales
nada ni agregues dependencias: los únicos comandos son `git`, `pdftotext` y el editor.

El repo es un registro personal de avance (se consulta desde varios dispositivos), no código que
vaya a producción.

## Estructura

- `Tp1/` … `Tp5/` — un trabajo práctico por carpeta. La numeración de ejercicios **se reinicia en cada TP**.
  La cátedra tiene **6** TPs: falta la carpeta `Tp6/` (MongoDB).
- Dentro de cada TP, un archivo por ejercicio: `Ejercicio<N>.sql`.
- `docs/Material/` — apuntes de la cátedra, un PDF por unidad.
- `docs/Tps/` — enunciados, un PDF por TP (Tp1 viene partido en P1 y P2).
- Tp1 tiene dos mitades: `tp1_parte1.sql`, `tp1_parte2_querys.sql`.
- Tp5 está vacío; `Tp5/Ejercicio1` existe con 0 bytes y está *staged* en git. No lo borres ni lo comitees vacío.
- **Extensión inconsistente**: varios archivos no tienen `.sql`. Los sin extensión son casi siempre
  prosa/análisis, no SQL ejecutable (`Tp2/Ejercicio 1_b`, `Tp3/Ejercicio3`, `Tp4/Ejercicio3|4|5`,
  `Tp4/Ejercicio6 Respuesta`). Si creás SQL nuevo, usá `.sql`.
- Cuando un ejercicio se parte en varios archivos, se sufixa: `Ejercicio6_triggers.sql`,
  `Ejercicio6 Respuesta`.

## Base de datos — lo más importante

PostgreSQL **17.9 remoto de la cátedra**, configurado como data source de DataGrip en
`.idea/dataSources.xml`:

- host `dbases.exa.unicen.edu.ar`, puerto `6432`, base `Ing26`
- usuario/rol: `unc_45782957` (tu schema personal). La cuenta expira el 31/12/2027.

Es un servidor **compartido por todos los alumnos de la cátedra**: nunca escribas fuera de
`unc_45782957`, y no ejecutes `DROP`/`TRUNCATE`/`DELETE` masivo — la cátedra y tus compañeros usan
esa misma base.

Schemas disponibles:

| Schema | Contenido |
|---|---|
| `unc_esq_voluntario` | `continente`, `direccion`, `historico`, `institucion`, `pais`, `tarea`, `voluntario` |
| `unc_esq_peliculas` | `ciudad`, `departamento`, `distribuidor`, `empleado`, `empresa_productora`, `entrega`, `internacional`, `nacional`, `pais`, `pelicula`, `renglon_entrega`, `tarea`, `video` |
| `unc_esq_libreria` | `autor`, `cliente`, `condicion`, `editorial`, `libro`, `titulo`, `venta`, `volumen` |
| `unc_45782957` | **Tu schema.** Tablas base de los ejercicios de Tp2/Tp3/Tp4 (`articulo`, `cliente`, `envio`, `instalacion`, `producto`, `provee`, `proveedor`, `referencia`, `servicio`, `sucursal`) mezcladas con tus objetos creados (`his_entrega`, `ciudad_kp_2`, `entregas_kp_3`) |

Trampas verificadas:

- **El DDL de las tablas de `unc_45782957` no está en este repo.** No existe ningún `CREATE TABLE`
  para `provee`, `envio`, `cliente`, etc. Antes de escribir SQL contra ellas, mirá las columnas con
  `\d unc_45782957.<tabla>` en la consola de DataGrip. No adivines nombres de columnas.
- **Siempre calificar con el schema** (`unc_esq_peliculas.empleado`). Tu rol **no tiene `search_path`
  configurado en el server**, así que los nombres sin calificar no resuelven. `Tp2/Ejercicio1.sql`,
  `Tp3/Ejercicio1.sql`, `Tp4/Ejercicio4` y `Tp4/Ejercicio5` usan nombres cortos y sólo funcionan si la
  sesión tiene un `SET search_path` — no copies ese patrón.
- **No hay `psql` en el PATH de esta máquina.** No podés verificar nada ejecutando desde la terminal;
  la validación se hace en la consola de DataGrip. Decí explícitamente al usuario que la consulta
  no fue ejecutada, en vez de dar por hecho que corrió.
- `unc_45782957` mezcla lo que da la cátedra con lo que creás vos: elegí nombres que no colisionen.
  Convención observada: vistas con prefijo `V_` (`V_ENVIOS_500`, `V_VOLUNTARIO_TAREA`) o sufijo de
  cátedra (`ciudad_kp_2`).
- `Tp4/Ejercicio5` redefine `V_EMPLEADO_DIST_20`, de la que dependen
  `V_EMPLEADO_DIST_20_SUELDOMAYORA_2000` y `V_EMPLEADO_DIST_20_NACIDO_DECADA_70`. Cambiar esa vista
  sin recrear las derivadas rompe el encadenamiento de `Tp4/Ejercicio2`.
- La introspección de DataGrip (`.idea/dataSources/`, puede estar desactualizada) indica que
  `Tp3/Ejercicio3` y `Tp3/Ejercicio5` **nunca se ejecutaron**: `empleado_1`/`empleado_2` y
  `historico_empleado_departamento` no existen en el servidor. No asumas que "ya corrió" porque el
  SQL está escrito.

## Cómo trabajar con `docs/`

**Este modelo no puede leer PDFs como imagen**: `read` sobre un `.pdf` falla. Extraé el texto con
`pdftotext`, que sí está instalado:

```bash
pdftotext -layout "docs/Tps/Practico 4 - Vistas.pdf" -        # a stdout
pdftotext "docs/Tps/Practico 4 - Vistas.pdf" /tmp/tp4.txt    # a archivo
pdfinfo "docs/Tps/Practico 4 - Vistas.pdf" | grep Pages       # nº de páginas
```

- El enunciado va **citado arriba de la solución** como bloque de comentario (`/* */` en
  `Tp4/Ejercicio2.sql`, `--` en `Tp4/Ejercicio7.sql`), y la justificación en prosa va **debajo** del
  SQL, en el mismo archivo. Citá la ruta del PDF de origen.
- **Los enunciados traen el SQL con nombres de tabla sin calificar** (`FROM pelicula`,
  `FROM voluntario`). Hay que **agregar el prefijo de esquema** al transcribirlos
  (`unc_esq_peliculas.pelicula`), o no van a resolver. El enunciado no es copiable tal cual.
- Verificá los nombres de columna contra la base antes de usarlos: las columnas que piden
  (`voluntario.telefono`, `pelicula.genero`, `historico.fecha_fin`) existen, pero otras
  variantes del enunciado no.
- `docs/Material/BD2_01_Consultas SQL.pdf` y `BD2_01_Consultas SQL (1).pdf` son **el mismo archivo**
  (idéntico md5, 70 págs). Es un duplicado.
- Los PDFs están encabezados "Fac. Cs. Exactas. **UNCPBA**", pero el servidor de la base es de
  **UNICEN** (`unicen.edu.ar`). Son servidores distintos: no los confundas.

## Tp5 — Optimización de consultas (aún sin empezar)

No es lo mismo que los TPs anteriores: el enunciado **trae las consultas ya escritas**; el trabajo es
`EXPLAIN` / `EXPLAIN (ANALYZE, BUFFERS)`, justificar índices y comparar B+ vs Hash.

- El servidor es compartido y **no hay volumen de prueba**. Cuando el optimizador no elija un Index
  Scan por sí solo, el propio enunciado autoriza forzar la comparación con
  `SET enable_seqscan = off;` … `RESET enable_seqscan;`. No está prohibido el Seq Scan, sólo se lo
  encarece artificialmente para poder observar el plan alternativo. **Usalo y mencioná que lo usaste.**
- El ejercicio 5 pide crear una tabla propia con volumen real (`ejercicio5_ventas`, 50 000 filas
  sintéticas vía `generate_series`) y **borrarla al terminar** para no ocupar espacio en el servidor
  compartido. `DROP TABLE` acá sí está pedido explícitamente.
- El ejercicio 3 usa un esquema propio del enunciado (`EMPLEADO`, `PROYECTO`, `TRABAJA_EN`) que
  **no existe en la base**: hay que crearlo.

## Tp6 — NoSQL / MongoDB (aún sin empezar)

Cambia de motor: no es SQL. La base es `Peliculas` y **está compartida con todo el curso**:

```
mongosh "mongodb://unc_DNI:DNI@dbases.exa.unicen.edu.ar:29017/Peliculas?authSource=admin"
```

- **Las partes C (modifica datos) y D (crea índices) hay que hacerlas sobre una copia local**, no
  sobre la base de la cátedra. El enunciado incluye el `mongodump` / `mongorestore` para bajarla
  (alternativa: exportar a JSON con Compass).
- Antes de cualquier `updateMany` / `deleteMany`, correr un `find()` con el mismo filtro para ver a
  qué documentos afecta.
- Ojo con la diferencia entre campo `null` y campo **inexistente**, y con valores guardados como
  `10` vs `0.10`. El enunciado avisa expresamente de esto.
- Herramientas que pide: MongoDB Server, MongoDB Database Tools (`mongodump`/`mongorestore`),
  Compass, y la extensión MongoDB for VS Code. Ninguna está instalada: no asumas que `mongosh`
  existe en el PATH.

## Estado de avance

Contra los enunciados de `docs/Tps/`, lo que falta es:

- **Tp1 parte 1** — el enunciado tiene 25 consultas; faltan la **20** (saltada con `--20 Alta paja.` en
  `Tp1/tp1_parte1.sql:138`, pide rehacer el grupo anterior con *subqueries*) y la **25** completa
  ("interpretación de resultados con nulos", 3 sub-grupos a/b/c).
- **Tp1 parte 2** — el enunciado tiene 8 ejercicios y el archivo tiene 9 marcadores: `--8.` aparece
  **dos veces** (el segundo es la recursiva), y al final quedó una query suelta sin terminar
  (`SELECT id_empleado FROM unc_esq_peliculas.empleado`, sin `;`).
- **Tp2** — completo, salvo `Tp2/Ejercicio_2_3_4:13`, donde el 4.a quedó como
  `ASSERTION o check de tabla?????????` sin decidir.
- **Tp3** — el enunciado tiene **8** ejercicios; en el repo están el 1 al 6. Faltan el **7**
  (tabla `TextosporAutor` + procedural + triggers) y el **8** (orden de ejecución de los triggers
  T1–T4 sobre `log_trigger` / `area_conocimiento`).
- **Tp4** — completo, salvo el inciso **c)** del ejercicio 6, que quedó en `--....`
  (`Tp4/Ejercicio6_triggers.sql:68`).
- **Tp5** y **Tp6** — sin empezar (no hay soluciones; `Tp5/Ejercicio1` está vacío).

Marcá los supuestos explícitamente en vez de inventar. Ya hay precedentes en el repo:
`Tp1/tp1_parte1.sql:161` (`--24.(No la entendi asique la hizo la ia)`) y
`Tp1/tp1_parte1.sql:138` (`--20 Alta paja.`). Si algo no se entiende, anotá la duda y pedila.

## Estilo de las soluciones (lo que el repo ya sigue)

- Todo en español: comentarios, alias, mensajes de `RAISE EXCEPTION`. Las tildes son inconsistentes
  en los comentarios existentes; no las fuerces.
- Cada consulta va precedida por su número: `--1.`, `--2.` (Tp1). En Tp3/Tp4: `--a)`, `--b)`, `--1.`.
- Los ejercicios que piden justificación guardan la respuesta **en prosa dentro del mismo archivo**,
  debajo del SQL (ver `Tp4/Ejercicio6 Respuesta`, `Tp2/Ejercicio 1_b`, `Tp2/Ejercicio1_c`).
- Siempre `CREATE OR REPLACE` (functions, triggers y views), para que re-ejecutar un archivo no falle.
- Triggers:
  ```sql
  CREATE OR REPLACE FUNCTION FN_<QUE_HACE>()
  RETURNS TRIGGER AS $$
  BEGIN
      ...
      RETURN NEW;   -- o RETURN OLD en DELETE
  END;
  $$ LANGUAGE 'plpgsql';

  CREATE OR REPLACE TRIGGER TG_<...>
  BEFORE INSERT OR UPDATE OF <cols> ON <tabla>
  FOR EACH ROW
  EXECUTE FUNCTION FN_<...>();
  ```
  Nombres en MAYÚSCULAS. `RAISE EXCEPTION 'mensaje en español', NEW.x;` con placeholders `%`.
  Compará con `IS DISTINCT FROM` (no `<>`), y usá `tg_op` / `TG_OP` para bifurcar por operación.
- `CREATE TABLE` propios en tu schema: `unc_45782957.HIS_ENTREGA`.
- Alias de tablas de una o dos letras (`v`, `e`, `d`, `i`), y `USING(id_x)` para joins por columna
  compartida. Fin de sentencia con `;`.

## `.idea/` está versionado

`.idea/.gitignore` excluye `workspace.xml`, `dataSources/` y `dataSources.local.xml`; el resto del
`.idea/` se commitea.

- `sqldialects.xml` y `data_source_mapping.xml` llevan **una entrada por archivo `.sql`**, y solo
  están los `.sql`: los archivos sin extensión no están registrados. Al crear un `.sql` nuevo, agregá
  `<file url="file://$PROJECT_DIR$/Ruta/Al/Archivo.sql" dialect="PostgreSQL" />` en `sqldialects.xml`
  y, si lo vas a ejecutar, la entrada correspondiente en `data_source_mapping.xml` con el valor
  `c6dcf885-1be1-4081-828a-304c2621def5` (el uuid del data source `Ing26`).
- No edites a mano `dataSources.local.xml` ni `dataSources/` (son estado local, gitignorados).

## Cómo trabajar con el usuario: rol de profesor

El usuario está **aprendiendo** la materia. Quiere resolver los ejercicios por su cuenta y que los
conceptos se corrijan **a partir de lo que le pasa**, no antes.

- **El usuario maneja el ritmo.** No le impongas una metodología, ni etapas, ni el orden en que
  atacar un ejercicio. Ya rechazó explícitamente un ciclo de predicción → ejecución → contraste:
  prefiere resolver "tal cual" y corregir sobre la marcha. Presentá el material y quedate
  disponible.
- En la misma línea: **no lo interroges con preguntas para arrancar**. Cuando le pidas algo, que
  sea una pista o una aclaración puntual, no un cuestionario que lo obligue a justificar antes de
  probar.
- **El objetivo es que entienda.** Cuando traiga un plan, un output o un error:
  - explicá el **concepto** detrás de lo que hizo el motor, no el parche;
  - corregí lo que está mal explícitamente, sin suavizar, aunque incomode;
  - si el error viene de un malentendido de fondo, ése es el punto a atacar, no la sintaxis.
- **No le resuelvas el ejercicio.** Si pide ayuda, primero una pista que lo haga pensar; la
  respuesta directa sólo si insiste o si ya entendió el concepto y sólo le falta la ejecución.
- Cuando algo esté conceptualmente mal y lo escrito en el archivo quede desactualizado, **corregilo
  en el archivo**: el repo es su material de estudio.
- **No podés ejecutar SQL**: no hay `psql` en la máquina. Todo experimento lo corre el usuario y te
  pasa el output. Si necesitás un dato de la base, pedile un `\d` o un `SELECT count(*)`.

## Git

- Rama `master`, remote en GitHub (`rochatomas-ing/Bases-de-datos-2`).
- Commits cortos e informales en español, tipo `Tp5 ejercicio 1 resuelto`. No hace falta
  conventional-commits ni detalle técnico.
- Commiteá sólo lo que el usuario haya pedido resolver; dejá el resto en el working tree.
