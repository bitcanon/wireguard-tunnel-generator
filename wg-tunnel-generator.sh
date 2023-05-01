#!/bin/bash

# Output directory for generated key pairs and configurations
CONF_DIR="./configs/"

# Pre-defined parameter values
ALLOWED_IPS="0.0.0.0/0"
DNS="1.0.0.1,1.1.1.1"
ENDPOINT="fw.example.com:13231"
FW_PRIVATE_KEY="0"
FW_PUBLIC_KEY="0"
IP_ADDR=""
NAME="mobile-phone"
VERBOSE=false

usage() {
    echo "Usage:"
    echo "  $0 [options] <mobile_peer_ip>"
    echo ""
    echo "Options:"
    echo "  <mobile_peer_ip>    Mobile peer IP address in CIDR notation, ie. 10.0.0.2/32"
    echo "  -a <subnet,...>     One or more IP subnet(s) to be routed through the tunnel"
    echo "  -d <dns,...>        One or more DNS server(s) to be used by the mobile client"
    echo "  -e <host[:port]>    WireGuard endpoint on the firewall, ie. fw.example.com:13231"
    echo "  -h                  Print this help and exit"
    echo "  -n <name>           Descriptive name for the mobile client"
    echo "  -p <public_key>     Public key of the WireGuard interface on the firewall"
    echo "  -v                  Print verbose debugging information"
    echo ""
    echo "Examples:"
}

# Make sure that package dependencies are installed prior to running this script
check_dependency() {
    if ! command -v "$1" > /dev/null ; then
        echo "Package dependency '$2' not found, but can be installed with:"
        echo "sudo apt install $2"
        exit 1
    fi
}

check_dependency "ipcalc-ng" "ipcalc-ng"
check_dependency "wg" "wireguard-tools"
check_dependency "qrencode" "qrencode"

# No parameters were passed
if [ "$#" -le 0 ]; then
    usage
    exit 1
fi

# Parse script parameters
while getopts "ha:d:e:n:p:v" flag; do
    case "$flag" in
        a) ALLOWED_IPS=$OPTARG;;
        d) DNS=$OPTARG;;
        e) ENDPOINT=$OPTARG;;
        h) usage;;
        n) NAME=$OPTARG;;
        p) FW_PUBLIC_KEY=$OPTARG;;
        v) VERBOSE=true;;
        \?) usage;;
    esac
done

IP_ADDR=${@:$OPTIND:1}
# ARG2=${@:$OPTIND+1:1}

# Client WireGuard configuration output files
CONF_OUTFILE=$CONF_DIR$NAME".conf"
QRCODE_OUTFILE=$CONF_DIR$NAME".png"

# MikroTik WireGuard configuration output file
MTCONF_OUTFILE=$CONF_DIR$NAME".rsc"

# Ensure the IP address was passed as an argument
if [[ -z "$IP_ADDR" ]]; then
    echo "$0: ip address is missing"
    exit 1
fi

# Perform IP address validation (using ipcalc-ng)
if ! ipcalc-ng -cs "$IP_ADDR" ; then
    echo "$0: invalid ip address ($IP_ADDR)"
    exit 1
fi

# Create the key pair directory if it doesn't exists
if [ ! -d $KEY_DIR ]; then
    mkdir $KEY_DIR
fi

# Create the WireGuard configuration directory if it doesn't exists
if [ ! -d $CONF_DIR ]; then
    mkdir $CONF_DIR
fi

# In case the user has not provided a public key with the -p parameter
# we need to generate a new key pair for the firewall as well
if [ "$FW_PUBLIC_KEY" = "0" ]; then
    FW_PRIVATE_KEY=$(wg genkey)
    FW_PUBLIC_KEY=$(echo $FW_PRIVATE_KEY | wg pubkey)
fi

# Generate new key pair and pre-shared key for the mobile device
PRIVATE_KEY=$(wg genkey)
PUBLIC_KEY=$(echo $PRIVATE_KEY | wg pubkey)
PRESHARED_KEY=$(openssl rand -base64 32)

# Export the mobile client configuration
printf "[Interface]\n" > $CONF_OUTFILE
printf "Address = %s\n" $IP_ADDR >> $CONF_OUTFILE
printf "PrivateKey = %s\n" $PRIVATE_KEY >> $CONF_OUTFILE
printf "DNS = %s\n\n" $DNS >> $CONF_OUTFILE
printf "[Peer]\n" >> $CONF_OUTFILE
printf "PublicKey = %s\n" $FW_PUBLIC_KEY >> $CONF_OUTFILE
printf "Endpoint = %s\n" $ENDPOINT >> $CONF_OUTFILE
printf "PresharedKey = %s\n" $PRESHARED_KEY >> $CONF_OUTFILE
printf "AllowedIPs = %s" $ALLOWED_IPS >> $CONF_OUTFILE

# Export QR Code to console and file
printf "#####################################################################\n"
printf "############## Scan QR Code with WireGuard mobile app ###############\n"
printf "#####################################################################\n"
qrencode -t ansiutf8 < $CONF_OUTFILE
qrencode -t png -s 5 -o $QRCODE_OUTFILE < $CONF_OUTFILE
printf "The QR code has been exported to '%s'...\n\n" $QRCODE_OUTFILE

# If the FW_PRIVATE_KEY variable has a value other that 0, that means that
# a new key pair has been generated for the firewall, and that we can provide
# the user with the RouterOS configuration for the WireGuard interface as well
rm -f $MTCONF_OUTFILE
if [ ! "$FW_PRIVATE_KEY" = "0" ]; then
    printf "#####################################################################\n"
    printf "############ RouterOS WireGuard Interface Configuration #############\n"
    printf "#####################################################################\n"
    printf "/interface wireguard\n" | tee -a $MTCONF_OUTFILE
    printf "add comment=\"WireGuard Mobile\" listen-port=13231 mtu=1420 name=wg_mobile \\ \n" | tee -a $MTCONF_OUTFILE
    printf "    private-key=\"%s\"\n\n" $FW_PRIVATE_KEY | tee -a $MTCONF_OUTFILE
fi

# Export the MikroTik configuration
printf "#####################################################################\n"
printf "########## RouterOS WireGuard Interface Peer Configuration ##########\n"
printf "#####################################################################\n"
printf "/interface wireguard peers\n" | tee -a $MTCONF_OUTFILE
printf "add allowed-address=%s comment=\"%s\" interface=wg_mobile \\ \n" $IP_ADDR $NAME | tee -a $MTCONF_OUTFILE
printf "    preshared-key=\"%s\" \\ \n" $PRESHARED_KEY | tee -a $MTCONF_OUTFILE
printf "    public-key=\"%s\"\n" $PUBLIC_KEY | tee -a $MTCONF_OUTFILE

# User has passed the -v parameter to the script so we
# dump all the useful debugging information to them
if [ "$VERBOSE" = true ]; then
    printf "\n#####################################################################\n"
    printf "############### Script Verbose Debugging Information ################\n"
    printf "#####################################################################\n"
    printf " Allowed IPs                 : %s\n" $ALLOWED_IPS
    printf " DNS                         : %s\n" $DNS
    printf " Firewall WG Endpoint        : %s\n" $ENDPOINT
    printf " Client IP Address           : %s\n" $IP_ADDR
    printf " Client Name/Description     : %s\n" $NAME
    printf " WG Client Configuration     : %s\n" $CONF_OUTFILE
    printf " WG MikroTik Configuration   : %s\n" $MTCONF_OUTFILE
    printf " QR Code Export File         : %s\n" $QRCODE_OUTFILE
fi
