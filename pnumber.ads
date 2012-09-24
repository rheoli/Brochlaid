--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      23. Juni 1997                                          ==
--==   Modul:      pnumber.ads                                           ==
--==   Verwendung: Nummereingabe-Element fuer CUI mit                     ==
--==               Kommastellenverarbeitung                               ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================

with Ada.Exceptions, Ada.Calendar;
use  Ada, Ada.Calendar;

package pnumber is
  NUMBER_not_initialized : exception;

  protected type ptoNumber is
    -- Start
    -- x, y: Position (x,y)
    -- s   : Anzahl Stellen Total
    -- ks  : davon Kommastellen
    -- m   : Max. Zahl die eingegeben werden kann
    -- d   : Default Zahl
    procedure start ( x : in integer; y : in integer; s : in integer; ks : in integer; m : in integer; d : in integer );
    procedure refresh ( fRet : out boolean );
    procedure print;
    procedure focusOn;
    procedure focusOff;
    procedure cursorRight;
    procedure cursorLeft;
    procedure cursorUp;
    procedure cursorDown;
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
    iKommaStelle : integer;
    iWidth       : integer;
    strNumber    : string(1..80);
    strMaxNumber : string(1..80);
  end ptoNumber;

end pnumber;
