# Home Lab Snapshot: 2025-08-12

This document reflects the current, stable architecture of the homelab cluster after a full rebuild and migration to the Longhorn storage system.

## 🚀 Core Architecture

  * **Orchestrator:** K3s (`v1.33.3+k3s1`)
  * **Storage:** Longhorn (`v1.6.2`)
  * **Ingress:** Cloudflare Tunnel

-----

## 💻 Nodes & Roles

  * **`ubuntu-node-01` (Master)**

      * **IP:** `192.168.86.77`
      * **Role:** K3s control-plane, master.
      * **SSH Access:** `ssh -p 2222 luke7524811@69.146.2.132`

  * **`gluster-node-1` (Worker & Storage)**

      * **IP:** `192.168.86.119`
      * **Role:** K3s worker node, Longhorn storage node.
      * **SSH Access:** `ssh -p 2223 luke7524811@69.146.2.132`

-----

## 💾 Storage Architecture (Longhorn)

  * **Storage Pool:** The Longhorn storage pool is formed from four 16.4TiB drives on `gluster-node-1`, providing a total capacity of **\~65TiB**.
  * **Data Safety:** A `StorageClass` named **`longhorn-retain`** is the cluster default. It uses a **`reclaimPolicy: Retain`** to prevent accidental data loss when applications are deleted. The `Default Replica Count` is set to **1**.
  * **Application Storage Model:**
      * Each application receives a private, `ReadWriteOnce` volume for its configuration data.
      * Shared `ReadWriteMany` volumes are used for common data paths like the media library and downloads, allowing multiple applications to access them simultaneously.

-----

## 💿 Backup & Data Migration Status

  * **Backup Location:** Your `appdata` and `audiobooks` backup is **safe and secure** on your fourth drive (`/dev/sde`), which is currently mounted at `/mnt/data3` on `gluster-node-1`.
  * **Migration Status:** This data **has not yet been migrated** to the new Longhorn volumes.

-----

## ✅ Final Action Plan

1.  **Migrate Your Backup Data:** Use a temporary `migration-pod` to `rsync` your backed-up `appdata` and `audiobooks` into the new, empty Longhorn volumes created by the manifest below.
2.  **Add Your Final Drive to Longhorn:** After the data migration is complete and verified, unmount and wipe your fourth drive (`/dev/sde`) and add it to the Longhorn storage pool via the UI.
3.  **Deploy New Applications:** Use the manifest below as a template to deploy `Vaultwarden`, `Metube`, and other services.

-----

## 📜 The Golden Manifest: Core Applications

This single manifest contains the complete, corrected, and simplified configurations to deploy your entire core application stack onto the Longhorn storage system.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: media
---
# ===================================================================
# StorageClass (The SAFE Profile)
# ===================================================================
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn-retain
provisioner: driver.longhorn.io
reclaimPolicy: Retain
parameters:
  numberOfReplicas: "1"
allowVolumeExpansion: true
---
# ===================================================================
# PersistentVolumeClaims (Your New Granular Layout)
# ===================================================================
# --- PRIVATE CONFIG VOLUMES ---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jellyfin-config-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 20Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sonarr-config-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: radarr-config-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sabnzbd-config-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 5Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prowlarr-config-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: obsidian-config-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 10Gi
---
# --- SHARED MEDIA & DOWNLOADS VOLUMES ---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: media-movies-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 5Ti
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: media-movies-christmas-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 500Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: media-movies-kids-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 2Ti
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: media-tv-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 5Ti
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: media-tv-anime-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 5Ti
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: media-tv-cartoons-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 2Ti
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: media-audiobooks-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 2Ti
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: downloads-pvc
  namespace: media
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: longhorn-retain
  resources:
    requests:
      storage: 1Ti
---
# ===================================================================
# Application Deployments and Services
# ===================================================================
# --- Jellyfin ---
apiVersion: v1
kind: Service
metadata:
  name: jellyfin
  namespace: media
spec:
  type: ClusterIP
  selector:
    app: jellyfin
  ports:
  - name: http
    port: 8096
    targetPort: 8096
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jellyfin
  namespace: media
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jellyfin
  template:
    metadata:
      labels:
        app: jellyfin
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        fsGroupChangePolicy: "OnRootMismatch"
      initContainers:
      - name: set-permissions
        image: busybox
        command: ["sh", "-c", "chown -R 1000:1000 /config /media"]
        securityContext:
          runAsUser: 0
        volumeMounts:
        - name: config
          mountPath: /config
        - name: media
          mountPath: /media
      containers:
      - name: jellyfin
        image: lscr.io/linuxserver/jellyfin:latest
        env:
        - name: PUID
          value: "1000"
        - name: PGID
          value: "1000"
        - name: TZ
          value: "America/Denver"
        ports:
        - containerPort: 8096
        volumeMounts:
        - name: config
          mountPath: /config
        - name: media
          mountPath: /media
      volumes:
      - name: config
        persistentVolumeClaim:
          claimName: jellyfin-config-pvc
      - name: media
        persistentVolumeClaim:
          claimName: media-library-pvc # This needs to be one of the granular volumes
---
# --- Radarr ---
apiVersion: v1
kind: Service
metadata:
  name: radarr
  namespace: media
spec:
  type: ClusterIP
  selector:
    app: radarr
  ports:
  - name: http
    port: 7878
    targetPort: 7878
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: radarr
  namespace: media
spec:
  replicas: 1
  selector:
    matchLabels:
      app: radarr
  template:
    metadata:
      labels:
        app: radarr
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        fsGroupChangePolicy: "OnRootMismatch"
      initContainers:
      - name: set-permissions
        image: busybox
        command: ["sh", "-c", "chown -R 1000:1000 /config /movies /downloads"]
        securityContext:
          runAsUser: 0
        volumeMounts:
        - name: config
          mountPath: /config
        - name: movies
          mountPath: /movies
        - name: kids-movies
          mountPath: /movies/kids
        - name: christmas-movies
          mountPath: /movies/christmas
        - name: downloads
          mountPath: /downloads
      containers:
      - name: radarr
        image: lscr.io/linuxserver/radarr:latest
        env:
        - name: PUID
          value: "1000"
        - name: PGID
          value: "1000"
        - name: TZ
          value: "America/Denver"
        ports:
        - containerPort: 7878
        volumeMounts:
        - name: config
          mountPath: /config
        - name: movies
          mountPath: /movies
        - name: kids-movies
          mountPath: /movies/kids
        - name: christmas-movies
          mountPath: /movies/christmas
        - name: downloads
          mountPath: /downloads
      volumes:
      - name: config
        persistentVolumeClaim:
          claimName: radarr-config-pvc
      - name: movies
        persistentVolumeClaim:
          claimName: media-movies-pvc
      - name: kids-movies
        persistentVolumeClaim:
          claimName: media-movies-kids-pvc
      - name: christmas-movies
        persistentVolumeClaim:
          claimName: media-movies-christmas-pvc
      - name: downloads
        persistentVolumeClaim:
          claimName: downloads-pvc
---
# --- Sonarr ---
apiVersion: v1
kind: Service
metadata:
  name: sonarr
  namespace: media
spec:
  type: ClusterIP
  selector:
    app: sonarr
  ports:
  - name: http
    port: 8989
    targetPort: 8989
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sonarr
  namespace: media
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sonarr
  template:
    metadata:
      labels:
        app: sonarr
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        fsGroupChangePolicy: "OnRootMismatch"
      initContainers:
      - name: set-permissions
        image: busybox
        command: ["sh", "-c", "chown -R 1000:1000 /config /tv /downloads"]
        securityContext:
          runAsUser: 0
        volumeMounts:
        - name: config
          mountPath: /config
        - name: tv
          mountPath: /tv
        - name: anime
          mountPath: /tv/anime
        - name: cartoons
          mountPath: /tv/cartoons
        - name: downloads
          mountPath: /downloads
      containers:
      - name: sonarr
        image: lscr.io/linuxserver/sonarr:latest
        env:
        - name: PUID
          value: "1000"
        - name: PGID
          value: "1000"
        - name: TZ
          value: "America/Denver"
        ports:
        - containerPort: 8989
        volumeMounts:
        - name: config
          mountPath: /config
        - name: tv
          mountPath: /tv
        - name: anime
          mountPath: /tv/anime
        - name: cartoons
          mountPath: /tv/cartoons
        - name: downloads
          mountPath: /downloads
      volumes:
      - name: config
        persistentVolumeClaim:
          claimName: sonarr-config-pvc
      - name: tv
        persistentVolumeClaim:
          claimName: media-tv-pvc
      - name: anime
        persistentVolumeClaim:
          claimName: media-tv-anime-pvc
      - name: cartoons
        persistentVolumeClaim:
          claimName: media-tv-cartoons-pvc
      - name: downloads
        persistentVolumeClaim:
          claimName: downloads-pvc
---
# --- Prowlarr ---
apiVersion: v1
kind: Service
metadata:
  name: prowlarr
  namespace: media
spec:
  type: ClusterIP
  selector:
    app: prowlarr
  ports:
  - name: http
    port: 9696
    targetPort: 9696
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prowlarr
  namespace: media
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prowlarr
  template:
    metadata:
      labels:
        app: prowlarr
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        fsGroupChangePolicy: "OnRootMismatch"
      initContainers:
      - name: set-permissions
        image: busybox
        command: ["sh", "-c", "chown -R 1000:1000 /config"]
        securityContext:
          runAsUser: 0
        volumeMounts:
        - name: config
          mountPath: /config
      containers:
      - name: prowlarr
        image: lscr.io/linuxserver/prowlarr:latest
        env:
        - name: PUID
          value: "1000"
        - name: PGID
          value: "1000"
        - name: TZ
          value: "America/Denver"
        ports:
        - containerPort: 9696
        volumeMounts:
        - name: config
          mountPath: /config
      volumes:
      - name: config
        persistentVolumeClaim:
          claimName: prowlarr-config-pvc
---
# --- SABnzbd ---
apiVersion: v1
kind: Service
metadata:
  name: sabnzbd
  namespace: media
spec:
  type: ClusterIP
  selector:
    app: sabnzbd
  ports:
  - name: http
    port: 8080
    targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sabnzbd
  namespace: media
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sabnzbd
  template:
    metadata:
      labels:
        app: sabnzbd
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        fsGroupChangePolicy: "OnRootMismatch"
      initContainers:
      - name: set-permissions-and-config
        image: busybox
        command: ["sh", "-c", "chown -R 1000:1000 /config /downloads && if [ ! -f /config/sabnzbd.ini ]; then touch /config/sabnzbd.ini; fi && if ! grep -q 'host_whitelist' /config/sabnzbd.ini; then echo 'host_whitelist = sabnzbd.rahl.cc' >> /config/sabnzbd.ini; fi"]
        securityContext:
          runAsUser: 0
        volumeMounts:
        - name: config
          mountPath: /config
        - name: downloads
          mountPath: /downloads
      containers:
      - name: sabnzbd
        image: lscr.io/linuxserver/sabnzbd:latest
        env:
        - name: PUID
          value: "1000"
        - name: PGID
          value: "1000"
        - name: TZ
          value: "America/Denver"
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: config
          mountPath: /config
        - name: downloads
          mountPath: /downloads
      volumes:
      - name: config
        persistentVolumeClaim:
          claimName: sabnzbd-config-pvc
      - name: downloads
        persistentVolumeClaim:
          claimName: downloads-pvc
---
# --- Obsidian ---
apiVersion: v1
kind: Service
metadata:
  name: obsidian
  namespace: media
spec:
  type: ClusterIP
  selector:
    app: obsidian
  ports:
  - name: http
    port: 8080
    targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: obsidian
  namespace: media
spec:
  replicas: 1
  selector:
    matchLabels:
      app: obsidian
  template:
    metadata:
      labels:
        app: obsidian
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        fsGroupChangePolicy: "OnRootMismatch"
      initContainers:
      - name: set-permissions
        image: busybox
        command: ["sh", "-c", "chown -R 1000:1000 /config"]
        securityContext:
          runAsUser: 0
        volumeMounts:
        - name: config
          mountPath: /config
      containers:
      - name: obsidian
        image: lscr.io/linuxserver/obsidian:latest
        env:
        - name: PUID
          value: "1000"
        - name: PGID
          value: "1000"
        - name: TZ
          value: "America/Denver"
        ports:
        - containerPort: 8080
        volumeMounts:
        - name: config
          mountPath: /config
        readinessProbe: null
        livenessProbe: null
      volumes:
      - name: config
        persistentVolumeClaim:
          claimName: obsidian-config-pvc
```

-----

## 📜 Ingress Configuration: Cloudflare Tunnel

This is the manifest for your ingress controller. The `ConfigMap` should be updated to include the hostnames for all the services you deploy.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cloudflare-tunnel
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cloudflared
  namespace: cloudflare-tunnel
---
apiVersion: v1
kind: Secret
metadata:
  name: cloudflared-credentials
  namespace: cloudflare-tunnel
stringData:
  # The content of your credentials.json file goes here
  credentials.json: |
    {"AccountTag":"...","TunnelID":"bb4c24f4-7fff-46b5-9548-517a288415ed","TunnelSecret":"..."}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: cloudflared-config
  namespace: cloudflare-tunnel
data:
  config.yaml: |
    tunnel: bb4c24f4-7fff-46b5-9548-517a288415ed
    credentials-file: /etc/cloudflared/credentials.json
    ingress:
      - hostname: jellyfin.rahl.cc
        service: http://jellyfin.media.svc.cluster.local:8096
      - hostname: sonarr.rahl.cc
        service: http://sonarr.media.svc.cluster.local:8989
      - hostname: radarr.rahl.cc
        service: http://radarr.media.svc.cluster.local:7878
      - hostname: sabnzbd.rahl.cc
        service: http://sabnzbd.media.svc.cluster.local:8080
      - hostname: prowlarr.rahl.cc
        service: http://prowlarr.media.svc.cluster.local:9696
      - hostname: obsidian.rahl.cc
        service: http://obsidian.media.svc.cluster.local:8080
      - hostname: longhorn.rahl.cc
        service: http://longhorn-frontend.longhorn-system.svc.cluster.local:80
      - service: http_status:404
---
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
            - --config
            - /etc/cloudflared/config.yaml
            - --metrics
            - 0.0.0.0:8080
            - run
          livenessProbe:
            httpGet:
              path: /ready
              port: 8080
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
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
```
 # --- Sonarr ---
apiVersion: v1
kind: Service
metadata:
  name: sonarr
  namespace: media
spec:
  type: ClusterIP
  selector:
    app: sonarr
  ports:
  - name: http
    port: 8989
    targetPort: 8989
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sonarr
  namespace: media
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sonarr
  template:
    metadata:
      labels:
        app: sonarr
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        fsGroupChangePolicy: "OnRootMismatch"
      initContainers:
      - name: set-permissions
        image: busybox
        command: ["sh", "-c", "chown -R 1000:1000 /config /tv /downloads"]
        securityContext:
          runAsUser: 0
        volumeMounts:
        - {name: config, mountPath: /config}
        - {name: tv, mountPath: /tv}
        - {name: anime, mountPath: /tv/anime}
        - {name: cartoons, mountPath: /tv/cartoons}
        - {name: downloads, mountPath: /downloads}
      containers:
      - name: sonarr
        image: lscr.io/linuxserver/sonarr:latest
        env:
        - {name: PUID, value: "1000"}
        - {name: PGID, value: "1000"}
        - {name: TZ, value: "America/Denver"}
        ports:
        - {containerPort: 8989}
        volumeMounts:
        - {name: config, mountPath: /config}
        - {name: tv, mountPath: /tv}
        - {name: anime, mountPath: /tv/anime}
        - {name: cartoons, mountPath: /tv/cartoons}
        - {name: downloads, mountPath: /downloads}
      volumes:
      - {name: config, persistentVolumeClaim: {claimName: sonarr-config}}
      - {name: tv, persistentVolumeClaim: {claimName: media-tv}}
      - {name: anime, persistentVolumeClaim: {claimName: media-tv-anime}}
      - {name: cartoons, persistentVolumeClaim: {claimName: media-tv-cartoons}}
      - {name: downloads, persistentVolumeClaim: {claimName: downloads}}
---
# --- Prowlarr ---
apiVersion: v1
kind: Service
metadata:
  name: prowlarr
  namespace: media
spec:
  type: ClusterIP
  selector:
    app: prowlarr
  ports:
  - name: http
    port: 9696
    targetPort: 9696
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prowlarr
  namespace: media
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prowlarr
  template:
    metadata:
      labels:
        app: prowlarr
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        fsGroupChangePolicy: "OnRootMismatch"
      initContainers:
      - name: set-permissions
        image: busybox
        command: ["sh", "-c", "chown -R 1000:1000 /config"]
        securityContext:
          runAsUser: 0
        volumeMounts:
        - {name: config, mountPath: /config}
      containers:
      - name: prowlarr
        image: lscr.io/linuxserver/prowlarr:latest
        env:
        - {name: PUID, value: "1000"}
        - {name: PGID, value: "1000"}
        - {name: TZ, value: "America/Denver"}
        ports:
        - {containerPort: 9696}
        volumeMounts:
        - {name: config, mountPath: /config}
      volumes:
      - {name: config, persistentVolumeClaim: {claimName: prowlarr-config}}
---
# --- SABnzbd ---
apiVersion: v1
kind: Service
metadata:
  name: sabnzbd
  namespace: media
spec:
  type: ClusterIP
  selector:
    app: sabnzbd
  ports:
  - name: http
    port: 8080
    targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sabnzbd
  namespace: media
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sabnzbd
  template:
    metadata:
      labels:
        app: sabnzbd
    spec:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
        fsGroupChangePolicy: "OnRootMismatch"
      initContainers:
      - name: set-permissions-and-config
        image: busybox
        command: ["sh", "-c", "chown -R 1000:1000 /config /downloads && if [ ! -f /config/sabnzbd.ini ]; then touch /config/sabnzbd.ini; fi && if ! grep -q 'host_whitelist' /config/sabnzbd.ini; then echo 'host_whitelist = sabnzbd.rahl.cc' >> /config/sabnzbd.ini; fi"]
        securityContext:
          runAsUser: 0
        volumeMounts:
        - {name: config, mountPath: /config}
        - {name: downloads, mountPath: /downloads}
      containers:
      - name: sabnzbd
        image: lscr.io/linuxserver/sabnzbd:latest
        env:
        - {name: PUID, value: "1000"}
        - {name: PGID, value: "1000"}
        - {name: TZ, value: "America/Denver"}
        ports:
        - {containerPort: 8080}
        volumeMounts:
        - {name: config, mountPath: /config}
        - {name: downloads, mountPath: /downloads}
      volumes:
      - {name: config, persistentVolumeClaim: {claimName: sabnzbd-config}}
      - {name: downloads, persistentVolumeClaim: {claimName: downloads}}
---
