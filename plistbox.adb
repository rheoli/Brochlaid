--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      24. Juni 1997                                          ==
--==   Modul:      plistbox.adb                                           ==
--==   Verwendung: Listbox-Element fuer CUI                               ==
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

package body plistbox is

  protected body ptoListBox is
    -- Start
    -- x, y : Position (x,y)
    -- width: Breite des Elements
    -- len  : Laenge des Elements
    -- str  : Titel
    procedure start ( x : in integer; y : in integer; width : integer; len : in integer; str : in string ) is
    begin
      fStarted            := true;
      iX                  := x;
      iY                  := y;
      iWidth              := width;
      iLength             := len;
      tLastPaint          := Clock;
      tLastChange         := Clock;
      strTitle(str'range) := str;
      iTLen               := str'Length;
    end;

    procedure setInfo ( str : in String ) is
    begin
      if ( not fStarted ) then
        raise LB_not_initialized;
      end if;
      tLastChange := Clock;
      strInfo     := str;
    end;
    
    procedure getInfo ( str : out String ) is
    begin
      if ( not fStarted ) then
        raise LB_not_initialized;
      end if;
      str := strInfo;
    end;

    procedure clsInfo is
    begin
      tLastChange := Clock;
      strInfo := (OTHERS => ' ');
    end;

    procedure refresh ( fRet : out boolean ) is
    begin
      if ( not fStarted ) then
        raise LB_not_initialized;
      end if;
      if ( tLastChange > tLastPaint ) then
        tLastPaint := Clock;
        fRet       := true;
        return;
      end if;
      fRet := false;
    end;        

    procedure add ( pPos : in rLine ) is
      pNew  : aLineP := null;
      pLoop : aLineP := null;
      pOld  : aLineP := null;
    begin
      if ( not fStarted ) then
        raise LB_not_initialized;
      end if;
      tLastChange := Clock;
      pNew        := new rLineP;
      pNew.aLine  := pPos;
      pNew.iZeile := iNextID;
      iNextID     := iNextID + 1;
      pNew.pNext  := null;
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
      if ( (iNextID-1) > iLength ) then
        fMoreDown := true;
      end if;
    end;

    procedure insert ( iZeile : in integer; pPos : in rLine ) is
      pLoop : aLineP := null;
      pOld  : aLineP := null;
      pNew  : aLineP := null;
    begin
      pLoop := pFirst;
      while ( pLoop /= null ) loop
        if ( pLoop.iZeile = iZeile ) then
          exit;
        end if;
        pOld  := pLoop;
        pLoop := pLoop.pNext;
      end loop;
      if ( pLoop = null ) then
        add ( pPos );
        return;
      end if;
      tLastChange := Clock;
      pNew        := new rLineP;
      pNew.aLine  := pPos;
      pNew.iZeile := iZeile;
      pNew.pNext  := null;
      if ( pOld = null ) then
        pNew.pNext := pFirst;
        pFirst     := pNew;       
      else
        pOld.pNext := pNew;
        pNew.pNext := pLoop;
      end if;
      while ( pLoop /= null ) loop
        pLoop.iZeile := pLoop.iZeile + 1;
        pLoop        := pLoop.pNext;
      end loop;
      iNextID := iNextID + 1;
    end;

    procedure delete ( iID : in integer ) is
      pLoop : aLineP := null;
      pOld  : aLineP := null;
    begin
      pLoop := pFirst;
      while ( pLoop /= null ) loop
        if ( pLoop.aLine.iID = iID ) then
          exit;
        end if;
        pOld  := pLoop;
        pLoop := pLoop.pNext;
      end loop;
      if ( pLoop = null ) then
        return;
      end if;
      if ( pOld = null ) then
        pFirst := pLoop.pNext;
      else
        pOld.pNext := pLoop.pNext;
      end if;
      pLoop := pLoop.pNext;
      while ( pLoop /= null ) loop
        pLoop.iZeile := pLoop.iZeile - 1;
        pLoop := pLoop.pNext;
      end loop;
      iNextID := iNextID - 1;
      if ( iSelected > (iNextID-1) ) then
        iSelected := iNextID - 1;
      end if;
      tLastChange := Clock;
    end;

    procedure deleteAll is
    begin
      if ( not fStarted ) then
        raise LB_not_initialized;
      end if;
      tLastChange := Clock;
      pFirst    := null;  -- Garbage Collection
      iNextID   := 1;
      iSelected := 1;
      iOffset   := 0;
      fMoreUp   := false;
      fMoreDown := false;
    end;

    procedure get ( iZeile : in integer; pPos : out rLine; fRet : out boolean ) is
      pLoop : aLineP := null;
    begin
      if ( not fStarted ) then
        raise LB_not_initialized;
      end if;
      pLoop := pFirst;
      while ( pLoop /= null ) loop
        if ( pLoop.iZeile = iZeile ) then
          exit;
        end if;
        pLoop := pLoop.pNext;
      end loop;
      if ( pLoop = null ) then
        fRet := false;
        return;
      end if;
      fRet := true;
      pPos := pLoop.aLine;
    end;

    procedure print is
      strSpace : string(1..80) := (OTHERS => ' ');
      fRet     : boolean       := false;
      item     : rLine;
    begin
      if ( not fStarted ) then
        raise LB_not_initialized;
      end if;
      if ( (iNextID-1) <= iLength ) then
        fMoreDown := false;
      end if;
      poScreen.paintWindow ( iX-1, iY-1, iWidth+3, iLength+2, strTitle(1..iTLen) );
      if ( fMoreUp ) then
        poScreen.putCharCurUpXY ( iX+iWidth, iY );
      else
        poScreen.putCharXY ( iX+iWidth, iY, CHARACTER'POS(' ') );
      end if;
      if ( fMoreDown ) then
        poScreen.putCharCurDownXY ( iX+iWidth, iY+iLength-1 );
      else
        poScreen.putCharXY ( iX+iWidth, iY+iLength-1, CHARACTER'POS(' ') );
      end if;      
      for i in 1..iLength loop
        get ( i+iOffset, item, fRet );
        if ( fRet ) then
          if ( iSelected = (i+iOffset) ) then
            poScreen.putInversStringXY ( iX, iY+i-1, item.sInfo(1..iWidth) );
          else
            poScreen.putStringXY ( iX, iY+i-1, item.sInfo(1..iWidth) );
          end if;
        else
          poScreen.putStringXY ( iX, iY+i-1, strSpace(1..iWidth) );
        end if;
      end loop;
    end;

    procedure cursorUp is
    begin
      if ( not fStarted ) then
        raise LB_not_initialized;
      end if;
      if ( iSelected > (iOffset+1) ) then
        iSelected := iSelected - 1;
        print;
      else
        if ( iOffset > 0 ) then
          iSelected := iSelected - 1;
          iOffset   := iOffset - iLength;
          fMoreDown := true;
          if ( iOffset = 0 ) then
            fMoreUp := false;
          end if;
          print;
        end if;
      end if;
    end;
    
    procedure cursorDown is
    begin
      if ( not fStarted ) then
        raise LB_not_initialized;
      end if;
      if ( (iSelected<(iOffset+iLength)) and (iSelected<(iNextID-1)) ) then
        iSelected := iSelected + 1;
        print;
      else
        if ( iSelected < (iNextID-1) ) then
          iOffset   := iOffset + iLength;
          iSelected := iSelected + 1;
          fMoreUp   := true;
          if ( (iOffset+iLength) >= (iNextID-1) ) then
            fMoreDown := false;
          end if;
          print;
        end if;
      end if;
    end;
        
    function getSelectedZeile return integer is
    begin
      if ( not fStarted ) then
        raise LB_not_initialized;
      end if;
      return ( iSelected );
    end;
    
    procedure debug is
      pLoop : aLineP := null;
    begin
      if ( not fStarted ) then
        raise LB_not_initialized;
      end if;
      pLoop := pFirst;
      while ( pLoop /= null ) loop
        put ( pLoop.aLine.sInfo );
        put ( "  " );
        put ( pLoop.aLine.iID );
        new_line;
        pLoop := pLoop.pNext;
      end loop;
    end;
  end ptoListBox;

end plistbox;

