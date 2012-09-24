--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      27. Juni 1997                                          ==
--==   Modul:      pedit.adb                                              ==
--==   Verwendung: Edit-Element fuer CUI                                  ==
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

package body pedit is

  protected body ptoEdit is
    procedure start ( x : in integer; y : in integer; b : in integer; s : in string ) is
    begin
      fStarted         := true;
      fFocus           := false;
      iX               := x;
      iY               := y;
      tLastPaint       := Clock;
      tLastChange      := Clock;
      iAnzBuchstaben   := b;
      iPos             := 1;
      strEdit          := (OTHERS => ' ');
      strEdit(s'range) := s;

      -- erstes ' ' hinter einem Buchstaben suchen, sonst iPos := 1
      for i in reverse 1..b loop
        if ( strEdit(i) /= ' ' ) then
          iPos := i + 1;
          if ( iPos > b ) then
            iPos := b;
          end if;
          exit;
        end if;
      end loop;
    end;

    procedure refresh ( fRet : out boolean ) is
    begin
      if ( not fStarted ) then
        raise EDIT_not_initialized;
      end if;
      if ( tLastChange > tLastPaint ) then
        tLastPaint := Clock;
        fRet       := true;
        return;
      end if;
      fRet := false;
    end;        

    procedure print is
      fRet : boolean       := false;
    begin
      if ( not fStarted ) then
        raise EDIT_not_initialized;
      end if;
      if ( fFocus ) then
        poScreen.paintInversWindow ( iX, iY-1, iAnzBuchstaben+2, 3, "" );
        poScreen.putStringXY ( iX+1, iY, strEdit(1..iAnzBuchstaben) );
        poScreen.putInversCharXY ( iX+iPos, iY, CHARACTER'POS(strEdit(iPos)) );
      else
        poScreen.paintWindow ( iX, iY-1, iAnzBuchstaben+2, 3, "" );
        poScreen.putStringXY ( iX+1, iY, strEdit(1..iAnzBuchstaben) );
      end if;
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
        raise EDIT_not_initialized;
      end if;
      if ( not fFocus ) then
        return;
      end if;
      if ( iPos < iAnzBuchstaben ) then
        iPos := iPos + 1;
      end if;
      print;
    end;
    
    procedure cursorLeft is
    begin
      if ( not fStarted ) then
        raise EDIT_not_initialized;
      end if;
      if ( not fFocus ) then
        return;
      end if;
      if ( iPos > 1 ) then
        iPos := iPos - 1;
      end if;
      print;
    end;

    procedure delChar is
    begin
      if ( not fStarted ) then
        raise EDIT_not_initialized;
      end if;
      if ( not fFocus ) then
        return;
      end if;
      if ( iPos < 2 ) then
        return;
      end if;
      for i in iPos..iAnzBuchstaben loop
        strEdit(i-1) := strEdit(i);
      end loop;
      strEdit(iAnzBuchstaben) := ' ';
      cursorLeft;
    end;
    
    procedure insertChar ( c : in integer ) is
    begin
      if ( not fStarted ) then
        raise EDIT_not_initialized;
      end if;
      if ( not fFocus ) then
        return;
      end if;
      for i in reverse (iPos+1)..iAnzBuchstaben loop
        strEdit(i) := strEdit(i-1);
      end loop;
      strEdit(iPos) := CHARACTER'VAL(c);
      cursorRight;
    end;

    procedure changeChar ( c : in integer ) is
    begin
      if ( not fStarted ) then
        raise EDIT_not_initialized;
      end if;
      if ( not fFocus ) then
        return;
      end if;
      strEdit(iPos) := CHARACTER'VAL(c);
      cursorRight;
    end;

    procedure setString ( s : in string ) is
    begin
      iPos             := 1;
      strEdit          := (OTHERS => ' ');
      strEdit(s'range) := s;

      -- erstes ' ' hinter einem Buchstaben suchen, sonst iPos := 1
      for i in reverse 1..iAnzBuchstaben loop
        if ( strEdit(i) /= ' ' ) then
          iPos := i + 1;
          if ( iPos > iAnzBuchstaben ) then
            iPos := iAnzBuchstaben;
          end if;
          exit;
        end if;
      end loop;
      tLastChange := Clock;
    end;
    
    procedure getString ( s : out string ) is
      iZahl : integer := 0;
      iRest : integer := 0;
    begin
      if ( not fStarted ) then
        raise EDIT_not_initialized;
      end if;
      s(1..iAnzBuchstaben) := strEdit(1..iAnzBuchstaben);
    end;
    
  end ptoEdit;

end pedit;

