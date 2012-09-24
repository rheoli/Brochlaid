--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      03. Juni 1997                                          ==
--==   Modul:      pscreen.ads                                            ==
--==   Verwendung: Screenverwaltung der CUI                               ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================

with System;
use  System;

package pScreen is
  protected poScreen is
    procedure init;
    entry paintWindow ( x : in integer; y : in integer; w : in integer; h : in integer; str : in string );
    entry paintInversWindow ( x : in integer; y : in integer; w : in integer; h : in integer; str : in string );
    entry paintTwinWindow ( x : in integer; y : in integer; w : in integer; h : in integer; w2 : in integer );
    entry paintInversTwinWindow ( x : in integer; y : in integer; w : in integer; h : in integer; w2 : in integer );
    entry paintBlinkWindow ( x : in integer; y : in integer; w : in integer; h : in integer; str : in string );
    entry clsWindow (  x : in integer; y : in integer; w : in integer; h : in integer );
    entry clrScr;
    entry putCharXY ( x : in integer; y : in integer; c : in integer );
    entry putCharCurUpXY ( x : integer; y : integer );
    entry putCharCurDownXY ( x : integer; y : integer );
    entry putStringXY ( x : in integer; y : in integer; str : in String );
    entry putInversCharXY ( x : in integer; y : in integer; c : in integer );
    entry putInversStringXY ( x : in integer; y : in integer; str : in String );
    entry kill;
  private
    fInit : boolean := false;
    fEnd  : boolean := false;
  end poScreen;
end pScreen;
