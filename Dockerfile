# Шаг 1: Используем базовый образ
FROM ubuntu:latest

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /app

# Установка таймзоны в UTC
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Шаг 2: Устанавливаем необходимые пакеты и зависимости
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    postgresql \
    nginx

# Шаг 3: Копируем проект Django в контейнер
COPY . /app

# Шаг 4: Устанавливаем зависимости Python
RUN pip3 install -r /app/requirements.txt

# Выполняем команды внутри виртуального окружения
RUN /app/venv/bin/python -m pip install --upgrade pip && \
    service postgresql start && \
    su - postgres -c "createuser -s mydbuser" && \
    su - postgres -c "createdb mydatabase" && \
    su - postgres -c "psql -c \"ALTER USER mydbuser WITH PASSWORD 'mypassword';\"" && \
    cd /app/ && \
    /app/venv/bin/python manage.py migrate


# Копирование файла настроек Django
COPY ./e4project/settings.py /app/e4project/settings.py


# Шаг 6: Конфигурируем Nginx
COPY nginx.conf /etc/nginx/sites-available/default

# Экспозиция портов
EXPOSE 80 8000 5432 8080

# Шаг 7: Запускаем приложение
CMD service postgresql start && \
    service nginx start && \
    cd /app && \
    python3 manage.py runserver 0.0.0.0:8000

