# Makefile zum erstellen des Programms 'Brochlaid'
# Mit 'make clean' werden alle Objekte und das Programm gel"oscht
# und mit 'make' wird das Programm kompiliert.

CC=gcc
CCLINK=
CINC=

COPTS=-O0

# Nur f"ur internen gebrauch
# CC=gcc2.7.2.1
# CCLINK=-gnatlink /usr/bin/gcc2.7.2.1
# CINC=-nostdlib -I/usr/include5

all: brochlaid

# Brochlaid: Haupttestprogramm
brochlaid: brochlaid.ali vt100.o in.o
	gnatbl $(CCLINK) brochlaid.ali in.o vt100.o

brochlaid.ali: brochlaid.adb pkeyboard.ali pscreen.ali int_io.ali probyproc.ali\
         pregelungproc.ali proby.ali
	$(CC) $(COPTS) -c brochlaid.adb


# Ada Packages
pkeyboard.ali: pkeyboard.ads pkeyboard.adb pscreen.ali
	$(CC) $(COPTS) -c pkeyboard.adb

pchannel.ali: pchannel.ads pchannel.adb plbchannel.ali plistbox.ali
	$(CC) $(COPTS) -c pchannel.adb

pscreen.ali: pscreen.ads pscreen.adb
	$(CC) $(COPTS) -c pscreen.adb

ppool.ali: ppool.ads ppool.adb rob3.ali int_io.ali plbpool.ali
	$(CC) $(COPTS) -c ppool.adb

plbroby.ali: plbroby.ads plistbox.ali
	$(CC) $(COPTS) -c plbroby.ads

probyproc.ali: probyproc.ads probyproc.adb int_io.ali plbpool.ali pcheckbox.ali\
               pnumber.ali pedit.ali pnumber2.ali pscreen.ali pinfo.ali pnumber.ali
	$(CC) $(COPTS) -c probyproc.adb

pregelungproc.ali: pregelungproc.ads pregelungproc.adb pregelpool.ali daca.ali
	$(CC) $(COPTS) -c pregelungproc.adb

pregelpool.ali: pregelpool.adb pregelpool.ads
	$(CC) $(COPTS) -c pregelpool.adb

daca.ali: daca.adb daca.ads
	$(CC) $(COPTS) -c daca.adb

plbchannel.ali: plbchannel.ads plistbox.ali
	$(CC) $(COPTS) -c plbchannel.ads

plbpool.ali: plbpool.ads plistbox.ali
	$(CC) $(COPTS) -c plbpool.ads

proby.ali: proby.ads proby.adb plistbox.ali int_io.ali plbroby.ali\
           float_io.ali pscreen.ali pchannel.ali pinfo.ali ppool.ali
	$(CC) $(COPTS) -c proby.adb

plistbox.ali: plistbox.ads plistbox.adb int_io.ali pscreen.ali
	$(CC) $(COPTS) -c plistbox.adb

pcheckbox.ali: pcheckbox.ads pcheckbox.adb int_io.ali pscreen.ali
	$(CC) $(COPTS) -c pcheckbox.adb

pnumber.ali: pnumber.ads pnumber.adb int_io.ali pscreen.ali
	$(CC) $(COPTS) -c pnumber.adb

pnumber2.ali: pnumber2.ads pnumber2.adb int_io.ali pscreen.ali
	$(CC) $(COPTS) -c pnumber2.adb

pedit.ali: pedit.ads pedit.adb int_io.ali pscreen.ali
	$(CC) $(COPTS) -c pedit.adb

pinfo.ali: pinfo.ads pinfo.adb int_io.ali pscreen.ali
	$(CC) $(COPTS) -c pinfo.adb

rob3.ali: rob3.ads rob3.adb osf_io.ali
	$(CC) $(COPTS) -c rob3.adb

osf_io.ali: osf_io.ads osf_io.adb
	$(CC) $(COPTS) -c osf_io.adb


# Renamed Ada Packages
int_io.ali: int_io.ads
	$(CC) $(COPTS) -c int_io.ads

float_io.ali: float_io.ads
	$(CC) $(COPTS) -c float_io.ads


# C Implementationen
in.o: in.c
	$(CC) $(COPTS) $(CINC) -c in.c

vt100.o: vt100.c
	$(CC) $(COPTS) $(CINC) -c vt100.c

clean:
	rm -f *.o
	rm -f *.ali
	rm -f *~
	rm -f brochlaid
