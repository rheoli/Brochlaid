-------------------------------------------------------------------------------
--  DACA
-------------------------------------------------------------------------------
--
--  File-Name  : daca_.ada
--
--  Author     : M. Wirz, J. Liechti
--  Department : HTL Brugg-Windisch, Diplomarbeit Ada-Real-Time-System
--  Date       : 06.09.1994
--
--  Purpose    : Package fuer A/D - D/A Wandler
--
--  How to use this Package :
--                 Das Package stellt die beiden Prozeduren DA_WRITE und 
--                 AD_READ zur Verfuegung. Mit diesen Prozeduren koennen
--                 Float-Wert im Bereich von -10.0 bis 10.0 als Spannung
--                 in Volt ausgegeben respektive gelesen werden.
--
--  Exceptions : --
--
--  Revision History : - erstellt am 06.09.1994
--
--                     - 3.10.1994 Portierung auf OSF/1 durch Patrick Lang
--
--                     - 3.10.1996 Portierung fuer GNAT Ada95 durch C.Werder
--
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
with OSF_IO;
use  OSF_IO;


package DACA is

   ----------------------------------------------------------------------------
   --  READ_AD
   ----------------------------------------------------------------------------
   --  Purpose    : Liest einen Wert zwischen -10 und +10 vom A/D-Wandler.
   ----------------------------------------------------------------------------
   procedure READ_AD (FD      : in FILE_DESCRIPTOR_TYPE;
                      WERT    : out FLOAT);

   ----------------------------------------------------------------------------
   --  WIRTE_DA
   ----------------------------------------------------------------------------
   --  Purpose    : Gibt einen Wert zwischen -10 V und +10 V auf dem
   --               angegebenen Kanal aus. Ist WERT > 10, so wird +10 V
   --               ausgegeben, ist er < -10, so wird -10 V ausgegeben.
   ----------------------------------------------------------------------------
   procedure WRITE_DA (FD      : in FILE_DESCRIPTOR_TYPE;
                       WERT    : in FLOAT);

end DACA;

