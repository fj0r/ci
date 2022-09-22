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
  ; apk add --no-cache --virtual .build-deps \
      build-base make coreutils \
  ; pip3 --no-cache-dir install \
      pydantic structlog pyyaml PyParsing \
      httpx markdown chevron \
      ansible psycopg[binary] kafka-python \
  ; pip3 --no-cache-dir install git+https://github.com/couler-proj/couler --ignore-installed \
  ; apk del .build-deps \
  ; rm -rf /var/cache/apk/*

