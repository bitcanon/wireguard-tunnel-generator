# 🖧 WireGuard Tunnel Generator
Hi and welcome! Click the button below if you enjoy the software and want to support my work. A lot of coffee is consumed as a software developer you know 😁

<a href="https://www.buymeacoffee.com/bitcanon" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

>Needless to say, this is completely voluntary.

## 🤓 Introduction
A simple bash script to speed up and simplify the deployment of WireGuard Road Warriors (mobile VPN clients) connecting to a MikroTik firewall running RouterOS.

The script will produce the RouterOS configuration required as well as a QR code to scan with the WireGuard mobile app. This will enable you to deploy a new mobile VPN client within a minute or two, and you don't have to send public keys back and forth between the mobile device and the router.

## 🕹 Demo
Here is a small command-line demo showing the WireGuard Tunnel Generator script in action.

![CLI Demo](docs/img/wireguard-tunnel-generator-demo.gif)

## 💻 Installation
Download the script from GitHub and place it inside your home directory.

The script needs three packages in order to operate correctly:
```
sudo apt install ipcalc-ng wireguard-tools qrencode
```

1. `ipcalc-ng` is used to validate IP adress input.
2. `wireguard-tools` is used to generate private/public key pair.
3. `qrencode` is used to encode the WireGuard configuration into a QR code.

>The script has only been tested on Debian but might also work on other operating systems.

## 📚 Basics
### Parameters
The script accepts parameters you use to define the WireGuard configuration for each client deployed:
```bash
Usage:
  ./wg-tunnel-generator.sh [options] <mobile_peer_ip>

Options:
  <mobile_peer_ip>    Mobile peer IP address in CIDR notation, ie. 10.0.0.2/32
  -a <subnet,...>     One or more IP subnet(s) to be routed through the tunnel
  -d <dns,...>        One or more DNS server(s) to be used by the mobile client
  -e <host[:port]>    WireGuard endpoint on the firewall, ie. fw.example.com:13231
  -h                  Print this help and exit
  -n <name>           Descriptive name for the mobile client
  -p <public_key>     Public key of the WireGuard interface on the firewall
  -v                  Print verbose debugging information
```
The only parameter required is `<mobile_peer_ip>`, which is the IP address to be assigned to the client; all other parameters (options) have default values that will be used if not provided when running the script. *But, these are simply testing values that you will want to override.*

Example:
```bash
./wg-tunnel-generator.sh -n my-phone -a 10.50.0.0/16 -d 1.1.1.1,8.8.8.8 -e vpn.example.com:13231 -p "fb4r8zxzstQ+/GxULwnqW9mqDF3YrBT2SvcEHyXqoWM=" 10.50.50.2/32
```

### Change the Defaults
The default options above can be modified simply by editing `wg-tunnel-generator.sh`. This can be handy if you don't want to pass parameters every time you need to deploy a new road warrior.

```bash
# Pre-defined parameter values
ALLOWED_IPS="0.0.0.0/0"
DNS="1.0.0.1,1.1.1.1"
ENDPOINT="fw.example.com:13231"
FW_PUBLIC_KEY="0"
NAME="mobile-phone"
```

To simplify the example in the last section we can change the variables to:
```bash
# Pre-defined parameter values
ALLOWED_IPS="10.50.0.0/16"
DNS="1.1.1.1,8.8.8.8"
ENDPOINT="vpn.example.com:13231"
FW_PUBLIC_KEY="fb4r8zxzstQ+/GxULwnqW9mqDF3YrBT2SvcEHyXqoWM"
NAME="mobile-phone"
```
No we can run the following command and still get the same result:
```bash
./wg-tunnel-generator.sh -n my-phone 10.50.50.2/32
```

## 💾 Running the Script
One thing to keep in mind when running the script is whether a **WireGuard Interface** has been configured on the router or not.

This is important because the interface only need to be created once. It's during the interface creation that a private/public key pair is generated.
 
### WireGuard Interface is configured

When the interface is already configured you need to get the public key from the configuration in RouterOS.

**WinBox**:
- Go to WireGuard and open the `wg_mobile` interface in the WireGuard tab.

**Terminal**:
- Run the command `:put ([/interface/wireguard/get wg_mobile ]->"public-key")`.

>Assuming the name of the WireGuard interface is `wg_mobile`.

### WireGuard Interface need to be configured

When the interface doesn't exists you can let the script generate the configuration for you. This is the default behavior when running the script and is shown in the demo above.

There are two ways to change this behavior:
1. Pass the **public key** as an argument to the script: `-p "fb4r8zxzstQ+/GxULwnqW9mqDF3YrBT2SvcEHyXqoWM="`
2. Set the variable `FW_PUBLIC_KEY` to the public key you got from the WireGuard interface in RouterOS, for instance `FW_PUBLIC_KEY=fb4r8zxzstQ+/GxULwnqW9mqDF3YrBT2SvcEHyXqoWM=`.
