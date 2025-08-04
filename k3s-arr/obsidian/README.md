# Obsidian (Self-Hosted)

This deployment runs the full Obsidian app in-browser using the `linuxserver/obsidian` image.

## URL

Accessible via: `https://obsidian.media.rahl.cc` through Cloudflare Tunnel.

## Vault Storage

- Config path: `/mnt/gluster/appdata/obsidian-config`

## User Auth

Login credentials are configured via environment variables:

- **CUSTOM_USER**: obsuser
- **PASSWORD**: obssecurepass

## Namespace

Deployed into: `media`

## Cloudflare Tunnel Entry

Ensure your `cloudflared-config` includes:

```yaml
- hostname: obsidian.media.rahl.cc
  service: http://obsidian.media.svc.cluster.local:3000
