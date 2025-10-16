# Gunakan Node.js versi stabil terbaru
FROM node:20

# Set direktori kerja utama
WORKDIR /app

# Install alat bantu
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Copy semua file lokal (kalau ada)
COPY . .

# URL ZIP default (bisa diganti lewat env di Railway/VPS)
ENV ZIP_URL="https://cdn.yupra.my.id/yp/cow9c4mh.zip"

# Download dan ekstrak ZIP, lalu pindahkan semua isi ke /app
RUN set -e; \
    echo "🔍 Mengecek sumber ZIP..."; \
    if [ -n \"$ZIP_URL\" ]; then \
        echo \"📥 Mendownload ZIP dari URL: $ZIP_URL\"; \
        curl -L \"$ZIP_URL\" -o app.zip || (echo \"❌ Gagal download ZIP!\" && exit 1); \
    fi; \
    if [ -f app.zip ]; then \
        echo \"📦 Mengekstrak file ZIP...\"; \
        mkdir -p /tmp/unzip && unzip -o app.zip -d /tmp/unzip && rm -f app.zip; \
        echo \"🚚 Memindahkan semua isi hasil ekstrak ke /app...\"; \
        mv /tmp/unzip/* /app/ || echo \"⚠️ Tidak ada file yang bisa dipindahkan.\"; \
        rm -rf /tmp/unzip; \
    else \
        echo \"⚠️ Tidak ada file ZIP ditemukan, lanjut tanpa ekstrak.\"; \
    fi

# Install dependencies jika ada package.json
RUN if [ -f package.json ]; then \
        echo \"📦 Menginstal dependencies...\"; \
        npm install --production; \
    else \
        echo \"ℹ️ Tidak ada package.json, lewati instalasi.\"; \
    fi

# Expose port untuk Railway / VPS / Render
EXPOSE 3000

# Jalankan index.js setelah semua selesai
CMD ["sh", "-c", "\
    echo '🚀 Menjalankan bot WhatsApp...'; \
    if [ -f index.js ]; then \
        node index.js; \
    else \
        echo '❌ index.js tidak ditemukan di /app!'; \
        ls -la; \
        sleep 15; \
    fi \
"]