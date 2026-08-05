# Taller 2 — SELECT y NULL

**Base de Datos 2 · 910404 · Grupo D1 · 2026B**
Miércoles 5 de agosto de 2026 · Docente: Hermes A. Acevedo Castellanos
Instituto Universitario de la Paz — UNIPAZ · Escuela de Ciencias · Ingeniería Informática

---

## Cómo trabajar este taller

- **En parejas.** Sobre la base `biblioteca_unipaz` en PostgreSQL, con DBeaver.
- **Piso: puntos 1 a 6** — obligatorios, valen **4,0**.
- **Techo: puntos 7 y 8** — opcionales, suman hasta **1,0**.
- **Total posible: 5,0**

> **Sin inteligencia artificial.**
> La próxima clase se hacen **dos defensas orales al azar** de este taller: dos minutos, de pie, explicando
> su propia consulta. Quien no pueda explicarla pierde el punto — así que escriban lo que entiendan.

**Una consulta que devuelve el resultado correcto pero sin explicación vale la mitad.** Aquí se califica el
criterio, no la sintaxis.

---

## Qué se entrega

Un archivo `.sql` por pareja, llamado:

```
apellido1_apellido2_taller02.sql
```

Con esta forma por dentro:

```sql
-- Taller 2 — SELECT y NULL
-- Integrantes: Nombre Apellido1, Nombre Apellido2
-- Fecha: 2026-08-05

-- ============================================
-- Punto 1
-- ============================================

SELECT ...;

-- Explicación:
-- Aquí va el razonamiento. Sin esto el punto vale la mitad.
```

**Cada punto necesita dos cosas:** la consulta que corre sin error, y la explicación escrita en comentarios.
Los puntos que piden un número (cuántas filas devolvió cada consulta) van también en el comentario.

---

## Preparar la base

Si el motor ya está sembrado en la sala, salten este paso. Si trabajan en su propia máquina:

```bash
# 1. crear la base
psql -U postgres -c "CREATE DATABASE biblioteca_unipaz;"

# 2. cargar el esquema y los datos
psql -U postgres -d biblioteca_unipaz -f biblioteca-schema.sql
```

Desde **DBeaver**: clic derecho en la conexión → *SQL Editor* → *Open SQL script* → abrir
`biblioteca-schema.sql` → **Execute script** (`Alt+X`, no `Ctrl+Enter`).

Al terminar debe imprimir esta tabla de control:

| tabla | filas |
|---|---|
| autor | 10 |
| libro | 9 |
| libro_autor | 15 |
| ejemplar | 20 |
| usuario | 10 |
| prestamo | 20 |

Si algún número no coincide, la carga quedó incompleta: vuelvan a correr el script completo.

---

## El esquema

```
autor                    libro                      libro_autor
─────                    ─────                      ───────────
id_autor      PK         id_libro          PK       id_libro   FK → libro
nombre                   titulo                     id_autor   FK → autor
nacionalidad  (NULL)     anio_publicacion  (NULL)
                         editorial         (NULL)

ejemplar                 usuario                    prestamo
────────                 ───────                    ────────
id_ejemplar   PK         id_usuario  PK             id_prestamo                PK
id_libro      FK         nombre                     id_ejemplar                FK → ejemplar
codigo_barras            programa    (NULL)         id_usuario                 FK → usuario
estado        (NULL)     tipo        (NULL)         fecha_prestamo
                                                    fecha_devolucion_esperada
                                                    fecha_devolucion_real      (NULL)
                                                    dias_mora                  (NULL)
```

**`(NULL)` significa que esa columna puede venir vacía.** No lo ignoren: es de lo que trata el taller.

- Un **libro** es el título; un **ejemplar** es una copia física en el estante.
- `estado` de un ejemplar: `'disponible'`, `'prestado'`, `'deteriorado'` — o vacío.
- `fecha_devolucion_real` vacía significa que **ese préstamo todavía no se ha devuelto**.

---

# Piso — obligatorio

> 6 puntos · 4,0 en total

## Punto 1 — Los ejemplares que no están prestados · 0,7

El bibliotecario pide **la lista de los ejemplares que no están prestados**, para hacer inventario.
Escriban la consulta.

Después corran estas tres y anoten **cuántas filas devuelve cada una**:

```sql
SELECT COUNT(*) FROM ejemplar;
SELECT COUNT(*) FROM ejemplar WHERE estado =  'prestado';
SELECT COUNT(*) FROM ejemplar WHERE estado <> 'prestado';
```

Expliquen en un comentario:

- **¿La suma de las dos últimas da el total?**
- Si no, **¿qué ejemplares faltan?** Den los códigos de barras exactos.
- **¿Por qué el motor los dejó por fuera?**

Su consulta final tiene que entregarle al bibliotecario **todos** los ejemplares que no están prestados.

## Punto 2 — La ficha del autor · 0,7

La biblioteca quiere imprimir una ficha por autor con el formato `Nombre (nacionalidad)`.
Alguien escribió esto y **se le perdió un autor**:

```sql
SELECT nombre || ' (' || nacionalidad || ')' AS ficha FROM autor;
```

- **a)** ¿Qué autor se perdió y qué salió en su lugar?
- **b)** ¿Por qué se perdió **el nombre completo** y no solo la nacionalidad?
- **c)** Arréglenlo para que salgan los 10 autores.

## Punto 3 — El listado de morosos de hoy · 0,7

Saquen los préstamos que **todavía no se han devuelto** y cuya fecha esperada **ya pasó**.
Muestren `id_prestamo`, `fecha_devolucion_esperada` y **cuántos días de retraso** llevan.

Usen `DATE '2026-08-05'` como «hoy», para que el resultado sea el mismo para todas las parejas.

> **Ojo:** son dos condiciones, y una de ellas no se pregunta con `=`.

En un comentario, expliquen **por qué un préstamo que vence exactamente hoy no debería salir** en esta lista.

## Punto 4 — El alias que no existe · 0,7

Esta consulta **no corre**. Da `ERROR: column "antiguedad" does not exist`.

```sql
SELECT titulo,
       2026 - anio_publicacion AS antiguedad
FROM   libro
WHERE  antiguedad > 10
ORDER BY antiguedad DESC;
```

- **a)** ¿Por qué el `ORDER BY` **sí** puede usar `antiguedad` y el `WHERE` **no**?
  Respondan con el **orden de ejecución** de las cláusulas, no con «porque así es».
- **b)** Arréglenla.
- **c)** Hay un libro sin año de publicación. **¿Aparece en su versión corregida?**
  Digan si eso está bien o mal, **y por qué**.

## Punto 5 — El catálogo de la página web · 0,7

Armen el catálogo: **título, año y editorial de todos los libros**, del **más nuevo al más viejo**.

Requisitos:

- Los libros **sin año registrado** deben salir **de últimos**, no de primeros.
- Donde no haya editorial debe imprimirse `Editorial no registrada`.
- **Los 9 libros tienen que aparecer.**

En un comentario expliquen **qué pasa si no controlan el orden de los NULL** y por qué eso arruinaría
un «top de novedades».

## Punto 6 — La contradicción de DISTINCT · 0,5

Corran las dos y anoten los resultados:

```sql
SELECT DISTINCT estado FROM ejemplar;
SELECT COUNT(*) FROM ejemplar WHERE estado IS NULL;
```

Los dos números **no cuentan la misma historia**. Expliquen la contradicción:
¿por qué para `=` dos NULL son distintos, pero `DISTINCT` los mostró como uno solo?

> **No hay que justificar el estándar** — hay que describir con precisión qué hizo el motor.

---

# Techo — opcional, sube nota

> 2 puntos de criterio · hasta 1,0

## Punto 7 — El promedio del informe · 0,5

El coordinador de la biblioteca va a poner esta cifra en su informe al Consejo:
**«el promedio de días de mora de la biblioteca es 7,25»**. La sacó así:

```sql
SELECT AVG(dias_mora) FROM prestamo;
```

- **a)** Corran `COUNT(*)` y `COUNT(dias_mora)` sobre `prestamo`. Muestren los dos números.
- **b)** Expliquen **sobre cuántos préstamos se calculó realmente** ese 7,25, y por qué la cifra del
  informe está mal.
- **c)** Calculen la cifra que **ustedes** defenderían, y **justifíquenla**: ¿qué decidieron que significa
  `dias_mora IS NULL`?

> **Aquí no hay una sola respuesta correcta.** Hay respuestas justificadas y respuestas sin justificar.
> Lo que se califica es la decisión, no el número.

## Punto 8 — El carnet de no-estudiante · 0,5

Recursos Humanos pide **todos los usuarios que no son estudiantes** para un carnet distinto.
Escribieron esto y **faltó gente**:

```sql
SELECT nombre, tipo FROM usuario WHERE tipo <> 'estudiante';
```

- **a)** ¿Quién quedó por fuera y por qué?
- **b)** Arréglenlo de **dos formas distintas**: una usando `OR ... IS NULL` y otra usando
  `IS DISTINCT FROM`. Verifiquen que las dos dan lo mismo.
- **c)** ¿Cuál de las dos entregarían en un sistema real, y por qué?
- **d)** **La pregunta de fondo:** esa persona tiene `tipo` en NULL. ¿Debería recibir el carnet de
  no-estudiante? Argumenten.

> **Este punto no se resuelve con SQL, se resuelve decidiendo** — y después escribiendo el SQL que
> refleja la decisión.

---

## Antes de entregar

- [ ] Los 6 puntos del piso están numerados en comentarios.
- [ ] Cada consulta corre sin error.
- [ ] Cada punto trae su explicación escrita.
- [ ] Los nombres de los dos integrantes están en la primera línea del archivo.
- [ ] El archivo se llama `apellido1_apellido2_taller02.sql`.

---

## Lo que se califica

| Punto | Tema | Valor |
|---|---|---|
| 1 | Los ejemplares que no están prestados | 0,7 |
| 2 | La ficha del autor | 0,7 |
| 3 | El listado de morosos | 0,7 |
| 4 | El alias que no existe | 0,7 |
| 5 | El catálogo de la página web | 0,7 |
| 6 | La contradicción de DISTINCT | 0,5 |
| | **Subtotal piso** | **4,0** |
| 7 | El promedio del informe | 0,5 |
| 8 | El carnet de no-estudiante | 0,5 |
| | **Total posible** | **5,0** |
