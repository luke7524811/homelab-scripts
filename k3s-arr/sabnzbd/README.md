# SABnzbd – K3s Deployment

This folder contains a complete manifest for running SABnzbd in K3s with:

- PersistentVolume + PVC (GlusterFS)
- Deployment using `lscr.io/linuxserver/sabnzbd`
- Service for internal routing
- Ingress for public access via `sabnzbd.rahl.cc`

**Storage paths:**

- Config: `/mnt/gluster/appdata/sabnzbd`
- Media: `/mnt/gluster/media`

## Deploy

```bash
kubectl apply -f sabnzbd.yaml -n media
