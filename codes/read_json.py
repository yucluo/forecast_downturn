import json
import urllib.parse
import ssl
import os


fh = []
directory = os.getcwd()

for filename in os.listdir(directory):
    if filename.endswith("json"):
        fh.append(filename)
    else:
        continue

source = []

for filename in fh:
    f = open(filename)
    try:
        data = json.load(f)
    except:
        continue
    value = data['value']
    for i in range(len(value)):
        source.append(value[i]['Source']["Name"])

# print(type(source))
print(source)
