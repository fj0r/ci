FROM ubuntu:jammy

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; apt-get update -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      tzdata curl \
      python3 python3-pip \
      jq git rsync openssh-client \
      build-essential \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  \
  ; just_url=$(curl -sSL https://api.github.com/repos/casey/just/releases -H 'Accept: application/vnd.github.v3+json' \
             | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; curl -sSL ${just_url} | tar zxf - -C /usr/local/bin just \
  \
  ; apt-get install -y --no-install-recommends build-essential \
  ; pip3 --no-cache-dir install \
      pydantic structlog pyyaml PyParsing \
      httpx markdown chevron \
      ansible \
      psycopg[binary] kafka-python \
  ; apt-get -y remove build-essential \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; k8s_ver=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt | cut -c 2-) \
  ; curl -L https://dl.k8s.io/v${k8s_ver}/kubernetes-client-linux-amd64.tar.gz \
      | tar zxf - --strip-components=3 -C /usr/local/bin kubernetes/client/bin/kubectl \
  ; chmod +x /usr/local/bin/kubectl \
  \
  ; ansible-galaxy collection install amazon.aws \
  ; ansible-galaxy collection install kubernetes.core \
  ;
