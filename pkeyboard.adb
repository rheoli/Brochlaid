--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      25. Juni 1997                                          ==
--==   Modul:      pkeyboard.adb                                          ==
--==   Verwendung: Tastatureingabeverarbeitung                            ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================
--==                                                                      ==
--== Brochlaid is free software; you can redistribute it and/or modify    ==
--== it under the terms of the GNU General Public License as published by ==
--== the Free Software Foundation; either version 2 of the License, or    ==
--== (at your option) any later version.                                  ==
--==                                                                      ==
--== This program is distributed in the hope that it will be useful,      ==
--== but WITHOUT ANY WARRANTY; without even the implied warranty of       ==
--== MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        ==
--== GNU General Public License for more details (File COPYING).          ==
--==                                                                      ==
--== You should have received a copy of the GNU General Public License    ==
--== along with this program; if not, write to the Free Software          ==
--== Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.            ==
--==                                                                      ==
--==========================================================================


with Ada.text_io, int_io, SYSTEM, pscreen;
use  Ada.text_io, int_io, SYSTEM, pscreen;

package body pkeyboard is
  function getChar_Import return integer;
  pragma Import ( C, getChar_Import, "getchar" );
  function getCharInBuff_Import return integer;
  pragma Import ( C, getCharInBuff_Import, "getCharInBuff" );

  -- Typen:
  --- 0: kein Zeichen vorhanden; falsches Zeichen
  --- 1: normales ASCII Zeichen
  --- 2: CTRL-Zeichen
  --- 3: ALT-Zeichen
  --- 4: Cursor Befehle

  protected body poKeyboard is
    procedure getKey ( iType : out integer; iKey : out integer ) is
      kMaxKeyRead : constant integer := 8;
      iaKeyBuffer : array(1..kMaxKeyRead) of integer;
      iDummy      : integer := 0;
      iKeys       : integer := 0;
    begin
      iKeys := getCharInBuff_Import;
      iKey  := 0;
      iType := 0;
      if ( iKeys = 0 ) then
        return;
      end if;
      
      for i in 1..iKeys loop
        if ( i < kMaxKeyRead ) then
          iaKeyBuffer(i) := getChar_Import;
        else
          iDummy         := getChar_Import;
        end if;
      end loop;

      if ( iKeys = 1 ) then
        iType := 1;
        iKey  := iaKeyBuffer(1);
        return;
      end if;
      if ( (iKeys=2) and then (iaKeyBuffer(1)=27) )  then
        iType := 3;
        iKey  := iaKeyBuffer(2);
        return;
      end if;
      if ( iKeys = 3 ) and then (iaKeyBuffer(1)=27 and iaKeyBuffer(2)=91) then
        -- Cursor Type
        iType := 4;
        if ( iaKeyBuffer(3) = 65 ) then
          -- Cursor Up
          iKey := 1;                  
        elsif ( iaKeyBuffer(3) = 66 ) then
          -- Cursor Down
          iKey := 2;
        elsif ( iaKeyBuffer(3) = 67 ) then
          -- Cursor rechts
          iKey := 3;
        elsif ( iaKeyBuffer(3) = 68 ) then
          -- Cursor links
          iKey := 4;
        end if;
        return;
      end if;
      if ( (iKeys=4) and then (iaKeyBuffer(1)=27) and then (iaKeyBuffer(2)=91) and then (iaKeyBuffer(4)=126) ) then
        iType := 4;
        if ( iaKeyBuffer(3) = 53 ) then
          -- <PgUp>
          iKey := 5;
        elsif ( iaKeyBuffer(3) = 54 ) then
          -- <PgDn>
          iKey := 6;
        elsif ( iaKeyBuffer(3) = 50 ) then
          -- <Insert>
          iKey := 7;
        elsif ( iaKeyBuffer(3) = 51 ) then
          -- <Delete>
          iKey := 8;
        end if;
        return;
      end if;
      iType := 0;
      iKey  := 0;  
    end;
  end poKeyboard;  
end pkeyboard;
