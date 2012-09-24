--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      03. Juni 1997                                          ==
--==   Modul:      pscreen.adb                                            ==
--==   Verwendung: Screenverwaltung der CUI                               ==
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


with Ada.Text_io;
use  Ada.Text_io;

package body pScreen is
  procedure initTerm_Import;
  pragma Import ( C, initTerm_Import, "initTerm" );
  procedure resetTerm_Import;
  pragma Import ( C, resetTerm_Import, "resetTerm" );

  procedure putCharXY_Import ( x : in integer; y : in integer; c : in integer );
  pragma Import ( C, putCharXY_Import, "putCharXY" );
  procedure putInversCharXY_Import ( x : in integer; y : in integer; c : in integer );
  pragma Import ( C, putInversCharXY_Import, "putInversCharXY" );

  procedure clrScr_Import;
  pragma Import ( C, clrScr_Import, "clrScr" );
  procedure gotoXY_Import ( x : in integer; y : in integer );
  pragma Import ( C, gotoXY_Import, "gotoXY" );  

  procedure cursorOn_Import;
  pragma Import ( C, cursorOn_Import, "cursorOn" );
  procedure cursorOff_Import;
  pragma Import ( C, cursorOff_Import, "cursorOff" );
  
  procedure inversOn_Import;
  pragma Import ( C, inversOn_Import, "inversOn" );
  procedure inversOff_Import;
  pragma Import ( C, inversOff_Import, "inversOff" );

  procedure blinkOn_Import;
  pragma Import ( C, blinkOn_Import, "blinkOn" );  
  procedure blinkOff_Import;
  pragma Import ( C, blinkOff_Import, "blinkOff" );  

  procedure putLDCharUR_Import;
  pragma Import ( C, putLDCharUR_Import, "putLDCharUR" );  
  procedure putLDCharOR_Import;
  pragma Import ( C, putLDCharOR_Import, "putLDCharOR" );
  procedure putLDCharUL_Import;
  pragma Import ( C, putLDCharUL_Import, "putLDCharUL" );
  procedure putLDCharOL_Import;
  pragma Import ( C, putLDCharOL_Import, "putLDCharOL" );
  procedure putLDCharLM_Import;
  pragma Import ( C, putLDCharLM_Import, "putLDCharLM" );
  procedure putLDCharRM_Import;
  pragma Import ( C, putLDCharRM_Import, "putLDCharRM" );
  procedure putLDCharOM_Import;
  pragma Import ( C, putLDCharOM_Import, "putLDCharOM" );
  procedure putLDCharUM_Import;
  pragma Import ( C, putLDCharUM_Import, "putLDCharUM" );
  procedure putLDCharKR_Import;
  pragma Import ( C, putLDCharKR_Import, "putLDCharKR" );
  
  procedure putLDCharCurUp_Import;
  pragma Import ( C, putLDCharCurUp_Import, "putLDCharCurUp" );
  procedure putLDCharCurDown_Import;
  pragma Import ( C, putLDCharCurDown_Import, "putLDCharCurDown" );
  
  procedure putLDCharHL_Import ( x : in integer; y : in integer; iAnz : in integer );
  pragma Import ( C, putLDCharHL_Import, "putLDCharHL" );
  procedure putLDCharVL_Import ( x : in integer; y : in integer; iAnz : in integer );
  pragma Import ( C, putLDCharVL_Import, "putLDCharVL" );

  procedure paintWindow_Intern ( x : in integer; y : in integer; w : in integer; h : in integer; str : in string ) is
    iLen   : integer := str'Length;
    iPoint : integer := 0;
  begin
    gotoXY_Import ( x, y );
    putLDCharOL_Import;
    putLDCharHL_Import ( x+1, y, w-2 );
    putLDCharOR_Import;
    putLDCharVL_Import ( x, y+1, h-2 );
    gotoXY_Import ( x, y+h-1 );
    putLDCharUL_Import;
    putLDCharHL_Import ( x+1, y+h-1, w-2 );
    putLDCharUR_Import;
    putLDCharVL_Import ( x+w-1, y+1, h-2 );
    if ( iLen /= 0 ) then
      iPoint := x+(w/2)-(iLen/2);
      for i in 1..iLen loop
        putCharXY_Import ( i+iPoint, y, CHARACTER'POS(str(i)) );
      end loop;
    end if;
  end;
  
  procedure paintTwinWindow_Intern ( x : in integer; y : in integer; w : in integer; h : in integer; w2 : in integer ) is
  begin
    paintWindow_Intern ( x, y, w2, h, "" );
    paintWindow_Intern ( x, y, w, h, "" );
    gotoXY_Import ( x+w-1, y );
    putLDCharOM_Import;
    gotoXY_Import ( x+w-1, y+h-1 );
    putLDCharUM_Import;
  end;


  protected body poScreen is
    procedure init is
    begin
      initTerm_Import;
      cursorOff_Import;
      fInit := true;
      fEnd  := false;
    end;

    entry paintWindow ( x : in integer; y : in integer; w : in integer; h : in integer; str : in string ) when fInit is
    begin
      if ( fEnd ) then
        return;
      end if;
      paintWindow_Intern ( x, y, w, h, str );
    end;

    entry paintTwinWindow ( x : in integer; y : in integer; w : in integer; h : in integer; w2 : in integer ) when fInit is
    begin
      if ( fEnd ) then
        return;
      end if;
      paintTwinWindow_Intern ( x, y, w, h, w2 );
    end;
    
    entry paintInversTwinWindow ( x : in integer; y : in integer; w : in integer; h : in integer; w2 : in integer ) when fInit is
    begin
      if ( fEnd ) then
        return;
      end if;
      inversOn_Import;
      paintTwinWindow_Intern ( x, y, w, h, w2 );
      inversOff_Import;
    end;

    entry paintInversWindow ( x : in integer; y : in integer; w : in integer; h : in integer; str : in string ) when fInit is
    begin
      if ( fEnd ) then
        return;
      end if;
      inversOn_Import;
      paintWindow_Intern ( x, y, w, h, str );
      inversOff_Import;
    end;
    
    entry paintBlinkWindow ( x : in integer; y : in integer; w : in integer; h : in integer; str : in string ) when fInit is
    begin
      if ( fEnd ) then
        return;
      end if;
      blinkOn_Import;
      paintWindow_Intern ( x, y, w, h, str );
      blinkOff_Import;
    end;

    entry clsWindow (  x : in integer; y : in integer; w : in integer; h : in integer ) when fInit is
      strSpace : string(1..80) := (OTHERS => ' ');
    begin
      if ( fEnd ) then
        return;
      end if;
      for i in y..(y+h-1) loop
        for j in x..(x+w-1) loop
          putCharXY_Import ( j, i, CHARACTER'POS(' ') );
        end loop;
      end loop;
    end;
    
    entry clrScr when fInit is
    begin
      clrScr_Import;
    end;
    
    entry putStringXY ( x : in integer; y : in integer; str : in String ) when fInit is
      iLen : integer := str'Length;
    begin
      if ( fEnd ) then
        return;
      end if;
      for i in 1..iLen loop
        putCharXY_Import ( x+i-1, y, CHARACTER'POS(str(i+str'First-1)) );
      end loop;
    end;
      
    entry putCharXY ( x : in integer; y : in integer; c : in integer ) when fInit is
    begin
      if ( fEnd ) then
        return;
      end if;
      putCharXY_Import ( x, y, c );
    end;

    entry putCharCurUpXY ( x : integer; y : integer ) when fInit is
    begin
      if ( fEnd ) then
        return;
      end if;
      gotoXY_Import ( x, y );
      putLDCharCurUp_Import;
    end;
    
    entry putCharCurDownXY ( x : integer; y : integer ) when fInit is
    begin
      if ( fEnd ) then
        return;
      end if;
      gotoXY_Import ( x, y );
      putLDCharCurDown_Import;
    end;
    
    entry putInversCharXY ( x : in integer; y : in integer; c : in integer ) when fInit is
    begin
      if ( fEnd ) then
        return;
      end if;
      putInversCharXY_Import ( x, y, c );
    end;

    entry putInversStringXY ( x : in integer; y : in integer; str : in String ) when fInit is
      iLen : integer := str'Length;
    begin
      if ( fEnd ) then
        return;
      end if;
      for i in 1..iLen loop
        putInversCharXY_Import ( x+i-1, y, CHARACTER'POS(str(i+str'First-1)) );
      end loop;
    end;

    entry kill when fInit is
    begin
      clrScr_Import;
      cursorOn_Import;
      resetTerm_Import;
      fEnd := true;
    end;    
  end poScreen;
end pScreen;
