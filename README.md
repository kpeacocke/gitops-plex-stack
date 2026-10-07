# GitOps Plex stack

Plex Media Server on the Synology NAS, deployed from this repository through
Portainer. Changes go through a pull request to `main`.

## Actual deployment

- LinuxServer Plex image, `latest` tag, with `VERSION=latest`.
- Automatic updates are intentionally retained, including the Watchtower opt-in.
  Plex may update its application at container startup, so its running version
  can differ from the container image build label. Record both when diagnosing
  problems or planning rollback; an old image alone does not guarantee rollback.
- Host networking, Intel Quick Sync device access through `/dev/dri`.
- TV and movies mounted at `/data/media/TV` and `/data/media/Movies`.
- Persistent configuration at `/config`; writable media supports Plex deletion.
- Disk-backed transcode directory at `/transcode`, not a RAM filesystem.
- No explicit container CPU or memory limits. Select limits only after measuring
  real playback and background-task demand alongside the DVR stack.
- Local `/identity` health check, rotated Docker logs and `unless-stopped` restart.
  A healthy identity endpoint does not prove playback, scanning or transcoding.

## Configuration

Copy `stack/.env.sample` to an untracked `stack/.env` for local deployment, or
supply the same variables in Portainer. Keep credentials out of Git.

| Variable | Purpose |
| --- | --- |
| `PLEX_CONFIG_PATH` | Persistent Plex configuration and databases |
| `PLEX_TV_PATH` | Existing TV shared folder |
| `PLEX_MOVIES_PATH` | Existing movie shared folder |
| `PLEX_TRANSCODE_PATH` | Disposable transcode working directory |
| `PUID`, `PGID` | NAS service-user identity |
| `TZ` | Local timezone |

Validate without production credentials:

```sh
docker compose --env-file stack/.env.sample -f stack/docker-compose.yml config --quiet
pre-commit run --all-files
```

Deploy locally only when intentionally targeting the correct Docker host:

```sh
docker compose --env-file stack/.env -f stack/docker-compose.yml up -d
```

## Deployment verification

CI validates the Compose file with the non-secret sample environment. The
Portainer webhook step fails on HTTP errors, but acceptance is not proof of a
completed deployment. This repository currently has only a webhook credential;
automated Portainer inspection requires a separately provisioned credential.
After deployment verify:

1. Portainer identifies the intended Git revision and container image.
2. Container health is healthy, without a restart loop or OOM event.
3. The local library API returns the expected TV/movie locations.
4. Record the live Plex version from `/identity`, including startup self-updates.
5. A representative client can play media; test a forced hardware transcode
   when a change affects GPU, drivers, permissions or transcoder settings.

Do not print Plex tokens or full preference files in logs.

## Library changes

Disable automatic library-trash emptying before changing mounts. Keep download
staging outside scanned library paths or explicitly excluded. Verify the library
and representative playback before deciding whether to remove missing entries.
Never use a broad recursive ownership change to address a single permission fault.

## Recovery

Follow [BACKUPS.md](BACKUPS.md). Preserve configuration and databases off the NAS;
exclude disposable transcode data, even when its host directory sits beside
configuration. Media needs a separate protection policy. Local database backups
alone do not prove recoverability. Record an isolated restore drill, including
server identity and playback, before major storage changes.
