# vim:set ft=dockerfile:
FROM postgres:9.4-alpine

COPY gestalt.sh /docker-entrypoint-initdb.d/gestalt.sh
RUN  chmod +x   /docker-entrypoint-initdb.d/gestalt.sh
