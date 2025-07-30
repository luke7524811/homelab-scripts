2025-07-30 - Home Lab Snapshot
==============================

🌐  Network & Access
--------------------
- Router: ASUS RT-BE86U BE6800 WiFi 7
- DNS: Cloudflare (A/CNAME + Cloudflare Tunnels)

🔐  Port Forwarding (only two open ports)
----------------------------------------
| External | Internal Destination | Purpose |
| -------- | ------------------- | ------- |
| 2222     | 192.168.86.77:22    | SSH to ubuntu-node-01 |
| 2223     | 192.168.86.119:22   | SSH to gluster-node-1 |

🧱  Nodes & Roles
-----------------
1. **ubuntu-node-01** – 192.168.86.77  
   - Swarm **manager**, Ansible controller, Cloudflare-tunnel host  
   - Services: Nginx Proxy Manager, Portainer, Vaultwarden, Sonarr, Radarr, SABnzbd, Prowlarr, Overseerr, DumbAssets, Actual, Plex (pinned)  
   - Storage: GlusterFS mounts → `/mnt/gluster/appdata`, `/mnt/gluster/media`  
   - New: **~/homelab-scripts Git repo** (script library) with symlinks in `/usr/local/bin`

2. **gluster-node-1** (renamed from ubuntu-node-02) – 192.168.86.119  
   - Dedicated GlusterFS storage node  
   - Bricks: data1-4 → `gfs_appdata` (replica 2) & `gfs_media` (distributed)

🔻  Pending / Offline Nodes
- ubuntu-node-03 (ex-Plexyglass) – 192.168.86.24 | offline  
- ubuntu-node-04 (ex-Stratosphere; future ubuntu-node-02) – 192.168.86.73 | offline

📦  Docker Swarm Apps (running unless noted)
-------------------------------------------
✅ Nginx Proxy Manager, Portainer, Vaultwarden, Sonarr, Radarr, SABnzbd, Prowlarr, Overseerr, DumbAssets, Actual, Plex  
⚠️ Audiobookshelf (stack ready; pending redeploy), Nextcloud (legacy on Unraid), Moodle/Kimai/EspoCRM/MiniCal (DBs staged), Odoo (planned)

🛠️  Script Library (NEW)
------------------------
- **Repo:** `https://github.com/luke7524811/homelab-scripts`  
- Current scripts: `fix-media-perms.sh`, `deduplicate-files.sh`, `deploy-all-stacks.sh`  
- Symlinks: `/usr/local/bin/fix-media-perms.sh` → repo version, same for `deduplicate-files.sh`  
- `fix-media-perms.sh` still runs nightly via cron (02:00) and writes to `/var/log/fix-media-perms.log`

🔁  Automation
--------------
- Ansible playbook **fix-media.yml** pushes scripts + cron to all nodes  
- Future: add a `snapshot-generator.sh` to commit nightly snapshots into `homelab-scripts/snapshots/`

🧩  Misc Notes
--------------
- All external traffic proxied through Cloudflare Tunnels to NPM (no other open ports).
- Drive 4 now active in Gluster and holds data
- K3s evaluation still planned alongside Swarm (no install yet).


