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

#include "uhal/uhal.hpp"

#include <iostream>
#include <iomanip>
#include <string>
#include <unistd.h>
#include <math.h> 

#include "calol2/FunkyMiniBus.hpp"

#include "boost/date_time/posix_time/posix_time.hpp" 


using namespace uhal;
using namespace calol2;


const uint32_t lIterations( 1000000 );
const uint32_t lSize( 8192 );


void DummyDatabaseAccess( const std::string& , std::vector< uint32_t >& aData )
{
  srand( time( NULL ) );
  for( uint32_t j(0) ; j!=lSize ; j++ )
  {
  	aData.push_back( rand() % 512 );
  	std::cout << "Autoconfigure data : 0x" << std::hex << std::setw(8) << aData.back() << std::dec << std::endl;
  }
}


std::vector< uint32_t > JsmIPbusRead( HwInterface& hw , const uint32_t& aSize )
{
  std::vector< uint32_t > lData;

  // Because the read from the RAM is using the IPbus address and takes two clocks but I am not delaying ack
  // I play a trick here where I discard the first read as invalid and instead match to the data returned on the next clock cycle
  for( uint32_t j(0); j< aSize ; j+=256 )
  {
    ValVector< uint32_t > lReadback( hw.getNode ( "IPB_0" ).readBlockOffset( 257 , j ) );
    hw.dispatch();
    lData.insert( lData.end() , lReadback.begin()+1 , lReadback.end() );
  }

  lData.resize( aSize );
  return lData;
}

UHAL_DEFINE_EXCEPTION_CLASS ( IPbusFunkyMiniBusSizeMismatch , "There was a mismatch between the size returned by IPbus vs FunkyMiniBus" );



// --------------------------------------------------------------------------------------------
int main ( int argc,char* argv[] )
{

// Connect to the hardware
  ConnectionManager manager ( "file://tests/etc/jsm-connections.xml" );
  HwInterface hw=manager.getDevice ( "jsm" );

  FunkyMiniBus lBus( hw.getNode( "FunkyMiniBus" ) );

// Dump the bus info to std::out
  std::cout << lBus << std::endl;

// Autoconfigure
  lBus.AutoConfigure( &DummyDatabaseAccess );
  lBus.ReadToFile( "FunkyMiniBusFileTest.txt" );

  FunkyMiniBus::iterator lIt(lBus.begin()) ;

  boost::posix_time::ptime t1(boost::posix_time::microsec_clock::local_time());

  std::string lBackspace( 25 , '\b' );

  for (uint32_t x(0) ; x!=lIterations ; ++x )
  {
    boost::posix_time::ptime t2(boost::posix_time::microsec_clock::local_time());
    boost::posix_time::time_duration dt( t2 - t1 );

    if( lIterations > 1 ) std::cout << lBackspace << std::setw( 7 ) << x << " | " << dt << std::flush;

    srand( time( NULL ) );
    std::vector< uint32_t > lData;
    for( uint32_t j(0) ; j< lSize ; j++ ) lData.push_back( rand() % 512 );
  
// FunkyMiniBus Write
    {
      lBus.unlock();
      lIt->write( lData );
      lIt->lock();
    }
  
// IPbus verify
    {
      std::vector< uint32_t > lReadback( JsmIPbusRead( hw , lSize ) );

      if( lData.size() != lReadback.size() )
      { 
      	std::cout << "\nIPBus size = " << lReadback.size() << " vs. data size = " << lData.size() << std::endl;
      	throw IPbusFunkyMiniBusSizeMismatch();
      }    	

      std::vector< uint32_t >::const_iterator a( lData.begin() );
      std::vector< uint32_t >::const_iterator b( lReadback.begin() );
      uint32_t i(0);

      for( ; a != lData.end() ; ++a , ++b , ++i )
      {
        if( *a != *b ) std::cout << "\nIPbus readback : Frame " << std::setw(4) << i << " : Sent 0x" << std::hex << std::setw(8) << *a << ", Received 0x" << std::setw(8) << *b << std::dec << std::endl;
      }
    }

// FunkyMiniBus Read
    {  
      lBus.unlock();
      std::vector< uint32_t > lReadback( lIt->read( ) );
      lIt->lock();

      if( lData.size() != lReadback.size() )
      { 
      	std::cout << "\nFunkyMiniBus size = " << lReadback.size() << " vs. data size = " << lData.size() << std::endl;
      	throw IPbusFunkyMiniBusSizeMismatch();
      }

      std::vector< uint32_t >::const_iterator a( lData.begin() );
      std::vector< uint32_t >::const_iterator b( lReadback.begin() );
      uint32_t i(0);

      for( ; a != lData.end() ; ++a , ++b , ++i )
      {
        if( *a != *b ) std::cout << "\nFunkyMiniBus readback : Frame " << std::setw(4) << i << " : Sent 0x" << std::hex << std::setw(8) << *a << ", Received 0x" << std::setw(8) << *b << std::dec << std::endl;
      }
    }

  }

// --------------------------------------------------------------------------------------------


  std::cout << std::endl;
}