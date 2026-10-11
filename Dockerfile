# Self-hosted build (Coolify): build the app, serve the output with nginx on port 3000.
FROM node:24-bookworm-slim AS build
ENV CI=1 NEXT_TELEMETRY_DISABLED=1 NODE_OPTIONS=--max-old-space-size=3072
WORKDIR /app
RUN corepack enable
COPY . .
RUN npm ci --no-audit --no-fund || npm install --no-audit --no-fund
WORKDIR /app/.
RUN npm run build

FROM nginx:1.31-alpine
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/./dist/ /usr/share/nginx/html/
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s CMD wget -q -O /dev/null http://127.0.0.1:3000/ || exit 1
