python alexa-scraper.py $1 > /dev/null 2>&1
dos2unix websites.csv

INPUT=websites.csv
OLDIFS=$IFS
HB=0
LNT=0
POO=0
FRK=0
COUNT=0
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
        /usr/local/ssl/bin/openssl s_client -connect akamai.com:443 -cipher EXPORT > /dev/null 2>&1
        if [[ $? < 1 ]]; then
            FRK=$((FRK+1))
        fi
        COUNT=$((COUNT+1))
    fi
    echo "{$HB, $LNT, $POO, $FRK}/$COUNT ($DOMAIN)"
done < $INPUT
IFS=$OLDIFS
