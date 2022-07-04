# Build
FROM python:alpine as build
ENV COMMON_DEPS='libffi-dev curl git linux-headers musl-dev gcc build-base libxml2-dev libxslt-dev' \
    PILLOW_DEPS='freetype-dev fribidi-dev harfbuzz-dev jpeg-dev lcms2-dev libimagequant-dev openjpeg-dev tcl-dev tiff-dev tk-dev zlib-dev' \
    WATCHFILES_DEPS='rust cargo'

# https://github.com/rust-lang/cargo/issues/10230#issuecomment-1120018227
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true

WORKDIR /app
COPY ./ /app/

# Build deps, wheels and store
RUN apk add --no-cache $COMMON_DEPS $PILLOW_DEPS $WATCHFILES_DEPS
RUN pip install -U pip wheel setuptools && \
    # https://github.com/rust-lang/cargo/issues/8172#issuecomment-659066173
    curl -s https://gist.githubusercontent.com/iamrony777/6f3a6e441b4bd9bbd41e5df58b3d161b/raw/9350a9cd07042a2e0f12e0a9c13988c5c84310a7/config >> /app/.git/config && \
    pip wheel --wheel-dir=/app/wheels -r requirements.txt

# Cleanup
FROM python:alpine
WORKDIR /app
COPY --from=build /app/wheels /app/wheels
