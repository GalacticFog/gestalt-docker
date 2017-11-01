# Up 

1. Clone this repo.  
2. Customize service initialization by editing `docker-compose.yml`  
 IMPORTANT: Be sure to change password defaults, etc. 
3. Launch the platform with  `docker-compose up --force-recreate`

After you see the message  `gestaltdocker_bootstrap_1 exited with code 0`  you should be able to log in at http://localhost/login.
If this fails run 'docker ps' and check to see which port galacticfog/gestalt-ui-react container is bound to.  


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
