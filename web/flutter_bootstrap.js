{{flutter_js}}
{{flutter_build_config}}

// Flutter's default bootstrap registers its (deprecated) service worker and
// waits up to 4 s for it to activate before loading the engine: on a first
// visit that was most of the load time. Hosting already caches the assets,
// so the site runs without one, and drops any worker a previous version
// installed.
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then(function (registrations) {
    registrations.forEach(function (registration) {
      registration.unregister();
    });
  });
}

_flutter.loader.load();
