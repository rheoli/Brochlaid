--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      25. Juni 1997                                          ==
--==   Modul:      pchannel.adb                                           ==
--==   Verwendung: Channel zwischen Haupttask und Robotersteuerung        ==
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

with int_io, Ada.text_io, plbchannel, plistbox;
use  int_io, Ada.text_io, plbchannel, plistbox;

package body pchannel is
  protected body poChannel is
    procedure start is
    begin
      fRunning := true;
    end;

    entry add ( nr : in integer; str : in string ) when fRunning is
      pNew     : aAblauf := null;
      lineItem : rLine;
    begin
      pNew           := new rAblauf;
      pNew.iAblaufNr := nr;
      pNew.sInfo     := str;
      if ( pFirstAblauf = null ) then
        pFirstAblauf := pNew;
        pLastAblauf  := pNew;
      else
        pNew.pNext   := pFirstAblauf;
        if ( pFirstAblauf = pLastAblauf ) then
          pLastAblauf.pPrev := pNew;
        end if;
        pFirstAblauf.pPrev := pNew;
        pFirstAblauf      := pNew;
      end if;
      lineItem.iID   := nr;
      lineItem.sInfo := str;
      poLBChannel.add ( lineItem );
    end;

    entry delete ( nr : in integer ) when fRunning is
      ptr : aAblauf := null;
    begin
      ptr := pFirstAblauf;
      for i in 1..(nr-1) loop
        if ( ptr.pNext = null ) then
          return;
        end if;
        ptr := ptr.pNext;
      end loop;
      if ( ptr.pPrev /= null ) then
        ptr.pPrev.pNext := ptr.pNext;
      else
        pFirstAblauf  := ptr.pNext;
      end if;
      if ( ptr.pNext /= null ) then
        ptr.pNext.pPrev := ptr.pPrev;
      else
        pLastAblauf   := ptr.pPrev;
      end if;
      ptr := null;  -- Garbage Collection ?!?!?
      poLBChannel.delete ( nr );
    end;

    entry deleteAll when fRunning is
      ptr    : aAblauf := null;
      ptrOld : aAblauf := null;
    begin
      ptr := pFirstAblauf;
      if ( ptr = null ) then
        return;
      end if;
      while ( ptr /= null ) loop
        ptrOld := ptr;
        ptr    := ptr.pNext;
        ptrOld := null;    -- Garbage Collection ?!?!?!
      end loop;
      pFirstAblauf := null;
      pLastAblauf  := null;
      poLBChannel.deleteAll;
    end;

    entry getNext ( nr : out integer; str : out string ) when (fRunning and (pLastAblauf/=null)) is
      ptr : aAblauf := null;
    begin
      if ( pLastAblauf.pPrev /= null ) then
        pLastAblauf.pPrev.pNext := null;
      else
        pFirstAblauf := null;
      end if;
      ptr := pLastAblauf;
      if ( pFirstAblauf = null ) then
        pLastAblauf := null;
      else
        pLastAblauf := pLastAblauf.pPrev;
      end if;
      nr  := ptr.iAblaufNr;
      str := ptr.sInfo;
      ptr := null;   -- Garbage Collection ?!?!
      poLBChannel.delete ( nr );
    end;

    entry debug when fRunning is
      ptr : aAblauf := null;
    begin
      ptr := pFirstAblauf;
      if ( ptr = null ) then
        put_line ( "Keine Elemente im Channel" );
        return;
      end if;
      put_line ( "Die Elemente sind:" );
      while ( ptr /= null ) loop
        put ( ptr.iAblaufNr );
        new_line;
        ptr := ptr.pNext;
      end loop;
    end debug;
    
  end poChannel;

end pchannel;

