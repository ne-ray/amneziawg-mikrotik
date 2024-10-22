### https://hub.docker.com/r/wiktorbgu/amneziawg-mikrotik

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
### To save disk space on the ARM64 platform (35Mb), you can use an ARM image (17Mb)!
```
/container/add remote-image=wiktorbgu/amneziawg-mikrotik:arm interface=AMNEZIAWG root-dir=/usb1/docker/amneziawg start-on-boot=yes logging=yes mounts=amnezia_wg_conf
```
# CLIENT MODE
### awg.conf EXAMPLE 
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

# Replace 192.168.254.1 with your router IP address in the bridge where the container is located
# exclude local networks
PreUp = ip route add 10.0.0.0/8 via 192.168.254.1 dev eth0
PreUp = ip route add 172.16.0.0/12 via 192.168.254.1 dev eth0
PreUp = ip route add 192.168.0.0/16 via 192.168.254.1 dev eth0

# Here is the IP of the Endpoint
PreUp = ip route add IP_SERVER_WG via 192.168.254.1 dev eth0

[Peer]
PublicKey = ====================KEY=====================
PresharedKey = ====================KEY=====================
AllowedIPs =  0.0.0.0/1, 128.0.0.0/1 # don't use 0.0.0.0/0
PersistentKeepalive = 25
Endpoint = IP_SERVER_WG:PORT
```

### Save EXAMPLE to file awg.conf to path /usb1/docker_configs/amnezia_wg_conf
### And RUN container
```
/container start [find interface=AMNEZIAWG]
```

# SERVER MODE

### Genetate config on site https://www.wireguardconfig.com/
### awg0.conf EXAMPLE 
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
Endpoint = 192.168.254.4:51820
PersistentKeepalive = 16
```
# Speed test on server mode
![Speed test on server mode](https://i.ibb.co/hBqcNYd/amnezia-server-mikrotik-speedtest.jpg)
