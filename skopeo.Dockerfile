FROM alpine:3

RUN set -eux \
  ; apk add --no-cache skopeo buildah
