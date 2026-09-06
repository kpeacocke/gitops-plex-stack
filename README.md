# 🛠️ GitOps Plex Stack

This repository contains a secure, maintainable Docker Compose stack to deploy [Plex Media Server](https://www.plex.tv) using GitOps best practices on Synology NAS.

---

## 🚀 Features

- 🎬 **Plex Media Server** with hardware transcoding (Intel Quick Sync)
- 🔒 **Secure configuration** with `.env` file (never commit secrets)
- 🔁 **GitOps-ready** deployment via Portainer Git stack sync
- ⚡ **Resource limits** configured for Synology DS920+ (20GB RAM)
- 📊 **Health monitoring** with automated healthchecks
- 🧱 **Modular structure** for easy expansion
- 🧪 **Justfile** for CLI automation
- 🔐 **Branch protection** and pre-commit linting

---

## 🧰 Prerequisites

- **Synology NAS** (DS920+ or similar with Intel CPU for hardware transcoding)
- **Docker** and **Docker Compose** installed
- **Portainer** (optional, for web-based management)
- **direnv** and **just** (for local development)

-

The stack is fully configurable via environment variables:

### Required Variables

\`\`\`bash

#### Plex Paths

PLEX_CONFIG_PATH=/volume1/dkrcfg/plex    # Plex config directory
PLEX_TV_PATH=/volume1/TV                  # TV shows library
PLEX_MOVIES_PATH=/volume1/Movies          # Movies library

#### User/Group IDs (match your NAS user)

PUID=1027                                 # User ID
PGID=100                                  # Group ID
TZ=Australia/Sydney                       # Timezone
\`\`\`

#### Resource Limits (Tuned for DS920+)

\`\`\`bash
PLEX_CPU_LIMIT=3                          # Max 3 of 4 cores
PLEX_CPU_RESERVATION=1                    # Reserve 1 core
PLEX_MEMORY_LIMIT=4G                      # Max 4GB RAM
PLEX_MEMORY_RESERVATION=1G                # Reserve 1GB RAM
PLEX_TRANSCODE_SIZE=2g                    # tmpfs for transcoding (2GB)
\`\`\`

**Total RAM usage:** ~6GB (4GB container + 2GB tmpfs), leaving 14GB for DSM and caching.

---

## 🛠️ Setup

1. **Clone the repository:**

   \`\`\`bash
   git clone <https://github.com/kpeacocke/gitops-plex-stack.git>
   cd gitops-plex-stack
   \`\`\`

2. **Configure environment:**

   \`\`\`bash

   ## Copy sample env file

   cp stack/.env.sample stack/.env

   ## Edit with your paths and settings

   nano stack/.env
   \`\`\`

3. **Ensure proper permissions:**

   \`\`\`bash

   ## Verify ownership of media directories matches PUID:PGID

   chown -R 1027:100 /volume1/dkrcfg/plex
   \`\`\`

4. **Deploy:**

   Via Portainer (recommended):
   - Add a new stack from Git repository
   - Poto \`stack/docker-compose.yml\`
   - Configure env file in Portainer UI

   Or locally:
   \`\`\`bash
   cd stack
   docker-compose up -d
   \`\`\`

---

## 🧪 Local Development

\`\`\`bash

### Install tools

direnv allow
pip install pre-commit
pre-commit install

### Validate stack

just validate

### Deploy locally

just deploy

### View logs

just logs

### Tear down

just down
\`\`\`

---

## 🔄 GitOps Workflow

All changes must go through Pull Requests:

\`\`\`text
feature/* → Pull Request → main → Auto-deploy via Portainer
\`\`\`

🚫 Direct commits to \`main\` are blocked by branch protection.

---

## Backups

Back up `PLEX_CONFIG_PATH` daily with Synology Hyper Backup and snapshots. Do
not back up `PLEX_TRANSCODE_PATH`; it is disposable working data. See
[`BACKUPS.md`](BACKUPS.md) for the restore contract and quarterly test.

## 🏗️ Stack Details

### Plex Media Server

- **Image:** \`lscr.io/linuxserv
- **Network:** Host mode (required for discovery/DLNA)
- **Hardware Transcoding:** Intel Quick Sync via \`/dev/dri\`
- **Transcode Directory:** tmpfs (RAM-based) for performance
- **Health Check:** API endpoint monitoring every 30s
- **Logging:** Rotated JSON logs (10MB × 3 files)

### Ports (Exposed via Host Network)

- \`32400\` - Plex Web UI
- \`1900\` - DLNA
- \`5353\` - Bonjour/Avahi
- \`8324\` - Plex Companion
- \`32410-32414\` - GDM network discovery
- \`32469\` - Plex DLNA Server

---

## 📋 File Structure

\`\`\`text
gitops-plex-stack/
├── stack/
│   ├── docker-compose.yml      # Main compose file
│   ├── .env                    # Local config (gitignored)
│   └── .env.sample            workflows/              # CI/CD pipelines
│   └── instructions/           # Coding guidelines
├── Justfile                    # Task automation
├── .pre-commit-config.yaml     # Code quality hooks
├── .envrc                      # direnv config
└── README.md                   # This file
\`\`\`

---

## 🔧 Troubleshooting

### Hardware Transcoding Not Working

- Verify \`/dev/dri\` exists: \`ls -l /dev/dri\`
- Check permissions: device should be accessible to PUID

### Out of Memory Issues

- Reduce \`PLEX_MEMORY_LIMIT\` and \`PLEX_TRANSCODE_SIZE\`
- Monitor with: \`docker stats plex\`

### Permission Denied Errors

- Ensure PUID/PGID match ownership of volume paths/plex\`

---

## 📄 License

This project is licensed under the [MIT License](./LICENSE).

---

## 🛡️ Security

Please review [SECURITY.md](./SECURITY.md) and report concerns to [krpeacocke@gmail.com](mailto:krpeacocke@gmail.com)

---
