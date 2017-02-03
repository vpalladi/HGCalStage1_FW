/* 
 * File:   MMCController.hpp
 * Author: ale
 *
 * Created on April 22, 2015, 11:33 AM
 */

#ifndef MP7_MMCCONTROLLER_HPP
#define	MP7_MMCCONTROLLER_HPP

// Boost Headers
#include <boost/noncopyable.hpp>

// Uhal Headers
#include "uhal/HwInterface.hpp"

// MP7 Headers
#include "mp7/MmcPipeInterface.hpp"

namespace mp7 {

class MmcController : public boost::noncopyable {
public:

  MmcController( const uhal::HwInterface& aHw );
  
  virtual ~MmcController();

  void hardReset();

  void rebootFPGA(const std::string& aSdFilename);
  
  void setDummySensorValue(const uint8_t aValue);
  
  std::vector<std::string> filesOnSD();
  
  void copyFileToSD(const std::string& aLocalPath, const std::string& aSdFilename);
  
  void copyFileFromSD(const std::string& aLocalPath, const std::string& aSdFilename);
  
  void deleteFileFromSD(const std::string& aSdFilename);
  
private:
    //! IPBus interface to the MP7 board
    uhal::HwInterface mHw;
    mp7::MmcPipeInterface mMmcNode;

    
    
};

} // namespace mp7

#endif	/* MP7_MMCCONTROLLER_HPP */

