# Building and Running the Website with Docker

This document provides instructions for building a Docker image for this website and running it as a container. This approach uses a multi-stage Docker build to create a small, optimized production image.

## Dockerfile

The following `Dockerfile` defines the build process:

```dockerfile
# Stage 1: Build the Hugo site
FROM docker.io/library/node:20-alpine AS builder

# Install Git and Hugo
ARG HUGO_VERSION=0.133.0
RUN apk add --no-cache git libc6-compat libstdc++
RUN wget "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz" -O /tmp/hugo.tar.gz && \
    tar -xzf /tmp/hugo.tar.gz -C /usr/local/bin/ hugo && \
    rm /tmp/hugo.tar.gz

WORKDIR /src

# Install Node.js dependencies (including Docsy theme)
COPY package.json package-lock.json ./
# Use --legacy-peer-deps if needed for older theme versions, but try without first
RUN npm ci

# Copy the rest of the website source
COPY . .

# Build the static site
# Using --minify for smaller output size
RUN hugo --minify

# Stage 2: Serve the built site with Nginx
FROM docker.io/library/nginx:stable-alpine AS final

# Copy the built site from the builder stage
COPY --from=builder /src/public /usr/share/nginx/html

# Expose port 80 for Nginx
EXPOSE 80

# Default command to start Nginx
CMD ["nginx", "-g", "daemon off;"]
```

**Explanation:**

1.  **Build Stage (`builder`):**
    *   Starts from a Node.js Alpine image.
    *   Installs Git (needed for theme modules) and Hugo `v0.133.0-extended`.
    *   Copies `package.json` and `package-lock.json`.
    *   Runs `npm ci` to install Node dependencies (like PostCSS and the Docsy theme).
    *   Copies the entire website source code.
    *   Runs `hugo --minify` to build the static website into the `/src/public` directory.
2.  **Runtime Stage (`final`):**
    *   Starts from a lightweight Nginx Alpine image.
    *   Copies *only* the built static files from the `/src/public` directory of the `builder` stage into Nginx's web root (`/usr/share/nginx/html`).
    *   Exposes port 80.
    *   Sets the default command to start Nginx.

## Building the Image

To build the Docker image, navigate to the directory containing the `Dockerfile` (the project root) and run:

```bash
docker build -t website-image:latest .
```

Replace `website-image:latest` with your desired image name and tag.

## Running the Container

To run the website container:

```bash
docker run -d -p 8080:80 --name website-container website-image:latest
```

**Explanation:**

*   `docker run`: Starts a new container.
*   `-d`: Runs the container in detached mode (in the background).
*   `-p 8080:80`: Maps port 8080 on your host machine to port 80 inside the container (where Nginx is listening). You can change `8080` to any available port on your host.
*   `--name website-container`: Assigns a name to the container for easier management.
*   `website-image:latest`: Specifies the image to use.

You should then be able to access the website by navigating to `http://localhost:8080` in your web browser.

To stop the container:

```bash
docker stop website-container
```

To remove the container:

```bash
docker rm website-container
