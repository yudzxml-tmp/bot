# 🧠 Gunakan Node.js versi stabil terbaru
FROM node:20

# ⚙️ Set direktori kerja utama
WORKDIR /app

# 🧩 Install alat bantu penting
RUN apt-get update && apt-get install -y curl unzip p7zip-full tar file && rm -rf /var/lib/apt/lists/*

# 🌐 URL arsip default (bisa dioverride lewat ENV di Railway/VPS)
ENV ZIP_URL="https://cdn.yupra.my.id/yp/cow9c4mh.zip"

# 🧰 Tahap download & ekstraksi berbagai format arsip
RUN set -e; \
    echo "🔍 Mengecek sumber arsip..."; \
    if [ -z "$ZIP_URL" ]; then \
        echo "⚠️ ZIP_URL kosong, melewati tahap download."; \
    else \
        echo "📥 Mendownload arsip dari: $ZIP_URL"; \
        curl -fL -A "Mozilla/5.0 (X11; Linux x86_64)" "$ZIP_URL" -o app.arc || (echo "❌ Gagal mendownload arsip!" && exit 1); \
        echo "✅ Download selesai, ukuran file: $(du -h app.arc | cut -f1)"; \
        echo "🔎 Mengecek tipe file..."; \
        FILETYPE=$(file app.arc); \
        echo "📂 Deteksi: $FILETYPE"; \
        mkdir -p /tmp/unzip; \
        if echo "$FILETYPE" | grep -q 'Zip archive data'; then \
            echo "📦 Mengekstrak ZIP..."; \
            unzip -oq app.arc -d /tmp/unzip || (echo '❌ Gagal ekstrak ZIP!' && exit 1); \
        elif echo "$FILETYPE" | grep -q '7-zip archive'; then \
            echo "📦 Mengekstrak 7z..."; \
            7z x app.arc -o/tmp/unzip >/dev/null || (echo '❌ Gagal ekstrak 7z!' && exit 1); \
        elif echo "$FILETYPE" | grep -q 'gzip compressed'; then \
            echo "📦 Mengekstrak tar.gz..."; \
            tar -xzf app.arc -C /tmp/unzip || (echo '❌ Gagal ekstrak tar.gz!' && exit 1); \
        elif echo "$FILETYPE" | grep -q 'tar archive'; then \
            echo "📦 Mengekstrak tar..."; \
            tar -xf app.arc -C /tmp/unzip || (echo '❌ Gagal ekstrak tar!' && exit 1); \
        else \
            echo "❌ Format arsip tidak dikenali!"; \
            file app.arc; \
            head -n 20 app.arc; \
            exit 1; \
        fi; \
        rm -f app.arc; \
        echo "🚚 Memindahkan hasil ekstrak ke /app..."; \
        cp -r /tmp/unzip/* /app/ 2>/dev/null || echo "⚠️ Tidak ada file untuk dipindahkan."; \
        rm -rf /tmp/unzip; \
        echo "✅ Ekstraksi selesai."; \
    fi

# 📦 Install dependencies (jika ada)
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
        echo '✅ Menjalankan index.js...'; \
        node index.js; \
    elif [ -f app.js ]; then \
        echo '⚙️ index.js tidak ditemukan, mencoba app.js...'; \
        node app.js; \
    else \
        echo '❌ Tidak ditemukan file index.js atau app.js di /app'; \
        echo '📂 Daftar file di direktori saat ini:'; \
        ls -la; \
        echo '💤 Menunggu 30 detik sebelum berhenti...'; \
        sleep 30; \
    fi \
"]