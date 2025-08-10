# Cloudflare Tunnel for Traefik (K3s)

This deployment uses `cloudflared` to create a secure tunnel from Cloudflare to your internal K3s Traefik LoadBalancer.

## Setup Instructions

1. **Create a Cloudflare tunnel using Docker:**

   ```bash
   docker run -v ~/.cloudflared:/etc/cloudflared --rm cloudflare/cloudflared:latest tunnel create traefik-k3s
Create the Kubernetes secret:

bash
Copy
Edit
kubectl create namespace cloudflare-tunnel

kubectl create secret generic cloudflared-credentials \
  --from-file=credentials.json=/home/luke7524811/.cloudflared/<tunnel-id>.json \
  -n cloudflare-tunnel
Apply the deployment:

bash
Copy
Edit
kubectl apply -f cloudflared.yaml


# cloudflared-config.yaml
Cloudflare Tunnel routes public hostnames → K8s Services directly (no Traefik).
Example:
hostname: sabnzbd.rahl.cc
service: http://sabnzbd.media.svc.cluster.local:8080

yaml
Copy
Edit

Apply & restart:
