/* 
 * File:   ReadoutControlNode.hpp
 * Author: ale
 *
 * Created on May 18, 2015, 1:37 PM
 */

#ifndef MP7_READOUTCONTROLNODE_HPP
#define	MP7_READOUTCONTROLNODE_HPP

#include "uhal/DerivedNode.hpp"
#include "mp7/exception.hpp"

namespace mp7 {

/**
 * @class ReadoutMenu
 */
class ReadoutMenu {
public:

  class Bank {
  public:
    uint32_t wordsPerBx;
  };
  
  class Capture {
  public:
    bool enable;
    uint32_t id;
    uint32_t bankId;
    uint32_t length;
    uint32_t delay;
    uint32_t readoutLength;
  };

  /**
   * @class ReadoutMenu
   */ 
  class Mode {
  public:
    typedef std::vector<Capture>::iterator iterator;
    typedef std::vector<Capture>::const_iterator const_iterator;

    Mode( size_t aSize );

    uint32_t eventSize;
    uint32_t eventToTrigger;
    uint32_t eventType;
    // uint32_t tokenDelay;

    void operator=( const Mode& aOther);
    
    Capture& operator[]( size_t i );
    const Capture& operator[]( size_t i ) const;

    size_t size() const;
    
    iterator begin() { return mCaptures.begin(); }
    const_iterator begin() const { return mCaptures.begin(); }
    iterator end() { return mCaptures.end(); }
    const_iterator end() const { return mCaptures.end(); }
    

  private:
    std::vector<Capture> mCaptures;

    friend class ReadoutMenu;
  };


  ReadoutMenu(size_t aNBanks, size_t aNModes, size_t aNCaptures);

  ~ReadoutMenu();

  size_t numBanks() const;

  size_t numModes() const;
  
  size_t numCaptures() const;  

  Bank& bank( size_t i );

  const Bank& bank( size_t i ) const;

  Mode& mode( size_t i );
  
  const Mode& mode( size_t i ) const;
  
  Capture& capture( size_t aMode, size_t aCap );

  const Capture& capture( size_t aMode, size_t aCap ) const;

  void setMode(uint32_t aMode, const Mode& aOther);

private:
  //! Number of Banks used by the menu
  const size_t mNumBanks;

  //! Number of trigger modes in the menu
  const size_t mNumModes;

  //! Number of capture mode per trigger mode
  const size_t mNumCaptures;

  std::vector<Mode> mModes;

  std::vector<Bank> mBanks;
  
};

std::ostream& operator<<( std::ostream& oStream, const ReadoutMenu::Bank& aBank );
std::ostream& operator<<( std::ostream& oStream, const ReadoutMenu::Mode& aMode );
std::ostream& operator<<( std::ostream& oStream, const ReadoutMenu::Capture& aCapture );
std::ostream& operator<<( std::ostream& oStream, const ReadoutMenu& aMenu );



/**
 * @class ReadoutCtrlNode
 */
class ReadoutCtrlNode : public uhal::Node {
  UHAL_DERIVEDNODE(ReadoutCtrlNode);

public:
  
  ReadoutCtrlNode(const uhal::Node& aNode);

  virtual ~ReadoutCtrlNode();
  
  uint32_t readNumBanks() const;

  uint32_t readNumModes() const;
  
  uint32_t readNumCaptures() const;
  
  void selectBank( uint32_t aBank ) const;
  
  void selectMode( uint32_t aMode ) const;
  
  void selectCapture( uint32_t aCapture ) const;
    
  void reset() const;
  
  void configureMenu( const ReadoutMenu& aMenu ) const;

  ReadoutMenu readMenu() const;
  
  /**
   * Set the Readout derandomisers watermarks
   * 
   * The values are in some units I still have to figure out.
   * 64 = 100%
   * 
   * @param aLowWM Derandomiser low water mark in some strange units
   * @param aHighWM Derandomiser high water mark in some strange units
   */
  void setDerandWaterMarks( uint32_t aLowWM, uint32_t aHighWM ) const;

private:

};



} // namespace mp7

#endif	/* MP7_READOUTCONTROLNODE_HPP */

