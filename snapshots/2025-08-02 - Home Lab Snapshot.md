📄 **2025-08-02 - Home Lab Snapshot**
*Based on: [GitHub Repo](https://github.com/luke7524811/homelab-scripts)*

---

## 🌐 Network & Access

* **Router:** ASUS RT-BE86U BE6800 WiFi 7
* **Modem:** Spectrum (direct to router)
* **Switch:** Gigabit unmanaged switch
* **DNS:** Cloudflare (A/CNAME + Cloudflare Tunnels)

### 🔐 Port Forwarding

| External Port | Internal Destination | Purpose       |
| ------------- | -------------------- | ------------- |
| 2222          | 192.168.86.77:22     | SSH to node 1 |
| 2223          | 192.168.86.119:22    | SSH to node 2 |

> All other access is routed via **Cloudflare Tunnel → Nginx Proxy Manager (Swarm)**

---

## 🧱 Nodes & Roles

### 1. `ubuntu-node-01`

* IP: `192.168.86.77`
* Username: `luke7524811`
* Role:

  * Docker Swarm Manager
  * K3s Control Plane
  * Ansible controller
  * Cloudflare Tunnel host
* Storage:

  * GlusterFS mounted at `/mnt/gluster/appdata` and `/mnt/gluster/media`
* Services:

  * Nginx Proxy Manager (Swarm)
  * Portainer
  * Vaultwarden
  * Sonarr (w/ permission automation)
  * Radarr, SABnzbd, Prowlarr
  * Overseerr, DumbAssets, Actual Server
  * **K3s apps:** SABnzbd, Prowlarr

### 2. `gluster-node-1` (renamed from ubuntu-node-02)

* IP: `192.168.86.119`
* Username: `luke7524811`
* Role: Dedicated GlusterFS storage node
* Drives: `data1`, `data2`, `data3`, `data4`
* Volumes:

  * `gfs_appdata` (replica 2)
  * `gfs_media` (distributed)

### 3. `ubuntu-node-03` *(formerly Plexyglass)*

* IP: `192.168.86.24`
* Username: `luke7524811`
* Status: **Offline**
* Role: Will become Docker Swarm/K3s worker
* Drives were moved to node 2

### 4. `ubuntu-node-04` *(formerly Stratosphere → will become ubuntu-node-02)*

* IP: `192.168.86.73`
* Status: **Offline**
* Drives: 2x12TB, to be moved to new node

### 🆕 Planned Node

* `gluster-2` — Future GlusterFS peer (not created yet)

---

## ☸️ K3s Stack (Live)

### 🗂️ GitHub Path

`homelab-scripts/k3s-arr/`

#### ✅ Apps Deployed in K3s

##### 1. **Prowlarr**

* Status: ✅ Running
* Path: `k3s-arr/prowlarr/prowlarr.yaml`
* Ingress: `https://prowlarr.rahl.cc`
* Namespace: `media`
* Volume: `/mnt/gluster/appdata/prowlarr` → `/config`
* Ingress Controller: Traefik

##### 2. **SABnzbd**

* Status: ✅ Running
* Path: `k3s-arr/sabnzbd/sabnzbd.yaml`
* Ingress: `https://sabnzbd.rahl.cc`
* Namespace: `media`
* Volumes:

  * `/mnt/gluster/appdata/sabnzbd` → `/config`
  * `/mnt/gluster/media` → `/media`
* Ingress Controller: Traefik

#### ❌ Nginx Proxy Manager (NPM)

* Removed from K3s
* Now deployed via Docker Swarm only
* Old K3s manifests removed

---

## 🌐 Domain Routing

| Domain                                 | Routed To                  | Status    |
| -------------------------------------- | -------------------------- | --------- |
| `nginx.rahl.cc`                        | Swarm NPM (external proxy) | ✅ Active  |
| `prowlarr.rahl.cc`                     | K3s via Traefik            | ✅ Working |
| `sabnzbd.rahl.cc`                      | K3s via Traefik            | ✅ Working |
| `audiobookshelf.rahl.cc`               | Swarm NPM → ABS            | ✅ Working |
| `audiobookshelf.fractal-financial.com` | Swarm NPM → ABS            | ✅ Working |

---

## 📦 Docker Swarm Apps

* ✅ Nginx Proxy Manager
* ✅ Portainer
* ✅ Vaultwarden
* ✅ Sonarr *(w/ Ansible fix)*
* ✅ Radarr
* ✅ SABnzbd
* ✅ Prowlarr
* ✅ Overseerr
* ✅ DumbAssets
* ✅ Actual Server
* ✅ Plex *(nodes 01/03/04 only)*
* ✅ Audiobookshelf *(via NPM + Docker Swarm)*
* ⚠️ Nextcloud *(still on Unraid)*
* ⚠️ Moodle, Kimai, EspoCRM, MiniCal *(DBs staged)*
* ⚠️ Odoo *(planned)*

---

## 🔁 Automation & Permissions

### Ansible Setup (Located on ubuntu-node-01)

* `~/ansible/inventory.ini` — tracks nodes
* `~/ansible/fix-media.yml` — playbook
* Script: `fix-media-perms.sh`
* Scheduled via cron @ 2:00 AM
* Applies `chmod 664` to files, `775` to dirs, `chown 1000:1000`

### Verify:

```bash
cat /etc/crontab | grep fix
ls -l /usr/local/bin/fix-media-perms.sh
sudo /usr/local/bin/fix-media-perms.sh
cat /var/log/fix-media-perms.log
```

---

## 📁 Filesystem & Volume Conventions

* Appdata: `/mnt/gluster/appdata/<appname>`
* Media:

  * TV/Movies/etc.: `/mnt/gluster/media/...`
  * ABS audiobooks: `/mnt/gluster/media/audiobooks`
  * ABS metadata: `/mnt/gluster/media/metadata`

All media containers run with:

* `PUID=1000`, `PGID=1000`
* Permissions enforced nightly with Ansible

---

## 🛠️ Supporting Config

* **Ingress Controller (K3s):** Traefik
* **Overlay Networks (Swarm):** `shared_net` (external)
* **K3s Service Access:** Traefik exposed internally, public routing handled via NPM on Swarm

---

## 🟡 To Do

1. Push manifests for:

   * ⬜️ Sonarr
   * ⬜️ Radarr
   * ⬜️ Huntarr
   * ⬜️ Overseerr
   * ⬜️ Audiobookshelf (migrate from Swarm)
2. Validate persistent volumes per app
3. Rebuild clean K3s manifests + readmes
4. Long-term: unify NPM into K3s or sync with Traefik

---

# 📁 GitHub Repo Structure

Your repository is:

**📦 [`homelab-scripts`](https://github.com/luke7524811/homelab-scripts)**
Snapshot files live here:
**`homelab-scripts/snapshots/`**

Each snapshot should be a `.txt` file named:

```
YYYY-MM-DD - Home Lab Snapshot.txt
```

✅ You already have:

```
2025-07-26 - Home Lab Snapshot (Updated).txt
```

We’re about to add:

```
2025-08-02 - Home Lab Snapshot.txt
```

---

# 🧠 Git Quick Start (SSH from `ubuntu-node-01`)

All of this assumes you're already in:

```bash
cd ~/homelab-scripts
```

If not:

```bash
cd ~/homelab-scripts
```

---

## ✅ Step 1: Add the New Snapshot File

Use nano or your favorite editor:

```bash
nano snapshots/2025-08-02 - Home Lab Snapshot.txt
```

📌 Paste in the full snapshot I gave you earlier.
Save and exit (`Ctrl+O`, `Enter`, then `Ctrl+X`).

---

## ✅ Step 2: Check Git Status

```bash
git status
```

You should see the new file as **untracked**.

---

## ✅ Step 3: Stage the File

```bash
git add "snapshots/2025-08-02 - Home Lab Snapshot.txt"
```

---

## ✅ Step 4: Commit It

```bash
git commit -m "📦 Add 2025-08-02 Home Lab Snapshot"
```

---

## ✅ Step 5: Push to GitHub (via SSH)

```bash
git push
```

If everything is set up with your SSH key (which it is), this will push directly without asking for login.

---

# 🧼 Optional: Edit or Remove Files

### ✏️ Edit an Existing File

```bash
nano snapshots/2025-07-26 - Home Lab Snapshot (Updated).txt
```

Then:

```bash
git add snapshots/2025-07-26\ -\ Home\ Lab\ Snapshot\ \(Updated\).txt
git commit -m "📝 Update 2025-07-26 snapshot details"
git push
```

---

### 🗑️ Delete a File

```bash
rm snapshots/2025-07-23\ -\ Home\ Lab\ Snapshot.txt
git add -u snapshots/
git commit -m "🗑️ Remove outdated 2025-07-23 snapshot"
git push
```

---

## ✅ Confirm It's Live

Go here:
🔗 [https://github.com/luke7524811/homelab-scripts/tree/main/snapshots](https://github.com/luke7524811/homelab-scripts/tree/main/snapshots)

You should see your new snapshot listed.

---

