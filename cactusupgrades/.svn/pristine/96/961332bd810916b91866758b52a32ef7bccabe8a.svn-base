/* 
 * File:   ReadoutCtrlNode.cpp
 * Author: ale
 * 
 * Created on May 18, 2015, 1:37 PM
 */

#include "mp7/ReadoutCtrlNode.hpp"

#include "mp7/Logger.hpp"

// Boost Headers
#include <boost/foreach.hpp>

// Namespace declaration
namespace l7 = mp7::logger;

namespace mp7 {
UHAL_REGISTER_DERIVED_NODE(ReadoutCtrlNode);


//---
ReadoutCtrlNode::ReadoutCtrlNode(const uhal::Node& aNode) :
  uhal::Node(aNode) {
}


//---
ReadoutCtrlNode::~ReadoutCtrlNode() {
}

uint32_t ReadoutCtrlNode::readNumBanks() const {
  uhal::ValWord<uint32_t> banks = getNode("csr.stat.n_banks").read();
  getClient().dispatch();
  return banks;
}

//---
uint32_t
ReadoutCtrlNode::readNumModes() const {
  uhal::ValWord<uint32_t> modes = getNode("csr.stat.n_modes").read();
  getClient().dispatch();
  return modes;
}


//---
uint32_t
ReadoutCtrlNode::readNumCaptures() const {
  uhal::ValWord<uint32_t> caps = getNode("csr.stat.n_caps").read();
  getClient().dispatch();
  return caps;
}


//---
void
ReadoutCtrlNode::selectBank(uint32_t aBank) const {
  getNode("csr.ctrl.bank_sel").write(aBank);
  getClient().dispatch();
}


//---
void
ReadoutCtrlNode::selectMode(uint32_t aMode) const {
  getNode("csr.ctrl.mode_sel").write(aMode);
  getClient().dispatch();
}


//---
void
ReadoutCtrlNode::selectCapture(uint32_t aCapture) const {
  getNode("csr.ctrl.cap_sel").write(aCapture);
  getClient().dispatch();
}


//---
void
ReadoutCtrlNode::setDerandWaterMarks(uint32_t aLowWM, uint32_t aHighWM) const {
  getNode("csr.dr_ctrl.dr_hwm").write(aHighWM); //48 = 25% 
  getNode("csr.dr_ctrl.dr_lwm").write(aLowWM); //32 = 50%
  getClient().dispatch();
}


//---
void ReadoutCtrlNode::reset() const {
  uhal::ValWord<uint32_t> nbanks = getNode("csr.stat.n_banks").read();
  uhal::ValWord<uint32_t> nmodes = getNode("csr.stat.n_modes").read();
  uhal::ValWord<uint32_t> ncaps = getNode("csr.stat.n_caps").read();

  getClient().dispatch();

  for (uint32_t iM(0); iM < nmodes; iM++) {
    // Select
    getNode("csr.ctrl.mode_sel").write(iM);
    // Reset mode specific nodes

    BOOST_FOREACH(const std::string& n, getNodes("mode_csr\\.(ctrl\\..*|user_data)")) {
      getNode(n).write(0x0);
    }

    for (uint32_t iC(0); iC < ncaps; iC++) {
      getNode("csr.ctrl.cap_sel").write(iC);
      // Reset mode specific nodes

      BOOST_FOREACH(const std::string& n, getNodes("cap_csr\\.ctrl\\..*")) {
        getNode(n).write(0x0);
      }
    }

    getClient().dispatch();
  }

}


//---
void ReadoutCtrlNode::configureMenu(const ReadoutMenu& aMenu) const {

  // Read configurations
  uhal::ValWord<uint32_t> nbanks = getNode("csr.stat.n_banks").read();
  uhal::ValWord<uint32_t> nmodes = getNode("csr.stat.n_modes").read();
  uhal::ValWord<uint32_t> ncaps = getNode("csr.stat.n_caps").read();
  getClient().dispatch();

  if (
    aMenu.numBanks() > nbanks or
    aMenu.numModes() > nmodes or
    aMenu.numCaptures() > ncaps 
    ) {
    // Spme errors
    throw std::runtime_error("Can't fit the menu in this fw version!");
  }

  // Check that none of the captures uses bankids with 0 length

  reset();

  for( uint32_t iB(0); iB < nbanks; ++iB) {
    getNode("csr.ctrl.bank_sel").write(iB);
    getNode("bank_csr.ctrl.wp_bx").write(aMenu.bank(iB).wordsPerBx);

  }
  getClient().dispatch();

  for (uint32_t iM(0); iM < nmodes; iM++) {
    const ReadoutMenu::Mode& m = aMenu.mode(iM);

    // Select
    getNode("csr.ctrl.mode_sel").write(iM);

    // Set mode specific nodes
    getNode("mode_csr.ctrl.evt_trig").write(m.eventToTrigger);
    getNode("mode_csr.ctrl.evt_size").write(m.eventSize);
    getNode("mode_csr.hdr.event_type").write(m.eventType);
    // FIXME: token delay is not used anymore. Remove it
    // getNode("mode_csr.ctrl.token_delay").write(m.tokenDelay);

    for (uint32_t iC(0); iC < ncaps; iC++) {

      const ReadoutMenu::Capture& c = aMenu.capture(iM, iC);
      
      // Select
      getNode("csr.ctrl.cap_sel").write(iC);
      getClient().dispatch();
      // Set mode specific nodes
      getNode("cap_csr.ctrl.bank_id").write(c.bankId);
      getNode("cap_csr.ctrl.cap_en").write(c.enable);
      getNode("cap_csr.ctrl.cap_delay").write(c.delay);
      getNode("cap_csr.ctrl.cap_size").write(c.length);
      getNode("cap_csr.ctrl.cap_id").write(c.id);
      getNode("cap_csr.ctrl.readout_length").write(c.readoutLength);

      getClient().dispatch(); // stops sim from freezing up
    }

    // one dispatch per mode - why?
    getClient().dispatch();
  }

}


//---
ReadoutMenu
ReadoutCtrlNode::readMenu() const {

  uhal::ValWord<uint32_t> wpbx;
  uhal::ValWord<uint32_t> evTrig, evSize, eventType;
  // uhal::ValWord<uint32_t> evTrig, evSize, tokenDelay, eventType;
  uhal::ValWord<uint32_t> enable, bankId, capDelay, capSize, captureId, roLength;

  // Read configurations
  uhal::ValWord<uint32_t> nmodes = getNode("csr.stat.n_modes").read();
  uhal::ValWord<uint32_t> ncaps = getNode("csr.stat.n_caps").read();
  uhal::ValWord<uint32_t> nbanks = getNode("csr.stat.n_banks").read();
  getClient().dispatch();

  ReadoutMenu menu = ReadoutMenu(nbanks, nmodes, ncaps);

  for( uint32_t iB(0); iB < nbanks; ++iB) {
    getNode("csr.ctrl.bank_sel").write(iB);
    wpbx = getNode("bank_csr.ctrl.wp_bx").read();
    getClient().dispatch();

    menu.bank(iB).wordsPerBx = wpbx;
  }

  getClient().dispatch();

  for (size_t iM(0); iM < nmodes; iM++) {
    // Select
    getNode("csr.ctrl.mode_sel").write(iM);

    // Set mode specific nodes
    evTrig = getNode("mode_csr.ctrl.evt_trig").read();
    evSize = getNode("mode_csr.ctrl.evt_size").read();
    eventType = getNode("mode_csr.hdr.event_type").read();
    // FIXME: token delay is not used anymore. Remove it
    // tokenDelay = getNode("mode_csr.ctrl.token_delay").read();

    getClient().dispatch();

    auto & m = menu.mode(iM);
    m.eventToTrigger = evTrig;
    m.eventSize = evSize;
    m.eventType = eventType;
    // m.tokenDelay = tokenDelay;
    
    for (size_t iC(0); iC < ncaps; iC++) {
      // Select
      getNode("csr.ctrl.cap_sel").write(iC);

      // Set mode specific nodes
      bankId     = getNode("cap_csr.ctrl.bank_id").read();
      enable     = getNode("cap_csr.ctrl.cap_en").read();
      capDelay   = getNode("cap_csr.ctrl.cap_delay").read();
      capSize    = getNode("cap_csr.ctrl.cap_size").read();
      captureId  = getNode("cap_csr.ctrl.cap_id").read();
      roLength   = getNode("cap_csr.ctrl.readout_length").read();
      
      getClient().dispatch();
      
      auto & c = m[iC];
      
      c.enable = enable;
      c.id = captureId;
      c.bankId = bankId;
      c.length = capSize;
      c.delay = capDelay;
      c.readoutLength = roLength;      
    }
  }

  return menu;

}

//---
ReadoutMenu::ReadoutMenu(size_t aNBanks, size_t aNModes, size_t aNCaptures) :
  mNumBanks(aNBanks),
  mNumModes(aNModes), 
  mNumCaptures(aNCaptures),
  mBanks(aNBanks) {

    for( uint32_t i(0); i<mNumModes; ++i)
      mModes.emplace_back( Mode(mNumCaptures) );
  }


//---
ReadoutMenu::~ReadoutMenu() {
}


//---
size_t
ReadoutMenu::numBanks() const {
  return mNumBanks;
}


//---
size_t
ReadoutMenu::numModes() const {
  return mNumModes;
}


//---
size_t
ReadoutMenu::numCaptures() const {
  return mNumCaptures;
}

ReadoutMenu::Bank& 
ReadoutMenu::bank(size_t i) {
  return mBanks.at(i);
}


const ReadoutMenu::Bank& 
ReadoutMenu::bank(size_t i) const {
  return const_cast<ReadoutMenu*>(this)->bank(i);
}


//---
ReadoutMenu::Mode&
ReadoutMenu::mode(size_t aMode) {
  return mModes.at(aMode);
}


//---
const ReadoutMenu::Mode&
ReadoutMenu::mode(size_t aMode) const {
  return const_cast<ReadoutMenu*>(this)->mode(aMode);
}


//---
void 
ReadoutMenu::setMode(uint32_t aMode, const Mode& aOther) {
  Mode& m = mModes.at(aMode);
  if ( m.size() != aOther.size() ) {
    throw std::runtime_error("ReadoutMenu::Mode size mismatch!");
  }
  m = aOther;
}


//---
ReadoutMenu::Mode::Mode(size_t aSize) : 
  eventSize(0x0),
  eventToTrigger(0x0),
  eventType(0x0),
  // tokenDelay(0x0),
  mCaptures(aSize) {
}


//---
void
ReadoutMenu::Mode::operator=(const ReadoutMenu::Mode& aOther) {
  if (size() != aOther.size()) {
    throw std::runtime_error("ReadoutMenu::Mode assignment error: size mismatch");
  }
  
  eventSize = aOther.eventSize;
  eventToTrigger = aOther.eventToTrigger;
  eventType = aOther.eventType;
  mCaptures = aOther.mCaptures;
}


//---
ReadoutMenu::Capture&
ReadoutMenu::Mode::operator[]( size_t i ) {
  return mCaptures.at(i);
}


//---
const ReadoutMenu::Capture&
ReadoutMenu::Mode::operator[]( size_t i ) const {
  return const_cast<ReadoutMenu::Mode*>(this)->operator [](i);
}


//---
size_t
ReadoutMenu::Mode::size() const {
  return mCaptures.size();
}


//---
ReadoutMenu::Capture&
ReadoutMenu::capture(size_t aMode, size_t aCapture) {
//  return mCaptures.at(aTrgMode * mNumCaptures + aCapMode);
  return this->mode(aMode)[aCapture];
}


//---
const ReadoutMenu::Capture&
ReadoutMenu::capture(size_t aTrgMode, size_t aCapMode) const {
  return const_cast<ReadoutMenu*>(this)->capture(aTrgMode, aCapMode);
}


//---
//ReadoutMenu::Mode&
//ReadoutMenu::mode( size_t i ) {
//  return mModes.at(i);
//}
//
////---
//const ReadoutMenu::Mode&
//ReadoutMenu::mode( size_t i ) const {
//  return const_cast<ReadoutMenu*>(this)->mode(i);
//}
//
////---
//size_t
//ReadoutMenu::size() const {
//  return mModes.size();
//}


//---
std::ostream& operator<<( std::ostream& oStream, const ReadoutMenu::Bank& aBank ) {
  auto fmt = oStream.flags();
  oStream << std::showbase
          << "{wordsPerBx: " << aBank.wordsPerBx << "}";
  oStream.flags(fmt);
  return oStream;
}


//---
std::ostream& operator<<( std::ostream& oStream, const ReadoutMenu::Mode& aMode ) {
  auto fmt = oStream.flags();
  oStream << std::showbase
          << "{eventSize: " << aMode.eventSize 
          << ", eventToTrigger: " << aMode.eventToTrigger
          << ", eventType: " << std::hex << aMode.eventType
          // << ", tokenDelay: " << aMode.tokenDelay
          << "}";
  oStream.flags(fmt);
  return oStream;
}


//---
std::ostream& operator<<( std::ostream& oStream, const ReadoutMenu::Capture& aCapture ) {
  auto fmt = oStream.flags();
  oStream << std::showbase
          << "{enable: " << aCapture.enable
          << ", captureId: " << std::hex << aCapture.id
          << ", bankId: " << aCapture.bankId 
          << ", length: " << aCapture.length
          << ", delay: " << aCapture.delay 
          << ", readoutLength: " << aCapture.readoutLength
          << "}";
  oStream.flags(fmt);
  return oStream;
}


//---
std::ostream& operator<<( std::ostream& oStream, const ReadoutMenu& aMenu ) {

  for( uint32_t iB(0); iB < aMenu.numBanks(); ++iB) {
    oStream << "bank " << iB << ": " << aMenu.bank(iB) << "\n";

  }

  for( uint32_t iM(0); iM < aMenu.numModes(); ++iM) {
    oStream << "mode " << iM << ": " << aMenu.mode(iM) << "\n";

    for (uint32_t iC(0); iC < aMenu.numCaptures(); iC++) {
        oStream << "  capture " << iC <<": " << aMenu.capture(iM,iC) << "\n";
    }
  }
  return oStream;
}

}



