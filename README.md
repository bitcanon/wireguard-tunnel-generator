# 🖧 WireGuard Tunnel Generator
Hi and welcome! Click the button below if you enjoy this library and want to support my work. A lot of coffee is consumed as a software developer you know 😁

<a href="https://www.buymeacoffee.com/bitcanon" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

>Needless to say, this is completely voluntary.

## 🤓 Introduction
A simple bash script to speed up and simplify the deployment of WireGuard Road Warriors (mobile VPN clients) against a MikroTik firewall running RouterOS.

The script will produce both the RouterOS configuration required as well as a QR code to scan with the WireGuard mobile app. This will enable you to deploy a new mobile VPN client within a minute or two, and you don't have to send public keys back and forth between the mobile device and the router.

## 🕹 Demo Applications
### Demo 1: Example Output
Here is a small command-line demo application showing the information that can be obtained from the device.

![SmartMeter CLI Demo](https://github.com/bitcanon/elnasmartmeter/blob/main/docs/img/elna-cli-application.gif)

The source code is available here: [powerping-demo.py](https://github.com/bitcanon/elnasmartmeter/blob/main/examples/powerping-demo.py).

## 💻 Installation
Setup the virtual environment:
```
virtualenv venv
source venv/bin/activate
```

Install the latest version with `pip`:
```
pip install elnasmartmeter
```

## 📚 Basics
### Setup
In order to use the library you need to know the IP address of the Elna device. You can find it in the DHCP server of your router (or wherever you are running your DHCP server). The MAC address of Elna is printed on the back of the device.

```python
from elna import smartmeter

# Connect the library to the Elna device
meter = smartmeter.Connect('192.168.0.10')

# Get general information
info = meter.get_info()

# Get power readings
electricity = meter.get_electricity()

# Get WLAN information
wlan = meter.get_wlan_info()
```
It's as simple as that to fetch the power consuption/production of your household. In a moment we will be looking at how to access the information via the `info` and `electricity` objects.

### Exceptions
All of the methods callable from the library will throw exceptions on failure. A full list of exceptions can be found [here](https://github.com/bitcanon/elnasmartmeter/blob/master/elnasmartmeter/exceptions.py).
```python
from elna import smartmeter
from elna.exceptions import *
...
try:
    info = meter.get_info()
except NewConnectionError as e:
    print(e)
```

### Printing Objects and Properties
The objects representing various entities in the library can be output with the `print()` method for easy inspection of its properties.

As an example, you can output the properties of an `Information` object by passing it to the `print()` method:
```python
print(info)
# Output: <class 'elna.classes.Information'>: {'id': '01ab:0200:00cd:03ef', 'manufacturer': 'NET2GRID', 'model': 'SBWF4602', 'firmware': '1.7.14', 'hardware': 1, 'batch': 'HMX-P0D-123456'}
```
The same goes for all classes in the library: `Information`, `Electricity`, `Power` and `WLANInformation`.

## 💾 Access the Data
There are two pieces of data that can be fetched with this library: general device `Information` and `Power` statistics.

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




