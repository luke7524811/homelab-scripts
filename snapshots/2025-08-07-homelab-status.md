# 2025-08-07 – Home Lab Status & K3s Standardization Progress

**📂 Snapshot File Path (Local):**  
`/home/luke7524811/homelab-scripts/snapshots/`  

**🌐 Public GitHub Repository:**  
[https://github.com/luke7524811/homelab-scripts](https://github.com/luke7524811/homelab-scripts)  

---

## 🌐 Network & Access
- **Router:** ASUS RT-BE86U BE6800 WiFi 7  
- **Modem:** Spectrum (direct to router)  
- **Switch:** Gigabit unmanaged switch  
- **DNS:** Cloudflare (A/CNAME entries + Cloudflare Tunnels)  
- **Current Access Model:** **Direct Cloudflare Tunnel to Pods**  
  - No Traefik in active use (removed due to persistent routing issues)  
  - Each service is exposed via its own tunnel hostname → pod service  

---

## 🔐 Port Forwarding (Current)
| External Port | Internal Destination  | Purpose       |
|---------------|-----------------------|---------------|
| 2222          | 192.168.86.77:22       | SSH to node 1 |
| 2223          | 192.168.86.119:22      | SSH to node 2 |

---

## 🧱 Nodes & Roles
1. **ubuntu-node-01**
   - IP: 192.168.86.77  
   - Role: K3s primary node, Ansible controller, Cloudflare tunnel host  
   - Storage: GlusterFS mounted at `/mnt/gluster/appdata` and `/mnt/gluster/media`  
   - Status: Online  

2. **gluster-node-1**
   - IP: 192.168.86.119  
   - Role: Dedicated GlusterFS storage node  
   - Drives: data1, data2, data3, data4  
   - Volumes: `gfs_appdata` (replica 2), `gfs_media` (distributed)  
   - Status: Online  

**Pending / Offline:**  
3. **ubuntu-node-03** – Planned K3s worker  
4. **ubuntu-node-04** – Planned K3s worker  

---

## 📦 Deployed Apps in K3s (Standardized Template)

**New Template Features:**
- Explicit `PUID`, `PGID`, `TZ` environment variables  
- `securityContext` with `runAsUser`, `runAsGroup`, `fsGroup`  
- Readiness and liveness probes  
- Resource requests/limits  
- Separated `pv.yaml`, `pvc.yaml`, and deployment `.yaml` files  
- One `README.md` per app folder in `~/homelab-scripts/k3s-arr/<app>/`  

**Current Working Apps:**

### 1. SABnzbd
- Updated to new template  
- PV mount points:  
  - `/config` → `/mnt/gluster/appdata/sabnzbd`  
  - `/downloads` → `/mnt/gluster/media/media_holder`  
  - `/incomplete-downloads` → `/mnt/gluster/media/incomplete`  
- `media_holder` now contains only category folders:  
  - `anime`, `tv show`, `movies`, `audiobook`, `youtube`, `xxx`, `music`, `software`, `incomplete`  

### 2. Jellyfin
- Migrated to new template  
- PVs:  
  - `/config` → `/mnt/gluster/appdata/jellyfin`  
  - `/media`  → `/mnt/gluster/media/media_holder`  
- Connected directly through Cloudflare tunnel without Traefik  

---

## 🛠️ What We Are Working On
- Migrating **all other pods** to the new standardized K3s template  
- Creating consistent `pv.yaml`, `pvc.yaml`, `deployment.yaml`, and `README.md` for each app  
- Ensuring all GlusterFS-mounted media/config paths have correct permissions (`1000:1000`, `775`)  
- Gradual elimination of old Docker Swarm services  

---

## 📌 Next Steps
1. Standardize remaining ARR stack pods (Sonarr, Radarr, Prowlarr, Overseerr, etc.)  
2. Continue replacing old Swarm deployments with K3s-managed pods  
3. Document full K3s structure in GitHub  
4. Prepare base manifests for VM workloads in K3s  
5. Begin scaling toward 10s–100s of containers + VM orchestration  
