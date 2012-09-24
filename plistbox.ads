--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      24. Juni 1997                                          ==
--==   Modul:      plistbox.ads                                           ==
--==   Verwendung: Listbox-Element fuer CUI                               ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================

with Ada.Exceptions, Ada.Calendar;
use  Ada, Ada.Calendar;

package plistbox is
  LB_not_initialized : exception;

  type rLine is
    record
      iID   : integer       := 0;
      sInfo : string(1..80) := (OTHERS => ' ');
    end record;

  type rLineP;
  type aLineP is access rLineP;

  type rLineP is
    record
      iZeile : integer := 0;
      aLine  : rLine;
      pNext  : aLineP;
    end record;

  protected type ptoListBox is
    procedure start    ( x : in integer; y : in integer; width : in integer; len : in integer; str : in string );
    procedure setInfo ( str : in String );
    procedure getInfo ( str : out String );
    procedure clsInfo;
    procedure refresh  ( fRet : out boolean );
    procedure add      ( pPos : in rLine );
    procedure insert   ( iZeile : in integer; pPos : in rLine );
    procedure delete   ( iID : in integer );
    procedure deleteAll;
    procedure get      ( iZeile : in integer; pPos : out rLine; fRet : out boolean );
    procedure print;
    procedure cursorUp;
    procedure cursorDown;
    function  getSelectedZeile return integer;
    procedure debug;
  private
    fStarted     : boolean := false;
    pFirst       : aLineP  := null;
    iNextID      : integer := 1;
    iSelected    : integer := 1;
    iX           : integer := 0;
    iY           : integer := 0;
    iLength      : integer := 0;
    iWidth       : integer := 0;
    iOffset      : integer := 0;
    fMoreUp      : boolean := false;
    fMoreDown    : boolean := false;
    tLastChange  : time;
    tLastPaint   : time;
    strInfo      : string(1..80) := (OTHERS => ' ');
    strTitle     : string(1..80) := (OTHERS => ' ');
    iTLen        : integer := 0;
  end ptoListBox;

end plistbox;

