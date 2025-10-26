<div align="center">

# 🐳 Inception

### Docker Infrastructure with NGINX, WordPress & MariaDB

<p>
  <img src="https://img.shields.io/badge/Score-100%2F100-success?style=for-the-badge&logo=42" alt="Score"/>
  <img src="https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker&logoColor=white" alt="Docker"/>
  <img src="https://img.shields.io/badge/NGINX-TLS%201.3-009639?style=for-the-badge&logo=nginx&logoColor=white" alt="NGINX"/>
  <img src="https://img.shields.io/badge/WordPress-PHP--FPM-21759B?style=for-the-badge&logo=wordpress&logoColor=white" alt="WordPress"/>
  <img src="https://img.shields.io/badge/MariaDB-Database-003545?style=for-the-badge&logo=mariadb&logoColor=white" alt="MariaDB"/>
  <img src="https://img.shields.io/badge/Circle-05-purple?style=for-the-badge&logo=42&logoColor=white" alt="Circle 05"/>
  <img src="https://img.shields.io/badge/42-Urduliz-000000?style=for-the-badge&logo=42&logoColor=white" alt="42 Urduliz"/>
</p>

*A multi-container Docker infrastructure featuring NGINX with TLS, WordPress with php-fpm, and MariaDB, orchestrated with Docker Compose.*

[Overview](#-overview) • [Architecture](#-architecture) • [Services](#-services) • [Setup](#-setup) • [Usage](#-usage)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Services](#-services)
- [Project Structure](#-project-structure)
- [Configuration](#-configuration)
- [Docker Images](#-docker-images)
- [Networking](#-networking)
- [Volumes](#-volumes)
- [Security](#-security)
- [Setup](#-setup)
- [Usage](#-usage)
- [Technical Challenges](#-technical-challenges)
- [Resources](#-resources)

---

## 🎯 Overview

**Inception** is a system administration project that demonstrates Docker containerization and orchestration. The infrastructure consists of three independent services running in dedicated containers, connected through a custom Docker network, and managed with Docker Compose.

### Why This Project Matters

- **Container orchestration**: Hands-on experience with Docker Compose and multi-container applications
- **Service isolation**: Each service runs in its own container with dedicated resources
- **Production practices**: TLS encryption, environment variables, health checks, volume persistence
- **Infrastructure as Code**: Declarative configuration with Dockerfiles and docker-compose.yml

### Project Specifications

- **3 Core Services**: NGINX, WordPress, MariaDB
- **Custom Dockerfiles**: Built from Alpine/Debian base images
- **TLS Encryption**: NGINX with TLSv1.2/1.3 only (port 443)
- **Persistent Storage**: Docker volumes for database and website files
- **Auto-restart**: Containers automatically restart on crash
- **Health Checks**: Service dependency management with health checks
- **Environment Variables**: Credentials stored in `.env` file
- **No Hacks**: Proper daemon/PID 1 handling (no `tail -f`, `sleep infinity`)

---

## 🏗️ Architecture

### Infrastructure Diagram

```
┌───────────────────────────────────────────────────────┐
│                     HOST MACHINE                      │
│                                                       │
│  ┌─────────────────────────────────────────────────┐  │
│  │           Docker Bridge Network                 │  │
│  │                                                 │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────┐ │  │
│  │  │   NGINX      │  │  WordPress   │  │MariaDB │ │  │
│  │  │   (Alpine)   │  │  (Debian)    │  │(Debian)│ │  │
│  │  │              │  │              │  │        │ │  │
│  │  │  Port: 443   │  │  Port: 9000  │  │Port:   │ │  │
│  │  │  TLS 1.3     │◄─┤  PHP-FPM 7.4 │◄─┤  3306  │ │  │
│  │  │              │  │              │  │        │ │  │
│  │  └──────┬───────┘  └──────┬───────┘  └───┬────┘ │  │
│  │         │                 │              │      │  │
│  └─────────┼─────────────────┼──────────────┼─────-┘  │
│            │                 │              │         │
│     ┌──────▼─────────┬───────▼──────┐   ┌──-▼─────┐   │
│     │  wp_data       │  wp_data     │   │ db_data │   │
│     │  (bind mount)  │  (bind mount)│   │ (bind   │   │
│     │  ~/data/wp_data│  ~/data/wp.. │   │ mount)  │   │
│     └────────────────┴──────────────┘   └─────────┘   │
│                                                       │
└───────────────────────────────────────────────────────┘
        ▲
        │ HTTPS (443)
        │ ingonzal.42.fr
```

### Service Communication

**Request Flow**:
1. **Client** → HTTPS request to `ingonzal.42.fr:443`
2. **NGINX** → Reverse proxy to `wordpress:9000` (FastCGI)
3. **WordPress** → Database queries to `mariadb:3306`
4. **MariaDB** → Returns data to WordPress
5. **WordPress** → Processes PHP, returns HTML
6. **NGINX** → Serves response to client over TLS

---

## 🔑 Services

### Core Services Overview

<table>
<tr>
<td width="33%" valign="top">

### NGINX
**Version**: Latest Alpine  
**Purpose**: Reverse proxy & TLS termination  
**Port**: 443 (HTTPS only)  
**Protocol**: TLSv1.2/1.3

**Features**:
- Self-signed SSL certificate
- FastCGI proxy to WordPress
- Static file serving
- TLS-only (no HTTP)

</td>
<td width="33%" valign="top">

### WordPress
**Version**: Latest Debian  
**Purpose**: CMS with PHP-FPM  
**Port**: 9000 (internal)  
**Runtime**: PHP-FPM 7.4

**Features**:
- WP-CLI installation
- PHP-FPM socket
- Database connection
- 2 users (admin + user)

</td>
<td width="33%" valign="top">

### MariaDB
**Version**: Latest Debian  
**Purpose**: MySQL database  
**Port**: 3306 (internal)  
**Engine**: MariaDB 10.5+

**Features**:
- WordPress database
- 2 database users
- Persistent storage
- Health checks

</td>
</tr>
</table>

---

## 📁 Project Structure

```
inception/
├── Makefile                      # Build and orchestration commands
└── srcs/
    ├── docker-compose.yml        # Service definitions and orchestration
    ├── .env                      # Environment variables (git-ignored)
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile        # MariaDB container definition
        │   ├── conf/
        │   │   └── 50-server.cnf # MariaDB configuration
        │   └── tools/
        │       └── init.sql      # Database initialization script
        ├── nginx/
        │   ├── Dockerfile        # NGINX container definition
        │   ├── conf/
        │   │   └── nginx.conf    # NGINX server configuration
        │   └── tools/
        │       ├── cert.sh       # SSL certificate generation script
        │       └── cnf           # OpenSSL configuration
        └── wordpress/
            ├── Dockerfile        # WordPress container definition
            ├── conf/             # (empty - WP configured via CLI)
            └── tools/
                └── init.sh       # WordPress installation script
```

**File Count**: 3 Dockerfiles, 3 configuration files, 3 initialization scripts

---

## ⚙️ Configuration

### Docker Compose Structure

**Services** (`docker-compose.yml`):
- **version**: `3`
- **services**: `mariadb`, `wordpress`, `nginx`
- **networks**: `docker_network` (bridge driver)
- **volumes**: `db_data`, `wp_data` (bind mounts to `~/data/`)

**Key Features**:
- `depends_on` with health checks for startup ordering
- `restart: unless-stopped` for auto-recovery
- `expose` for internal ports (not published to host)
- `ports` only on NGINX (443:443)

<details>
<summary><b>Full docker-compose.yml</b></summary>

```yaml
version: '3'

services:
  mariadb:
    build:
      context: .
      dockerfile: requirements/mariadb/Dockerfile
    image: mariadb
    container_name: mariadb
    env_file: .env
    volumes:
      - db_data:/var/lib/mysql
    expose:
      - "3306"
    restart: unless-stopped
    networks:
      - docker_network
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 5s
      retries: 5

  wordpress:
    build:
      context: .
      dockerfile: requirements/wordpress/Dockerfile
    container_name: wordpress
    image: wordpress
    depends_on:
      mariadb:
        condition: service_healthy
    env_file: .env
    volumes:
      - wp_data:/var/www/inception/wordpress
    expose:
      - "9000"
    restart: unless-stopped
    networks:
      - docker_network
    healthcheck:
      test: ["CMD", "pidof", "php-fpm7.4", ">/dev/null"]
      interval: 5s
      retries: 30

  nginx:
    build:
      context: .
      dockerfile: requirements/nginx/Dockerfile
    container_name: nginx
    image: nginx
    depends_on:
      wordpress:
        condition: service_healthy
    env_file: .env
    volumes:
      - wp_data:/var/www/inception/wordpress
    ports:
      - "443:443"
    restart: unless-stopped
    networks:
      - docker_network

networks:
  docker_network:
    driver: bridge

volumes:
  db_data:
    driver: local
    driver_opts:
      type: none
      device: ${HOME}/data/db_data
      o: bind
  wp_data:
    driver: local
    driver_opts:
      type: none
      device: ${HOME}/data/wp_data
      o: bind
```

</details>

### Environment Variables

**`.env` file** (git-ignored):
```bash
# Domain configuration
DOMAIN_NAME=ingonzal.42.fr

# MariaDB credentials
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=wp_password

# WordPress credentials
WP_ADMIN_USER=admin_user
WP_ADMIN_PASSWORD=admin_password
WP_ADMIN_EMAIL=admin@example.com
WP_USER=regular_user
WP_USER_PASSWORD=user_password
WP_USER_EMAIL=user@example.com
```

**Security Note**: Never commit `.env` to version control. Use strong passwords in production.

---

## 🐋 Docker Images

### Dockerfile Overview

Each service has a **custom Dockerfile** built from Alpine or Debian base images.

<table>
<tr>
<td width="33%" valign="top">

### MariaDB Dockerfile
**Base**: `debian:bullseye`

**Steps**:
1. Install MariaDB server
2. Copy custom config (`50-server.cnf`)
3. Copy init script (`init.sql`)
4. Expose port 3306
5. Run `mysqld` as PID 1

**Key Point**: No `tail -f` hacks, proper daemon mode

</td>
<td width="33%" valign="top">

### WordPress Dockerfile
**Base**: `debian:bullseye`

**Steps**:
1. Install PHP-FPM 7.4
2. Install WP-CLI
3. Create directory structure
4. Copy init script (`init.sh`)
5. Expose port 9000
6. Run `php-fpm7.4` as PID 1

**Key Point**: WP-CLI installs WordPress programmatically

</td>
<td width="33%" valign="top">

### NGINX Dockerfile
**Base**: `alpine:3.17`

**Steps**:
1. Install NGINX + OpenSSL
2. Copy config (`nginx.conf`)
3. Copy SSL scripts (`cert.sh`, `cnf`)
4. Generate self-signed cert
5. Expose port 443
6. Run `nginx -g 'daemon off;'` as PID 1

**Key Point**: TLS-only, no port 80

</td>
</tr>
</table>

<details>
<summary><b>MariaDB Dockerfile Example</b></summary>

```dockerfile
FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

COPY requirements/mariadb/conf/50-server.cnf /etc/mysql/mariadb.conf.d/
COPY requirements/mariadb/tools/init.sql /docker-entrypoint-initdb.d/

EXPOSE 3306

CMD ["mysqld"]
```

</details>

---

## 🔗 Networking

### Docker Bridge Network

**Network Name**: `docker_network`  
**Driver**: `bridge`  
**Subnet**: Auto-assigned by Docker

**Service Hostnames**:
- `mariadb` → resolves to MariaDB container IP
- `wordpress` → resolves to WordPress container IP
- `nginx` → resolves to NGINX container IP

**Port Mapping**:
- **NGINX**: `0.0.0.0:443 → nginx:443` (published)
- **WordPress**: `wordpress:9000` (internal only)
- **MariaDB**: `mariadb:3306` (internal only)

**DNS Resolution**: Docker's embedded DNS server resolves container names to IPs automatically.

### Network Security

- Only **NGINX** is exposed to the host (port 443)
- **WordPress** and **MariaDB** are isolated from external access
- Inter-container communication via internal bridge network
- TLS encryption for all external traffic

---

## 💾 Volumes

### Persistent Storage

**Two volumes** for data persistence:

| Volume | Mount Point (Container) | Host Path | Purpose |
|--------|--------------------------|-----------|---------|
| `db_data` | `/var/lib/mysql` | `~/data/db_data` | MariaDB database files |
| `wp_data` | `/var/www/inception/wordpress` | `~/data/wp_data` | WordPress files (themes, plugins, uploads) |

**Volume Type**: **Bind mounts** (not anonymous volumes)

**Benefits**:
- Data persists across container restarts
- Easy backup/restore (just copy host directory)
- Shared access (wp_data mounted in both WordPress and NGINX)

**Lifecycle**:
```bash
# Created by Makefile
mkdir -p ~/data/db_data
mkdir -p ~/data/wp_data

# Removed by Makefile clean targets
rm -rf ~/data/db_data
rm -rf ~/data/wp_data
```

---

## 🔒 Security

### TLS/SSL Configuration

**NGINX TLS Settings**:
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;
ssl_prefer_server_ciphers on;
```

**Certificate Generation**:
- **Type**: Self-signed certificate
- **Algorithm**: RSA 2048-bit
- **Validity**: 365 days
- **CN**: `ingonzal.42.fr`

<details>
<summary><b>Certificate Generation Script (cert.sh)</b></summary>

```bash
#!/bin/sh

# Generate SSL certificate for NGINX
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -config /etc/nginx/ssl/cnf \
    -subj "/C=ES/ST=Euskadi/L=Urduliz/O=42/OU=Student/CN=ingonzal.42.fr"
```

</details>

### Credential Management

**Environment Variables**:
- All credentials stored in `.env` file
- `.env` added to `.gitignore`
- No hardcoded passwords in Dockerfiles

**Database Security**:
- Separate `root` and `wordpress` database users
- Non-admin WordPress user has limited database privileges
- Admin usernames cannot contain "admin", "administrator"

---

## 🛠️ Setup

### Prerequisites

**Host Requirements**:
- Virtual Machine (Debian/Ubuntu recommended)
- Docker Engine 20.10+
- Docker Compose 1.29+
- Make utility
- 2+ GB free disk space

**Installation**:
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt-get install docker-compose-plugin

# Verify installation
docker --version
docker compose version
```

### Domain Configuration

**Add entry to `/etc/hosts`**:
```bash
# Edit hosts file
sudo nano /etc/hosts

# Add line
127.0.0.1  ingonzal.42.fr
```

**Note**: Replace `ingonzal` with your 42 login.

### Environment Setup

**Create `.env` file**:
```bash
cd inception/srcs
cp .env.example .env  # If example provided
nano .env             # Edit credentials
```

**Set permissions**:
```bash
chmod 600 .env  # Readable only by owner
```

---

## 🚀 Usage

### Makefile Commands

**Build and start infrastructure**:
```bash
make        # or: make all
```

**Operations**:
```bash
make down     # Stop and remove containers (keeps volumes)
make fclean   # Stop, remove containers, prune networks/images
make re       # Rebuild from scratch (fclean + all)
make destroy  # Nuclear option: remove everything including volumes
```

<details>
<summary><b>Full Makefile</b></summary>

```makefile
NAME = Inception

$(NAME):
	@mkdir -p ${HOME}/data/db_data
	@mkdir -p ${HOME}/data/wp_data
	@docker-compose -f srcs/docker-compose.yml up -d --build

down:
	@docker-compose -f srcs/docker-compose.yml down --rmi all -v

destroy:
	@docker-compose -f srcs/docker-compose.yml down --rmi all; \
	docker volume rm srcs_db_data; docker volume rm srcs_wp_data; \
	docker system prune -a -f; docker network prune -f; \
	rm -rf ${HOME}/data/db_data; rm -rf ${HOME}/data/wp_data;

all: $(NAME)

fclean: down
	@docker network prune -f; \
	docker system prune -a -f

re: fclean all

.PHONY: all destroy down fclean re
```

</details>

### Accessing the Site

1. **Build infrastructure**:
   ```bash
   make
   ```

2. **Wait for services** (check logs):
   ```bash
   docker-compose -f srcs/docker-compose.yml logs -f
   ```

3. **Open browser**:
   ```
   https://ingonzal.42.fr
   ```

4. **Accept self-signed certificate** (browser warning is expected)

5. **WordPress setup**:
   - If automated: Site already configured
   - If manual: Follow WordPress installation wizard

### Debugging Commands

**Check container status**:
```bash
docker ps -a
```

**View logs**:
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

**Enter container**:
```bash
docker exec -it nginx /bin/sh
docker exec -it wordpress /bin/bash
docker exec -it mariadb /bin/bash
```

**Test database connection**:
```bash
docker exec -it mariadb mysql -u wp_user -p
# Enter password, then:
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
```

**Test PHP-FPM**:
```bash
docker exec -it wordpress pidof php-fpm7.4
```

**Test NGINX config**:
```bash
docker exec -it nginx nginx -t
```

---

## 🔬 Technical Challenges

### Challenge 1: PID 1 and Daemon Management

**Problem**: Containers must run daemons as PID 1 without hacks like `tail -f` or `sleep infinity`.

**Solution**: 
- **NGINX**: `CMD ["nginx", "-g", "daemon off;"]` runs nginx in foreground
- **PHP-FPM**: `CMD ["php-fpm7.4", "-F"]` runs php-fpm in foreground (`-F` flag)
- **MariaDB**: `CMD ["mysqld"]` runs mysqld as PID 1 (no wrapper scripts)

**Why**: PID 1 receives SIGTERM for graceful shutdown. Wrapper scripts break signal handling.

### Challenge 2: Service Startup Dependencies

**Problem**: WordPress needs MariaDB ready before connection. NGINX needs WordPress ready before proxying.

**Solution**: Health checks with `depends_on` conditions:
```yaml
depends_on:
  mariadb:
    condition: service_healthy
```

**MariaDB Health Check**:
```yaml
healthcheck:
  test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
  interval: 5s
  retries: 5
```

**WordPress Health Check**:
```yaml
healthcheck:
  test: ["CMD", "pidof", "php-fpm7.4", ">/dev/null"]
  interval: 5s
  retries: 30
```

### Challenge 3: WordPress Installation Automation

**Problem**: WordPress needs database connection and initial setup before NGINX can serve requests.

**Solution**: **init.sh** script with WP-CLI:
```bash
# Wait for database
while ! mysqladmin ping -h mariadb; do sleep 1; done

# Download WordPress
wp core download --path=/var/www/inception/wordpress

# Configure database connection
wp config create --dbname=wordpress --dbuser=wp_user --dbpass=$MYSQL_PASSWORD

# Install WordPress
wp core install --url=$DOMAIN_NAME --title="Inception" --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL

# Create second user
wp user create $WP_USER $WP_USER_EMAIL --user_pass=$WP_USER_PASSWORD
```

### Challenge 4: TLS-Only Configuration

**Problem**: NGINX must only accept TLS 1.2/1.3 on port 443, no HTTP on port 80.

**Solution**: 
- No `listen 80` directive in nginx.conf
- `ssl_protocols TLSv1.2 TLSv1.3;` explicitly set
- Self-signed certificate generated at build time
- All HTTP traffic rejected (no redirect, just unavailable)

### Challenge 5: Volume Bind Mounts

**Problem**: Docker Compose volumes must bind to host directories in `~/data/`.

**Solution**: Driver options for local volumes:
```yaml
volumes:
  db_data:
    driver: local
    driver_opts:
      type: none
      device: ${HOME}/data/db_data
      o: bind
```

**Makefile creates directories** before docker-compose runs:
```makefile
$(NAME):
	@mkdir -p ${HOME}/data/db_data
	@mkdir -p ${HOME}/data/wp_data
```

---

## 📚 Resources

### Docker Documentation

**Docker Engine**:
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Networking](https://docs.docker.com/network/)
- [Docker Volumes](https://docs.docker.com/storage/volumes/)
- [PID 1 Signal Handling](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#entrypoint)

**Docker Compose**:
- [Compose File Reference v3](https://docs.docker.com/compose/compose-file/compose-file-v3/)
- [Health Checks](https://docs.docker.com/compose/compose-file/compose-file-v3/#healthcheck)
- [Depends On](https://docs.docker.com/compose/compose-file/compose-file-v3/#depends_on)
- [Environment Variables](https://docs.docker.com/compose/environment-variables/)

### Service Documentation

**NGINX**:
- [NGINX Configuration](https://nginx.org/en/docs/beginners_guide.html)
- [NGINX SSL Configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [FastCGI with PHP](https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/)

**WordPress**:
- [WP-CLI Commands](https://developer.wordpress.org/cli/commands/)
- [WordPress Configuration](https://wordpress.org/support/article/editing-wp-config-php/)
- [PHP-FPM Configuration](https://www.php.net/manual/en/install.fpm.configuration.php)

**MariaDB**:
- [MariaDB Configuration](https://mariadb.com/kb/en/configuring-mariadb/)
- [MySQL Initialization](https://dev.mysql.com/doc/refman/8.0/en/data-directory-initialization.html)
- [MariaDB Security](https://mariadb.com/kb/en/securing-mariadb/)

### Security & TLS

**SSL/TLS**:
- [OpenSSL Certificate Generation](https://www.openssl.org/docs/man1.1.1/man1/req.html)
- [TLS Best Practices](https://wiki.mozilla.org/Security/Server_Side_TLS)
- [Self-Signed Certificates](https://letsencrypt.org/docs/certificates-for-localhost/)

**Docker Security**:
- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Environment Variables in Docker](https://docs.docker.com/compose/environment-variables/)
- [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)

### System Administration

**Linux Tools**:
- [Systemd and Services](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [Process Management](https://man7.org/linux/man-pages/man1/ps.1.html)
- [Network Configuration](https://man7.org/linux/man-pages/man8/ip.8.html)

---

## 💡 What I Learned

**Docker Fundamentals**:
- ✅ Writing production-ready Dockerfiles (no hacks, proper PID 1)
- ✅ Multi-container orchestration with Docker Compose
- ✅ Docker networking (bridge networks, service discovery)
- ✅ Volume management (bind mounts vs named volumes)
- ✅ Health checks and service dependencies

**System Administration**:
- ✅ NGINX reverse proxy configuration
- ✅ TLS/SSL certificate generation and configuration
- ✅ FastCGI protocol (NGINX ↔ PHP-FPM)
- ✅ Database initialization and user management
- ✅ Environment variable management

**WordPress Stack**:
- ✅ WordPress installation with WP-CLI
- ✅ PHP-FPM configuration and optimization
- ✅ MariaDB setup and configuration
- ✅ Multi-user WordPress setup

**DevOps Practices**:
- ✅ Infrastructure as Code (Dockerfiles, docker-compose.yml)
- ✅ Automated deployment with Makefile
- ✅ Log management and debugging
- ✅ Graceful shutdown and restart policies

**Security**:
- ✅ TLS-only configuration (no plaintext HTTP)
- ✅ Credential management with environment variables
- ✅ Container isolation and network security
- ✅ Principle of least privilege (database users)

---

## 🎯 Key Takeaways

### For Docker

1. **PID 1 is critical** for signal handling and graceful shutdown
2. **Health checks** enable reliable service dependencies
3. **Bind mounts** provide easy host access to container data
4. **Bridge networks** enable secure inter-container communication
5. **No hacks**: Proper daemon management beats workarounds

### For Web Infrastructure

1. **Reverse proxies** centralize TLS termination and routing
2. **FastCGI** separates web server from application runtime
3. **Database isolation** improves security and scalability
4. **Environment variables** separate config from code
5. **TLS-only** is non-negotiable for production

### For System Administration

1. **Automation** (Makefile) reduces human error
2. **Idempotency** enables safe repeated runs
3. **Logging** is essential for debugging
4. **Health monitoring** catches failures early
5. **Documentation** saves time during incidents

---

## 🔗 Related Projects

**Prerequisites**:
- **Born2beRoot**: Linux system administration, services, security
- **NetPractice**: TCP/IP networking, subnetting

**Related**:
- **Webserv**: HTTP server implementation, networking
- **ft_transcendence**: Full-stack web application with Docker

**Skills Apply To**:
- Microservices architecture
- Kubernetes orchestration
- CI/CD pipelines
- Cloud infrastructure (AWS ECS, GCP Cloud Run)
- Production web hosting

---

<div align="center">

**Made with ☕ by [Iñigo Gonzalez](https://github.com/Z3n42)**

*42 Urduliz | Circle 05*

[![42 Profile - ingonzal](https://img.shields.io/badge/42_Intra-ingonzal-000000?style=flat&logo=42&logoColor=white)](https://profile.intra.42.fr/users/ingonzal)
[![GitHub - Z3n42](https://img.shields.io/badge/GitHub-Z3n42-181717?style=flat&logo=github)](https://github.com/Z3n42)

</div>
