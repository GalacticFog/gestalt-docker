# Up 

1. Clone this repo.  
2. Customize service initialization by `vi docker-compose.yml`. IMPORTANT: Be sure to change password defaults, etc. 
3. Start system by with command:  
```
docker-compose up --force-recreate --build
```

After you see the message `gestaltdocker_bootstrap_1 exited with code 0` you should be able to point your browser at: http://localhost and login with the credential set in the
`docker-compose.yml` file (`ADMIN_USERNAME` and `ADMIN_PASSWORD`, set to `root:root` by default).

If this fails, run `docker ps` and check to see which port the `gestaltdocker_ui_1` container is bound to.  

# Down 

```
docker service ls -q | xargs docker service rm
docker-compose down
```

# Meta developer mode

For local meta dev, modify the `docker-compose-metadev.yml` and `localmeta.rc` file to include your IP address.

Source `localmeta.rc` and run meta. Then start the stack with:
```
docker-compose -f ./docker-compose-metadev.yml up --force-recreate --build
```
