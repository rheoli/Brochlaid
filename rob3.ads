-----------------------------------------------------------------------------
-- FILE    : rob3_.ada
-- DATUM   : 09.09.94
-- AUTOREN : P. Lang, T. Zehnder
-- ZWECK   : Das Package ROB3 implementiert die Ansteuerungsfunktionen fuer 
--           den Roboter ROB3 der Firma P+P Elektronik GmbH Nuernberg ueber
--           die serielle Schnittstelle 2 ( /dev/tty01 ) des DEC Alpha 2000 
--           Model 300 Rechners unter OSF/1 und verwendet hierzu POSIX 
--           kompatible Aufrufe zur Konfiguration der Schnittstelle
-- AENDERUNGEN : 20.09.94 Namensanpassungen an Robotertask von J. Liechti und
--                        M. Wirz
--
--               03.10.96 Portierung des Package fuer GNAT Ada95 durch
--                        R.Barandund und C.Werder
-----------------------------------------------------------------------------

package ROB3 is

   -- Filename der zu verwendenden Schnittstelle
   DEV_NAME : constant STRING := "/dev/tty01" & ascii.nul;

   N_ACHSEN        : constant INTEGER := 6; -- Anzahl Roboterachsen
   N_GESCHW_STUFEN : constant INTEGER := 5; -- Anzahl Geschwindigkeitsstufen

   subtype POS_TYPE    is INTEGER range 0 .. 255;
   subtype ACHSEN_TYPE is INTEGER range 1 .. N_ACHSEN;
   subtype GESCHW_TYPE is INTEGER range 1 .. N_GESCHW_STUFEN;

   type POS_ARRAY_TYPE    is array (1..N_ACHSEN) of POS_TYPE;
   type GESCHW_ARRAY_TYPE is array (1..N_ACHSEN) of GESCHW_TYPE;

   ----------------------------------------------------------------------------
   --  TERMINATE_COMMUNICATIONS
   ----------------------------------------------------------------------------
   --  Purpose    : Die Verbindung zum Roboter wird abgebrochen.
   ----------------------------------------------------------------------------
   procedure TERMINATE_COMMUNICATIONS;

   ----------------------------------------------------------------------------
   --  INIT_ROB
   ----------------------------------------------------------------------------
   procedure INIT_ROB (SUCCESS : out BOOLEAN);

   ----------------------------------------------------------------------------
   --  SET_POS
   ----------------------------------------------------------------------------
   --  Purpose    : Eine Achse wird positioniert.
   ----------------------------------------------------------------------------
   procedure SET_POS (ACHSE   : in     ACHSEN_TYPE;
                      POS     : in     POS_TYPE;
                      SUCCESS :    out BOOLEAN);

   ----------------------------------------------------------------------------
   --  SET_POS_ALL
   ----------------------------------------------------------------------------
   --  Purpose    : Alle Achsen werden positioniert.
   ----------------------------------------------------------------------------
   procedure SET_POS_ALL (POS_ARRAY  : in     POS_ARRAY_TYPE;
                          SUCCESS    :    out BOOLEAN);

   ----------------------------------------------------------------------------
   --  SET_POS_V
   ----------------------------------------------------------------------------
   --  Purpose    : Eine Achse wird positioniert. Zusaetzlich kann eine
   --     Positionierungsgeschwindigkeit angegeben werden.
   ----------------------------------------------------------------------------
   procedure SET_POS_V (ACHSE   : in     ACHSEN_TYPE;
                        POS     : in     POS_TYPE;
                        GESCHW  : in     GESCHW_TYPE;
                        SUCCESS :    out BOOLEAN);

   ----------------------------------------------------------------------------
   --  SET_POS_ALL_V
   ----------------------------------------------------------------------------
   --  Purpose    : Alle Achsen werden positioniert. Zusaetzlich kann fuer
   --     jede Achse die Positionierungsgeschwindigkeit angegeben werden.
   ----------------------------------------------------------------------------
   procedure SET_POS_ALL_V (POS_ARRAY     : in     POS_ARRAY_TYPE;
                            GESCHW_ARRAY  : in     GESCHW_ARRAY_TYPE;
                            SUCCESS       :    out BOOLEAN);

   ----------------------------------------------------------------------------
   --  READ_POS
   ----------------------------------------------------------------------------
   --  Purpose    : Eine Achsenposition wird gelesen.
   ----------------------------------------------------------------------------
   procedure READ_POS (ACHSE    : in     ACHSEN_TYPE;
                       POSITION :    out POS_TYPE;
                       SUCCESS  :    out BOOLEAN);
   ----------------------------------------------------------------------------
   --  READ_POS_ALL
   ----------------------------------------------------------------------------
   --  Purpose    : Alle Achsenpositionen werden gelesen.
   ----------------------------------------------------------------------------
   procedure READ_POS_ALL (POS_ARRAY : out POS_ARRAY_TYPE;
                           SUCCESS   : out BOOLEAN);

end ROB3;

