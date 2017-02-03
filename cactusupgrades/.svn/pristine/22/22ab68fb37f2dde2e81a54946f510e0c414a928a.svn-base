#include "calol2/Utilities.hpp"

// C++ Headers
#include <cmath>
#include <fstream>

// Boost Headers
#include <boost/unordered_map.hpp>
#include <boost/tokenizer.hpp>

// MP7 Headers
#include "mp7/Logger.hpp"

namespace calol2 {
namespace utils {

// --------------------------------------------------------------------------------------------
std::vector< uint32_t > VectorToBLOB( const std::vector< uint32_t >& aVector , const uint32_t& aWidth )
{
  if ( aWidth > 32 )
  {
    return aVector;
  }

  // -------------------
  // The BLOB itself
  std::vector< uint32_t > lRet( ceil( aVector.size() * aWidth / 32.0 ) , 0x00000000 );
  // Variables to track of the word and bits in the BLOB to which we are writing
  std::vector< uint32_t >::iterator lWrite( lRet.begin() );
  int32_t lOffset( 0 );     
  // -------------------

  // -------------------
  // A mask to make sure the user isn't doing anything naughty or stupid
  uint32_t lMask( 0 );
  for( uint32_t i(0) ; i!=aWidth ; ++i ) lMask |= (0x1<<i);
  // -------------------

  // -------------------
  // The packing loop
  for( std::vector< uint32_t >::const_iterator lRead( aVector.begin() ) ; lRead != aVector.end() ; lRead++ )
  {
    *lWrite |= ( (*lRead & lMask) << (lOffset) );
    if( (lOffset += aWidth) > 31 ) *(++lWrite) |= ( (*lRead & lMask) >> ( aWidth - (lOffset -= 32) ) );
  }
  // -------------------

  return lRet;
}
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
std::vector< uint32_t > BLOBtoVector( const std::vector< uint32_t >& aBlob , const uint32_t& aWidth )
{
  if ( aWidth > 32 )
  {
    return aBlob;
  }

  // -------------------
  // The vector itself
  std::vector< uint32_t > lRet( floor( aBlob.size() * 32.0 / aWidth ) , 0x00000000 );

  // Variables to track of the word and bits in the BLOB which we are reading
  std::vector< uint32_t >::const_iterator lRead( aBlob.begin() );
  int32_t lOffset( 0 );     
  // -------------------

  // -------------------
  // A mask to select the right bits
  uint32_t lMask( 0 );
  for( uint32_t i(0) ; i!=aWidth ; ++i ) lMask |= (0x1<<i);
  // -------------------

  // -------------------
  // The unpacking loop
  for( std::vector< uint32_t >::iterator lWrite( lRet.begin() ) ; lWrite != lRet.end() ; lWrite++ )
  {
    *lWrite |= ( (*lRead >> lOffset) & (lMask) );
    if( (lOffset += aWidth) > 31 ) *lWrite |= ( ( (*(++lRead) ) << ( aWidth - (lOffset -= 32) ) ) & (lMask) );
  }
  // -------------------

  return lRet;
}
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
MPLUTFileAccess::MPLUTFileAccess(const std::string& aPath) :
mPath(aPath),
mMap({
  { "C", "C_EgammaCalibration_12to18.mif"},
  { "D", "D_EgammaIsolation_13to9.mif"},
  { "H1", "H_TauIsolation1_12to9.mif"},
  { "H2", "H_TauIsolation2_12to9.mif"},
  { "I", "I_TauCalibration_11to18.mif"},
  { "L", "L_JetCalibration_11to18.mif"},
  { "ME", "M_ETMETecal_11to18.mif"},
  { "MS", "M_ETMET_11to18.mif"},
  { "MX", "M_ETMETX_11to18.mif"},
  { "MY", "M_ETMETY_11to18.mif"},
  { "JetSeedThr", "1_JetSeedThreshold.mif"},
  { "ClstrSeedThr", "2_ClusterSeedThreshold.mif"},
  { "ClstrThr", "3_ClusterThreshold.mif"},
  { "PileUpThr", "4_PileUpThreshold.mif"},
  { "JetEtaMax", "6_JetEtaMax.mif"},
  { "EgammaEtaMax", "5_EgammaTauEtaMax.mif"},
  { "TauEtaMax", "5_EgammaTauEtaMax.mif"},
  { "HT", "8_HtThreshold.mif"},
  { "MHT", "9_MHtThreshold.mif"},
  { "HTMHT", "7_RingEtaMax.mif"},
  { "ETMET", "7_RingEtaMax.mif"},
  { "EgRelaxThr", "10_EgRelaxThr.mif"}
})
{
}
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
void MPLUTFileAccess::operator()(const std::string& aName, std::vector<uint32_t>& aData) const
{
  // --------------------------------
  static const boost::char_separator<char> lSeparators("_");
  boost::tokenizer< boost::char_separator<char> > lTokens(aName, lSeparators); // split endpoint name at '_' characters
  boost::unordered_map< std::string, std::string >::const_iterator lIt(mMap.find(*lTokens.begin())); // associate endpoint with filename & size
  if (lIt == mMap.end()) return; // return nothing if we are not in the "database"
  // --------------------------------
  boost::filesystem::path lPath(boost::filesystem::canonical(mPath / lIt->second)); // create path to file
  if (!boost::filesystem::is_regular_file(lPath)) throw NoSuchFile(); // check file exists
  std::cout << aName << " -> " << *lTokens.begin() << " -> " << lIt->second << " -> " << lPath << std::endl;
  // --------------------------------
  std::string lLine;
  std::ifstream lFile(lPath.string().c_str());
  while (getline(lFile, lLine)) aData.push_back(std::stoul(lLine, NULL, 16));
  lFile.close();
  std::cout << "File read successfully" << std::endl;
  // --------------------------------
}


AllZeros::AllZeros()
{
}


void AllZeros::operator()(const std::string& aName, std::vector<uint32_t>& aData) const
{
  MP7_LOG(mp7::logger::kDebug) << "Zeroing " << aName;
  static const std::vector< uint32_t > lZeros( 8192 , 0x00000000 ); //8192 @ width=9 = max RAM size at minimum ram width
  aData = lZeros;
}


} // namespace utils
} // namespace calol2