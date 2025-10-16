# Gunakan Node.js versi stabil terbaru
FROM node:20

# Set direktori kerja
WORKDIR /app

# Install curl dan unzip
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Copy semua file lokal (kalau ada app.zip atau file pendukung di repo)
COPY . .

# Env default ZIP_URL (bisa diubah lewat Railway / VPS Environment)
ENV ZIP_URL="https://github.com/yudzxml-tmp/bot/raw/refs/heads/main/app.zip"

# Download & ekstrak file ZIP (baik dari URL maupun lokal)
RUN set -e; \
    echo "🔍 Mengecek sumber ZIP..."; \
    if [ -n "$ZIP_URL" ]; then \
        echo "📥 Mendownload ZIP dari URL: $ZIP_URL"; \
        curl -L "$ZIP_URL" -o app.zip || (echo "❌ Gagal mendownload ZIP dari URL" && exit 1); \
    fi; \
    if [ -f app.zip ] || [ -f app.zip.zip ]; then \
        echo "📦 Mengekstrak file ZIP..."; \
        unzip -o app.zip* -d ./src && rm -f app.zip*; \
    else \
        echo "⚠️ Tidak ada file ZIP ditemukan, lanjut tanpa ekstrak."; \
    fi

# Pastikan folder src ada (kalau ZIP kosong atau tidak diekstrak)
RUN mkdir -p /app/src && \
    if [ -d /app/src ]; then \
        echo "📁 Direktori src siap digunakan."; \
    fi

# Pindah ke folder hasil ekstrak
WORKDIR /app/src

# Install dependencies jika ada package.json
RUN if [ -f package.json ]; then \
        echo "📦 Menemukan package.json, menginstal dependensi..."; \
        npm install --production; \
    else \
        echo "ℹ️ Tidak ada package.json ditemukan, lewati instalasi."; \
    fi

# Expose port default (untuk Railway / Render / VPS)
EXPOSE 3000

# Jalankan index.js (fallback aman kalau file tidak ditemukan)
CMD ["sh", "-c", "if [ -f index.js ]; then node index.js; else echo '❌ index.js tidak ditemukan di /app/src!'; ls -la; sleep 15; fi"]