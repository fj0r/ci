FROM python:alpine

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; apk update && apk upgrade \
  ; rm -rf /var/cache/apk/* \
  ; apk add --no-cache tzdata curl bash \
      jq git openssh-client rsync just \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; pip3 --no-cache-dir install \
      pydantic structlog pyyaml PyParsing \
      requests furl markdown chevron \
      psycopg[binary] kafka-python

