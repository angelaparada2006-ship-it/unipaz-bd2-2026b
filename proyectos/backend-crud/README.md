# Backend CRUD — Demo técnica de PostgreSQL y Supabase

Demostración académica de un sistema CRUD de personas desarrollado para Bases de Datos II en UNIPAZ. La portada pública explica la entrega y permite probar las operaciones con registros completamente ficticios, guardados solo en memoria del navegador durante la sesión. El botón **Acceso administrador** abre el módulo conectado al proyecto Supabase **Backend-CRUD** (`knlspzqaodqexqnqyojr`) para cuentas autorizadas.

La aplicación identifica el trabajo de Angela para Bases de Datos II en UNIPAZ, con el docente Hermes Acevedo, Ingeniería Informática, cuarto semestre y jornada diurna. Resume la arquitectura y operaciones del CRUD, e incluye enlace al repositorio de GitHub. La demo pública no consulta ni modifica la base real.

## Modelo y seguridad

- La tabla `public.usuarios` contiene identificación, tipo, nombres, apellidos, correo, teléfono, dirección, username y foto.
- Las contraseñas se gestionan con Supabase Auth. La migración elimina la antigua columna `password` (la tabla estaba vacía) y nunca almacena claves en `usuarios`.
- RLS y permisos de Data API limitan todos los registros reales a cuentas autenticadas con rol `admin`. Asigna ese rol solo a personas autorizadas: los datos incluyen identificaciones, correos, teléfonos y direcciones. La pantalla pública usa ejemplos ficticios y no es una cuenta demo conectada a la base real.
- Las fotos van al bucket privado `profile-photos`; los enlaces firmados duran una hora.
- `supabase-config.js` contiene la URL y la publishable key del proyecto. Esa clave es pública por diseño y está limitada por RLS; nunca la sustituyas por una `service_role` o secret key.

## Puesta en marcha

1. Las migraciones aplicadas están en `supabase/migrations/`; el esquema combinado está en `schema.sql`.
2. Desde la portada, selecciona **Acceso administrador**, crea una cuenta y confirma el correo si Supabase lo solicita.
3. En SQL Editor, cambia el correo del `insert` al final de `schema.sql` y ejecútalo para otorgar `admin` a tu cuenta.
4. Sirve esta carpeta con Live Server u otro servidor estático que soporte ES modules. No abras el archivo con `file://`. La demo pública funciona en el navegador y sus cambios se reinician al actualizar la página.

## Publicación

La rama `feat/backend-crud-supabase` despliega la app con GitHub Pages desde `.github/workflows/deploy-backend-crud.yml`. Para que los registros nuevos confirmen el correo y regresen a la app, en Supabase → Authentication → URL Configuration define como **Site URL** `https://angelaparada2006-ship-it.github.io/unipaz-bd2-2026b/` y agrega esa misma URL a **Redirect URLs**. Añade también `http://127.0.0.1:5500/**` para pruebas locales.
