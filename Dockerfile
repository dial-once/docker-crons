FROM debian:jessie

RUN \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 && \
  echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list && \
  apt-get update && \
  apt-get install -y vim cron mongodb-org-shell rsyslog python-pip && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
  pip install tutum awscli docker-cloud

ADD crontab /etc/cron.d/backup-cron
RUN chmod 0644 /etc/cron.d/backup-cron && \
  touch /var/log/syslog

COPY scripts /scripts
RUN touch /var/log/cron-stdout.log

CMD rsyslogd && cron && tail -F /var/log/syslog /var/log/cron-stdout.log