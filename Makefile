


ifeq ($(OS),Windows_NT)
	TSHARKBIN?=C:\Program Files\Wireshark\tshark.exe
	WIRESHARKBIN?=C:\Program Files\Wireshark\wireshark.exe
else
	TSHARKBIN?=tshark
endif


.PHONY: tests
tests:
	$(TSHARKBIN) -X lua_script:nmea0183.lua -T fields -e nmea.count -r samples/second.pcapng


.PHONY: ws
ws:
	$(WIRESHARKBIN) -X lua_script:nmea0183.lua ./samples/second.pcapng