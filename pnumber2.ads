--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      23. Juni 1997                                          ==
--==   Modul:      pnumber2.ads                                           ==
--==   Verwendung: Nummereingabe-Element fuer CUI mit                     ==
--==               Geschwindigkeitseingabe                                ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================

with Ada.Exceptions, Ada.Calendar;
use  Ada, Ada.Calendar;

package pnumber2 is
  NUMBER2_not_initialized : exception;

  protected type ptoNumber2 is
    -- Start
    -- x, y: Position (x,y)
    -- s   : Anzahl Stellen Total
    -- m   : Max. Zahl die eingegeben werden kann
    -- d   : Default Zahl
    -- t   : Default Geschwindigkeit
    procedure start ( x : in integer; y : in integer; s : in integer; m : in integer; d : in integer; t : in integer );
    procedure refresh ( fRet : out boolean );
    procedure print;
    procedure focusOn;
    procedure focusOff;
    procedure cursorRight;
    procedure cursorLeft;
    procedure cursorUp;
    procedure cursorDown;
    procedure setTNumber ( t : in integer );
    function getTNumber return integer;
    procedure setNumber ( t : in integer );
    function getNumber return integer;
  private
    fStarted     : boolean := false;
    fFocus       : boolean := false;
    iX           : integer := 0;
    iY           : integer := 0;
    iPos         : integer := 0;
    tLastChange  : time;
    tLastPaint   : time;
    iAnzStellen  : integer;
    strNumber    : string(1..80);
    strMaxNumber : string(1..80);
    iTNumber     : integer := 1;
  end ptoNumber2;

end pnumber2;
