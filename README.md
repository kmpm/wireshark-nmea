# wireshark-nmea
nmea 0183 over ethernet protocol dissector for wireshark written in lua




## Testing
* tshark -r samples/second.pcapng -T fields -X lua_script:nmea0183.lua -e nmea.message
* wireshark -X lua_script:nmea0183.lua samples/second.pcapng


## Reference
* NMEA format - http://www.catb.org/gpsd/NMEA.html
* NMEA Simulator - `link no longer working`
* kplex - http://www.stripydog.com/kplex/
