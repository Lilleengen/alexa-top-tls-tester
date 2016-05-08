#!/usr/bin/python

from bs4 import BeautifulSoup
import requests
import csv
import sys

alexa = 'http://www.alexa.com/topsites/countries;{}/'+sys.argv[1]
base = 'http://www.alexa.com'

def getSites():
    sites = {}
    for i in xrange(20):
        page = requests.get(alexa.format(i))
        parsed = BeautifulSoup(page.text, 'lxml')
        entries = parsed.select('.desc-container')
        for e in entries:
            name = e.find('a').decode_contents(formatter="html")

            sites[name] = name.lower()
    return sites

if __name__ == '__main__':
    sites = getSites()
    for siteName in sites:
        print siteName, sites[siteName]
    with open('websites.csv', 'w') as f:
        writer = csv.writer(f)
        for siteName in sites:
            writer.writerow([siteName, sites[siteName]])
