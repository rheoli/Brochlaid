--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      23. Juli 1997                                          ==
--==   Modul:      brochlaid.adb                                          ==
--==   Verwendung: Haupttask mit CUI-Verarbeitung                         ==
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
--== Nicht unter diese Lizenz fallen die Dateien: osf_io.ad?, rob3.ad?    ==
--== und daca.ad?, sie sind Copyright der jeweiligen Autoren.             ==
--==========================================================================

with Ada.text_io, int_io, pscreen, pkeyboard, probyproc, pregelungproc;
use  Ada.text_io, int_io, pscreen, pkeyboard;

procedure brochlaid is
  fRoby : boolean       := true;	-- Selektiertes Fenster (Default: Roby)
  iKey  : integer       := 0;		-- 
  iType : integer       := 0;		-- Key-Type

  procedure paintMainScreen is
    strSpace : string(1..80) := (OTHERS => ' ');
  begin
    poScreen.clrScr;
    poScreen.putInversStringXY ( 1, 1, strSpace );
    poScreen.putInversStringXY ( 31, 1, "Brochlaid V 1.00" );
    poScreen.paintWindow ( 1, 2, 80, 23, "" );
  end;

  procedure paintChildScreens ( fSide : in boolean ) is
  begin
    if ( fSide ) then
      poScreen.paintBlinkWindow ( 1, 2, 40, 23, " Roboter " );
    else
      poScreen.paintWindow ( 1, 2, 40, 23, " Roboter " );
    end if;
    if ( fSide ) then
      poScreen.paintWindow ( 41, 2, 40, 23, " Regelung " );
    else
      poScreen.paintBlinkWindow ( 41, 2, 40, 23, " Regelung " );
    end if;    
  end;
  
begin
  -- Screen initialisieren
  poScreen.init;

  -- Roboter Utilities initialisieren
  pRobyProc.initRoby;

  -- Regelung initialisieren
  pRegelungProc.initRegelung;
  
  -- Umgebung zeichnen
  paintMainScreen;
  paintChildScreens ( fRoby );

  -- Fensterinhalte zeichnen
  pRobyProc.paintRoby;
  pRegelungProc.paintRegelung;

  -- Tastaturschleife
  while ( true ) loop
    poKeyboard.getKey ( iType, iKey );
    if ( iType = 1 ) then
      if ( iKey = 120 ) then
        exit;
      end if;     
      if ( fRoby ) then
        pRobyProc.type1Roby ( iKey );
      else
        pRegelungProc.type1Regelung ( iKey );
      end if;
      if ( iKey = 9 ) then
        fRoby := not fRoby;
        paintChildScreens ( fRoby );
        pRobyProc.focus ( fRoby );
        pRegelungProc.focus ( fRoby );
      end if;
    elsif ( iType = 3 ) then
      if ( iKey = 120 ) then
        exit;
      end if;
    elsif ( iType = 4 ) then
      if ( fRoby ) then
        pRobyProc.type4Roby ( iKey );
      else
        pRegelungProc.type4Regelung ( iKey );
      end if;
    end if;
    pRobyProc.refreshRoby;
    pRegelungProc.refreshRegelung;
    delay 0.01;
  end loop;

  pRobyProc.endRoby;
  pRegelungProc.endRegelung;

  poScreen.kill;
exception
  when others =>
    pRobyProc.savePoolData;
    poScreen.kill;
    raise;
end;
