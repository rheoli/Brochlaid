--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      27. Juni 1997                                          ==
--==   Modul:      proby.adb                                              ==
--==   Verwendung: Robotertask                                            ==
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


with text_io, int_io, plbroby, plistbox, pinfo, pchannel, ppool, float_io, pscreen, rob3;
use  text_io, int_io, plbroby, plistbox, pinfo, pchannel, ppool, float_io, pscreen, rob3;

package body proby is
  task body toRoby is

    fWithRoby : constant boolean := false;
    
    lineItem  : rLine;
    i         : integer := 1;
    iState    : eInfos  := kRINone;
    iID       : integer := 0;
    posItem   : rExtPosition;
    fRet      : boolean;
    str       : string(1..80);
    fSuccess  : boolean := false;
    aGrundPos : pos_array_type;
    aOldPos   : pos_array_type;
  begin
    accept start;    
    -- Initialisieren des Roboters
    if ( fWithRoby ) then
      init_rob ( fSuccess );
      aGrundPos := (128,164,140,182, 14,128);
      if ( not fSuccess ) then
        lineItem.iID   := 1;
        lineItem.sInfo := (OTHERS => ' ');
        lineItem.sInfo(1..13) := "No connection";
        poLBRoby.add ( lineItem );
        poInfo.error;
      end if;
    end if;
    loop
      loop
        if ( fWithRoby ) then
          if ( fSuccess ) then
            poScreen.putStringXY ( 14, 25, "wartet              " );
          end if;
        else
          poScreen.putStringXY ( 14, 25, "wartet                " );
        end if;
        poChannel.getNext ( iID, str );
        poLBRoby.setInfo ( str );
        poScreen.putStringXY ( 14, 25, "gestoppt                " );
        poInfo.getState ( iState );
        exit when ( (iState=kRIEnd) or (iState=kRIRunning) );
        if ( iState = kRIReset ) then
          poChannel.deleteAll;
        end if;
      end loop;
      exit when ( (iState=kRIEnd) );
              
      poPool.get ( iID, posItem, fRet );
      poLBRoby.setInfo ( posItem.sInfo ); -- Auftragname setzen

      poLBRoby.deleteAll;
      for j in 1..kPosition loop
        exit when ( posItem.aPos(j).iCode = kPANone );
        lineItem.iID   := j;
        lineItem.sInfo := (OTHERS => ' ');
        if ( (posItem.aPos(j).iCode=kPAFahren) or (posItem.aPos(j).iCode=kPAFahrenundWarten) or (posItem.aPos(j).iCode=kPAManuell) ) then
          lineItem.sInfo(2) := 'F';
          put ( lineItem.sInfo(4..6), posItem.aPos(j).paPos(1) );
          put ( lineItem.sInfo(8..10), posItem.aPos(j).paPos(2) );
          put ( lineItem.sInfo(12..14), posItem.aPos(j).paPos(3) );
          put ( lineItem.sInfo(16..18), posItem.aPos(j).paPos(4) );
          put ( lineItem.sInfo(20..22), posItem.aPos(j).paPos(5) );
          put ( lineItem.sInfo(24..26), posItem.aPos(j).paPos(6) );
          poLBRoby.add ( lineItem );
        end if;
        lineItem.sInfo := (OTHERS => ' ');
        if ( (posItem.aPos(j).iCode=kPAWarten) or (posItem.aPos(j).iCode=kPAFahrenundWarten) ) then
          lineItem.sInfo(2) := 'W';
          put ( lineItem.sInfo(4..16), float(posItem.aPos(j).dWartezeit), aft=>1, exp=>0 );
          poLBRoby.add ( lineItem );
        end if;
      end loop;
      if ( posItem.aPos(1).iCode /= kPAManuell ) then
        lineItem.iID          := 100;
        lineItem.sInfo        := (OTHERS => ' ');
        lineItem.sInfo(1..13) := "Zurueckfahren";
        poLBRoby.add ( lineItem );
      end if;
      
      for i in 1..kPosition loop
        if ( posItem.aPos(i).iCode = kPANone ) then
          -- Roboter auf Grundstellung
          if ( fWithRoby ) then
            if ( posItem.aPos(1).iCode /= kPAManuell ) then
              set_pos_all ( aGrundPos, fSuccess );
              if ( not fSuccess ) then
                lineItem.iID   := 1;
                lineItem.sInfo := (OTHERS => ' ');
                lineItem.sInfo(1..13) := "No connection";
                poLBRoby.deleteAll;
                poLBRoby.add ( lineItem );
                poInfo.error;
              end if;
            end if;
          else
            delay 2.0;
          end if;

          poLBRoby.cursorDown;
          exit;
        end if;
        poInfo.getState ( iState );
        if ( (iState=kRIEnd) or (iState=kRIReset) ) then
          -- Roboter in Grundstellung
          if ( fWithRoby ) then
            set_pos_all ( aGrundPos, fSuccess );
            if ( not fSuccess ) then
              lineItem.iID   := 1;
              lineItem.sInfo := (OTHERS => ' ');
              lineItem.sInfo(1..13) := "No connection";
              poLBRoby.deleteAll;
              poLBRoby.add ( lineItem );
              poInfo.error;
            end if;
          else
            delay 2.0;
          end if;
          poLBRoby.cursorDown;
          exit;
        end if;

        -- Roboteraktionen
        if ( (posItem.aPos(i).iCode=kPAFahren) or
                (posItem.aPos(i).iCode=kPAFahrenundWarten) or
                (posItem.aPos(i).iCode=kPAManuell)) then
          if ( fWithRoby ) then
            read_pos_all ( aOldPos, fSuccess );
            if ( not fSuccess ) then
              lineItem.iID   := 1;
              lineItem.sInfo := (OTHERS => ' ');
              lineItem.sInfo(1..13) := "No connection";
              poLBRoby.deleteAll;
              poLBRoby.add ( lineItem );
              poInfo.error;
            end if;
            for j in 1..6 loop
              if ( posItem.aPos(i).paPos(j) /= 0 ) then
                aOldPos(j) := posItem.aPos(i).paPos(j);
              end if;
            end loop;
            set_pos_all_v ( aOldPos, posItem.aPos(i).gaGeschw, fSuccess );
            if ( not fSuccess ) then
              lineItem.iID   := 1;
              lineItem.sInfo := (OTHERS => ' ');
              lineItem.sInfo(1..13) := "No connection";
              poLBRoby.deleteAll;
              poLBRoby.add ( lineItem );
              poInfo.error;
            end if;
          else
            delay 2.0;  -- nur fuer Testzwecke
          end if;
          poLBRoby.cursorDown;
        end if;
        if ( (posItem.aPos(i).iCode=kPAWarten) or (posItem.aPos(i).iCode=kPAFahrenundWarten) ) then
          select
            accept EndeWait;
          or
            delay posItem.aPos(i).dWartezeit;
          end select;
          poLBRoby.cursorDown;
        end if;        
      end loop;
      poLBRoby.deleteAll;
      poLBRoby.clsInfo;
      exit when ( iState = kRIEnd );
      if ( iState = kRIReset ) then
        poChannel.deleteAll;
      end if;
    end loop;
    -- auf Grundstellung fahren
    if ( fWithRoby ) then
      set_pos_all ( aGrundPos, fSuccess );
    end if;
  end toRoby;

end proby;

