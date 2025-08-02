# Prowlarr – K3s Deployment

This folder contains a manifest to deploy **Prowlarr** into your K3s cluster.

---

## 🌐 Ingress Domain

Accessible at:  
**https://prowlarr.rahl.cc**  
*(Managed via Nginx Proxy Manager and Traefik)*

---

## 📦 Container Info

- **Image**: `lscr.io/linuxserver/prowlarr:latest`
- **Port**: `9696` (exposed through Service and Ingress)
- **Namespace**: `media`

---

## 💾 Storage Paths

| Mount Path       | Host Path                               | Description                |
|------------------|------------------------------------------|----------------------------|
| `/config`        | `/mnt/gluster/appdata/prowlarr`         | App config (GlusterFS)     |

---

## 🛠️ Deployment Instructions

Apply with:

```bash
kubectl apply -f prowlarr.yaml -n media

Make sure:

The media namespace exists

Traefik is installed and configured

DNS points prowlarr.rahl.cc to your cluster IP

✅ Status Check
Verify pod is running:

bash
Copy
Edit
kubectl get pods -n media -l app.kubernetes.io/name=prowlarr
🔄 Updating
To update the container:

bash
Copy
Edit
kubectl rollout restart deployment prowlarr -n media
yaml
Copy
Edit

Save and exit with `Ctrl+O`, `Enter`, then `Ctrl+X`.

---

When ready, commit and push the changes:

```bash
cd ~/homelab-scripts
git add k3s-arr/
git commit -m "Removed NPM from K3s and added README for Prowlarr"
git push
