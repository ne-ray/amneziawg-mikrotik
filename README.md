### https://hub.docker.com/r/wiktorbgu/amneziawg-mikrotik

> ## AmneziaWG protocol configuration
> ### It is important to remember that the parameters S1, S2 and H1, H2, H3, H4 must remain equal to the specified values ​​on the client and on the server (otherwise nothing will work), and you can change the parameters J as you like, but Jc must be from 1 to 128, the value of Jmin must not exceed Jmax, and Jmax must not be more than 1280.

## Mikrotik settings

```/interface/bridge add name=Bridge-Docker port-cost-mode=short
/ip/address add address=192.168.254.1/24 interface=Bridge-Docker network=192.168.254.0
/interface/veth add address=192.168.254.4/24 gateway=192.168.254.1 name=AMNEZIAWG
/interface/bridge/port add bridge=Bridge-Docker interface=AMNEZIAWG
```

### change path /usb1 to your actual path
```
/container/config set registry-url=https://registry-1.docker.io tmpdir=/usb1/docker/pull

/container/mounts add dst=/etc/amnezia/amneziawg name=amnezia_wg_conf src=/usb1/docker_configs/amnezia_wg_conf

/container/add remote-image=wiktorbgu/amneziawg-mikrotik interface=AMNEZIAWG root-dir=/usb1/docker/amneziawg start-on-boot=yes logging=yes mounts=amnezia_wg_conf
```
# CLIENT MODE
### awg.conf EXAMPLE - any file name is used automatically (not very long)
> ### Attention!
> In this configuration the parameters S1 S2 H1 H2 H3 H4 are specified for connecting to a standard WG server with the addition of garbage packets Jc Jmin Jmax to try to bypass DPI!
If you are using an AWG server, read the message above `AmneziaWG protocol configuration`
```
[Interface]
PrivateKey = ====================KEY=====================
Address = 10.10.10.2/24
DNS = 8.8.8.8, 1.1.1.1
MTU = 1440
Jc = 6
Jmin = 50
Jmax = 1000
S1 = 0
S2 = 0
H1 = 1
H2 = 2
H3 = 3
H4 = 4

# Add IP masquerading
PostUp = iptables -t nat -A POSTROUTING -o %i -j MASQUERADE
# Del IP masquerading
PostDown = iptables -t nat -D POSTROUTING -o %i -j MASQUERADE

# Add clamp mss to pmtu
PostUp = iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
# Del clamp mss to pmtu
PostDown = iptables -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

# route over other table
Table = awg
PostUp = ip rule add priority 300 from all iif eth0 lookup awg || true
PostDown = ip rule del from all iif eth0 lookup awg || true

[Peer]
PublicKey = ====================KEY=====================
PresharedKey = ====================KEY=====================
AllowedIPs =  0.0.0.0/0
PersistentKeepalive = 25
Endpoint = IP_OR_DNS_SERVER_WG:PORT
```

### Save EXAMPLE to file awg.conf to path /usb1/docker_configs/amnezia_wg_conf
### And RUN container
```
/container start [find interface=AMNEZIAWG]
```
## For check client status
### Open console container and use command `awg`
```
/container shell [find interface=AMNEZIAWG status=running]

MikroTik:/# awg
interface: warp
  public key: xxxxxxxxxxxxxxxxxxxxxxxxxxxOzOZZiqt6s/s0H1wpQZXA=
  private key: (hidden)
  listening port: 45706
  jc: 6
  jmin: 50
  jmax: 1000

peer: xxxxxxxxxxxxxxxxxxxxxxxxxxxtzH0JuVo51h2wPfgyo=
  endpoint: 162.159.192.1:2408
  allowed ips: 0.0.0.0/1, 128.0.0.0/1
  latest handshake: 3 seconds ago
  transfer: 92 B received, 5.72 KiB sent
  persistent keepalive: every 25 seconds

# or info for real awg server

MikroTik:/# awg
interface: warp
  public key: xxxxxxxxxxxxxxxxxxxxxxxxxxxDOTg1URsTQDtJ0nc=
  private key: (hidden)
  listening port: 44730
  jc: 6
  jmin: 50
  jmax: 1000
  s1: 30
  s2: 71
  h1: 1787607718
  h2: 2134371398
  h3: 207168052
  h4: 2022740759

peer: xxxxxxxxxxxxxxxxxxxxxxxxxxx9vDcaOOqSsRCk=
  preshared key: (hidden)
  endpoint: xx.xx.66.55:54937
  allowed ips: 0.0.0.0/1, 128.0.0.0/1
  latest handshake: 6 seconds ago
  transfer: 92 B received, 4.21 KiB sent
  persistent keepalive: every 16 seconds

```
# SERVER MODE

### Genetate config on site https://www.wireguardconfig.com/
### awg0.conf EXAMPLE - any file name is used automatically (not very long)
```
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = 6JFnjl93rF1vDr2TxzwWRumHmck5bOGr4NOOn+PsHXU=
Jc = 4
Jmin = 50
Jmax = 1000
S1 = 146
S2 = 42
H1 = 532916466
H2 = 2096090865
H3 = 406337014
H4 = 57583056

# Add IP masquerading
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# Del IP masquerading
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# Add clamp mss to pmtu
PostUp = iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
# Del clamp mss to pmtu
PostDown = iptables -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu


Table = awg
PostUp = ip rule add priority 300 from all iif eth0 lookup awg || true
PostDown = ip rule del from all iif eth0 lookup awg || true

[Peer]
PublicKey = hVneLKyyM/v3ZJf4j5CA1C5J4y+cHt0b92BlaH24wyw=
AllowedIPs = 10.0.0.2/32

[Peer]
PublicKey = LZxKz1UWe70dKAIzJPBDIKA7Opk8nuolLxq80WDcbnA=
AllowedIPs = 10.0.0.3/32

[Peer]
PublicKey = SBx4YTAAsHoxtHIXMxT0Xd/tAKxO24fDP5pVWCKvS3M=
AllowedIPs = 10.0.0.4/32
```

### Save EXAMPLE to file awg0.conf to path /usb1/docker_configs/amnezia_wg_conf
### For connect to the server AWG from internet
Dst-nat with simple change external port for connections `It is better to use a non-standard port`
```
/ip firewall nat add action=dst-nat chain=dstnat comment="DST-NAT to AmneziaWG container" dst-port=14243 in-interface=ether1-wan protocol=udp to-addresses=192.168.254.4 to-ports=51820
```

### And RUN container
```
/container start [find interface=AMNEZIAWG]
```
## On client side config:
Example for Windows client https://github.com/amnezia-vpn/amneziawg-windows-client/releases
```
[Interface]
PrivateKey = WJCJ5FX3Wsu+yjrwPdaC6PAt5bHiAQ+j7KAwld/C1l8=
Jc = 4
Jmin = 50
Jmax = 1000
S1 = 146
S2 = 42
H1 = 532916466
H2 = 2096090865
H3 = 406337014
H4 = 57583056
Address = 10.0.0.2/24
MTU = 1420

[Peer]
PublicKey = KB3AhYqcsckbvXSX5gvUqsk8gQyPIf409pc4KdaLqhc=
AllowedIPs = 0.0.0.0/1, 128.0.0.0/1
Endpoint = EXTERNAL_INTERNET_IP:DST_NAT_PORT # or container ip and port for testing connect in local network mikrotik
PersistentKeepalive = 16
```
## For check server status
### Open console container and use command `awg`
```
/container shell [find interface=AMNEZIAWG status=running]

MikroTik:/# awg
interface: wg0
  public key: KB3AhYqcsckbvXSX5gvUqsk8gQyPIf409pc4KdaLqhc=
  private key: (hidden)
  listening port: 51820
  jc: 4
  jmin: 50
  jmax: 1000
  s1: 146
  s2: 42
  h1: 532916466
  h2: 2096090865
  h3: 406337014
  h4: 57583056

peer: hVneLKyyM/v3ZJf4j5CA1C5J4y+cHt0b92BlaH24wyw=
  endpoint: xx.xxx.44.106:30544
  allowed ips: 10.0.0.2/32
  latest handshake: 3 seconds ago
  transfer: 626.09 KiB received, 5.33 MiB sent

peer: SBx4YTAAsHoxtHIXMxT0Xd/tAKxO24fDP5pVWCKvS3M=
  allowed ips: 10.0.0.4/32

peer: LZxKz1UWe70dKAIzJPBDIKA7Opk8nuolLxq80WDcbnA=
  allowed ips: 10.0.0.3/32

```

# Speed test on server mode
![Speed test on server mode](https://i.ibb.co/hBqcNYd/amnezia-server-mikrotik-speedtest.jpg)
