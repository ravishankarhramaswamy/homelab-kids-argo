# JClic.js

Static JClic.js launcher served by NGINX. It hosts an index page and an `/activities` folder where you can upload `.jclic.zip` activity packs.

## Defaults
- Hostname: `jclic.family.home.arpa`
- Namespace: `games-jclic`
- Routing: Gateway API `HTTPRoute` via Envoy Gateway (`family-gateway`)
- Image: `nginx:1.27-alpine`

## Activities
Upload `.jclic.zip` files into the `/activities` directory (PVC-backed by default).
Then set `content.projectUrl` in `values.yaml`, for example:

```
/activities/my-activity.jclic.zip
```

## Notes
- The included index page loads JClic.js from a CDN. Update the script URLs if you want to self-host the library.
- If you disable persistence, activities must be copied into the pod on every restart.
