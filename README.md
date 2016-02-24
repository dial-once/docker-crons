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
