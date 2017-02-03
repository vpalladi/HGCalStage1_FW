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
// #include <iomanip>
// #include <unistd.h>

#include <boost/program_options.hpp>
#include <boost/filesystem.hpp>
#include <boost/tokenizer.hpp>

#include "uhal/uhal.hpp"
#include "uhal/log/exception.hpp"

#include "calol2/FunkyMiniBus.hpp"


using namespace uhal;
using namespace calol2;

UHAL_DEFINE_EXCEPTION_CLASS( NoSuchFile , "No such file exists" );

void AllZeros( const std::string& , std::vector< uint32_t >& aData )
{
  std::cout << "Writing zeros" << std::endl;
  static const std::vector< uint32_t > lZeros( 8192 , 0x00000000 ); //8192 @ width=9 = max RAM size at minimum ram width
  aData = lZeros;
}


class CaloLUTFileAccess : public FunkyMiniBus::CallbackFunctor
{
  public:
    boost::filesystem::path mPath;
    const std::unordered_map< std::string , std::string > mMap;    

    CaloLUTFileAccess( const std::string& aPath ) : 
      mPath( aPath ),
      mMap( {
              { "C"   , "C_EgammaCalibration_12to18.mif"  },
              { "D"   , "D_EgammaIsolation_13to9.mif"  },
              { "H1"  , "H_TauIsolation1_12to9.mif"  },
              { "H2"  , "H_TauIsolation2_12to9.mif"  },
              { "I"   , "I_TauCalibration_11to18.mif"  },
              { "L"   , "L_JetCalibration_11to18.mif"  },
              { "ME"  , "M_ETMETecal_11to18.mif"  },
              { "MS"  , "M_ETMET_11to18.mif"  },
              { "MX"  , "M_ETMETX_11to18.mif"  },
              { "MY"  , "M_ETMETY_11to18.mif"  },
              { "JetSeedThr"   , "1_JetSeedThreshold.mif"  },
              { "ClstrSeedThr" , "2_ClusterSeedThreshold.mif"  },
              { "ClstrThr"     , "3_ClusterThreshold.mif" }, 
              { "PileUpThr"    , "4_PileUpThreshold.mif" }, 
              { "JetEtaMax"    , "6_JetEtaMax.mif" }, 
              { "EgammaEtaMax" , "5_EgammaTauEtaMax.mif" }, 
              { "TauEtaMax"    , "5_EgammaTauEtaMax.mif" }, 
              { "HT"           , "8_HtThreshold.mif" }, 
              { "MHT"          , "9_MHtThreshold.mif" }, 
              { "HTMHT"        , "7_RingEtaMax.mif" }, 
              { "ETMET"        , "7_RingEtaMax.mif" } 
            } )
    {}

    void operator() ( const std::string& aName , std::vector< uint32_t >& aData ) const
    {
      // --------------------------------
      static const boost::char_separator<char> lSeparators("_");
      boost::tokenizer< boost::char_separator<char> > lTokens( aName , lSeparators );                                                // split endpoint name at '_' characters
      std::unordered_map< std::string , std::string >::const_iterator lIt( mMap.find( *lTokens.begin() ) ); // associate endpoint with filename & size
      if( lIt == mMap.end() ) return;                                                                                                // return nothing if we are not in the "database"
      // --------------------------------
      boost::filesystem::path lPath( boost::filesystem::canonical( mPath / lIt->second ) );                                    // create path to file
      if ( !boost::filesystem::is_regular_file ( lPath ) ) throw NoSuchFile();                                                       // check file exists
      std::cout << aName << " -> " << *lTokens.begin() << " -> " << lIt->second << " -> " << lPath << std::endl;
      // --------------------------------
      std::string lLine;
      std::ifstream lFile( lPath.string().c_str() );
      while ( getline ( lFile, lLine) ) aData.push_back( std::stoul( lLine , NULL , 16 ) );
      lFile.close();
      std::cout << "File read successfully" << std::endl;    
      // --------------------------------
    }

};



// --------------------------------------------------------------------------------------------
int main ( int argc,char* argv[] )
{
  using namespace boost::program_options;

  std::string lBoard , lPath, lConnections;

  // -----------------------------------------------------------------------------
  // Declare the supported options.
  options_description desc ( "Allowed options" );
  desc.add_options()
  ( "help,h", "Produce help message" )
  ( "connections,c", value< std::string > ( &lConnections )->default_value("file://${CALOL2_ROOT}/tests/etc/calo2/connections-TDR.xml") , "Select connection file" )
  ( "target,t", value< std::string > ( &lBoard )->required() , "Select target board (Required)" )
  ( "zeros,z" , "Dump zeros onto the bus" )
  ( "path,p", value< std::string > ( &lPath ) , "Path to HexRom files" )
  ( "read,r", value< std::string > ( &lPath ) , "File into which to dump bus content" );

  variables_map vm;

  try{
    store ( parse_command_line ( argc, argv, desc ), vm );
    notify ( vm );
  }catch( const std::exception& e ){
    std::cout << e.what() << std::endl;    
    std::cout << desc << std::endl;
    return 1;
  }
  // -----------------------------------------------------------------------------

  uint32_t lOptions( 0 );
  if ( vm.count("zeros") ) lOptions++;
  if ( vm.count("path") ) lOptions++;
  if ( vm.count("read") ) lOptions++;

  if ( lOptions == 0 )
  {
    std::cout << "Must specify either zeros or path to HexRom files" << std::endl;
    std::cout << desc << std::endl;
    return 1;    
  }

  if ( lOptions > 1 )
  {
    std::cout << "Cannot specify more than one option from 'zeros', 'path to HexRom files' and 'read'" << std::endl;
    std::cout << desc << std::endl;
    return 1;    
  }
  
  try{
    std::cout << "Board: " << lBoard << std::endl;

    uhal::setLogLevelTo( uhal::Notice() );

    // Connect to the hardware
    ConnectionManager manager ( lConnections );
    HwInterface hw = manager.getDevice ( lBoard );
    FunkyMiniBus lBus( hw.getNode( "payload" ) );

    std::cout << "Bus:\n" << lBus << std::endl;

	if ( vm.count("read") )      lBus.ReadToFile( lPath );
    else if( vm.count("zeros") ) lBus.AutoConfigure( AllZeros ); 
    else                         lBus.AutoConfigure( CaloLUTFileAccess( lPath ) );
    
  }catch( const std::exception& e ){
    std::cout << e.what() << std::endl;    
    return 1;
  }

  std::cout << "Finished" << std::endl;
}
// --------------------------------------------------------------------------------------------
