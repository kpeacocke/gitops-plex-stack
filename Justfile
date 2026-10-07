deploy:
  docker compose -f stack/docker-compose.yml --env-file stack/.env up -d

validate:
  docker compose --env-file stack/.env.sample -f stack/docker-compose.yml config --quiet

down:
  docker compose -f stack/docker-compose.yml down
