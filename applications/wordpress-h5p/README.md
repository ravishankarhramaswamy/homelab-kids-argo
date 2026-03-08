# WordPress + H5P

Local Helm chart that deploys WordPress and bundles the H5P plugin via an init container.

## Defaults
- Hostname: `h5p.family.home.arpa`
- Namespace: `games-wordpress-h5p`
- Routing: Gateway API `HTTPRoute` via Envoy Gateway (`family-gateway`)
- WordPress image: `wordpress:6.9.1-php8.2-apache`

## Secrets
Create this secret out of band (see examples in `shared/secrets/examples/`):
- `wordpress-mariadb`
  - `mariadb-root-password`
  - `mariadb-password`

## H5P plugin
The chart downloads the plugin from `https://downloads.wordpress.org/plugin/h5p.zip` into
`/var/www/html/wp-content/plugins` on first boot. Override `h5p.pluginUrl` if you want a pinned version.

## Manual post-deploy steps
- Open the site and complete the WordPress install wizard (admin user is created there).
- Activate the H5P plugin from the WordPress admin UI.
- Configure SMTP or outbound email if needed.

## Notes
- If you change database credentials after initial install, you may need to reset the DB volume.
