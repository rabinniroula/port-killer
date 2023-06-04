#!/bin/bash

list_of_open_ports=$(lsof -i -P -n | grep LISTEN | awk -F ' ' '{printf "%s\t\"%s\t%s\t%s\" ", ++count, $1, $2, $9}');

# Weird hack time! 🥷

cmd=$(printf 'dialog --clear --title "PortKiller 1.0" --menu "Select the port to be killed: " 0 0 0 %s 2>&1 1>&3' "$list_of_open_ports");
exec 3>&1;
result=$(eval "$cmd");
exitcode=$?;
case $exitcode in
    1) echo "Process not killed"; exit;;
    255) echo "ESC key pressed"; exit;;
esac
exec 3>&-;
result=$(($result*4-1));
pid_to_be_killed=$(echo $list_of_open_ports | cut -d' ' -f$result);

cmd=$(printf "dialog --title \"Kill Process?\" --yesno \"Are you sure you want to end the process: PID=%s?\" 0 0" $pid_to_be_killed);
eval "$cmd";
response=$?;
case $response in
    0) kill -9 $pid_to_be_killed; echo "Process Killed Succesfully";;
    1) echo "Process not killed";;
    255) echo "ESC key pressed";;
esac