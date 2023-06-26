ARG BASEIMAGE=fj0rd/io:base
FROM ${BASEIMAGE}

#--break-system-packages
ARG PIP_FLAGS=""
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; apt-get update -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      python3 python3-pip \
      git openssh-client \
      build-essential \
      buildah skopeo podman \
  ; ln -sf /usr/bin/python3 /usr/bin/python \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  \
  ; apt-get install -y --no-install-recommends build-essential \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} \
      pydantic structlog pyyaml PyParsing \
      httpx furl markdown chevron \
      ansible kubernetes \
      psycopg[binary] kafka-python \
      pymongo github3.py \
  ; apt-get remove -y build-essential \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; ansible-galaxy collection install ansible.posix \
  ; ansible-galaxy collection install community.docker \
  ; ansible-galaxy collection install community.mongodb \
  ; ansible-galaxy collection install community.mysql \
  ; ansible-galaxy collection install community.postgresql \
  ; ansible-galaxy collection install community.general \
  ; ansible-galaxy collection install community.windows \
  ; ansible-galaxy collection install kubernetes.core \
  \
  ; k8s_ver=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt | cut -c 2-) \
  ; curl -L https://dl.k8s.io/v${k8s_ver}/kubernetes-client-linux-amd64.tar.gz \
      | tar zxf - --strip-components=3 -C /usr/local/bin kubernetes/client/bin/kubectl \
  ; chmod +x /usr/local/bin/kubectl \
  \
  ; helm_ver=$(curl -sSL https://api.github.com/repos/helm/helm/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; curl -L https://get.helm.sh/helm-v${helm_ver}-linux-amd64.tar.gz \
      | tar zxvf - -C /usr/local/bin linux-amd64/helm --strip-components=1 \
  \
  ; istio_ver=$(curl -sSL https://api.github.com/repos/istio/istio/releases/latest | jq -r '.tag_name') \
  ; curl -L https://github.com/istio/istio/releases/latest/download/istioctl-${istio_ver}-linux-amd64.tar.gz \
      | tar zxvf - -C /usr/local/bin istioctl \
  ;
