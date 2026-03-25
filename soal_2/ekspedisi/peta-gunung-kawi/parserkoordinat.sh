#!/bin/bash
awk '
BEGIN {
FS = "[\\":,]"
OFS = ","
}
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
' gsxtrack.json > titik-penting.txt
echo "Parsing i mari cak. tak simpen ndek : titik-penting.txt"
