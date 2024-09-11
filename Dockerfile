FROM alpine:3.17

ENV JAVA_VERSION=11 \
    JAVA_HOME="/jre" \
    LANG=C.UTF-8 \
    GLIBC_VERSION=2.35

RUN apk update && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    update-ca-certificates && \
    cd /tmp && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget --quiet https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION-r0/glibc-$GLIBC_VERSION-r1.apk && \
    wget --quiet https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION-r0/glibc-bin-$GLIBC_VERSION-r1.apk && \
    wget --quiet https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION-r0/glibc-i18n-$GLIBC_VERSION-r1.apk && \
    apk add --no-cache \
        glibc-$GLIBC_VERSION-r1.apk \
        glibc-bin-$GLIBC_VERSION-r1.apk \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    cd "/tmp" && \
    mkdir "jre" && \
    wget --quiet https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.tar.gz && \
    tar -xzf "amazon-corretto-21-x64-linux-jdk.tar.gz" --directory "jre" --strip-components=1 && \
    mv "/tmp/jre" "/jre" && \
    rm -rf "/jre/bin/jjs" \
          "/jre/bin/pack200" \
          "/jre/bin/rmid" \
          "/jre/bin/rmiregistry" \
          "/jre/bin/unpack200" \
          "/jre/lib/jfr" && \
    ln -s "$JAVA_HOME/bin/"* "/usr/bin/" && \
    apk add --no-cache iproute2 && \
    rm -rf /tmp/* /var/cache/apk/* /sbin/ip /sbin/tc /sbin/ifstat /usr/bin/scanelf /usr/bin/wget

RUN apk add --no-cache openjdk11-jre

COPY SectigoRSADomainValidationSecureServerCA.crt /usr/local/share/ca-certificates/SectigoRSADomainValidationSecureServerCA.crt.crt

# Add MCP self-signed CA public certificate to TrustStore

ADD mcp-root-ca-2017.crt /tmp
ADD mcp-root-ca-2020.crt /tmp

RUN set -xe; \
    keytool -keystore $JAVA_HOME/lib/security/cacerts -importcert -alias mcp-root-ca -file /tmp/mcp-root-ca-2017.crt -storepass changeit -noprompt; \
    keytool -keystore $JAVA_HOME/lib/security/cacerts -importcert -alias mcp-root-ca-2020 -file /tmp/mcp-root-ca-2020.crt -storepass changeit -noprompt; \
    rm -rf /tmp/*

#ENV LANG=C.UTF-8
