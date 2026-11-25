Muyes — Tracker Makan + Tracker Eek (Personal Project)
File ini adalah SPEC untuk vibecoding. Kasih file ini ke AI coding agent (Claude Code / Cursor / Copilot / dll) sebagai konteks utama. Agent harus ikuti spec ini, jangan ngarang fitur di luar MVP tanpa konfirmasi.
1. Ide Inti
Aplikasi personal untuk mencatat:
Makan jam berapa, makan apa
Eek jam berapa, eek-nya kayak gimana
Terus ada AI lokal yang analisa korelasinya. Contoh:
"Kamu mules terus habis makan pedes level 4-5, kemungkinan besar pemicunya pedes."
"Dalam 7 hari terakhir kamu eek 4x sehari 2 hari berturut-turut + Bristol 6-7, ini abnormal, waspada."
"Kamu belum eek 3 hari, hati-hati konstipasi."
"Kamu 2 hari ini cuma makan 1x sehari + 3x makan berat di atas jam 11 malam minggu ini — pola makanmu lagi nggak teratur."
Bukan aplikasi medis. Bukan diagnosis. Hanya pola dari data user sendiri + peringatan umum.
2. Nama
Muyes
Tagline: Makan apa, eek gimana, perut bilang apa.
3. Prinsip Produk
Local-first, privacy-first. Semua data di HP user. Tanpa akun, tanpa backend, tanpa cloud, tanpa kirim data ke server.
AI lokal. Analisa jalan di device, tanpa API key, tanpa internet. V1 = rule-based + statistik sederhana, BUKAN LLM. V2 (opsional) baru pertimbangkan on-device LLM.
Logging harus < 10 detik. Kalau ribet, user nggak akan isi. Quick-log adalah fitur paling penting.
Jujur soal confidence. AI harus bilang "kemungkinan" + nunjukin datanya ("3 dari 4 kali..."), jangan sok yakin.
No fake data. Jangan tampilkan statistik / insight / contoh yang bukan dari data user.
4. Tech Stack (Rekomendasi)
Framework: Flutter (Dart) — satu codebase Android + iOS (target V1: Android + iOS)
Local DB: Drift (SQLite) atau Isar — pilih salah satu, konsisten
State management: Riverpod atau Bloc — pilih salah satu, konsisten
Charts: fl_chart (untuk grafik frekuensi + Bristol trend)
Notifikasi lokal: flutter_local_notifications (untuk reminder, opsional di MVP)
AI: Pure Dart functions di lib/ai/ — tanpa package ML di V1
Dataset: TIDAK BUTUH dataset eksternal di V1. AI-nya rule-based (if-then + hitung frekuensi dari log user sendiri), bukan ML yang harus di-training. "Dataset"-nya adalah log makan + eek + mules user sendiri — makin banyak dicatat, makin akurat. Jangan download dataset Kaggle / apapun untuk V1. Kalau nanti V2 mau ML, dataset training-nya tetap log user sendiri (30–90 hari), bukan dataset publik, karena pemicu mules itu personal (misal: kamu sensitif santan, orang lain belum tentu).
Kalau agent mau pakai stack lain (misal Kotlin + Jetpack Compose), harus tanya user dulu. Jangan ganti diam-diam.
5. Fitur MVP (V1 — Wajib)
5.1 Log Makan (FoodLog)
Satu tap dari Home → form cepat.
Field:
waktu (datetime, default: sekarang, bisa edit)
nama_makanan (text bebas, contoh: "Mie ayam level 3")
kategori (multi-select chips): Nasi, Mie, Pedas, Gorengan, Santan, Susu/Olahan Susu, Kopi/Kafein, Teh, Manis, Buah, Sayur, Daging, Seafood, Junk Food, Lainnya
level_pedas (0-5, 0 = tidak pedas)
porsi (Kecil / Sedang / Besar)
minuman (opsional text: "Es teh manis", "Kopi susu")
catatan (opsional text bebas)
foto — SKIP di V1 (diputuskan user 25 Nov 2026, jangan dibangun dulu)
Fitur pendukung:
Quick-add: makanan yang sering dimakan muncul sebagai chip di atas form ("Makan lagi")
Edit & hapus log
5.2 Log Eek (PoopLog)
Satu tap dari Home → form cepat.
Keputusan user 25 Nov 2026: user biasanya cuma nyatet jam eek. Jadi form ini TIDAK boleh ribet. Yang wajib cuma waktu, sisanya opsional.
Wajib (1 field doang):
waktu (datetime, default: sekarang, bisa edit)
Direkomendasikan (1 tap, tampil langsung di form, tapi boleh di-skip):
skala_bristol (1-7, OPSIONAL, dengan visual + deskripsi):
1 = Keras, bulat-bulat kecil (konstipasi berat)
2 = Berbentuk sosis, bergumpal
3 = Sosis, ada retakan
4 = Sosis halus, normal ✅
5 = Gumpalan lunak, tepi jelas
6 = Lembek, potongan tidak jelas
7 = Cair, tanpa bentuk padat (diare)
Kenapa direkomendasikan: tanpa Bristol, AI cuma bisa baca frekuensi / gap (misal: belum eek 3 hari, diare berulang nggak kedeteksi). Dengan Bristol, AI jauh lebih akurat. Tapi tetap boleh kosong — jangan paksa user.
Detail tambahan (SEMUA opsional, sembunyi di balik "Tambah detail" / expandable, jangan tampil di form utama):
warna (pilih): Coklat normal, Kuning, Hijau, Hitam, Merah / berdarah, Pucat / putih
urgensi (0-3): Santai / Lumayan kebelet / Harus buru-buru / Hampir nggak ketahan
mules / nyeri perut (0-5, 0 = tidak mules)
darah (boolean: Ya/Tidak)
lendir (boolean: Ya/Tidak)
durasi (opsional: <5 mnt / 5-15 mnt / >15 mnt)
catatan (opsional)
Aturan form:
Quick-log ideal: buka form → waktu udah keisi "sekarang" → tap Bristol (kalau mau) → Simpan. Selesai dalam 2 tap / <5 detik kalau cuma waktu.
Tombol Simpan harus aktif walau Bristol kosong dan semua detail kosong.
Jangan tampilkan semua field di atas sekaligus di layar utama form — itu yang bikin user males ngisi.
Fitur pendukung:
Edit & hapus log
5.2b Log Mules (SymptomLog — baru, karena mules sering terjadi TANPA eek)
Mules tidak harus nunggu pas eek. Kalau mules doang, user tidak boleh dipaksa bikin log eek palsu cuma buat nyatet mules.
Cara log mules (2 tap):
Tombol + Mules di Home → form mini → pilih level → Simpan.
Field:
waktu (datetime, default: sekarang, bisa edit) — WAJIB, satu-satunya yang wajib
level_mules (0-5, WAJIB di form ini, tampil sebagai 4 chip cepat, bukan slider angka):
Ringan (= 1-2)
Sedang (= 3)
Parah (= 4-5)
Plus opsi Nggak mules (= 0, untuk koreksi / nandain udah baikan — opsional dipakai)
Simpan mapping angka di DB (1-5), tapi UI tampil kata-kata di atas, bukan angka 0-5.
catatan (opsional, contoh: "habis makan seblak", "perut kembung juga")
Aturan:
Mules yang dicatat bareng log eek (field mules di 5.2) dan MulesLog terpisah adalah sumber yang sama untuk AI — analyzer harus gabung keduanya sebagai "kejadian mules", dan deduplikasi kalau waktunya berdekatan (<30 menit = 1 kejadian, jangan dihitung 2x).
Jangan minta user isi mules 2x (di log eek + di log mules) untuk kejadian yang sama. Di form log eek, kasih hint kecil: "Kalau mulesnya udah dicatat terpisah, skip aja bagian ini."
MulesLog juga muncul di timeline hari ini dengan ikon berbeda (misal ⚡ / 🤢), bukan ikon eek.
5.3 Home / Hari Ini
Kartu ringkasan hari ini: makan x kali, eek x kali, mules x kali, terakhir makan jam X, terakhir eek jam X, terakhir mules jam X
3 tombol besar: + Makan, + Eek, dan + Mules
Timeline hari ini (gabungan makan + eek + mules, urut waktu)
Status perut hari ini (dari AI, contoh: "Aman", "Waspada: mules 2x hari ini")
Status makan hari ini (dari AI, contoh: "Belum makan 8 jam", "Baru makan 1x hari ini")
5.4 Riwayat & Kalender
List semua log, filter: Semua / Makan saja / Eek saja
Kalender bulanan: tiap tanggal ada dot (hijau = normal, kuning = waspada, merah = abnormal), tap tanggal → detail hari itu
Search makanan (misal cari "sambal" → semua hari yang ada sambal)
5.5 Insights — AI Lokal (Fitur Kunci)
Halaman khusus Insights. AI menganalisa data 7 hari dan 30 hari terakhir.
A. Korelasi Makanan → Mules / Diare
Logika:
Untuk tiap kejadian mules (dari MulesLog level >= 3 ATAU PoopLog dengan mules >= 3) ATAU diare (PoopLog bristol >= 6), cari FoodLog dalam 2–12 jam sebelumnya.
Hitung frekuensi pemicu yang muncul di kejadian mules vs di hari normal.
Tampilkan hanya jika muncul minimal 2x dan polanya jelas.
Contoh output:
"Pedas level 4-5 muncul di 3 dari 4 kejadian mules kamu minggu ini. Di hari tanpa pedas, kamu cuma mules 1 dari 7 kali. Kemungkinan pedas adalah pemicu utama kamu."
Tampilkan juga:
Confidence: Rendah / Sedang / Tinggi (berdasarkan jumlah sampel)
Data pendukung: "3/4 kejadian" — jangan sembunyikan angka
Pemicu yang dilacak: Pedas, Santan, Susu, Kopi/Kafein, Gorengan, Mie Instan, Makanan Manis Berlebih
B. Deteksi Abnormal (Rule-based, prioritas tinggi)
Cek setiap kali ada log baru + saat buka Insights:
Kondisi
Level
Pesan
Diare (Bristol 6-7) ≥3x dalam sehari, 2 hari berturut-turut
🔴 Waspada Tinggi
"Diare berulang 2 hari. Perbanyak cairan, hindari pemicu. Kalau berlanjut / ada darah / demam, pertimbangkan ke dokter."
Ada darah di eek (sekali pun)
🔴 Waspada Tinggi
"Ada darah di eek kamu. Ini perlu perhatian serius, pertimbangkan konsultasi ke dokter."
Eek hitam (bukan karena obat/suplemen zat besi)
🔴 Waspada Tinggi
"Eek hitam bisa jadi tanda perdarahan saluran cerna atas. Pertimbangkan ke dokter."
Tidak eek ≥3 hari
🟡 Waspada
"Kamu belum eek 3 hari. Coba perbanyak air + serat, gerak. Kalau >5 hari / sakit parah, ke dokter."
Mules ≥4 dalam sehari
🟡 Waspada
"Mules 4x hari ini. Cek makanan 12 jam terakhir di atas."
Bristol 1-2 terus 3+ hari
🟡 Waspada
"Eek keras terus 3 hari — kemungkinan konstipasi."
Pola normal (Bristol 3-5, 1-2x/hari, mules 0-1)
🟢 Aman
"Pola eek kamu minggu ini normal."
C. Ringkasan Mingguan (auto, tiap Senin / saat dibuka)
Total makan, total eek, rata-rata makan/hari, rata-rata eek/hari
Jam makan rata-rata (sarapan / makan siang / makan malam) + seberapa teratur jamnya
Distribusi Bristol minggu ini (bar chart sederhana)
Makanan paling sering + pemicu yang paling sering muncul bareng mules
1 insight utama (kalimat paling penting minggu ini)
D. Deteksi Pola Makan Abnormal (dari FoodLog saja, baru 25 Nov 2026)
Selain analisa eek, AI juga harus bisa bilang kalau pola makannya sendiri udah nggak teratur / abnormal. Ini dihitung dari FoodLog 7 dan 30 hari terakhir, tanpa butuh data eek.
Baseline "normal" yang dipakai (bukan standar medis, cuma patokan pola):
2–4x makan/hari, jeda antar makan 3–6 jam
Jam makan relatif teratur (variasi <2 jam antar hari)
Tidak makan berat larut malam
Kondisi
Level
Pesan (contoh)
Makan cuma 0–1x/hari, 2 hari berturut-turut
🟡 Waspada
"Kamu cuma makan 1x kemarin dan hari ini. Pola ini kalau berlanjut bisa bikin perut makin sensitif. Coba isi makan ringan dulu kalau belum selera makan berat."
Gap makan >10 jam di jam bangun (06:00–22:00), atau tidak ada log makan >14 jam
🟡 Waspada
"Terakhir makan udah 11 jam lalu. Kamu skip makan atau lupa catat?"
Makan ≥6x/hari, 2 hari berturut-turut
🟡 Waspada
"Kamu makan 7x kemarin dan 6x hari ini — ngemil terus. Cek apakah ini lapar beneran atau cuma iseng / stres."
Makan berat (porsi Sedang/Besar) jam 23:00–04:00, ≥3x dalam seminggu
🟡 Waspada
"3x minggu ini kamu makan berat di atas jam 11 malam. Makan larut gini sering bikin mules / begah besok paginya."
Jam makan tidak teratur: jam makan pertama / siang / malam bervariasi >3 jam antar hari dalam 7 hari
🟡 Waspada
"Jam makan kamu minggu ini lompat-lompat, kadang jam 7, kadang jam 12. Perut suka pola yang lebih teratur."
Porsi Besar ≥2x/hari, 3 hari berturut-turut
🟡 Waspada
"3 hari terakhir porsi kamu besar terus. Kalau habis itu sering begah / mules, coba turunin ke Sedang dulu."
Kopi/Kafein ≥4x/hari
🟡 Waspada
"Kopi 4x hari ini. Kafein berlebih bisa bikin perut perih + eek jadi lembek."
Junk Food / Gorengan >70% dari total makan seminggu
🟡 Waspada
"70%+ makanan kamu minggu ini junk food / gorengan. Bukan dilarang, tapi variasinya kurang — coba selipin 1 makanan yang lebih ringan per hari."
Pola makan normal (2–4x/hari, teratur, tidak larut malam)
🟢 Aman
"Pola makan kamu minggu ini teratur."
Aturan khusus pola makan:
Jangan hitung kalori. Spec ini tidak punya field kalori, jangan ditambah di V1.
Jangan diagnosis gangguan makan. Bahasanya selalu pola + kemungkinan + saran umum, jangan pernah bilang "kamu kena X" atau bikin user merasa bersalah soal makan.
Selalu kasih opsi "lupa catat" — gap panjang bisa jadi user cuma lupa log, bukan beneran nggak makan. Insight harus nanya balik, bukan nuduh.
Kalau user lagi puasa / intermittent fasting, detector skip-makan harus bisa dimatikan di Settings (toggle "Mode Puasa / IF"). Kalau toggle ON, rule skip-makan + gap panjang dimatikan, rule lain tetap jalan.
Insight pola makan harus tampil terpisah dari insight eek di halaman Insights (2 section: Pola Makan dan Pola Eek), tapi digabung di ringkasan mingguan.
Butuh minimal 3 hari data makan untuk memunculkan insight pola makan. Kalau kurang, tampilkan: "Catat makan 3 hari dulu biar pola makanmu kebaca."
Aturan AI:
Semua analisa harus bisa dijelaskan: tampilkan Kenapa AI bilang ini? → data mentahnya (tanggal + log terkait, bisa di-tap).
Kalau data kurang dari 3 hari / <5 log eek, tampilkan: "Data masih sedikit, insight akan muncul setelah 3-5 hari pencatatan."
AI harus tahan data kosong (karena Bristol + detail lain opsional): kalau Bristol kosong, skip analisa yang butuh Bristol (distribusi Bristol, diare Bristol 6-7, konstipasi Bristol 1-2) dan cuma pakai frekuensi / gap waktu. Kalau mules kosong, skip korelasi mules. Jangan pernah anggap field kosong = 0 / normal. Kalau insight jadi terbatas karena banyak field kosong, bilang jujur: "Insight terbatas karena Bristol jarang diisi — isi Bristol biar analisanya lebih akurat." Jangan bikin insight ngarang dari data yang nggak ada.
Jangan pernah kasih diagnosis penyakit ("kamu kena X"). Bahasanya selalu pola + kemungkinan + saran umum + "pertimbangkan ke dokter" untuk yang merah.
Semua teks insight dalam Bahasa Indonesia, santai, tidak menakut-nakuti.
5.6 Settings / Data
Export data (CSV / JSON) — untuk backup
Import data (dari export sebelumnya)
Hapus semua data (dengan konfirmasi 2x)
Reminder opsional: "Ingatkan catat makan siang jam 12" / "Ingatkan review harian jam 21" (default OFF)
Toggle "Mode Puasa / Intermittent Fasting" (default OFF): kalau ON, rule skip-makan + gap panjang di Deteksi Pola Makan Abnormal dimatikan
Tentang + Disclaimer medis
6. Model Data
// FoodLog
id: String (uuid)
eatenAt: DateTime
foodName: String
categories: List<String>
spicyLevel: int // 0-5
portion: String // Kecil | Sedang | Besar
drink: String?
note: String?
createdAt: DateTime
updatedAt: DateTime

// PoopLog — hanya poopedAt yang wajib, sisanya nullable
id: String (uuid)
poopedAt: DateTime // WAJIB, satu-satunya field wajib
bristol: int? // 1-7, nullable (boleh kosong)
color: String? // Coklat | Kuning | Hijau | Hitam | Merah | Pucat
urgency: int? // 0-3
painLevel: int? // 0-5, mules
hasBlood: bool? // null = tidak diisi
hasMucus: bool? // null = tidak diisi
duration: String? // <5mnt | 5-15mnt | >15mnt
note: String?
createdAt: DateTime
updatedAt: DateTime

// MulesLog — log mules terpisah (tanpa eek)
id: String (uuid)
feltAt: DateTime // WAJIB
painLevel: int // 1-5 (UI: Ringan 1-2, Sedang 3, Parah 4-5)
note: String?
createdAt: DateTime
updatedAt: DateTime

// Insight (hasil analisa, di-generate, bukan diinput user)
id: String
type: String // correlation | abnormal | eating_pattern | weekly_summary
level: String // info | warning | alert
title: String
body: String
confidence: String // Rendah | Sedang | Tinggi
evidenceLogIds: List<String> // id FoodLog/PoopLog pendukung
periodDays: int // 7 atau 30
createdAt: DateTime
isRead: bool
7. Struktur Folder (Flutter)
lib/
  main.dart
  models/
    food_log.dart
    poop_log.dart
    mules_log.dart
    insight.dart
  data/
    database.dart        // Drift setup
    food_log_dao.dart
    poop_log_dao.dart
    mules_log_dao.dart
  ai/
    analyzer.dart        // orchestrator: panggil semua rule
    correlation.dart     // makanan -> mules/diare
    abnormal_detector.dart // pola eek abnormal
    eating_pattern_detector.dart // pola makan abnormal (dari FoodLog saja)
    weekly_summary.dart
  screens/
    home_screen.dart
    log_food_screen.dart
    log_poop_screen.dart
    log_mules_screen.dart
    history_screen.dart
    insights_screen.dart
    settings_screen.dart
  widgets/
    bristol_picker.dart
    spicy_picker.dart
    log_timeline.dart
    insight_card.dart
  utils/
    date_utils.dart
    bristol_info.dart    // deskripsi 1-7
8. UI/UX
8.1 Referensi UI — Home Page + Gaya Duolingo (User, 25 Nov 2026)
Referensi: workspace/user/media_library/image/image-4c3efbfd.png (mock Home Page dari user). Ikuti gaya ini untuk SEMUA screen, bukan cuma Home.
Gaya visual: Duolingo-style (keputusan user 25 Nov 2026)
Gabungkan mock orange di atas dengan prinsip Duolingo:
Chunky & playful: tombol besar, rounded besar (16-24dp), font bold rounded, bukan tipis/minimal
Flat colors + thick outline: ikon dan ilustrasi flat dengan outline tebal gelap (2-3dp), bukan garis tipis atau gradient halus
Tombol 3D ala Duolingo: tombol utama punya bottom shadow / border bawah lebih gelap 4dp (contoh: tombol orange #FFA63D dengan bawah #E08A1E), saat ditekan tombol "turun" (shadow hilang). Terapkan ke tombol Simpan + tombol +Poop/+Meals/+Muyes.
Warna cerah, kontras tinggi, satu warna utama dominan (orange Muyes) + warna status hijau/kuning/merah hanya untuk waspada
Karakter / ikon ekspresif dengan mata besar, seperti maskot Duolingo — ikon Poop, Meals, Muyes harus punya muka / ekspresi, bukan ikon geometris polos
Jangan pakai gaya minimalis tipis, jangan pakai shadow abu-abu lembut yang samar — Duolingo itu bold dan jelas
Warna (pakai ini, jangan ngarang warna baru):
Primary orange: #FFA63D (background atas + bottom nav + border tombol)
Light orange: #FFC46B
Background: gradient / solid orange di atas → cream #FFF6E8 di bawah, atau solid #FFB35C untuk area header
Card: putih #FFFFFF, rounded 24dp, shadow lembut
Text: gelap #222222, judul di header putih #FFFFFF
Status waspada tetap hijau / kuning / merah hanya untuk level waspada, jangan dipakai sebagai warna utama
Font:
Heading / judul: font rounded playful bold (Fredoka; disarankan Baloo 2 sebagai alternatif) — contoh: "Hari Ini" putih, 32sp, bold. Di app ini font di-bundle lokal di assets/fonts (Fredoka 500/600/700 + Nunito 400/600/700) supaya app tetap jalan offline — bukan google_fonts runtime.
Body: Nunito / Quicksand, 14-16sp
Jangan pakai font default Material yang kaku untuk judul
Layout Home (ikuti referensi persis strukturnya):
Header: "Hari Ini" + tanggal, contoh "27 Sept 2026" — putih, bold, di atas background orange. Jangan tulis "Hari Ini..." (jangan ada ellipsis).
Kartu Stats (putih, rounded 24dp):
Baris atas: 3 kolom ikon + angka count hari ini — Eek (ikon eek coklat lucu bermata), Makan (ikon muka putih), Mules (ikon hijau dengan zigzag)
Di bawahnya: 3 baris Terakhir Makan | <waktu>, Terakhir Eek | <waktu>, Terakhir Mules | <waktu> — kalau waktunya hari ini tulis "Hari ini, 19:56", kemarin "Kemarin, 19:56"; kalau lebih lama dari kemarin baru tanggal lengkap "27 Sept 2026, 19:56" (koreksi user, 25 Nov 2026). Kalau belum ada log, tampilkan -, JANGAN "Bla bla" dan jangan data palsu.
Kartu Aksi (putih, rounded 24dp):
Judul tengah: "Catat makan, eek, dan mules!" + divider orange tipis
3 tombol sejajar, sama besar: + Eek, + Makan, + Mules — background putih, border orange 2dp, rounded 16dp, ikon 48dp di atas, label bold di bawah
Bottom Nav (floating pill):
Bar orange #FFA63D, rounded penuh (pill), 3 ikon putih: Beranda (Home), Riwayat (ikon dokumen), Pengaturan (ikon orang). Ikon aktif terisi penuh, non-aktif outline.
Ikon:
Pakai ikon lucu / custom seperti di referensi (eek coklat bermata, muka, lingkaran hijau zigzag), bukan ikon Material default yang kaku. Kalau belum ada aset gambar, buat sebagai widget / emoji besar yang konsisten di semua screen, jangan ganti-ganti gaya ikon per screen.
Aset Ikon Custom (Poop / Meals / Muyes) — 25 Nov 2026:
Export sebagai SVG (lebih baik dari PNG untuk ikon ini): scalable tanpa pecah di semua ukuran layar, file kecil, warna tetap tajam. PNG cuma fallback kalau ikonnya punya gradient/shadow kompleks yang rusak saat di-export SVG.
Taruh di folder project Flutter: assets/icons/ — nama file final:
assets/icons/meal.svg
assets/icons/poop.svg
assets/icons/muyes.svg
Pakai lewat helper MuyesIcon / MuyesIconView (lib/widgets/muyes_icons.dart) di semua tempat (Home, timeline, log screen), JANGAN ganti dengan emoji atau ikon Material (koreksi user, 25 Nov 2026).
Daftarkan di pubspec.yaml:
  flutter:
    assets:
      - assets/icons/
Tambah package flutter_svg di pubspec.yaml, pakai SvgPicture.asset('assets/icons/meal.svg') di Flutter. Jangan pakai Image.asset untuk SVG.
Export dari Figma: pilih frame ikon → Export SVG, 1x. Pastikan ikon flat, outline tebal, background transparan, ukuran canvas konsisten (misal 120x120px) biar ketiganya sejajar di Home.
App launcher icon — 25 Nov 2026:
Sumber: assets/icons/logo-muyes.png (maskot Muyes). Generate ikon Android (legacy mipmap + adaptive icon mipmap-anydpi-v26) + iOS AppIcon.appiconset lewat tool/generate_app_icons.py (butuh Python + Pillow). Android adaptive background: orange #FFA63D (color ic_launcher_background).
Gaya untuk screen lain:
Header orange + judul putih yang sama, kartu putih rounded 24dp, tombol utama orange / tombol sekunder putih border orange, bottom nav pill yang sama di semua screen utama (Beranda, Riwayat, Pengaturan).
Form log (Makan / Eek / Mules) pakai kartu putih yang sama, field dengan border orange lembut saat fokus, tombol Simpan orange penuh (gaya 3D DuoButton).
BAHASA UI (koreksi user, 25 Nov 2026): seluruh teks UI Bahasa Indonesia konsisten — "Hari Ini", "Terakhir Makan/Eek/Mules", "+ Eek / + Makan / + Mules", "Beranda/Riwayat/Pengaturan". Tidak boleh campur English di layar manapun.
Yang TIDAK boleh dicopy dari mock:
"Bla bla" di baris Terakhir — itu placeholder, ganti data asli atau -
"Hari Ini..." — tulis "Hari Ini" + tanggal lengkap (tanpa ellipsis)
Angka 0 yang statis — count harus dari DB hari ini
8.2 Aturan Umum
Tone: Santai, lucu dikit, tidak jijik, tidak medis-kaku. Emoji boleh, tapi jangan berlebihan.
Bristol Picker: Wajib visual — 7 pilihan dengan gambar/ikon bentuk + deskripsi, bukan dropdown angka doang.
Quick-log: Form makan & eek harus bisa selesai dalam 3 tap untuk kasus umum (waktu = sekarang, isi field wajib doang, simpan). Form eek paling minimal: 1 tap Simpan doang kalau cuma mau catat jam.
Tidak ada onboarding panjang. Buka app → langsung Home. Penjelasan Bristol muncul saat pertama kali log eek.
Dark mode: Opsional V1, boleh skip.
9. Acceptance Criteria (V1 Selesai Kalau...)
Bisa log makan <10 detik (waktu + nama + pedas + simpan)
Bisa log eek <5 detik kalau cuma waktu (buka form → Simpan langsung aktif, tanpa wajib isi Bristol/detail lain)
Bisa log eek <10 detik kalau isi Bristol juga (waktu + Bristol + simpan)
Bisa log mules <5 detik (buka form → pilih Ringan/Sedang/Parah → Simpan)
AI tidak crash / tidak ngarang insight kalau Bristol + detail eek kosong — cuma pakai frekuensi waktu
Mules yang dicatat di log eek + di log mules dalam <30 menit dihitung 1 kejadian, bukan 2x
Home menampilkan ringkasan hari ini dengan benar
History + kalender menampilkan semua log
Insights menampilkan minimal 1 korelasi yang benar dari data dummy (misal: 3x pedas → mules)
Abnormal detector memicu alert merah untuk darah & diare berulang di data dummy
Eating pattern detector memicu warning kuning dari data dummy (misal: makan 1x/hari 2 hari + makan berat jam 23:30 3x seminggu)
Toggle Mode Puasa ON mematikan warning skip-makan / gap panjang, tapi warning lain tetap jalan
Semua data tersimpan lokal, app bisa dibuka offline 100%
Export CSV/JSON menghasilkan file yang bisa dibuka
Tidak ada data yang dikirim ke internet (cek: tanpa permission internet pun app jalan)
10. Data Dummy untuk Testing
Agent WAJIB buat seed data dummy (toggle di Settings → "Isi data contoh"):
14 hari data: makan 3x/hari, eek 1-2x/hari
Pola sengaja: tiap makan pedas level 4-5, 6-10 jam kemudian mules 3-4 + Bristol 6
1 hari diare 4x (Bristol 7)
1 log dengan darah = true (untuk test alert merah)
3 hari tanpa eek di minggu ke-2 (untuk test konstipasi)
Pola makan abnormal sengaja: 2 hari cuma makan 1x/hari, 3x makan berat jam 23:30 dalam seminggu, 1 hari makan 6x, 1 hari kopi 4x (untuk test eating pattern detector)
Tombol "Hapus data contoh" harus ada.
11. Yang TIDAK Termasuk V1 (Jangan Dibangun Dulu)
Akun / login / sync cloud
Foto makanan dengan AI recognition
LLM / chatbot ("tanya AI soal perutku")
Share ke sosial media
Integrasi Apple Health / Google Fit
Multi-user / keluarga
Rekomendasi resep / meal plan
12. Cara Pakai File Ini untuk Vibecoding
Buat project Flutter baru, paste spec ini sebagai konteks.
Minta agent bangun sesuai urutan: Model + DB → Log Makan → Log Eek → Home → History → AI Insights → Settings.
Setiap selesai satu modul, minta agent jalankan flutter analyze + tunjukkan cara test manualnya.
Kalau agent mau nambah fitur di luar daftar di atas, suruh tanya dulu.
13. Keputusan User (25 Nov 2026 — Sudah Diputuskan)
Nama final app: Muyes
Platform: Android + iOS
Foto makanan: Skip di V1