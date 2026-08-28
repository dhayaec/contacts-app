# ---------------------------------------------------------------
# Multi-stage build for production image
# ---------------------------------------------------------------
FROM node:20-alpine AS base
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@9.15.0 --activate

# Dependencies stage
FROM base AS deps
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile --prod=false --ignore-scripts

# Build stage
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm build

# Production stage (Next.js standalone server)
FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/next.config.ts ./next.config.ts

EXPOSE 3000
CMD ["pnpm", "start"]
