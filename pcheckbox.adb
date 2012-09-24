--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      25. Juni 1997                                          ==
--==   Modul:      pcheckbox.adb                                          ==
--==   Verwendung: Checkbox-Element fuer CUI                              ==
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

package body pcheckbox is

  protected body ptoCheckbox is   
    procedure start ( x : in integer; y : in integer; s : in boolean ) is
    begin
      fStarted            := true;
      fSelected           := s;
      iX                  := x;
      iY                  := y;
      tLastPaint          := Clock;
      tLastChange         := Clock;
    end;

    procedure switchState is
    begin
      if ( not fStarted ) then
        raise CHECKBOX_not_initialized;
      end if;
      tLastChange := Clock;
      fSelected   := not fSelected;
    end;

    procedure refresh ( fRet : out boolean ) is
    begin
      if ( not fStarted ) then
        raise CHECKBOX_not_initialized;
      end if;
      if ( tLastChange > tLastPaint ) then
        tLastPaint := Clock;
        fRet       := true;
        return;
      end if;
      fRet := false;
    end;        

    procedure print is
      strRadio : string(1..3);
    begin
      if ( not fStarted ) then
        raise CHECKBOX_not_initialized;
      end if;
      strRadio := "[ ]";
      if ( fSelected ) then
        strRadio(2) := 'X';
      end if;
      poScreen.putStringXY ( iX, iY, strRadio );
    end;

    function isSelected return boolean is
    begin
      if ( not fStarted ) then
        raise CHECKBOX_not_initialized;
      end if;
      return ( fSelected );
    end;

    procedure setState ( f : in boolean ) is
    begin
      tLastChange := Clock;
      fSelected := f;
    end;
    
  end ptoCheckbox;

end pcheckbox;
