
ifeq ($(OS),Windows_NT)
	TSHARKBIN?=C:\Program Files\Wireshark\tshark.exe
	WIRESHARKBIN?=C:\Program Files\Wireshark\wireshark.exe
	FixPath = $(subst /,\,$1)
else
	TSHARKBIN?=tshark
	WIRESHARKBIN=wireshark
	FixPath = $1
endif

TESTFIELDS=-e nmea.count -e nmea.sentence.index -e nmea.sentence.tag

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
	"$(TSHARKBIN)" -X lua_script:nmea0183.lua -T fields $(TESTFIELDS) -r $@


.PHONY: ws
ws:
	$(WIRESHARKBIN) -X lua_script:nmea0183.lua 