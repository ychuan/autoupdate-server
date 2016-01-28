FROM debian:jessie

RUN apt-get update
RUN apt-get install -y apt-transport-https
RUN apt-get install -y ca-certificates
RUN apt-get install -y bsdiff git curl

ENV PACKAGE_NAME github.com/getlantern/autoupdate-server

ENV WORKDIR /app
RUN mkdir -p $WORKDIR

ENV GO_VERSION go1.5.3

ENV GOROOT /usr/local/go
ENV GOPATH /go
RUN mkdir -p $GOPATH

ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin

ENV GO_PACKAGE_URL https://storage.googleapis.com/golang/$GO_VERSION.linux-amd64.tar.gz
RUN curl -sSL $GO_PACKAGE_URL | tar -xvzf - -C /usr/local

RUN go get github.com/robfig/glock

ENV APPSRC_DIR /go/src/$PACKAGE_NAME
ENV mkdir -p $APPSRC_DIR
COPY ./ $APPSRC_DIR/

RUN cd $APPSRC_DIR && go get -d ./...
RUN glock sync $PACKAGE_NAME
RUN go build -o /bin/autoupdate-server $PACKAGE_NAME

VOLUME [ "/keys", $APPSRC_DIR, $WORKDIR ]

WORKDIR $WORKDIR

ENTRYPOINT ["/bin/autoupdate-server"]

CMD ["-k", "/keys/private.key", "-l", ":9999", "-p", "https://update.getlantern.org/", "-o", "getlantern", "-n", "lantern"]
