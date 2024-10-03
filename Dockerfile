# Étape 1: Build l'application
# Utilise une image Node.js officielle comme base pour l'étape de build
FROM node:18-alpine AS builder

# Définit le répertoire de travail à l'intérieur du conteneur
WORKDIR /app

# Copie le fichier package.json et yarn.lock ou package-lock.json
COPY package*.json ./
# ou si tu utilises Yarn
# COPY package.json yarn.lock ./

# Installe les dépendances
RUN npm install 
# ou si tu utilises Yarn
# RUN yarn install

# Copie le reste du code de l'application
COPY . .

# Build l'application pour la production
RUN npm run build
# ou si tu utilises Yarn
# RUN yarn build

# Étape 2: Lancer l'application
# Utilise une image Node.js officielle pour exécuter l'application
FROM node:18-alpine AS runner

# Définit le répertoire de travail à l'intérieur du conteneur
WORKDIR /app

# Copie uniquement les fichiers nécessaires pour exécuter l'application
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules

# Expose le port sur lequel l'application va s'exécuter
EXPOSE 3000

# Commande pour démarrer l'application
CMD ["npm", "start"]
# ou si tu utilises Yarn
# CMD ["yarn", "start"]
