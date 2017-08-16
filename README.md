# Up 

Customization in the `bootstrap` service in `docker-compose.yml`

```
docker-compose up --force-recreate --build
```

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
