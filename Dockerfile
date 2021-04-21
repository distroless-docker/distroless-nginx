FROM ubuntu:20.04 as builder

RUN mkdir /work && mkdir /work/sources && mkdir /work/debs
WORKDIR /work

RUN echo "deb-src http://security.ubuntu.com/ubuntu focal-security main restricted" >> /etc/apt/sources.list \
    && echo "deb-src http://security.ubuntu.com/ubuntu focal-security universe" >> /etc/apt/sources.list \
    && echo "deb-src http://security.ubuntu.com/ubuntu focal-security multiverse" >> /etc/apt/sources.list

RUN apt-get update && apt-get -y install \
    wget \
    && rm -rf /var/lib/apt/lists/*
    
ENV PKG=nginx
RUN apt-get update && \
    for f in $(apt-cache depends $PKG -qq --recurse --no-pre-depends --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances | sed 's/.*: //' | sort --unique); do wget $(apt-get install --reinstall --print-uris -qq $f | cut -d"'" -f2); done \
    && rm -rf /var/lib/apt/lists/* \
    && for f in ./*.deb; do dpkg -x $f out; done \
    && for f in ./*.deb; do cp $f debs/; done \
    && rm -rf *.deb
    
RUN apt-get update && \
    apt-get source --print-uris -qq gcc-8-base | cut -d"'" -f2 && \
    for f in $(apt-cache depends $PKG -qq --recurse --no-pre-depends --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances | sed 's/.*: //' | sort --unique); do echo $(apt-get source --print-uris -qq $f | cut -d"'" -f2) && wget $(apt-get source --print-uris -qq $f | cut -d"'" -f2) -P sources/ || true; done \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf *.tar.xz && rm -rf *.dsc
        
RUN mkdir licenses && for f in $(find /work/out/usr/share/doc/*/copyright -type f); do cp $f licenses/$(basename $(dirname $f)); done

RUN addgroup --system --gid 101 nginx
RUN adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx
RUN mkdir -p /run/nginx

FROM scratch as image-temp

COPY --from=builder /etc/passwd /etc/group /etc/
COPY --from=builder /run/nginx /run/nginx

COPY html /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf

COPY --from=builder /work/out /
COPY --from=builder /work/licenses /licenses

FROM scratch as image-final

COPY --from=image-temp / /

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
