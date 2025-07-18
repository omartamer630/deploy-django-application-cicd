#!/bin/sh

echo "Applying database migrations..."
python manage.py migrate

echo "Creating superuser if not exists..."
echo "from django.contrib.auth import get_user_model; \
User = get_user_model(); \
User.objects.filter(username='admin').exists() or \
User.objects.create_superuser('admin', 'admin@example.com', 'adminpass')" | python manage.py shell

echo "Starting server..."
exec gunicorn hello_world_django_app.wsgi:application --bind 0.0.0.0:80
