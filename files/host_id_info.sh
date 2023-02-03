#bin/bash

MANUFACTURER=$(/opt/puppetlabs/bin/facter dmi.manufacturer)
MODEL=$(/opt/puppetlabs/bin/facter dmi.product.name)
LAST_USER=$(last -n 1 -R -w | head -n1 | cut -d' ' -f1)
#LAST_TIME=$(last -n 1 -R -w --time-format iso | head -n1 | tr -s ' ' | cut -d' ' -f3)
LAST_TIME=$(lastlog -u $LAST_USER | tail -n1 | tr -s ' ' | cut -d' ' -f4-)
SERIAL=$(/opt/puppetlabs/bin/facter dmi.product.serial_number)
OS=$(/opt/puppetlabs/bin/facter os.name)
OS_VER=$(/opt/puppetlabs/bin/facter os.release.full)
LAST_LOGIN=$(date -d"$LAST_TIME" +"%m/%d/%Y %H:%M:%S")

if [ "$MODEL" == "VMware Virtual Platform" ]; then
        MANUFACTURER="VMware"
        MODEL="Virtual Platform"
fi

HOSTNAME=$(hostname -s | tr '[[:lower:]]' '[[:upper:]]')

kinit -k "$HOSTNAME\$"

ldapsearch -LLL -Q -o ldif-wrap=no -h campusdc22a.CAMPUS.TAYLORU.EDU -b dc=campus,dc=tayloru,dc=edu -Y GSSAPI "(&(objectClass=computer)(cn=$HOSTNAME))" dn | head -n1 > /tmp/host_update.ldif

echo "changetype: Modify
replace: extensionAttribute1
extensionAttribute1: $MANUFACTURER
-
replace: extensionAttribute2
extensionAttribute2: $MODEL
-
replace: extensionAttribute3
extensionAttribute3: $LAST_USER
-
replace: extensionAttribute4
extensionAttribute4: $LAST_LOGIN
-
replace: serialNumber
serialNumber: $SERIAL
-
replace: operatingSystem
operatingSystem: $OS
-
replace: operatingSystemVersion
operatingSystemVersion: $OS_VER
" >> /tmp/host_update.ldif

ldapmodify -Q -h campusdc22a.CAMPUS.TAYLORU.EDU -Y GSSAPI -f /tmp/host_update.ldif > /dev/null
