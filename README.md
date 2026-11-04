<h1 align="center">🗄️ Base de Datos 2</h1>

<p align="center">
  <strong>Instituto Universitario de la Paz — UNIPAZ</strong><br>
  Escuela de Ciencias · Ingeniería Informática<br>
  Código <strong>910404</strong> · Grupo <strong>D1</strong> · Semestre <strong>2026B</strong>
</p>

<p align="center">
  <img alt="PostgreSQL 16" src="https://img.shields.io/badge/PostgreSQL-16-336791?style=for-the-badge&logo=postgresql&logoColor=white">
  <img alt="DBeaver" src="https://img.shields.io/badge/DBeaver-Community-382923?style=for-the-badge&logo=dbeaver&logoColor=white">
  <img alt="Clases" src="https://img.shields.io/badge/clases-14-2ea44f?style=for-the-badge">
  <img alt="Caso" src="https://img.shields.io/badge/caso-Biblioteca%20UNIPAZ-8a2be2?style=for-the-badge">
</p>

---

## 📌 Qué es este repositorio

Este es el repositorio de **todo el semestre**. Aquí vive el material de cada clase, el esquema de la base
de datos con la que vamos a trabajar desde agosto hasta noviembre, y los talleres.

**Un solo caso todo el semestre: el sistema de préstamos de la Biblioteca de UNIPAZ.**

No cambiamos de tema cada semana a propósito. Explicar un enunciado nuevo cada clase se come media
sesión — y ese tiempo lo queremos en el motor, escribiendo consultas. La biblioteca parece un caso
sencillo y no lo es: un libro no es una copia, un préstamo se renueva, una reserva hace cola, la mora
sanciona, y un libro puede tener tres autores. El modelo ingenuo se rompe solo, y ustedes lo van a ver
romperse.

> 📚 Los libros que están sembrados en la base **existen de verdad** en esa biblioteca. Son los mismos que
> van a tener que ir a consultar.

---

## 🗂️ Cómo está organizado

### Proyecto adicional — Backend CRUD

La aplicación de directorio construida con Supabase vive en [`proyectos/backend-crud/`](proyectos/backend-crud/README.md). Incluye el frontend adaptable a móvil, SQL para `public.usuarios`, autenticación, fotos privadas y políticas RLS para administradores.

### La rama `main` — el material acumulado

```
unipaz-bd2-2026b/
├── README.md              ← este archivo
├── db/
│   └── biblioteca-schema.sql    ← el esquema + los datos. Fuente única de verdad.
└── clases/
    ├── clase-02-select/
    │   ├── TALLER-02-SELECT.md
    │   └── ...
    └── clase-03-join/
        └── ...
```

`main` **siempre tiene todo lo visto hasta hoy.** Es la rama a la que hay que volver cuando no sepan
dónde buscar algo.

### Las ramas `clase-NN` — puntos de control

Cada clase deja una rama con el estado **exacto** de la base al terminar esa sesión:

| Rama | Qué contiene |
|---|---|
| `clase-02` | La base como quedó al final de la clase 2 |
| `clase-03` | La base como quedó al final de la clase 3 |
| … | … |

**¿Para qué sirve esto?** Este curso es acumulativo: la base de la clase 8 es la de la clase 7 con más
cosas encima. Si faltaron a una clase, o si rompieron su base y no saben dónde, **no tienen que empezar
de cero ni pedirle el archivo a un compañero**. Se paran en el checkpoint correcto y siguen:

```bash
git checkout clase-03
```

Y para volver a lo último:

```bash
git checkout main
```

---

## 🚀 Empezar (una sola vez en el semestre)

### 1. Hacer un fork

Botón **Fork** arriba a la derecha en esta página. Eso crea **tu propia copia** del repositorio en tu
cuenta de GitHub, donde sí puedes escribir.

> 👥 **El fork es por pareja, no por persona.** Los talleres se entregan en parejas, así que uno de los
> dos hace el fork y agrega al otro como colaborador (*Settings → Collaborators* en el fork).

### 2. Clonar tu fork a tu computador

Reemplaza `TU-USUARIO` por tu usuario de GitHub:

```bash
git clone https://github.com/TU-USUARIO/unipaz-bd2-2026b.git
cd unipaz-bd2-2026b
```

### 3. Conectar tu fork con el repositorio del curso

⚠️ **Este paso es el que casi nadie hace y el que después duele.** Sin él, tu fork se queda congelado en
el día que lo creaste y no vas a ver el material de las clases siguientes.

```bash
git remote add upstream https://github.com/sha2cs/unipaz-bd2-2026b.git
git remote -v     # debe listar 'origin' (tu fork) y 'upstream' (el del curso)
```

- **`origin`** = tu copia. Aquí subes tus entregas.
- **`upstream`** = el repositorio del curso. De aquí bajas el material nuevo. No puedes escribir en él.

### 4. Montar la base de datos

```bash
# crear la base
psql -U postgres -c "CREATE DATABASE biblioteca_unipaz;"

# cargar el esquema y los datos
psql -U postgres -d biblioteca_unipaz -f db/biblioteca-schema.sql
```

Desde **DBeaver**: clic derecho en la conexión → *SQL Editor* → *Open SQL script* → abrir
`db/biblioteca-schema.sql` → **Execute script** con `Alt+X` (⚠️ **no** `Ctrl+Enter`, que solo ejecuta una
sentencia).

Al terminar debe imprimir esta tabla de control:

| tabla | filas |
|---|---|
| autor | 10 |
| libro | 9 |
| libro_autor | 15 |
| ejemplar | 20 |
| usuario | 10 |
| prestamo | 20 |

**Si algún número no coincide, la carga quedó incompleta.** Vuelvan a correr el script completo — está
escrito para poder ejecutarse muchas veces sin dañar nada.

---

## 🔄 Antes de cada clase: bajar el material nuevo

Esto se hace **cada semana**. Son tres líneas:

```bash
git checkout main
git fetch upstream
git merge upstream/main
```

Si además quieren una rama de checkpoint que salió después de su fork:

```bash
git fetch upstream
git checkout -b clase-05 upstream/clase-05
```

> 💡 **Desde el navegador también se puede:** en tu fork aparece un botón **Sync fork** cuando `main`
> está atrasada. Sirve para `main`, pero **no trae las ramas nuevas** — para eso sí toca la terminal.

---

## 📤 Cómo se entregan los talleres

Las entregas se hacen por **Pull Request**. Cinco pasos:

### 1. Actualizar y crear la rama de la entrega

```bash
git checkout main
git fetch upstream && git merge upstream/main
git checkout -b entrega/clase-02/perez-gomez
```

Nombre de la rama: `entrega/clase-NN/apellido1-apellido2`, en minúscula y sin tildes.

### 2. Poner el archivo en su lugar

```
entregas/clase-02/perez_gomez_taller02.sql
```

El nombre del archivo y su contenido interno los define **cada taller** — está escrito en el `.md` del
taller, en la sección *«Qué se entrega»*. Léanla, porque ahí también dice qué se califica.

### 3. Confirmar y subir

```bash
git add entregas/clase-02/perez_gomez_taller02.sql
git commit -m "Entrega taller 02 - Perez, Gomez"
git push origin entrega/clase-02/perez-gomez
```

### 4. Abrir el Pull Request

GitHub muestra un botón **Compare & pull request** después del push. Al abrirlo, verifica que va
**de tu rama** hacia **`sha2cs/unipaz-bd2-2026b` rama `main`**.

**Título del PR, exactamente con esta forma:**

```
[Clase 02] Pérez - Gómez
```

**En la descripción del PR:**

```markdown
- Integrantes: Nombre Pérez, Nombre Gómez
- Puntos del piso resueltos: 1, 2, 3, 4, 5, 6
- Puntos del techo intentados: 7
- Dudas o cosas que no logramos: ...
```

Esa última línea **no baja nota**. Decir con precisión dónde se quedaron vale más que entregar algo que
no pueden defender.

### 5. Listo

La retroalimentación llega **como comentarios en el PR**.

> ℹ️ **Tu Pull Request se va a cerrar sin fusionarse, y eso es lo normal.** El PR es el sobre en el que
> entregas, no un aporte al material del curso. Cerrado ≠ rechazado: la nota y los comentarios quedan
> ahí, y el PR sigue siendo el registro permanente de tu entrega.

---

## ⚖️ Reglas del curso

| Regla | Detalle |
|---|---|
| 🚫 **Sin inteligencia artificial** | En los talleres. La razón está más abajo. |
| 🗣️ **Defensa oral, 2 al azar por clase** | Dos minutos, de pie, explicando **tu propia** consulta. Quien no pueda explicarla pierde el punto. |
| 📝 **Sin explicación vale la mitad** | Una consulta que devuelve el resultado correcto, sin explicación escrita, vale la mitad. Aquí se califica el criterio, no la sintaxis. |
| 🪜 **Piso y techo** | El **piso** es obligatorio y vale 4,0 — está calibrado para que se pueda. El **techo** es opcional y suma hasta 1,0. Total 5,0. |
| 📖 **Cuaderno de biblioteca** | Una pregunta por corte cuya respuesta **solo está en los libros físicos**. A mano, citando la página. Se entrega el día del parcial. Tres en el semestre. |

### Por qué no se usa IA en los talleres

No es desconfianza y no es nostalgia. Es que los talleres de este curso **no están escritos para que la IA
falle** — están escritos para que responderlos **sin entender no sirva de nada**.

Casi ningún punto pide «escribe una consulta que liste X». Piden otra cosa: *esta consulta devuelve un
resultado incorrecto, encuentra por qué* · *estas tres dan lo mismo, decide cuál es mejor y sostenlo* ·
*el informe dice 7,25 y el dato real es otro, explica de dónde salió la diferencia*.

Ahí no hay una respuesta que copiar: hay una **decisión** que tomar y defender. Y a los dos minutos de la
defensa oral, la diferencia entre quien decidió y quien pegó se ve completa.

---

## 🗓️ El semestre

**Miércoles, 1:00 – 5:00 pm.** Cada sesión tiene la misma forma — la repetición es deliberada:

| Hora | Bloque |
|---|---|
| 1:00 – 1:15 | Revisión del taller anterior · 2 defensas orales al azar |
| 1:15 – 2:45 | Explicación |
| 2:45 – 3:00 | Descanso |
| 3:00 – 4:30 | Taller práctico |
| 4:30 – 5:00 | Cierre y calificación |

### Corte 1 — SQL de verdad

> Al terminar el corte, consultan bien. Es el hueco más grande que trae todo el mundo de BD1.

| # | Fecha | Tema |
|---|---|---|
| 1 | mié 29-jul | Arranque, el caso Biblioteca y diagnóstico |
| 2 | mié 5-ago | **SELECT** — filtrado, orden, expresiones, alias, `DISTINCT` y **NULL** |
| 3 | mié 12-ago | **JOIN** — `INNER`, `LEFT`, `RIGHT`, `FULL`, `CROSS`, self-join |
| 4 | mié 19-ago | **Agregación** — `GROUP BY`, `HAVING` vs `WHERE`, los NULL en cada agregado |
| 5 | mié 26-ago | **Subconsultas y conjuntos** — `EXISTS` vs `IN`, `UNION`, `INTERSECT`, `EXCEPT` |
| 6 | mié 2-sep | **Vistas y CTE** — `WITH`, la legibilidad como criterio profesional |
| 📝 | mié 9-sep | **PARCIAL 1** + cuaderno de biblioteca #1 |

### Corte 2 — La base piensa

> Aquí BD2 se separa de BD1: la lógica deja de vivir solo en la aplicación.

| # | Fecha | Tema |
|---|---|---|
| 7 | mié 16-sep | **Integridad y restricciones** — `FOREIGN KEY`, `CHECK`, `DOMAIN` |
| 8 | mié 23-sep | **Transacciones y concurrencia** — ACID, `ROLLBACK`, niveles de aislamiento |
| 9 | mié 30-sep | **Funciones y procedimientos** — PL/pgSQL, y cuándo **no** poner lógica en la base |
| 10 | mié 7-oct | **Triggers y auditoría** — y el peligro real de las cascadas |
| 📝 | mié 14-oct | **PARCIAL 2** + cuaderno de biblioteca #2 |

### Corte 3 — La base en producción

> Deja de ser un ejercicio. Es lo que separa a quien escribe SQL de quien sostiene un sistema.

| # | Fecha | Tema |
|---|---|---|
| 11 | mié 21-oct | **Índices y plan de ejecución** — `EXPLAIN ANALYZE`, y cuándo un índice estorba |
| 12 | mié 28-oct | **Normalización aplicada** — como consecuencia de lo que ya sufrieron, no como teoría |
| 13 | mié 4-nov | **Seguridad** — roles, `GRANT`/`REVOKE`, **inyección SQL** |
| 14 | mié 11-nov | **Respaldo y recuperación** — `pg_dump`, `pg_restore`, punto de recuperación |
| 🎓 | mié 18-nov | **EXAMEN FINAL** + sustentación + cuaderno #3 |

---

## 🧩 El esquema de la Biblioteca

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

**`(NULL)` significa que esa columna puede venir vacía.** No lo ignoren: buena parte del curso trata
justamente de eso.

- Un **libro** es el título. Un **ejemplar** es una copia física en el estante. No son lo mismo, y esa
  distinción es la primera cosa que rompe el modelo ingenuo.
- `estado` de un ejemplar: `'disponible'`, `'prestado'`, `'deteriorado'` — o vacío.
- `fecha_devolucion_real` vacía significa que **ese préstamo todavía no se ha devuelto**.

---

## 🩹 Cuando algo se rompe

<details>
<summary><strong>«Mi fork no tiene el material de la clase de hoy»</strong></summary>

Falta traer los cambios del curso:

```bash
git checkout main
git fetch upstream
git merge upstream/main
```

Si `git remote -v` no lista `upstream`, se saltaron el paso 3 del arranque. Vuelvan a él.
</details>

<details>
<summary><strong>«No veo la rama <code>clase-05</code>»</strong></summary>

Las ramas creadas **después** de tu fork no aparecen solas:

```bash
git fetch upstream
git checkout -b clase-05 upstream/clase-05
```
</details>

<details>
<summary><strong>«<code>git push</code> me da <em>Permission denied</em> o <em>403</em>»</strong></summary>

Están empujando al repositorio del curso, no al suyo. Verifiquen:

```bash
git remote -v
```

`origin` debe apuntar a **tu usuario**. Si apunta a `sha2cs`, corríjanlo:

```bash
git remote set-url origin https://github.com/TU-USUARIO/unipaz-bd2-2026b.git
```
</details>

<details>
<summary><strong>«La tabla de control no da los números correctos»</strong></summary>

La carga quedó a medias — casi siempre por ejecutar con `Ctrl+Enter` (una sola sentencia) en vez de
`Alt+X` (todo el script). Vuelvan a correr `db/biblioteca-schema.sql` completo; está escrito para poder
ejecutarse muchas veces sin dañar nada.
</details>

<details>
<summary><strong>«Rompí mi base y no sé dónde»</strong></summary>

Para eso están los checkpoints. Recárguenla desde el estado de la clase que necesiten:

```bash
git checkout clase-03
psql -U postgres -d biblioteca_unipaz -f db/biblioteca-schema.sql
```
</details>

<details>
<summary><strong>«Mi Pull Request aparece cerrado»</strong></summary>

Es lo esperado: los PR de entrega se revisan y se cierran sin fusionar. Cerrado no es rechazado — la nota
y los comentarios están en el PR, y ese PR es el registro de tu entrega.
</details>

---

## 📖 Bibliografía

Los libros del curso están **en la biblioteca de UNIPAZ**, catalogados y disponibles. El *cuaderno de
biblioteca* existe por una razón concreta: hay respuestas que no están en internet, y saber encontrarlas
en un libro es parte del oficio.

---

<p align="center">
  <strong>Docente:</strong> Hermes A. Acevedo Castellanos<br>
  <sub>Base de Datos 2 · 910404 · D1 · 2026B · UNIPAZ</sub>
</p>
