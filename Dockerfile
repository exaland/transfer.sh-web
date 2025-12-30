# Utiliser une image de base avec Node.js et Go
FROM ubuntu:20.04

# Variables pour éviter les prompts
ENV DEBIAN_FRONTEND=noninteractive

# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    gnupg \
    build-essential \
    software-properties-common \
    wget

# Installer Node.js (version LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs

# Installer Bower globalement
RUN npm install -g bower grunt-cli

# Installer Go
RUN wget https://golang.org/dl/go1.20.linux-amd64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz

ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin

# Installer go-bindata
RUN go install github.com/shuLhan/go-bindata/...@latest

# Ajouter votre code source (copiez votre projet dans /app)
WORKDIR /app
COPY . .

# Installer les dépendances Node et Bower
RUN npm install
RUN bower install --config.interactive=false --allow-root

# Build du frontend avec grunt
RUN grunt build

# Générer les assets Go avec go generate
RUN go generate .

# Exposer le port 8080 (si vous utilisez un serveur web pour servir le dist)
EXPOSE 8080

# Commande par défaut: servir le contenu avec nginx (optionnel)
# Vous pouvez aussi utiliser un simple serveur HTTP Python si vous préférez
# Par exemple, pour nginx, vous pouvez copier une config nginx et l'utiliser
# Pour un serveur simple:
#CMD ["python3", "-m", "http.server", "dist", "--bind", "0.0.0.0", "--port", "8080"]