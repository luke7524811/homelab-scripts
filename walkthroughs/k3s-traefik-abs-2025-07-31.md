# K3s + Traefik (NodePort behind NPM) + Audiobookshelf Walkthrough (2025-07-31)

## 1. Prerequisites & Lab Facts

| Item              | Value                                                   |
| ----------------- | ------------------------------------------------------- |
| Primary node      | `ubuntu-node-01` (`192.168.86.77`)                      |
| Gluster paths     | `/mnt/gluster/appdata`, `/mnt/gluster/media`            |
| Traefik NodePorts | `31080` (HTTP), `31443` (HTTPS)                         |
| Public entry      | Nginx Proxy Manager on `*:80/443` via Cloudflare Tunnel |
| SSH user          | `luke7524811`                                           |

---

## 2. Install K3s (with Traefik, ServiceLB disabled)

```bash
sudo apt update && sudo apt full-upgrade -y

curl -sfL https://get.k3s.io | \
  INSTALL_K3S_EXEC="--write-kubeconfig-mode=644 --disable-network-policy --disable-cloud-controller --disable=servicelb" \
  sh -

echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
source ~/.bashrc
```

---

## 3. Patch Traefik Service to NodePort 31080/31443

```bash
kubectl -n kube-system patch svc traefik \
  -p '{"spec":{"type":"NodePort","ports":[
        {"name":"http","port":80,"nodePort":31080},
        {"name":"https","port":443,"nodePort":31443}]}}'

kubectl get svc -n kube-system traefik
```

---

## 4. Configure Nginx Proxy Manager

1. **Proxy Hosts → Add**
2. Domain: `abs.rahl.cc` (or `*.rahl.cc`)
3. Forward Hostname/IP: `192.168.86.77`
4. Forward Port: `31080`
5. Enable SSL as usual.

---

## 5. Prepare Storage Directories

```bash
sudo mkdir -p /mnt/gluster/appdata/audiobookshelf
sudo mkdir -p /mnt/gluster/media/audiobooks
sudo mkdir -p /mnt/gluster/media/metadata

sudo chown -R 1000:1000 /mnt/gluster/{appdata,audiobookshelf,media/{audiobooks,metadata}}
sudo chmod -R 775 /mnt/gluster/{appdata,audiobookshelf,media/{audiobooks,metadata}}
```

---

## 6. PersistentVolumes & Claims

Create **`abs-storage.yaml`**:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-abs-config
spec:
  capacity:
    storage: 10Gi
  accessModes: ["ReadWriteOnce"]
  hostPath:
    path: /mnt/gluster/appdata/audiobookshelf
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-abs-config
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 10Gi
```

Apply:

```bash
kubectl apply -f abs-storage.yaml
```

---

## 7. Deploy Audiobookshelf via Helm

```bash
# Helm setup
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add truecharts https://charts.truecharts.org
helm repo update

# Values file
cat > abs-values.yaml <<'EOF'
persistence:
  config:
    existingClaim: pvc-abs-config
  audiobooks:
    hostPath: /mnt/gluster/media/audiobooks
    type: hostPath
  metadata:
    hostPath: /mnt/gluster/media/metadata
    type: hostPath
env:
  TZ: America/Denver
  PUID: "1000"
  PGID: "1000"
ingress:
  main:
    enabled: true
    annotations:
      traefik.ingress.kubernetes.io/router.entrypoints: web
    hosts:
      - host: abs.rahl.cc
        paths:
          - /
EOF

# Create namespace & install
kubectl create namespace media
helm install audiobookshelf truecharts/audiobookshelf -n media -f abs-values.yaml
```

---

## 8. Verification

```bash
kubectl -n media get pods,svc
curl -H "Host: abs.rahl.cc" http://localhost:31080
```

Open `https://abs.rahl.cc` in a browser to confirm the UI loads.

---

## 9. Multi-node Notes

* When new nodes join the cluster, NodePorts `31080/31443` automatically appear on every node.
* Traefik replicas and backend pods load-balance across nodes; no NPM change required.

---

## 10. Snapshot & GitHub Workflow

```bash
git clone git@github.com:luke7524811/homelab-scripts.git
cd homelab-scripts
git checkout -b walkthroughs/k3s-traefik-abs-2025-07-31

mkdir -p walkthroughs
cp /path/to/this.md walkthroughs/k3s-traefik-abs-2025-07-31.md

echo "- [K3s + Traefik + Audiobookshelf Walkthrough (2025-07-31)](walkthroughs/k3s-traefik-abs-2025-07-31.md)" >> README.md

git add walkthroughs/k3s-traefik-abs-2025-07-31.md README.md
git commit -m "feat: add K3s + Traefik + ABS walkthrough (2025-07-31)"
git push -u origin walkthroughs/k3s-traefik-abs-2025-07-31
```

Create a pull request on GitHub and merge after review.

