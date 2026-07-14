# Architecture

## AWS layout

```mermaid
flowchart LR
    User[Internet user] --> ALB[Application Load Balancer]
    Admin[Administrator] --> Bastion[Bastion host]

    subgraph Public[Public subnet layer]
        ALB
        Bastion
    end

    subgraph Private[Private application subnet]
        EC2[Private EC2 Docker host]
    end

    ALB -->|HTTP 8080 from ALB security group| EC2
    Bastion -->|SSH 22 from bastion security group| EC2

    subgraph Stack[Docker Compose stack on EC2]
        App[Tomcat application]
        DB[MySQL db01]
        Cache[Memcached mc01]
        MQ[RabbitMQ rmq01]
        Search[Elasticsearch vprosearch01]

        App --> DB
        App --> Cache
        App --> MQ
        App --> Search
    end

    EC2 --> Stack
```

The ALB is the only application entry point. The Docker host has no public IPv4 address. The bastion is used only for controlled administrative access.

## Container isolation

```mermaid
flowchart TB
    Host[EC2 private IP port 8080] --> App[app]
    App -->|db_net| DB[db01]
    App -->|cache_net| Cache[mc01]
    App -->|mq_net| MQ[rmq01]
    App -->|search_net| Search[vprosearch01]
```

Only `app:8080` is published on the EC2 host. All backend networks are marked `internal: true`, and backend service ports are not published.

## Security-group matrix

| Security group | Inbound rule | Source |
|---|---:|---|
| ALB SG | 443 | Intended clients or the Internet |
| ALB SG | 80 | Optional HTTP-to-HTTPS redirect |
| Docker EC2 SG | 8080 | ALB SG only |
| Docker EC2 SG | 22 | Bastion SG only |
| Bastion SG | 22 | Administrator public IP `/32` only |

Do not open MySQL `3306`, RabbitMQ `5672`, Memcached `11211`, Elasticsearch `9200/9300`, or RabbitMQ management `15672` on the EC2 security group.
