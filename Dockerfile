FROM golang:1.25-alpine AS builder
RUN apk add --no-cache git
WORKDIR /src
RUN git clone --depth 1 https://github.com/katiem0/gh-migrate-rulesets .
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/gh-migrate-rulesets .

FROM alpine:3.20
RUN apk add --no-cache bash coreutils jq github-cli ca-certificates
COPY --from=builder /out/gh-migrate-rulesets /usr/local/bin/gh-migrate-rulesets
RUN chmod +x /usr/local/bin/gh-migrate-rulesets \
 && gh --version
ENTRYPOINT ["/bin/sh","-lc"]
