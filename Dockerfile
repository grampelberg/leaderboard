FROM python:3-alpine as base

FROM base as builder

WORKDIR /install

RUN apk add --no-cache build-base

COPY requirements.txt ./
RUN pip install \
  --no-cache-dir \
  --install-option="--prefix=/install" \
  -r requirements.txt

FROM base

WORKDIR /code

COPY --from=builder /install /usr/local
COPY . .
