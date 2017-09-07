# Up 

Important:  Customize service initialization in `docker-compose.yml`

```
docker-compose up --force-recreate --build
```

# Down 

```
docker service ls -q | xargs docker service rm
docker-compose down
```
