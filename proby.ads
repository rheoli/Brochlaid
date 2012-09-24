--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      27. Juni 1997                                          ==
--==   Modul:      proby.ads                                              ==
--==   Verwendung: Robotertask                                            ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================

package proby is

  kpoLBRobyWidth : constant integer := 26;

  task toRoby is
    entry start;
    entry EndeWait;
  end toRoby;

end proby;
