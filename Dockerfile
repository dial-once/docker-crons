FROM debian:jessie

RUN \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
  apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 && \
  echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list && \
  echo "deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list && \
  apt-get update && \
  apt-get install -y ca-certificates curl cron mongodb-org-tools rsyslog python-pip mariadb-client postgresql-client-9.5 openssh-client expect && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  pip install tutum awscli docker-cloud

COPY crontab /etc/cron.d/backup-cron
RUN chmod 0644 /etc/cron.d/backup-cron && \
  touch /var/log/syslog

COPY scripts /scripts
RUN touch /var/log/cron-stdout.log

CMD env > /root/env && sed -i '/GPG_KEYS/d' /root/env && sed -i '/no_proxy/d' /root/env && sed -i -e 's/^/export /' /root/env && chmod +x /root/env && rsyslogd && cron && tail -F /var/log/syslog /var/log/cron-stdout.log
