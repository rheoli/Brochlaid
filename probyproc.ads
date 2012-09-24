--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      27. Juni 1997                                          ==
--==   Modul:      probyproc.ads                                          ==
--==   Verwendung: Allgemeine Robotersteuerungsproceduren                 ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================

package pRobyProc is

  procedure refreshRoby;
  procedure type1Roby ( iKey : in integer );
  procedure type4Roby ( iKey : in integer );
  procedure focus ( fRoby : in boolean );
  procedure loadPoolData;
  procedure savePoolData;
  procedure initRoby;
  procedure paintRoby;
  procedure endRoby;
      
end pRobyProc;
