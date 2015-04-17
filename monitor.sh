#########################################################################
# File Name: memory_monitor.sh
# Author: wangrun04
# mail: wangrun20088002@126.com
# Created Time: Thu 16 Apr 2015 06:58:02 PM PDT
#########################################################################
#!/bin/bash

#maximun ratio of memory usage
mem_quota=80
hd_quota=80

watch_memory()
{
    mem_total=`cat /proc/meminfo |grep MemTotal | awk '{print $2}'`
    mem_free=`cat /proc/meminfo |grep MemFree |awk '{print $2}'`
    mem_usage=$((100-mem_free*100/mem_total))
    if [ $mem_usage -gt $mem_quota ];then 
        mem_message="ALARM!!!The memory usage is $mem_usage!!!"
        echo $mem_message
        return 1
    else 
        echo 'ok'
        return 0
    fi
}

watch_hd()
{
    hd_usage=`df |grep /dev/sda1 | awk '{print $5}' |sed 's/%//g'`
    if [ $hd_usage -gt $hd_quota ];then
        hd_message="ALARM!!!The hard disk usage is $hd_usage%!!!"
        echo $hd_message 
        return 1 
    else
        echo 'ok'
        return 0
    fi 
}

cpu_quota=80
time_gap=60
runtime_gap=600

get_cpu_info()
{
    cat /proc/sta |grep -i "^cpu[0-9]\+" |\
        awk '{used+=$2+$3+$3; unused+=$5+$6+$7+$8} END{print used,unused}'
}

watch_cpu()
{
    time_point_1=`get_cpu_info`
    sleep $time_gap
    time_point_2=`get_cpu_info`
    cpu_usage=`echo $time_point_1 $time_point_2|\
        awk '{used=$3-$1;total=$3+$4-$1-$2;print used*100/total}'`
    if [ $cpu_usage > $cpu_quota ];then
        cpu_message="ALARM!!!The cpu usage id over $cpu_usage"
        echo $cpu_usagee
        return 1
    else
        echo $cpu_usage
        return 0
    fi
}

proc_cpu_top_10()
{
    proc_busiest=`ps -aux| sort -nk 3r | head -11`
}

while true;do
    report=""
if [ `watch_memory` -eq 1 ];then
    report=$report'\n'$mem_message

fi
if [ `watch_hd` -eq 1 ];then
    report=$report'\n'$hd_message
fi
if [ `watch_cpu` -eq 1 ];then
    report=$report'\n'$cpu_message
    proc_cpu_top_10
    report=$report'\n'$proc_busiest
fi
if [ -n $report ];then
    sendmessage phonenumber report 
fi
sleep $((runtime-gap_time_gap))
done
