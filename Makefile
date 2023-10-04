
ifeq ($(OS),Windows_NT)
	TSHARKBIN?=C:\Program Files\Wireshark\tshark.exe
	WIRESHARKBIN?=C:\Program Files\Wireshark\wireshark.exe
	FixPath = $(subst /,\,$1)
else
	TSHARKBIN?=tshark
	WIRESHARKBIN=wireshark
	FixPath = $1
endif

SAMPLEFILES := $(wildcard samples/*.pcapng)

SUBDIRS := tests
TOPTARGETS := tests clean


.PHONY: $(TOPTARGETS) $(SUBDIRS)
$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)


.PHONY: samples
samples: $(SAMPLEFILES)

.PHONY: $(SAMPLEFILES)
$(SAMPLEFILES):
	"$(TSHARKBIN)" -X lua_script:nmea0183.lua -T fields -e nmea.count -e nmea.format -e nmea.header -e nmea.talker -e nmea.fields -e nmea.checksum.status -r $@


.PHONY: ws
ws:
	$(WIRESHARKBIN) -X lua_script:nmea0183.lua 