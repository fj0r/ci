FROM fj0rd/ci

RUN set -eux \
  ; apk add --no-cache buildah skopeo
