2025-07-26 - Home Lab Snapshot (Updated)
=======================================

🌐 Network & Access
-------------------
- Router: ASUS RT-BE86U BE6800 WiFi 7
- Modem: Spectrum (direct to router)
- Switch: Gigabit unmanaged switch
- DNS: Cloudflare (A/CNAME entries + Cloudflare Tunnels)

🔐 Port Forwarding (Current)
---------------------------
| External Port | Internal Destination | Purpose       |
|-------------- |---------------------|---------------|
| 2222          | 192.168.86.77:22    | SSH to node 1 |
| 2223          | 192.168.86.119:22   | SSH to node 2 |

🌀 All other services are routed through Cloudflare Tunnel to Nginx Proxy Manager.

🧱 Nodes & Roles
----------------
1. **ubuntu-node-01**  
   - IP: 192.168.86.77  
   - Username: luke7524811  
   - Role: Docker Swarm Manager, Ansible controller, Cloudflare-tunnel host  
   - Services: Nginx Proxy Manager, Portainer, Prowlarr, Radarr, Sonarr, SABnzbd,  
     Vaultwarden, Overseerr, DumbAssets, Actual Server  
   - Storage: GlusterFS mounted at `/mnt/gluster/appdata` and `/mnt/gluster/media`

2. **gluster-node-1** (renamed from ubuntu-node-02)  
   - IP: 192.168.86.119  
   - Username: luke7524811  
   - Role: Dedicated GlusterFS storage node  
   - Drives: data1, data2, data3, data4 (moved from node 3)  
   - Volumes: `gfs_appdata` (replica 2), `gfs_media` (distributed)  
   - SSH: root login temporarily enabled for rename, then restored

🔻 Pending / Offline Nodes
3. **ubuntu-node-03** (formerly Plexyglass) – 192.168.86.24 – Offline  
   Drives moved to gluster-node-1; will become Swarm worker.

4. **ubuntu-node-04** (formerly Stratosphere → will become ubuntu-node-02) – 192.168.86.73 – Offline  
   Holds 2 × 12 TB drives to be moved.

🆕 Future Additions
- **gluster-2** (new GlusterFS node) – not yet created

📦 Docker Swarm Apps
--------------------
✅ Nginx Proxy Manager, Portainer, Vaultwarden, Sonarr (w/ Ansible fix), Radarr,  
✅ SABnzbd, Prowlarr, Overseerr, DumbAssets, Actual Server, Plex (nodes 01/03/04)  
⚠️ Audiobookshelf (planned), Nextcloud (legacy on Unraid), Moodle / Kimai / EspoCRM / MiniCal (DBs created), Odoo (planned)

🔁 Automation
-------------
- Managed by Ansible from ubuntu-node-01  
- Playbook: `fix-media.yml`  
- Script: `/usr/local/bin/fix-media-perms.sh` (cron @ 02:00) – fixes GlusterFS media permissions cluster-wide

🧩 Misc Notes
-------------
- Cloudflare Tunnel handles all external access (no other exposed ports).  
- K3s will be installed alongside Docker Swarm.  
- Audiobookshelf will be first K3s test app.  
- **Drive 4** is now part of Gluster bricks and contains data.

📌 Next Steps
-------------
1. Deploy Audiobookshelf in Docker Swarm  
2. Set up gluster-2  
3. Begin dual-stack testing: Docker Swarm + K3s  
4. Migrate Nextcloud appdata into GlusterFS  
5. Rebuild Nginx on K3s when ready

