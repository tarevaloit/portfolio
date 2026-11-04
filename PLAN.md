# Plan portfolio Flutter Web — handoff a Claude Code

Nov 4, 2026 · @Tobias Arevalo

## Cómo usar este doc

El código se construye con Claude Code en tu compu (app de escritorio, pestaña Code), dentro de una carpeta vacía `portfolio/`.

1. Exportá este doc como Markdown y guardalo en la raíz del repo como `PLAN.md`.
2. Sacale capturas al mockup del canvas (home + detalle Fishar) y guardalas en `docs/mockup/`. Claude Code no puede abrir el link privado del canvas.
3. Abrí la carpeta en Claude Code y pegale el prompt de la última sección.
4. Trabajá fase por fase: revisás, commiteás y recién ahí le pedís la siguiente.

## Objetivo y contexto

Un portfolio personal hecho en Flutter Web. Tiene que mostrar los proyectos y la experiencia de Tobias, y a la vez ser la prueba de cómo trabaja: clean architecture, tests, CI/CD y buenas animaciones.

- **Audiencia:** recruiters y tech leads que buscan devs Flutter. Llegan desde el CV o LinkedIn, así que el SEO es secundario.
- **Idiomas:** español e inglés, con español por defecto.
- **Repo público:** el código es parte del portfolio. El README explica la arquitectura.
- **Diferencial:** un "modo arquitectura" que superpone, sobre la UI, las capas presentation / domain / data de cada feature.

## Contenido

Todo el contenido vive en `assets/content/` como JSON + Markdown, en ES y EN. Agregar un proyecto no requiere tocar código. Lo que está entre corchetes lo completa Tobias.

### Proyectos

| Proyecto | Qué es | Stack | Estado | Capas a mostrar en modo arquitectura |
| --- | --- | --- | --- | --- |
| Fishar | App social de pesca (Byto Apps): spots en el mapa, capturas, comunidad | Flutter, Firebase, Maps · iOS + Android | Beta: TestFlight y Play closed testing | \[nombres reales de clases del feature spots\] |
| Fundido | Chatbot de finanzas personales con un cerdito conectado a IA: le hablás y te organiza las finanzas | Flutter, \[proveedor de IA\], \[backend/almacenamiento\] | \[estado\] | \[nombres reales de clases del chat\] |
| Laburito | Plataforma que conecta clientes con trabajadores de oficio. Proyecto final de la USAL, con plan IEEE 1058, matriz de riesgos y burndown | Flutter, Google Maps, Firebase, Mercado Pago, backend relacional | Proyecto final | \[nombres reales de clases del flujo de contratación\] |
| Este portfolio | Caso de estudio del propio sitio | Flutter Web (WASM), go\_router, \[Riverpod o Bloc\] | Online | Las del propio repo |

Cada proyecto necesita capturas o un video corto, un link a la store, TestFlight o GitHub si existe, y 2 o 3 decisiones técnicas para su página de detalle.

### Experiencia

**ueno bank / itti — Flutter Developer, Mobile Core** (\[desde AAAA\] – presente)

- Features para una super-app que integra más de 40 microapps como packages.
- Mantenimiento y versionado (tags) de uacd, las dependencias cross de las microapps.
- Feature flags nativas en tiempo real (\~1 s) en lugar de las hasta 24 h de Firebase Remote Config.
- Generador de What's New con IA que analiza los cambios de cada microapp y redacta las novedades.
- Deploy de la app a App Store y Google Play.
- Revisiones de arquitectura en el SDK interno (por ejemplo, Strategy pattern para conexiones de feature flags).

Nada de código, capturas internas ni nombres de repos privados del banco: solo descripciones y diagramas genéricos.

**Byto Apps — Founder / freelance mobile developer** (\[desde AAAA\] – presente). Apps para clientes internacionales y productos propios.

### Contacto

Email, GitHub, LinkedIn y CV descargable en PDF (ES/EN) en `assets/cv/`.

## Diseño y animaciones

La referencia es el mockup en `docs/mockup/`: home + detalle de proyecto. Look oscuro, tipográfico, con estética de plano técnico.

### Tokens

| Token | Valor |
| --- | --- |
| Fondo | #0E0F12 · superficies #131519 / #17191E · bordes #22252B |
| Texto | #ECEAE4 · secundario #B9B8B1 · muted #9A9A93 |
| Acento | Lima #C6F432 (configurable en el theme) |
| Capas | presentation #7DD3FC · domain = acento · data #FDBA74 |
| Tipografía | Bricolage Grotesque (display y texto) + JetBrains Mono (etiquetas y código), vía google\_fonts o assets locales |
| Radios | 16 / 24 / 32 · pills 999 |

### Secciones de la home

1. Nav: logo `tobias.dev_` con cursor titilando, links y el toggle **Modo arquitectura**.
2. Hero: título grande ("Apps Flutter con arquitectura que aguanta."), bajada, CTAs y tres planchas flotantes (presentation / domain / data).
3. Tres métricas reales: 40+ microapps, feature flags en \~1 s y deploy iOS + Android.
4. Marquee infinito con el stack.
5. Grilla de proyectos: cards con hover que levanta y Hero transition al detalle.
6. Experiencia en formato timeline.
7. Bloque de contacto en color acento.

### Detalle de proyecto

Hero con el nombre gigante y los metadatos (rol, plataformas, estado). Al costado, un phone frame con una mini versión navegable de la app. Abajo, la sección "Cómo está hecho", con las tres capas y un snippet de código real con syntax highlight.

### Animaciones

- Entradas escalonadas (fade + slide) con `flutter_animate`.
- Reveal al scrollear: cada sección anima al entrar al viewport.
- Hero transitions entre la card y el detalle.
- Fondo con fragment shader (`.frag`) sutil, que reacciona al mouse y al scroll.
- Modo arquitectura: aparece una grilla tipo plano y cada widget muestra su badge de capa, todo con transición animada.
- Microinteracciones con Rive: el toggle, y el cerdito de Fundido en su página.
- Respetar `MediaQuery.disableAnimations` (reduced motion).

## Stack y arquitectura

Flutter Web compilado a WASM (`flutter build web --wasm`), con clean architecture por feature.

| Tema | Elección |
| --- | --- |
| Estado | \[Riverpod o Bloc: el que use Tobias en el laburo\] |
| Navegación | go\_router con URLs limpias (`/`, `/projects/fishar`, `/en/...`) |
| i18n | flutter\_localizations + ARB (ES/EN) |
| Animación | flutter\_animate, Rive, fragment shaders |
| Modelos | freezed + json\_serializable |
| Inyección | providers de Riverpod o get\_it, según el estado elegido |
| Tests | unit (domain), widget, golden (cards y hero) |
| Lint | very\_good\_analysis o flutter\_lints estricto |
| Hosting | Firebase Hosting o Cloudflare Pages |
| CI/CD | GitHub Actions: analyze, test, build web --wasm y deploy en push a `main` |

### Estructura

```
lib/
  app/                # MaterialApp.router, theme, l10n
  core/
    design_system/    # tokens, tipografía, componentes base
    architecture_mode/# overlay + LayerBadge (widget que envuelve y etiqueta)
    shaders/
    router/
  features/
    projects/
      data/           # LocalContentSource (assets JSON/MD), DTOs, ProjectsRepositoryImpl
      domain/         # Project, ProjectsRepository, GetProjects, GetProjectBySlug
      presentation/   # HomeProjectsGrid, ProjectDetailPage, ProjectCard, state
    experience/       # mismo esquema
    contact/
assets/content/{es,en}/
web/index.html        # loader HTML/CSS + meta/OG tags
```

### Modo arquitectura (cómo implementarlo)

- Un `ArchitectureModeController` global (bool + animación).
- Un widget `LayerBadge(layer:, label:, child:)` envuelve los widgets clave. Con el modo activo, dibuja un borde y una etiqueta con el color de su capa y el nombre real de la clase.
- Las cards de proyecto muestran, desde el contenido, qué clases tiene cada capa de ese proyecto.
- Un link "ver en GitHub" en cada badge, apuntando al archivo real del repo del portfolio.

### Performance

- Deferred imports para el detalle de proyecto y para los shaders.
- Loader en `index.html` mientras carga el engine.
- Imágenes en WebP con tamaños fijos.
- Meta y OG tags estáticos en `index.html`, para que las previews de link se vean bien.

## Fases y tareas

Son 6 fases, cada una con su PR o commit revisable. Al ritmo part-time son entre 6 y 8 semanas.

### Fase 0 — Contenido (Tobias)

- [ ] Textos ES/EN de Fishar, Fundido y Laburito
- [ ] Capturas y videos cortos de cada app
- [ ] Fechas de experiencia, links y CV en PDF
- [ ] Nombres reales de clases para el modo arquitectura

### Fase 1 — Base técnica

- [ ] `flutter create --platforms web`, lints y estructura de carpetas
- [ ] Theme con los tokens, tipografías, go\_router, l10n ES/EN
- [ ] GitHub Actions: analyze + test + build --wasm + deploy de una home vacía
- [ ] README inicial con el diagrama de capas

### Fase 2 — Dominio y datos

- [ ] Entidades Project y Experience, repositorios abstractos y casos de uso
- [ ] LocalContentSource leyendo `assets/content/{locale}/`
- [ ] Unit tests de domain y data

### Fase 3 — Home

- [ ] Nav, hero con planchas flotantes, métricas, marquee
- [ ] Grilla de proyectos, experiencia, contacto
- [ ] Responsive: 360, 768, 1280 y 1440 px
- [ ] Widget y golden tests de las cards

### Fase 4 — Detalle de proyecto

- [ ] ProjectDetailPage con Hero transition desde la card
- [ ] Phone frame con mini demo navegable (Fishar: mapa con spots; Fundido: chat con el cerdito; Laburito: flujo de contratación)
- [ ] "Cómo está hecho": capas + snippet con syntax highlight

### Fase 5 — Diferenciales

- [ ] Modo arquitectura (controller + LayerBadge + grilla de plano)
- [ ] Fragment shader de fondo
- [ ] Rive para el toggle y el cerdito de Fundido

### Fase 6 — Pulido y lanzamiento

- [ ] Loader HTML, deferred imports, WebP
- [ ] Meta y OG tags, favicon, 404
- [ ] Accesibilidad: Semantics, navegación con teclado, reduced motion
- [ ] Dominio propio \[dominio\] y README final con GIFs

## Criterios de aceptación y reglas

- `flutter analyze` sin warnings y todos los tests en verde antes de cerrar cada fase.
- `domain/` es Dart puro: no importa Flutter, Firebase ni nada de `data/`.
- Ningún texto hardcodeado en widgets: todo sale de l10n o del contenido.
- Primera carga usable en menos de 3 s con buena conexión; el loader aparece al instante.
- Se ve bien de 360 a 1440 px, sin scroll horizontal.
- Animaciones a 60 fps en una notebook común; con reduced motion se desactivan.
- Cero información confidencial de ueno bank o itti.
- Commits chicos con mensajes claros: el historial también se muestra.

## Prompt para pegar en Claude

```
Vamos a construir mi portfolio en Flutter Web. Leé PLAN.md completo y las imágenes de docs/mockup/ antes de tocar nada.

Reglas:
- Trabajamos fase por fase según PLAN.md. Arrancá por la Fase 1 y frená al terminarla para que yo revise.
- Antes de codear cada fase, mostrame un plan corto de archivos y decisiones.
- Clean architecture estricta: domain en Dart puro, data implementa los contratos, presentation no conoce data.
- Gestor de estado: [Riverpod/Bloc].
- Corré flutter analyze y flutter test al final de cada fase y arreglá lo que falle.
- Si falta contenido (textos, imágenes, links), dejá placeholders claros y anotalos en TODO.md, no inventes datos.
- Commits chicos y descriptivos.

Empezá con la Fase 1.
```
