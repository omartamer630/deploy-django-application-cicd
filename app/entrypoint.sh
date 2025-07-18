#!/bin/sh

# Wait for Postgres to be ready
echo "Waiting for PostgreSQL..."

while ! nc -z "$POSTGRES_HOST" "$POSTGRES_PORT"; do
  sleep 1
done

echo "PostgreSQL is up - continuing..."

echo "Applying database migrations..."
python manage.py migrate

echo "Creating superuser if not exists..."
echo "from django.contrib.auth import get_user_model; \
User = get_user_model(); \
User.objects.filter(username='admin').exists() or \
User.objects.create_superuser('admin', 'admin@example.com', 'adminpass')" | python manage.py shell

echo "Starting server..."
exec python manage.py runserver 0.0.0.0:80
