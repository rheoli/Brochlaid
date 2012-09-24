--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      04. Juni 1997                                          ==
--==   Modul:      ppool.adb                                              ==
--==   Verwendung: Pool mit Roboterkoordinaten fuer Roboter-              ==
--==               steuerung                                              ==
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


with plistbox, plbpool;
use  plistbox, plbpool;

package body ppool is

  protected body poPool is
    procedure start is
    begin
      fRunning := true;
    end;

    entry add ( pPos : in rExtPosition ) when fRunning is
      pNew     : aPositionsAblauf := null;
      pLoop    : aPositionsAblauf := null;
      pOld     : aPositionsAblauf := null;
      lineItem : rLine;
    begin
      pNew             := new rPositionsAblauf;
      pNew.aAblauf     := pPos;
      if ( pPos.iID /= 0 ) then
        pNew.aAblauf.iID := iNextID;
        iNextID          := iNextID + 1;
      end if;
      pNew.pNext       := null;
      if ( pNew.aAblauf.iID /= 0 ) then
        lineItem.iID     := pNew.aAblauf.iID;
        lineItem.sInfo   := pNew.aAblauf.sInfo;
        poLBPool.add ( lineItem );
      end if;
      if ( pFirst = null ) then
        pFirst := pNew;
        return;
      end if;
      pLoop := pFirst;
      while ( pLoop /= null ) loop
        pOld  := pLoop;
        pLoop := pLoop.pNext;
      end loop;
      pOld.pNext := pNew;
    end;

    entry edit ( pPos : in rExtPosition ) when fRunning is
      pLoop    : aPositionsAblauf := null;
      lineItem : rLine;
    begin
      pLoop := pFirst;
      while ( pLoop /= null ) loop
        if ( pLoop.aAblauf.iID = pPos.iID ) then
          exit;
        end if;
        pLoop := pLoop.pNext;
      end loop;
      if ( pLoop = null ) then              
        add ( pPos );
        return;
      end if;
      pLoop.aAblauf := pPos;
      if ( pLoop.aAblauf.iID /= 0 ) then
        poLBPool.delete ( pLoop.aAblauf.iID );
        lineItem.iID     := pLoop.aAblauf.iID;
        lineItem.sInfo   := pLoop.aAblauf.sInfo;
        poLBPool.insert ( pLoop.aAblauf.iID, lineItem );
      end if;
    end;

    entry delete ( iID : in integer ) when fRunning is
      pLoop    : aPositionsAblauf := null;
      pOld     : aPositionsAblauf := null;
      lineItem : rLine;
    begin
      if ( iID = 0 ) then
        return;
      end if;
      pLoop := pFirst;
      while ( pLoop /= null ) loop
        if ( pLoop.aAblauf.iID = iID ) then
          exit;
        end if;
        pOld  := pLoop;
        pLoop := pLoop.pNext;
      end loop;
      if ( pLoop = null ) then
        return;  -- evtl. hier Exception einfuegen
      end if;
      if ( pOld = null ) then
        poLBPool.delete ( pFirst.aAblauf.iID );
        pFirst := pLoop.pNext;
        return;
      end if;
      poLBPool.delete ( pLoop.aAblauf.iID );
      pOld.pNext := pLoop.pNext;
      pLoop      := null;
    end;

    entry deleteAll when fRunning is
    begin
      pFirst   := null;  -- Garbage Collection
      pGetLoop := null;
      poLBPool.deleteAll;
    end;

    entry get ( iID : in integer; pPos : out rExtPosition; fRet : out boolean ) when fRunning is
      pLoop : aPositionsAblauf := null;
    begin
      pLoop := pFirst;
      while ( pLoop /= null ) loop
        if ( pLoop.aAblauf.iID = iID ) then
          exit;
        end if;
        pLoop := pLoop.pNext;
      end loop;
      if ( pLoop = null ) then
        fRet := false;
        return;
      end if;
      fRet := true;
      pPos := pLoop.aAblauf;
    end;
    
    entry getFirst ( pPos : out rExtPosition; fRet : out boolean ) when fRunning is
    begin
      pGetLoop := pFirst;
      if ( pGetLoop = null ) then
        fRet := false;
        return;
      end if;
      fRet := true;
      pPos := pGetLoop.aAblauf;
    end;
    
    entry getNext ( pPos : out rExtPosition; fRet : out boolean ) when fRunning is
    begin
      if ( pGetLoop = null ) then
        fRet := false;
        return;
      end if;
      pGetLoop := pGetLoop.pNext;
      if ( pGetLoop = null ) then
        fRet := false;
        return;
      end if;
      fRet := true;
      pPos := pGetLoop.aAblauf;
    end;

    entry debug when fRunning is
      pLoop : aPositionsAblauf := null;
    begin
      pLoop := pFirst;
      while ( pLoop /= null ) loop
        put ( pLoop.aAblauf.sInfo );
        put ( "  " );
        put ( pLoop.aAblauf.iID );
        put ( "  " );
        case pLoop.aAblauf.aPos(1).iCode is
          when kPAFahren => put ( "Fahren" );
          when kPAWarten => put ( "Warten" );
          when others => put ( "sonstiges" );
        end case;
        new_line;
        pLoop := pLoop.pNext;
      end loop;
    end;
  end poPool;

end ppool;

