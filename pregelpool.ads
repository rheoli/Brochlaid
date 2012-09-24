--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      25. Juni 1997                                          ==
--==   Modul:      pregelpool.ads                                         ==
--==   Verwendung: Pool fuer Regelungsdaten                               ==
--==                                                                      ==
--==   Copyright (c) 1997 by A.Rietsch, St.Toggweiler                     ==
--==                                                                      ==
--==========================================================================

package pregelpool is

  -- Regelintervall
  iTimeIntervall : integer;

  -- neue Abtastzeit und Verstaerkung setzen
  procedure setVerhalten(Kr, Ti : in float);

  protected param is
    
    -- set new variables
    procedure set(ib0, ib1 : in float);

    -- read parameters for calculation
    procedure read(ob0, ob1 : out float);

  private

    -- Parameter
    b0, b1 : float;

  end param;

end pregelpool;