from bs4 import BeautifulSoup
from selenium import webdriver
from urllib.request import Request, urlopen
import ast
import json
import os
import requests
import ssl
import urllib
import urllib.error
import urllib.parse
import urllib.request
import webbrowser

from selenium import webdriver
from selenium.webdriver.chrome.options import Options

CHROME_PATH = '/usr/bin/google-chrome'
CHROMEDRIVER_PATH = '/usr/bin/chromedriver'
WINDOW_SIZE = "1920,1080"

chrome_options = Options()  
chrome_options.add_argument("--headless")  
chrome_options.add_argument("--window-size=%s" % WINDOW_SIZE)
chrome_options.binary_location = CHROME_PATH

driver = webdriver.Chrome(executable_path=CHROMEDRIVER_PATH,
                          chrome_options=chrome_options
                         )  

# driver.get("https://www.google.com")
# driver.get_screenshot_as_file("capture.png")
# driver.close()

def GetSoupRequests(url): 
    req_headers = {
        'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
        'accept-encoding': 'gzip, deflate, br',
        'accept-language': 'en-US,en;q=0.8',
        'upgrade-insecure-requests': '1',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36'
    }
    with requests.Session() as s:
        r = s.get(url, headers=req_headers)
        soup = BeautifulSoup(r.content, "lxml")
    return soup 

def GetSoup(url, selenium = True, driver = driver):
    if selenium: 
        driver.get(url)
        html = driver.page_source
        soup = BeautifulSoup(html, "lxml")
    else:
        soup = GetSoupRequests(url)
    return soup

def GetGoogleResults(query, selenium = True):
    text = urllib.parse.quote_plus(query)
    return GetSoup('https://google.com/search?q=' + text, selenium)

def GetTruliaURL(address, selenium = True):
    soup = GetGoogleResults(address + " Trulia", selenium)
    urls = [] 
    for e in soup.find_all("a", href = True):
        url = e['href']
        if 'trulia' in url:
            urls.append(url)
    return urls[0]

def GetComparableURLs(trulia_url, selenium = True):
    soup = GetSoup(trulia_url, selenium)
    comps = soup.find("div", id = "comparablesTable")
    comps_urls = [e['href'] for e in comps.find_all("a")]
    comps_address = [e.text for e in comps.find_all("a")]
    return {'urls':['https://www.trulia.com' + e for e in comps_urls],
            'locations':comps_address}

def GetZillowURL(address, selenium = True):
    soup = GetGoogleResults(address + " Zillow", selenium)
    urls = [] 
    for e in soup.find_all("a", href = True):
        url = e['href']
        if 'zillow' in url:
            urls.append(url)
    return urls[0]

def GetAddressFromTruliaURL(trulia_url, selenium = True):
    soup = GetSoup(trulia_url, selenium)
    street = soup.find("div", attrs = {"data-role":"address"}).text.strip()
    city_state = soup.find("span", attrs = {"data-role":"cityState"}).text.strip()
    return (street, city_state)

def TruliaToZillow(trulia_url, selenium = True):
    address = " ".join(GetAddressFromTruliaURL(trulia_url, selenium))
    return GetZillowURL(address, selenium = True)

def ZillowToTrulia(zillow_url):
    return None 

def ForGG(address, selenium = True):
    trulia_url = GetTruliaURL(address, selenium = True)
    comp_locations = GetComparableURLs(trulia_url, selenium = False)['locations']
    target_zillow = GetZillowURL(address, selenium = True)
    zillow_comp_urls = [] 
    for comp in comp_locations:
        url = GetZillowURL(comp, selenium = True)
        zillow_comp_urls.append(url)
    return {'target':target_zillow, 'comps':zillow_comp_urls}


#address = "80 Captain's Row, Bourne, MA"
#address = "36 E Main St #A Salisbury, CT 06068"
address =  "39 Reservoir Rd Lakeville, CT 06039"
trulia_url = GetTruliaURL(address, selenium = True)
comp_locations = GetComparableURLs(trulia_url, selenium = False)['locations']
target_zillow = GetZillowURL(address, selenium = True)
zillow_comp_urls = [] 
for comp in comp_locations:
    url = GetZillowURL(comp, selenium = True)
    zillow_comp_urls.append(url)


print("")
print(target_zillow)
for z in zillow_comp_urls:
    print(z)
    
