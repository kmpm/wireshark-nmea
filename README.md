# wireshark-nmea
nmea 0183 over ethernet protocol dissector for wireshark written in lua




## Testing
* tshark -r samples/second.pcapng -T fields -X lua_script:nmea0183.lua -e nmea.message
* wireshark -X lua_script:nmea0183.lua samples/second.pcapng


## Reference
* http://www.catb.org/gpsd/NMEA.html