### 1. 
```
{ 
	"info": "Sample JSON output from our service\t",
    "elements": [
        { 
			"name": "first",
			"type": "server",
			"ip": 7175 
        },
        {
			"name": "second",
			"type": "proxy",
			"ip": "71.78.22.43"
        }
    ]
}
```

### 2.
```
#!/usr/bin/env python3

import socket
import time
import yaml
import json

urls_ip = {'drive.google.com':'', 'mail.google.com':'', 'google.com':''}

with open('ip.yml', 'w') as ip_yaml:  
  ip_yaml.write(yaml.dump(urls_ip))
  
with open('ip.json', 'w') as ip_json:
  ip_json.write(json.dumps(urls_ip))

while(True):
  for url in urls_ip.keys():
    ip = socket.gethostbyname(url)
    if(ip == urls_ip[url]):
      print(f'{url} - {ip}')
    else:
      if(urls_ip[url] != ''):
        print(f'[ERROR] {url} IP mismatch: {urls_ip[url]} {ip}')
      urls_ip[url] = ip
	  	  
	  with open('ip.yml', 'w') as ip_yaml:
		ip_yaml.write(yaml.dump(urls_ip))
	  	  
	  with open('ip.json', 'w') as ip_json:
		ip_json.write(json.dumps(urls_ip))
		
  time.sleep(60)
```