//==========================================================================
//============                 Brochlaid                 ===================
//==========================================================================
//==                                                                      ==
//==   Echtzeitprogramm zur Steuerung eines Roboters und einer Regelung   ==
//==                                                                      ==
//==   Version:    1.00                                                   ==
//==   Datum:      03. Juli 1997                                          ==
//==   Modul:      in.c                                                   ==
//==   Verwendung: Terminal fuer CUI einstellen                           ==
//==                                                                      ==
//==   Copyright (c) 1997 by St.Toggweiler, A.Rietsch                     ==
//==                                                                      ==
//==========================================================================
//==                                                                      ==
//== Brochlaid is free software; you can redistribute it and/or modify    ==
//== it under the terms of the GNU General Public License as published by ==
//== the Free Software Foundation; either version 2 of the License, or    ==
//== (at your option) any later version.                                  ==
//==                                                                      ==
//== This program is distributed in the hope that it will be useful,      ==
//== but WITHOUT ANY WARRANTY; without even the implied warranty of       ==
//== MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        ==
//== GNU General Public License for more details (File COPYING).          ==
//==                                                                      ==
//== You should have received a copy of the GNU General Public License    ==
//== along with this program; if not, write to the Free Software          ==
//== Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.            ==
//==                                                                      ==
//==========================================================================

#include <stdio.h>
#include <termios.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/time.h>
#include <sys/fcntl.h>
 
static struct termios tOrigTTY, tNewTTY;

void resetTerm ( void )
{
  if ( tcsetattr (0, TCSADRAIN, &tOrigTTY) == -1 )  {
    printf ( "Error in tcsetattr\n" );
    exit ( 1 );
  }
}
 
void initTerm ( void )
{
  if ( tcgetattr(0, &tOrigTTY) == -1 )  {
    fprintf ( stderr, "Error in tcgetattr\n" );
    exit ( 1 );
  }
  memcpy ( &tNewTTY, &tOrigTTY, sizeof(struct termios) );
  tNewTTY.c_lflag    &= ~ICANON;
  tNewTTY.c_lflag    &= ~ECHO;
  tNewTTY.c_cc[VMIN]  = 1;
  tNewTTY.c_cc[VTIME] = 0;
  if ( tcsetattr (0, TCSADRAIN, &tNewTTY) == -1 )  {
    fprintf ( stderr, "Error in tcsetattr\n" );
    exit ( 1 );
  }
}

int waitForChar ( void )
{
  fd_set         fdMask;
  struct timeval tvWait;

  tvWait.tv_sec  = 1;
  tvWait.tv_usec = 0;

  FD_SET(0, &fdMask);

  if ( select ( 32, &fdMask, 0, 0, &tvWait ) == 0 )  {
    return ( 0 );
  }
  return ( 1 );
}

int getCharInBuff ( void )
{
  int nb;
  if ( waitForChar() != 0 )  {
    ioctl ( 0, FIONREAD, &nb );
    return ( nb );
  }
  return ( 0 );  
}

