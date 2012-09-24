--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      25. Juni 1997                                          ==
--==   Modul:      pkeyboard.ads                                          ==
--==   Verwendung: Tastatureingabeverarbeitung                            ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================

with Ada.text_io, int_io, SYSTEM;
use  Ada.text_io, int_io, SYSTEM;

package pkeyboard is
  protected poKeyboard is
    -- Typen:
    --- 0: kein Zeichen vorhanden; falsches Zeichen
    --- 1: normales ASCII Zeichen
    --- 2: CTRL-Zeichen
    --- 3: ALT-Zeichen
    --- 4: Cursor Befehle
    procedure getKey ( iType : out integer; iKey : out integer );
  end poKeyboard;  
end pkeyboard;
