ifeq ($(OS),Windows_NT)
	TSHARKBIN?=C:\Program Files\Wireshark\tshark.exe
	DIFF = fc /L /N /T $(1) $(2)
	FixPath = $(subst /,\,$1)
	RM = del
else
	TSHARKBIN?=tshark
	DIFF = diff $(1) $(2)
	FixPath = $1
	RM = rm
endif

TEST="$(TSHARKBIN)" -X lua_script:../nmea0183.lua -T fields -e nmea.count -e nmea.format -e nmea.header -e nmea.talker -e nmea.fields -e nmea.checksum.status

CAPFILES := $(wildcard *.pcapng)
FILES := $(patsubst %.pcapng,%,$(CAPFILES))
OUTFILES := $(patsubst %,%.out,$(FILES))


all: tests


.PHONY: tests
tests: $(OUTFILES) $(FILES)


.PHONY: clean	
clean:
	-$(RM) *.out
	
	
.PHONY: $(FILES)
$(FILES):
	$(call DIFF,$@.fields.txt,$@.out)
	
		
%.out: %.pcapng
	echo "stuffit $@ $^"
	$(TEST) -r $^ > $@
	