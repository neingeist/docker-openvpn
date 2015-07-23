#!/bin/sh
# vim:tw=120:


# configuration
. `dirname $0`/enable-docker-openvpn-v6-routing.conf


# fix up missing fe80::1 address on docker bridge
# (this bug might be fixed in fedoras docker)
dev=docker0
if ! ip addr show dev $DEV | grep -q 'inet6 fe80::1/64'; then
    ip addr add fe80::1/64 dev $DEV
fi


# route the network to the container
container_ip=`docker inspect -f '{{.NetworkSettings.GlobalIPv6Address}}' $CONTAINER_NAME`
ip -6 route flush $NETV6
ip -6 route add $NETV6 via $container_ip dev $DEV
ip6tables -I FORWARD -s $NETV6 -j ACCEPT


# enable ipv6 forwarding via nsenter
container_pid=`docker inspect -f '{{.State.Pid}}' $CONTAINER_NAME`
nsenter --target $container_pid --mount --uts --ipc --net --pid \
    /bin/sh -c '/usr/bin/mount /proc/sys -o remount,rw;
                /usr/sbin/sysctl -q net.ipv6.conf.all.forwarding=1;
                /usr/bin/mount /proc/sys -o remount,ro;
                /usr/bin/mount /proc -o remount,rw # restore rw on /proc'
