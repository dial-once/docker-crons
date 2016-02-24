# Docker crons

A docker container used to launch crons tasks easily

## Add a cron
Modify the crontab file and place your files into the ``/scripts`` folder

## Sample

``crontab``
```sh
* * * * * root /bin/sh /scripts/hello-world.sh >> /var/log/cron-stdout.log 2>&1
```

``/scripts/hello-world.sh``
```sh
echo "It works!"
```

This will print 'It works!' to the docker output

Script the ``>> /var/log/cron-stdout.log 2>&1`` part in the crontab if you don't want the output to be seen in the container output (credentials, etc.)


## Bundled tools
Each of these can be of course removed from the container if you are not using them, in the Dockerfile.

### AWS CLI

Env vars to set on your container if you use the AWS CLI in your scripts
```sh
AWS_ACCESS_KEY_ID=<AWSaccessKey>
AWS_SECRET_ACCESS_KEY=<AWSsecretKey>
AWS_DEFAULT_REGION=<AWSregion>
``

### Tutum CLI
```sh
TUTUM_USER=<username>
TUTUM_APIKEY=<password>
```

### Docker Cloud CLI
```sh
DOCKERCLOUD_USER=<username>
DOCKERCLOUD_PASS=<password>
```

### Mongodb commands
You can use the ``mongo`` command inside your container as it is installed by default

### MySQL and MariaDB commands
N/A

### Postgres commands
N/A


## Available scripts
N/A
