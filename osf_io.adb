-----------------------------------------------------------------------------
-- FILE    : osf_io.ada
-- DATUM   : 09.09.94
-- AUTOREN : P. Lang, T. Zehnder
--
-- Revision History
--
--    - 03.10.96, R.Barandun & C.Werder
--      Package portiert fuer GNAT Ada95
-----------------------------------------------------------------------------
with SYSTEM, Interfaces.C, Interfaces.C.Strings;
use  SYSTEM, Interfaces.C, Interfaces.C.Strings;

Package body OSF_IO is

   function TO_LENGTH(ADDR : ADDRESS) return NATURAL is
      VALU : STRING(1..INTEGER'last); for VALU use at ADDR;
   begin
      for I in VALU'range loop
	 if VALU(I) = ASCII.NUL then
            return I-VALU'first;
	 end if;
      end loop;
      return VALU'length;
   end TO_LENGTH;

   function GETCWD return STRING is
      function GETWD(BUF : ADDRESS) return ADDRESS;
          pragma Import(C,GETWD,"getwd");
      MAX_FILE_NAME_SIZE : constant integer := 1300; 
   begin
      declare   
         PATHNAME : STRING(1..MAX_FILE_NAME_SIZE);
      begin
         if GETWD(PATHNAME'address) /= ADDRESS_ZERO then
	    return PATHNAME(1..TO_LENGTH(PATHNAME'address));
         end if;
      end;
      return "./";
   end GETCWD;


   function GETENV(N : STRING; DEFAULT : STRING) return STRING is
      function GETENV(N : STRING) return ADDRESS;
         pragma Import(C, GETENV, "getenv");
      ADDR : ADDRESS := GETENV(N);
   begin
      if ADDR = ADDRESS_ZERO then
	 return DEFAULT;
      else
	 declare
	    VALU : STRING(1..TO_LENGTH(ADDR)); for VALU'address use ADDR'address;
         begin
	    return VALU;
	 end;
      end if;
   end;

   function TTYNAME(FD : in FILE_DESCRIPTOR_TYPE) return STRING is
       function TTYNAME(FD : in  FILE_DESCRIPTOR_TYPE) return ADDRESS;
          pragma Import(C, TTYNAME, "ttyname");
      ADDR : ADDRESS := TTYNAME(FD);
   begin
      if ADDR = ADDRESS_ZERO then
	 return "not a tty";
      else
	 declare
	    VALU : STRING(1..TO_LENGTH(ADDR)); for VALU'address use ADDR'address;
         begin
	    return VALU;
	 end;
      end if;
   end;

end OSF_IO;
