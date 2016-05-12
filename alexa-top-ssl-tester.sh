echo "Downloading alexa toplist to websites.csv"
python scrape-alexa.py $1 > /dev/null 2>&1

dos2unix websites.csv > /dev/null 2>&1

INPUT=websites.csv
OLDIFS=$IFS
HB=0
LNT=0
POO=0
FRK=0
DRW=0
COUNT=0
COUNTT=0
IFS=,
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }
while read name website
do
    DOMAIN=$website
    if curl -s -k --connect-timeout 10 --head  --request GET https://$DOMAIN | grep "200 OK\|301 Moved Permanently\|302 Found" > /dev/null; then
        Heartbleed $DOMAIN > /dev/null 2>&1
        if [[ $? == 1 ]] ; then
            HB=$((HB+1))
        fi
        CVE-2016-2107 $DOMAIN > /dev/null 2>&1
        if [[ $? == 1  ]] ; then
            LNT=$((LNT+1))
        fi
        ./test-poodle.sh $DOMAIN
        if [[ $? == 1 ]]; then
            POO=$((POO+1))
        fi
        timeout 10 /usr/local/ssl/bin/openssl s_client -connect $DOMAIN:443 -cipher EXPORT 2>&1 >/dev/null | grep -q "error"
        if [[ $? == 1 ]]; then
            FRK=$((FRK+1))
        fi
        ./test-drown.sh $DOMAIN > /dev/null 2>&1
        if [[ $? == 1 ]]; then
            DRW=$((DRW+1))
        fi
        COUNT=$((COUNT+1))
    fi
    COUNTT=$((COUNTT+1))
    echo -en "\r{$HB (hearthbleed), $LNT (lucky -20), $POO (poodle), $FRK (freak), $DRW (drown)}/$COUNT ($((COUNTT/5))%, $DOMAIN)\033[K"
done < $INPUT
IFS=$OLDIFS
echo -en "\r{$HB (hearthbleed), $LNT (lucky -20), $POO (poodle), $FRK (freak), $DRW (drown)}/$COUNT\n\033[K"
