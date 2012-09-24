--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      25. Juni 1997                                          ==
--==   Modul:      pregelungproc.ads                                      ==
--==   Verwendung: Proceduren zu Regelungssteuerung, sowie                ==
--==               Regelungstask                                          ==
--==                                                                      ==
--==   Copyright (c) 1997 by A.Rietsch, St.Toggweiler                     ==
--==                                                                      ==
--==========================================================================

package pRegelungProc is

  procedure refreshRegelung;
  procedure paintRegelung;
  procedure focus ( fRoby : in boolean );
  procedure type1Regelung ( iKey : in integer );
  procedure type4Regelung ( iKey : in integer );
  procedure initRegelung;
  procedure endRegelung;

  task tRegelung is
    entry startstop;
    entry quit;
  end tRegelung;
  
end pRegelungProc;
