# K3s VM with Linux Mint GUI + Guacamole Access (2025-08-06)

## ✨ Overview

Deployed a Linux Mint virtual machine (with GUI) on KubeVirt inside a K3s cluster. Configured browser-based remote desktop access via Apache Guacamole using a Cloudflare Tunnel.

---

## 📁 Folder Structure

```
~/homelab-scripts/
├── kubevirt/
│   └── vm-lab/
│       ├── mint-pv-pvc.yaml
│       └── mint-vm.yaml
├── k3s-vm-lab/
    └── guacamole.yaml
```

---

## ✨ Persistent Volume Setup

**File:** `mint-pv-pvc.yaml`

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mint-vm-pv
spec:
  storageClassName: local-path
  capacity:
    storage: "40Gi"
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /mnt/gluster/media/vms/mint-vm.img
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mint-vm-pvc
  namespace: vm-lab
spec:
  storageClassName: local-path
  volumeName: mint-vm-pv
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: "40Gi"
```

**Commands:**

```bash
kubectl create namespace vm-lab
kubectl apply -f ~/homelab-scripts/kubevirt/vm-lab/mint-pv-pvc.yaml
```

---

## 🌟 KubeVirt Virtual Machine Spec

**File:** `mint-vm.yaml`

```yaml
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: linuxmint-vm
  namespace: vm-lab
spec:
  running: true
  template:
    metadata:
      labels:
        kubevirt.io/domain: linuxmint-vm
    spec:
      domain:
        cpu:
          cores: 2
        resources:
          requests:
            memory: 4Gi
        devices:
          disks:
            - name: rootdisk
              disk:
                bus: virtio
            - name: cdromiso
              cdrom:
                bus: sata
            - name: cloudinitdisk
              disk:
                bus: virtio
          interfaces:
            - name: default
              masquerade: {}
      volumes:
        - name: rootdisk
          persistentVolumeClaim:
            claimName: mint-vm-pvc
        - name: cdromiso
          hostDisk:
            path: /mnt/gluster/media/vms/linuxmint.iso
            type: Disk
        - name: cloudinitdisk
          cloudInitNoCloud:
            userData: |
              #cloud-config
              users:
                - name: mint
                  ssh-authorized-keys: []
              chpasswd:
                list: |
                  mint:mint
                expire: False
      networks:
        - name: default
          pod: {}
```

**Commands:**

```bash
kubectl apply -f ~/homelab-scripts/kubevirt/vm-lab/mint-vm.yaml
```

**VNC Access via CLI:**

```bash
virtctl vnc linuxmint-vm -n vm-lab
```

---

## 🚀 Guacamole Deployment (No DB, oznu version)

**File:** `guacamole.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: guacamole
---
apiVersion: v1
kind: Service
metadata:
  name: guacamole
  namespace: guacamole
spec:
  selector:
    app: guacamole
  ports:
    - name: http
      port: 8080
      targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: guacamole
  namespace: guacamole
spec:
  replicas: 1
  selector:
    matchLabels:
      app: guacamole
  template:
    metadata:
      labels:
        app: guacamole
    spec:
      containers:
        - name: guacamole
          image: oznu/guacamole
          ports:
            - containerPort: 8080
```

**Deploy:**

```bash
kubectl apply -f ~/homelab-scripts/k3s-vm-lab/guacamole.yaml
```

**Access URL:** `https://guac.rahl.cc`

* Username: `guacadmin`
* Password: `guacadmin`

---

## ⚙️ Cloudflare Tunnel Config Addition

Add to `cloudflared-config`:

```yaml
- hostname: guac.rahl.cc
  service: http://guacamole.guacamole.svc.cluster.local:8080
```

Then restart:

```bash
kubectl rollout restart deploy cloudflared -n cloudflare-tunnel
```

---

## 📊 Outcome

* Linux Mint VM is running with GUI
* Browser access to VM via Guacamole at `guac.rahl.cc`
* Full deployment done via K3s + KubeVirt + GlusterFS storage

---

## ✅ Next Steps

* Install Mint GUI inside VM
* Set up `x11vnc` for persistent desktop access
* Add MySQL to Guacamole for saved sessions
* Auto-start VMs on node boot
