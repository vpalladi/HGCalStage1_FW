
#ifndef FUNKYMINIBUS_HPP
#define	FUNKYMINIBUS_HPP

// uHal Headers
#include "uhal/Node.hpp"
#include "mp7/exception.hpp"

#include <boost/ptr_container/ptr_vector.hpp>
#include <boost/noncopyable.hpp>

#include <string>
#include <vector>


#ifndef UHAL_DEFINE_EXCEPTION_CLASS
#define UHAL_DEFINE_EXCEPTION_CLASS ExceptionClass 
#endif


namespace calol2 {


class FunkyMiniBus : public boost::noncopyable
{
  private:

  public:
    typedef void (*CallbackFn_t)( const std::string& , std::vector< uint32_t >& aData ); // typedef for conciseness
    class CallbackFunctor { public: virtual void operator() ( const std::string& aName , std::vector< uint32_t >& aData ) const = 0; };

  public:
    class Endpoint
    {
      private:
        friend class FunkyMiniBus;
        
        Endpoint( const uhal::Node& aNode , const uint32_t* aEndpoints );
        void unlock();

      public:

        uint32_t size() const;
        uint32_t width() const;
        const std::string& name() const;

        void write( const std::vector< uint32_t >& aVector ) const;
        void lock();

        std::vector< uint32_t > read();

      private:
        uint32_t mNativeWidth;
        uint32_t mBitCount;
        std::string mName;
        const uhal::Node& mNode;
        bool mLocked;
    };

    class Counters
    {
    public:
        Counters();
        Counters( uhal::ValVector< uint32_t >::const_iterator& aIt );
        uint32_t Ignore , Data , ReadData , WriteData , Lock , Unlock , Reset , Error;
    };

    typedef boost::ptr_vector< Endpoint >::iterator iterator;
    typedef boost::ptr_vector< Endpoint >::const_iterator const_iterator;

  public:
    FunkyMiniBus( const uhal::Node& aNode );

    void AutoConfigure( CallbackFn_t aCallback );
    void AutoConfigure( const CallbackFunctor& aCallback );

    void ReadToFile( const std::string& aFilename );

    virtual ~FunkyMiniBus();

    iterator begin();
    iterator end();
    
    const_iterator begin() const;
    const_iterator end() const;

    void lock();
    void unlock();
    
    void UpdateCounters();
    const Counters& getStartCounters();
    const Counters& getEndCounters();

    size_t size() const;

  private:
    void Initialize();

    // --------------------------------------------------------------------------------------------
    enum State { kIgnore = 0x0 , kData = 0x1 , kReadData = 0x2 , kWriteData = 0x3 , kLock = 0x4 , kUnlock = 0x5 };
    // --------------------------------------------------------------------------------------------

    boost::ptr_vector< Endpoint > mEndpoints;
    Counters mStartCounters , mEndCounters;

    const uhal::Node& mNode;

};

std::ostream& operator<< ( std::ostream& aStr , const FunkyMiniBus& aFunkyMiniBus );
std::ostream& operator<< ( std::ostream& aStr , const FunkyMiniBus::Endpoint& aEndpoint );

MP7ExceptionClass ( InsufficientDataForEndPoint , "The payload was smaller than the endpoint size" );
MP7ExceptionClass ( AccessAttemptOnLockedEndpoint , "Access was attempted on a locked endpoint" );
MP7ExceptionClass ( DeprecatedFirmware , "Target has deprecated firmware with no native width specified" );
MP7ExceptionClass ( ReadToFileFailed , "Failed to open file for dumping readback" );

} // namespace calol2

#endif	/* FUNKYMINIBUS_HPP */

