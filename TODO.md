# TODO

Contenido y configuración que faltan. No se inventan datos: todo lo que está
acá aparece como placeholder (`[...]`) en el sitio o en la config hasta que se
complete.

## Contenido (Fase 0 — Tobias)

### Experiencia (`assets/content/experience.json`)
- [ ] `startYear` de ueno bank / itti (hoy `null`).
- [ ] `startYear` de Byto Apps (hoy `null`).
- [ ] **Confidencialidad:** saqué el nombre `uacd` del bullet de dependencias
      cross ("Mantenimiento y versionado (tags) de las dependencias cross…")
      porque el PLAN prohíbe nombres de repos privados del banco y no sé si
      `uacd` es uno. Si es público, se puede volver a agregar.

### Contacto (`assets/content/contact.json`, hoy todo en `null`)
- [ ] `email` (`[TU EMAIL]` en el mockup).
- [ ] `github` (URL).
- [ ] `linkedin` (URL).
- [ ] CV en PDF, ES y EN → `assets/cv/`, declarar la carpeta en `pubspec.yaml`
      y completar `cv.es` / `cv.en` con la ruta.

### Proyectos (`assets/content/projects/` y `{es,en}/projects/`)
Los textos de cards y descripciones salen de PLAN.md y del mockup. Faltan:

- [ ] `role` de Laburito, Fundido y Este portfolio (hoy `[Rol]`).
- [ ] `platforms` de Laburito y Fundido (hoy `[Plataformas]`).
- [ ] Fundido: proveedor de IA y backend/almacenamiento en `stack`, y `status`.
- [ ] `links` de cada proyecto (store, TestFlight, GitHub, web): hoy `null`.
      El de GitHub de Este portfolio va cuando exista el repo público.
- [ ] `decisions`: 2 o 3 decisiones técnicas por proyecto. Fishar, Laburito y
      Fundido tienen placeholders `[Decisión técnica N]`.
- [ ] Nombres reales de clases para el modo arquitectura:
  - [ ] Fishar, feature spots: hoy son los del mockup (`SpotsMapPage`,
        `SpotsCubit`, `GetNearbySpots`, `SpotsRepositoryImpl`…). Confirmar.
  - [ ] Fundido, feature chat: placeholders.
  - [ ] Laburito, flujo de contratación: placeholders, incluido el nombre del
        feature.
  - [ ] Descripciones por capa de Laburito y Fundido: placeholders.
- [ ] Snippets reales para "Cómo está hecho" (`projects/<slug>.snippet` +
      `snippet` en el JSON). Fishar no tiene: el del mockup era ilustrativo.
- [ ] Cuerpo largo opcional en Markdown (`{es,en}/projects/<slug>.md`).
- [ ] Capturas y videos cortos de cada app (WebP, tamaños fijos).

## Copy a revisar
- [ ] Traducción al inglés del hero: "Flutter apps with architecture that holds
      up." (`lib/l10n/app_en.arb`). La propuse yo; validarla.
- [ ] Todas las traducciones al inglés de `assets/content/en/` (las hice yo a
      partir del español).
- [ ] Textos en inglés de la home en `lib/l10n/app_en.arb` (hero, métricas,
      contacto, footer, tip): traducciones mías del mockup.
- [ ] Textos de ejemplo de las demos (`demoFundido*`, `demoLaburito*` en los
      ARB): conversación del cerdito, oficios y nombres ficticios de
      trabajadores. Los escribí yo para que las demos se entiendan; cambialos
      por los de las apps reales si querés.
- [ ] Demo de Fishar: usa los placeholders del mockup (`[Nombre del spot]`,
      `[Especie] · [distancia] · [cantidad] capturas`).
- [ ] Métricas de la home: son las del PLAN/mockup ("40+", "~1 s",
      "iOS + Android"). Confirmar que se pueden mostrar así.
- [ ] Este portfolio: descripciones por capa y las 3 decisiones técnicas
      (`es/projects/portfolio.json`). Las escribí yo a partir de lo que tiene
      el repo; revisar el tono.
- [ ] Este portfolio: `description` es "Caso de estudio del propio sitio." (del
      PLAN); quizás quieras algo más largo para el detalle.
- [ ] Meta description de `web/index.html` y `web/manifest.json`.

## Infraestructura
- [ ] Crear el repo público en GitHub y hacer push de `main`.
- [ ] Crear el proyecto de Firebase y habilitar Hosting.
- [ ] En GitHub → Settings → Secrets and variables → Actions:
  - [ ] Variable `FIREBASE_PROJECT_ID`.
  - [ ] Secret `FIREBASE_SERVICE_ACCOUNT` (JSON de la service account).
  Hasta que existan, el job `deploy` de CI se saltea.
- [ ] Dominio propio (`[dominio]`) apuntando a Firebase Hosting.
- [ ] Opcional: fijar la versión de Flutter con fvm (`fvm use 3.44.0`, crea
      `.fvmrc`). CI ya usa 3.44.0.

## Pendientes técnicos de fases futuras
- [ ] Rive: hoy el switch del modo arquitectura (`BlueprintSwitch`) y el
      cerdito (`PiggyAvatar`) están animados en Flutter. Cuando haya `.riv`
      exportados de rive.app, reemplazarlos. Inputs sugeridos de las state
      machines: toggle → `isOn` (bool); cerdito → `talking` (bool) y
      `happy` (trigger).
- [ ] `links.github` de "Este portfolio" en `assets/content/projects/portfolio.json`:
      activa los links "↗" de cada clase en el modo arquitectura.
- [ ] Renderizar el cuerpo en Markdown del detalle (`{es,en}/projects/<slug>.md`)
      cuando haya contenido; hoy ningún proyecto tiene.
- [ ] Deferred import de la página de detalle (Fase 6).
- [ ] Títulos de pestaña y `lang` del `<html>` según la ruta: hoy los pone cada
      página con `Title`; revisarlo junto con los meta tags (Fase 6).
- [ ] Nav en mobile: hoy oculta los links de sección; evaluar un menú.
- [ ] Favicon e íconos de la PWA: siguen siendo los default de Flutter (Fase 6).
- [ ] `lang` del `<html>` y título de la pestaña según el idioma de la ruta (Fase 6).
- [ ] Loader HTML y OG tags (Fase 6).
