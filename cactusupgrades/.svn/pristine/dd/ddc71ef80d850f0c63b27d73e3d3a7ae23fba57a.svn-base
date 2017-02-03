#include <math.h>
#include <vector>
#include <iostream>
#include <iomanip> 
#include <stdint.h> 

//-----------------------------------------------------------------------------------------------------------------------------------------------
class cordic
{
  public:
    cordic( const uint32_t& aPhiScale , const uint32_t& aMagnitudeBits , const uint32_t& aSteps );
    virtual ~cordic();

    void operator() ( int32_t aX , int32_t aY , int32_t& aPhi , uint32_t& aMagnitude );

    double NormalizePhi( const int32_t& aPhi);
    double NormalizeMagnitude( const uint32_t& aMagnitude );
    int32_t IntegerizeMagnitude( const double& aMagnitude );

  private:
    uint32_t tower( const double& aRadians );

  private:
    uint32_t mPhiScale;
    uint32_t mMagnitudeScale;
    uint32_t mMagnitudeBits;
    uint32_t mSteps;
    uint32_t mMagnitudeRenormalization;
    std::vector<uint32_t> mRotations;

    const double mPi;
};
//-----------------------------------------------------------------------------------------------------------------------------------------------




//-----------------------------------------------------------------------------------------------------------------------------------------------
cordic::cordic( const uint32_t& aPhiScale , const uint32_t& aMagnitudeBits , const uint32_t& aSteps ) : mPhiScale( aPhiScale ) , mMagnitudeScale( 1 << aMagnitudeBits ) , mMagnitudeBits( aMagnitudeBits ) , mSteps( aSteps ) , mPi( 3.1415926535897932384626433832795 )
{
  mRotations.reserve( mSteps );

  double lValue( 1.0 );

  for( uint32_t lStep( 0 ); lStep!=mSteps ; ++lStep ){
    lValue /= sqrt( 1.0 + pow( 4.0 , -double(lStep) ) );
    mRotations.push_back( tower( atan( pow( 2.0 , -double(lStep) ) ) ) );
  }
  mMagnitudeRenormalization = uint32_t( round( mMagnitudeScale * lValue ) );
}

cordic::~cordic(){}

double cordic::NormalizePhi( const int32_t& aPhi)
{
  return double( aPhi ) / double( mPhiScale );
}

double cordic::NormalizeMagnitude( const uint32_t& aMagnitude )
{
  return double( aMagnitude ) / double( mMagnitudeScale );
}

int32_t cordic::IntegerizeMagnitude( const double& aMagnitude )
{
  return int32_t( aMagnitude * mMagnitudeScale );
}

uint32_t cordic::tower( const double& aRadians )
{
  return uint32_t( round( mPhiScale * 36.0 * aRadians / mPi ) );
}

void cordic::operator() ( int32_t aX , int32_t aY , int32_t& aPhi , uint32_t& aMagnitude )
{
  bool lSign(true);

  switch( ((aY>=0)?0x0:0x2) | ((aX>=0)?0x0:0x1) ){
  case 0:
    aPhi = 0;
    break;
  case 1:
    aPhi = tower( mPi );
    lSign = false;
    aX = -aX;
    break;
  case 2:
    aPhi = tower( 2 * mPi );
    lSign = false;
    aY = -aY;    
    break;
  case 3:
    aPhi = tower( mPi );
    aX = -aX;
    aY = -aY;   
    break;
  default:
    throw 0;
  }

    std::cout << "Start : " << aPhi << std::endl;


  for( uint32_t lStep( 0 ); lStep!=mSteps ; ++lStep ){
    if ( (aY < 0) == lSign ){
      aPhi -= mRotations[ lStep ];
    }else{    
      aPhi += mRotations[ lStep ];
    }

    std::cout <<"Step " << lStep << " : " << aPhi << std::endl;

    int32_t lX(aX), lY(aY);
    if( lY < 0 ){
      aX = lX - (lY >> lStep);
      aY = lY + (lX >> lStep);
    }else{    
      aX = lX + (lY >> lStep);
      aY = lY - (lX >> lStep);
    }
  }

  aMagnitude = (aX * mMagnitudeRenormalization) >> mMagnitudeBits;
}
//-----------------------------------------------------------------------------------------------------------------------------------------------




//-----------------------------------------------------------------------------------------------------------------------------------------------
int main()
{
  cordic lCordic( 14 , 6 , 8 );

  int32_t lPhi;
  uint32_t lMagnitude;

 // std::cout << std::scientific << std::setprecision( 3 ) << std::endl;

//   for( int i(0) ; i!=72 ; ++i )
//   {
//       double phi( 6.283185307179586476925286766559 * i/72.0 );
//       double mag( 5.0 );
//       int32_t lScaledX( lCordic.IntegerizeMagnitude( mag*cos( phi ) ) );
//       int32_t lScaledY( lCordic.IntegerizeMagnitude( mag*sin( phi ) ) );
// 
//       lCordic( lScaledX , lScaledY , lPhi , lMagnitude );
// 
//       std::cout << "ref phi=" << double(i) << " vs. calc phi=" << lCordic.NormalizePhi(lPhi) 
//                 << " | " 
//                 << "ref mag=" <<       mag << " vs. calc mag=" << lCordic.NormalizeMagnitude(lMagnitude) 
//                 << std::endl;
//   }


lCordic( -44 , -62 , lPhi , lMagnitude );

double lPhiTower( lCordic.NormalizePhi(lPhi) );
double lPhiRadians( 6.283185307179586476925286766559 * lPhiTower/72.0 );


std::cout << "Mag: " << lMagnitude << std::endl;
std::cout << "Phi: " << lPhi << ", Normalized Phi: " << lPhiTower << ", Radian Phi: " << lPhiRadians << std::endl;


std::cout << "Recalculated X : " << (lMagnitude*cos(lPhiRadians)) << std::endl;
std::cout << "Recalculated Y : " << (lMagnitude*sin(lPhiRadians)) << std::endl;



}
//-----------------------------------------------------------------------------------------------------------------------------------------------

