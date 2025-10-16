# 🧠 Gunakan Node.js versi stabil terbaru
FROM node:20

# ⚙️ Set direktori kerja utama
WORKDIR /app

# 🧩 Install alat bantu penting
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# 📂 Copy file lokal jika ada (misalnya Dockerfile, README, package.json)
COPY . .

# 🌐 URL ZIP default (bisa dioverride lewat env di Railway/VPS)
ENV ZIP_URL="https://cdn.yupra.my.id/yp/cow9c4mh.zip"

# 🧰 Tahap download dan ekstraksi ZIP
RUN set -e; \
    echo "🔍 Mengecek sumber ZIP..."; \
    if [ -n \"$ZIP_URL\" ]; then \
        echo \"📥 Mendownload ZIP dari: $ZIP_URL\"; \
        curl -fL \"$ZIP_URL\" -o app.zip || (echo \"❌ Gagal mendownload ZIP!\" && exit 1); \
    else \
        echo \"⚠️ ZIP_URL kosong, melewati tahap download.\"; \
    fi; \
    if [ -f app.zip ]; then \
        echo \"📦 Mengekstrak file ZIP...\"; \
        mkdir -p /tmp/unzip; \
        unzip -oq app.zip -d /tmp/unzip || (echo \"❌ Gagal ekstrak ZIP!\" && exit 1); \
        rm -f app.zip; \
        echo \"🚚 Memindahkan hasil ekstrak ke /app...\"; \
        cp -r /tmp/unzip/* /app/ 2>/dev/null || echo \"⚠️ Tidak ada file untuk dipindahkan.\"; \
        rm -rf /tmp/unzip; \
    else \
        echo \"⚠️ Tidak ada file ZIP ditemukan, melewati tahap ekstraksi.\"; \
    fi

# 📦 Install dependencies (jika package.json tersedia)
RUN if [ -f package.json ]; then \
        echo \"📦 Menginstal dependencies dari package.json...\"; \
        npm ci --only=production || npm install --production; \
    else \
        echo \"ℹ️ Tidak ada package.json, melewati instalasi dependencies.\"; \
    fi

# 🔓 Expose port default untuk Railway / Render / VPS
EXPOSE 3000

# 🚀 Jalankan aplikasi utama (fallback jika index.js hilang)
CMD ["sh", "-c", "\
    echo '🚀 Menjalankan bot WhatsApp...'; \
    if [ -f index.js ]; then \
        echo '✅ File index.js ditemukan. Memulai...'; \
        node index.js; \
    elif [ -f app.js ]; then \
        echo '⚙️ File index.js tidak ada, coba jalankan app.js'; \
        node app.js; \
    else \
        echo '❌ Tidak ditemukan file index.js atau app.js di /app'; \
        ls -la; \
        echo '💤 Menunggu 30 detik sebelum berhenti...'; \
        sleep 30; \
    fi \
"]