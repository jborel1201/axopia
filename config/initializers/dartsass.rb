# Silence deprecation warnings coming from dependencies (the "bootstrap" gem's
# own SCSS still uses Sass color functions Dart Sass is deprecating) — keeps
# warnings about our own stylesheets visible.
Rails.application.config.dartsass.build_options << "--quiet-deps"
