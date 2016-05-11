alexa-top-tls-tester
======
Tests the TLS implementation of the top 500 sites on Alexa

```
$ ./alexa-top-tls-tester.sh [ISO-3166-2-alpha]
 {0 (hearthbleed), 65 (lucky -20), 32 (poodle), 19 (freak), 3 (drown)}/321
$

```

### Getting started
Install the following project before using:
 - [PeterMosmans/openssl](https://github.com/PeterMosmans/openssl)
 - [FiloSottile/Heartbleed](https://github.com/FiloSottile/Heartbleed)
 - [FiloSottile/CVE-2016-2107](https://github.com/FiloSottile/CVE-2016-2107)

Modify CVE-2016-2107 to return 2 instead of 1 on error.

## Version 
* Version 0.1

## Contact
#### Henrik Lilleengen
* e-mail: mail@ithenrik.com
