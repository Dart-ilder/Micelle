#!/bin/sh

telegram_chat_id=429839982
telegram_bot_token=1841147141:AAEwfEktpavHlCA8PUpzUsvKkdsK_VlL9DM
touch list_slurm.txt
id_list_old=$(awk '{print $1}' list_slurm.txt)
id_list_new=$(squeue -o "%.18i %.9P %j %u %.2t %.10M %.6D %R" |
grep studtscm04 | awk '{print $1}')
# Finished
for ids in ${id_list_old}
do
if [ $( echo ${id_list_new} | grep -c $ids) = 0 ]; then
echo "Finished: $ids"
task_info=$(awk -v id=$ids '{if ($1==id){print}}' list_slurm.txt)
partion=$(echo $task_info | awk '{print $2}')
name=$(echo $task_info | awk '{print $3}')
node=$(echo $task_info | awk '{print $8}')
curl \
-d parse_mode=HTML \
-d chat_id=${telegram_chat_id} \
-d disable_notification=True \
-d text="<b> FINISHED </b>: %0A \
<b><i>Name:</i> $name </b> %0A \
<b><i>Partion:</i></b> $partion %0A \
<b><i>Node:</i></b> $node %0A" \
-s -X POST \
https://api.telegram.org/bot${telegram_bot_token}/sendMessage
fi
done
# Started
for ids in ${id_list_new}
do
if [ $( echo ${id_list_old} | grep -c $ids) = 0 ]; then
echo "Started: $ids"
task_info=$(squeue -o "%.18i %.9P %j %u %.2t %.10M %.6D %R" |
grep studtscm04 | awk -v id=$ids '{if ($1==id){print}}')
partion=$(echo $task_info | awk '{print $2}')
name=$(echo $task_info | awk '{print $3}')
node=$(echo $task_info | awk '{print $8}')
curl \
-d parse_mode=HTML \
-d chat_id=${telegram_chat_id} \
-d disable_notification=True \
-d text="<b> STARTED </b>: %0A \
<b><i>Name:</i> $name </b> %0A \
<b><i>Partion:</i></b> $partion %0A \
<b><i>Node:</i></b> $node %0A" \
-s -X POST \
https://api.telegram.org/bot${telegram_bot_token}/sendMessage
fi
done
squeue -o "%.18i %.9P %j %u %.2t %.10M %.6D %R" |
grep studtscm04 > list_slurm.txt
