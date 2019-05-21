import urllib.request
import urllib.parse
import urllib.error
from bs4 import BeautifulSoup
import ssl
import json
import ast
import os
from urllib.request import Request, urlopen

import requests
from lxml import etree

def GetData(url):
    req_headers = {
    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
    'accept-encoding': 'gzip, deflate, br',
    'accept-language': 'en-US,en;q=0.8',
    'upgrade-insecure-requests': '1',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36'
    }
    with requests.Session() as s:
        r = s.get(url, headers=req_headers)
        z = BeautifulSoup(r.content, "lxml")
    matches = z.findAll("script", attrs= {"id": "hdpApolloPreloadedData"})
    d = json.loads(matches[0].text)
    details = json.loads(d['apiCache'])
    keys = details.keys()
    d1 = details[list(keys)[0]]['property']
    return d1 

urls = ['https://www.zillow.com/homedetails/210-Clipper-Rd-Bourne-MA-02532/186978102_zpid/',
         'https://www.zillow.com/homedetails/188-Captains-Row-Bourne-MA-02532/186978104_zpid/']

# for url in urls: 
#      print(GetData(url))
