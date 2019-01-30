#! /bin/sh

reserved=12582912
availableMemory=$((1024 * $( (fgrep MemAvailable /proc/meminfo || fgrep MemTotal /proc/meminfo) | sed 's/[^0-9]//g' ) ))
if [ $availableMemory -le $(($reserved * 2)) ]; then
    echo "Not enough memory" >&2
    exit 1
fi
availableMemory=$(($availableMemory - $reserved))
msg_cache_size=$(($availableMemory / 3))
rr_cache_size=$(($availableMemory / 3))
nproc=$(nproc)
if [ $nproc -gt 1 ]; then
    threads=$(($nproc - 1))
else
    threads=1
fi

sed \
    -e "s/@MSG_CACHE_SIZE@/${msg_cache_size}/" \
    -e "s/@RR_CACHE_SIZE@/${rr_cache_size}/" \
    -e "s/@THREADS@/${threads}/" \
    > /opt/unbound/etc/unbound/unbound.conf << EOT
server:
  verbosity: 1
  num-threads: @THREADS@
  interface: 0.0.0.0@53
  so-reuseport: yes
  edns-buffer-size: 1252
  delay-close: 10000
  cache-min-ttl: 60
  cache-max-ttl: 86400
  do-daemonize: no
  username: "_unbound"
  log-queries: no
  hide-version: yes
  identity: "MyUnbound"
  harden-short-bufsize: yes
  harden-large-queries: yes
  harden-glue: yes
  harden-dnssec-stripped: yes
  harden-below-nxdomain: yes
  harden-referral-path: no
  do-not-query-localhost: no
  prefetch: yes
  prefetch-key: yes
  qname-minimisation: yes
  ratelimit: 1000
  rrset-roundrobin: yes
  minimal-responses: yes
  chroot: "/opt/unbound/etc/unbound"
  directory: "/opt/unbound/etc/unbound"
  auto-trust-anchor-file: "var/root.key"
  num-queries-per-thread: 4096
  outgoing-range: 8192
  msg-cache-size: @MSG_CACHE_SIZE@
  rrset-cache-size: @RR_CACHE_SIZE@
  neg-cache-size: 4M
  serve-expired: yes
  access-control: 127.0.0.1/32 allow
  access-control: 192.168.0.0/16 allow
  access-control: 172.16.0.0/12 allow
  access-control: 10.0.0.0/8 allow
  include: /opt/unbound/etc/unbound/a-records.conf
  forward-zone:
    name: "."
    forward-addr: 8.8.8.8
    forward-addr: 8.8.4.4
EOT

mkdir -p /opt/unbound/etc/unbound/dev && \
cp -a /dev/random /dev/urandom /opt/unbound/etc/unbound/dev/

mkdir -p -m 700 /opt/unbound/etc/unbound/var && \
chown _unbound:_unbound /opt/unbound/etc/unbound/var && \
/opt/unbound/sbin/unbound-anchor -a /opt/unbound/etc/unbound/var/root.key

exec /opt/unbound/sbin/unbound -d -c /opt/unbound/etc/unbound/unbound.conf
