#include "calol2/FunkyMiniBus.hpp"
#include "uhal/uhal.hpp"

#include "calol2/Utilities.hpp"

#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>



namespace calol2 {

// --------------------------------------------------------------------------------------------
FunkyMiniBus::FunkyMiniBus( const uhal::Node& aNode ) :
mNode(aNode)
{
  Initialize();
}
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
FunkyMiniBus::~FunkyMiniBus()
{}
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
void FunkyMiniBus::Initialize()
{
  // Read the bus size
  uhal::ValWord< uint32_t > lBusSize( mNode.getNode ( "BusSize" ).read() );
  mNode.getClient().dispatch();

  // Read the infospace
  uhal::ValVector< uint32_t > lEndpoints( mNode.getNode ( "InfoSpace" ).readBlock ( 4*lBusSize ) );
  mNode.getClient().dispatch();

  // Make the infospace user friendly
  mEndpoints.clear();
  mEndpoints.reserve( lBusSize );
  for(size_t i=0; i!= lBusSize; ++i) mEndpoints.push_back( new Endpoint(mNode , &( lEndpoints[4*i] ) ) );
}
// --------------------------------------------------------------------------------------------



// --------------------------------------------------------------------------------------------
void FunkyMiniBus::AutoConfigure( FunkyMiniBus::CallbackFn_t aCallback )
{
  std::vector< uint32_t > lData;

  unlock();
  for( iterator lIt( mEndpoints.begin() ) ; lIt != mEndpoints.end() ; ++lIt  )
  {
    lData.clear();
    aCallback( lIt->name() , lData );
    if( lData.size() ) lIt->write( lData );
    lIt->lock();      
  }
}
// --------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------
void FunkyMiniBus::AutoConfigure( const CallbackFunctor& aCallback )
{
  std::vector< uint32_t > lData;

  unlock();
  for( iterator lIt( mEndpoints.begin() ) ; lIt != mEndpoints.end() ; ++lIt  )
  {
    lData.clear();
    aCallback( lIt->name() , lData );
    if( lData.size() ) lIt->write( lData );
    lIt->lock();      
  }
}
// --------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------
void FunkyMiniBus::ReadToFile( const std::string& aFilename )
{
  unlock();
  std::ofstream lFile ( aFilename.c_str() );
  if( ! lFile.is_open() ) throw ReadToFileFailed();


  lFile << std::hex << std::setfill('0');
  for( iterator lIt( mEndpoints.begin() ) ; lIt != mEndpoints.end() ; ++lIt  )
  {
    lFile << "'" << lIt->name() << "'" << std::endl;
    std::vector< uint32_t > lData( lIt->read() );
    lIt->lock();  
    for( std::vector< uint32_t >::const_iterator a( lData.begin() ) ; a != lData.end() ; ++a ) lFile << "0x" << std::setw(8) << *a << std::endl;
  }
  lFile << std::dec;
  lFile.close();
}
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
FunkyMiniBus::Counters::Counters( ) : Ignore( 0 ) , Data( 0 ) , ReadData( 0 ) , WriteData( 0 ) , Lock( 0 ) , Unlock( 0 ) , Reset( 0 ) , Error( 0 )
{}
// --------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------
FunkyMiniBus::Counters::Counters(  uhal::ValVector< uint32_t >::const_iterator& aIt  ) : Ignore( 0 ) , Data( 0 ) , ReadData( 0 ) , WriteData( 0 ) , Lock( 0 ) , Unlock( 0 ) , Reset( 0 ) , Error( 0 )
{
  Ignore = *aIt++;
  Data = *aIt++;
  ReadData = *aIt++;
  WriteData = *aIt++;
  Lock = *aIt++;
  Unlock = *aIt++;
  Reset = *aIt++;
  Error = *aIt++;
}
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
  void FunkyMiniBus::UpdateCounters()
  {
    uhal::ValVector< uint32_t > lReadback( mNode.getNode ( "Counters" ).readBlock( 16 ) );
    uhal::ValVector< uint32_t >::const_iterator lIt( lReadback.begin() );
    mStartCounters = Counters( lIt );
    mEndCounters = Counters( lIt );
  }

  const FunkyMiniBus::Counters& FunkyMiniBus::getStartCounters()
  {
    return mStartCounters;
  }

  const FunkyMiniBus::Counters& FunkyMiniBus::getEndCounters()
  {
    return mEndCounters;
  }
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
FunkyMiniBus::iterator FunkyMiniBus::begin()
{
  return mEndpoints.begin();
}
// --------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------
FunkyMiniBus::iterator FunkyMiniBus::end()
{
  return mEndpoints.end();
}
// --------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------
FunkyMiniBus::const_iterator FunkyMiniBus::begin() const
{
  return mEndpoints.begin();
}
// --------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------
FunkyMiniBus::const_iterator FunkyMiniBus::end() const
{
  return mEndpoints.end();
}
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
size_t FunkyMiniBus::size() const
{
  return mEndpoints.size();
}
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
void FunkyMiniBus::lock()
{
  // if( !mEndpoints.size() ) Initialize();
  for( iterator lIt( mEndpoints.begin() ) ; lIt != mEndpoints.end() ; ++lIt  ) lIt->lock();
}
// --------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------
void FunkyMiniBus::unlock()
{
  // if( !mEndpoints.size() ) Initialize();
  for( iterator lIt( mEndpoints.begin() ) ; lIt != mEndpoints.end() ; ++lIt  ) lIt->unlock();
}
// --------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------
FunkyMiniBus::Endpoint::Endpoint( const uhal::Node& aNode , const uint32_t* aEndpoints ) : mNode( aNode ) , mLocked( true )
{
  mBitCount = (*aEndpoints >> 0 ) & 0x00FFFFFF;
  mNativeWidth = (*aEndpoints >> 24 ) & 0x000000FF;

  if( !mNativeWidth ) throw DeprecatedFirmware();

  const char* lPtr( (const char*)( aEndpoints+1 ) );
  const char* lEnd( lPtr + 12 );

  while ( *lPtr && lPtr!=lEnd ) mName += (*lPtr++);
}
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
uint32_t FunkyMiniBus::Endpoint::size() const
{
  return mBitCount;
}
// --------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------
uint32_t FunkyMiniBus::Endpoint::width() const
{
  return mNativeWidth;
}
// --------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------
const std::string& FunkyMiniBus::Endpoint::name() const
{
  return mName;
}
// --------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------
void FunkyMiniBus::Endpoint::unlock( )
{
  mNode.getNode ( "Instruction" ).write ( kUnlock );
  mNode.getClient().dispatch();
  mLocked = false;
}
// --------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------
void FunkyMiniBus::Endpoint::write( const std::vector< uint32_t >& aVector ) const
{
  if( mLocked ) throw AccessAttemptOnLockedEndpoint();
  if( (aVector.size() * mNativeWidth) < mBitCount ) throw InsufficientDataForEndPoint();

  std::vector< uint32_t > lBlob( utils::VectorToBLOB( aVector , mNativeWidth ) );

  // Send a write instructions to the FunkyMiniBus
  mNode.getNode ( "Instruction" ).write ( kWriteData );

  std::vector< uint32_t >::const_iterator lIt1 , lIt2( lBlob.begin() ) ;
  do
  {
    lIt1 = lIt2;
    lIt2 = ( (lBlob.end() - lIt1) > 256 ? lIt1 + 256 : lBlob.end() ) ;
    std::vector< uint32_t > lVector( lIt1 , lIt2 );
    mNode.getNode ( "Data" ).writeBlock ( lVector );
    mNode.getClient().dispatch();
  }
  while( lIt2 != lBlob.end() );
  
}
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
void FunkyMiniBus::Endpoint::lock( )
{
  // Send a lock instructions to the FunkyMiniBus
  mNode.getNode ( "Instruction" ).write ( kLock );
  mNode.getClient().dispatch();  
}
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
std::vector< uint32_t > FunkyMiniBus::Endpoint::read()
{
  if( mLocked ) throw AccessAttemptOnLockedEndpoint();

  int32_t lSize( int32_t( ceil( mBitCount / 32.0 ) ) );

  std::vector< uint32_t > lDummy( lSize<256 ? lSize : 256 , 0x00000000 );

  std::vector< uint32_t > lVector;
  lVector.reserve( lSize );

  // Send a read instructions to the FunkyMiniBus
  mNode.getNode ( "Instruction" ).write ( kReadData );
  mNode.getClient().dispatch();  

  do
  {
    if (lSize < 256) lDummy.resize( lSize );

    mNode.getNode ( "Data" ).writeBlock( lDummy );
    mNode.getClient().dispatch();

    uhal::ValVector< uint32_t > lReadback( mNode.getNode ( "Data" ).readBlock( lDummy.size() ) );
    mNode.getClient().dispatch();
    lVector.insert( lVector.end() , lReadback.begin() , lReadback.end() );
  }
  while( (lSize -= 256) > 0 );

  if ( mNativeWidth > 32 ) return lVector;
  
  std::vector< uint32_t > lNativeVector( utils::BLOBtoVector( lVector , mNativeWidth ) );
  lNativeVector.resize( mBitCount / mNativeWidth );
  return lNativeVector;
}
// --------------------------------------------------------------------------------------------


// --------------------------------------------------------------------------------------------
std::ostream& operator<< ( std::ostream& aStr , const FunkyMiniBus::Endpoint& aInfo )
{
  aStr << "'" << aInfo.name() << "' : "<< aInfo.size() << " bits";
  return aStr;
}
// --------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------
std::ostream& operator<< ( std::ostream& aStr , const FunkyMiniBus& aFunkyMiniBus )
{
  for( FunkyMiniBus::const_iterator lIt( aFunkyMiniBus.begin() ) ; lIt != aFunkyMiniBus.end() ; ++lIt  ) aStr << *lIt << "\n";
  return aStr;    
}
// --------------------------------------------------------------------------------------------

} // namespace calol2
