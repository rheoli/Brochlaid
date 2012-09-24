--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      27. Juni 1997                                          ==
--==   Modul:      pedit.ads                                              ==
--==   Verwendung: Edit-Element fuer CUI                                  ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================

with Ada.Exceptions, Ada.Calendar;
use  Ada, Ada.Calendar;

package pedit is
  EDIT_not_initialized : exception;

  protected type ptoEdit is
    -- Start
    -- x, y: Position (x,y)
    -- b   : Breite des Elements
    -- s   : Default String
    procedure start ( x : in integer; y : in integer; b : in integer; s : in string );
    procedure refresh ( fRet : out boolean );
    procedure print;
    procedure focusOn;
    procedure focusOff;
    procedure cursorRight;
    procedure cursorLeft;
    procedure delChar;
    procedure insertChar ( c : in integer );
    procedure changeChar ( c : in integer );
    procedure getString ( s : out string );
    procedure setString ( s : in string );
  private
    fStarted       : boolean := false;
    fFocus         : boolean := false;
    iX             : integer := 0;
    iY             : integer := 0;
    iPos           : integer := 0;
    tLastChange    : time;
    tLastPaint     : time;
    iAnzBuchstaben : integer;
    strEdit        : string(1..80);
  end ptoEdit;

end pedit;
