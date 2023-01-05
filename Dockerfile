# dockerfile git to push to gitops repo
FROM alpine/git:latest
RUN apk add --no-cache git curl

RUN curl --silent --location --remote-name \
    "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/v3.2.3/kustomize_kustomize.v3.2.3_linux_amd64" && \
    chmod a+x kustomize_kustomize.v3.2.3_linux_amd64 && \
    mv kustomize_kustomize.v3.2.3_linux_amd64 /usr/local/bin/kustomize

ADD entry.sh /entry.sh

RUN chmod +x /entry.sh

ENTRYPOINT [ "sh", "/entry.sh" ]

