FROM anapsix/alpine-java:latest

LABEL vendor="Galactic Fog IP, Inc."
LABEL com.galacticfog.version="release-1.2.0"

# Add dependent packages
RUN apk add --update \
    bash \
    curl \
    jq \
    postgresql-client \
    python \
    py-pip \
    ca-certificates && \
    pip install --upgrade pip && \
    pip install httpie httpie-unixsocket && \
    rm -rf /var/cache/apk/*

# Inject gestalt files
COPY ./gestalt /gestalt
COPY ./deps/gestalt-cli.jar /gestalt
RUN chmod 644 /gestalt && chmod +x /gestalt/*.sh && chmod +x /gestalt/gestaltctl

# define entrypoint
ENTRYPOINT ["/gestalt/entrypoint.sh"]

