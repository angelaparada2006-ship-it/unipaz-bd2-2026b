# Backend CRUD — Directorio de personas

Aplicación web adaptable a móvil para iniciar sesión y administrar los registros de `public.usuarios`: crear, consultar, editar y eliminar. Usa el proyecto Supabase **Backend-CRUD** (`knlspzqaodqexqnqyojr`).

La portada identifica el trabajo como proyecto académico de Angela para Bases de Datos II en UNIPAZ, con el docente Hermes Acevedo, Ingeniería Informática, cuarto semestre y jornada diurna. También resume el CRUD y la arquitectura usada: Supabase Auth, PostgreSQL/Data API y almacenamiento privado de fotos.

## Modelo y seguridad

- La tabla existente `usuarios` contiene identificación, tipo, nombres, apellidos, correo, teléfono, dirección, usuario y foto.
- Las contraseñas se gestionan con Supabase Auth. La migración elimina la antigua columna `password` (la tabla estaba vacía) y nunca almacena claves en `usuarios`.
- RLS y permisos de Data API limitan todos los registros a cuentas autenticadas con rol `admin`. Asigna ese rol solo a personas autorizadas: los datos incluyen identificaciones, correos, teléfonos y direcciones.
- Las fotos van al bucket privado `profile-photos`; los enlaces firmados duran una hora.
- `supabase-config.js` contiene la URL y la publishable key del proyecto. Esa clave es pública por diseño y está limitada por RLS; nunca la sustituyas por una `service_role` o secret key.

## Puesta en marcha

1. Las migraciones aplicadas están en `supabase/migrations/`; el esquema combinado está en `schema.sql`.
2. Crea una cuenta desde la app (`index.html`) y confirma el correo si Supabase lo solicita.
3. En SQL Editor, cambia el correo del `insert` al final de `schema.sql` y ejecútalo para otorgar `admin` a tu cuenta.
4. Sirve esta carpeta con Live Server u otro servidor estático que soporte ES modules. No abras el archivo con `file://`.

## Publicación

La rama `feat/backend-crud-supabase` despliega la app con GitHub Pages desde `.github/workflows/deploy-backend-crud.yml`. Para que los registros nuevos confirmen el correo y regresen a la app, en Supabase → Authentication → URL Configuration define como **Site URL** `https://angelaparada2006-ship-it.github.io/unipaz-bd2-2026b/` y agrega esa misma URL a **Redirect URLs**. Añade también `http://127.0.0.1:5500/**` para pruebas locales.
