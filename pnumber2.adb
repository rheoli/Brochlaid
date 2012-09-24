--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      23. Juni 1997                                          ==
--==   Modul:      pnumber2.adb                                           ==
--==   Verwendung: Nummereingabe-Element fuer CUI mit                     ==
--==               Geschwindigkeitseingabe                                ==
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

with Ada.Text_io, Ada.calendar, int_io, pscreen;
use  Ada.Text_io, Ada.calendar, int_io, pscreen;

package body pnumber2 is

  protected body ptoNumber2 is
    procedure start ( x : in integer; y : in integer; s : in integer; m : in integer; d : in integer; t : in integer ) is
    begin
      fStarted    := true;
      fFocus      := false;
      iX          := x;
      iY          := y;
      tLastPaint  := Clock;
      tLastChange := Clock;
      iAnzStellen := s;
      iPos        := 1;
      iTNumber    := t;
      put ( strMaxNumber(1..s), m );
      put ( strNumber(1..s), d );
      for i in 1..s loop
        if ( strMaxNumber(i) = ' ' ) then
          strMaxNumber(i) := '0';
        end if;
        if ( strNumber(i) = ' ' ) then
          strNumber(i) := '0';
        end if;
      end loop;
      if ( strMaxNumber(1..s) < strNumber(1..s) ) then
        strNumber(1..s) := strMaxNumber(1..s);
      end if;
    end;

    procedure refresh ( fRet : out boolean ) is
    begin
      if ( not fStarted ) then
        raise NUMBER2_not_initialized;
      end if;
      if ( tLastChange > tLastPaint ) then
        tLastPaint := Clock;
        fRet       := true;
        return;
      end if;
      fRet := false;
    end;        

    procedure print is
      strSpace : string(1..80) := (OTHERS => ' ');
      fRet     : boolean       := false;
    begin
      if ( not fStarted ) then
        raise NUMBER2_not_initialized;
      end if;
      if ( fFocus ) then
        poScreen.paintInversTwinWindow ( iX, iY-1, iAnzStellen+2, 3, iAnzStellen+4 );
        poScreen.putStringXY ( iX+1, iY, strNumber(1..iAnzStellen) );        
        poScreen.putInversCharXY ( iX+iPos, iY, CHARACTER'POS(strNumber(iPos)) );
      else
        poScreen.paintTwinWindow ( iX, iY-1, iAnzStellen+2, 3, iAnzStellen+4 );
        poScreen.putStringXY ( iX+1, iY, strNumber(1..iAnzStellen) );
      end if;
      poScreen.putCharXY ( iX+iAnzStellen+2, iY, iTNumber+CHARACTER'POS('0') );
    end;

    procedure focusOn is
    begin
      tLastChange := Clock;
      fFocus      := true;
    end;

    procedure focusOff is
    begin
      tLastChange := Clock;
      fFocus      := false;
    end;
    
    procedure cursorRight is
    begin
      if ( not fStarted ) then
        raise NUMBER2_not_initialized;
      end if;
      if ( not fFocus ) then
        return;
      end if;
      if ( iPos < iAnzStellen ) then
        iPos := iPos + 1;
      end if;
      print;
    end;
    
    procedure cursorLeft is
    begin
      if ( not fStarted ) then
        raise NUMBER2_not_initialized;
      end if;
      if ( not fFocus ) then
        return;
      end if;
      if ( iPos > 1 ) then
        iPos := iPos - 1;
      end if;
      print;
    end;

    procedure cursorUp is
      iNew   : integer := 0;
      iOld   : integer := 0;
    begin
      if ( not fStarted ) then
        raise NUMBER2_not_initialized;
      end if;
      if ( not fFocus ) then
        return;
      end if;
      iNew := CHARACTER'POS(strNumber(iPos));
      iOld := iNew;
      if ( iNew < CHARACTER'POS('9') ) then
        iNew := iNew + 1;
      else
        iNew := CHARACTER'POS('0');
      end if;
      strNumber(iPos) := CHARACTER'VAL(iNew);
      if ( strNumber(1..iAnzStellen) > strMaxNumber(1..iAnzStellen) ) then
        strNumber(iPos) := CHARACTER'VAL(iOld);
      end if;
      print;
    end;
    
    procedure cursorDown is
      iNew   : integer := 0;
      iOld   : integer := 0;
    begin
      if ( not fStarted ) then
        raise NUMBER2_not_initialized;
      end if;
      if ( not fFocus ) then
        return;
      end if;
      iNew := CHARACTER'POS(strNumber(iPos));
      iOld := iNew;
      if ( iNew > CHARACTER'POS('0') ) then
        iNew := iNew - 1;
      else
        iNew := CHARACTER'POS('9');
      end if;
      strNumber(iPos) := CHARACTER'VAL(iNew);
      if ( strNumber(1..iAnzStellen) > strMaxNumber(1..iAnzStellen) ) then
        strNumber(iPos) := CHARACTER'VAL(iOld);
      end if;
      print;
    end;        

    procedure setTNumber ( t : in integer ) is
    begin
      if ( not fStarted ) then
        raise NUMBER2_not_initialized;
      end if;
      if ( (t>=0) and (t<=9) ) then
        iTNumber := t;
        tLastChange := Clock;
      end if;
    end;

    function getTNumber return integer is
    begin
      if ( not fStarted ) then
        raise NUMBER2_not_initialized;
      end if;
      return ( iTNumber );
    end;

    procedure setNumber ( t : in integer ) is
    begin
      put ( strNumber(1..iAnzStellen), t );
      for i in 1..iAnzStellen loop
        if ( strNumber(i) = ' ' ) then
          strNumber(i) := '0';
        end if;
      end loop;
      if ( strMaxNumber(1..iAnzStellen) < strNumber(1..iAnzStellen) ) then
        strNumber(1..iAnzStellen) := strMaxNumber(1..iAnzStellen);
      end if;
      tLastChange := Clock;
    end;
    
    function getNumber return integer is
      iZahl : integer := 0;
      iRest : integer := 0;
    begin
      if ( not fStarted ) then
        raise NUMBER2_not_initialized;
      end if;
      get ( strNumber, iZahl, iRest );
      return ( iZahl );
    end;
    
  end ptoNumber2;

end pnumber2;

