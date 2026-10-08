# ==============================================================================
# ContentPilot AI — Production Backend Dockerfile
# ==============================================================================
FROM node:22-bookworm-slim AS builder

WORKDIR /app

# Install system build dependencies and native tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy package manifests
COPY package.json package-lock.json ./
COPY backend/package.json ./backend/

# Install dependencies
RUN npm ci

# Copy backend source and prisma schema
COPY backend/ ./backend/

# Generate Prisma Client & compile TypeScript
WORKDIR /app/backend
RUN npx prisma generate
RUN npm run build

# ==============================================================================
# Runner Stage
# ==============================================================================
FROM node:22-bookworm-slim AS runner

WORKDIR /app

# Install production runtime dependencies: FFmpeg, FFprobe, SQLite3, CA-certificates
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    sqlite3 \
    ca-certificates \
    openssl \
    && rm -rf /var/lib/apt/lists/* \
    && ffmpeg -version \
    && ffprobe -version

ENV NODE_ENV=production
ENV PORT=3001
ENV STORAGE_DIR=/app/backend/storage
ENV DATABASE_URL="file:/app/backend/prisma/production.db"

# Copy package manifests and production dependencies
COPY package.json package-lock.json ./
COPY backend/package.json ./backend/

RUN npm ci --omit=dev

# Copy generated Prisma engine and client
COPY --from=builder /app/backend/node_modules/.prisma ./backend/node_modules/.prisma
COPY --from=builder /app/backend/node_modules/@prisma ./backend/node_modules/@prisma

# Copy compiled JavaScript output and schema
COPY --from=builder /app/backend/dist ./backend/dist
COPY --from=builder /app/backend/prisma ./backend/prisma

# Create persistent storage directories
RUN mkdir -p /app/backend/storage /app/backend/prisma

WORKDIR /app/backend

EXPOSE 3001

CMD ["node", "dist/index.js"]
