#include "calol2/CaloL2Controller.hpp"
#include "calol2/FunkyMiniBus.hpp"
#include "calol2/Utilities.hpp"
#include "mp7/Logger.hpp"

namespace calol2 {

CaloL2Controller::CaloL2Controller(const uhal::HwInterface& aHw) : 
  mp7::MP7Controller(aHw),
  mFunkyManager(hw().getNode("payload"))
{

}


CaloL2Controller::~CaloL2Controller()
{
}


FunkyMiniBus& CaloL2Controller::funkyMgr()
{
  return mFunkyManager;
}


void CaloL2Controller::resetPayload()
{
  // MP7_LOG(mp7::logger::kInfo) << "Zeroing minibus";
  // Fill minibus endpoints with 0s 
  // funkyMgr().AutoConfigure(utils::AllZeros());
}


} // namespace calol2