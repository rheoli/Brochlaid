--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      25. Juni 1997                                          ==
--==   Modul:      pregelpool.adb                                         ==
--==   Verwendung: Pool fuer Regelungsdaten                               ==
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

package body pRegelPool is

  procedure setVerhalten(Kr, Ti : in float) is
    b0, b1 : float;
  begin
    b0 := -Kr;
    b1 := Kr * (1.0 + (float(iTimeIntervall)/1000.0) / Ti);
    param.set(b0, b1);
  end;

  protected body param is
    
    -- set new variables
    procedure set(ib0, ib1 : in float) is
    begin
      b0 := ib0;
      b1 := ib1;
    end;
    
    -- read parameters for calculation
    procedure read(ob0, ob1 : out float) is
    begin
      ob0 := b0;
      ob1 := b1;
    end;
  
  end param;

end pRegelPool;
