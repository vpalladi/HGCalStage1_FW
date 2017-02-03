/*
---------------------------------------------------------------------------


---------------------------------------------------------------------------
*/

#include "uhal/uhal.hpp"

#include <iostream>
#include <iomanip>
#include <string>
#include <unistd.h>
#include <math.h> 

#include "calol2/FunkyMiniBus.hpp"


using namespace uhal;
using namespace calol2;



// --------------------------------------------------------------------------------------------
int main ( int argc,char* argv[] )
{

//  const uint32_t lSize( 8192 );

// Connect to the hardware
  ConnectionManager manager ( "file://${CALOL2_TESTS}/etc/calol2/connections-TDR.xml" );
  HwInterface hw=manager.getDevice ( "MP0" );

  FunkyMiniBus lBus( hw.getNode( "payload" ) );

// Dump the bus info to std::out
  std::cout << lBus << std::endl;

}
// --------------------------------------------------------------------------------------------
