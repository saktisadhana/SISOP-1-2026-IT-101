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

Tidak ada kendala.

### Soal 3

#### Brief Overview

#### Penjelasan

#### Output

#### Kendala

