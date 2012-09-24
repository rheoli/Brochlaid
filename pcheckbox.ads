--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      25. Juni 1997                                          ==
--==   Modul:      pcheckbox.ads                                          ==
--==   Verwendung: Checkbox-Element fuer CUI                              ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================

with Ada.Exceptions, Ada.Calendar;
use  Ada, Ada.Calendar;

package pcheckbox is
  CHECKBOX_not_initialized : exception;

  protected type ptoCheckbox is
    -- Start
    -- x, y: Position (x,y)
    -- s   : Default Selektierung
    procedure start    ( x : in integer; y : in integer; s : in boolean );
    procedure switchState;
    procedure refresh  ( fRet : out boolean );
    procedure print;
    function  isSelected return boolean;
    procedure setState ( f : in boolean );
  private
    fStarted     : boolean := false;
    fSelected    : boolean := false;
    iX           : integer := 0;
    iY           : integer := 0;
    tLastChange  : time;
    tLastPaint   : time;
  end ptoCheckbox;

end pcheckbox;

