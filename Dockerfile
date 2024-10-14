FROM node:18-alpine as base

# Installe les dépendances requises
RUN apk add --no-cache g++ make py3-pip libc6-compat
WORKDIR /app

# Copie les fichiers de dépendances avant d'exécuter npm install
COPY package*.json ./
EXPOSE 3000

# Étape de construction
FROM base as builder
WORKDIR /app
COPY . .
RUN npm run build

# Étape de production
FROM base as production
WORKDIR /app

ENV NODE_ENV=production
RUN npm ci --only=production

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public

CMD ["npm", "start"]

# Étape de développement
FROM base as dev
WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .

CMD ["npm", "run", "dev"]
