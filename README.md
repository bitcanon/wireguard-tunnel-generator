# 🖧 WireGuard Tunnel Generator
Hi and welcome! Click the button below if you enjoy this library and want to support my work. A lot of coffee is consumed as a software developer you know 😁

<a href="https://www.buymeacoffee.com/bitcanon" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

>Needless to say, this is completely voluntary.

## 🤓 Introduction
A simple bash script to speed up and simplify the deployment of WireGuard Road Warriors (mobile VPN clients) against a MikroTik firewall running RouterOS.

The script will produce both the RouterOS configuration required as well as a QR code to scan with the WireGuard mobile app. This will enable you to deploy a new mobile VPN client within a minute or two, and you don't have to send public keys back and forth between the mobile device and the router.

## 🕹 Demo Applications
### Demo 1: Example Output
Here is a small command-line demo showing the WireGuard Tunnel Generator script in action.

![CLI Demo](docs/img/wireguard-tunnel-generator-demo.gif)

## 💻 Installation
Download the script from GitHub and place in inside your home directory.

The script needs three packages in order to operate smoothly:
```
sudo apt install ipcalc-ng wireguard-tools qrencode
```

1. `ipcalc-ng` is used to validate IP adress input.
2. `wireguard-tools` is used to generate private/public key pair.
3. `qrencode` is used to encode the WireGuard configuration into a QR code.

>The script has only been tested on Debian but might work on other operating systems as well.

## 📚 Basics
### Parameters
The script accepts parameters which you use to define the WireGuard configuration for each client deployed:
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
The only parameter required is `<mobile_peer_ip>`, which is the IP address to be assigned to the client; all other parameters (options) have default values that will be used if not provided by your when running the script. *But, these are simply testing values that you will want to override.*

Example:
```bash
./wg-tunnel-generator.sh -n my-phone -a 10.50.0.0/16 -d 1.1.1.1,8.8.8.8 -e vpn.example.com:13231 -p "fb4r8zxzstQ+/GxULwnqW9mqDF3YrBT2SvcEHyXqoWM=" 10.50.50.2/32
```

### Change the Defaults
The default option values above can be modified simply by editing `wg-tunnel-generator.sh`. This can be handy if you don't want to pass parameters every time you need to deploy a new road warrior.

```bash
# Pre-defined parameter values
ALLOWED_IPS="0.0.0.0/0"
DNS="1.0.0.1,1.1.1.1"
ENDPOINT="fw.example.com:13231"
FW_PRIVATE_KEY="0"
FW_PUBLIC_KEY="0"
IP_ADDR=""
NAME="mobile-phone"
VERBOSE=false
```

### Some more stuff
The...

## 💾 Running the Script
One thing to keep in mind when running the script is whether a **WireGuard Interface** has been configured on the router. This is important because the interface only need to be created once. It's during the interface creation that a private/public key pair is generated.

When the interface is already configured you need to get the public key from the configuration in RouterOS.

WinBox:
- Go to WireGuard and open `wg_mobile` in the WireGuard tab.

Terminal:
- Run `:put ([/interface/wireguard/get wg_mobile ]->"public-key")`.

>Assuming the name of the WireGuard interface is `wg_mobile`.

### Device Information
To get the general device information we just call the `get_info()` method.

```python
info = meter.get_info()
```
Access the values via the class properties:
```python
info.id                         # Returns the device ID        : '01ab:0200:00cd:03ef'  (for example).
info.manufacturer               # Returns the manufacturer     : 'NET2GRID'
info.model                      # Returns the model            : 'SBWF4602'
info.firmware                   # Returns the firmware version : '1.7.14'
info.hardware                   # Returns the hardware version : 1
info.batch                      # Returns the batch number     : 'HMX-P0D-123456'
```
### Power Readings
To get the power readings we call the `get_electricity()` method. These readings are a bit more complex since the information gathered from the Elna device is divided in to sub-classes, but it's not that complicated:

```python
electricity = meter.get_electricity()
```

#### Now
Get the **current** power consumption:
```python
electricity.now.key             # Returns the string  : 'now'
electricity.now.value           # Returns the power   : 453  (for example).
electricity.now.unit            # Returns the unit    : 'W'  (as in Watt)
electricity.now.timestamp       # Returns a timestamp : '2022-12-24 13:37:00'
```

#### Minimum
Get the **minimum** power consumption in the period:
```python
electricity.minimum.key         # Returns the string  : 'minimum'
electricity.minimum.value       # Returns the power   : 202  (for example).
electricity.minimum.unit        # Returns the unit    : 'W'  (as in Watt)
electricity.minimum.timestamp   # Returns a timestamp : '2022-12-13 13:37:00'
```

#### Maximum
Get the **maximum** power consumption in the period:
```python
electricity.maximum.key         # Returns the string  : 'maximum'
electricity.maximum.value       # Returns the power   : 14320  (for example).
electricity.maximum.unit        # Returns the unit    : 'W'  (as in Watt)
electricity.maximum.timestamp   # Returns a timestamp : '2022-12-31 13:37:00'
```
> The time frame (period) of which the **minimum** and **maximum** values has been recorded is unknown (to me).

#### Imported
Get the **imported** power. This would be total power coming **into** the household:
```python
electricity.imported.key         # Returns the string  : 'imported'
electricity.imported.value       # Returns the power   : 12345678  (for example).
electricity.imported.unit        # Returns the unit    : 'Wh'  (as in Watt hours)
electricity.imported.timestamp   # Returns a timestamp : '2022-12-31 13:37:00'
```

#### Exported
Get the **exported** power. This would be total power coming **out of** the household:
```python
electricity.exported.key         # Returns the string  : 'exported'
electricity.exported.value       # Returns the power   : 87654321  (for example).
electricity.exported.unit        # Returns the unit    : 'Wh'  (as in Watt hours)
electricity.exported.timestamp   # Returns a timestamp : '2022-12-31 13:37:00'
```
> Check out the smartmeter demo at the top to try it out.

### WLAN Information
We can also get the WLAN information of the device by calling the `get_wlan_info()` method. The device can act as both a Wireless Client (Station) and an Access Point (AP) depending on if it has been connected to you WiFi network or not.

```python
wlan = meter.get_wlan_info()
```

Access the WLAN information via the class properties of the object:
```python
wlan.mode           # Returns the current WLAN mode
wlan.ap_ssid        # Returns the Access Point SSID
wlan.ap_key         # Returns the Access Point Password
wlan.client_ssid    # Returns the SSID of the AP Elna is connected to
wlan.join_status    # Returns the number of clients joined to the Elna AP
wlan.mac            # Returns the MAC address currently in use
wlan.ip             # Returns the IP address
wlan.subnet         # Returns the Subnet mask
wlan.gateway        # Returns the Default gateway
wlan.dns            # Returns the Primary DNS server
wlan.dnsalt         # Returns the Secondary DNS server
wlan.n2g_id         # Returns the Net2Grid ID number
wlan.sta_mac        # Returns the MAC address of the WLAN Station
wlan.ap_mac         # Returns the MAC address of the Access Point
wlan.eth_mac        # Returns the Ethernet MAC address (?)
```
> Note: The descriptions following the WLAN properties above are estimated guesses.

## ⚠ Legal Disclaimer

The product names, trademarks and registered trademarks in this repository, are property of their respective owners, and are used by the author for identification purposes only. The use of these names, trademarks and brands, do not imply endorsement or affiliation.




