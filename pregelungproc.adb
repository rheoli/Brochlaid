--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      25. Juni 1997                                          ==
--==   Modul:      pregelungproc.adb                                      ==
--==   Verwendung: Proceduren zu Regelungssteuerung, sowie                ==
--==               Regelungstask                                          ==
--==                                                                      ==
--==   Copyright (c) 1997 by A.Rietsch, St.Toggweiler                     ==
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


with ada.text_io, float_io, pscreen, pnumber, daca, ada.calendar, 
     osf_io, pregelpool;
use  ada.text_io, float_io, pscreen, pnumber, daca, ada.calendar, 
     osf_io;

package body pRegelungProc is

  -- GUI elements
  poKr, poTi : ptoNumber;
  poT        : ptoNumber;
  iNSelect   : integer := 1;		-- Selected Numberwindow
  fAmpMax, fAmpMin : float := 0.0; 	-- amplitude values
  running : boolean := false;		-- running / stalled
  sandwich : integer := 0;

  task tMinMax is
    entry start;
    entry quit;
  end;

  -- Regelungstask
  task body tRegelung is

    -- local variables
    fad0, fad1, fda : file_descriptor_type;
    iNextTime : time;                   -- time of next event
    ist, soll : float;
    err, m, u : float;                  -- error value, last coefficient, output
    u1, u2, err1, err2 : float;         -- history
    b0, b1 : float;             	-- parameters
    str                : string(1..30);
 
  begin
    accept startstop;

    fad0 := open("/dev/dacaad0", O_RDONLY, S_IRWXU);
    fad1 := open("/dev/dacaad1", O_RDONLY, S_IRWXU);
    fda  := open("/dev/dacada0", O_WRONLY, S_IRWXU);

    iNextTime := clock + duration(float(pregelpool.iTimeIntervall)/1000.0);
    u1 := 0.0;
    u2 := 0.0;
    err1 := 0.0;
    err2 := 0.0;
    m := 0.0;
    pregelpool.param.read(b0, b1);
    loop
      select
        accept startstop;
        sandwich := 1;
        accept startstop;
        sandwich := 0;
        pregelpool.param.read(b0, b1);

      or
        accept quit;
        exit;

      or
        delay until iNextTime;             
        -- start of time critical section
        read_ad(fad0, soll);
        read_ad(fad1, ist);
        err := soll - ist;
        u := m + b0*err;
        if (u > 9.99) then
          u := 9.99;
        elsif (u < -9.99) then
          u := -9.99;
        end if;
        write_da(fda, u);
        -- end of time critical section
        if (u > fAmpMax) then
          fAmpMax := u;
        elsif (u < fAmpMin) then 
          fAmpMin := u;
        end if; 
        iNextTime := iNextTime + duration(float(pregelpool.iTimeIntervall)/1000.0);
        u2 := u1;
        u1 := u;
        err2 := err1;
        err1 := err;
        m := u1 + b1*err1;
        pregelpool.param.read(b0, b1);
      end select;
    end loop;

--    close(fad);
--    close(fda);

  end tRegelung;

  -- GUI Elemente
  procedure paintRegelung is
  begin
    poScreen.putStringXY(43, 4, "Aktuelle Regelparameter:");
    poScreen.putStringXY(45, 6, "Kr:");
    poKr.print;
    poScreen.putStringXY(45, 9, "Ti:");
    poTi.print;
    poScreen.putStringXY(45, 12, "Abtastrate [ms]:");
    poT.print;
    poScreen.putStringXY(43, 20, "Ausgangspegel:");
    poScreen.putStringXY(45, 22, "Ampl. Max/s:");
    poScreen.putStringXY(45, 23, "Ampl. Min/s:");
    poScreen.putStringXY(47, 25, "Regelung:");
    poScreen.putStringXY(57, 25, "laeuft   ");
  end;

  
  procedure refreshRegelung is
    fret : boolean := false;
  begin
    poKr.refresh(fret);
    if (fret) then
      poKr.print;
    end if;
    poTi.refresh(fret);
    if (fret) then
      poTi.print;
    end if;
    poT.refresh(fret);
    if (fret) then
      poT.print;
    end if;
  end;
  
  task body tMinMax is
    output : string(1..22) := (OTHERS => ' ');
  begin
    accept start;
    loop
      select
        accept quit;
        exit;
      or
        delay 1.0;
        output := (OTHERS => ' ');
        put(output, fAmpMax);
        poScreen.putStringXY(56, 22, output);
        output := (OTHERS => ' ');
        put(output, fAmpMin);
        poScreen.putStringXY(56, 23, output);
        fAmpMax := -9.99;
        fAmpMin :=  9.99;
      end select;
    end loop;
  end;
  
  procedure focus ( fRoby : in boolean ) is
  begin
    if ( fRoby ) then
      if ( iNSelect = 1 ) then
        poKr.focusOff;
      elsif ( iNSelect = 2 ) then
        poTi.focusOff;
      else
        poT.focusOff;
      end if;
    else
      if ( iNSelect = 1 ) then
        poKr.focusOn;
      elsif ( iNSelect = 2 ) then
        poTi.focusOn;
      else
        poT.focusOn;
      end if;
    end if;
  end;
  
  -- Tasteneingabe
  procedure type1Regelung ( iKey : in integer ) is
  begin
    if (iKey = 115) then			-- S
      if (running = true) then
        tRegelung.startstop;
        running := false;
        poScreen.putStringXY(57, 25, "gestoppet");
      else
        tRegelung.startstop;
        running := true;
        poScreen.putStringXY(57, 25, "laeuft   ");
      end if;
    elsif ( iKey = 10 ) then
      pregelpool.iTimeIntervall := poT.getNumber;
      pregelpool.setVerhalten(float(poKr.getNumber)/1000.0, float(poTi.getNumber)/1000.0);      
    end if;
  end;
  
  procedure type4Regelung ( iKey : in integer ) is
  begin
    if ( iKey = 1 ) then
      -- Cursor Up
      if ( iNSelect = 1 ) then
        poKr.cursorUp;
      elsif ( iNSelect = 2 ) then
        poTi.cursorUp;
      else
        poT.cursorUp;
      end if;
    elsif ( iKey = 2 ) then
      -- Cursor Down
      if ( iNSelect = 1 ) then
        poKr.cursorDown;
      elsif ( iNSelect = 2 ) then
        poTi.cursorDown;
      else
        poT.cursorDown;
      end if;
    elsif ( iKey = 3 ) then
      -- Cursor rechts      
      if ( iNSelect = 1 ) then
        poKr.cursorRight;
      elsif ( iNSelect = 2 ) then
        poTi.cursorRight;
      else
        poT.cursorRight;
      end if;
    elsif ( iKey = 4 ) then
      -- Cursor links
      if ( iNSelect = 1 ) then
        poKr.cursorLeft;
      elsif ( iNSelect = 2 ) then
        poTi.cursorLeft;
      else
        poT.cursorLeft;
      end if;
    elsif ( iKey = 5 ) then
      -- PgUp
      if ( iNSelect = 1 ) then
        poKr.focusOff;
      elsif ( iNSelect = 2 ) then
        poTi.focusOff;
      else
        poT.focusOff;
      end if;
      iNSelect := iNSelect - 1;
      if ( iNSelect < 1 ) then
        iNSelect := 3;
      end if;
      if ( iNSelect = 1 ) then
        poKr.focusOn;
      elsif ( iNSelect = 2 ) then
        poTi.focusOn;
      else
        poT.focusOn;
      end if;
    elsif ( iKey = 6 ) then
      -- PgDn
      if ( iNSelect = 1 ) then
        poKr.focusOff;
      elsif ( iNSelect = 2 ) then
        poTi.focusOff;
      else
        poT.focusOff;
      end if;
      iNSelect := iNSelect + 1;
      if ( iNSelect > 3 ) then
        iNSelect := 1;
      end if;
      if ( iNSelect = 1 ) then
        poKr.focusOn;
      elsif ( iNSelect = 2 ) then
        poTi.focusOn;
      else
        poT.focusOn;
      end if;
    end if;
  end;

  -- Initialisierung
  procedure initRegelung is
    Kr : constant float := 0.190;
    Ti : constant float := 0.134;
    T : constant integer := 50;
  begin
    -- Regelungstask starten
    tRegelung.startstop;
    tMinMax.start;
    running := true;
    -- Startparameter setzen
    pregelpool.iTimeIntervall := T;		-- 50msec Abtastintervall
    pregelpool.setVerhalten(Kr, Ti);
    poKr.start(50, 6, 5, 3, 99999, integer(Kr * 1000.0));
    poKr.focusOff;
    poTi.start(50, 9, 5, 3, 99999, integer(Ti * 1000.0));
    poTi.focusOff;   
    poT.start(65, 12, 5, 0, 10000, T);
    poT.focusOff;
    fAmpMax := -9.99;
    fAmpMin :=  9.99;
  end;

  procedure endRegelung is
  begin
    if ( sandwich = 1 ) then
      tRegelung.startstop;
    end if;
    poScreen.putStringXY(57, 25, "beenden      ");
    tRegelung.quit;
    tMinMax.quit;
  end;

end pRegelungProc;
