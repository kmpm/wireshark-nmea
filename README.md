# wireshark-nmea
Wireshark protocol dissector in lua for NMEA 0183 protocol over ethernet.




## Testing
* tshark -r samples/second.pcapng -T fields -X lua_script:nmea0183.lua -e nmea.message
* wireshark -X lua_script:nmea0183.lua samples/second.pcapng
* `make clean tests`

### PowerShell / Windows
```powershell
# if wireshark is installed in the "normal" folder
& 'C:\Program Files\Wireshark\Wireshark.exe' -X lua_script:nmea0183.lua samples\second.pcapng


# usint tshark and showing header, type and fields from the dissected data
& 'C:\Program Files\Wireshark\tshark.exe'  -X lua_script:nmea0183.lua -T fields -e nmea.header -e nmea.type -e nmea.fields -r .\samples\second.pcapng

```

## Reference
* Wikipedia Article - https://en.wikipedia.org/wiki/NMEA_0183
* NMEA format - https://gpsd.gitlab.io/gpsd/NMEA.html
* kplex - http://www.stripydog.com/kplex/
* Lua Support in Wireshark - https://www.wireshark.org/docs/wsdg_html_chunked/wsluarm.html
* Wireshark wiki for lua - https://gitlab.com/wireshark/wireshark/-/wikis/Lua


## License
Apache License 2.0. See the file LICENSE.