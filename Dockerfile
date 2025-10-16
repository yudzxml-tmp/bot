# 🧠 Gunakan Node.js versi stabil terbaru
FROM node:20

# ⚙️ Set direktori kerja utama
WORKDIR /app

# 🧩 Install alat bantu penting
RUN apt-get update && apt-get install -y curl unzip file && rm -rf /var/lib/apt/lists/*

# 🌐 URL ZIP default (bisa dioverride lewat env di Railway/VPS)
ENV ZIP_URL="https://cdn.yupra.my.id/yp/cow9c4mh.zip"

# 🧰 Tahap download dan ekstraksi ZIP
RUN set -e; \
    echo "🔍 Mengecek sumber ZIP..."; \
    if [ -z "$ZIP_URL" ]; then \
        echo "⚠️ ZIP_URL kosong, melewati tahap download."; \
    else \
        echo "📥 Mendownload ZIP dari: $ZIP_URL"; \
        curl -fL -A "Mozilla/5.0 (X11; Linux x86_64)" "$ZIP_URL" -o app.zip || (echo "❌ Gagal mendownload ZIP!" && exit 1); \
        echo "✅ Download selesai, ukuran file: $(du -h app.zip | cut -f1)"; \
        echo "🔎 Mengecek apakah file valid ZIP..."; \
        if file app.zip | grep -q 'Zip archive data'; then \
            echo "📦 Mengekstrak file ZIP..."; \
            mkdir -p /tmp/unzip; \
            unzip -oq app.zip -d /tmp/unzip || (echo "❌ Gagal ekstrak ZIP!" && exit 1); \
            rm -f app.zip; \
            echo "🚚 Memindahkan hasil ekstrak ke /app..."; \
            cp -r /tmp/unzip/* /app/ 2>/dev/null || echo "⚠️ Tidak ada file untuk dipindahkan."; \
            rm -rf /tmp/unzip; \
            echo "✅ Ekstraksi selesai."; \
        else \
            echo "❌ File yang diunduh bukan ZIP valid!"; \
            file app.zip; \
            head -n 20 app.zip; \
            exit 1; \
        fi; \
    fi

# 📦 Install dependencies (jika package.json tersedia)
RUN if [ -f package.json ]; then \
        echo "📦 Menginstal dependencies dari package.json..."; \
        npm ci --only=production || npm install --production; \
    else \
        echo "ℹ️ Tidak ada package.json, melewati instalasi dependencies."; \
    fi

# 🔓 Expose port default
EXPOSE 3000

# 🚀 Jalankan aplikasi utama
CMD ["sh", "-c", "\
    echo '🚀 Menjalankan bot WhatsApp...'; \
    if [ -f index.js ]; then \
        echo '✅ File index.js ditemukan. Memulai...'; \
        node index.js; \
    elif [ -f app.js ]; then \
        echo '⚙️ File index.js tidak ditemukan, mencoba app.js...'; \
        node app.js; \
    else \
        echo '❌ Tidak ditemukan file index.js atau app.js di /app'; \
        echo '📂 Daftar file:'; \
        ls -la; \
        echo '💤 Menunggu 30 detik sebelum berhenti...'; \
        sleep 30; \
    fi \
"]