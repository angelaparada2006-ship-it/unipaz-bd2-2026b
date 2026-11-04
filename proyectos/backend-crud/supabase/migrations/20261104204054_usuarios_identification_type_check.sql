do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'usuarios_tipo_identificacion_check'
      and conrelid = 'public.usuarios'::regclass
  ) then
    alter table public.usuarios add constraint usuarios_tipo_identificacion_check
      check (tipo_identificacion in ('CC','TI','CE','PA','PPT','OTRO'));
  end if;
end;
$$;
