# Multi-stage production image for MetaMCP
# ---------- Build stage ----------
FROM node:20-alpine AS build

# Install tini for better signal handling
RUN apk add --no-cache tini

WORKDIR /app

# Install dependencies based on lock file if present, fall back to package.json
COPY package*.json ./
RUN npm ci --ignore-scripts

# Copy the rest of the source code and build the TypeScript project
COPY . .
RUN npm run build

# ---------- Production stage ----------
FROM node:20-alpine

# Create app directory
WORKDIR /app

# Copy production node_modules and built sources
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist

# Copy package metadata
COPY package*.json ./

ARG PORT=12005
ENV PORT=$PORT
EXPOSE $PORT

CMD ["node", "dist/index.js", "--port", "$PORT", "--use-docker-host"]