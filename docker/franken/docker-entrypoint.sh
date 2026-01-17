#!/bin/sh
set -e


echo "🔧 Preparing The Project... If it breaks, we didn’t see anything 👀🔥"

# Clear stale caches first
php artisan optimize:clear --quiet || true

# Discover packages (autoload rebuild-like step)
php artisan package:discover --quiet --no-ansi

# Build caches
php artisan config:cache --quiet
php artisan route:cache --quiet
php artisan view:cache --quiet
php artisan event:cache --quiet

echo "🔮 Summoning FrankenPHP on port 8000... Please fasten your seatbelts 😈🚀"

exec php /app/artisan octane:frankenphp \
    --host=0.0.0.0 \
    --port=8000 \
    --workers=4 \
    --max-requests=300 \
    --no-interaction \
    --quiet
