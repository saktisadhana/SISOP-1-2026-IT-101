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
