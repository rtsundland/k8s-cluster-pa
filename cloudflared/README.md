# Cloudflare Zero-Trust

## Easiest Install Ever
Go to Cloudflare Zero Trust and create a new Tunnel configuration (Networks > Tunnels).  Use the generated token to populate the TUNNEL_TOKEN variable in cloudflared.secret.

Then run the following command:
```
(source cloudflared.secret && envsubst < values.yaml) | helm upgrade --install --create-namespace -n cloudflared cloudflared oci://tccr.io/truecharts/cloudflared -f -
```

