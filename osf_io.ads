-----------------------------------------------------------------------------
-- FILE    : osf_io_.ada
-- DATUM   : 09.09.94
-- AUTOREN : P. Lang, T. Zehnder
--
-- Revision History
--
--   - 03.10.96, R.Barandun &  C.Werder
--     Package portiert fuer GNAT Ada95
-----------------------------------------------------------------------------
--  Beschreibung:
--     I/O Funktionen unter OSF/1 mit POSIX kompatiblen Aufrufen
--     Definitionen der zugehoerigen Parameter und Konstanten
--
--  Funktionen und Prozeduren:
-- 
--     function CLOSE
--	  Schliesst ein File mit File Descriptor
--     function DUP
--        Oeffnet einen neuen File Descriptor auf das File bezeichnet mit
--        einem bestehenden File Descriptor   
--     function DUP2
--        Wie DUP als zweites Argument wird jedoch der gewuenschte File
--        Descriptor uebergeben. Bezeichnet dieser ein schon geoeffnetes
--        File, wird es geschlossen und der File Descriptor auf das vom 
--        ersten Argument bezeichnete File gesetzt
--     function FCNTL 
--        Fuehrt verschiedene File Control Funktionen aus
--     procedure FSTAT
--        Fragt den Status des Files ab
--     function LSEEK
--        Verschiebt den Read bzw. Write Pointer innerhalb des Files
--     function OPEN
--        Oeffnet das als Pfad angegebene File
--     function READ
--        Liest die Anzahl angegebener Zeichen vom File
--     procedure STAT
--        Fragt den Status des Files ab
--     function UNLINK
--        Loescht das File
--     function WRITE
--        Schreibt die angegebene Anzahl Zeichen in das File
--     function GETPID 
--        Gibt die PID des aufrufenden Prozesses zurueck
--     function GETENV
--        Liest den Wert der Umgebungsvariabel
--     function GETCWD 
--        Liest den Pfadnamen des aktuellen 'working directory'
--     function ISATTY
--        Stellt fest, ob das File einem Terminal Device entspricht
--     function TTYNAME
--        Liest den Namen des Terminals       
--     function FTRUNCATE
--        Aendert die Filegroesse
--     function CFGETOSPEED
--        Liest die Output-Uebertragungsgeschwindigkeit aus einem TERMIOS_T
--     function CFSETOSPEED
--        Setzt die Output-Uebertragungsgeschwindigkeit in einem TERMIOS_T
--     function CFGETISPEED
--        Liest die Input-Uebertragungsgeschwindigkeit aus einem TERMIOS_T
--     function CFSETISPEED
--        Setzt die Input-Uebertragungsgeschwindigkeit in einem TERMIOS_T
--     function TCGETATTR
--        Liest die Terminaleinstellung
--     function TCSETATTR 
--        Setzt die Terminaleinstellung
--     function TCSENDBREAK
--        Sendet ein Break ueber eine serielle Leitung
--     function TCDRAIN
--        Wartet bis die Ausgabe beendet ist
--     function TCFLUSH
--        Verwirft noch nicht gesendete Ausgabedaten oder noch nicht gelesene
--        Eingangsdaten
--     function TCFLOW
--        Fuehrt Flusskontrollfunktionen aus
------------------------------------------------------------------------------------
with SYSTEM, Interfaces.C, Interfaces.C.Strings;
use  SYSTEM, Interfaces.C, Interfaces.C.Strings;

package OSF_IO is

   ADDRESS_ZERO : constant system.address := Null_Address;
   
   subtype FILE_DESCRIPTOR_TYPE is Interfaces.C.int;

   type UNSIGNED_32 is new Interfaces.C.unsigned;
   
   -- file permissions

   subtype FILE_PERMISSION_TYPE is UNSIGNED_32;

   S_ISUID  : constant UNSIGNED_32 := 8#004000#; 
   S_ISGID  : constant UNSIGNED_32 := 8#002000#;

   S_IRWXU  : constant UNSIGNED_32 := 8#000700#; 
   S_IRUSR  : constant UNSIGNED_32 := 8#000400#;  
   S_IWUSR  : constant UNSIGNED_32 := 8#000200#;  
   S_IXUSR  : constant UNSIGNED_32 := 8#000100#; 
   S_IRWXG  : constant UNSIGNED_32 := 8#000070#; 
   S_IRGRP  : constant UNSIGNED_32 := 8#000040#;  
   S_IWGRP  : constant UNSIGNED_32 := 8#000020#;  
   S_IXGRP  : constant UNSIGNED_32 := 8#000010#; 
   S_IRWXO  : constant UNSIGNED_32 := 8#000007#;
   S_IROTH  : constant UNSIGNED_32 := 8#000004#;  
   S_IWOTH  : constant UNSIGNED_32 := 8#000002#;  
   S_IXOTH  : constant UNSIGNED_32 := 8#000001#;  
	
   -- open flags
   subtype OPEN_FLAGS_TYPE is UNSIGNED_32;

   O_RDONLY   : constant UNSIGNED_32 := 8#000000#;  -- read only
   O_WRONLY   : constant UNSIGNED_32 := 8#000001#;  -- write only
   O_RDWR     : constant UNSIGNED_32 := 8#000002#;  -- read and write
   O_ACCMODE  : constant UNSIGNED_32 := 8#000003#;  -- mask for access modes
   O_NONBLOCK : constant UNSIGNED_32 := 8#000004#;  -- non-blocking mode
   O_APPEND   : constant UNSIGNED_32 := 8#000010#;  -- append file
   O_CREAT    : constant UNSIGNED_32 := 8#001000#;  -- create file
   O_TRUNC    : constant UNSIGNED_32 := 8#002000#;  -- truncate file
   O_EXCL     : constant UNSIGNED_32 := 8#004000#;  -- exclusive access
   O_NOCTTY   : constant UNSIGNED_32 := 8#010000#;  -- no control terminal
 
   -- FSTAT
   subtype STAT_MODE_TYPE is UNSIGNED_32;

   S_IFMT  : constant STAT_MODE_TYPE := 8#0170000#;	--  type of file
   S_IFREG : constant STAT_MODE_TYPE := 8#0100000#;     --  regular
   S_IFBLK : constant STAT_MODE_TYPE := 8#0060000#;	--  block special
   S_IFDIR : constant STAT_MODE_TYPE := 8#0040000#;	--  directory
   S_IFCHR : constant STAT_MODE_TYPE := 8#0020000#;	--  character special
   S_IFIFO : constant STAT_MODE_TYPE := 8#0010000#;	--  FIFO - named pipe
   S_IFLNK : constant STAT_MODE_TYPE := 8#0120000#;	--  symbolic link
   S_IFSOCK: constant STAT_MODE_TYPE := 8#0140000#;	--  socket
   S_ISVTX : constant STAT_MODE_TYPE := 8#0001000#;	--  save swapped text even after use
   S_IREAD : constant STAT_MODE_TYPE := 8#0000400#;	--  read permission, owner
   S_IWRITE: constant STAT_MODE_TYPE := 8#0000200#;	--  write permission, owner
   S_IEXEC : constant STAT_MODE_TYPE := 8#0000100#;	--  execute/search permission, owner
     
   subtype DEV_TYPE is Interfaces.C.INT;
   subtype INO_TYPE is Interfaces.C.INT;
   subtype TIME_TYPE is Interfaces.C.INT;

   -- **** Do not access either SAVED_INODE or SAVED_CWD without first
   -- **** locking the CWD_MUTEX.
   --
   SAVED_INODE : INO_TYPE := INO_TYPE(0);
   type ACCESS_DIR_NAME is access STRING;
   SAVED_CWD : ACCESS_DIR_NAME;

   -- Controls access to the global variable that contains the
   -- current working directory name and current working directory inode.
   --
--   CWD_MUTEX : LOW_LEVEL_IO.LOCK_MANAGER.LOCK_TYPE;

   -- Used by fcntl.
   --
   F_DUPFD : constant := 0; 	-- duplicate fd
   F_GETFD : constant := 1; 	-- get fd flags
   F_SETFD : constant := 2; 	-- set fd flags
   F_GETFL : constant := 3; 	-- get file flags
   F_SETFL : constant := 4;	-- set file flags
   F_GETLK : constant := 7;     -- get file lock
   F_SETLK : constant := 8;     -- set file lock
   F_SETLKW: constant := 9;	-- set file lock and wait

   type STAT_TYPE is                  
      record                         
         DEV	: DEV_TYPE;	   -- ID des Geraet, welches den
                                   -- Verzeichniseintrag fuer das File hat   
       	 INO	: INO_TYPE;	   -- Inode des Fileeintrags  
         MODE	: STAT_MODE_TYPE;  -- Status und Zugriffsmodus  
         NLINK  : SHORT_INTEGER;   -- Anzahl Links  
         PAD1   : SHORT_INTEGER;     
         UID	: INTEGER;	   -- User ID des File-Owners  
         GID	: INTEGER;	   -- Group ID der File-Gruppe  
         RDEV   : DEV_TYPE;	   -- Device ID bei 'character' und 'block
                                   -- special files'  
         PAD2   : INTEGER;	   
         SIZE   : INTEGER;	   -- Filegroesse in Bytes  
	 PAD3	: INTEGER;         
         ATIME  : TIME_TYPE;       -- Zeitpunkt des letzten Zugriffes	     
         SPARE1 : INTEGER;	     
         MTIME  : TIME_TYPE;	   -- Zeitpunkt der letzten Modifikation    
         SPARE2 : INTEGER;	     
         CTIME  : TIME_TYPE;	   -- Zeitpunkt der letzten Filestatusaenderung  
         SPARE3 : INTEGER;	     
         BLKSIZE: INTEGER;	   -- Blockgroesse  
         BLOCKS : INTEGER;	   -- Anzahl allozierter Bloecke  
	 FLAGS	: OPEN_FLAGS_TYPE; -- Anwenderspezifizierte Flags  
       	 GENNUM : Interfaces.C.INT;     -- 'file generation number'
         SPARE4 : INTEGER;	     
      end record;			     
 
 
   STAT_TYPE_INIT : constant STAT_TYPE :=       
      (DEV	=> DEV_TYPE(0),			     
       INO	=> INO_TYPE(0),	     
       MODE	=> 0,	     
       NLINK	=> 0,			     
       PAD1	=> 0,
       UID	=> 0,			     
       GID	=> 0,			     
       RDEV	=> 0,			     
       PAD2	=> 0,
       SIZE	=> 0,			     
       PAD3	=> 0,
       ATIME	=> TIME_TYPE(0),	     
       SPARE1	=> 0,			     
       MTIME	=> TIME_TYPE(0),	     
       SPARE2	=> 0,			     
       CTIME	=> TIME_TYPE(0),	     
       SPARE3	=> 0,			     
       BLKSIZE	=> 0,			     
       BLOCKS	=> 0,			     
       FLAGS	=> O_RDONLY,
       GENNUM	=> Interfaces.C.INT(0),	     
       SPARE4	=> 0);			     

   -- return types
   subtype RESULT_TYPE is INTEGER range -1 .. INTEGER'last;

   subtype STATUS_TYPE is INTEGER range -1 .. 1;

   -- LSEEK
   type LSEEK_WHENCE_TYPE is (L_SET, L_INCR, L_XTND);


   -- IOCTL
   type DACA_IOCTL_DATACTR is record
      OFFSET  : UNSIGNED_CHAR;
      VALUE   : UNSIGNED_CHAR;
   end record;
   
   subtype DACA_IOCTL_BASE is SHORT_INTEGER;
   subtype DACA_IOCTL_PORTDATA is SHORT_INTEGER;
   subtype DACA_IOCTL_DATADA is SHORT_INTEGER;
   subtype DACA_IOCTL_DATAAD is SHORT_INTEGER;
   subtype DACA_IOCTL_DIGIDATA is SHORT_INTEGER;

   type  DACA_IOCTL_INIT is record
      pcc_reg          : UNSIGNED_CHAR;  -- Pacer Clock Control
      pgc_reg          : UNSIGNED_CHAR;  -- Programmable Gain Control
      state_reg        : UNSIGNED_CHAR;  -- Status Register
      control_reg      : UNSIGNED_CHAR;  -- DMA, Interrupt, Trigger
      counter1         : UNSIGNED_CHAR;  -- Wert des Zaehlers 1 
      counter2         : UNSIGNED_CHAR;  -- Wert des Zaehlers 2 
      countcontrol_reg : UNSIGNED_CHAR;  -- Counter Controll Register
      portcontrol_reg  : UNSIGNED_CHAR;  -- Port Controll Register
      cd_reg           : UNSIGNED_CHAR;  -- Convert Disable Register
      me_reg           : UNSIGNED_CHAR;  -- Mode Enable Register
      bme_reg          : UNSIGNED_CHAR;  -- Burst Mode Enable Register
   end record;


   type DACA_IOCTL_GETCONF is record
      pgc_reg         : UNSIGNED_CHAR;   -- Programmable Gain Control
      state_reg       : UNSIGNED_CHAR;   -- Status Register
      control_reg     : UNSIGNED_CHAR;   -- DMA, Interrupt, Trigger
      counter1        : UNSIGNED_CHAR;   -- Wert des Zaehlers 1
      counter2        : UNSIGNED_CHAR;   -- Wert des Zaehlers 2
      countcon        : UNSIGNED_CHAR;   -- Counter Controll Register
      portcontrol_reg : UNSIGNED_CHAR;   -- Port Controll Register
      bs_reg          : UNSIGNED_CHAR;   -- Burst Status Register
   end record;

-- Konstanten fuer das IOCTL-Interface
   IOCPARM_MASK  : constant UNSIGNED_32 := 16#1fff#;
   IOC_VOID      : constant UNSIGNED_32 := 16#20000000#;
   IOC_IN        : constant UNSIGNED_32 := 16#80000000#;
   IOC_OUT       : constant UNSIGNED_32 := 16#40000000#;

   DACA_READ             : constant UNSIGNED_32 :=
   (IOC_OUT or ((2 and IOCPARM_MASK) * 16#ffff#) or (CHARACTER'POS('@') * 16#ff#) or 0);
   DACA_WRITE            : constant UNSIGNED_32 :=
   (IOC_IN or ((2 and IOCPARM_MASK) * 16#ffff#) or (CHARACTER'POS('@') * 16#ff#) or 1);
   DACA_SETBASE          : constant UNSIGNED_32 :=
   (IOC_IN or ((2 and IOCPARM_MASK) * 16#ffff#) or (CHARACTER'POS('@') * 16#ff#) or 2);
   DACA_INIT             : constant UNSIGNED_32 :=
   (IOC_IN or ((11 and IOCPARM_MASK) * 16#ffff#) or (CHARACTER'POS('@') * 16#ff#) or 3);
   DACA_GETCONF          : constant UNSIGNED_32 :=
   (IOC_OUT or ((8 and IOCPARM_MASK) * 16#ffff#) or (CHARACTER'POS('@') * 16#ff#) or 4);
   DACA_COUNTER_0_READ   : constant UNSIGNED_32 :=
   (IOC_OUT or ((2 and IOCPARM_MASK) * 16#ffff#) or (CHARACTER'POS('@') * 16#ff#) or 5);
   DACA_COUNTER_0_WRITE  : constant UNSIGNED_32 :=
   (IOC_IN or ((2 and IOCPARM_MASK) * 16#ffff#) or (CHARACTER'POS('@') * 16#ff#) or 6);

-- Konstanten fuer das Statusregister
   DACA_EOC    : constant UNSIGNED_32 :=  128;
   DACA_UNIPOL : constant UNSIGNED_32 :=  64;
   DACA_MUX    : constant UNSIGNED_32 :=  32;
   DACA_INT    : constant UNSIGNED_32 :=  16;
   DACA_CH0    : constant UNSIGNED_32 :=   0;
   DACA_CH1    : constant UNSIGNED_32 :=   1;
   DACA_CH2    : constant UNSIGNED_32 :=   2;
   DACA_CH3    : constant UNSIGNED_32 :=   3;
   DACA_CH4    : constant UNSIGNED_32 :=   4;
   DACA_CH5    : constant UNSIGNED_32 :=   5;
   DACA_CH6    : constant UNSIGNED_32 :=   6;
   DACA_CH7    : constant UNSIGNED_32 :=   7;
   DACA_CH8    : constant UNSIGNED_32 :=   8;
   DACA_CH9    : constant UNSIGNED_32 :=   9;
   DACA_CH10   : constant UNSIGNED_32 :=  10;
   DACA_CH11   : constant UNSIGNED_32 :=  11;
   DACA_CH12   : constant UNSIGNED_32 :=  12;
   DACA_CH13   : constant UNSIGNED_32 :=  13;
   DACA_CH14   : constant UNSIGNED_32 :=  14;
   DACA_CH15   : constant UNSIGNED_32 :=  15;

-- Konstanten fuer das DMA, INT und Trigger Control-Register
   DACA_INTE   : constant UNSIGNED_32 := 16#80#;
   DACA_INTR2  : constant UNSIGNED_32 := 16#20#;
   DACA_INTR3  : constant UNSIGNED_32 := 16#30#;
   DACA_INTR4  : constant UNSIGNED_32 := 16#40#;
   DACA_INTR5  : constant UNSIGNED_32 := 16#50#;
   DACA_INTR6  : constant UNSIGNED_32 := 16#60#;
   DACA_INTR7  : constant UNSIGNED_32 := 16#70#;
   DACA_DMAEN  : constant UNSIGNED_32 := 16#40#;
   DACA_TS0    : constant UNSIGNED_32 := 16#00#;     -- Softwaregetriggertes AD
   DACA_TS1    : constant UNSIGNED_32 := 16#02#;     -- Trigger mit DI0, Pin 25
   DACA_TS2    : constant UNSIGNED_32 := 16#03#;     -- Trigger mit Clock 

-- Gain-Kontroll-Register                           Bipolar    Unipolar   
   DACA_GAIN0 : constant UNSIGNED_32 := 16#00#; -- +/- 10V     0 - 10V
   DACA_GAIN1 : constant UNSIGNED_32 := 16#01#; -- +/-  1V     0 -  1V
   DACA_GAIN2 : constant UNSIGNED_32 := 16#02#; -- +/-  0.1V   0 -  0.1V
   DACA_GAIN3 : constant UNSIGNED_32 := 16#03#; -- +/-  0.01V  0 -  0.01V

   -- TCGETATTR & TCSETATTR
   --
   -- Special Control Characters 
   --
   -- Index into c_cc character array.
   --
   --	Name	     			Subscript	Enabled by

	VEOF	:constant integer :=	0;		-- ICANON 
	VEOL	:constant integer :=	1;		-- ICANON 
	VEOL2	:constant integer :=	2;		-- ICANON 
	VERASE	:constant integer :=	3;		-- ICANON 
	VWERASE :constant integer :=	4;		-- ICANON 
	VKILL	:constant integer :=	5;		-- ICANON 
	VREPRINT:constant integer := 	6;		-- ICANON 
        --   spare 1
	VINTR	:constant integer :=	8;		-- ISIG 
	VQUIT	:constant integer :=	9;		-- ISIG 
	VSUSP	:constant integer :=	10;		-- ISIG 
	VDSUSP	:constant integer :=	11;		-- ISIG 
	VSTART	:constant integer :=	12;		-- IXON, IXOFF 
	VSTOP	:constant integer :=	13;		-- IXON, IXOFF 
	VLNEXT	:constant integer :=	14;		-- IEXTEN 
	VDISCARD:constant integer :=	15;		-- IEXTEN 
	VFLUSH	:constant integer :=	VDISCARD;	 -- for sun 
	VMIN	:constant integer :=	16;		-- !ICANON 
	VTIME	:constant integer :=	17;		-- !ICANON 
	VSTATUS	:constant integer :=	18;		-- ISIG 
	--   spare 2 
	NCCS	:constant integer :=	19;     	-- number of ccs

   -- Input flags - software input processing

	IGNBRK		:constant UNSIGNED_32 :=    16#00000001#;	-- ignore BREAK condition
	BRKINT		:constant UNSIGNED_32 :=    16#00000002#;	-- map BREAK to SIGINTR
	IGNPAR		:constant UNSIGNED_32 :=    16#00000004#;	-- ignore (discard) parity errors
	PARMRK		:constant UNSIGNED_32 :=    16#00000008#;	-- mark parity and framing errors
	INPCK		:constant UNSIGNED_32 :=    16#00000010#;	-- disable checking of parity errors
	ISTRIP		:constant UNSIGNED_32 :=    16#00000020#;	-- strip 8th bit off chars
	INLCR		:constant UNSIGNED_32 :=    16#00000040#;	-- map NL into CR
	IGNCR		:constant UNSIGNED_32 :=    16#00000080#;	-- ignore CR
	ICRNL		:constant UNSIGNED_32 :=    16#00000100#;	-- map CR to NL (ala CRMOD)
	IXON		:constant UNSIGNED_32 :=    16#00000200#;	-- enable output flow control
	IXOFF		:constant UNSIGNED_32 :=    16#00000400#;	-- enable input flow control
	IXANY		:constant UNSIGNED_32 :=    16#00000800#;	-- any char will restart after stop
	IUCLC		:constant UNSIGNED_32 :=    16#00001000#;	-- DUMMY VALUE Map upper to lower
	IFLOW		:constant UNSIGNED_32 :=    IXON;		-- enable output flow control
	ITANDEM		:constant UNSIGNED_32 :=    IXOFF;		-- enable input flow control 
	IMAXBEL		:constant UNSIGNED_32 :=    16#00002000#;	-- ring bell on input queue full 


   -- Output flags - software output processing

	OPOST		:constant UNSIGNED_32 :=    16#00000001#;	-- enable following output processing
	ONLCR		:constant UNSIGNED_32 :=    16#00000002#;	-- map NL to CR-NL (ala CRMOD)
	OLCUC           :constant UNSIGNED_32 :=    16#00000004#;	-- Map lower case to upper on output
	OCRNL           :constant UNSIGNED_32 :=    16#00000008#;	-- Map CR to NL on output
	ONOCR           :constant UNSIGNED_32 :=    16#00000010#;	-- No CR output at column 0
	ONLRET          :constant UNSIGNED_32 :=    16#00000020#;	-- NL performs CR function 
	OFILL           :constant UNSIGNED_32 :=    16#00000040#;	-- Use fill characters for delay
	OFDEL           :constant UNSIGNED_32 :=    16#00000080#;	-- fill is DEL, else NUL 
	NLDLY		:constant UNSIGNED_32 :=    16#00000300#;	-- \n delay 
	   NL0		:constant UNSIGNED_32 :=    16#00000000#;
	   NL1		:constant UNSIGNED_32 :=    16#00000100#;	-- tty 37
	   NL2		:constant UNSIGNED_32 :=    16#00000200#;	-- vt05 
	   NL3		:constant UNSIGNED_32 :=    16#00000300#;
	TABDLY		:constant UNSIGNED_32 :=    16#00000c00#;	-- horizontal tab delay
	   TAB0		:constant UNSIGNED_32 :=    16#00000000#;
	   TAB1		:constant UNSIGNED_32 :=    16#00000400#;	-- tty 37 
	   TAB2		:constant UNSIGNED_32 :=    16#00000800#;
	   TAB3		:constant UNSIGNED_32 :=    16#00000C00#;	-- expand tabs on output 
	CRDLY		:constant UNSIGNED_32 :=    16#00003000#;	-- \r delay 
	   CR0		:constant UNSIGNED_32 :=    16#00000000#;
	   CR1		:constant UNSIGNED_32 :=    16#00001000#;	-- tn 300 
	   CR2		:constant UNSIGNED_32 :=    16#00002000#;	-- tty 37 
	   CR3		:constant UNSIGNED_32 :=    16#00003000#;	-- concept 100
	FFDLY           :constant UNSIGNED_32 :=    16#00004000#;	-- Form feed delay
	   FF0		:constant UNSIGNED_32 :=    16#00000000#;
	   FF1		:constant UNSIGNED_32 :=    16#00004000#;
	BSDLY		:constant UNSIGNED_32 :=    16#00008000#;	-- \b delay
	   BS0		:constant UNSIGNED_32 :=    16#00000000#;
	   BS1		:constant UNSIGNED_32 :=    16#00008000#;
	VTDLY		:constant UNSIGNED_32 :=    16#00010000#;	-- vertical tab delay 
	   VT0		:constant UNSIGNED_32 :=    16#00000000#;
	   VT1		:constant UNSIGNED_32 :=    16#00010000#;	-- tty 37
	ONLCRNL		:constant UNSIGNED_32 :=    ONLCR;
	OXTABS		:constant UNSIGNED_32 :=    16#00040000#;	-- expand tabs to spaces 
	ONOEOT		:constant UNSIGNED_32 :=    16#00080000#;	-- discard EOT's (^D) on output) 

   -- Control flags - hardware control of terminal

	CSIZE		:constant UNSIGNED_32 :=    16#00000300#;	-- character size mask 
	     CS5	:constant UNSIGNED_32 :=    16#00000000#;   	-- 5 bits (pseudo) 
	     CS6	:constant UNSIGNED_32 :=    16#00000100#;   	-- 6 bits 
	     CS7	:constant UNSIGNED_32 :=    16#00000200#;   	-- 7 bits 
	     CS8	:constant UNSIGNED_32 :=    16#00000300#;   	-- 8 bits 
	CSTOPB		:constant UNSIGNED_32 :=    16#00000400#;	-- send 2 stop bits 
	CREAD		:constant UNSIGNED_32 :=    16#00000800#;	-- enable receiver 
	PARENB		:constant UNSIGNED_32 :=    16#00001000#;	-- parity enable 
	PARODD		:constant UNSIGNED_32 :=    16#00002000#;	-- odd parity, else even 
	HUPCL		:constant UNSIGNED_32 :=    16#00004000#;	-- hang up on last close 
	CLOCAL		:constant UNSIGNED_32 :=    16#00008000#;	-- ignore modem status lines 
	CRTSCTS		:constant UNSIGNED_32 :=    16#00010000#;	-- RTS/CTS flow control 


   -- "Local" flags - dumping ground for other state
   --
   -- Warning: some flags in this structure begin with
   -- the letter "I" and look like they belong in the
   -- input flag.

	ECHOE		:constant UNSIGNED_32 :=    16#00000002#;	-- visually erase chars
	ECHOK		:constant UNSIGNED_32 :=    16#00000004#;	-- echo NL after line kill
	ECHO		:constant UNSIGNED_32 :=    16#00000008#;	-- enable echoing 
	ECHONL		:constant UNSIGNED_32 :=    16#00000010#;	-- echo NL even if ECHO is off
	ISIG		:constant UNSIGNED_32 :=    16#00000080#;	-- enable signals INTR, QUIT, [D]SUSP
	ICANON		:constant UNSIGNED_32 :=    16#00000100#;	-- canonicalize input lines 
	IEXTEN		:constant UNSIGNED_32 :=    16#00000400#;	-- enable FLUSHO and LNEXT
	NOFLSH		:constant UNSIGNED_32 :=    16#80000000#;	-- don't flush after interrupt
	TOSTOP		:constant UNSIGNED_32 :=    16#00400000#;	-- stop background jobs from output 
	XCASE		:constant UNSIGNED_32 :=    16#00004000#;	-- Cononical upper/lower presentation
	ECHOKE		:constant UNSIGNED_32 :=    16#00000001#;	-- visual erase for line kill
	ECHOPRT		:constant UNSIGNED_32 :=    16#00000020#;	-- visual erase mode for hardcopy
	ECHOCTL  	:constant UNSIGNED_32 :=    16#00000040#;	-- echo control chars as ^(Char)
	ALTWERASE	:constant UNSIGNED_32 :=    16#00000200#;	-- use alternate WERASE algorithm 
	MDMBUF		:constant UNSIGNED_32 :=    16#00100000#;	-- flow control output via Carrier
	FLUSHO		:constant UNSIGNED_32 :=    16#00800000#;	-- output being flushed (state)
	NOHANG		:constant UNSIGNED_32 :=    16#01000000#;	-- XXX this should go away 
	PENDIN		:constant UNSIGNED_32 :=    16#20000000#;	-- retype pending input (state)
	NOKERNINFO      :constant UNSIGNED_32 :=    16#40000000#;	-- Disable printing kernel info 


   -- * Commands passed to tcsetattr() for setting the termios structure.

	TCSANOW		:constant Interfaces.C.INT :=    0;			-- make change immediate 
	TCSADRAIN	:constant Interfaces.C.INT :=    1;			-- drain output, then change
	TCSAFLUSH	:constant Interfaces.C.INT :=    2;			-- drain output, flush input


   -- values for the queue_selector argument to tcflush()

	TCIFLUSH        :constant Interfaces.C.INT :=    0;
	TCOFLUSH        :constant Interfaces.C.INT :=    1;
	TCIOFLUSH       :constant Interfaces.C.INT :=    2;


   -- values for the action argument to tcflow()

	TCOOFF          :constant Interfaces.C.INT :=    0;
	TCOON           :constant Interfaces.C.INT :=    1;
	TCIOFF          :constant Interfaces.C.INT :=    2;
	TCION           :constant Interfaces.C.INT :=    3;


   -- Standard speeds

   type SPEED_T is new Interfaces.C.UNSIGNED;
        
	B0		:constant SPEED_T :=    0;
	B50		:constant SPEED_T :=    50;
	B75		:constant SPEED_T :=    75;
	B110		:constant SPEED_T :=    110;
	B134		:constant SPEED_T :=    134;
	B150		:constant SPEED_T :=    150;
	B200		:constant SPEED_T :=    200;
	B300		:constant SPEED_T :=    300;
	B600		:constant SPEED_T :=    600;
	B1200		:constant SPEED_T :=    1200;
	B1800		:constant SPEED_T :=    1800;
	B2400		:constant SPEED_T :=    2400;
	B4800		:constant SPEED_T :=    4800;
	B9600		:constant SPEED_T :=    9600;
	B19200		:constant SPEED_T :=    19200;
	B38400		:constant SPEED_T :=    38400;
	EXTA		:constant SPEED_T :=    19200;
	EXTB		:constant SPEED_T :=    38400;


   --
   -- Ioctl control packet
   --
   type CC_ARRAY_T is array(0..NCCS-1) of UNSIGNED_CHAR;

   type TERMIOS_T is
      record
         c_iflag : UNSIGNED_32;	-- input flags
         c_oflag : UNSIGNED_32;	-- output flags 
         c_cflag : UNSIGNED_32;	-- control flags
         c_lflag : UNSIGNED_32;	-- local flags 
         c_cc    : CC_ARRAY_T;	-- control chars
         c_ispeed: SPEED_T;	-- input speed 
         c_ospeed: SPEED_T;	-- output speed 
      end record;

   for TERMIOS_T use
      record at mod 8;
         c_iflag   at  0 range 0..31;
         c_oflag   at  4 range 0..31;
         c_cflag   at  8 range 0..31; 
         c_lflag   at 12 range 0..31; 
         c_cc      at 16 range 0..8*NCCS-1; 
         c_ispeed  at 36 range 0..31;
         c_ospeed  at 40 range 0..31;
      end record;
   for TERMIOS_T'SIZE use 352;

   function CLOSE(FD : in  FILE_DESCRIPTOR_TYPE) return STATUS_TYPE;
          pragma Import(C,CLOSE,"close");

    function DUP (OLDD	: in  FILE_DESCRIPTOR_TYPE)
                  return FILE_DESCRIPTOR_TYPE;
          pragma Import(C,DUP,"dup");
             
    function DUP2(OLDD	: in  FILE_DESCRIPTOR_TYPE;
	          NEWD	: in  FILE_DESCRIPTOR_TYPE)
                  return RESULT_TYPE;
          pragma Import(C,DUP2,"dup2");
 

    function FCNTL (FD	     : in  FILE_DESCRIPTOR_TYPE;
	            REQUEST  : in  INTEGER;
	            ARGUMENT : in  SYSTEM.ADDRESS) 
                    return RESULT_TYPE;
          pragma Import(C,FCNTL,"fcntl");
 

    procedure FSTAT(FD	   : in  FILE_DESCRIPTOR_TYPE;
	            BUF	   : access STAT_TYPE);
          pragma Import(C,FSTAT,"fstat");
 


    function LSEEK(FD	  : in  FILE_DESCRIPTOR_TYPE;
	           OFFSET : in  INTEGER;
	           WHENCE : in  LSEEK_WHENCE_TYPE) return RESULT_TYPE;
           pragma Import(C,LSEEK,"lseek");
 

    function OPEN(PATH	: in  string;
	          FLAGS	: in  OPEN_FLAGS_TYPE;
	          MODE	: in  FILE_PERMISSION_TYPE)
		  return FILE_DESCRIPTOR_TYPE;
           pragma Import(C,OPEN,"open");

  
    function READ(FD     : in  FILE_DESCRIPTOR_TYPE;
	          BUF	 : in  SYSTEM.ADDRESS;
	          NBYTES : in  INTEGER) 
                  return RESULT_TYPE;
           pragma Import(C,READ,"read");
 


    function STAT(PATH   : in  string;
	           BUF    : in SYSTEM.ADDRESS) 
	           return RESULT_TYPE;
           pragma Import(C,STAT,"stat");



    function UNLINK(PATH : in  STRING) return STATUS_TYPE;
           pragma Import(C,UNLINK,"unlink");
 


    function WRITE(FD	  : in  FILE_DESCRIPTOR_TYPE;
	           BUF    : in  SYSTEM.ADDRESS;
	           NBYTES : in  INTEGER) 
                   return RESULT_TYPE;
 
           pragma Import(C,WRITE,"write");



    function IOCTL(FD      : in  FILE_DESCRIPTOR_TYPE;
                   REQUEST : in  UNSIGNED_32;
                   BUF     : in  SYSTEM.ADDRESS)
                   return STATUS_TYPE;
           pragma Import(C,IOCTL,"ioctl");


    function GETPID return INTEGER;
           pragma Import(C,GETPID,"getpid");



    function GETENV(N : STRING; DEFAULT : STRING) return STRING;

    function GETCWD return STRING;

    function ISATTY(FD : in  FILE_DESCRIPTOR_TYPE) return STATUS_TYPE;
           pragma Import(C,ISATTY,"isatty");


    function TTYNAME(FD : in  FILE_DESCRIPTOR_TYPE) return STRING;
    
    function FTRUNCATE(FD   : in  FILE_DESCRIPTOR_TYPE;
                       SIZE : in INTEGER ) return STATUS_TYPE;
           pragma Import(C,FTRUNCATE,"ftruncate");



   function TCGETATTR(FILEDES: FILE_DESCRIPTOR_TYPE;
		      TERMINAL_SETTINGS:  SYSTEM.ADDRESS) 
                      return STATUS_TYPE;
           pragma Import(C,TCGETATTR,"tcgetattr");


   function TCSETATTR(FILEDES: FILE_DESCRIPTOR_TYPE;
                      ACTION: Interfaces.C.INT;
                      TERMINAL_SETTINGS: SYSTEM.ADDRESS)
                      return STATUS_TYPE; 
           pragma Import(C,TCSETATTR,"tcsetattr");


   function TCSENDBREAK(FILEDES: FILE_DESCRIPTOR_TYPE; DURATION: Interfaces.C.INT) return STATUS_TYPE;
      pragma INTERFACE(C, TCSENDBREAK);

   function TCDRAIN(FILEDES: FILE_DESCRIPTOR_TYPE) return STATUS_TYPE;
      pragma INTERFACE(C, TCDRAIN);

   function TCFLUSH(FILEDES: FILE_DESCRIPTOR_TYPE; QUEUE_SELECTOR: Interfaces.C.INT) return STATUS_TYPE;
      pragma INTERFACE(C, TCFLUSH);

   function TCFLOW(FILEDES: FILE_DESCRIPTOR_TYPE; ACTION: Interfaces.C.INT) return RESULT_TYPE;
      pragma INTERFACE(C, TCFLOW);
  
end OSF_IO;
