--==========================================================================
--============                 Brochlaid                 ===================
--==========================================================================
--==                                                                      ==
--==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
--==                                                                      ==
--==   Version:    1.00                                                   ==
--==   Datum:      27. Juni 1997                                          ==
--==   Modul:      probyproc.adb                                          ==
--==   Verwendung: Allgemeine Robotersteuerungsproceduren                 ==
--==                                                                      ==
--==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
--==                                                                      ==
--==========================================================================
--==                                                                      ==
--== Brochlaid is free software; you can redistribute it and/or modify    ==
--== it under the terms of the GNU General Public License as published by ==
--== the Free Software Foundation; either version 2 of the License, or    ==
--== (at your option) any later version.                                  ==
--==                                                                      ==
--== This program is distributed in the hope that it will be useful,      ==
--== but WITHOUT ANY WARRANTY; without even the implied warranty of       ==
--== MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        ==
--== GNU General Public License for more details (File COPYING).          ==
--==                                                                      ==
--== You should have received a copy of the GNU General Public License    ==
--== along with this program; if not, write to the Free Software          ==
--== Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.            ==
--==                                                                      ==
--==========================================================================


with Ada.Text_io, pscreen, plistbox, plbroby, plbchannel, plbpool, proby, pchannel, pinfo,
     ppool, pcheckbox, pnumber, int_io, pedit, pnumber2, Ada.IO_Exceptions;
use  Ada.Text_io, pscreen, plistbox, plbroby, plbchannel, plbpool, proby, pchannel, pinfo,
     ppool, pcheckbox, pnumber, int_io, pedit, pnumber2;

package body probyproc is
  
  type eRobySideState is (kRSSChannel, kRSSPool, kRSSPoolEdit, kRSSManual);
  type ePoolEditType  is ( kPETNone, kPETAdd, kPETEdit );

  eState : eRobySideState := kRSSChannel;
  eEdit  : ePoolEditType  := kPETNone;
  
  poRWait   : ptoCheckbox;
  poRFahren : ptoCheckbox;
  poRNone   : ptoCheckbox;
  poEdit    : ptoEdit;
  poNumber  : array(1..6) of ptoNumber2;
  poTime    : ptoNumber;
  iNBSel    : integer := 1;
  iSeite    : integer := 1;
  posItem  : rExtPosition;


  procedure refreshRoby is
    fRet     : boolean := false;
    strTitle : string(1..80);
  begin
    poLBRoby.refresh ( fRet );
    if ( fRet ) then
      poLBRoby.getInfo ( strTitle );
      poScreen.putStringXY ( 13, 3, strTitle(1..20) );
      poLBRoby.print;
    end if;
    if ( eState = kRSSPool ) then
      poLBPool.refresh ( fRet );
      if ( fRet ) then
        poLBPool.print;
      end if;
    elsif ( eState = kRSSChannel ) then
      poLBChannel.refresh ( fRet );
      if ( fRet ) then
        poLBChannel.print;
      end if;
    elsif ( eState = kRSSPoolEdit ) then
      if ( iSeite = 1 ) then
        poEdit.refresh ( fRet );
        if ( fRet ) then
          poEdit.print;
        end if;
        null;
      else
        poRFahren.refresh ( fRet );
        if ( fRet ) then
          poRFahren.print;
        end if;
        poRWait.refresh ( fRet );
        if ( fRet ) then
          poRWait.print;
        end if;
        poRNone.refresh ( fRet );
        if ( fRet ) then
          poRNone.print;
        end if;
        poTime.refresh ( fRet );
        if ( fRet ) then
          poTime.print;
        end if;        
        for i in 1..6 loop
          poNumber(i).refresh ( fRet );
          if ( fRet ) then
            poNumber(i).print;
          end if;
        end loop;
      end if;
    elsif ( eState = kRSSManual ) then
      for i in 1..6 loop
        poNumber(i).refresh ( fRet );
        if ( fRet ) then
          poNumber(i).print;
        end if;
      end loop;
    end if;
  end;

  procedure focus ( fRoby : in boolean ) is
  begin
    if ( fRoby ) then
      if ( eState = kRSSPoolEdit ) then
        if ( iNBSel < 8 ) then
          if ( iSeite = 1 ) then
            poEdit.focusOn;
          else
            if ( iNBSel < 7 ) then
              poNumber(iNBSel).focusOn;
            else
              poTime.focusOn;
            end if;
          end if;
        else
          poScreen.paintInversWindow ( 4, 12, 33, 12, "" );
        end if;
      end if;
      if ( eState = kRSSManual ) then
        poNumber(iNBSel).focusOn;
      end if;
    else
      if ( eState = kRSSPoolEdit ) then
        if ( iNBSel < 8 ) then
          if ( iSeite = 1 ) then
            poEdit.focusOff;
          else
            if ( iNBSel < 7 ) then
              poNumber(iNBSel).focusOff;
            else
              poTime.focusOff;
            end if;
          end if;
        else
          poScreen.paintWindow ( 4, 12, 33, 12, "" );
        end if;
      end if;    
      if ( eState = kRSSManual ) then
        poNumber(iNBSel).focusOff;
      end if;
    end if;
  end;

  procedure initSeitenManual is
    lineItem : rLine;
    fRet     : boolean := false;
  begin
    posItem.sInfo := (OTHERS => ' ');
    posItem.sInfo(1..7) := "Manuell";
    posItem.iID   := 0;
    for i in 1..20 loop
      if ( i = 1 ) then
        posItem.aPos(i).iCode         := kPAManuell;
      else
        posItem.aPos(i).iCode         := kPANone;
      end if;
      posItem.aPos(i).dWartezeit    := 0.0;
      for j in 1..6 loop
        posItem.aPos(i).paPos(j)    := 0;
        posItem.aPos(i).gaGeschw(j) := 1;
      end loop;
    end loop;
    poPool.add ( posItem );
    iNBSel := 1;
    poNumber(1).start ( 9, 15, 3, 250, 0, 1 );
    poNumber(1).focusOn;
    poNumber(2).start ( 17, 15, 3, 250, 0, 1 );
    poNumber(2).focusOff;
    poNumber(3).start ( 25, 15, 3, 250, 0, 1 );
    poNumber(3).focusOff;
    poNumber(4).start ( 9, 19, 3, 250, 0, 1 );
    poNumber(4).focusOff;
    poNumber(5).start ( 17, 19, 3, 250, 0, 1 );
    poNumber(5).focusOff;
    poNumber(6).start ( 25, 19, 3, 250, 0, 1 );
    poNumber(6).focusOff;
  end;

  procedure initSeiten is
    lineItem : rLine;
    iZeile   : integer;
    fRet     : boolean := false;
  begin
    iSeite := 1;
    if ( eEdit = kPETAdd ) then
      posItem.sInfo := (OTHERS => ' ');
      posItem.iID   := 1;
      for i in 1..20 loop
        posItem.aPos(i).iCode         := kPANone;
        posItem.aPos(i).dWartezeit    := 0.0;
        for j in 1..6 loop
          posItem.aPos(i).paPos(j)    := 0;
          posItem.aPos(i).gaGeschw(j) := 1;
        end loop;
      end loop;
    else
      -- KPETEdit
      iZeile := poLBPool.getSelectedZeile;
      poLBPool.get ( iZeile, lineItem, fRet );
      if ( fRet = false ) then
        eEdit  := kPETNone;
        eState := kRSSPool;
        poLBPool.print;
        return;
      end if;
      poPool.get ( lineItem.iID, posItem, fRet );
      if ( fRet = false ) then
        eEdit  := kPETNone;
        eState := kRSSPool;
        poLBPool.print;
        return;
      end if;      
    end if;
    poScreen.clsWindow ( 5, 13, 30, 10 );
    poScreen.putStringXY ( 31, 21, "( 1)" );
    -- Edit
    poEdit.start ( 10, 17, 20, posItem.sInfo );
    poEdit.focusOn;
    poEdit.print;
    -- Fahren
    poRFahren.start ( 8, 14, false );
    poNumber(1).start ( 12, 14, 3, 250, 0, 1 );
    poNumber(1).focusOn;
    poNumber(2).start ( 19, 14, 3, 250, 0, 1 );
    poNumber(2).focusOff;
    poNumber(3).start ( 26, 14, 3, 250, 0, 1 );
    poNumber(3).focusOff;
    poNumber(4).start ( 12, 17, 3, 250, 0, 1 );
    poNumber(4).focusOff;
    poNumber(5).start ( 19, 17, 3, 250, 0, 1 );
    poNumber(5).focusOff;
    poNumber(6).start ( 26, 17, 3, 250, 0, 1 );
    poNumber(6).focusOff;
    -- Warten
    poRWait.start ( 8, 20, false );
    poTime.start ( 12, 20, 5, 1, 99999, 100 );
    poTime.focusOff;
    -- None
    poRNone.start ( 8, 22, false );
  end;
  
  procedure printSeite1 is
  begin
    poScreen.clsWindow ( 5, 13, 30, 10 );
    poScreen.putStringXY ( 31, 21, "( 1)" );
    -- Edit
    poEdit.print;
  end;
  
  procedure printRSeite is
    strSeite : string(1..4);
  begin
    iNBSel := 8;
    poScreen.clsWindow ( 5, 13, 30, 10 );
    strSeite := "(  )";
    put ( strSeite(2..3), iSeite );
    poScreen.putStringXY ( 31, 21, strSeite );
    -- Fahren
    poScreen.putCharXY ( 6, 14, CHARACTER'POS('F') );
    poRFahren.print;
    for i in 1..6 loop      
      poNumber(i).focusOff;
      poNumber(i).print;
    end loop;
    poTime.focusOff;
    poTime.print;
    -- Warten
    poScreen.putCharXY ( 6, 20, CHARACTER'POS('W') );
    poRWait.print;
    -- None
    poScreen.putCharXY ( 6, 22, CHARACTER'POS('N') );
    poRNone.print;
  end;

  procedure readPage is
  begin
    if ( iSeite = 1 ) then
      poEdit.getString ( posItem.sInfo );
    else            
      if ( (poRWait.isSelected) and (not poRFahren.isSelected) and (not poRNone.isSelected) ) then
        posItem.aPos(iSeite-1).iCode := kPAWarten;
      elsif ( (not poRWait.isSelected) and (poRFahren.isSelected) and (not poRNone.isSelected) ) then
        posItem.aPos(iSeite-1).iCode := kPAFahren;
      elsif ( (poRWait.isSelected) and (poRFahren.isSelected) and (not poRNone.isSelected) ) then
        posItem.aPos(iSeite-1).iCode := kPAFahrenundWarten;
      else
        posItem.aPos(iSeite-1).iCode := kPANone;
      end if;
      posItem.aPos(iSeite-1).dWartezeit := duration(float(poTime.getNumber)/10.0);
      for i in 1..6 loop
        posItem.aPos(iSeite-1).paPos(i)    := poNumber(i).getNumber;
        posItem.aPos(iSeite-1).gaGeschw(i) := poNumber(i).getTNumber;
      end loop;            
    end if;
  end;

  procedure writePage is
  begin
    if ( iSeite = 1 ) then
      poEdit.setString ( posItem.sInfo );
      printSeite1;
    else
      poRWait.setState ( false );
      poRFahren.setState ( false );
      poRNone.setState ( true );
      if ( (posItem.aPos(iSeite-1).iCode=kPAWarten) or (posItem.aPos(iSeite-1).iCode=kPAFahrenundWarten) ) then
        poRWait.setState ( true );
        poRNone.setState ( false );
      end if;
      if ( (posItem.aPos(iSeite-1).iCode=kPAFahren) or (posItem.aPos(iSeite-1).iCode=kPAFahrenundWarten) ) then
        poRFahren.setState ( true );
        poRNone.setState ( false );
      end if;
      poTime.setNumber ( integer(posItem.aPos(iSeite-1).dWartezeit*10.0) );
      for i in 1..6 loop              
        poNumber(i).setNumber ( posItem.aPos(iSeite-1).paPos(i) );
        poNumber(i).setTNumber ( posItem.aPos(iSeite-1).gaGeschw(i) );
      end loop;            
      printRSeite;
    end if;
  end;


  procedure type1Roby ( iKey : in integer ) is
    fRet     : boolean := false;
    lineItem     : rLine;
    iZeile   : integer := 0;
  begin
  
    -- Channel
    if ( eState = kRSSChannel ) then
      if ( iKey = 114 ) then
        -- 'r'
        poInfo.reset;
      elsif ( iKey = 115 ) then
        -- 's'
        poInfo.start;
      elsif ( iKey = 116 ) then
        -- 't'
        poInfo.stop;
      elsif ( iKey = 109 ) then
        -- 'm'
        eState := kRSSManual;
        eEdit  := kPETAdd;
        initSeitenManual;
        poScreen.clsWindow ( 4, 12, 33, 12 );
        poScreen.paintWindow ( 4, 12, 33, 12, " Manuell Steuerung " );
        for i in 1..6 loop
          poNumber(i).print;
        end loop;
      end if;
      
    -- Pool
    elsif ( eState = kRSSPool ) then
      if ( iKey = 27 ) then
        eState := kRSSChannel;
        poScreen.clsWindow ( 4, 12, 33, 12 );
        poLBChannel.print;
      elsif ( iKey = 10 ) then
        eState := kRSSChannel;
        poScreen.clsWindow ( 4, 12, 33, 12 );
        poLBChannel.print;
        iZeile := poLBPool.getSelectedZeile;
        poLBPool.get ( iZeile, lineItem, fRet );
        if ( fRet ) then
          poChannel.add ( lineItem.iID, lineItem.sInfo );
        end if;
      elsif ( iKey = 97 ) then
        eState := kRSSPoolEdit;
        eEdit  := kPETAdd;
        initSeiten;
      elsif ( iKey = 100 ) then
        iZeile := poLBPool.getSelectedZeile;
        poLBPool.get ( iZeile, lineItem, fRet );        
        poPool.delete ( lineItem.iID );
      elsif ( iKey = 101 ) then
        eState := kRSSPoolEdit;
        eEdit  := kPETEdit;
        initSeiten;
      end if;
      
    -- Pool-Edit
    elsif ( eState = kRSSPoolEdit ) then
      if ( iKey = 27 ) then
        readPage;
        eState := kRSSPool;
        if ( eEdit = kPETAdd ) then
          poPool.add ( posItem );
        else
          poPool.edit ( posItem );
        end if;
        poLBPool.print;      
      elsif ( iSeite = 1 ) then
        -- {A-Z},{a-z},{' '}
        if ( ((iKey>=65) and (iKey<=90)) or ((iKey>=97) and (iKey<=122)) or (iKey=32) ) then
          poEdit.insertChar ( iKey );
        -- {0-9},{_},{-},{&}
        elsif ( ((iKey>=48) and (iKey<=57)) or (iKey=95) or (iKey=45) or (iKey=38) ) then
          poEdit.insertChar ( iKey );
        -- '<-'-Taste
        elsif ( iKey = 127 ) then
          poEdit.delChar;
        end if;
      else
        if ( (iNBSel<7) and then ((iKey>=49) and (iKey<=54)) ) then
          poNumber(iNBSel).setTNumber ( iKey-CHARACTER'POS('0') );        
        elsif ( iKey = 102 ) then
          poRFahren.switchState;
          if ( poRFahren.isSelected ) then
            poRNone.setState ( false );
          end if;
        elsif ( iKey = 119 ) then
          poRWait.switchState;
          if ( poRWait.isSelected ) then
            poRNone.setState ( false );
          end if;
        elsif ( iKey = 110 ) then
          poRNone.switchState;
          if ( poRNone.isSelected ) then
            poRFahren.setState ( false );
            poRWait.setState ( false );
          end if;
        end if;
      end if;
    elsif ( eState = kRSSManual ) then
      if ( iKey = 27 ) then
        eState := kRSSChannel;
        poScreen.clsWindow ( 4, 12, 33, 12 );
        poLBChannel.print;
        for i in 1..6 loop
          posItem.aPos(1).gaGeschw(i) := 1;
        end loop;            
        posItem.aPos(1).paPos(1) := 128;
        posItem.aPos(1).paPos(2) := 164;
        posItem.aPos(1).paPos(3) := 140;
        posItem.aPos(1).paPos(4) := 182;
        posItem.aPos(1).paPos(5) :=  14;
        posItem.aPos(1).paPos(6) := 128;
        poPool.edit ( posItem );
        poChannel.add ( 0, posItem.sInfo );
      elsif ( iKey = 103 ) then
        -- 'G'o: mit Roboterarm nach poNumber fahren
        for i in 1..6 loop
          posItem.aPos(1).paPos(i)    := poNumber(i).getNumber;
          posItem.aPos(1).gaGeschw(i) := poNumber(i).getTNumber;
        end loop;
        poPool.edit ( posItem );
        poChannel.add ( 0, posItem.sInfo );
      elsif ( (iKey>=49) and (iKey<=54) ) then
        poNumber(iNBSel).setTNumber ( iKey-CHARACTER'POS('0') );                
      end if;
    end if;
  end;

  procedure type4Roby ( iKey : in integer ) is
    lineItem : rLine;
    iZeile   : integer := 0;
    fRet     : boolean := false;
  begin
    if ( iKey = 1 ) then
      -- Cursor Up
      if ( eState = kRSSPool ) then
        poLBPool.cursorUp;
      elsif ( eState = kRSSChannel ) then
        poLBChannel.cursorUp;
      elsif ( eState = kRSSPoolEdit ) then
        if ( (iSeite/=1) and then (iNBSel<8) ) then
          if ( iNBSel < 7 ) then
            poNumber(iNBSel).cursorUp;
          else
            poTime.cursorUp;
          end if;
        end if;
      elsif ( eState = kRSSManual ) then
        poNumber(iNBSel).cursorUp;
      end if;
    elsif ( iKey = 2 ) then
      -- Cursor Down
      if ( eState = kRSSPool ) then
        poLBPool.cursorDown;
      elsif ( eState = kRSSChannel ) then
        poLBChannel.cursorDown;
      elsif ( eState = kRSSPoolEdit ) then
        if ( (iSeite/=1) and then (iNBSel<8) ) then
          if ( iNBSel < 7 ) then
            poNumber(iNBSel).cursorDown;
          else
            poTime.cursorDown;
          end if;
        end if;
      elsif ( eState = kRSSManual ) then
        poNumber(iNBSel).cursorDown;
      end if;
    elsif ( iKey = 3 ) then
      -- Cursor rechts      
      if ( eState = kRSSPoolEdit ) then
        if ( iNBSel < 8 ) then
          if ( iSeite = 1 ) then
            poEdit.cursorRight;
          else
            if ( iNBSel < 7 ) then
              poNumber(iNBSel).cursorRight;
            else
              poTime.cursorRight;
            end if;
          end if;
        else        
          readPage;
          iSeite := iSeite + 1;
          if ( iSeite > 21 ) then
            iSeite := 1;
          else
            if ( ((iSeite-2)>0) and then ((posItem.aPos(iSeite-2).iCode=kPANone) and (posItem.aPos(iSeite-1).iCode=kPANone)) ) then
              iSeite := 1;
            end if;
          end if;
          writePage;
        end if;
      elsif ( eState = kRSSManual ) then
        poNumber(iNBSel).cursorRight;
      end if;
    elsif ( iKey = 4 ) then
      -- Cursor links
      if ( eState = kRSSPoolEdit ) then
        if ( iNBSel < 8 ) then
          if ( iSeite = 1 ) then
            poEdit.cursorLeft;
          else
            if ( iNBSel < 7 ) then
              poNumber(iNBSel).cursorLeft;
            else
              poTime.cursorLeft;
            end if;
          end if;
        else
          readPage;
          iSeite := iSeite - 1;
          if ( iSeite < 1 ) then
            iSeite := 21;
            for i in 1..19 loop              
              if ( posItem.aPos(i).iCode = kPANone ) then
                iSeite := i + 1;
                exit;
              end if;
            end loop;
          end if;
          writePage;
        end if;
      elsif ( eState = kRSSManual ) then
        poNumber(iNBSel).cursorLeft;
      end if;
    elsif ( iKey = 5 ) then
      -- PgUp
      if ( eState = kRSSPoolEdit ) then
        if ( iNBSel < 8 ) then
          if ( iSeite = 1 ) then
            poEdit.focusOff;
          else
            if ( iNBSel < 7 ) then
              poNumber(iNBSel).focusOff;
            else
              poTime.focusOff;
            end if;
          end if;
        else
          poScreen.paintWindow ( 4, 12, 33, 12, "" );
        end if;
        if ( iSeite = 1 ) then
          if ( iNBSel < 8 ) then
            iNBSel := 8;
          else
            iNBSel := 1;
          end if;
        else
          iNBSel := iNBSel - 1;
          if ( iNBSel < 1 ) then
            iNBSel := 8;
          end if;
        end if;
        if ( iNBSel < 8 ) then
          if ( iSeite = 1 ) then
            poEdit.focusOn;
          else        
            if ( iNBSel < 7 ) then
              poNumber(iNBSel).focusOn;
            else
              poTime.focusOn;
            end if;
          end if;
        else
          poScreen.paintInversWindow ( 4, 12, 33, 12, "" );
        end if;
      elsif ( eState = kRSSManual ) then
        poNumber(iNBSel).focusOff;
        iNBSel := iNBSel - 1;
        if ( iNBSel < 1 ) then
          iNBSel := 6;
        end if;
        poNumber(iNBSel).focusOn;
      end if;
    elsif ( iKey = 6 ) then
      -- PgDn
      if ( eState = kRSSPoolEdit ) then
        if ( iNBSel < 8 ) then
          if ( iSeite = 1 ) then
            poEdit.focusOff;
          else
            if ( iNBSel < 7 ) then
              poNumber(iNBSel).focusOff;
            else
              poTime.focusOff;
            end if;
          end if;
        else
          poScreen.paintWindow ( 4, 12, 33, 12, "" );
        end if;
        if ( iSeite = 1 ) then
          if ( iNBSel < 8 ) then
            iNBSel := 8;
          else
            iNBSel := 1;
          end if;
        else      
          iNBSel := iNBSel + 1;
          if ( iNBSel > 8 ) then
            iNBSel := 1;
          end if;
        end if;
        if ( iNBSel < 8 ) then
          if ( iSeite = 1 ) then
            poEdit.focusOn;
          else        
            if ( iNBSel < 7 ) then
              poNumber(iNBSel).focusOn;
            else
              poTime.focusOn;
            end if;
          end if;
        else
          poScreen.paintInversWindow ( 4, 12, 33, 12, "" );
        end if;
      elsif ( eState = kRSSManual ) then
        poNumber(iNBSel).focusOff;
        iNBSel := iNBSel + 1;
        if ( iNBSel > 6 ) then
          iNBSel := 1;
        end if;
        poNumber(iNBSel).focusOn;
      end if;
    elsif ( (iKey=7) and then (eState=kRSSChannel) ) then
      -- <INS>
      poLBPool.print;
      eState := kRSSPool;
    elsif ( (iKey=8) and then (eState=kRSSChannel) ) then
      -- <DEL>
      iZeile := poLBChannel.getSelectedZeile;
      poLBChannel.get ( iZeile, lineItem, fRet );
      if ( fRet ) then
        poLBChannel.delete ( lineItem.iID );
      end if;
    end if;
  end;

  procedure loadPoolData is
    sItem  : rExtPosition;
    handle : file_type;
    iNr    : integer;
  begin
    open ( handle, in_file, "roby.dat" );
    get ( handle, iNr );
    while ( iNr = 1 ) loop
      get ( handle, sItem.sInfo );
      get ( handle, sItem.iID );
      for i in 1..20 loop      
        get ( handle, iNr );
        sItem.aPos(i).iCode := ePosAktion'VAL(iNr);
        get ( handle, iNr );
        sItem.aPos(i).dWartezeit := duration(iNr)/10.0;
        for j in 1..6 loop              
          get ( handle, sItem.aPos(i).paPos(j) );
          get ( handle, sItem.aPos(i).gaGeschw(j) );
        end loop;
      end loop;
      poPool.add ( sItem );
      get ( handle, iNr );
    end loop;
    close ( handle );      
  exception
    when ada.io_exceptions.name_error =>
      null;
    when others =>
      raise;
  end;

  procedure savePoolData is
    handle : file_type;
    sItem  : rExtPosition;
    fRet   : boolean := false;
    iNr    : integer := 1;
  begin
    create ( file=>handle, name=>"roby.dat" );
    poPool.getFirst ( sItem, fRet );
    while ( fRet ) loop
      put ( handle, iNr );
      new_line ( handle );
      put ( handle, sItem.sInfo );
      new_line ( handle );
      put ( handle, sItem.iID );
      for i in 1..20 loop      
        put ( handle, ePosAktion'POS(sItem.aPos(i).iCode) );
        put ( handle, integer(sItem.aPos(i).dWartezeit)*10 );
        for j in 1..6 loop              
          put ( handle, sItem.aPos(i).paPos(j) );
          put ( handle, sItem.aPos(i).gaGeschw(j) );
        end loop;
        new_line ( handle );
      end loop;      
      poPool.getNext ( sItem, fRet );
    end loop;
    iNr := 0;   
    put ( handle, iNr );
    new_line ( handle );
    close ( handle );      
  end;

  procedure initRoby is
  begin  
    -- Zwischenverbindungen starten
    poPool.start;
    poChannel.start;

    -- Listboxen initialisieren
    poLBRoby.start ( 5, 5, kpoLBRobyWidth, 6, " Roboterablauf " );
    poLBChannel.start ( 5, 13, kpoLBChannelWidth, 6, " Auftragqueue " );
    poLBPool.start ( 5, 13, 30, 10, " Auftrag-Edit " );

    -- Pool fuellen
    loadPoolData;

    -- Roboter-Task starten
    toRoby.start;
  end;

  procedure paintRoby is
  begin
    -- Roboterausgabe-Listbox
    poScreen.putStringXY ( 5, 3, "Auftrag:" );
    poLBRoby.print;

    -- Roboter freigeben
    poScreen.putStringXY ( 5, 25, "Roboter:" );
    poInfo.start;
    poScreen.putStringXY ( 14, 25, "wartet                 " );

    -- Channel-Listbox zeichnen  
    poLBChannel.print;
  end;

  procedure endRoby is
    strSpace : string(1..80) := (OTHERS => ' ');
  begin
    poInfo.ende;
    poChannel.add ( 0, strSpace );
    savePoolData;
  end;
      
end probyproc;
