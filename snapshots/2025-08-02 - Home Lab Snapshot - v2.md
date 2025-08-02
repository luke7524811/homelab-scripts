# 📄 **2025-08-02 - Home Lab Snapshot**

## 🌐 Network & Access

* Router: ASUS RT-BE86U BE6800 WiFi 7
* Modem: Spectrum (direct to router)
* Switch: Gigabit unmanaged switch
* DNS: Cloudflare (A/CNAME entries + Cloudflare Tunnels)

## 🔐 Port Forwarding

| External Port | Internal Destination | Purpose       |
| ------------- | -------------------- | ------------- |
| 2222          | 192.168.86.77:22     | SSH to node 1 |
| 2223          | 192.168.86.119:22    | SSH to node 2 |

🌀 All other services routed through Cloudflare Tunnel to Nginx Proxy Manager.

---

## 🧱 Nodes & Roles

1. **ubuntu-node-01**

   * IP: 192.168.86.77
   * Username: luke7524811
   * Role: Docker Swarm Manager, Ansible controller, Cloudflare tunnel host
   * Services: Nginx Proxy Manager, Portainer, Prowlarr, Radarr, Sonarr, SABnzbd, Vaultwarden, Overseerr, DumbAssets, Actual Server
   * Storage: GlusterFS mounted at `/mnt/gluster/appdata` and `/mnt/gluster/media`

2. **gluster-node-1** (renamed from ubuntu-node-02)

   * IP: 192.168.86.119
   * Username: luke7524811
   * Role: Dedicated GlusterFS storage node
   * Drives: data1, data2, data3, data4 (formerly from node 3)
   * Volumes:

     * `gfs_appdata`: replica 2 (✳ needs replica 3 validation/fix)
     * `gfs_media`: distributed
   * SSH: root login temporarily enabled for rename, then disabled

3. **ubuntu-node-03** (formerly Plexyglass) - Offline

   * IP: 192.168.86.24
   * Username: luke7524811
   * Status: Offline
   * Drives: Formerly had 4x18TB, now transferred to gluster-node-1
   * Role: Will become Docker Swarm worker node

4. **ubuntu-node-04** (formerly Stratosphere → will become ubuntu-node-02) - Offline

   * IP: 192.168.86.73
   * Status: Offline
   * Drives: 2x12TB (to be moved to new node)

## 🆕 Future Additions

* **gluster-2**: Second GlusterFS node (not yet created)

---

## 📦 Deployed Docker Swarm Apps

* ✅ Nginx Proxy Manager
* ✅ Portainer
* ✅ Vaultwarden
* ✅ Sonarr (with Ansible permission fix)
* ✅ Radarr
* ✅ SABnzbd
* ✅ Prowlarr
* ✅ Overseerr
* ✅ DumbAssets
* ✅ Actual Server
* ✅ Plex (limited to nodes 01/03/04)
* ⚠️ Audiobookshelf (Planned - deploy next)
* ⚠️ Nextcloud (Legacy, still on Unraid)
* ⚠️ Moodle, Kimai, EspoCRM, MiniCal (DBs created or staged)
* ⚠️ Odoo (Planned)

---

## 🤖 Automation (Ansible)

* Host: `ubuntu-node-01`
* Directory: `~/ansible/`
* Files:

  * `inventory.ini` — defines all Swarm nodes
  * `fix-media.yml` — nightly playbook
  * Role: `fix_permissions`

    * Script: `fix-media-perms.sh`
    * Cron: 2AM on all nodes
    * Fixes media permissions across `/mnt/gluster/media`
* SSH keys configured for passwordless access to all nodes

---

## ☁️ Cloudflared Tunnel – K3s Deployment

**Tunnel ID:** `bb4c24f4-7fff-46b5-9548-517a288415ed`
**Namespace:** `cloudflare-tunnel`
**GitHub:** [`homelab-scripts/k3s-cloudflared`](https://github.com/luke7524811/homelab-scripts/tree/main/k3s-cloudflared)
**Live Subdomains:**

* [https://jellyfin.rahl.cc](https://jellyfin.rahl.cc)
* [https://sabnzbd.rahl.cc](https://sabnzbd.rahl.cc)

✅ **Kubernetes Objects Created**

* Namespace: `cloudflare-tunnel`
* Deployment: `cloudflared`
* ServiceAccount: `cloudflared`
* ConfigMap: `cloudflared-config`
* Secret: `cloudflared-credentials`

📄 **Deployment YAML:** `k3s-cloudflared/cloudflared.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloudflared
  namespace: cloudflare-tunnel
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cloudflared
  template:
    metadata:
      labels:
        app: cloudflared
    spec:
      serviceAccountName: cloudflared
      containers:
        - name: cloudflared
          image: cloudflare/cloudflared:latest
          args:
            - tunnel
            - run
            - --cred-file
            - /etc/cloudflared/credentials.json
          volumeMounts:
            - name: config-volume
              mountPath: /etc/cloudflared/config.yaml
              subPath: config.yaml
            - name: credentials-volume
              mountPath: /etc/cloudflared/credentials.json
              subPath: credentials.json
      volumes:
        - name: config-volume
          configMap:
            name: cloudflared-config
        - name: credentials-volume
          secret:
            secretName: cloudflared-credentials
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cloudflared
  namespace: cloudflare-tunnel
```

📄 **ConfigMap: `config.yaml`**

```yaml
tunnel: bb4c24f4-7fff-46b5-9548-517a288415ed
credentials-file: /etc/cloudflared/credentials.json
ingress:
  - hostname: jellyfin.rahl.cc
    service: http://jellyfin.kube.svc.cluster.local:8096
  - hostname: sabnzbd.rahl.cc
    service: http://sabnzbd.kube.svc.cluster.local:8080
  - service: http_status:404
```

📈 **Status:**

* Deployment running and stable
* QUIC tunnel confirmed with Cloudflare edge
* Ingress rules routing correctly for all domains

---

## 📌 Next Steps

1. Connect the remaining K3 pods to the cloudflare tunnel
2. Migrate the remainder of the swarm to K3
3. Deploy gluster-2 and expand `gfs_appdata` to replica 3
4. Migrate Nextcloud to K3s and GlusterFS


---

