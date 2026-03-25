#!/bin/bash
awk '
BEGIN{
FS = ","
OFS = ","
}
NR > 2{
total_ya += $3; total_xa += $4; total_ya = total_ya / 2; total_xa = total_xa /2
}
NR <= 2{
total_yb += $3; total_xb += $4; total_yb = total_yb / 2; total_xb = total_xb / 2
}
END {
total_y = (total_ya+total_yb)/2; total_x = (total_xa+total_xb)/2
print total_y,total_x
}
' titik-penting.txt > posisipusaka.txt
hasil=$(cat posisipusaka.txt)
echo "Koordinat pusat:"
echo "$hasil"
