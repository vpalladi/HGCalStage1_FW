/*
---------------------------------------------------------------------------

    This file is part of uHAL.

    uHAL is a hardware access library and programming framework
    originally developed for upgrades of the Level-1 trigger of the CMS
    experiment at CERN.

    uHAL is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    uHAL is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with uHAL.  If not, see <http://www.gnu.org/licenses/>.

      Andrew Rose, Imperial College, London
      email: awr01 <AT> imperial.ac.uk

---------------------------------------------------------------------------
*/

#include <unordered_map> 
#include <string>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <signal.h>
// #include <unistd.h>

#include <boost/program_options.hpp>
#include "boost/date_time/posix_time/posix_time.hpp" 


#include "uhal/uhal.hpp"
#include "uhal/log/exception.hpp"

#include "calol2/FunkyMiniBus.hpp"

using namespace uhal;
using namespace calol2;

// -----------------------------------------------------------------------------------------------
bool gInterrupted( false );

void CtrlcHandler( int s ){
  std::cout << std::endl << "Caught Ctrl-C: Will exit next time it is safe to do so" << std::endl;
  gInterrupted = true;
}
// -----------------------------------------------------------------------------------------------


// -----------------------------------------------------------------------------------------------
int ParseCommandLine( int argc, char* argv[] , std::string& aBoard, std::string& aConnections , bool& aImmediate , bool& aDelayed )
{
  using namespace boost::program_options;

  // Declare the supported options.
  options_description desc ( "Allowed options" );
  desc.add_options()
  ( "help,h", "Produce help message" )
  ( "connections,c", value< std::string > ( &aConnections )->default_value("file://${CALOL2_ROOT}/tests/etc/calol2/connections-Schroff2.xml") , "Select connection file" )
  ( "target,t", value< std::string > ( &aBoard )->required() , "Select target board (Required)" )
  ( "immediate,i" , "Read each endpoint immediately after write" )
  ( "delayed,d" , "Read all endpoints after write completed" )
  ;

  variables_map vm;

  try{
    store ( parse_command_line ( argc, argv, desc ), vm );
    notify ( vm );
  }catch( const std::exception& e ){
    std::cout << e.what() << std::endl;    
    std::cout << desc << std::endl;
    return 1;
  }

  aImmediate = bool( vm.count("immediate") );
  aDelayed = bool( vm.count("delayed") );

  if ( !( aImmediate || aDelayed ) )
  {
    std::cout << "Must specify either 'immediate' or 'delayed'" << std::endl;
    std::cout << desc << std::endl;
    return 1;    
  }

  if ( aImmediate && aDelayed )
  {
    std::cout << "Cannot specify both 'immediate' and 'delayed'" << std::endl;
    std::cout << desc << std::endl;
    return 1;    
  }

  return 0;
}
// -----------------------------------------------------------------------------------------------


// -----------------------------------------------------------------------------------------------
// FunkyMiniBus CreateBus( const std::string& aBoard, const std::string& aConnections )
// {
//   // Connect to the hardware
//   std::cout << "Board: " << aBoard << std::endl;
//   ConnectionManager manager ( aConnections );
//   HwInterface hw = manager.getDevice ( aBoard );
//   FunkyMiniBus lBus( hw.getNode< FunkyMiniBus >( "payload" ) );
//   std::cout << "Bus:\n" << lBus << std::endl;
//   return lBus;
// }
// -----------------------------------------------------------------------------------------------


// -----------------------------------------------------------------------------------------------
void MakeRandomData( const FunkyMiniBus& aBus , std::list< std::vector< uint32_t > >& aData )
{
  FunkyMiniBus::const_iterator lBusIt( aBus.begin() );
  std::list< std::vector< uint32_t > >::iterator lDataIt( aData.begin() );

  // Iterate over the bus
  for( ; lBusIt != aBus.end() ; ++lBusIt , ++lDataIt )
  {
    // Create a bit mask
    uint32_t lMask( 0 );
    for( uint32_t i(0) ; i!= (lBusIt->width() % 32) ; ++i ) lMask |= (0x1<<i);

    // Create some random data
    for( std::vector< uint32_t >::iterator lDataIt2( lDataIt->begin()) ; lDataIt2 != lDataIt->end() ; ++lDataIt2 ) *lDataIt2 = rand() & lMask;
  }
}
// -----------------------------------------------------------------------------------------------


// -----------------------------------------------------------------------------------------------
void Write( const FunkyMiniBus::iterator& aBusIt , 
            const std::list< std::vector< uint32_t > >::iterator& aDataIt , std::list< std::vector< uint32_t > >::iterator& aReadIt , 
            boost::posix_time::time_duration& aWriteAccessTimer )
{
  // Write the data
  boost::posix_time::ptime lStart(boost::posix_time::microsec_clock::local_time());          
  aBusIt->write( *aDataIt );
  boost::posix_time::ptime lEnd(boost::posix_time::microsec_clock::local_time());
  aWriteAccessTimer += ( lEnd - lStart );
}
// -----------------------------------------------------------------------------------------------


// -----------------------------------------------------------------------------------------------
void ReadAndValidate( const FunkyMiniBus::iterator& aBusIt , 
                      const std::list< std::vector< uint32_t > >::iterator& aDataIt , std::list< std::vector< uint32_t > >::iterator& aReadIt , 
                      boost::posix_time::time_duration& aReadAccessTimer )
{
  // Read the data
  boost::posix_time::ptime lStart(boost::posix_time::microsec_clock::local_time());
  *aReadIt = aBusIt->read();
  boost::posix_time::ptime lEnd(boost::posix_time::microsec_clock::local_time());
  aReadAccessTimer += ( lEnd - lStart );

  // Check that the data is the correct size
  if( aDataIt->size() != aReadIt->size() )
  {
    std::cout << std::endl << "Caught error accessing '" << aBusIt->name() << "', which is of width " << aBusIt->width() << " and total size " << aBusIt->size() << "." << std::endl;
    std::cout << "Expected data of size " << aDataIt->size() << "words but found " << aReadIt->size() << "words." << std::endl;
    gInterrupted = true;
    return;              
  }

  // It is, so verify
  std::vector< uint32_t >::const_iterator a( aDataIt->begin() ) , b( aReadIt->begin() );
  for( ; a != aDataIt->end() ; ++a , ++b )
  {
    if( *a != *b )
    {
      std::cout << std::endl << "Caught error accessing '" << aBusIt->name() << "', which is of width " << aBusIt->width() << " and total size " << aBusIt->size() << "." << std::endl;
      std::cout << "On frame " << ( a - aDataIt->begin() ) << " found 0x" << std::hex << std::setw(8) << *b << " but was expecting " << std::setw(8) << *a << "." << std::endl;
      gInterrupted = true;
    }
  }

}
// -----------------------------------------------------------------------------------------------






// --------------------------------------------------------------------------------------------
int main ( int argc,char* argv[] )
{
  try{
    // Utility code
    srand( time( NULL ) );

    // Register Ctrl-C handler
    signal ( SIGINT , CtrlcHandler );

    // Get the command-line options
    std::string lBoard , lConnections;
    bool lImmediate , lDelayed;
    if( ParseCommandLine( argc, argv , lBoard, lConnections , lImmediate , lDelayed ) ) return 1;
 
    // Connect to the hardware
    std::cout << "Board: " << lBoard << std::endl;
    ConnectionManager manager ( lConnections );
    HwInterface hw( manager.getDevice ( lBoard ) );
    FunkyMiniBus lBus( hw.getNode( "payload" ) );
    FunkyMiniBus::iterator lBusIt( lBus.begin() );

    // Prepare space for data
    std::list< std::vector< uint32_t > > lData , lRead;
    std::list< std::vector< uint32_t > >::iterator lDataIt, lReadIt;
    for( FunkyMiniBus::iterator lBusIt( lBus.begin() ) ; lBusIt != lBus.end() ; ++lBusIt  )
    {
      uint32_t lWordCount( ceil( lBusIt->size() / double( ( lBusIt->width() < 32 ) ? lBusIt->width() : 32 ) ) );
      lData.push_back( std::vector< uint32_t >( lWordCount , 0x00000000 ) );
      lRead.push_back( std::vector< uint32_t >( lWordCount , 0x00000000 ) );
    }

    // Prepare some timers
    boost::posix_time::time_duration lWriteAccessTimer , lReadAccessTimer;
    boost::posix_time::ptime lRunStart(boost::posix_time::microsec_clock::local_time());


    // Some debug info
    std::cout << "Bus:\n" << lBus << std::endl;
    std::cout << std::setfill('0') << "|  Iteration  |   Running time  |           Write (Average)         |            Read (Average)         |" << std::endl;

    // Some small number of iterations
    for( uint32_t lIteration(0) ; lIteration != 0xFFFFFFFF ; ++lIteration )
    { 

      // Make some random data
      MakeRandomData( lBus , lData );

      // Unlock the bus    
      lBus.unlock();

      // Iterate over the bus
      for( lBusIt = lBus.begin() , lDataIt = lData.begin() , lReadIt = lRead.begin() ; lBusIt != lBus.end() ; ++lBusIt , ++lDataIt , ++lReadIt  )
      {
        // Write the data to the endpoint
        Write( lBusIt , lDataIt , lReadIt , lWriteAccessTimer );
        // If we are doing an immediate read, Read some data and validate it
        if( lImmediate ) ReadAndValidate( lBusIt , lDataIt , lReadIt , lReadAccessTimer );
        // And lock this endpoint
        lBusIt->lock();
      }

      // We are safe to quit and have seen Ctrl-C
      if( gInterrupted ) return 0;

      // If we are doing a delayed read, do it here
      if( lDelayed )
      {
        // Unlock the bus    
        lBus.unlock();

        // Iterate over the bus
        for( lBusIt = lBus.begin() , lDataIt = lData.begin() , lReadIt = lRead.begin() ; lBusIt != lBus.end() ; ++lBusIt , ++lDataIt , ++lReadIt  )
        {
          // Read some data and validate it
          ReadAndValidate( lBusIt , lDataIt , lReadIt , lReadAccessTimer );
          // And lock this endpoint
          lBusIt->lock();
        }   
      }

      // We are safe to quit and have seen Ctrl-C
      if( gInterrupted ) return 0;

      // Some debug information
      boost::posix_time::ptime lCurrentTime(boost::posix_time::microsec_clock::local_time());
      std::cout << "\r| " << std::setw( 11 ) << lIteration << std::dec 
                 << " | " << ( lCurrentTime - lRunStart )
                 << " | " << lWriteAccessTimer << " (" << ( lWriteAccessTimer / (lIteration+1) ) << ")"
                 << " | " << lReadAccessTimer << " (" << ( lReadAccessTimer / (lIteration+1) ) << ")" 
                 << " |" << std::flush;

    }
    

  }catch( const std::exception& e ){
    std::cout << e.what() << std::endl;    
    return 1;
  }

  std::cout << "Finished" << std::endl;
}
// --------------------------------------------------------------------------------------------
