#include "mp7/MP7Controller.hpp"
#include "calol2/FunkyMiniBus.hpp"

namespace calol2 {

class CaloL2Controller : public mp7::MP7Controller {
public:
  CaloL2Controller(const uhal::HwInterface& aHw);
  virtual ~CaloL2Controller();

  FunkyMiniBus& funkyMgr();

  virtual void resetPayload();

private:

  FunkyMiniBus mFunkyManager;
  
};


} // namespace calol2