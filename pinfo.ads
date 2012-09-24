--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      30. Juni 1997                                          ==
--==   Modul:      pinfo.ads                                              ==
--==   Verwendung: Informationsaustausch zwischen Haupttask und           ==
--==               Robotersteuerung:                                      ==
--==                - Start, Stop (mit Blockeren der Roboterst.),         ==
--==                  Reset und Ende                                      ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================

package pinfo is

  type eInfos is (kRINone, kRIRunning, kRIStopped, kRIReset, kRIEnd, kRIError);

  protected poInfo is
    procedure start;
    procedure stop;
    procedure reset;
    procedure ende;
    procedure error;
    entry getState ( iState : out eInfos );
  private
    iRobostate : eInfos  := kRIStopped;
  end poInfo;

end pinfo;
