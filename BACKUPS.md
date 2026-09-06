# Plex Backup and Restore Contract

## Protected data

- Source: `${PLEX_CONFIG_PATH}` (`/volume1/dkrcfg/plex` by default).
- Schedule: daily with Synology Hyper Backup, plus filesystem snapshots where
  supported.
- Destination: encrypted storage outside this NAS.
- Retention: at least 30 daily, 12 monthly, and 3 yearly versions.
- Integrity: enable backup integrity checks and failure notifications.

Do not back up `${PLEX_TRANSCODE_PATH}`. Transcode files are temporary and do
not participate in recovery. Media libraries are outside this configuration
backup contract and need their own protection policy.

## Consistent restore

1. Stop the Plex container.
2. Restore `${PLEX_CONFIG_PATH}` to a temporary directory first.
3. Preserve ownership, permissions, hidden files, and symlinks.
4. Replace the live config only after the restored SQLite databases pass an
   integrity check.
5. Start Plex and verify the server identity, libraries, users, and playback.

Perform and record this restore drill quarterly.
