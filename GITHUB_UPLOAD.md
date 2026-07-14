# Upload this project to GitHub

Recommended repository name:

```text
vprofile-secure-docker-aws
```

Recommended description:

```text
Secure multi-container VProfile deployment with Docker Compose on a private AWS EC2 instance behind an Application Load Balancer.
```

Recommended topics:

```text
docker docker-compose aws ec2 alb bastion java tomcat mysql rabbitmq memcached elasticsearch devops container-security
```

Create an empty GitHub repository without generating a README, `.gitignore`, or license. Then run:

```bash
cd vprofile-secure-docker-aws
git init
git add .
git commit -m "Initial secure VProfile Docker Compose deployment"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/vprofile-secure-docker-aws.git
git push -u origin main
```

Before pushing, confirm no secrets are staged:

```bash
git status
git ls-files | grep -E '(^|/)(\.env|secrets/)' || true
```

Only `secrets/.gitignore` should appear from the `secrets` directory.
