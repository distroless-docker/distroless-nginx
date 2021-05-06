FROM ubuntu:20.04 as builder

RUN mkdir /work && mkdir /work/sources && mkdir /work/debs
WORKDIR /work

RUN echo "deb-src http://security.ubuntu.com/ubuntu focal-security main restricted" >> /etc/apt/sources.list \
    && echo "deb-src http://security.ubuntu.com/ubuntu focal-security universe" >> /etc/apt/sources.list \
    && echo "deb-src http://security.ubuntu.com/ubuntu focal-security multiverse" >> /etc/apt/sources.list \
    && echo "deb-src http://archive.ubuntu.com/ubuntu/ focal main restricted" >> /etc/apt/sources.list \
    && echo "deb-src http://archive.ubuntu.com/ubuntu/ focal-updates main restricted" >> /etc/apt/sources.list \
    && echo "deb-src http://archive.ubuntu.com/ubuntu/ focal universe" >> /etc/apt/sources.list \
    && echo "deb-src http://archive.ubuntu.com/ubuntu/ focal-updates universe" >> /etc/apt/sources.list \
    && echo "deb-src http://archive.ubuntu.com/ubuntu/ focal multiverse" >> /etc/apt/sources.list \
    && echo "deb-src http://archive.ubuntu.com/ubuntu/ focal-updates multiverse" >> /etc/apt/sources.list \
    && echo "deb-src http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list

RUN apt-get update && apt-get -y install \
    wget \
    && rm -rf /var/lib/apt/lists/*
    
ENV PKG=nginx=1.18.0-0ubuntu1
RUN apt-get update && \
    for f in $(apt-cache depends $PKG -qq --recurse --no-pre-depends --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances | sed 's/.*: .*//' | sed 's/.*:.*//' | sed 's/<.*>//' | sed -e 's/^[ \t]*//' | sort --unique); do echo $(apt-get -y install --print-uris --reinstall --no-install-recommends $f |  grep -E 'https://|http://' | tr -d "'" | awk '{print$1}'); done > packages && \
    cat packages | sed 's/ /\n/g' | sort --unique | wget -i - \
    && rm -rf /var/lib/apt/lists/* \
    && for f in ./*.deb; do dpkg -x $f out; done \
    && for f in ./*.deb; do cp $f debs/; done \
    && rm -rf *.deb
RUN apt-get update && \
    for f in $(apt-cache depends $PKG -qq --recurse --no-pre-depends --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances | sed 's/.*: .*//' | sed 's/.*:.*//' | sed 's/<.*>//' | sed -e 's/^[ \t]*//' | sort --unique); do echo $(apt-get source --print-uris $f |  grep -E 'https://|http://' | tr -d "'" | awk '{print$1}'); done > packages && \
    cat packages | sed 's/ /\n/g' | sort --unique | wget -P sources/ -i - || true \
    && rm -rf /var/lib/apt/lists/*
        
RUN mkdir licenses && for f in $(find /work/out/usr/share/doc/*/copyright -type f); do cp $f licenses/$(basename $(dirname $f))-$(find /work/debs | grep $(basename $(dirname $f)) | awk -F_ '{print $2}' | sed "s/-/_/"); done

RUN addgroup --system --gid 101 nginx
RUN adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false --uid 101 nginx
RUN mkdir -p /run/nginx

FROM scratch as image-sources
COPY --from=builder /work/sources /

FROM scratch as image-temp

COPY --from=builder /etc/passwd /etc/group /etc/
COPY --from=builder /run/nginx /run/nginx

COPY --from=builder /work/out /
COPY --from=builder /work/licenses /licenses

COPY html /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/nginx.conf

FROM scratch as image-final

COPY --from=image-temp / /

EXPOSE 80

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
