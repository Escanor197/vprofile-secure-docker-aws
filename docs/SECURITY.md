# Security guide

## Implemented controls

- Tomcat runs as UID/GID `10001`, not root.
- Runtime credentials are loaded from files under `/run/secrets`.
- The application root filesystem is read-only.
- Linux capabilities are dropped wherever practical.
- `no-new-privileges` is enabled for every service.
- Backend services use dedicated internal Docker networks.
- Only the Tomcat port is published on the EC2 private IP.
- Memcached UDP is disabled.
- RabbitMQ uses a dedicated user and `/vprofile` virtual host instead of remote `guest/guest`.
- MySQL uses a dedicated application user and TLS-required client configuration.
- Persistent data uses named volumes.
- Health checks, restart policies, resource limits, PID limits, and log rotation are configured.

## Required AWS controls

- ALB listener on HTTPS `443` with an ACM certificate.
- HTTP `80` redirects to HTTPS.
- EC2 port `8080` accepts traffic only from the ALB security group.
- EC2 SSH `22` accepts traffic only from the bastion security group.
- Bastion SSH `22` accepts traffic only from a trusted administrator IP `/32`.
- The private EC2 instance has no public IPv4 address.
- Use encrypted EBS volumes and snapshots.
- Require IMDSv2.
- Restrict the EC2 instance role to minimum permissions.
- Enable ALB access logs and consider AWS WAF for an Internet-facing lab.

## Secret handling

Never commit `.env` or files under `secrets/`. The source secret files remain on the EC2 filesystem because standalone Compose uses file-backed mounts. Protect the EC2 volume, keep the secret directory owned by root, and rotate credentials when access changes.

Do not solve permission problems by running Tomcat as root or using `chmod 777`.

## Known legacy dependency risk

The training application depends on old Spring and Elasticsearch libraries and uses the Elasticsearch 5.6 transport client. Elasticsearch 5.6.4 is isolated on an internal Docker network and is not exposed on the host, but the application stack should not be treated as production-grade until those dependencies are upgraded.
