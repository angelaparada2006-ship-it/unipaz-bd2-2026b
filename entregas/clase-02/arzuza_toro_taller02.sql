-- Taller 2 - SELECT y NULL
-- Integrantes: Angela Arzuza y Miguel Toro
-- Fecha: 2026-08-05

-- # Punto 1 -- Los ejemplares que no estan prestados

SELECT id_ejemplar, codigo_barras, estado
FROM ejemplar
WHERE estado <> 'prestado'
   OR estado IS NULL;

SELECT COUNT(*) FROM ejemplar;
SELECT COUNT(*) FROM ejemplar WHERE estado = 'prestado';
SELECT COUNT(*) FROM ejemplar WHERE estado <> 'prestado';

-- Explicacion:
-- El total de ejemplares es 20.
-- La suma de las consultas con estado = 'prestado' y estado <> 'prestado'
-- no da 20 porque hay 2 ejemplares con estado NULL.
-- Los codigos de barras de esos ejemplares son BU-0019 y BU-0020.
-- El motor deja los NULL por fuera de estado <> 'prestado' porque NULL
-- no representa un valor conocido.
-- La consulta final incluye tambien los NULL con OR estado IS NULL.


-- # Punto 2 -- La ficha del autor

SELECT nombre || ' (' || nacionalidad || ')' AS ficha
FROM autor;

SELECT nombre || ' (' || COALESCE(nacionalidad, 'sin nacionalidad') || ')' AS ficha
FROM autor;

-- Explicacion:
-- El autor que se perdio fue Ricardo Socas Gutierrez porque su nacionalidad
-- tiene valor NULL.
-- En su lugar salio una fila NULL en la columna ficha.
-- Se perdio la ficha completa porque una concatenacion con NULL produce NULL.
-- COALESCE reemplaza el NULL por 'sin nacionalidad' y permite mostrar
-- los 10 autores.


-- # Punto 3 -- El listado de morosos de hoy

SELECT id_prestamo,
       fecha_devolucion_esperada,
       DATE '2026-08-05' - fecha_devolucion_esperada AS dias_retraso
FROM prestamo
WHERE fecha_devolucion_real IS NULL
  AND fecha_devolucion_esperada < DATE '2026-08-05';

-- Explicacion:
-- La consulta devuelve 2 prestamos.
-- El prestamo 14 tiene 2 dias de retraso.
-- El prestamo 18 tiene 7 dias de retraso.
-- Se usa IS NULL porque todavia no han sido devueltos.
-- Se usa < porque la fecha esperada debe haber pasado.
-- Un prestamo que vence exactamente el 5 de agosto no aparece porque
-- ese dia todavia no ha pasado.


-- # Punto 4 -- El alias que no existe

SELECT titulo,
       2026 - anio_publicacion AS antiguedad
FROM libro
WHERE 2026 - anio_publicacion > 10
ORDER BY antiguedad DESC;

-- Explicacion:
-- El WHERE se ejecuta antes que el SELECT, por eso el alias antiguedad
-- todavia no existe cuando el WHERE intenta usarlo.
-- El ORDER BY se ejecuta despues del SELECT y por eso si puede usar el alias.
-- La consulta se corrige repitiendo la expresion en el WHERE.
-- La consulta corregida devuelve 5 filas.
-- El libro con anio_publicacion NULL no aparece porque 2026 - NULL produce
-- NULL y la condicion del WHERE no resulta verdadera.


-- # Punto 5 -- El catalogo de la pagina web

SELECT titulo,
       anio_publicacion,
       COALESCE(editorial, 'Editorial no registrada') AS editorial
FROM libro
ORDER BY anio_publicacion DESC NULLS LAST;

-- Explicacion:
-- COALESCE reemplaza los valores NULL de editorial por
-- 'Editorial no registrada'.
-- DESC ordena los libros del mas nuevo al mas viejo.
-- NULLS LAST hace que los libros sin anio registrado aparezcan de ultimos.
-- Si no se controla el orden de NULL, los libros sin anio pueden aparecer
-- antes que las novedades al ordenar de forma descendente.
-- La consulta devuelve los 9 libros.


-- # Punto 6 -- La contradiccion de DISTINCT

SELECT DISTINCT estado FROM ejemplar;
SELECT COUNT(*) FROM ejemplar WHERE estado IS NULL;

-- Explicacion:
-- DISTINCT muestra 4 valores: NULL, deteriorado, disponible y prestado.
-- COUNT con IS NULL devuelve 2 porque hay 2 registros con estado NULL.
-- DISTINCT muestra NULL una sola vez aunque existan 2 registros con NULL.
-- Por eso los dos resultados cuentan cosas diferentes.


-- # Punto 7 -- El promedio del informe

SELECT COUNT(*) FROM prestamo;
SELECT COUNT(dias_mora) FROM prestamo;

SELECT AVG(dias_mora) AS promedio_dias_mora
FROM prestamo;

SELECT AVG(COALESCE(dias_mora, 0)) AS promedio_defendido
FROM prestamo;

-- Explicacion:
-- Hay 20 prestamos en total.
-- Solo 8 tienen dias_mora registrado y 12 tienen NULL.
-- AVG ignora los NULL, por eso 7.25 se calcula sobre 8 prestamos.
-- Esa cifra no esta bien si se presenta como promedio de toda la biblioteca,
-- porque no tuvo en cuenta todos los prestamos.
-- Yo defenderia el promedio usando COALESCE(dias_mora, 0), que da 2.90.
-- La decision es tomar dias_mora NULL como 0 cuando no hubo mora o no aplica.


-- # Punto 8 -- El carnet de no-estudiante

SELECT nombre, tipo
FROM usuario
WHERE tipo <> 'estudiante';

SELECT nombre, tipo
FROM usuario
WHERE tipo <> 'estudiante'
   OR tipo IS NULL;

SELECT nombre, tipo
FROM usuario
WHERE tipo IS DISTINCT FROM 'estudiante';

-- Explicacion:
-- La consulta original devuelve 3 personas.
-- Sandra Milena Avila queda por fuera porque su tipo es NULL.
-- Las dos consultas corregidas devuelven las mismas 4 personas.
-- IS DISTINCT FROM permite considerar NULL como distinto de 'estudiante'.
-- Para este ejercicio se incluye a Sandra Milena Avila porque no aparece
-- registrada como estudiante.
-- En un sistema real revisaria el dato antes de emitir el carnet, porque
-- NULL significa desconocido, no necesariamente no-estudiante.
