--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      30. Juni 1997                                          ==
--==   Modul:      pinfo.adb                                              ==
--==   Verwendung: Informationsaustausch zwischen Haupttask und           ==
--==               Robotersteuerung:                                      ==
--==                - Start, Stop (mit Blockeren der Roboterst.),         ==
--==                  Reset und Ende                                      ==
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


with int_io, Ada.text_io, pscreen;
use  int_io, Ada.text_io, pscreen;

package body pinfo is

  protected body poInfo is
    procedure start is
    begin
      if ( iRoboState = kRIError ) then
        return;
      end if;
      iRoboState := kRIRunning;
      poScreen.putStringXY ( 14, 25, "erwartet Arbeit       " );
    end;

    procedure stop is
    begin
      if ( iRoboState = kRIError ) then
        return;
      end if;
      iRoboState := kRIStopped;
      poScreen.putStringXY ( 14, 25, "gestoppt              " );
    end;

    procedure reset is
    begin
      if ( iRoboState = kRIError ) then
        return;
      end if;
      iRoboState := kRIReset;
      poScreen.putStringXY ( 14, 25, "macht Reset           " );
    end;

    procedure ende is
    begin
      iRoboState := kRIEnd;
      poScreen.putStringXY ( 14, 25, "beendet               " );
    end;
    
    procedure error is
    begin
      iRoboState := kRIError;
      poScreen.putStringXY ( 14, 25, "Fehler                " );
    end;

    entry getState ( iState : out eInfos ) when (iRoboState /= kRIStopped) and (iRoboState /= kRIError) is
    begin
      iState := iRoboState;
      case iRoboState is
        when kRIRunning =>
          poScreen.putStringXY ( 14, 25, "arbeitet               " );
        when kRIStopped =>
          poScreen.putStringXY ( 14, 25, "gestoppt               " );
        when kRIReset =>
          poScreen.putStringXY ( 14, 25, "gestoppt               " );
        when kRIEnd =>
          poScreen.putStringXY ( 14, 25, "beenden                " );
        when OTHERS =>
          poScreen.putStringXY ( 14, 25, "????                   " );
      end case;
      if ( iState = kRIReset ) then
        iRoboState := kRIStopped;
      end if;      
    end;
  end poInfo;

end pinfo;
