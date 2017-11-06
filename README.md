# Requirements

The Gestalt CaaS adapter uses components of the Docker remote API that are only available in Swarm mode. However, the composition contained here assumes that the local machine is part of the
swarm, in order to have predictable addressing. This assumption will be relaxed in later versions, but it serves the current "developer laptop" use case. Therefore, it is recommended
that this composition is used on "swarms of one". 

If you would like assistance evaluating the Gestalt platform using Docker Swarm, please contact us in [Slack](https://chat.galacticfog.com)
or from the `Contact Us` link [on our webpage](http://www.galacticfog.com).

# Up 

1. Clone this repo:
```
git clone https://github.com/GalacticFog/gestalt-docker.git
```
2. Customize service initialization using the variables at the bottom of the `docker-compose.yml` file. IMPORTANT: Be sure to change password defaults, especially if deploying to a publically visible machine.
3. Start the system with the command:  
```
docker-compose pull
docker-compose up --force-recreate --build
```

After you see the message `gestaltdocker_bootstrap_1 exited with code 0` you should be able to point your browser at http://localhost and log in with the credential set in the
`docker-compose.yml` file (`ADMIN_USERNAME` and `ADMIN_PASSWORD`, set to `root:root` by default).

# Down 

Because the Gestalt platform deploys services outside of docker-compose, these must be removed manually.

The core platform services can be stopped like so:
```
docker-compose down
```

# Meta developer mode

For local meta dev, modify the `docker-compose-metadev.yml` and `localmeta.rc` file to include your IP address.

Source `localmeta.rc` and run meta. Then start the stack with:
```
docker-compose -f ./docker-compose-metadev.yml up --force-recreate --build
```
