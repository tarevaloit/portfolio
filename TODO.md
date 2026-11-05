# TODO

Contenido y configuración que faltan. No se inventan datos: todo lo que está
acá aparece como placeholder (`[...]`) en el sitio o en la config hasta que se
complete.

## Contenido (Fase 0 — Tobias)

### Experiencia (`assets/content/experience.json`)
- [x] `startYear` de ueno bank / itti: 2025 (del CV), con el cargo actual
      "Software Engineer — Mobile Core".
- [ ] Byto Apps no aparece en el CV: ¿se mantiene en la experiencia? Si sí,
      falta su `startYear`.
- [ ] El CV tiene más puestos (OneInfo 2024–2025, freelance 2024, Miiii
      2019–2024): decidir si suman a la experiencia del sitio.
- [ ] **Confidencialidad:** saqué el nombre `uacd` del bullet de dependencias
      cross ("Mantenimiento y versionado (tags) de las dependencias cross…")
      porque el PLAN prohíbe nombres de repos privados del banco y no sé si
      `uacd` es uno. Si es público, se puede volver a agregar.

### Contacto (`assets/content/contact.json`, hoy todo en `null`)
- [x] `email`: bytoapps@gmail.com.
- [ ] `github` (URL).
- [x] `linkedin`.
- [x] CV en PDF, ES y EN, en `assets/cv/` (incluyen teléfono, email y foto).

### Proyectos (`assets/content/projects/` y `{es,en}/projects/`)
Los textos de cards y descripciones salen de PLAN.md y del mockup. Faltan:

- [ ] `role` de Laburito, Fundido y Este portfolio (hoy `[Rol]`).
- [ ] `platforms` de Laburito y Fundido (hoy `[Plataformas]`).
- [ ] Fundido: proveedor de IA y backend/almacenamiento en `stack`, y `status`.
- [ ] `links` de cada proyecto (store, TestFlight, GitHub, web): hoy `null`.
- [ ] `decisions`: 2 o 3 decisiones técnicas por proyecto. Fishar, Laburito y
      Fundido tienen placeholders `[Decisión técnica N]`.
- [ ] Nombres reales de clases para el modo arquitectura:
  - [ ] Fishar, feature spots: hoy son los del mockup (`SpotsMapPage`,
        `SpotsCubit`, `GetNearbySpots`, `SpotsRepositoryImpl`…). Confirmar.
  - [ ] Fundido, feature chat: placeholders.
  - [ ] Laburito, flujo de contratación: placeholders, incluido el nombre del
        feature.
  - [ ] Descripciones por capa de Laburito y Fundido: placeholders.
- [x] Código real por capa para "Cómo está hecho" (`snippets` en el JSON +
      `projects/<slug>.<id>.snippet`) y árbol del feature (`files`).
- [ ] Cuerpo largo opcional en Markdown (`{es,en}/projects/<slug>.md`).
- [x] Capturas de cada app (WebP, en `assets/projects/`).
- [ ] Videos cortos de cada app (opcional).

## Contenido real importado (revisar)
Sacado de `~/Documents/mediomundo-app`, `~/Documents/laburito` y
`~/Desktop/fundido_app` (sin leer `.env`):
- [ ] Clases, stack, descripciones y decisiones técnicas de Fishar, Laburito y
      Fundido: las decisiones las redacté yo a partir de README, docs y código.
- [ ] Extractos copiados de cada repo (`assets/content/projects/*.snippet`):
      si cambia el archivo original, hay que volver a copiarlos (los de este
      portfolio los verifica un test).
- [ ] CI deploy: a la service account le falta el rol "Service Usage
      Consumer" (y "Firebase Hosting Admin" si no lo tiene) en IAM.
- [ ] Íconos de las apps y el burndown del Sprint 3 de Laburito (`assets/projects/`).
- [ ] Estado de Laburito ("Sprint 6 · release v0.5.0") y de Fundido
      ("Prototipo · 2025", último commit en julio de 2025).
- [ ] `contact.github` = https://github.com/tarevaloit (dueño de los tres repos):
      confirmar que es el perfil público que querés mostrar.
- [ ] Rive real de Fundi en `fundido_app/assets/rive/pig_run_cycle.riv`:
      confirmar licencia antes de usarlo.
- [ ] Capturas reales (las pasaste vos; las recorté y convertí a WebP):
      Fishar sale de las de la tienda; Laburito y Fundido de tus carpetas.
      Dejé afuera las que mostraban emails, teléfono, DNI, IPs, la dirección
      del pedido o tarjetas, y en el dashboard del panel difuminé los
      accesos. Revisá los epígrafes (`mediaCaptions`).
- [ ] Fundido: el chat sale vacío ("¡Empezá a chatear!"). Una captura con una
      conversación con Fundi lo mostraría mucho mejor.
- [ ] Laburito: `links.website` está vacío. Si laburito.web.app es público,
      sumarlo.

## Copy a revisar
- [ ] Traducción al inglés del hero: "Flutter apps with architecture that holds
      up." (`lib/l10n/app_en.arb`). La propuse yo; validarla.
- [ ] Todas las traducciones al inglés de `assets/content/en/` (las hice yo a
      partir del español).
- [ ] Textos en inglés de la home en `lib/l10n/app_en.arb` (hero, métricas,
      contacto, footer, tip): traducciones mías del mockup.
- [ ] Home nueva (hero, métricas y Byto Apps) con datos del CV: 6+ años con
      Flutter, deploys a las stores (ueno bank, OneInfo, apps propias) e IA
      (What's New con IA en ueno, Fundido). Revisar el tono de los textos
      (`hero*`, `metric*`, `byto*` en los ARB).
- [ ] Byto Apps: "Hechas por Toby" lista Fishar, Laburito y Fundido.
      Confirmar si Laburito (proyecto final USAL) va bajo Byto Apps, y sumar
      el año de inicio si querés mostrarlo.
- [ ] Este portfolio: descripciones por capa y las 3 decisiones técnicas
      (`es/projects/portfolio.json`). Las escribí yo a partir de lo que tiene
      el repo; revisar el tono.
- [ ] Este portfolio: `description` es "Caso de estudio del propio sitio." (del
      PLAN); quizás quieras algo más largo para el detalle.
- [ ] Meta description de `web/index.html` y `web/manifest.json`.

## Infraestructura
- [x] Repo público: https://github.com/tarevaloit/portfolio
- [x] Proyecto de Firebase `portfolio-byto`, sitio `tobias-arevalo` → https://tobias-arevalo.web.app
- [ ] En GitHub → Settings → Secrets and variables → Actions:
  - [ ] Variable `FIREBASE_PROJECT_ID`.
  - [ ] Secret `FIREBASE_SERVICE_ACCOUNT` (JSON de la service account).
  Hasta que existan, el job `deploy` de CI se saltea.
- [ ] Opcional: dominio propio (por ejemplo tobiasarevalo.dev) apuntando al
      sitio `tobias-arevalo`; hoy la URL es https://tobias-arevalo.web.app.
- [ ] Flutter Web bloquea el zoom en mobile (`user-scalable=no` lo inyecta el
      engine); Lighthouse lo marca en accesibilidad. Revisar en próximas
      versiones de Flutter.
- [ ] Opcional: fijar la versión de Flutter con fvm (`fvm use 3.44.0`, crea
      `.fvmrc`). CI ya usa 3.44.0.

## Pendientes técnicos de fases futuras
- [ ] Rive: hoy el switch del modo arquitectura (`BlueprintSwitch`) y el
      cerdito (`PiggyAvatar`) están animados en Flutter. Cuando haya `.riv`
      exportados de rive.app, reemplazarlos. Inputs sugeridos de las state
      machines: toggle → `isOn` (bool); cerdito → `talking` (bool) y
      `happy` (trigger).
- [x] `links.github` de "Este portfolio": activa "Código ↗" y los links "↗" de
      cada clase en el modo arquitectura.
- [ ] Renderizar el cuerpo en Markdown del detalle (`{es,en}/projects/<slug>.md`)
      cuando haya contenido; hoy ningún proyecto tiene.
- [ ] Nav en mobile: hoy oculta los links de sección; evaluar un menú.
- [x] `og:url` y URLs absolutas de las imágenes de preview (apuntan a
      tobias-arevalo.web.app; cambiarlas si se suma un dominio propio).
- [ ] Ícono del sitio: generé una marca `t_` en lima (`tool/brand_assets.py`).
      Reemplazala si tenés un ícono propio.
- [ ] Deferred loading en WASM: revisar cuando dart2wasm soporte dividir
      módulos (hoy solo divide el build JS).
