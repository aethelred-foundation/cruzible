# Aethelred Cruzible Frontend Dockerfile
# Multi-stage build for Next.js production

# ============ BASE ============
FROM node:20-alpine AS base

RUN apk add --no-cache libc6-compat curl
WORKDIR /app

# ============ DEPENDENCIES ============
FROM base AS dependencies

COPY package*.json ./
RUN npm ci --legacy-peer-deps

# ============ BUILDER ============
FROM dependencies AS builder

COPY . .

ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

RUN npm run build

# ============ PRODUCTION ============
FROM base AS production

RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

WORKDIR /app

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"
ENV NODE_ENV=production

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

CMD ["node", "server.js"]
