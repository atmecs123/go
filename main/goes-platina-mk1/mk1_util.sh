#!/bin/bash

xeth_all()
{
    for i in $(ls -1 /sys/class/net); do
	if [ $i == "lo" ]; then
	    continue
	fi
	if $(ethtool -i $i | grep -q mk1); then
	    echo $i
	fi
    done
}

xeth_range()
{
    start=$1
    shift
    stop=$1
    shift

    for i in $(seq $start $stop); do
	echo -n xeth$i" "
    done
}

eth_range()
{
    start=$1
    shift
    stop=$1
    shift

    for i in $(seq $start $stop); do
	echo -n eth-$i-0" "
    done
}

xeth_up()
{
    for i in $xeth_list; do
	ip link set $i up
    done
}

xeth_down()
{
    for i in $xeth_list; do
	ip link set $i down
    done
}

xeth_flap()
{
    xeth_down $xeth_list
    xeth_up $xeth_list
}

xeth_add()
{
    for i in $xeth_list; do
	ip link add $i type platina-mk1
	ip link set $i up
	ethtool -s $i speed 100000 autoneg off
    done
}

xeth_del()
{
    for i in $xeth_list; do
	ip link del $i
    done
}

xeth_show()
{
    for i in $xeth_list; do
	ip link show $i
    done
}

xeth_stat()
{
    for i in $xeth_list; do
	echo $i
	ethtool -S $i
    done
}

range="all"
if [ $# -gt 0 ]; then
    range=$1
fi

if [ $range == "xeth_range" ]; then
    shift
    start=$1
    shift
    stop=$1
    shift
    xeth_list=$(xeth_range $start $stop)

elif [ $range == "eth_range" ]; then
    shift
    start=$1
    shift
    stop=$1
    shift
    xeth_list=$(eth_range $start $stop)

else
    xeth_list="$(xeth_all)"
fi

cmd="help"
if [ $# -gt 0 ]; then
    cmd=$1
    shift
fi

echo range = $xeth_list
echo command = $cmd


if [ $cmd == "help" ]; then
    grep range.*[t]hen $0 | grep -o \".*\"
    grep cmd.*[t]hen $0 | grep -o \".*\"
    exit 0
elif [ $cmd == "show" ]; then
    xeth_show $xeth_list
elif [ $cmd == "add" ]; then
    xeth_add $xeth_list
elif [ $cmd == "del" ]; then
    xeth_del $xeth_list
elif [ $cmd == "up" ]; then
    xeth_up $xeth_list
elif [ $cmd == "down" ]; then
    xeth_down $xeth_list
elif [ $cmd == "flap" ]; then
    xeth_flap $xeth_list
elif [ $cmd == "isup" ]; then
    xeth_show $xeth_list | grep -i state.up
    xeth_show $xeth_list | grep -i state.up | wc -l
elif [ $cmd == "stat" ]; then
    xeth_stat $xeth_list | grep -v " 0$"
fi
