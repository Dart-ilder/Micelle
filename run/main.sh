#!bin/bash

cd ~/final/run



max_length=30
cage_size=70
rho=0.55
peptide_percentage=0.2
number_of_peptides=$(bc<<<"scale=1;$peptide_percentage * $cage_size * $cage_size * $rho")
pept=${number_of_peptides%.*}

echo "000000000000000000000000000000 Program start"
#for (( i=3; i<=max_length; i=i+2 ))
for i in 6;
do

relax_length=$(($i * 4000))
echo "000000000000000000000000000000 Generating data for length of $i"
sed "s/PEPTIDE_LENGTH/$i/g" ~/final/micelle/def.micelle_mod > def.micelle1
sed "s/CAGE_SIZE/$cage_size $cage_size/g" def.micelle1 > def.micelle2
sed "s/RHO/$rho/g" def.micelle2 > def.micelle1
sed "s/NUMBER_OF_PEPTIDES/$pept/g" def.micelle1 > def.micelle
sed "s/RELAX_LENGTH/$relax_length/g" ~/final/micelle/in.micelle > ./in.micelle
~/final/micelle/micelle2d.out < def.micelle > data.micelle
rm def.micelle1
rm def.micelle2
echo "000000000000000000000000000000 Running simulation for length of $i"
srun -N 1 --ntasks-per-node=8 -J sharov_micelle_${i} --comment="Lammps micelle run for length of $i" -p RT ~/bin/lmp_mpi -in in.micelle 

echo "000000000000000000000000000000 Simulation for length of $i complited"
N=$(grep -A1 -m1 "ITEM: NUMBER OF ATOMS" ./dump.micelle | tail -1) 
tail -n ${N} dump.micelle >> dump.slice

#gnuplot ./dump/gnuplot.sh


    gnuplot -persist <<-EOFMarker
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
plot '~/final/run/dump.slice' using 3:4:2 linecolor variable pt 7 ps 1 t ''
EOFMarker

curl -s -X POST \                                                                    https://api.telegram.org/bot1841147141:AAEwfEktpavHlCA8PUpzUsvKkdsK_VlL9DM/sendPhoto -F chat_id=429839982 -F photo="@dumb_picture.png" -F caption="Oversimplistic picture. Simulation for peptides with length of ${i} ended"
cd ~/final/run
mv dump.micelle ./dump/dump.micelle_$i
cat ./bond.micelle >> ./dump/dump.micelle_$i

done


rm bond.micelle
rm log.lammps
rm in.micelle
rm list_slurm.txt
rm dumb_picture.png
rm dump.slice
