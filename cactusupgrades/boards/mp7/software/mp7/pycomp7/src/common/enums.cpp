/**
 * @file    enums.hpp
 * @author  Alessandro Thea
 * @date    December 2014
 */

// Boost Headers
#include <boost/python/def.hpp>
#include <boost/python/wrapper.hpp>
#include <boost/python/overloads.hpp>
#include <boost/python/class.hpp>
#include <boost/python/enum.hpp>

// MP7 Headers
#include "mp7/definitions.hpp"

// Namespace resolution
using namespace boost::python;


namespace pycomp7 {

void
register_enums() {

    enum_<mp7::MP7Kind> ("MP7Kind")
      .value("kMP7Xe",     mp7::kMP7Xe)
      .value("kMP7R1",     mp7::kMP7R1)
      .value("kMP7Sim",    mp7::kMP7Sim)
      .value("kMP7Unknown",mp7::kMP7Unknown)
      .export_values()
    ;

    // Wrap FormatterKind
    enum_<mp7::FormatterKind> ("FormatterKind")
        .value("kNoFormatter",  mp7::kNoFormatter)
        .value("kTDRFormatter",    mp7::kTDRFormatter)
        .value("kStage1Formatter", mp7::kStage1Formatter)
        .value("kDemuxFormatter",  mp7::kDemuxFormatter)
        .value("kUnknownFormatter",  mp7::kUnknownFormatter)
        .export_values()
    ;

    enum_<mp7::RxTxSelector> ("RxTxSelector")
        .value("kRx", mp7::kRx)
        .value("kTx", mp7::kTx)
        .export_values()
    ;

    enum_<mp7::TTCBCommand>("TTCBCommand")
        .value("kBC0", mp7::kBC0)
        .value("kEC0", mp7::kEC0)
        .value("kResync", mp7::kResync)
        .value("kOC0", mp7::kOC0)
        .value("kTest", mp7::kTest)
        .value("kStart", mp7::kStart)
        .value("kStop", mp7::kStop)
    ; 

    enum_<mp7::TTSState>("TTSState")
        .value("kDisconnectedLow", mp7::kDisconnectedLow )
        .value("kWarningOverflow", mp7::kWarningOverflow )
        .value("kOutOfSync", mp7::kOutOfSync )
        .value("kBusy", mp7::kBusy )
        .value("kReady", mp7::kReady )
        .value("kError", mp7::kError )
        .value("kDisconnectedHigh", mp7::kDisconnectedHigh )
    ;

}

} // namespace mp7