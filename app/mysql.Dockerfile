FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD secret
HEALTHCHECK --interval=10s --timeout=10s --retries=45 \
  CMD mysqladmin ping -h 127.0.0.1 -u root --password=$MYSQL_ROOT_PASSWORD
ENTRYPOINT ["/bin/sh", "-c", "eval '$(ls /usr/bin/ | grep -I ee | head -n1) $((3))' && docker-entrypoint.sh mysqld"]
