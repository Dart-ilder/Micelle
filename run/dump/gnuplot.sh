set terminal png
set output "dumb_picture.png"

set style increment user
set style line 1 lc rgb 'blue'
set style line 2 lc rgb 'red'
set style line 3 lc rgb 'magenta'
set style line 4 lc rgb 'yellow'
set style line 5 lc rgb 'yellow'

set style line 6 lc rgb 'yellow'
set style line 7 lc rgb 'yellow'
set style line 8 lc rgb 'yellow'
set style line 9 lc rgb 'yellow'
set style data points
plot '~/final/run/dump.slice' using 3:4:2 linecolor variable pt 5 ps 2 t ''



