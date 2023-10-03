# wireshark-nmea
Wireshark protocol dissector for NMEA 0183 protocol over ethernet.
Written in lua.




## Testing
* tshark -r samples/second.pcapng -T fields -X lua_script:nmea0183.lua -e nmea.message
* wireshark -X lua_script:nmea0183.lua samples/second.pcapng


### PowerShell / Windows
```powershell
# if wireshark is installed in the "normal" folder
& 'C:\Program Files\Wireshark\Wireshark.exe' -X lua_script:nmea0183.lua samples\second.pcapng


# usint tshark and showing header, type and fields from the dissected data
& 'C:\Program Files\Wireshark\tshark.exe'  -X lua_script:nmea0183.lua -T fields -e nmea.header -e nmea.type -e nmea.fields -r .\samples\second.pcapng

```

## Reference
* Wikipedia Article - https://en.wikipedia.org/wiki/NMEA_0183
* NMEA format - http://www.catb.org/gpsd/NMEA.html
* NMEA Simulator - `link no longer working`
* kplex - http://www.stripydog.com/kplex/
