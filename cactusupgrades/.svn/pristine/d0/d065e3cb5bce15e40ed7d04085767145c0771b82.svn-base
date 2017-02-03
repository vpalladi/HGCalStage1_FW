#include "mp7/MmcController.hpp"

#include "mp7/MmcManager.hpp"
// #include <fstream>

// #include "boost/filesystem.hpp"
// #include <boost/assign/std/vector.hpp>
// #include <boost/assign/list_inserter.hpp>

// #include "mp7/Logger.hpp"
// #include "mp7/Utilities.hpp"

// namespace l7 = mp7::logger;

namespace mp7 {

//---
MmcController::MmcController(const uhal::HwInterface& aHw) :
  noncopyable(),
  mHw(aHw),
  mMmcNode(mHw.getNode<mp7::MmcPipeInterface>("uc") ){
}


//---
MmcController::~MmcController() {
}


//---
void
MmcController::hardReset() {
  // MP7_LOG(l7::kInfo) << "MP7 board is being rebooted";
  // mMmcNode.BoardHardReset("RuleBritannia");
  MmcManager mgr(mMmcNode);

  mgr.hardReset(); 
}


//---
void
MmcController::rebootFPGA(const std::string& aSdFilename) {
  // mMmcNode.RebootFPGA(aSdFilename, "RuleBritannia");
  // mp7::millisleep(3000);

  // std::string textSpace = mMmcNode.GetTextSpace();
  // if (textSpace == aSdFilename)
  //   MP7_LOG(l7::kInfo) << "FPGA has rebooted with firmware image " << aSdFilename;
  // else
  //   MP7_LOG(l7::kWarning) << "FPGA failed to boot with image \"" << aSdFilename << "\". Rebooted with GoldenImage.bin";
  MmcManager mgr(mMmcNode);

  mgr.rebootFPGA(aSdFilename); 
}


//---
void
MmcController::setDummySensorValue(const uint8_t aValue) {
  // mMmcNode.SetDummySensor(aValue);

  MmcManager mgr(mMmcNode);

  mgr.setDummySensorValue(aValue);
}


//---
std::vector<std::string>
MmcController::filesOnSD() {
  // return mMmcNode.ListFilesOnSD();

  MmcManager mgr(mMmcNode);

  return mgr.filesOnSD();
}


//---
void
MmcController::copyFileToSD(const std::string& aLocalPath, const std::string& aSdFilename) {

  // if (aSdFilename.size() > 31) {
  //   mp7::SDCardError e("\"" + aSdFilename + "\" exceeds the maximum number of characters allowed for SD card filenames.");
  //   MP7_LOG(l7::kError) << e.what();
  //   throw e;

  // } else if (aSdFilename == "GoldenImage.bin") {
  //   mp7::SDCardError e("MmcManager cannot upload MP7 firmware image \"GoldenImage.bin\"");
  //   MP7_LOG(l7::kError) << e.what();
  //   throw e;
  // }


  // MP7_LOG(l7::kInfo) << "Uploading file \"" << aLocalPath << "\" to SD card (SD filename \"" << aSdFilename << "\")";


  // std::string ext = boost::filesystem::path(aLocalPath).extension().c_str();
  // if (ext == ".bin") {
  //   mp7::XilinxBinFile firmware(aLocalPath);
  //   mMmcNode.FileToSD(aSdFilename, firmware);
  // } else if (ext == ".bit") {
  //   mp7::XilinxBitFile firmware(aLocalPath);
  //   mMmcNode.FileToSD(aSdFilename, firmware);
  // } else {
  //   mp7::InvalidExtension e("Local file path \"" + aLocalPath + "\" has invalid extension (must be \".bin\" or \".bit\")");
  //   MP7_LOG(l7::kError) << e.what();
  //   throw e;
  // }

  MmcManager mgr(mMmcNode);

  mgr.copyFileToSD(aLocalPath, aSdFilename);
}


//---
void
MmcController::copyFileFromSD(const std::string& aLocalPath, const std::string& aSdFilename) {

  // MP7_LOG(l7::kInfo) << "Copying SD card file \"" << aSdFilename << "\" to local path \"" << aLocalPath << "\"";

  // mp7::XilinxBitStream firmware = mMmcNode.FileFromSD(aSdFilename);

  // MP7_LOG(l7::kDebug) << "Creating local file \"" << aLocalPath << "\"";

  // //TODO: Create directory if it doesn't exist already.

  // std::ofstream localFile(aLocalPath, std::ios::binary);
  // const std::vector<uint8_t>& bitstream(firmware.Bitstream());
  // localFile.write((char*) (&bitstream.front()), bitstream.size());
  // localFile.close();

  // MP7_LOG(l7::kInfo) << "Finished downloading bitstream \"" << aSdFilename << "\" to local path: " << aLocalPath;

  MmcManager mgr(mMmcNode);

  mgr.copyFileFromSD(aLocalPath,aSdFilename);
}


//---
void
MmcController::deleteFileFromSD(const std::string& aSdFilename) {
  // if (aSdFilename == "GoldenImage.bin") {
  //   mp7::SDCardError e("MmcManager cannot delete MP7 firmware image \"GoldenImage.bin\"");
  //   MP7_LOG(l7::kError) << e.what();
  //   throw e;
  // }

  // //TODO: Check that file exists on SD card ?

  // mMmcNode.DeleteFromSD(aSdFilename, "RuleBritannia");
  
  MmcManager mgr(mMmcNode);

  mgr.deleteFileFromSD(aSdFilename);
}


} // namespace mp7
