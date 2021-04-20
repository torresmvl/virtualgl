## This is a sample folder for persisting data within containers restarts

See `docker-compose.yml` and configure your environment

```docker-compose
---
version: '3.8'
services:
  virtualgl:
    . . .
    volumes:
      - ~/.ssh/authorized_keys:/root/.ssh/authorized_keys
      - ./data:/data
```
