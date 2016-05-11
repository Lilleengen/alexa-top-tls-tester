#!/bin/bash
#
# DROWNcheck.sh
#
# Authors:
#  Thorsten Lusser <tlusser@anexia-it.com>
#  Stephan Peijnik <speijnik@anexia-it.com>
#
# The MIT License (MIT)
#
# Copyright (c) 2016 ANEXIA Internetdienstleistungs GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
# Modified by
#  Henrik Lilleengen <mail@ithenrik.com>
#
# Modifications released under The MIT License (MIT)

VERSION=1.0.0
HOST=$1
PORT=${2:-443}


function check_connect() {
	
	PATCHED="yes"
	for cipher in ${1}
	do
	  echo -en "Testing cipher ${cipher}: "
	  result=$(echo -n | timeout 10 /usr/local/ssl/bin/openssl  s_client -ssl2 -cipher "$cipher" -connect $SERVER 2>&1)
	  if [[ "$result" =~ "connect:errno=" ]]
	  then
	    err=$(echo $result | grep ^connect: \
	      | sed -e 's/connect:errno=.*//g' -e 's/connect: //g')
	    echo -e "\033[93mConnection error: $err"
	    echo -e "Aborting checks.\033[0m"
	    exit 2
	  elif [[ "$result" =~ "SSL23_GET_SERVER_HELLO:unknown protocol" ]]
	  then
	    echo -e "\033[93mNo SSL/TLS support on target port."
	    echo -e "Aborting checks.\033[0m"
	    exit 2
	  elif [[ "$result" =~ "SSL_CTX_set_cipher_list:no cipher match" ]]
	  then
	    echo -e "\033[93mYour version of OpenSSL is not supported."
	    echo -e "Aborting checks.\033[39m"
	    exit 2
	  elif [[ "$result" =~ "Cipher is ${cipher}" || "$result" =~ "Cipher    : ${cipher}" ]]
	  then
	    echo -e "\033[91mSUPPORTED\033[0m"
	    if [[ "$PATCHED" == "yes" ]]
	    then
	      PATCHED="no"
	    fi
	  else
	    echo -e "\033[92mUNSUPPORTED\033[0m"
	  fi
	done
}

REMOVED_SSLv2_CIPHERS="EXP-RC4-MD5 RC2-CBC-MD5 EXP-RC2-CBC-MD5 DES-CBC-MD5"
SSLv2_CIPHERS="DES-CBC3-MD5 RC2-CBC-MD5 RC4-MD5"

# Test if OpenSSL does support the ciphers we're checking for...
echo -n "Testing if OpenSSL supports the ciphers we are checking for: "

#check_existing_ciphers $REMOVED_SSLv2_CIPHERS
#check_existing_ciphers $SSLv2_CIPHERS

echo -e "\033[92mYES\033[0m"

SERVER=$HOST:$PORT

echo -e "\n\033[94mTesting ${SERVER} for availability of SSLv2 and export ciphers...\033[0m"

check_connect "${REMOVED_SSLv2_CIPHERS}"
patched=$PATCHED

if [ "$patched" == "no" ]; then
    echo -e "\033[91mThe system needs to be patched!\033[0m"
else
    echo -e "\033[92mThe system is up-to-date.\033[0m"
fi

check_connect "${SSLv2_CIPHERS}"
sslv2_active=$PATCHED
if [ "$sslv2_active" == "no" ]; then
    echo -e "\033[91mSSLv2 is active!\033[0m"
    exit 1
else
    echo -e "\033[92mSSLv2 is inactive.\033[0m"
    exit 0
fi
