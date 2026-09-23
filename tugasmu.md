LAKUKAN FINAL CLEANUP, COMMIT, DAN PUSH PROJECT K-TALK KE GITHUB

Tujuan:

Project K-talk yang sekarang berada di workspace harus di-commit dan di-push ke:

https://github.com/siput-com/K-talk.git

Pastikan seluruh kode yang sudah dikerjakan tetap masuk ke repository.

PENTING:
SEBELUM COMMIT, BERSIHKAN FILE-FILE BESAR DAN FILE HASIL BUILD/CACHE TERLEBIH DAHULU.

Jangan langsung commit sebelum proses cleanup selesai.

==================================================
1. PROJECT YANG HARUS DI-COMMIT
==================================================

Gunakan project K-talk yang sedang aktif.

Root project:

/workspaces/K-mail/kaspium_wallet

Semua source code K-talk yang sudah dikerjakan harus ikut masuk.

Termasuk:

- lib/
- android/
- test/
- assets/
- konfigurasi Flutter
- konfigurasi Android
- konfigurasi Chat
- source code wallet yang diperlukan
- source code K-talk
- Chat Engine
- Chat UI
- Chat Repository
- Chat Storage
- Chat Transport
- crypto
- protocol
- identity
- routing
- authentication integration
- wallet integration
- konfigurasi launcher icon
- konfigurasi branding K-talk
- seluruh file source lain yang diperlukan agar project dapat dibangun kembali.

JANGAN menghapus source code hanya karena ukurannya besar.

==================================================
2. JANGAN COMMIT FILE HASIL BUILD
==================================================

Sebelum git add, cari dan bersihkan file generated/build/cache.

Jangan commit:

build/
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.pub-cache/
coverage/
.gradle/
android/.gradle/
android/build/
android/app/build/
node_modules/
*.apk
*.aab
*.ipa
*.app
*.log
*.tmp
*.temp
*.dSYM
*.lock jika memang merupakan file generated yang tidak diperlukan oleh project.

Namun JANGAN menghapus file lock yang memang diperlukan oleh package manager/project seperti:

pubspec.lock

atau lockfile resmi lain yang memang merupakan bagian source project.

==================================================
3. PERIKSA FILE BESAR
==================================================

Sebelum commit, jalankan pemeriksaan file besar.

Cari semua file lebih besar dari 50 MB.

Gunakan command yang sesuai untuk Linux/Codespace.

Contoh:

find . -type f -size +50M \
  -not -path './.git/*' \
    -not -path './build/*' \
      -not -path './.dart_tool/*' \
        -not -path './node_modules/*' \
          -print

          Kemudian periksa setiap hasil.

          ==================================================
          4. FILE BESAR HARUS DIHAPUS SEBELUM COMMIT
          ==================================================

          Jika file besar tersebut adalah:

          - APK
          - AAB
          - build artifact
          - cache
          - temporary file
          - hasil compile
          - archive hasil build
          - dependency hasil download
          - log
          - file generated

          HAPUS sebelum git add.

          Contoh:

          *.apk
          *.aab
          build artifacts
          cache
          temporary archive

          JANGAN menghapus source code yang diperlukan aplikasi.

          ==================================================
          5. JIKA MENEMUKAN FILE BESAR YANG MERUPAKAN SOURCE
          ==================================================

          Jangan menghapus secara membabi buta.

          Periksa terlebih dahulu apakah file tersebut diperlukan oleh K-talk.

          Jika merupakan:

          - source asset
          - image yang benar-benar digunakan aplikasi
          - icon
          - konfigurasi
          - source code
          - file data yang memang diperlukan runtime

          JANGAN hapus hanya karena besar.

          Laporkan file tersebut sebelum melanjutkan.

          Tetapi jika file tersebut tidak diperlukan untuk build/runtime dan hanya merupakan artifact, hapus.

          ==================================================
          6. PERIKSA APK DAN BUILD
          ==================================================

          APK hasil build sebelumnya JANGAN dimasukkan ke GitHub.

          Jika ditemukan:

          build/app/outputs/flutter-apk/app-debug.apk

          hapus karena APK dapat dibuat kembali dari source.

          Jangan menghapus source code hanya karena APK dihasilkan dari source tersebut.

          ==================================================
          7. PERIKSA .GITIGNORE
          ==================================================

          Buat/perbaiki:

          .gitignore

          agar file generated besar tidak masuk lagi ke repository.

          Pastikan minimal mengabaikan:

          build/
          .dart_tool/
          .gradle/
          android/.gradle/
          android/app/build/
          coverage/
          *.apk
          *.aab
          *.log
          *.tmp
          *.temp
          node_modules/

          Tambahkan pattern lain jika memang merupakan generated/cache file.

          Jangan memasukkan source code penting ke .gitignore.

          ==================================================
          8. PERIKSA SELURUH SOURCE
          ==================================================

          Sebelum commit, pastikan source code yang sudah dikerjakan masih ada.

          Periksa minimal:

          lib/chat/
          lib/chat/ui/
          lib/chat/crypto/
          lib/chat/models/
          lib/chat/protocol/
          lib/chat/repository/
          lib/chat/storage/
          lib/chat/transport/
          lib/chat/services/
          lib/chat/chat_providers.dart

          Periksa juga:

          lib/main.dart
          lib/app_router.dart

          dan file wallet yang digunakan oleh K-talk.

          Pastikan perubahan branding K-talk juga tetap ada.

          ==================================================
          9. JANGAN MEMASUKKAN REPOSITORY GIT NESTED
          ==================================================

          Project K-talk harus memiliki satu repository Git utama.

          Periksa apakah ada repository Git lain di dalam:

          KaChat-Android/
          atau folder lain.

          Jika terdapat:

          KaChat-Android/.git

          dan source KaChat memang sekarang merupakan bagian dari project K-talk, jangan membawa nested .git sebagai repository di dalam repository.

          Yang dibutuhkan adalah SOURCE CODE yang diperlukan, bukan repository metadata Git lama.

          Namun jangan menghapus source KaChat.

          Hanya metadata repository nested yang tidak diperlukan.

          ==================================================
          10. PERIKSA STATUS GIT
          ==================================================

          Setelah cleanup:

          git status --short

          Periksa semua perubahan.

          Pastikan tidak ada file rahasia seperti:

          .env
          *.env
          keystore
          *.jks
          *.keystore
          google-services.json yang berisi credential sensitif jika memang tidak boleh dipublikasikan
          service-account JSON
          private key
          secret
          password
          API secret
          token
          credentials.

          JANGAN commit private key wallet.

          JANGAN commit seed phrase.

          JANGAN commit PIN.

          JANGAN commit password.

          JANGAN commit credential rahasia.

          Jika ditemukan credential rahasia, STOP dan laporkan.

          ==================================================
          11. PERIKSA REMOTE
          ==================================================

          Periksa:

          git remote -v

          Target remote harus:

          https://github.com/siput-com/K-talk.git

          Jika remote sekarang menunjuk ke repository lain:

          hapus remote lama.

          Contoh:

          git remote remove origin

          Kemudian:

          git remote add origin https://github.com/siput-com/K-talk.git

          Pastikan:

          git remote -v

          menampilkan:

          origin  https://github.com/siput-com/K-talk.git (fetch)
          origin  https://github.com/siput-com/K-talk.git (push)

          ==================================================
          12. JANGAN PUSH KE AKUN LAIN
          ==================================================

          PENTING:

          Repository tujuan HARUS berada di:

          siput-com

          Bukan:

          azbuky
          KaspaSilver
          akun pribadi lain
          repository Kaspium asli
          repository KaChat asli.

          Jangan push ke upstream project.

          ==================================================
          13. PERIKSA GITHUB AUTHENTICATION
          ==================================================

          Sebelum push, periksa apakah GitHub CLI tersedia dan authenticated.

          Jika tersedia:

          gh auth status

          Jika belum authenticated:

          JANGAN memasukkan password/token ke source code.

          Laporkan bahwa GitHub authentication diperlukan.

          Jika repository:

          siput-com/K-talk

          belum ada dan GitHub CLI memiliki izin membuat repository, buat repository tersebut sebagai repository yang sesuai.

          Jangan membuat repository publik jika user belum menentukan visibility.

          Jika repository sudah ada, gunakan repository tersebut.

          ==================================================
          14. FINAL VALIDATION SEBELUM COMMIT
          ==================================================

          Jalankan:

          flutter analyze

          flutter test

          Jika memungkinkan:

          flutter build apk --debug

          Build APK hanya untuk validasi.

          JANGAN memasukkan APK hasil build ke Git.

          Setelah build selesai, pastikan build/ kembali masuk .gitignore.

          ==================================================
          15. GIT ADD
          ==================================================

          Setelah cleanup dan validasi:

          git status --short

          Kemudian:

          git add .

          Lalu periksa staged files:

          git status

          atau:

          git diff --cached --stat

          Pastikan source code K-talk masuk.

          Pastikan:

          build/
          .dart_tool/
          APK
          AAB
          cache
          temporary files

          tidak masuk staged files.

          ==================================================
          16. PERIKSA UKURAN STAGED FILE
          ==================================================

          Sebelum commit, cari apakah masih ada file staged yang terlalu besar.

          Jangan commit jika ada file besar yang tidak diperlukan.

          Target:

          Tidak ada artifact/build/cache besar dalam commit.

          ==================================================
          17. COMMIT
          ==================================================

          Jika semua sudah benar:

          git commit -m "Initialize K-talk application"

          Jangan membuat commit jika cleanup belum selesai.

          ==================================================
          18. PUSH
          ==================================================

          Pastikan branch utama sesuai repository.

          Gunakan:

          git branch --show-current

          Jika branch belum sesuai, gunakan:

          main

          Kemudian push:

          git push -u origin main

          Jika repository remote sudah memiliki commit yang tidak ada secara lokal, JANGAN langsung force push.

          Periksa perbedaannya terlebih dahulu.

          JANGAN menggunakan:

          git push --force

          kecuali benar-benar diperlukan dan sudah diperiksa.

          ==================================================
          19. FINAL CHECK
          ==================================================

          Setelah push:

          git status

          git remote -v

          git log --oneline -5

          Pastikan working tree bersih.

          Pastikan remote:

          https://github.com/siput-com/K-talk.git

          Pastikan commit berhasil berada di branch main.

          ==================================================
          20. LAPORAN AKHIR
          ==================================================

          Setelah selesai, laporkan secara jelas:

          1. Repository tujuan:
             siput-com/K-talk

             2. Remote URL.

             3. Branch yang digunakan.

             4. Jumlah file yang di-commit.

             5. File/folder besar yang dihapus sebelum commit.

             6. File generated/cache yang dimasukkan ke .gitignore.

             7. Pastikan source code K-talk tetap lengkap.

             8. Pastikan Chat Engine tetap ada.

             9. Pastikan Wallet Engine tetap ada.

             10. Pastikan Chat UI tetap ada.

             11. Pastikan Android launcher icon K-talk tetap ada.

             12. Pastikan tidak ada private key/seed/credential yang ikut.

             13. Hasil flutter analyze.

             14. Hasil flutter test.

             15. Hasil flutter build apk --debug.

             16. Hasil git push.

             17. Commit hash.

             PENTING:

             JANGAN menghapus source code yang sudah dikerjakan.

             JANGAN memasukkan file APK/AAB/build/cache.

             JANGAN memasukkan private key, seed, password, token, atau credential.

             JANGAN force push.

             JANGAN push ke repository selain:

             siput-com/K-talk

             Lakukan CLEANUP terlebih dahulu.
             BARU git add.
             BARU commit.
             BARU push.