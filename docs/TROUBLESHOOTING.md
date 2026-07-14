# Troubleshooting

## MySQL: both password variables are set

Error:

```text
Both MYSQL_ROOT_PASSWORD and MYSQL_ROOT_PASSWORD_FILE are set
```

The database image still contains an old `ENV MYSQL_ROOT_PASSWORD=...` instruction. Rebuild it using `docker/mysql/Dockerfile` without cache:

```bash
sudo docker compose down
sudo docker compose build --no-cache db01
sudo docker compose up -d db01
```

## Application secret permission denied

Error:

```text
/run/secrets/app_properties (Permission denied)
```

Apply the expected ownership and recreate the application container:

```bash
sudo chown root:10001 secrets/app_properties
sudo chmod 0440 secrets/app_properties
sudo docker compose up -d --no-deps --force-recreate app
```

Test readability without printing the secret:

```bash
sudo docker compose run --rm --no-deps --entrypoint /bin/sh app -c '
  id
  ls -ln /run/secrets/app_properties
  test -r /run/secrets/app_properties && echo readable
'
```

## `jar: not found` while building the app image

The final Tomcat JRE image does not include the JDK `jar` utility. The provided Dockerfile extracts the WAR in the Maven build stage and copies the extracted application into the final image.

## MySQL volume was initialized with old credentials

MySQL initialization variables and SQL files run only when the data directory is empty. For a disposable lab only:

```bash
sudo ./scripts/reset-lab.sh
sudo ./scripts/deploy.sh
```

This permanently deletes all application data.

## Application is unreachable through the ALB

Check:

```bash
sudo docker compose ps
sudo docker compose logs --tail=100 app
curl -I http://127.0.0.1:8080/
```

Then confirm:

- Target group port is `8080`.
- Health check success matcher allows `200-399`.
- EC2 security group permits `8080` from the ALB security group.
- `APP_BIND_IP` matches the EC2 private IP.
