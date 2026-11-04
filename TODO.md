# TODO

Contenido y configuración que faltan. No se inventan datos: todo lo que está
acá aparece como placeholder (`[...]`) en el sitio o en la config hasta que se
complete.

## Contenido (Fase 0 — Tobias)

### Experiencia
- [ ] Año de inicio en ueno bank / itti (`[AÑO]` en el mockup).
- [ ] Año de inicio en Byto Apps (`[AÑO]` en el mockup).

### Contacto
- [ ] Email de contacto (`[TU EMAIL]` en el mockup).
- [ ] URL de GitHub.
- [ ] URL de LinkedIn.
- [ ] CV en PDF, ES y EN → `assets/cv/`.

### Proyectos
- [ ] Textos ES/EN de Fishar, Fundido y Laburito.
- [ ] Capturas y videos cortos de cada app (WebP, tamaños fijos).
- [ ] Links a store, TestFlight o GitHub de cada proyecto, si existen.
- [ ] 2 o 3 decisiones técnicas por proyecto para la página de detalle.
- [ ] Fundido: proveedor de IA, backend/almacenamiento y estado del proyecto.
- [ ] Nombres reales de clases para el modo arquitectura:
  - [ ] Fishar, feature spots (el mockup usa `SpotsMapPage`, `SpotsCubit`,
        `GetNearbySpots`, `SpotsRepositoryImpl`, etc.: confirmar si son los reales).
  - [ ] Fundido, chat.
  - [ ] Laburito, flujo de contratación.
- [ ] Fishar: snippet real para "Cómo está hecho" (el del mockup es ilustrativo).

## Copy a revisar
- [ ] Traducción al inglés del hero: "Flutter apps with architecture that holds
      up." (`lib/l10n/app_en.arb`). La propuse yo; validarla.
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
- [ ] Favicon e íconos de la PWA: siguen siendo los default de Flutter (Fase 6).
- [ ] `lang` del `<html>` y título de la pestaña según el idioma de la ruta (Fase 6).
- [ ] Loader HTML y OG tags (Fase 6).
