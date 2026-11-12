---
title: Panel Kontrol
description: Gunakan kartu panel kontrol Quickshell.
---

Panel Kontrol adalah permukaan Quickshell akses cepat untuk sesi aktif. Ini adalah tempat untuk memeriksa status atau melakukan tindakan yang sering dilakukan tanpa membuka aplikasi pengaturan penuh.

Panel menggunakan katalog bersama `argvus-i18n`. Ketika bahasa yang berbeda diterapkan di **Control Center → Locale & Region**, layanan Control Panel akan dimulai ulang secara otomatis sehingga dapat memuat katalog yang dipilih.

Control Panel berbagi tepi taskbar dengan ARGVUS Focus dan ARGVUS Clock. Membuka panel akan menutup kedua popup terlebih dahulu; membuka Focus atau Clock akan menutup panel.

## Panel Kontrol atau Pusat Kontrol?

Gunakan panel untuk status saat ini dan tindakan cepat. Gunakan [Control Center](/docs/components/argvus-control-center/) ketika Anda ingin mengubah konfigurasi desktop yang persisten. Misalnya, panel dapat menampilkan kontrol tampilan, layar, jaringan, volume, kecerahan, notifikasi, daya, dan sesi; konfigurasi visual dan tata letak yang detail berada di **Control Center → Appearance**.

## Kartu-kartu

Registry kartu saat ini mencakup:

- Pengguna;
- Pemberitahuan;
- Kalender;
- Cuaca;
- Volumenya;
- Kecerahan;
- Jaringan;
- Bluetooth;
- Sistem;
- Penampilan;
- Sesi;
- Menampilkan;
- Kekuatan.

Beberapa kartu bersifat kondisional. Bluetooth disembunyikan ketika kemampuan Bluetooth tidak tersedia. Kecerahan disembunyikan ketika baik backlight yang didukung maupun alat kontrol monitor tidak tersedia. Oleh karena itu daftar kartu mencerminkan mesin saat ini daripada menjanjikan kontrol yang bisa disediakan setiap mesin.

## Visibilitas dan urutan

Halaman **Appearance → Control Panel** pada panel memungkinkan Anda mengaktifkan, menonaktifkan, dan mengatur ulang kartu. Pembantu yang dikemas juga menampilkan status yang sama:

```sh
cards-config.sh status
cards-config.sh set <card> enabled
cards-config.sh set <card> disabled
cards-config.sh move <card> <index>
```

Gunakan antarmuka pengguna jika memungkinkan. Status panel disimpan sebagai konfigurasi pengguna; ini terpisah dari file tata letak Hyprland yang dihasilkan.

Menonaktifkan sebuah kartu menyembunyikannya dari panel; ini tidak mencopot pemasok yang ada di baliknya. Mengubah urutan mengubah urutan penyajian kartu. Tidak ada subperintah `reset` dalam pembantu saat ini. Jika preferensi kartu pengguna dihapus, penyedia akan menormalkan kembali keadaan ke kartu yang dikenal, yang diaktifkan secara default dan dalam urutan paket.

Kartu tampilan Panel Kontrol tidak lagi mengelola pengaturan Transparansi global. Konfigurasikan Transparansi dan Blur secara terpisah untuk Panel Kontrol di **Control Center → Appearance → Control Panel**. Saklar utama **Enable** Panel Kontrol masih mengontrol seluruh permukaan dan layanannya. `cards-config.sh master set` hanya memulai ulang atau menghentikan panel ketika saklar berubah; menyetel nilai yang sudah dimilikinya hanya memastikan panel yang diaktifkan berjalan.

## Navigasi keyboard

Saat panel terbuka, gunakan **↑/↓** untuk menggulir isinya. **Tab** bergerak maju melalui tombol, kontrol, dan bidang; **Shift+Tab** bergerak mundur. Tombol menunjukkan fokus dengan bingkai yang disorot dan dapat diaktifkan dengan **Enter** atau **Space**. Slider dan bidang teks mempertahankan tombol tersebut untuk penyesuaian atau pengeditan mereka sendiri. **Esc** menutup panel.

## Tetap selaras dengan sisa desktop

Kartu Notifikasi menyembunyikan riwayatnya saat mode Jangan Ganggu aktif. Notifikasi yang diterima selama waktu itu tetap berada di Dunst dan akan muncul kembali di kartu setelah mode Jangan Ganggu dimatikan.

Kartu menampilkan keadaan langsung dari desktop. Perubahan yang dilakukan di tempat lain (Control Center, bilah tugas, pintasan keyboard, atau baris perintah `argvus`) akan muncul di panel tanpa perlu memulainya kembali:

| Kartu | Dari mana keadaan berasal | Kapan itu diperbarui |
| --- | --- | --- |
| Pengguna | `getent passwd` | setiap 3 detik saat panel terbuka |
| Volume | saluran default PipeWire (`wpctl`) and `pactl subscribe`acara | segera pada setiap acara audio; setiap 2 detik sebagai jaring pengaman |
| Penampilan (Telemetri, Animasi, dan Efek) | itu `/effects`bagian dari`argvus config`| setiap 2 detik saat panel terbuka |
| Kekuatan | `powerprofilesctl` | setiap 3 detik saat panel terbuka |
| Cuaca | file lokasi dan penyedia wttr.in/Open-Meteo | saat panel dibuka dan setiap 15 menit; tab berganti antara kondisi saat ini dan prakiraan harian untuk tujuh hari ke depan |

Kartu Tampilan memiliki dua saklar independen. **Animasi** menjalankan `argvus effects-toggle animations toggle` dan mengontrol semua yang bergerak. **Efek** menjalankan `argvus effects-toggle effects toggle` dan mengubah blur serta transparansi Terminal, Launcher, Widget Telemetry, Panel Kontrol, dan Taskbar secara bersamaan; akan terlihat aktif ketika setidaknya salah satu dari mereka aktif. **SUPER + F6** (`argvus effects-toggle toggle`) mengubah keduanya secara bersamaan. Mengubah salah satunya akan memuat ulang Hyprland dan konsumen tema secara langsung: Waybar membaca ulang stylesheet-nya, panel memuat ulang melalui IPC, dan Dunst memuat ulang konfigurasinya kecuali mode Jangan Ganggu aktif, dalam hal ini pemuat ulang ditunda hingga DND dimatikan. Tidak ada yang dimulai ulang dan tidak ada layar pemuatan yang muncul.

Menggulir ikon volume di taskbar dan tombol media menggunakan `argvus config audio`, yang menerapkan perubahan ke PipeWire dan juga mencatat volume di `/audio`. Oleh karena itu, memuat ulang konfigurasi tidak mengembalikan volume lama.

## Perilaku sesi

`argvus-control-panel.service` dimulai oleh `argvus-session` `argvus config display night-light status|toggle` . Membuka dan menutup panel mengubah status panel sesi, tetapi tidak berarti bahwa setiap tindakan kartu adalah konfigurasi yang persisten. Tindakan jaringan, audio, daya, dan tampilan dapat diserahkan kepada penyedia mereka atau ke sesi desktop saat ini.

Lihat [taskbar dan panel](/docs/argvus-taskbar/taskbar/) untuk hubungan antara panel, margin taskbar, dan tata letak jendela.

## Cahaya Malam

Kartu Tampilan menunjukkan tombol nyala/mati Lampu Malam dan suhu aktif. Sudut dan animasinya mengikuti token tema yang sama dengan sakelar panel lainnya, termasuk tata letak Sticky dan Spaced. Sakelar tidak memiliki batas dan menggunakan kursor penunjuk, seperti sakelar panel lainnya. Ini menggunakan

, melakukan polling setiap dua detik saat terbuka dan mengambil kembali setelah suatu tindakan. Baris disembunyikan ketika backend tidak tersedia; tindakan yang gagal menunjukkan kesalahan. Penjadwalan dan suhu dikonfigurasi di **Pusat Kontrol > Desktop & Input > Tampilan > Lampu Malam**. Pengalihan manual terjadwal berlangsung hingga transisi berikutnya; jika tidak, aktivasi akan terus-menerus.

Kalender bilah tugas, ARGVUS Focus, ARGVUS Clock, dan Panel Kontrol saling eksklusif: membuka salah satunya menutup yang lain.

## Label multibahasa kompak

Tab cuaca menggunakan katalog bersama (kondisi saat ini dan tujuh hari). Cuaca
pengukuran menempati kolom dengan lebar sama; label membungkus dan nilai tetap sejajar.
Singkatan hari dalam kalender bersifat spesifik lokal dan dimulai dari hari Minggu, termasuk
label hari prakiraan. Mereka bukan terjemahan harfiah dari singkatan bahasa Inggris.

Tombol mengikat grup ikon/label mereka ke lebar yang tersedia. Jika sebuah label membutuhkan
elipsis, melayang atau memfokuskan tombol akan menampilkan teks penuhnya. Profil daya
tombol juga menampilkan teks deskriptif mereka dalam tooltip. Deskripsi saklar panjang
dibungkus, dan bidang numerik serta input pengguna menyediakan cukup ruang untuk font yang dipilih.
Tinggi kartu bertambah dengan teks yang dibungkus; gunakan gulir vertikal untuk melihat kartu di bawah.
Perubahan ini mempertahankan font yang dipilih dan tindakan kartu yang ada.
