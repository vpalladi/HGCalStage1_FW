/*
 * File: mp7/MmcManager.hpp
 * Author: tsw
 *
 * Date: November 2014
 */

#ifndef MP7_MMCMANAGER_HPP
#define MP7_MMCMANAGER_HPP


#include <string>
#include <vector>

#include "mp7/MmcPipeInterface.hpp"
#include "mp7/Measurement.hpp"


namespace mp7{

  ///! Provides higher-level API for MMC-related control (i.e. board/FPGA reboots, and SD card)
  class MmcManager {
  private:
    MmcManager(const mp7::MmcPipeInterface& aMmcNode);
  public:
    ~MmcManager();

    void hardReset();

    void rebootFPGA(const std::string& aSdFilename);

    void setDummySensorValue(const uint8_t aValue);

    std::vector<std::string> filesOnSD();

    void copyFileToSD(const std::string& aLocalPath, const std::string& aSdFilename);

    void copyFileFromSD(const std::string& aLocalPath, const std::string& aSdFilename);

    void deleteFileFromSD(const std::string& aSdFilename);

    std::map<std::string, mp7::Measurement> readSensorInfo();

  private:
    mp7::MmcPipeInterface mMmcNode;
    
    friend class MP7Controller;
    friend class MmcController;

  };

}

#endif /* MP7_MMCMANAGER_HPP */
