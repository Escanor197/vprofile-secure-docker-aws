# AWS deployment guide

## Prerequisites

- A private EC2 instance with no public IP.
- An Application Load Balancer in public subnet(s).
- A bastion host in a public subnet.
- Docker Engine and the Docker Compose plugin on the private EC2 instance.
- Outbound access from the private EC2 instance through a NAT gateway or suitable VPC endpoints when pulling images or cloning the application source.
- Recommended lab sizing: at least 4 vCPU, 16 GiB RAM, and 100 GiB encrypted gp3 storage.

## 1. Transfer the repository through the bastion

From your workstation, keep the private key locally and use SSH ProxyJump:

```bash
scp -r \
  -o ProxyJump=ec2-user@BASTION_PUBLIC_IP \
  -i YOUR_KEY.pem \
  vprofile-secure-docker-aws \
  ec2-user@APP_EC2_PRIVATE_IP:/home/ec2-user/
```

Connect to the private EC2 instance:

```bash
ssh \
  -J ec2-user@BASTION_PUBLIC_IP \
  -i YOUR_KEY.pem \
  ec2-user@APP_EC2_PRIVATE_IP
```

Do not copy the private key onto the bastion host.

## 2. Configure the deployment

```bash
cd ~/vprofile-secure-docker-aws
cp .env.example .env
vi .env
```

Set `APP_BIND_IP` to the private IP of the Docker EC2 instance. Set the image variables to local image names or private registry references.

## 3. Prepare the host and secrets

```bash
chmod +x scripts/*.sh docker/rabbitmq/secure-entrypoint.sh
sudo ./scripts/prepare-host.sh
sudo ./scripts/generate-secrets.sh
```

The application secret is created as `root:10001` with mode `0440`, allowing the non-root Tomcat process to read it without making it world-readable.

## 4. Build or pull images

Build directly on the EC2 host:

```bash
sudo docker compose build --pull
```

For images already pushed to a registry, update the image references in `.env`, then run:

```bash
sudo docker compose pull
```

A private EC2 instance requires outbound connectivity to reach GitHub and image registries. A bastion alone does not provide outbound Internet access.

## 5. Start the stack

```bash
sudo docker compose config --quiet
sudo ./scripts/deploy.sh
sudo docker compose ps
```

Follow the application logs:

```bash
sudo docker compose logs -f app
```

## 6. Configure the ALB target group

- Target type: `Instances`
- Protocol: `HTTP`
- Port: `8080`
- Health check path: `/`
- Success codes: `200-399`
- EC2 security group source for port `8080`: ALB security group only

Terminate TLS at the ALB with an ACM certificate. Redirect HTTP port `80` to HTTPS port `443`.

## 7. Verify exposure

```bash
sudo docker compose ps
sudo ss -lntp
```

Only the application port should be published. Backend services should show no host port mappings.
