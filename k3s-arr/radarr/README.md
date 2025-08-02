# Radarr (K3s Deployment)

Radarr is a movie collection manager for Usenet and BitTorrent users.

## 📦 Deployment Info

- **Cluster**: K3s
- **Namespace**: default
- **Replicas**: 1
- **Ingress**: Traefik

## 🌐 Access URLs

- https://radarr.rahl.cc
- https://radarr.fractal-financial.com

## 🔧 Volume Mounts

| Mount | Host Path                        | Container Path |
|-------|----------------------------------|----------------|
| Config | `/mnt/gluster/appdata/radarr`  | `/config`      |
| Movies | `/mnt/gluster/media/movies`    | `/movies`      |

## 🛠️ Environment

- `PUID=1000`
- `PGID=1000`
- `TZ=America/Denver`

## ✅ Status

- Uses GlusterFS
- Reverse proxied via Traefik
- Auto permission fix via Ansible
