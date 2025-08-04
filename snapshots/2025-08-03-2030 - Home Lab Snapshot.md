# 2025-08-03 - Home Lab Snapshot (20:30)

## 🧱 Infrastructure Overview

- **Kubernetes**: ✅ **K3s only**
- **Docker Swarm**: ❌ No longer used
- **Ingress / Proxy**: ❌ Traefik removed, ❌ Nginx Proxy Manager removed
- **Access Method**: ✅ All external access now routed **directly through Cloudflare Tunnels** to individual services using internal Kubernetes DNS
- **Cloudflare Tunnel**:
  - Namespace: `cloudflare-tunnel`
  - Tunnel ID: `bb4c24f4-7fff-46b5-9548-517a288415ed`
  - Image: `cloudflare/cloudflared:2023.10.0`
  - Config stored in ConfigMap: `cloudflared-config`
  - Credentials stored in Secret: `cloudflared-credentials`
  - Routing uses Kubernetes internal DNS (`*.svc.cluster.local`)
  - Services verified: ✅ Radarr, ✅ Sonarr, ✅ SABnzbd, ✅ Jellyfin, ✅ Overseerr, ✅ Vaultwarden

## 🌐 Network & Access

- Router: ASUS RT-BE86U BE6800 WiFi 7
- DNS: Cloudflare with A/CNAME entries
- Cloudflare Tunnels for all traffic
- Port Forwarding:

  | External Port | Internal IP        | Purpose       |
  |---------------|--------------------|---------------|
  | 2222          | 192.168.86.77      | SSH to node 1 |
  | 2223          | 192.168.86.119     | SSH to node 2 |

## 🧱 Nodes & Roles

### ✅ Active Nodes

1. **ubuntu-node-01**
   - IP: `192.168.86.77`
   - Role: K3s master, Ansible controller, Cloudflare tunnel host
   - Storage: GlusterFS mounted at `/mnt/gluster/appdata` and `/mnt/gluster/media`

2. **gluster-node-1** (formerly `ubuntu-node-02`)
   - IP: `192.168.86.119`
   - Role: Dedicated GlusterFS storage node
   - Drives: `data1`, `data2`, `data3`, `data4`
   - Volumes:
     - `gfs_appdata`: replica 2 (to be corrected to replica 3 in future)
     - `gfs_media`: distributed

### 🔻 Offline Nodes

3. **ubuntu-node-03** (formerly Plexyglass)
   - IP: `192.168.86.24`
   - Status: Offline (awaiting repurpose as K3s worker)
   - Drives: Previously hosted 4×18TB (now in gluster-node-1)

4. **ubuntu-node-04** (formerly Stratosphere → will become ubuntu-node-02)
   - IP: `192.168.86.73`
   - Status: Offline
   - Drives: 2×12TB (awaiting relocation)

### 🆕 Future

- `gluster-2`: new GlusterFS node (not yet created)

## 📦 K3s Application Stack (Namespace: `media`)

### ✅ Radarr
- `radarr.media.svc.cluster.local`
- Volumes:
  - `/downloads` → `/mnt/gluster/media/media_holder/movies`
- Remote Path Mapping:
  - Host: `sabnzbd.rahl.cc`
  - Remote: `/media/media_holder/movies`
  - Local: `/downloads`
- Issue fixed: Removed stale Radarr in `default` namespace

### ✅ Sonarr
- Same structure as Radarr
- Namespace correction made in tunnel config

### ✅ SABnzbd
- Volumes:
  - Shares `/mnt/gluster/media/media_holder/movies`
- Files now created with UID/GID `1000`

### 🛠️ Other Deployed Apps
- ✅ Jellyfin
- ✅ Overseerr
- ✅ Vaultwarden
- All verified accessible via Cloudflare

## 🔐 Permissions

- All apps standardized with:
  - `PUID=1000`
  - `PGID=1000`
  - `TZ=America/Denver`
- GlusterFS access confirmed by creating `/downloads/testfile.txt` from inside Radarr
- Permissions command used:

  ```bash
  sudo chown -R 1000:1000 /mnt/gluster/media/media_holder/movies
  sudo chmod -R 775 /mnt/gluster/media/media_holder/movies
  ```

- Ansible-managed nightly automation:
  - `fix-media-perms.sh`
  - Playbook: `~/ansible/fix-media.yml`
  - Cron: 2 AM
  - Applies to: `/mnt/gluster/media` (should be expanded to include `/downloads`, `/tv`, etc.)

## 🔁 Automation

- Primary Node: `ubuntu-node-01`
- Managed by Ansible (see: `Ansible - Sonarr Media Permission Automation Guide`)
- Role Path: `~/ansible/roles/fix_permissions/`
- Nightly Cron Permission Fix enabled on all nodes
- Script path: `/usr/local/bin/fix-media-perms.sh`

## 🧩 Clean-Up Completed

- ✅ Removed all Docker Swarm stack YAMLs
- ✅ Deleted Traefik
- ✅ Removed Nginx Proxy Manager
- ✅ Migrated services to Cloudflare-based ingress
- ✅ Verified all media apps function correctly
- ✅ No 404 or permission issues observed
- ✅ GitHub updated with new manifests per app (one YAML per app)

## 📌 Remaining Tasks

- [ ] Update `fix-media-perms.sh` to include `/downloads`, `/tv`, etc.
- [ ] Ensure consistent UID/GID in all Kubernetes manifests
- [ ] Replace any lingering references to `default.svc` in tunnel config
- [ ] Remove any stale pods or ConfigMaps from Swarm era
- [ ] Update `gfs_appdata` to use valid replica 3 (currently replica 2 on 3 bricks)

---

✅ **Current Status**: Fully operational K3s-based media stack using GlusterFS and Cloudflare Tunnel ingress only. All ARR apps migrated and functioning.
