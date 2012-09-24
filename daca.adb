-------------------------------------------------------------------------------
--  DACA
-------------------------------------------------------------------------------
--
--  File-Name  : daca.ada
--
--  Author     : M. Wirz, J. Liechti
--  Department : HTL Brugg-Windisch, Diplomarbeit Ada-Real-Time-System
--  Date       : 06.09.1994
--
--  Implementation Notes : --
--
--  Portability Issues :
--     Das Package benoetigt eine Data-Aquisition-Card.
--
--
--  Revision History : - erstellt am 06.09.1994
--
--                     - 3.10.1994 Portierung auf OSF/1 durch Patrick Lang
--
--                     - 3.10.1996 Portierung fuer GNAT Ada95 durch C.Werder
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

with OSF_IO, SYSTEM;
use  OSF_IO, SYSTEM;

package body DACA is

   MAX_IN      : constant FLOAT         := 10.0;
   MIN_IN      : constant FLOAT         := -10.0;
   DIFF_IN     : constant FLOAT         := MAX_IN - MIN_IN;
   MAX_OUT     : constant SHORT_INTEGER := 4095;
   MIN_OUT     : constant SHORT_INTEGER := 0;
   DIFF_OUT    : constant SHORT_INTEGER := MAX_OUT - MIN_OUT;
   FAKTOR      : constant FLOAT         := FLOAT (DIFF_OUT) / DIFF_IN;


   ----------------------------------------------------------------------------
   --  READ_AD
   ----------------------------------------------------------------------------
   procedure READ_AD (FD      : in FILE_DESCRIPTOR_TYPE;
                      WERT    : out FLOAT) is

      READ_VALUE     : SHORT_INTEGER;
      ret            : RESULT_TYPE;
   begin
      ret      := read(FD, READ_VALUE'address, 2); 
      WERT     := FLOAT ((READ_VALUE - MIN_OUT)) / FAKTOR + MIN_IN;
   end READ_AD;


   ----------------------------------------------------------------------------
   --  WRITE_DA
   ----------------------------------------------------------------------------
   procedure WRITE_DA (FD      : in FILE_DESCRIPTOR_TYPE;
                       WERT    : in FLOAT) is

      TMP_DATA       : SHORT_INTEGER;
      DATA           : SHORT_INTEGER;
      ret            : RESULT_TYPE;

   begin
      TMP_DATA := SHORT_INTEGER ((WERT - MIN_IN) * FAKTOR) + MIN_OUT;
      case TMP_DATA is
         when SHORT_INTEGER'FIRST .. - 1 =>
            DATA :=  SHORT_INTEGER(0);
         when 0 .. 4095 =>
            DATA :=  SHORT_INTEGER(TMP_DATA);
         when others =>
            DATA :=  SHORT_INTEGER(4095);
      end case;

      ret := write(FD, DATA'ADDRESS, 2);
   end WRITE_DA;

end DACA;

