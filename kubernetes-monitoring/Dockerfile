# Используем официальный образ Nginx
FROM nginx:alpine

# Копируем настройки Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Установим необходимые инструменты
RUN apk add --no-cache curl

# Порт для экспорта метрик
EXPOSE 8080

# Docker Healthcheck для мониторинга состояния Nginx
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:80/ || exit 1