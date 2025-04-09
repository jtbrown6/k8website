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
# Disable GitInfo as .git is not included in build context
RUN hugo --minify --enableGitInfo=false

# Stage 2: Serve the built site with Nginx
FROM docker.io/library/nginx:stable-alpine AS final

# Copy the built site from the builder stage
COPY --from=builder /src/public /usr/share/nginx/html

# Expose port 80 for Nginx
EXPOSE 80

# Default command to start Nginx
CMD ["nginx", "-g", "daemon off;"]
