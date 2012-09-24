--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      25. Juni 1997                                          ==
--==   Modul:      pchannel.ads                                           ==
--==   Verwendung: Channel zwischen Haupttask und Robotersteuerung        ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================

package pchannel is

  kpoLBChannelWidth : constant integer := 26;

  type rAblauf;
  type aAblauf is access rAblauf;

  type rAblauf is
    record
      iAblaufNr : integer   := 0;
      sInfo     : string(1..80);
      pPrev     : aAblauf   := null;
      Pnext     : aAblauf   := null;
    end record;

  protected poChannel is
    procedure start;
    entry add ( nr : in integer; str : in string );
    entry delete ( nr : in integer );
    entry deleteAll;
    entry getNext ( nr : out integer; str : out string );
    entry debug;
  private
    fRunning     : boolean := false;
    pFirstAblauf : aAblauf := null;
    pLastAblauf  : aAblauf := null;
  end poChannel;

end pchannel;

