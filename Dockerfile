# Gunakan Node.js versi stabil terbaru
FROM node:20

# Set direktori kerja
WORKDIR /app

# Install curl dan unzip
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Copy semua file ke dalam container (jika ada app.zip di repo)
COPY . .

# Env default ZIP_URL (bisa diubah di Railway Variables)
ENV ZIP_URL="https://github.com/yudzxml-tmp/bot/raw/refs/heads/main/app.zip"

# Ekstrak file ZIP lokal atau dari URL (jika tersedia)
RUN set -e; \
    if [ -n "$ZIP_URL" ]; then \
        echo "📥 Mendownload ZIP dari URL: $ZIP_URL"; \
        curl -L "$ZIP_URL" -o app.zip || (echo "❌ Gagal mendownload ZIP" && exit 1); \
    fi; \
    if [ -f app.zip ]; then \
        echo "📦 Mengekstrak app.zip..."; \
        unzip -o app.zip -d ./src && rm app.zip; \
    else \
        echo "⚠️  Tidak ada app.zip ditemukan, lanjut tanpa ekstrak."; \
    fi

# Pindah ke folder hasil ekstrak jika ada, kalau tidak pakai root /app
WORKDIR /app/src
RUN if [ ! -d /app/src ]; then mkdir -p /app/src && cp -r /app/* /app/src/ || true; fi

# Install dependensi jika ada package.json
RUN if [ -f package.json ]; then npm install --production; else echo "ℹ️  Tidak ada package.json, lewati instalasi."; fi

# Expose port Railway
EXPOSE 3000

# Jalankan index.js
CMD ["sh", "-c", "if [ -f index.js ]; then node index.js; else echo '❌ index.js tidak ditemukan!'; sleep 10; fi"]