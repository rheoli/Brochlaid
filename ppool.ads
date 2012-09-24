--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      04. Juni 1997                                          ==
--==   Modul:      ppool.ads                                              ==
--==   Verwendung: Pool mit Roboterkoordinaten fuer Roboter-              ==
--==               steuerung                                              ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================

with Ada.Text_io, int_io, rob3;
use  Ada.Text_io, int_io, rob3;

package ppool is

  kPosition : constant natural := 20;

  type ePosAktion is (kPANone, kPAFahren, kPAWarten, kPAFahrenundWarten, kPAManuell);

  type rPosition is
    record
      iCode      : ePosAktion := kPANone;
      dWartezeit : duration   := 0.0;    -- ???
      paPos      : POS_ARRAY_TYPE;       -- Pos = 0 bedeutet das nichts veraendert wird.
      gaGeschw   : GESCHW_ARRAY_TYPE;
    end record;

  type arPosition is array(1..kPosition) of rPosition;

  type rExtPosition is
    record
      iID   : integer       := 0;
      sInfo : string(1..80) := (OTHERS => ' ');
      aPos  : arPosition;
    end record;

  type rPositionsAblauf;
  type aPositionsAblauf is access rPositionsAblauf;

  type rPositionsAblauf is
    record
      aAblauf : rExtPosition;
      pNext   : aPositionsAblauf;
    end record;

  protected poPool is
    procedure start;
    entry add      ( pPos : in rExtPosition );
    entry edit     ( pPos : in rExtPosition );
    entry delete   ( iID : in integer );
    entry deleteAll;
    entry get      ( iID : in integer; pPos : out rExtPosition; fRet : out boolean );
    entry getFirst ( pPos : out rExtPosition; fRet : out boolean );
    entry getNext  ( pPos : out rExtPosition; fRet : out boolean );
    entry debug;
  private
    fRunning     : boolean          := false;
    pFirst       : aPositionsAblauf := null;
    pGetLoop     : aPositionsAblauf := null;
    iNextID      : integer          := 1;
  end poPool;

end ppool;

