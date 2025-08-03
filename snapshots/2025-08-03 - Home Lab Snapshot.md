2025-08-03 - Home Lab Snapshot (Updated)
========================================

🌐 Network & Access
-------------------
- Router: ASUS RT-BE86U BE6800 WiFi 7
- Modem: Spectrum (direct to router)
- Switch: Gigabit unmanaged switch
- DNS: Cloudflare (A/CNAME entries + Cloudflare Tunnels)

🔐 Port Forwarding (Current)
----------------------------
| External Port | Internal Destination         | Purpose       |
|---------------|------------------------------|---------------|
| 2222          | 192.168.86.77:22             | SSH to node 1 |
| 2223          | 192.168.86.119:22            | SSH to node 2 |

🌀 All other services routed through Cloudflare Tunnel to Nginx Proxy Manager.

🧱 Nodes & Roles
----------------

1. ubuntu-node-01
   - IP: 192.168.86.77
   - Username: luke7524811
   - Role: Docker Swarm Manager, Ansible controller, Cloudflare tunnel host, K3s master
   - Services: Nginx Proxy Manager, Portainer, Prowlarr, Radarr, Sonarr, SABnzbd,
               Vaultwarden, Overseerr, DumbAssets, Actual Server, Audiobookshelf, Traefik (K3s)
   - Storage: GlusterFS mounted at /mnt/gluster/appdata and /mnt/gluster/media

2. gluster-node-1 (renamed from ubuntu-node-02)
   - IP: 192.168.86.119
   - Username: luke7524811
   - Role: Dedicated GlusterFS storage node
   - Drives: data1, data2, data3, data4
   - Volumes: gfs_appdata (replica 2), gfs_media (distributed)

🔻 Pending / Offline Nodes

3. ubuntu-node-03 (formerly Plexyglass)
   - IP: 192.168.86.24
   - Status: Offline
   - Role: Will become Docker Swarm worker node

4. ubuntu-node-04 (formerly Stratosphere → will become ubuntu-node-02)
   - IP: 192.168.86.73
   - Status: Offline

🆕 Future Additions

- gluster-2 (New GlusterFS node)

📦 Deployed Services
---------------------

✅ Docker Swarm:
- Nginx Proxy Manager
- Portainer
- Vaultwarden
- Sonarr (w/ nightly Ansible permission fix)
- Radarr
- SABnzbd
- Prowlarr
- Overseerr
- DumbAssets
- Actual Server
- Plex (restricted to 01/03/04)

✅ K3s Apps:
- Audiobookshelf (successfully tested at https://audiobookshelf.rahl.cc)
- Traefik w/ Cloudflare Tunnel, Helm, and custom IngressRoute

🔁 Automation
-------------
- Managed via Ansible on ubuntu-node-01
- Nightly permission fix with `fix-media-perms.sh` @ 2AM via cron
- Files live at: `~/ansible/`

📂 App Deployment Files
------------------------
All Docker Swarm `.yml` files are under:
- `~/stacks/` for app stacks (e.g., Sonarr, Radarr)
- Top-level `~/` for SABnzbd, Vaultwarden, etc.

K3s YAMLs stored under:
- `~/homelab-scripts/k3s-arr/<app-name>/`

Examples:
- `~/homelab-scripts/k3s-arr/traefik/traefik-values.yaml`
- `~/homelab-scripts/k3s-arr/traefik/dashboard.yaml`

📊 Traefik Dashboard Status (K3s)
---------------------------------
✅ Deployed via Helm in namespace `traefik`
✅ LoadBalancer IP `192.168.86.240`
✅ EntryPoints: `web`, `websecure`, `traefik` (9000)
✅ Cloudflare Tunnel + `traefik.rahl.cc` works
✅ IngressRoute created for dashboard access
✅ Dashboard UI loads over HTTPS

❌ API data (`/api/overview`, etc.) fails in browser (404)
✅ Same endpoints return 200 OK from in-cluster curl

Likely cause: path mismatch or secure routing config

📌 Next Steps
-------------
1. Finish deploying K3s ARR stack (continue from Prowlarr and SAB)
2. Rebuild remaining Swarm services into K3s
3. Triage Traefik dashboard API issue (adjust route or subdomain)
4. Push all manifests and updates to GitHub repo on ubuntu-node-01
5. Build README.md for `~/homelab-scripts/k3s-arr/traefik/`
