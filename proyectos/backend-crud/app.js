import { createClient } from "https://esm.sh/@supabase/supabase-js@2.119.0";
import { SUPABASE_URL, SUPABASE_ANON_KEY } from "./supabase-config.js";

const $ = (selector) => document.querySelector(selector);
const landingView = $("#landing-view"), demoView = $("#demo-view"), authView = $("#auth-view"), appView = $("#app-view");
const authForm = $("#auth-form"), profileForm = $("#profile-form");
const configReady = SUPABASE_URL.startsWith("https://") && !SUPABASE_URL.includes("TU-PROJECT") && SUPABASE_ANON_KEY.length > 20 && !SUPABASE_ANON_KEY.includes("TU-PUBLISHABLE");
let supabase, currentUser, usuarios = [], editingId = null, selectedPhoto = null, authMode = "signin", toastTimer, demoToastTimer, demoEditingId = null;
let demoPeople = [
  {id:"11111111-1111-4111-8111-111111111111",identificacion:"DEMO-001",tipo_identificacion:"CC",nombres_1_y_2:"Ana María",apellidos_1_y_2:"Ejemplo Cortés",correo_electronico:"ana@example.com",telefono:"+57 300 000 0001",direccion:"Dirección ficticia 1",username:"cortes.ana.demo"},
  {id:"22222222-2222-4222-8222-222222222222",identificacion:"DEMO-002",tipo_identificacion:"TI",nombres_1_y_2:"Alex",apellidos_1_y_2:"Persona Demostración",correo_electronico:"alex@example.com",telefono:"+57 300 000 0002",direccion:"Dirección ficticia 2",username:"demostracion.alex.demo"}
];

function toast(message) { const el = $("#toast"); el.textContent = message; el.classList.remove("hidden"); clearTimeout(toastTimer); toastTimer = setTimeout(() => el.classList.add("hidden"), 3200); }
function showError(message) { const el = $("#form-error"); el.textContent = message; el.classList.remove("hidden"); }
function clearError() { $("#form-error").classList.add("hidden"); $("#form-error").textContent = ""; }
function errorText(error) {
  if (error?.code === "23505") return "La identificación, el correo o el usuario ya están registrados.";
  if (error?.status === 429) return "Demasiados intentos. Espera un momento y vuelve a intentarlo.";
  return error?.message || "Ocurrió un error. Inténtalo de nuevo.";
}
function setAuthMode(mode) {
  authMode = mode;
  const signup = mode === "signup";
  $("#auth-eyebrow").textContent = signup ? "CREA TU CUENTA" : "BIENVENIDO";
  $("#auth-title").textContent = signup ? "Crea tu acceso" : "Inicia sesión";
  $("#auth-subtitle").textContent = signup ? "Usa tu correo y una contraseña segura." : "Accede al sistema de demostración CRUD.";
  $("#auth-submit").innerHTML = signup ? "Crear cuenta <span aria-hidden=\"true\">→</span>" : "Iniciar sesión <span aria-hidden=\"true\">→</span>";
  $("#auth-switch-copy").textContent = signup ? "¿Ya tienes cuenta?" : "¿Primera vez aquí?";
  $("#auth-switch").textContent = signup ? "Iniciar sesión" : "Crear cuenta";
  $("#auth-password").autocomplete = signup ? "new-password" : "current-password";
}
async function showSignedIn(user) {
  currentUser = user;
  const { data, error } = await supabase.from("app_roles").select("role").eq("user_id", user.id).eq("role", "admin").maybeSingle();
  if (error) { toast(errorText(error)); return; }
  landingView.classList.add("hidden"); demoView.classList.add("hidden");
  if (!data) {
    authView.classList.remove("hidden"); appView.classList.add("hidden");
    $("#auth-title").textContent = "Acceso pendiente";
    $("#auth-subtitle").textContent = "Esta cuenta necesita el rol de administrador para gestionar el directorio.";
    $("#auth-form").classList.add("hidden"); $(".auth-switch").classList.add("hidden");
    let logout = $("#access-signout");
    if (!logout) { logout = document.createElement("button"); logout.id = "access-signout"; logout.type = "button"; logout.className = "button quiet"; logout.textContent = "Cerrar esta sesión"; $(".auth-card").append(logout); logout.addEventListener("click", async () => { await supabase.auth.signOut(); }); }
    return;
  }
  $("#access-signout")?.remove(); $("#auth-form").classList.remove("hidden"); $(".auth-switch").classList.remove("hidden");
  authView.classList.add("hidden"); appView.classList.remove("hidden"); $("#signed-in-email").textContent = user.email || "";
  await loadUsuarios();
}
function fullName(person) { return [person.nombres_1_y_2, person.apellidos_1_y_2].filter(Boolean).join(" "); }
function initials(person) { return `${person.nombres_1_y_2?.trim()?.[0] || ""}${person.apellidos_1_y_2?.trim()?.[0] || ""}`.toUpperCase() || "P"; }
async function photoUrl(path) {
  if (!path) return null;
  const { data } = await supabase.storage.from("profile-photos").createSignedUrl(path, 3600);
  return data?.signedUrl || null;
}
async function loadUsuarios() {
  const list = $("#profile-list"); list.innerHTML = `<div class="empty-state">Cargando personas…</div>`;
  const { data, error } = await supabase.from("usuarios").select("id,identificacion,tipo_identificacion,nombres_1_y_2,apellidos_1_y_2,correo_electronico,telefono,direccion,username,foto,created_at,updated_at").order("apellidos_1_y_2").order("nombres_1_y_2");
  if (error) { list.innerHTML = ""; toast(errorText(error)); return; }
  usuarios = data || []; renderUsuarios();
}
async function renderUsuarios() {
  const query = $("#search").value.trim().toLocaleLowerCase("es");
  const filtered = usuarios.filter((p) => [fullName(p),p.identificacion,p.correo_electronico,p.username].filter(Boolean).join(" ").toLocaleLowerCase("es").includes(query));
  $("#profile-count").textContent = `${usuarios.length} ${usuarios.length === 1 ? "persona registrada" : "personas registradas"}`;
  $("#empty-state").classList.toggle("hidden", usuarios.length > 0);
  $("#profile-list").classList.toggle("hidden", usuarios.length === 0);
  $("#profile-list").innerHTML = filtered.map((p) => `<article class="profile-item" data-id="${p.id}"><div class="avatar" data-avatar="${p.id}">${escapeHtml(initials(p))}</div><div><p class="person-name">${escapeHtml(fullName(p))}</p><p class="person-meta">@${escapeHtml(p.username)}</p></div><div class="profile-email">${escapeHtml(p.correo_electronico)}</div><p class="profile-document">${escapeHtml(p.tipo_identificacion)} · ${escapeHtml(p.identificacion)}</p><div class="item-actions"><button class="small-action" data-action="edit" type="button">Editar</button><button class="small-action" data-action="delete" type="button">Eliminar</button></div></article>`).join("");
  for (const p of filtered.filter((person) => person.foto)) { const url = await photoUrl(p.foto); const avatar = document.querySelector(`[data-avatar="${CSS.escape(p.id)}"]`); if (url && avatar) avatar.innerHTML = `<img src="${url}" alt="Foto de ${escapeHtml(fullName(p))}" />`; }
}
function escapeHtml(value) { return String(value ?? "").replace(/[&<>"']/g, (c) => ({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c])); }
function resetProfileForm() { profileForm.reset(); editingId = null; selectedPhoto = null; $("#profile-form-title").textContent = "Nueva persona"; $("#save-profile").innerHTML = "Guardar persona <span aria-hidden=\"true\">→</span>"; $("#photo-preview").innerHTML = "＋"; clearError(); }
function openProfileForm(person = null) {
  resetProfileForm(); editingId = person?.id || null;
  $("#profile-form-title").textContent = editingId ? "Editar persona" : "Nueva persona";
  $("#save-profile").innerHTML = editingId ? "Guardar cambios <span aria-hidden=\"true\">→</span>" : "Guardar persona <span aria-hidden=\"true\">→</span>";
  if (person) {
    const [first = "", ...middle] = (person.nombres_1_y_2 || "").split(" ");
    const [last = "", ...second] = (person.apellidos_1_y_2 || "").split(" ");
    for (const [id,value] of Object.entries({"identification-type":person.tipo_identificacion,"identification-number":person.identificacion,"first-name":first,"middle-name":middle.join(" "),"last-name":last,"second-last-name":second.join(" "),"profile-email":person.correo_electronico,"phone":person.telefono,"address":person.direccion})) $(`#${id}`).value = value || "";
    if (person.foto) photoUrl(person.foto).then((url) => { if (url) $("#photo-preview").innerHTML = `<img src="${url}" alt="Foto actual" />`; });
  }
  $("#profile-list-view").classList.add("hidden"); $("#profile-form-view").classList.remove("hidden"); window.scrollTo({top:0,behavior:"smooth"});
}
function closeProfileForm() { $("#profile-form-view").classList.add("hidden"); $("#profile-list-view").classList.remove("hidden"); resetProfileForm(); }
function makeUsername() {
  const base = [$("#last-name").value,$("#first-name").value].join(".").normalize("NFD").replace(/[\u0300-\u036f]/g,"").toLowerCase().replace(/[^a-z0-9.]/g,"").replace(/\.+/g,".").replace(/^\.|\.$/g,"").slice(0,36);
  return `${base || "usuario"}.${crypto.randomUUID().slice(0,6)}`;
}

function demoToast(message) { const el = $("#demo-toast"); el.textContent = message; el.classList.remove("hidden"); clearTimeout(demoToastTimer); demoToastTimer = setTimeout(() => el.classList.add("hidden"), 2600); }
function renderDemo() {
  const query = $("#demo-search").value.trim().toLocaleLowerCase("es");
  const filtered = demoPeople.filter((person) => [fullName(person),person.identificacion,person.correo_electronico,person.username].join(" ").toLocaleLowerCase("es").includes(query));
  $("#demo-count").textContent = `${demoPeople.length} ${demoPeople.length === 1 ? "registro ficticio" : "registros ficticios"}`;
  $("#demo-empty").classList.toggle("hidden", filtered.length > 0);
  $("#demo-list").classList.toggle("hidden", filtered.length === 0);
  $("#demo-list").innerHTML = filtered.map((person) => `<article class="profile-item" data-demo-id="${escapeHtml(person.id)}"><div class="avatar">${escapeHtml(initials(person))}</div><div><p class="person-name">${escapeHtml(fullName(person))}</p><p class="person-meta">@${escapeHtml(person.username)}</p></div><div class="profile-email">${escapeHtml(person.correo_electronico)}</div><p class="profile-document">${escapeHtml(person.tipo_identificacion)} · ${escapeHtml(person.identificacion)}</p><div class="item-actions"><button class="small-action" data-demo-action="edit" type="button">Editar</button><button class="small-action" data-demo-action="delete" type="button">Eliminar</button></div></article>`).join("");
}
function openDemoForm(person = null) {
  demoEditingId = person?.id || null; $("#demo-form").reset();
  $("#demo-form-title").textContent = demoEditingId ? "Editar persona de ejemplo" : "Nueva persona de ejemplo";
  for (const [id,value] of Object.entries({"demo-identification-type":person?.tipo_identificacion,"demo-identification":person?.identificacion,"demo-names":person?.nombres_1_y_2,"demo-surnames":person?.apellidos_1_y_2,"demo-email":person?.correo_electronico,"demo-phone":person?.telefono,"demo-address":person?.direccion})) $(`#${id}`).value = value || "";
  $("#demo-list-view").classList.add("hidden"); $("#demo-form-view").classList.remove("hidden"); window.scrollTo({top:0,behavior:"smooth"});
}
function closeDemoForm() { $("#demo-form-view").classList.add("hidden"); $("#demo-list-view").classList.remove("hidden"); $("#demo-form").reset(); demoEditingId = null; }
function openAuth() {
  landingView.classList.add("hidden"); demoView.classList.add("hidden"); appView.classList.add("hidden"); authView.classList.remove("hidden");
  if (configReady) { authForm.classList.remove("hidden"); $(".auth-switch").classList.remove("hidden"); $("#access-signout")?.remove(); authForm.reset(); setAuthMode("signin"); }
}
function showLanding() {
  demoView.classList.add("hidden"); authView.classList.add("hidden"); appView.classList.add("hidden"); landingView.classList.remove("hidden");
  if (configReady) { authForm.classList.remove("hidden"); $(".auth-switch").classList.remove("hidden"); $("#access-signout")?.remove(); authForm.reset(); setAuthMode("signin"); }
}

$("#auth-switch").addEventListener("click", () => setAuthMode(authMode === "signin" ? "signup" : "signin"));
authForm.addEventListener("submit", async (event) => {
  event.preventDefault(); const button = $("#auth-submit"); button.disabled = true;
  try {
    const email = $("#auth-email").value.trim(), password = $("#auth-password").value;
    const result = authMode === "signup" ? await supabase.auth.signUp({email,password,options:{emailRedirectTo:new URL("./",window.location.href).href}}) : await supabase.auth.signInWithPassword({email,password});
    if (result.error) throw result.error;
    if (authMode === "signup" && !result.data.session) { toast("Confirma tu correo y luego inicia sesión."); setAuthMode("signin"); }
    else if (result.data.user) await showSignedIn(result.data.user);
  } catch (error) { toast(errorText(error)); } finally { button.disabled = false; }
});
$("#open-login").addEventListener("click", openAuth);
authView.addEventListener("click", (event) => { if (event.target.closest("#back-to-project")) showLanding(); });
$("#try-demo").addEventListener("click", () => { landingView.classList.add("hidden"); authView.classList.add("hidden"); demoView.classList.remove("hidden"); closeDemoForm(); renderDemo(); });
$("#demo-to-landing").addEventListener("click", showLanding);
$("#demo-to-auth").addEventListener("click", openAuth);
$("#demo-new").addEventListener("click", () => openDemoForm());
$("#demo-cancel").addEventListener("click", closeDemoForm);
$("#demo-cancel-top").addEventListener("click", closeDemoForm);
$("#demo-search").addEventListener("input", renderDemo);
$("#demo-list").addEventListener("click", (event) => {
  const button = event.target.closest("button[data-demo-action]"); if (!button) return;
  const person = demoPeople.find((item) => item.id === button.closest("[data-demo-id]").dataset.demoId); if (!person) return;
  if (button.dataset.demoAction === "edit") openDemoForm(person);
  if (button.dataset.demoAction === "delete" && window.confirm(`¿Eliminar el ejemplo de ${fullName(person)}?`)) { demoPeople = demoPeople.filter((item) => item.id !== person.id); renderDemo(); demoToast("Ejemplo eliminado de esta sesión."); }
});
$("#demo-form").addEventListener("submit", (event) => {
  event.preventDefault();
  const previous = demoPeople.find((person) => person.id === demoEditingId);
  const names = $("#demo-names").value.trim(), surnames = $("#demo-surnames").value.trim();
  const usernameBase = [surnames.split(/\s+/)[0],names.split(/\s+/)[0]].join(".").normalize("NFD").replace(/[\u0300-\u036f]/g,"").toLowerCase().replace(/[^a-z0-9.]/g,"");
  const person = {id:previous?.id || crypto.randomUUID(),identificacion:$("#demo-identification").value.trim(),tipo_identificacion:$("#demo-identification-type").value,nombres_1_y_2:names,apellidos_1_y_2:surnames,correo_electronico:$("#demo-email").value.trim().toLowerCase(),telefono:$("#demo-phone").value.trim()||null,direccion:$("#demo-address").value.trim()||null,username:previous?.username || `${usernameBase || "persona"}.${crypto.randomUUID().slice(0,6)}`};
  demoPeople = previous ? demoPeople.map((item) => item.id === previous.id ? person : item) : [...demoPeople,person];
  closeDemoForm(); renderDemo(); demoToast(previous ? "Ejemplo actualizado en esta sesión." : "Ejemplo agregado en esta sesión.");
});
$("#sign-out").addEventListener("click", async () => { await supabase.auth.signOut(); usuarios = []; authForm.reset(); setAuthMode("signin"); });
$("#new-profile").addEventListener("click", () => openProfileForm());
$("#empty-create").addEventListener("click", () => openProfileForm());
$("#cancel-edit").addEventListener("click", closeProfileForm);
$("#cancel-edit-bottom").addEventListener("click", closeProfileForm);
$("#search").addEventListener("input", renderUsuarios);
$("#profile-list").addEventListener("click", async (event) => {
  const button = event.target.closest("button[data-action]"); if (!button) return;
  const person = usuarios.find((p) => p.id === button.closest("[data-id]").dataset.id); if (!person) return;
  if (button.dataset.action === "edit") openProfileForm(person);
  if (button.dataset.action === "delete") {
    if (!window.confirm(`¿Eliminar el registro de ${fullName(person)}? Esta acción no se puede deshacer.`)) return;
    const { error } = await supabase.from("usuarios").delete().eq("id", person.id);
    if (error) toast(errorText(error)); else { if (person.foto) await supabase.storage.from("profile-photos").remove([person.foto]); toast("Persona eliminada."); loadUsuarios(); }
  }
});
$("#photo-input").addEventListener("change", (event) => {
  const file = event.target.files?.[0]; if (!file) return;
  if (!/^image\/(jpeg|png|webp)$/.test(file.type) || file.size > 5*1024*1024) { event.target.value = ""; selectedPhoto = null; showError("Elige una imagen JPG, PNG o WebP de máximo 5 MB."); return; }
  clearError(); selectedPhoto = file; const reader = new FileReader(); reader.onload = () => { $("#photo-preview").innerHTML = `<img src="${reader.result}" alt="Vista previa de la foto" />`; }; reader.readAsDataURL(file);
});
profileForm.addEventListener("submit", async (event) => {
  event.preventDefault(); clearError(); const button = $("#save-profile"); button.disabled = true;
  let uploadedPath = null;
  try {
    const personId = editingId || crypto.randomUUID();
    const previous = usuarios.find((p) => p.id === editingId);
    const names = [$("#first-name").value.trim(),$("#middle-name").value.trim()].filter(Boolean).join(" ");
    const surnames = [$("#last-name").value.trim(),$("#second-last-name").value.trim()].filter(Boolean).join(" ");
    const values = {identificacion:$("#identification-number").value.trim(),tipo_identificacion:$("#identification-type").value,nombres_1_y_2:names,apellidos_1_y_2:surnames,correo_electronico:$("#profile-email").value.trim().toLowerCase(),telefono:$("#phone").value.trim()||null,direccion:$("#address").value.trim()||null,username:previous?.username || makeUsername(),created_by:previous?.created_by || currentUser.id};
    if (selectedPhoto) { const ext = selectedPhoto.type === "image/png" ? "png" : selectedPhoto.type === "image/webp" ? "webp" : "jpg"; uploadedPath = `${personId}/${crypto.randomUUID()}.${ext}`; const {error} = await supabase.storage.from("profile-photos").upload(uploadedPath,selectedPhoto,{upsert:false,contentType:selectedPhoto.type}); if (error) throw error; values.foto = uploadedPath; }
    else if (previous) values.foto = previous.foto;
    const {error} = editingId ? await supabase.from("usuarios").update(values).eq("id",personId) : await supabase.from("usuarios").insert({id:personId,...values});
    if (error) throw error;
    if (selectedPhoto && previous?.foto) await supabase.storage.from("profile-photos").remove([previous.foto]);
    closeProfileForm(); toast(editingId ? "Cambios guardados." : "Persona registrada."); await loadUsuarios();
  } catch (error) { if (uploadedPath) await supabase.storage.from("profile-photos").remove([uploadedPath]); showError(errorText(error)); }
  finally { button.disabled = false; }
});

if (!configReady) {
  authView.innerHTML = `<div class="auth-intro"><div class="brand"><span class="brand-mark">C</span><span>CRUD · UNIPAZ</span></div><div class="intro-copy"><span class="eyebrow">CONFIGURACIÓN PENDIENTE</span><h1>Conecta tu<br /><em>proyecto.</em></h1><p>La demo pública está disponible. Para usar la administración, configura la conexión con Supabase.</p></div><div class="intro-footer">Revisa el archivo README.md</div></div><div class="auth-card-wrap"><button id="back-to-project" class="button quiet back-to-project" type="button">← Volver a la presentación</button><div class="auth-card"><div class="auth-heading"><span class="eyebrow">PASO FINAL</span><h2>Configura Supabase</h2><p>Completa la clave en <code>supabase-config.js</code> y aplica <code>schema.sql</code> en SQL Editor.</p></div></div></div>`;
} else {
  supabase = createClient(SUPABASE_URL,SUPABASE_ANON_KEY);
  supabase.auth.onAuthStateChange((_event,session) => { if (session?.user) queueMicrotask(() => showSignedIn(session.user)); else { appView.classList.add("hidden"); demoView.classList.add("hidden"); authView.classList.add("hidden"); landingView.classList.remove("hidden"); authForm.classList.remove("hidden"); $(".auth-switch").classList.remove("hidden"); $("#access-signout")?.remove(); setAuthMode("signin"); } });
}
