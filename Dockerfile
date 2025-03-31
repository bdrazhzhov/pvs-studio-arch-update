FROM docker.io/library/alpine AS base

FROM base AS build-pacman
RUN apk add --no-cache build-base git meson cmake bash libarchive-dev gcompat curl-dev
RUN cd /tmp && git clone --depth 1 https://gitlab.archlinux.org/pacman/pacman.git

WORKDIR /tmp/pacman
RUN meson setup build --prefix=/ --buildtype=plain -Di18n=false
RUN meson compile -C build
RUN meson install -C build --destdir /tmp/pacman-install

FROM base AS build-app

RUN apk add --no-cache crystal shards openssl-dev make yaml-dev

WORKDIR /app
COPY shard.lock shard.yml ./
COPY src /app/src

RUN shards install --production
RUN shards build --release --no-debug && strip bin/pvs-studio-arch-update

FROM base
COPY --from=build-pacman /tmp/pacman-install /
COPY --from=build-app /app/bin/pvs-studio-arch-update /bin

RUN apk add --no-cache bash coreutils fakeroot file gpg ncurses xz curl \
    libarchive-tools libarchive binutils pcre2 gc libevent zstd

RUN addgroup --system --gid 1000 builder && \
    adduser builder --uid 1000 -G builder --disabled-password --shell /bin/sh
RUN chmod 777 /var/lib/pacman

USER 1000:1000

COPY docker-entrypoint.sh ./

VOLUME ["/tmp/output"]
VOLUME ["/tmp/repo"]

ENV CARCH=x86_64
ENV PACKAGER="Boris Drazhzhov <bdrazhzhov@gmail.com>"
ENV PKGEXT='.pkg.tar.zst'

ENTRYPOINT ["/docker-entrypoint.sh"]
