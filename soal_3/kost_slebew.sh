#!/bin/bash
if [[ "$1" == "--check-tagihan" ]]; then
  SCRIPT_DIR="$(dirname "$0")"
  DATA_FILE="$SCRIPT_DIR/data/penghuni.csv"
  LOG_FILE="$SCRIPT_DIR/log/tagihan.log"
  tgl=$(date +"%Y-%m-%d %H:%M:%S")
  found=0
  while IFS=',' read -r nama kamar harga tanggal status; do
    if [[ "$status" == "Menunggak" ]]; then
      # Format harga ke Rp dengan titik ribuan
      harga_fmt=$(echo "$harga" | awk '{
        n=$1+0; f=""
        do { r=n%1000; n=int(n/1000)
          if(n>0) f="." sprintf("%03d",r) f
          else    f=r f
        } while(n>0)
        print "Rp" f
      }')
      echo "[$tgl] TAGIHAN: $nama (Kamar $kamar) - Menunggak $harga_fmt" >> "$LOG_FILE"
      found=1
    fi
  done < "$DATA_FILE"
  if [[ $found -eq 0 ]]; then
    echo "[$tgl] Tidak ada penghuni menunggak." >> "$LOG_FILE"
  fi
  echo "" >> "$LOG_FILE"
  exit 0
fi
while true; do
echo "==============================================="
echo "                                               
     ▄▄                                              
   ▄█▀▀█▄            █▄                █▄            
   ██  ██   ▄        ██               ▄██▄           
   ██▀▀██   ███▄███▄ ████▄ ▄▀▀█▄ ▄██▀█ ██ ▄▀▀█▄ ██ ██
 ▄ ██  ██   ██ ██ ██ ██ ██ ▄█▀██ ▀███▄ ██ ▄█▀██ ██▄██
 ▀██▀  ▀█▄█▄██ ██ ▀█▄████▀▄▀█▄███▄▄██▀▄██▄▀█▄██▄▄▀██▀
                                                  ██ 
                                                ▀▀▀  
                                                     "
echo "==============================================="
echo "          PLATFORM MANAJEMEN AMBASTAY          "
echo "==============================================="
echo " NO | OPTION                                   "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo " 1  | Tambah Penghuni Baru                     "
echo " 2  | Hapus Penghuni Baru                      "
echo " 3  | Tampilkan Daftar Penghuni                "
echo " 4  | Update Status Penghuni                   "
echo " 5  | Cetak Laporan Keuanganan                 "
echo " 6  | Kelola Cron (Pengingat Tagihan)          "
echo " 7  | Exit Program                             "
echo "==============================================="
read -p "$ [1-7] > " opsi

DATA_FILE="$(dirname "$0")/data/penghuni.csv" 

case $opsi in
  "1")
echo "==============================================="
echo "           TAMBAH PENGHUNI BARU                "
echo "==============================================="
read -p "> Masukkan Nama: " nama
while true; do
  read -p "> Masukkan Kamar: " kamar
  if grep -q "^[^,]*,${kamar}," "$DATA_FILE" 2>/dev/null; then
    echo " [!] Kamar ${kamar} sudah ditempati. Pilih kamar lain."
  else
    break
  fi
  done
  while true; do
    read -p "> Masukkan Harga Sewa: " harga_sewa
    if ! [[ "$harga_sewa" =~ ^[0-9]+$ ]] || [ "$harga_sewa" -le 0 ]; then
      echo " [!] Harga sewa harus berupa angka positif."
    else
      break
    fi
  done
  today=$(date +%Y-%m-%d)
  while true; do
    read -p "> Masukkan Tanggal Masuk (YYYY-MM-DD): " tanggal_masuk
    if ! [[ "$tanggal_masuk" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      echo " [!] Format tanggal salah. Gunakan YYYY-MM-DD."
    elif [[ "$tanggal_masuk" > "$today" ]]; then
      echo " [!] Tanggal tidak boleh melebihi hari ini ($today)."
    else
      break
    fi
  done
  while true; do
    read -p "> Masukkan Status Awal (Aktif/Menunggak): " status
    if [[ "$status" != "Aktif" && "$status" != "Menunggak" ]]; then
      echo " [!] Status harus 'Aktif' atau 'Menunggak'."
    else
      break
    fi
  done
  echo "${nama},${kamar},${harga_sewa},${tanggal_masuk},${status}" >> "$DATA_FILE"
  echo " [v] Penghuni $nama di kamar $kamar berhasil ditambahkan dengan status $status"
  echo "==============================================="
  read -p "Tekan ENTER untuk kembali ke menu utama..."
  ;;
  "2")
    HISTORY_FILE="$(dirname "$0")/sampah/history_hapus.csv"
    echo "==============================================="
    echo "              HAPUS PENGHUNI                   "
    echo "==============================================="
    read -p "Masukkan nama penghuni yang akan dihapus: " nama_hapus
    baris=$(grep -i "^${nama_hapus}," "$DATA_FILE" 2>/dev/null | head -n 1)
    if [ -z "$baris" ]; then
      echo " [!] Penghuni \"$nama_hapus\" tidak ditemukan di database."
    else
      tgl_hapus=$(date +%Y-%m-%d)
      echo "${baris},${tgl_hapus}" >> "$HISTORY_FILE"
      grep -iv "^${nama_hapus}," "$DATA_FILE" > /tmp/penghuni_tmp.csv
      mv /tmp/penghuni_tmp.csv "$DATA_FILE"
      echo " [v] Data penghuni \"$nama_hapus\" berhasil diarsipkan ke sampah/history_hapus.csv dan dihapus dari sistem."
    fi
    echo "==============================================="
    read -p "Tekan ENTER  untuk kembali ke menu utama"
    ;;
  "3")
    echo "==============================================="
    echo "          DAFTAR PENGHUNI KOST SLEBEW          "
    echo "==============================================="
    echo " No | Nama           | Kamar | Harga Sewa     | Status"
    echo "-----------------------------------------------"
    if [ ! -s "$DATA_FILE" ]; then
      echo " (Belum ada penghuni terdaftar)"
    else
      awk -F',' '
      {
        no++
        nama    = $1
        kamar   = $2
        harga   = $3
        status  = $5

        n = harga + 0
        formatted = ""
        do {
          r = n % 1000
          n = int(n / 1000)
          if (n > 0)
            formatted = "." sprintf("%03d", r) formatted
          else
            formatted = r formatted
        } while (n > 0)
        harga_fmt = "Rp" formatted

        printf " %-2d | %-14s | %-5s | %-14s | %s\n", no, nama, kamar, harga_fmt, status
        print "-----------------------------------------------"

        total++
        if (status == "Aktif")     aktif++
        else if (status == "Menunggak") nunggak++
      }
      END {
        printf " Total: %d penghuni | Aktif: %d | Menunggak: %d\n", total, aktif+0, nunggak+0
      }
      ' "$DATA_FILE"
    fi
    echo "==============================================="
    read -p "Tekan [ENTER] untuk kembali ke menu..."
    ;;
  "4")
    echo "==============================================="
    echo "              UPDATE STATUS                    "
    echo "==============================================="
    read -p "Masukkan Nama Penghuni: " nama_update
    while true; do
      read -p "Masukkan Status Baru (Aktif/Menunggak): " status_baru
      if [[ "$status_baru" != "Aktif" && "$status_baru" != "Menunggak" ]]; then
        echo " [!] Status harus 'Aktif' atau 'Menunggak'."
      else
        break
      fi
    done
    baris_update=$(grep -i "^${nama_update}," "$DATA_FILE" | head -n 1)
    if [ -z "$baris_update" ]; then
      echo " [!] Penghuni \"$nama_update\" tidak ditemukan."
    else
      awk -F',' -v nama="$nama_update" -v status="$status_baru" 'BEGIN{OFS=","} {
        if (tolower($1) == tolower(nama)) $5 = status
        print
      }' "$DATA_FILE" > /tmp/penghuni_update.csv
      mv /tmp/penghuni_update.csv "$DATA_FILE"
      echo " [v] Status $nama_update berhasil diubah menjadi: $status_baru"
    fi
    echo "==============================================="
    read -p "Tekan [ENTER] untuk kembali ke menu..."
    ;;
  "5")
    LAPORAN_FILE="$(dirname "$0")/rekap/laporan_bulanan.txt"
    bulan=$(date +"%B %Y")
    echo "==============================================="
    echo "       LAPORAN KEUANGAN KOST SLEBEW            "
    echo "==============================================="
    awk -F',' -v laporan="$LAPORAN_FILE" '
    function rupiah(n,    r, f) {
      f = ""
      do {
        r = n % 1000
        n = int(n / 1000)
        if (n > 0) f = "." sprintf("%03d", r) f
        else       f = r f
      } while (n > 0)
      return "Rp" f
    }
    {
      total_kamar++
      status = $5
      harga  = $3 + 0
      if (status == "Aktif") {
        total_masuk += harga
      } else if (status == "Menunggak") {
        total_tunggak += harga
        nunggak_list = nunggak_list "   " $1 "\n"
        nunggak++
      }
    }
    END {
      sep = "-----------------------------------------------"
      l1  = " Total pemasukan (Aktif)  : " rupiah(total_masuk+0)
      l2  = " Total tunggakan          : " rupiah(total_tunggak+0)
      l3  = " Jumlah kamar terisi      : " total_kamar+0
      print "==============================================="
      print l1
      print l2
      print l3
      print sep
      print " Daftar penghuni menunggak:"
      if (nunggak+0 == 0)
        print "   Tidak ada tunggakan."
      else
        printf "%s", nunggak_list
      print ""
      print "==============================================="

      # Simpan ke file
      print "==============================================="  > laporan
      print l1                                               >> laporan
      print l2                                               >> laporan
      print l3                                               >> laporan
      print sep                                              >> laporan
      print " Daftar penghuni menunggak:"                   >> laporan
      if (nunggak+0 == 0)
        print "   Tidak ada tunggakan."                      >> laporan
      else
        printf "%s", nunggak_list                            >> laporan
      print "===============================================" >> laporan
    }
    ' "$DATA_FILE"
    echo " [v] Laporan berhasil disimpan ke rekap/laporan_bulanan.txt"
    read -p "Tekan [ENTER] untuk kembali ke menu..."
    ;;
  "6")
    SCRIPT_PATH="$(realpath "$0")"
    CRON_MARKER="$SCRIPT_PATH --check-tagihan"
    while true; do
      echo "================================="
      echo "         MENU KELOLA CRON        "
      echo "================================="
      echo " 1. Lihat Cron Job Aktif"
      echo " 2. Daftarkan Cron Job Pengingat"
      echo " 3. Hapus Cron Job Pengingat"
      echo " 4. Kembali"
      echo "================================="
      read -p "Pilih [1-4]: " pilih_cron
      echo ""
      case $pilih_cron in
        "1")
          echo "--- Daftar Cron Job Pengingat Tagihan ---"
          hasil=$(crontab -l 2>/dev/null | grep "$CRON_MARKER")
          if [ -z "$hasil" ]; then
            echo "  (Tidak ada cron job aktif)"
          else
            echo "$hasil"
          fi
          read -p "Tekan [ENTER] untuk kembali ke menu..."
          ;;
        "2")
          while true; do
            read -p "Masukkan Jam (0-23): " jam
            if [[ "$jam" =~ ^[0-9]+$ ]] && [ "$jam" -ge 0 ] && [ "$jam" -le 23 ]; then
              break
            else
              echo " [!] Jam tidak valid. Masukkan angka 0-23."
            fi
          done
          while true; do
            read -p "Masukkan Menit (0-59): " menit
            if [[ "$menit" =~ ^[0-9]+$ ]] && [ "$menit" -ge 0 ] && [ "$menit" -le 59 ]; then
              break
            else
              echo " [!] Menit tidak valid. Masukkan angka 0-59."
            fi
          done
          menit_fmt=$(printf "%02d" "$menit")
          jam_fmt=$(printf "%02d" "$jam")
          cron_job="$menit_fmt $jam_fmt * * * $CRON_MARKER"
          (crontab -l 2>/dev/null | grep -v "$CRON_MARKER"; echo "$cron_job") | crontab -
          echo " [v] Cron job berhasil didaftarkan: $cron_job"
          read -p "Tekan [ENTER] untuk kembali ke menu..."
          ;;
        "3")
          if crontab -l 2>/dev/null | grep -q "$CRON_MARKER"; then
            crontab -l 2>/dev/null | grep -v "$CRON_MARKER" | crontab -
            echo " [v] Cron job pengingat tagihan berhasil dihapus."
          else
            echo " [!] Tidak ada cron job pengingat yang aktif."
          fi
          read -p "Tekan [ENTER] untuk kembali ke menu..."
          ;;
        "4")
          break
          ;;
        *)
          echo " [!] Pilihan tidak valid."
          ;;
      esac
      echo ""
    done
    ;;
  "7")
    echo "==============================================="
    echo "      Exiting AMBASTAY management system       "
    echo "==============================================="
    exit 0
    ;;
  *)
    echo " [!] Pilihan tidak valid. Masukkan angka 1-7."
    ;;
esac
done