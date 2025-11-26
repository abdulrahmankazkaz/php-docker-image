#!/bin/sh
set -e


echo "🔧 Preparing The Project... If it breaks, we didn’t see anything 👀🔥"

# Clear stale caches first
frankenphp php-cli artisan optimize:clear --quiet || true

# Discover packages (autoload rebuild-like step)
frankenphp php-cli artisan package:discover --quiet --no-ansi

# Build caches
frankenphp php-cli artisan config:cache --quiet
frankenphp php-cli artisan route:cache --quiet
frankenphp php-cli artisan view:cache --quiet
frankenphp php-cli artisan event:cache --quiet

echo "🔮 Summoning FrankenPHP on port 8000... Please fasten your seatbelts 😈🚀"

exec frankenphp php-cli artisan octane:frankenphp \
    --host=0.0.0.0 \
    --port=8000 \
    --workers=4 \
    --max-requests=300 \
    --no-interaction \
    --quiet
