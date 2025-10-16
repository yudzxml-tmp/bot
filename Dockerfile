# Gunakan Node.js versi stabil
FROM node:20

# Set direktori kerja
WORKDIR /app

# Copy semua file ke dalam container
COPY . .

# Install unzip
RUN apt-get update && apt-get install -y unzip && rm -rf /var/lib/apt/lists/*

# Ekstrak file ZIP (misalnya app.zip) ke folder ./src
RUN if [ -f app.zip ]; then \
    echo "📦 Mengekstrak app.zip..."; \
    unzip -o app.zip -d ./src && rm app.zip; \
  fi

# Pindah ke hasil ekstrak
WORKDIR /app/src

# Install dependensi (kalau ada)
RUN if [ -f package.json ]; then npm install --production; fi

# Port default Railway
EXPOSE 3000

# Jalankan index.js
CMD ["node", "index.js"]