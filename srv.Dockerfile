FROM python:alpine

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; apk update && apk upgrade \
  ; rm -rf /var/cache/apk/* \
  ; apk add --no-cache tzdata bash \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; pip3 install --no-cache-dir --prefix=/usr \
      pydantic \
      fastapi uvicorn httpx aiofile \
      PyParsing decorator more-itertools \
      typer structlog pyyaml cachetools chronyk \
      psycopg[binary] kafka-python

WORKDIR /app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "3000"]


