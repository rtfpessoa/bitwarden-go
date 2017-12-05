FROM golang:alpine as build
WORKDIR /build
COPY *.go ./
RUN apk --no-cache --update add git alpine-sdk
RUN go get -d ./...
RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o bitwarden-go .

FROM alpine:latest
LABEL maintainer="rodrigo.fernandes@tecnico.ulisboa.pt"
LABEL version="1.0.0-alpha.1"
ENV LANG C.UTF-8
ENV APP_HOME /app/bitwarden-go
ENV APP_PORT 80
ENV DB_ROOT /bitwarden/db
WORKDIR ${APP_HOME}
COPY --from=build /build/bitwarden-go ${APP_HOME}/
EXPOSE ${APP_PORT}
VOLUME ${DB_ROOT}
CMD ["./bitwarden-go"]
