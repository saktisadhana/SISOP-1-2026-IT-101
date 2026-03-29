# SISOP-1-2026-IT-101

## Identitas Praktikan

| Nama                     | NRP        | Kode Asisten |
| ------------------------ | ---------- | ------------ |
| Putu Putra Sakti Sadhana | 5027251101 | NINN         |
## Reporting
### Soal 1

Praktikan diinstruksikan untuk membuat suatu file dengan nama `KANJ.sh` yang berfungsi untuk mengekstrak data dari `passenger.csv`. Sesuai dengan instruksi soal, untuk menggunakan program, praktikan harus menjalankan command :

```bash
awk -f KANJ.sh passenger.csv a
```

Command di atas menunjukkan bahwa `KANJ.sh` merupakan suatu script awk karena command `awk -f file` itu sendiri menjadikan file `KANJ.sh` sebagai sumber kode programnya yang akan dijalankan terhadap suatu input data (`passenger.csv`).

Di dalam `KANJ.sh` terdapat lima opsi (a, b, c, d, & e), opsi tersebut akan dijelaskan lebih lanjut pada bagian **Penjelasan**.

#### Penjelasan

##### KANJ.sh

Dalam bahasa pemrograman awk, siklus eksekusi utama memproses kode secara berurutan, membaca baris data satu per satu dari atas hingga bawah. Namun terdapat dua pola khusus yang dapat berjalan di luar siklus eksekusi utama, kedua pola tersebut merupakan BEGIN dan END.

Secara singkat BEGIN berjalan sebelum data dibaca, sedangkan END berjalan setelah semua baris dalam data telah selesai dibaca.

```shell
BEGIN {
FS = ","
#Dalam array ARGV, command "awk -f KANJ.sh passenger.csv a" disimpan menjadi:
#ARGV[0] = awk
#ARGV[1] = passenger.csv
#ARGV[2] = a
file = ARGV[1]
#menyimpang ARGV[2] kedalam variabel mode, jadi jika ARGV[2] = a, mode juga akan bernilai "a"
mode = ARGV[2]
#Karena awk mengira ARGV[2] (a,b,c, & d) adalah sebuah file kita harus menghapus ARGV[2]
delete ARGV[2]
}
```

Bisa dilihat dari cuplikan kode diatas, saya melakukan beberapa hal sebelum program akan membaca `passenger.csv`. 

1. Saya menetapkan karakter `,`(Koma) sebagai Field Seperator (Pemisah kolom) dari `passenger.csv`.
2. Saya menyimpan ARGV[1] (passenger.csv) kedalam variabel file.
3. Saya menyimpan ARGV[2] (a) kedalam variabel mode.
4. Saya menghapus data yang tersimpan dalam ARGV[2].

Hal ini saya lakukan karena beda dengan shell scripting, semua argumen pada penjalanan command awk akan selalu dianggap sebagai sebuah file. Untuk menghindari masalah program berusaha membuka file yang tidak ada, setelah kita menyimpan ARGV[2] kedalam sebuah variabel (mode), kita dapat langsung menghapus data yang tersimpan dalam ARGV[2].

Setelah semua itu dijalankan kita bisa masuk kedalam siklus eksekusi utama

```shell
{
#Untuk menghilangkan \r 
sub(/\r$/, "")

if ( NR > 1 )
{
	if ( mode == "a" )
		{
			#Akan menghitung record dalam column pertama karena setiap penumpang unik
			count_passenger++
		} else if ( mode == "b" )
		{
			count_carriage[$4]++
		} else if ( mode == "c" )
		{	#Yang tertua
			if ( $2 > age )
			{
				age = $2; oldest = $1 
			}
		} else if ( mode == "d" )
		{
			total_age += $2; count_passenger++
		} else if ( mode == "e" )
		{
			if ( $3 == "Business")
			{
				business_passenger++
			}
		}
}
}
```

Dalam cuplikan kode di atas saya melakukan beberapa hal sebelum masuk kedalam logika 5 opsi / mode yang bisa dipilih 

1. Saya menghilangkan `\r` yang merupakan karakter tersembunyi bawaan windows (CRLF) dari `passenger.csv` 
2. Saya mengabaikan baris pertama agar `Nama Penumpang,Usia,Kursi Kelas,Gerbong` tidak terbaca

Setelah itu untuk logika dari 5 opsi yang dapat dipilih

	Jumlah seluruh penumpang KANJ adalah  $(count_passenger) orang
Untuk opsi ini saya menghitung seluruh baris - 1 tabel tersebut

	Jumlah gerbong penumpang KANJ adalah $(carriage)
Untuk opsi ini saya memilih untuk mendata seluruh kolumn ke-4 kedalam array yang bernama count_carriage, setelah mendata seluruh kolumn saya memeriksa panjang dari array tersebut untuk mendapatkan jumlah gerbong penumpang.

	$(oldest) adalah penumpang kereta tertua dengan usia $(age) tahun
Untuk opsi ini saya memeriksa kolum ke-2, baris per baris apakah nilai baris tersebut lebih besar daripada variabel age (Yang dimana pada baris pertama age akan bernilai 0), jika iya nilai dari variabel age akan sama dengan nilai baris tersebut, selain itu nama yang terdapat pada kolumn pertama dengan baris yang sama akan di data kedalam variabel oldest.

	Rata-rata usia penumpang adalah $(average_age) tahun
Untuk opsi ini saya memilih untuk menjumlahkan nilai pada kolumn ke-2, disamping menjumlahkan bari per baris, saya juga menghitung jumlah total baris dengan melakukan peningkatan nilai variabel count_passenger setiap baris dibaca.

	Jumlah penumpang business class ada $(business_passenger) orang
Untuk opsi terakhir saya memilih untuk memeriksa kolumn ke-3 dan melakukan peningkatan nilai variabel business_passenger setiap nilai baris tersebut setara dengan Business.

Setelah seluruh baris selesai dibaca, kode akan menjalankan bagian berikut

```shell
END {
	if ( mode == "a" )
	{
		print "Jumlah seluruh penumpang KANJ adalah " count_passenger " orang"
	} else if ( mode ==  "b" )
	{
		carriage = length(count_carriage)
		print "Jumlah gerbong penumpang KANJ adalah " carriage
	} else if ( mode == "c" )
	{
		print oldest " adalah penumpang kereta tertua dengan usia " age " tahun"
	} else if ( mode == "d" )
	{
                average_age = total_age / count_passenger
                # Membuang (memotong) semua angka di belakang koma
                average_age = int(average_age)
		print "Rata-rata usia penumpang adalah " average_age " tahun"
	} else if ( mode == "e" )
	{
		print "Jumlah penumpang business class ada " business_passenger " orang"
	} else
	{
		print "Soal tidak dikenali. Gunakan a, b, c, d, atau e.\nContoh Penggunaan: awk -f file.sh data.csv a"
	}
}
```

Bagian ini hanya berfungsi untuk menunjukkan seluruh variabel yang telah didata pada siklus eksekusi utama. Satu hal yang mau saya komentari adalah line `average_age = int(average_age)` yang berfungsi untuk memotong semua angka di belakang koma, sesuai dengan instruksi soal.
#### Output

1. Menjalankan mode `a`
![Pasted image 20260323192908](https://raw.githubusercontent.com/saktisadhana/SISOP-1-2026-IT-101/main/Assets/Pasted%20image%2020260323192908.png)
2. Menjalankan mode `b`
![Pasted image 20260323191457](https://raw.githubusercontent.com/saktisadhana/SISOP-1-2026-IT-101/main/Assets/Pasted%20image%2020260323191457.png)
3. Menjalankan mode `c`
![Pasted image 20260323191514](https://raw.githubusercontent.com/saktisadhana/SISOP-1-2026-IT-101/main/Assets/Pasted%20image%2020260323191514.png)
4. Menjalankan mode `d`
![Pasted image 20260323191540](https://raw.githubusercontent.com/saktisadhana/SISOP-1-2026-IT-101/main/Assets/Pasted%20image%2020260323191540.png)
5. Menjalankan mode `e`
![Pasted image 20260323191603](https://raw.githubusercontent.com/saktisadhana/SISOP-1-2026-IT-101/main/Assets/Pasted%20image%2020260323191603.png)
6. Menjalankan mode selain `a, b, c, d, atau e`
![Pasted image 20260323191619](https://raw.githubusercontent.com/saktisadhana/SISOP-1-2026-IT-101/main/Assets/Pasted%20image%2020260323191619.png)
#### Kendala

Tidak ada kendala.
### Soal 2

Praktikan diisntruksikan untuk mencari sebuah link GitHub yang disematkan di dalam file `peta-ekspedisi-amba.pdf`. Setelah mendapatkan link tersebut, praktikan bisa mendapatkan `gsxtrack.json`.  Di dalam file ini terdapat variabel `id, site_name, latitude, longitude`, praktikan harus bisa mendapatkan nilai dari variabel tersebut yang dimana setelah itu harus disimpan kedalam `titik-penting.txt`. Dengan adanya `titik-penting.txt` praktikan bisa titik lokasi pusaka dengan mencari titik tengah dari empat node yang dimana hasil dari kakulasi tersebut harus disimpan kedalam `posisipuka.txt`.
#### Penjelasan

##### Mendownload PDF, mendapatkan link GitHub, & Git clone repo

Setelah melakukan command

```bash
gdown https://drive.google.com/uc?id=1q10pHSC3KFfvEiCN3V6PTroPR7YGHF6Q
```

Saya melakukan command 

```bash
strings peta-ekspedisi-amba.pdf
```

untuk mendapatkan link GitHub.

Saya memilih untuk melakukan command strings karena dari soal disebut bahwa "Setelah seharian scrolling isi file pdf yang seperti bahasa Alien Vrindavan". Deskripsi tersebut sangat sesuai dengan pengalaman saya ketika menggunakan command strings kepada file apapun. 

Setalah mendapatkan link, sesuai dengan instruksi soal yang dimana saya harus menduplikat repo tersebut, saya harus melakukan command.

```bash
git clone https://github.com/pocongcyber77/peta-gunung-kawi.git
```

##### parserkoordinat.sh

Untuk mengambil nilai dari variabel `id, site_name, latitude, longitude` saya memilih untuk menggunakan awk.

```shell
#!/bin/bash
awk '
BEGIN {
FS = "[\":,]"
OFS = ","
}
```

Sebelum membaca `gsxtrack.json` saya menentukan bahwa *Field Seperator* file tersebut adalah `,`(Koma), `"` (Tanda kutip dua), & `:` (Titik dua). Selain itu sesuai dengan instruksi soal, karena data tersebut harus disimpan dengan format `id,site_name,latitude,longitude` saya memilih `,` (Koma) sebagai *Output Field Separator* (Pemisah kolom output).

Setelah itu menuju bagian siklus eksekusi utama

```shell
/site_name/ {
site_name = $5
}
/id/ {
id = $5
}
/latitude/ {
lat = $4
gsub(/ /, "", lat)
}
/longitude/ {
long = $4
gsub(/ /, "", long)
print id,site_name,lat,long
}
` gsxtrack.json > titik-penting.txt
```

Pada bagian ini saya memperintahkan program untuk mencari 4 pola yaitu `site_name,id,latitude,longitude`. Setelah menghilangkan FS yang telah ditentukan, program akan melihat `gsxtrack.json` seperti ini:

```
...
" site_name " : " Titik Berak Paman Mas Mba ",
...
```

- $1 adalah karakter sebelum tanda kutip dua pertama.
- $2 adalah karakter sebelum tanda kutip dua ke-2  yang merupakan `site_name`.
- $3 adalah karakter sebelum titik dua pertama.
- $4 adalah karakter sebelum tanda kutip dua ke-3.
- $5 adalah karakter sebelum tanda kutip dua ke-4 yang merupakan Titik Berak Paman Mas Mba.
- $6 adalah karakter sebelum tanda koma.

Sedangkan untuk latitude dan longitude, program akan melihat `gsxtrack.json` seperti ini:

```
...
"latitude": -7.920000,
...
```

- $1 adalah karakter sebelum tanda kutip dua pertama.
- $2 adalah karakter sebelum tanda kutip dua ke-2  yang merupakan `latitude`.
- $3 adalah karakter sebelum titik dua pertama.
- $4 adalah karakter sebelum tanda koma yangmerupakan ` -7.920000`.

Jika bisa dilihat output dari ekstraksi latitude adalah

```
" -7.920000"
```

Untuk menghilangkan spasi di depan tanda minus saya menggunakan `gsub(/ /, "", lat)`. Kode tersebut memerintahkan program untuk mencari spasi pada variabel `lat` dan setelah itu menggantikannya dengan blank space.

Setelah program selesai membaca `gsxtrack.json` baris per baris program akan menjalankan kode

```
...
print id,site_name,lat,long
}
` gsxtrack.json > titik-penting.txt
echo "Parsing i mari cak. tak simpen ndek : titik-penting.txt"
...
```

Di dalam kode ini, program akan print nilai dari variabel `id,site_name,lat,long`. Hasil print tersebut akan tersimpan kedalam `titik-penting.txt`

Setelah semua itu terjadi sesuai dengan instruksi soal, program akan memberikan respons "Parsing i mari cak. tak simpen ndek : titik-penting.txt".

##### nemupusaka.sh

Mengikuti instruksi soal `nemupusaka.sh` berfungsi untuk mencari titik tengah dari empat titik / nodes yang telah berhasil disimpan pada file `titik-penting.txt`. Untuk mengambil data dari file tersebut saya memilih untuk menggunakan awk, yang dimana nantinya akan di kalkulasi menggunakan shell scripting.

```shell
#!/bin/bash
awk '
BEGIN{
FS = ","
OFS = ","
}
```

Sebelum membaca `titik-penting.txt`, saya memerintahkan program untuk menetapkan karakter `,` (Koma) sebagain *Field Seperator* dan *Output Field Separator*. Setelah itu dalam siklus eksekusi utama

```shell
NR > 2{
total_ya += $3; total_xa += $4; total_ya = total_ya / 2; total_xa = total_xa /2
}
NR <= 2{
total_yb += $3; total_xb += $4; total_yb = total_yb / 2; total_xb = total_xb / 2
}
```

Saya memisahkan kalukulasi menjadi dua bagian:

	NR >2
Merupakan bagian dimana program hanya melakukan kalkulasi terhadap variabel`latitude` yang bernilai `-7.937960`. Sedangkan bagian...

	NR <=2
Hanya melakukan kalkulasi terhadap variabel `latitude` yang bernilai `-7.920000`.

Mengikuti rumus yang telah diberikan oleh soal, penjumlah ke-dua nilai latitude / longitude akan dibagi oleh 2. Saya juga menyimpan hasil kalkulasi tersebut kedalam variabel nya masing-masing.

```
END {
total_y = (total_ya+total_yb)/2; total_x = (total_xa+total_xb)/2
print total_y,total_x
}
' titik-penting.txt > posisipuka.txt
hasil=$(cat posisipuka.txt)
echo "Koordinat pusat:"
echo "$hasil"
```

Setelah program selesai membaca `titik-penting.txt` saya melakukan kalkulasi terakhir untuk mendapatkan total dari latitude dan total dari longitude. Hasil dari kalkulasi tersebut akan tersimpan kedalam file `posisipusaka.txt`.

Karena program harus menampilkan hasil dari kallkulasi saya memilih untuk membaca `posisipusaka.txt` menyimpan output tersebut kedalam variabel `hasil` dan setelah itu   menampilkannya ke terminal menggunakan perintah `echo`.

#### Output

1. `parserkoordinat.sh`
![Pasted image 20260324100805](https://raw.githubusercontent.com/saktisadhana/SISOP-1-2026-IT-101/main/Assets/Pasted%20image%2020260324100805.png)
2. `titik-penting.txt`
![Pasted image 20260324100850](https://raw.githubusercontent.com/saktisadhana/SISOP-1-2026-IT-101/main/Assets/Pasted%20image%2020260324100850.png)
3. `nemupusaka.sh`
![Pasted image 20260324101452](https://raw.githubusercontent.com/saktisadhana/SISOP-1-2026-IT-101/main/Assets/Pasted%20image%2020260324101452.png)
4. `posisipusaka.txt`
![Pasted image 20260324101529](https://raw.githubusercontent.com/saktisadhana/SISOP-1-2026-IT-101/main/Assets/Pasted%20image%2020260324101529.png)

#### Kendala

1. Karena  terrdapat foler tersembunyi yang bernama `.git` pada bagian `peta-gunung-kawi` saya mengalami kendala saat push ke GitHub.
2. Setelah diperiksa formula `nemupusaka.sh` keliru / salah ;-;

### Soal 3

Praktikan diinstruksikan untuk membuat suatu program yang dapat mengelola suatu kost. Dalam program tersebut terdapat 6 opsi yang bisa dilakukan saat menjalankan program. Opsi tersebut akan dijelaskan lebih lanjut pada bagian selanjutnya.
#### Penjelasan

##### Menu Utama Program

```bash
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
    echo " 2  | Hapus Penghuni                           "
    echo " 3  | Tampilkan Daftar Penghuni                "
    echo " 4  | Update Status Penghuni                   "
    echo " 5  | Cetak Laporan Keuangan                   "
    echo " 6  | Kelola Cron (Pengingat Tagihan)          "
    echo " 7  | Exit Program                             "
    echo "==============================================="
    read -p "$ [1-7] > " opsi
```

Mengikuti instruksi soal, program harus memuat 6 opsi yang dapat dipilih pada menu utama program. Seluruh kode diinkapsulasi dalam sebuah `while loop; do`, yang menyebabkan program dapat berjalan berulang kali sebelum memilih opsi ke-7. 

Pada kode dapat dilihat saya menggunakan variabel `opsi` untuk menampung input. Selain itu saya juga memilih untuk menggunakan `read`, karena menurut saya lebih sesuai dengan output soal yang dimana pemilihan opsi dilakukan disamping text "[1-7] > " dan bukan dibawahnya seperti ini:

```
$ [1-7] > 
▮ < Input dilakukan disini
```
##### Tambah Penghuni Baru

Pada opsi ini program menanyakan beberapa hal agar penghuni tersebut dapat di data
##### Nama Penghuni Baru

```bash
"1")
    echo "==============================================="
    echo "           TAMBAH PENGHUNI BARU               "
    echo "==============================================="
    read -p "> Masukkan Nama: " nama
```

Untuk memilih 6 opsi program ( 7 jika menghitung exit program) saya menggunakan switch case. Selain itu saya menggunakan variabel `nama` untuk menyimpan nama penghuni baru kost.
##### Kamar Penghuni Baru

```bash
while true; do
    read -p "> Masukkan Kamar: " kamar
    if cut -d',' -f2 "$DATA_FILE" | grep -qx "$kamar"; then
        echo " [!] Kamar ${kamar} sudah ditempati. Pilih kamar lain."
    else
        break
    fi
done
```

Setelah itu program akan menanyakan kamar yang akan ditempati. Setelah menyimpan input kedalam variabel `kamar` sesuai dengan instruksi soal, program juga harus memeriksa apakah kamar tersebut sudah ditempati atau belum.

Disini saya memilih untuk menggunakan command `cut` yang berfungsi untuk memotong / mengambil kolom dari suatu data. Dalam bagian ini saya memilih untuk memotong kolom ke-2, yag diindikasikan dengan adanya `-f2` saat menjalankan command.

Selain itu, bisa dilihat bahwa terdapat variabel dengan nama`$DATA_FILE` yang menyimpan lokasi `penghuni.csv`. Lokasi file dapat diketahui dengan kode berikut yang berjalan pertama kali dalam program

```bash
SCRIPT_DIR="$(dirname "$0")"
DATA_FILE="$SCRIPT_DIR/data/penghuni.csv"
```

Cara kerja kode ini adalah pertama dengan mengetahui lokasi file `kost_slebew.sh` dengan menggunakan command `dirname "$0"`. Hasil command tersebut akan disimpan kedalam variabel yang bernama `SCRIPT_DIR.
`
Dari situlah kita bisa mengetahui bahwa lokasi dari `penghuni.csv` adalah gabungan dari `SCRIPT_DIR` dan juga perintah soal yang dimana `penghuni.csv` harus tersimpan dalam folder `data`.

Setalah melaksanakan comman `cut` hasil dari command tersebut akan di pipe kedalam command grep. Command ini berfungsi untuk mencari suatu string didalam sebuah file / data. Bisa dilihat saat menjalankan commad tersebut kita menggunakan fungsi argumen `-qx` (Merupakan gabungan dari fungsi argumen `-q` dan `-x`). Fungsinya adalah untuk tidak menampilkan teks ke terminal, hanya mengembalikan hasil biner 0 atau 1, (Fungsi dari `-q`) dan untuk mecari string yang tersimpan dalam variabel `kamar`.

Jika ditemukan nomer kamar tersebut maka program akan menunjukkan teks "[!] Kamar ${kamar} sudah ditempati. Pilih kamar lain." dan program akan kembali ke atas menanpilkan "read -p "> Masukkan Kamar: " kamar". Jika tidak maka loop tersebut akan berhenti.

###### Harga Sewa Penghuni Baru

```bash
while true; do
    read -p "> Masukkan Harga Sewa: " harga_sewa
    if ! [[  "$harga_sewa" =~ ^[0-9]+$ ]] || [ "$harga_sewa" -le 0 ]; then
        echo " [!] Harga sewa harus berupa angka positif."
    else
        break
    fi
done
```

Untuk bagian ini saya juga memeriksa dua hal dari variabel `harga_sewa`. Pertama saya memeriksa apakah nilai variabel tersebut adalah numerik dengan kode `"$harga_sewa" =~ ^[0-9]+$` dan kedua saya memeriksa apakah nilai dari variabel `harga_sewa` kurang dari atau sama dengan 0.
###### Tanggal Masuk Penghuni Baru

```bash
today=$(date +%Y-%m-%d)
while true; do
    read -p "> Masukkan Tanggal Masuk (YYYY-MM-DD): " tanggal_masuk
	if ! [[  "$tanggal_masuk" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo " [!] Format tanggal salah. Gunakan YYYY-MM-DD."
    elif [[ "$tanggal_masuk" > "$today" ]]; then
        echo " [!] Tanggal tidak boleh melebihi hari ini ($today)."
    else
        break
    fi
done
```

Sesuai dengan instruksi yang diberikan, saya memeriksa apakah nilai dari variabel `$tanggal_masuk` sesuai dengan format penamaan yang telah diberikan yaitu "YYYY-MM-DD". Jika iya program setelah itu akan memeriksa apakah nilai dari variabel tersebut lebih besar dari nilai variabel `today` yang merupakan tanggal saat menjalankan program tersebut. Cara mendapatkan tanggal tersebut adalah dengan code 

```bash
today=$(date +%Y-%m-%d)
```

Yang dilakukan oleh program adalah menjalankan command `date` dengan format tahun, bulan, dan hari.

###### Status Awal Penghuni Baru

``` bash
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
```

Yang terakhir, progra akan menanyakan mengenai stauts awal penghuni baru, dan karena status yang diperbolehkan hanya "Aktif" atua "Menunggak" saya memeriksa nilai variabel `status` dengan kode `"$status" != "Aktif" && "$status" != "Menunggak"`.

Jika semua variabel telah diisi dengan benar, program setelah itu akan menyimpan data tersebut kedalam `penghuni.csv` dengan menambahkan bari baru.

##### Hapus Penghuni

```bash
"2")
    HISTORY_FILE="$SCRIPT_DIR/sampah/history_hapus.csv"
    echo "==============================================="
    echo "              HAPUS PENGHUNI                  "
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
        echo " [v] Data penghuni \"$nama_hapus\" berhasil diarsipkan dan dihapus."
    fi
    echo "==============================================="
    read -p "Tekan ENTER untuk kembali ke menu utama..."
    ;;
```

Sesuai dengan output yang diberikan soal, opsi ke-2 berfungsi untuk menghapus penghuni. Pertama program akan meminta untuk mencari nama penghuni yang akan dihapus, input tersebut kemudian tersimpan kedalam variabel bernama `nama_hapus`.

Setelah itu, yang dilakukan pada cuplikan kode tersebut adalah menjalankan command `grep` secara case sesitive (Fungsi dari flag `-i`) untuk mencari baris yang dimulai dengan nilai variabel `nama_hapus`. File yang akan dianalisis adalah `penghuni.csv`. Bagian `2>/dev/null` berfungsi untuk membuang segala error jika command `grep` gagal untuk menemukan penghuni, dan ` | head -n ` berfungsi untuk mengambil baris pertama dari hasil penjalanan command. Hasil tersebut selanjutnya akan disimpan pada variabel `baris`.

Setelah itu program akan memeriksa variabel `baris`, jika variabel tersebut kosong (Fungsi dari flag -z), program akan menjalankan bagian `echo " [!] Penghuni \"$nama_hapus\" tidak ditemukan di database."`. Jika tidak program akan menjalankan bagian

```bash
tgl_hapus=$(date +%Y-%m-%d)
    echo "${baris},${tgl_hapus}" >> "$HISTORY_FILE"
    grep -iv "^${nama_hapus}," "$DATA_FILE" > /tmp/penghuni_tmp.csv
    mv /tmp/penghuni_tmp.csv "$DATA_FILE"
    echo " [v] Data penghuni \"$nama_hapus\" berhasil diarsipkan dan dihapus."
```

Karena soal menginstruksikan untuk mendata tanggal (Dengan format YYYY-MM-DD) dan data dari penghuni yang akan dihapus, saya membuat variabel baru bernama `tanggal_hapus`. Setelah itu program menjalankan command

```bash
grep -iv "^${nama_hapus}," "$DATA_FILE" > /tmp/penghuni_tmp.csv
```

Command grep ini diikuti dengan dua flag yang merupakan:

- -i
	Berfungsi untuk melakukan pencarian case sensitive.
- -v
	Berfungsi untuk mengeluarkan output tanpa adanya string yang dicarik.

Saya menyimpan tersebut pada folder temp dengan nama `penghuni_tmp.csv`.

##### Tampilkan Daftar Penghuni

```bash
"3")
    echo "==============================================="
    echo "         DAFTAR PENGHUNI KOST SLEBEW          "
    echo "==============================================="
    echo " No | Nama           | Kamar | Harga Sewa     | Status"
    echo "-----------------------------------------------"
    if [ ! -s "$DATA_FILE" ]; then
        echo " (Belum ada penghuni terdaftar)"
    else
        awk -F',' '
        {
            no++
            n = $3 + 0; f = ""
            do {
                r = n % 1000; n = int(n / 1000)
                if (n > 0) f = "." sprintf("%03d", r) f
                else        f = r f
            } while (n > 0)
            printf " %-2d | %-14s | %-5s | %-14s | %s\n", no, $1, $2, "Rp" f, $5
            print "-----------------------------------------------"
            total++
            if ($5 == "Aktif") aktif++
            else if ($5 == "Menunggak") nunggak++
        }
        END {
            printf " Total: %d penghuni | Aktif: %d | Menunggak: %d\n", total, aktif+0, nunggak+0
        }
        ' "$DATA_FILE"
    fi
    echo "==============================================="
    read -p "Tekan [ENTER] untuk kembali ke menu..."
    ;;
```

Setelah menentukan apakah `penghuni.csv` kosong atau tidak. Jika tidak program akan menjalankan 

```bash
awk -F',' '
        {
            no++
            n = $3 + 0; f = ""
            do {
                r = n % 1000; n = int(n / 1000)
                if (n > 0) f = "." sprintf("%03d", r) f
                else        f = r f
            } while (n > 0)
            printf " %-2d | %-14s | %-5s | %-14s | %s\n", no, $1, $2, "Rp" f, $5
            print "-----------------------------------------------"
            total++
            if ($5 == "Aktif") aktif++
            else if ($5 == "Menunggak") nunggak++
        }
        END {
            printf " Total: %d penghuni | Aktif: %d | Menunggak: %d\n", total, aktif+0, nunggak+0
        }
        ' "$DATA_FILE"
```

Setelah menentukan field seperator `penghuni.csv`, program akan menjalankan code yang berfungsi untuk memformat uang menjadi format ribuan

```bash
n = $3 + 0; f = ""
            do {
                r = n % 1000; n = int(n / 1000)
                if (n > 0) f = "." sprintf("%03d", r) f
                else        f = r f
            }
```

Yang terakhir tentunya adalah mencetak nilai variabel tersebut dengan

```bash
printf " %-2d | %-14s | %-5s | %-14s | %s\n", no, $1, $2, "Rp" f, $5
```

##### Update Status Penghuni

```bash
"4")
    echo "==============================================="
    echo "             UPDATE STATUS PENGHUNI           "
    echo "==============================================="
    read -p "Masukkan Nama Penghuni: " nama_update
```

Setelah menyimpan nama penghuni yang akan dihapus pada `nama_update`

```bash
    while true; do
        read -p "Masukkan Status Baru (Aktif/Menunggak): " status_baru
        if [[ "$status_baru" != "Aktif" && "$status_baru" != "Menunggak" ]]; then
            echo " [!] Status harus 'Aktif' atau 'Menunggak'."
        else
            break
        fi
    done
```

Program akan pertama memeriksa apakah input merupakan "Aktif" atau "Menunggak". Jika tidak maka file akan stuck dalam while loop hingga input tersebut benar.

```bash
    if ! grep -qi "^${nama_update}," "$DATA_FILE"; then
        echo " [!] Penghuni \"$nama_update\" tidak ditemukan."
```

Setelah itu program akan memeriksa menggunakan command grep untuk memeriksa apakah nama penghuni terdapat dalam `penghuni.csv`

```bash
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
```

Dan jika semua porses tersebut berjalan lancar, program akhirnya akan mengganti status penghuni dengan menggunakan awk.

##### Cetak Laporan Keuangan

```bash
"5")
    LAPORAN_FILE="$SCRIPT_DIR/rekap/laporan_bulanan.txt"
    echo "==============================================="
    echo "       LAPORAN KEUANGAN KOST SLEBEW           "
    echo "==============================================="
```

Setelah mengoutput header tersebut saya memilih awk untuk mencetak laporan keuangan

```bash
    awk -F',' -v laporan="$LAPORAN_FILE" '
    function rupiah(n,    r, f) {
        f = ""
        do {
            r = n % 1000; n = int(n / 1000)
            if (n > 0) f = "." sprintf("%03d", r) f
            else        f = r f
        } while (n > 0)
        return "Rp" f
    }
```

Sebelum membaca `laporan_bulanan.txt`, saya menentukan bahwa *Field Seperator* adalah koma dan menyimpan `laporan_bulanan.txt`. Saya juga memilih untuk membuat suatu fungsi untuk memformat angka uang menjadi format rupiah

```bash
    {
        total_kamar++
        harga = $3 + 0
        if ($5 == "Aktif") {
            total_masuk += harga
        } else if ($5 == "Menunggak") {
            total_tunggak += harga
            nunggak_list = nunggak_list "   " $1 "\n"
            nunggak++
        }
    }
    END {
        print "==============================================="
        print " Total pemasukan (Aktif)  : " rupiah(total_masuk+0)
        print " Total tunggakan          : " rupiah(total_tunggak+0)
        print " Jumlah kamar terisi      : " total_kamar+0
        print "-----------------------------------------------"
        print " Daftar penghuni menunggak:"
        if (nunggak+0 == 0)
            print "   Tidak ada tunggakan."
        else
            printf "%s", nunggak_list
        print "==============================================="
    }
    ' "$DATA_FILE" | tee "$LAPORAN_FILE"
    echo " [v] Laporan disimpan ke rekap/laporan_bulanan.txt"
    read -p "Tekan [ENTER] untuk kembali ke menu..."
    ;;
```


##### Kelola Cron

```bash
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
                read -p "Tekan [ENTER] untuk kembali..."
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
                menit=$(printf "%02d" "$menit")
                jam=$(printf "%02d" "$jam")
                cron_job="$menit $jam * * * $CRON_MARKER"
                (crontab -l 2>/dev/null | grep -v "$CRON_MARKER"; echo "$cron_job") | crontab -
                echo " [v] Cron job didaftarkan: $cron_job"
                read -p "Tekan [ENTER] untuk kembali..."
                ;;
            "3")
                if crontab -l 2>/dev/null | grep -q "$CRON_MARKER"; then
                    crontab -l 2>/dev/null | grep -v "$CRON_MARKER" | crontab -
                    echo " [v] Cron job pengingat tagihan dihapus."
                else
                    echo " [!] Tidak ada cron job pengingat yang aktif."
                fi
                read -p "Tekan [ENTER] untuk kembali..."
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
```

Cuplikan kode diatas berfungsi untuk mengelola kron, sesuai dengan instruksi terdapat empat opsi yaitu :

1. Lihat Cron Job Aktif"
2. Daftarkan Cron Job Pengingat"
3. Hapus Cron Job Pengingat"
4. Kembali"
##### Exit Program

```bash
"7")
    echo "==============================================="
    echo "      Exiting AMBASTAY management system       "
    echo "==============================================="
    exit 0
    ;;
```

Karena `exit 0` while loop do yang mengekapsulasi program akan menjadi false, menyebabkan program tidak loop.
##### --check-tagihan

```bash
if [[ "$1" == "--check-tagihan" ]]; then
    LOG_FILE="$SCRIPT_DIR/log/tagihan.log"
    tgl=$(date +"%Y-%m-%d %H:%M:%S")
    found=0
    while IFS=',' read -r nama kamar harga tanggal status; do
        if [[ "$status" == "Menunggak" ]]; then
            echo "[$tgl] TAGIHAN: $nama (Kamar $kamar) - Menunggak $(rupiah "$harga")" >> "$LOG_FILE"
            found=1
        fi
    done < "$DATA_FILE"
    if [[ $found -eq 0 ]]; then
        echo "[$tgl] Tidak ada penghuni menunggak." >> "$LOG_FILE"
    fi
    echo "" >> "$LOG_FILE"
    exit 0
fi
```

Sesuai dengan instruksi program juga dapat memiliki flag yaitu `--check-tagihan`
#### Output

1. Main Menu![[Pasted image 20260329235502.png]]
2.  Tambah Penghuni Baru![[Pasted image 20260329235636.png]]
 3. Hapus Penghuni![[Pasted image 20260329235654.png]]
 ![[Pasted image 20260329235725.png]]
 4. Tampilkan Daftar Penghuni ![[Pasted image 20260329235548.png]]
 ![[Pasted image 20260329235807.png]]
 5. Update Status Penghuni![[Pasted image 20260329235847.png]]
 6. Cetak Laporan Keuangan![[Pasted image 20260329235857.png]]
 7. Kelola Cron (Pengingat Tagihan)
 8. Exit Program
#### Kendala

Tidak ada kendala