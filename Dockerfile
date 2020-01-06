FROM alpine:3.11

ENV CONFIG_FLAGS='--fully-static --without-etw --without-npm --without-inspector --without-dtrace --without-intl --enable-lto'

RUN export NODE_VERSION=$(wget -O - -q https://nodejs.org/download/nightly/ | grep -o -E '(v14\.0\.0-nightly[A-Za-z0-9]+)' | tail -1) \
  && echo $NODE_VERSION \
  && wget https://nodejs.org/download/nightly/$NODE_VERSION/node-$NODE_VERSION.tar.xz \
  && apk add --no-cache \
        libstdc++ \
  && apk add --no-cache --virtual .build-deps-full \
        binutils-gold \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python \
    && tar -xf "node-$NODE_VERSION.tar.xz" \
    && cd "node-$NODE_VERSION" \
    && export CXXFLAGS="-O3 -ffunction-sections -fdata-sections" \
    && export LDFLAGS="-Wl,--gc-sections,--strip-all" \
    && ./configure ${CONFIG_FLAGS} \
    && make -j$(getconf _NPROCESSORS_ONLN) V=

FROM scratch
COPY --from=builder node-v*/out/Release/node /bin/node