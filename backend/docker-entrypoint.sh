#!/usr/bin/env bash
set -e

# load env file if present
if [ -f /.env ]; then
  export $(cat /.env | xargs)
fi

# Wait for Postgres to be ready (simple retry loop)
attempts=0
until python - <<PYCODE
import sys, time
import psycopg2
try:
    conn = psycopg2.connect(
      host="postgres",
      database="${POSTGRES_DB:-loghub}",
      user="${POSTGRES_USER:-loghub}",
      password="${POSTGRES_PASSWORD:-loghubpass}"
    )
    conn.close()
except Exception as e:
    sys.exit(1)
sys.exit(0)
PYCODE
do
  attempts=$((attempts+1))
  echo "Waiting for postgres... ($attempts)"
  sleep 2
  if [ $attempts -gt 30 ]; then
    echo "Postgres did not become ready, exiting"
    exit 1
  fi
done

# Run migrations and collectstatic (dev safe)
python manage.py migrate --noinput
python manage.py collectstatic --noinput || true

# Start dev server (change to gunicorn if you want prod)
exec gunicorn loghub.wsgi:application -w 2 -b 0.0.0.0:8000
