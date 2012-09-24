-----------------------------------------------------------------------------
-- FILE    : rob3.ada
-- DATUM   : 09.09.94
-- AUTOREN : P. Lang, T. Zehnder
-- ZWECK   : Das Package ROB3 implementiert die Ansteuerungsfunktionen fuer 
--           den Roboter ROB3 der Firma P+P Elektronik GmbH Nuernberg ueber
--           die serielle Schnittstelle 2 ( /dev/tty01 ) des DEC Alpha 2000 
--           Model 300 Rechners unter OSF/1 und verwendet hierzu POSIX 
--           kompatible Aufrufe zur Konfiguration der Schnittstelle
-----------------------------------------------------------------------------
with OSF_IO, SYSTEM, Interfaces.C;
use  OSF_IO, SYSTEM, Interfaces.C;

package body ROB3 is

   fd            : FILE_DESCRIPTOR_TYPE; -- File Descriptor fuer Roboter
   settings,                             -- Einstellungen der seriellen 
   old_settings  : TERMIOS_T;            -- Schnittstelle 
   
    -- Roboter-Befehle   
   
   I_INIT        : constant UNSIGNED_CHAR := 16#20#;
   I_SET_POS     : constant UNSIGNED_CHAR := 16#07#;
   I_SET_POS_ALL : constant UNSIGNED_CHAR := 16#0F#;
   I_V           : constant UNSIGNED_CHAR := 16#77#;
   I_V_ALL       : constant UNSIGNED_CHAR := 16#7F#;
   I_READ_POS    : constant UNSIGNED_CHAR := 16#3F#;
   I_READ_POS_ALL: constant UNSIGNED_CHAR := 16#47#;
   
   -- Kommunikationsbytes 

   ETX       : constant UNSIGNED_CHAR := character'pos(ascii.etx);
   NAK       : constant UNSIGNED_CHAR := character'pos(ascii.nak);
   NEXEC     : constant UNSIGNED_CHAR := 16#F1#;  -- command not executed
  
   type BYTE_ARRAY is array(INTEGER range <>) of UNSIGNED_CHAR;

   procedure INIT_ROB(success: out boolean) is
      ret  : OSF_IO.RESULT_TYPE;
      buf  : BYTE_ARRAY(1..1):= (I_INIT, others => 0);
   begin
      success := true;
      fd := open(DEV_NAME, O_RDWR or O_NOCTTY, 0);
      if ( integer(fd) < 0) then
         -- Es konnte kein Filedescriptor auf das File erzeugt werden.
         success := false;
         return;
      end if;
      -- Alte Einstellungen der Terminalline (Seriellen Schnittstelle) speichern
      -- und neu Konfiguration setzen.
      ret := tcgetattr(fd, old_settings'address);
      ret := tcgetattr(fd, settings'address);
      settings.c_iflag     := 0;
      settings.c_oflag     := 0;
      settings.c_cflag     := CS8 or CSTOPB or CREAD or HUPCL or CLOCAL;
      settings.c_lflag     := 0;
      settings.c_cc(VMIN)  := 0;
      settings.c_cc(VTIME) := 20;
      settings.c_ispeed    := B9600;
      settings.c_ospeed    := B9600;
      ret := tcsetattr(fd, TCSANOW, settings'address);
      if (integer(ret) < 0 ) then
         -- Die neuen Terminaleinstellungen konnten nicht geschrieben werden.
         success := false;
         ret := close(fd);
         return;
      end if;
      -- Initialisierung des Roboters
      ret := tcflush(fd, TCIOFLUSH);
      ret := write(fd, buf'address, 1);
      ret := read(fd, buf'address, 1);
      if (ret /= 1) or (( buf(1) /= NAK) and ( buf(1) /= NEXEC )) then
         -- Der Roboter konnte nicht initialisiert werden
         success := false;
         ret := tcsetattr(fd, TCSANOW, old_settings'address);
         ret := close(fd);
         return;
      end if;
      -- Setze neue Timeoutzeit fuer Inter-Character-Timeout
      settings.c_cc(VTIME) := 3;
      ret := tcsetattr(fd, TCSANOW, settings'address);
      ret := tcflush(fd, TCIOFLUSH);
   end INIT_ROB;
 
   procedure TERMINATE_COMMUNICATIONS is
      ret: OSF_IO.RESULT_TYPE;
   begin
      -- Zurueckschreiben der alten Terminaleinstellung der seriellen Schnittstelle
      ret := tcsetattr(fd, TCSANOW, old_settings'address);
      -- Schliessen des File Descriptors
      ret := close(fd);
   end TERMINATE_COMMUNICATIONS;

   procedure SET_POS(achse  : in  ACHSEN_TYPE; 
                     pos    : in  POS_TYPE;
                     success: out boolean) is 
      buf:  BYTE_ARRAY(1..3);
      ret:  OSF_IO.RESULT_TYPE;
   begin
      ret := tcflush(fd, TCIOFLUSH);
      buf(1) := I_SET_POS + UNSIGNED_CHAR(achse);   
      buf(2) := UNSIGNED_CHAR(pos);
      buf(3) := ETX;
      ret := write(fd, buf'address, 3);
      settings.c_cc(VMIN) := 2;
      ret := tcsetattr(fd, TCSANOW, settings'address);
      ret := read(fd, buf'address, 2);
      if (ret = 2) and (buf(1) = I_SET_POS + UNSIGNED_CHAR(achse)) then
         success := true;
      else
         success := false;
      end if;
   end SET_POS;

   procedure SET_POS_ALL(pos_array    : in  pos_array_type;
                         success      : out boolean) is
      buf : BYTE_ARRAY(1..pos_array'last+2);
      ret : RESULT_TYPE;
   begin
      ret := tcflush(fd, TCIOFLUSH);
      buf(1)    := I_SET_POS_ALL;  
      for i in pos_array'range loop 
         buf(i+1) := UNSIGNED_CHAR(pos_array(i));
      end loop;
      buf(pos_array'last+2)    := ETX;
      ret := write(fd, buf'address, pos_array'last+2);
      settings.c_cc(VMIN) := 2;
      ret := tcsetattr(fd, TCSANOW, settings'address);
      ret := read(fd, buf'address, 2);
      if (ret = 2) and (buf(1) = I_SET_POS_ALL) then
         success := true;
      else
         success := false;
      end if;
   end SET_POS_ALL;
   
   procedure SET_POS_V(achse  : in  ACHSEN_TYPE; 
                       pos    : in  POS_TYPE;
                       geschw : in  GESCHW_TYPE;
                       success: out boolean) is 
      buf : BYTE_ARRAY(1..4);
      ret : RESULT_TYPE;
   begin
      ret := tcflush(fd, TCIOFLUSH);
      buf(1) := I_V + UNSIGNED_CHAR(achse);   
      buf(2) := UNSIGNED_CHAR(pos);
      buf(3) := UNSIGNED_CHAR(geschw);
      buf(4) := ETX;
      ret := write(fd, buf'address, 4);
      settings.c_cc(VMIN) := 2;
      ret := tcsetattr(fd, TCSANOW, settings'address);
      ret := read(fd, buf'address, 2);
      if (ret = 2) and (buf(1) = I_V + UNSIGNED_CHAR(achse)) then
         success := true;
      else
         success := false;
      end if;
   end SET_POS_V;

   procedure SET_POS_ALL_V(pos_array    : in  pos_array_type;
                           geschw_array : in  geschw_array_type;
                           success      : out boolean) is
      buf : BYTE_ARRAY(1..pos_array'last+geschw_array'last+2);
      ret : RESULT_TYPE;
   begin
      ret := tcflush(fd, TCIOFLUSH);
      buf(1)    := I_V_ALL;   
      for i in pos_array'range loop
         buf(i+1) := UNSIGNED_CHAR(pos_array(i));
      end loop;
      for i in geschw_array'range loop
         buf(1+pos_array'last+i):= UNSIGNED_CHAR(geschw_array(i));
      end loop;
      buf(pos_array'last+geschw_array'last+2) := ETX;
      ret := write(fd, buf'address, pos_array'last+geschw_array'last+2);
      settings.c_cc(VMIN) := 2;
      ret := tcsetattr(fd, TCSANOW, settings'address);
      ret := read(fd, buf'address, 2);
      if (ret = 2) and (buf(1) = I_V_ALL) then
         success := true;
      else
         success := false;
      end if;
   end SET_POS_ALL_V;

   procedure READ_POS(achse    : in  ACHSEN_TYPE;
                      position : out POS_TYPE;
                      success  : out boolean) is
      buf : BYTE_ARRAY(1..3);
      ret : RESULT_TYPE;
   begin
      ret := tcflush(fd, TCIOFLUSH);
      buf(1) := I_READ_POS + UNSIGNED_CHAR(achse);
      buf(2) := ETX;
      ret := write(fd, buf'address, 2);
      settings.c_cc(VMIN) := 3;
      ret := tcsetattr(fd, TCSANOW, settings'address);
      ret := read(fd, buf'address, 3);
      if (ret = 3) and (buf(1) = I_READ_POS + UNSIGNED_CHAR(achse)) then
         position := INTEGER(buf(2));
         success := true;
      else 
         success := false;
      end if;
   end READ_POS;

   procedure READ_POS_ALL(pos_array  : out pos_array_type; 
                          success    : out boolean) is
      buf : BYTE_ARRAY(1..pos_array'last+2);
      ret : RESULT_TYPE;
   begin
      ret := tcflush(fd, TCIOFLUSH);
      buf(1) := I_READ_POS_ALL;
      buf(2) := ETX;
      ret := write(fd, buf'address, 2);
      settings.c_cc(VMIN) := 8;
      ret := tcsetattr(fd, TCSANOW, settings'address);
      ret := read(fd, buf'address, 8);
      if (ret = 8) and (buf(1) = I_READ_POS_ALL) then
         for i in pos_array'range loop
            pos_array(i) := INTEGER(buf(I+1));
         end loop;
         success := true;
      else 
         success := false;
      end if;
   end READ_POS_ALL;

end rob3;
