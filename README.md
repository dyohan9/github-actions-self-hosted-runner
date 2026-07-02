# GitHub Actions Self-Hosted Runner (Docker)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)

Run one or many GitHub Actions Self-Hosted Runners inside Docker containers while sharing the host Docker Engine.

This project allows you to deploy a scalable pool of GitHub Actions runners on a single VPS or dedicated server.

Unlike the official setup, this image already includes:

- ✅ Docker CLI
- ✅ Docker Compose
- ✅ Docker Buildx
- ✅ Automatic runner registration
- ✅ Automatic runner cleanup
- ✅ Organization support
- ✅ Multiple runners using Docker Compose

---

## Architecture

```
                    GitHub

                       │

             Workflow Dispatch

                       │

         runs-on: self-hosted

                       │

              Docker Compose

         ┌─────────┬─────────┐
         │         │         │
      Runner1   Runner2   Runner3
         │         │         │
         └─────────┴─────────┘

                Docker Socket

          /var/run/docker.sock

                     │

             Docker Engine Host
```

Every runner is an independent container.

They all share the host Docker daemon, allowing workflows to execute:

- `docker build`
- `docker compose`
- `docker push`
- `docker pull`
- `docker buildx`

without running Docker-in-Docker.

---

## Features

- Ubuntu 24.04
- GitHub Actions Runner
- Docker CLI
- Docker Compose
- Docker Buildx
- Automatic registration
- Automatic deregistration
- Organization Runner
- Docker Compose scaling
- Lightweight image
- **Helper Scripts** to simplify deployment and scaling

---

## Requirements

- Ubuntu 24.04
- Docker Engine
- Docker Compose
- GitHub Personal Access Token

---

## Create a GitHub Personal Access Token

Create a Classic Personal Access Token.

Required permissions:

```
admin:org
repo:workflow
```

---

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/dyohan9/github-actions-self-hosted-runner.git
cd github-actions-self-hosted-runner
```

### 2. Configure Environment

Copy the example configuration:

```bash
cp .env.example .env
```

Edit the `.env` file with your details:

```env
ACCESS_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxx

ORG=YOUR_ORGANIZATION
```

### 3. Build

Run the build script, which automatically resolves your Docker Group ID to ensure socket permissions work inside the container.

```bash
./scripts/build.sh
```

### 4. Start

Start the default number of runners (4 instances):

```bash
./scripts/up.sh
```

If you want to start a specific number of runners (e.g., 8), pass the number as an argument:

```bash
./scripts/up.sh 8
```

---

## Managing Runners

### Scaling

Increase to 20 runners:

```bash
./scripts/up.sh 20
```

Decrease to 5 runners:

```bash
./scripts/up.sh 5
```

### Logs

To view the output of all runners:

```bash
./scripts/logs.sh
```

### Updating

If you need to pull latest changes or rebuild the image, run:

```bash
./scripts/rebuild.sh
```

### Stop

To stop and remove all runner containers safely:

```bash
./scripts/down.sh
```

---

## Verify

1. Go to your GitHub Organization Settings.
2. Click on **Actions** > **Runners**.
3. You should see your instances listed as `Idle`:

```
runner-91aab   Idle
runner-a19df   Idle
runner-ef991   Idle
runner-c12ab   Idle
```

---

## Example Workflow

```yaml
name: Test Runner

on:
  workflow_dispatch:

jobs:
  test:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4
      - run: whoami
      - run: docker version
      - run: docker compose version
      - run: docker buildx version
```

---

## Troubleshooting

### `docker: command not found`

Docker CLI is not installed inside the image. Rebuild the image:
```bash
./scripts/rebuild.sh
```

### `permission denied while trying to connect to docker.sock`

The Docker group id inside the container does not match the host. Our build script should handle this automatically, but if it fails, verify your host Docker GID with `getent group docker | cut -d: -f3`.

### Runner Offline

The container stopped unexpectedly. Restart it:
```bash
./scripts/up.sh
```

### Invalid Registration Token

Your Personal Access Token expired or does not have enough permissions. Generate a new token and update your `.env` file.

### Buildx missing

Verify manually inside your workflow:
```bash
docker buildx version
```

---

## Security

- **Never commit:** `.env`
- **Never expose:** `ACCESS_TOKEN`

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

## Credits

This project was originally inspired by:

- https://testdriven.io/blog/github-actions-docker/
- https://baccini-al.medium.com/how-to-containerize-a-github-actions-self-hosted-runner-5994cc08b9fb

This repository modernizes that approach by adding:

- Docker CLI
- Docker Buildx
- Docker Compose
- Organization Runners
- Proper Docker socket permissions
- Modern Ubuntu 24.04 support
- Automated deployment scripts