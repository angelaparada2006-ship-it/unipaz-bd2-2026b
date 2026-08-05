-- =====================================================================
--  BIBLIOTECA UNIPAZ — esquema y datos sembrados
--  Base de Datos 2 (910404) · D1 · 2026B · Hermes A. Acevedo Castellanos
--  Motor: PostgreSQL 16
--
--  CÓMO CARGARLO (en DBeaver o psql):
--    psql -U postgres -c "CREATE DATABASE biblioteca_unipaz;"
--    psql -U postgres -d biblioteca_unipaz -f biblioteca-schema.sql
--
--  Es idempotente: se puede volver a correr y reconstruye todo desde cero.
--
--  ⚠️  NOTA PARA EL DOCENTE — LOS NULL ESTÁN SEMBRADOS A PROPÓSITO.
--      No son datos sucios por descuido: son las trampas de la clase 2.
--      Ver el bloque "MAPA DE TRAMPAS" al final del archivo.
-- =====================================================================

DROP TABLE IF EXISTS prestamo     CASCADE;
DROP TABLE IF EXISTS libro_autor  CASCADE;
DROP TABLE IF EXISTS ejemplar     CASCADE;
DROP TABLE IF EXISTS usuario      CASCADE;
DROP TABLE IF EXISTS libro        CASCADE;
DROP TABLE IF EXISTS autor        CASCADE;

-- ---------------------------------------------------------------------
-- 1. ESTRUCTURA
--    Deliberadamente mínima: sin CHECK, sin NOT NULL de más, sin
--    restricciones sofisticadas. Todo eso llega en el CORTE 2 (clase 7),
--    y llega porque en el corte 1 ya sufrieron su ausencia.
-- ---------------------------------------------------------------------

CREATE TABLE autor (
    id_autor      SERIAL PRIMARY KEY,
    nombre        TEXT NOT NULL,
    nacionalidad  TEXT              -- admite NULL: hay autores sin dato
);

CREATE TABLE libro (
    id_libro          SERIAL PRIMARY KEY,
    titulo            TEXT NOT NULL,
    anio_publicacion  INTEGER,      -- admite NULL: hay libros sin año en la ficha
    editorial         TEXT          -- admite NULL
);

CREATE TABLE libro_autor (
    id_libro  INTEGER REFERENCES libro(id_libro),
    id_autor  INTEGER REFERENCES autor(id_autor),
    PRIMARY KEY (id_libro, id_autor)
);

CREATE TABLE ejemplar (
    id_ejemplar    SERIAL PRIMARY KEY,
    id_libro       INTEGER REFERENCES libro(id_libro),
    codigo_barras  TEXT,
    estado         TEXT          -- 'disponible' | 'prestado' | 'deteriorado' | NULL
);

CREATE TABLE usuario (
    id_usuario  SERIAL PRIMARY KEY,
    nombre      TEXT NOT NULL,
    programa    TEXT,             -- admite NULL: personal administrativo sin programa
    tipo        TEXT              -- 'estudiante' | 'docente'
);

CREATE TABLE prestamo (
    id_prestamo                SERIAL PRIMARY KEY,
    id_ejemplar                INTEGER REFERENCES ejemplar(id_ejemplar),
    id_usuario                 INTEGER REFERENCES usuario(id_usuario),
    fecha_prestamo             DATE,
    fecha_devolucion_esperada  DATE,
    fecha_devolucion_real      DATE,     -- NULL = todavía no lo devuelve
    dias_mora                  INTEGER   -- NULL = no aplica / sin calcular
);

-- ---------------------------------------------------------------------
-- 2. AUTORES
--    Reales, tomados de la bibliografía de la asignatura.
--    El autor 8 no tiene nacionalidad registrada (trampa de COALESCE).
-- ---------------------------------------------------------------------

INSERT INTO autor (nombre, nacionalidad) VALUES
    ('Adoración de Miguel Castaño',   'España'),      -- 1
    ('Paloma Martínez Fernández',     'España'),      -- 2
    ('Elena Castro Galán',            'España'),      -- 3
    ('Iván López Montalbán',          'España'),      -- 4
    ('María José Castellano Pérez',   'España'),      -- 5
    ('Jaime Ospino Rivas',            'Colombia'),    -- 6
    ('Eduardo Jorge Reinosa',         'Argentina'),   -- 7
    ('Ricardo Socas Gutiérrez',        NULL),         -- 8  ← sin nacionalidad
    ('Calixto Alejandro Maldonado',   'Argentina'),   -- 9
    ('Manuel de Castro Vázquez',      'España');      -- 10

-- ---------------------------------------------------------------------
-- 3. LIBROS
--    Los seis primeros existen de verdad en la Biblioteca UNIPAZ
--    (ver Bibliografia/Bibliografía.md). Los tres últimos son de relleno
--    controlado para que existan los casos borde.
-- ---------------------------------------------------------------------

INSERT INTO libro (titulo, anio_publicacion, editorial) VALUES
    ('Diseño de bases de datos: problemas resueltos',                              2001, 'Alfaomega Ra-Ma'),        -- 1
    ('Bases de datos: desarrollo de aplicaciones multiplataforma y web',            2013, 'Alfaomega-Garceta'),      -- 2
    ('Bases de datos',                                                              2012, 'Alfaomega Grupo Editor'), -- 3
    ('Gestión de bases de datos',                                                   2014, 'Garceta'),                -- 4
    ('Administración de sistemas gestores de bases de datos',                       2015, 'Garceta'),                -- 5
    ('Bases de datos: teoría y práctica aplicada a la ingeniería del software',     2025, 'Alpha Editorial'),        -- 6
    ('Introducción a los sistemas NoSQL',                                           NULL, 'Ra-Ma'),                  -- 7  ← año NULL
    ('SQL práctico para desarrolladores',                                           2019, NULL),                     -- 8  ← editorial NULL, y SIN ejemplares
    ('Modelado de datos con UML',                                                   2018, 'Alfaomega');              -- 9  ← SIN ejemplares

-- ---------------------------------------------------------------------
-- 4. LIBRO_AUTOR (N:M)
--    Varios libros tienen TRES autores. Eso infla cualquier COUNT(*) hecho
--    sobre el JOIN — es el punto 9 del diagnóstico y la base de la clase 4.
--    Los libros 8 y 9 quedan SIN autor registrado a propósito.
-- ---------------------------------------------------------------------

INSERT INTO libro_autor (id_libro, id_autor) VALUES
    (1,1),(1,2),(1,3),                 -- Diseño de BD: 3 autores
    (2,4),(2,5),(2,6),                 -- DAM y DAW: 3 autores
    (3,7),(3,9),                       -- Bases de datos: 2 autores
    (4,4),(4,10),                      -- Gestión de BD: 2 autores
    (5,4),(5,6),(5,5),                 -- Administración SGBD: 3 autores
    (6,8),                             -- Texto guía: 1 autor
    (7,8);                             -- NoSQL: 1 autor
    -- libros 8 y 9: sin autor registrado

-- ---------------------------------------------------------------------
-- 5. EJEMPLARES
--    Un libro = N copias físicas. Es el corazón del caso.
--
--    ⚠️  TRAMPA CENTRAL DE LA CLASE: los ejemplares 19 y 20 tienen
--        estado NULL (llegaron por donación y nadie los catalogó).
--        Por eso  WHERE estado <> 'prestado'  los PIERDE en silencio.
-- ---------------------------------------------------------------------

INSERT INTO ejemplar (id_libro, codigo_barras, estado) VALUES
    (1, 'BU-0001', 'disponible'),
    (1, 'BU-0002', 'prestado'),
    (1, 'BU-0003', 'prestado'),
    (1, 'BU-0004', 'deteriorado'),
    (2, 'BU-0005', 'disponible'),
    (2, 'BU-0006', 'prestado'),
    (2, 'BU-0007', 'disponible'),
    (3, 'BU-0008', 'prestado'),
    (3, 'BU-0009', 'disponible'),
    (4, 'BU-0010', 'disponible'),
    (4, 'BU-0011', 'prestado'),
    (4, 'BU-0012', 'deteriorado'),
    (5, 'BU-0013', 'disponible'),
    (5, 'BU-0014', 'prestado'),
    (6, 'BU-0015', 'disponible'),
    (6, 'BU-0016', 'prestado'),
    (6, 'BU-0017', 'disponible'),
    (7, 'BU-0018', 'disponible'),
    (7, 'BU-0019',  NULL),          -- 19 ← sin catalogar
    (3, 'BU-0020',  NULL);          -- 20 ← sin catalogar
    -- libros 8 y 9: SIN ningún ejemplar

-- ---------------------------------------------------------------------
-- 6. USUARIOS
--    El usuario 9 no tiene programa (es administrativo) → NULL.
--    El usuario 10 no tiene tipo registrado → NULL.
-- ---------------------------------------------------------------------

INSERT INTO usuario (nombre, programa, tipo) VALUES
    ('Laura Cristina Ortiz',    'Ingeniería Informática',   'estudiante'),  -- 1
    ('Andrés Felipe Guzmán',    'Ingeniería Informática',   'estudiante'),  -- 2
    ('Deidree Cárdenas',        'Ingeniería Informática',   'estudiante'),  -- 3
    ('Juan Sebastián Porras',   'Ingeniería Informática',   'estudiante'),  -- 4
    ('Mónica Alejandra Ruiz',   'Ingeniería Agronómica',    'estudiante'),  -- 5
    ('Carlos Eduardo Vega',     'Ingeniería Ambiental',     'estudiante'),  -- 6
    ('Hermes Acevedo',          'Ingeniería Informática',   'docente'),     -- 7
    ('Gloria Patricia Méndez',  'Ingeniería Agronómica',    'docente'),     -- 8
    ('Wilson Rodríguez',         NULL,                      'docente'),     -- 9  ← sin programa
    ('Sandra Milena Ávila',     'Ingeniería Informática',    NULL);         -- 10 ← sin tipo

-- ---------------------------------------------------------------------
-- 7. PRÉSTAMOS
--    Fecha de referencia de la clase: 5 de agosto de 2026.
--
--    ⚠️  DOS SEMÁNTICAS DISTINTAS DE NULL CONVIVEN AQUÍ, Y ESO ES EL PUNTO:
--        fecha_devolucion_real IS NULL  → "todavía no lo devuelve"
--        dias_mora IS NULL              → "no aplica" (no hubo mora)
--        dias_mora = 0                  → "devolvió justo el día"
--
--        Por eso AVG(dias_mora) miente: ignora los NULL y calcula el
--        promedio SOLO sobre los que llegaron tarde. Punto 10 del diagnóstico.
-- ---------------------------------------------------------------------

INSERT INTO prestamo (id_ejemplar, id_usuario, fecha_prestamo, fecha_devolucion_esperada, fecha_devolucion_real, dias_mora) VALUES
    -- devueltos a tiempo (sin mora → dias_mora NULL)
    ( 1,  1, '2026-06-02', '2026-06-16', '2026-06-14', NULL),
    ( 5,  2, '2026-06-03', '2026-06-17', '2026-06-17',    0),   -- justo el día: mora 0, NO NULL
    ( 9,  3, '2026-06-10', '2026-06-24', '2026-06-20', NULL),
    (13,  1, '2026-06-15', '2026-06-29', '2026-06-28', NULL),
    (15,  4, '2026-06-18', '2026-07-02', '2026-07-02',    0),
    (17,  5, '2026-06-22', '2026-07-06', '2026-07-01', NULL),
    ( 7,  1, '2026-07-01', '2026-07-15', '2026-07-13', NULL),
    (10,  2, '2026-07-02', '2026-07-16', '2026-07-16',    0),

    -- devueltos TARDE (mora real)
    ( 4,  6, '2026-05-20', '2026-06-03', '2026-06-15',   12),
    (12,  5, '2026-06-05', '2026-06-19', '2026-07-01',   12),
    (18,  3, '2026-06-08', '2026-06-22', '2026-07-10',   18),
    ( 1,  4, '2026-06-25', '2026-07-09', '2026-07-14',    5),
    ( 9,  6, '2026-07-05', '2026-07-19', '2026-07-30',   11),

    -- NO devueltos todavía (fecha_devolucion_real NULL) — algunos ya vencidos
    ( 2,  1, '2026-07-20', '2026-08-03', NULL, NULL),   -- vencido hace 2 días
    ( 3,  2, '2026-07-22', '2026-08-05', NULL, NULL),   -- vence hoy
    ( 6,  7, '2026-07-25', '2026-08-08', NULL, NULL),
    ( 8,  4, '2026-07-28', '2026-08-11', NULL, NULL),
    (11,  8, '2026-07-15', '2026-07-29', NULL, NULL),   -- vencido hace 7 días
    (14,  1, '2026-07-30', '2026-08-13', NULL, NULL),
    (16,  9, '2026-08-01', '2026-08-15', NULL, NULL);
    -- usuario 10 (Sandra Milena Ávila): NUNCA ha pedido prestado nada

-- ---------------------------------------------------------------------
-- 8. VERIFICACIÓN RÁPIDA
-- ---------------------------------------------------------------------

SELECT 'autor'       AS tabla, COUNT(*) AS filas FROM autor
UNION ALL SELECT 'libro',       COUNT(*) FROM libro
UNION ALL SELECT 'libro_autor', COUNT(*) FROM libro_autor
UNION ALL SELECT 'ejemplar',    COUNT(*) FROM ejemplar
UNION ALL SELECT 'usuario',     COUNT(*) FROM usuario
UNION ALL SELECT 'prestamo',    COUNT(*) FROM prestamo;

-- Esperado: autor 10 · libro 9 · libro_autor 15 · ejemplar 20 · usuario 10 · prestamo 20


-- =====================================================================
--  MAPA DE TRAMPAS — SOLO PARA EL DOCENTE
--  Qué hay sembrado, dónde, y qué consulta lo revienta.
-- =====================================================================
--
--  ┌── TRAMPA 1 · El <> que pierde filas en silencio ────────────────┐
--  │ Sembrado en: ejemplar 19 y 20 (estado NULL).                    │
--  │ Revienta con:                                                   │
--  │     SELECT COUNT(*) FROM ejemplar;                    -- 20     │
--  │     SELECT COUNT(*) FROM ejemplar WHERE estado='prestado';  -- 7 │
--  │     SELECT COUNT(*) FROM ejemplar WHERE estado<>'prestado'; -- 11│
--  │ 7 + 11 = 18, no 20. Se perdieron dos ejemplares.                │
--  │ Arreglo: WHERE estado <> 'prestado' OR estado IS NULL           │
--  │          (o  WHERE estado IS DISTINCT FROM 'prestado')          │
--  └─────────────────────────────────────────────────────────────────┘
--
--  ┌── TRAMPA 2 · = NULL nunca es verdad ────────────────────────────┐
--  │ Sembrado en: 7 préstamos sin devolver.                          │
--  │     WHERE fecha_devolucion_real = NULL     -- 0 filas (miente)  │
--  │     WHERE fecha_devolucion_real IS NULL    -- 7 filas (correcto)│
--  └─────────────────────────────────────────────────────────────────┘
--
--  ┌── TRAMPA 3 · AVG ignora los NULL ───────────────────────────────┐
--  │ Sembrado en: dias_mora con tres significados distintos.         │
--  │     AVG(dias_mora)              -- 7,25 sobre 8 filas           │
--  │     COUNT(*)                    -- 20                            │
--  │     COUNT(dias_mora)            -- 8                             │
--  │ El promedio "de la biblioteca" resulta ser el promedio de los    │
--  │ morosos, no de los préstamos. Punto 10 del diagnóstico.          │
--  │ Arreglo honesto: COALESCE(dias_mora,0) — pero solo si se decide  │
--  │ que NULL significa "no hubo mora". Es una decisión de negocio,   │
--  │ no de sintaxis. Ese es el aprendizaje.                           │
--  └─────────────────────────────────────────────────────────────────┘
--
--  ┌── TRAMPA 4 · Concatenar con NULL aniquila la cadena ────────────┐
--  │ Sembrado en: autor 8 (Socas Gutiérrez, nacionalidad NULL).      │
--  │     SELECT nombre || ' (' || nacionalidad || ')' FROM autor;    │
--  │ Esa fila sale NULL COMPLETO, no "Socas Gutiérrez ()".           │
--  │ Arreglo: COALESCE(nacionalidad,'sin dato')                       │
--  └─────────────────────────────────────────────────────────────────┘
--
--  ┌── TRAMPA 5 · La incoherencia de DISTINCT ───────────────────────┐
--  │ Para = , dos NULL NO son iguales. Para DISTINCT y GROUP BY, SÍ  │
--  │ se agrupan juntos. Es una inconsistencia real del estándar.     │
--  │     SELECT DISTINCT estado FROM ejemplar;                       │
--  │ Devuelve 4 filas: disponible, prestado, deteriorado y UNA sola  │
--  │ fila NULL — aunque hay dos ejemplares sin catalogar.            │
--  └─────────────────────────────────────────────────────────────────┘
--
--  ┌── TRAMPA 6 · ORDER BY pone los NULL de último ──────────────────┐
--  │ Sembrado en: libro 7 (año NULL).                                │
--  │     ORDER BY anio_publicacion         -- NULL al final          │
--  │     ORDER BY anio_publicacion DESC    -- NULL al PRINCIPIO      │
--  │ En PostgreSQL el NULL cuenta como el valor más grande.          │
--  │ Se controla con NULLS FIRST / NULLS LAST.                        │
--  └─────────────────────────────────────────────────────────────────┘
--
--  ┌── SEMBRADO PARA CLASES POSTERIORES (no tocar hoy) ──────────────┐
--  │ Clase 3 (JOIN):   libros 8 y 9 sin ejemplares y sin autores.    │
--  │                   Usuario 10 sin ningún préstamo.               │
--  │ Clase 4 (GROUP):  libro 1 con 3 autores infla COUNT(*).         │
--  │ Clase 8 (concurr): ejemplar 3 vence HOY → pelea por el último.  │
--  └─────────────────────────────────────────────────────────────────┘
-- =====================================================================
