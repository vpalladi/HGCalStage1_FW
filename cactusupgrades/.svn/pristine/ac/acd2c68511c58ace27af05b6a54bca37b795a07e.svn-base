// Boost Headers
#include <boost/python/module.hpp>
#include <boost/python/def.hpp>
//#include <boost/python/wrapper.hpp>
//#include <boost/python/enum.hpp>
#include <boost/python/operators.hpp>
#include <boost/python/copy_const_reference.hpp>
#include <boost/python/return_internal_reference.hpp>
#include <boost/python/overloads.hpp>
#include <boost/python/bases.hpp>
#include <boost/python/init.hpp>
#include <boost/python/class.hpp>
#include <boost/python/iterator.hpp>
#include <boost/python/str.hpp>
//#include <boost/python.hpp>

#include "calol2/FunkyMiniBus.hpp"
#include "calol2/CaloL2Controller.hpp"
#include "calol2/Utilities.hpp"

namespace bpy = boost::python;

// *** N.B: The argument of this BOOST_PYTHON_MODULE macro MUST be the same as the name of the library created, i.e. if creating library file my_py_binds_module.so , imported in python as:
//                import my_py_binds_module
//          then would have to put
//                BOOST_PYTHON_MODULE(my_py_binds_module)
//          Otherwise, will get the error message "ImportError: dynamic module does not define init function (initmy_py_binds_module)
BOOST_PYTHON_MODULE(_pycalol2) {
  
  // Wrap FunkyMiniBus
  {
    // FunkyMiniBus scoping (add calol2 namespace)
    bpy::scope calol2_FunkyMiniBus_scope = bpy::class_<calol2::FunkyMiniBus, boost::noncopyable > ("FunkyMiniBus", bpy::init<const uhal::Node&>())        
      .def(/*__str__*/ bpy::self_ns::str(bpy::self))
      .def("__iter__", bpy::range(//&calol2::FunkyMiniBus::cbegin, &calol2::FunkyMiniBus::cend)
        static_cast<calol2::FunkyMiniBus::const_iterator (calol2::FunkyMiniBus::*)() const>(&calol2::FunkyMiniBus::begin),
        static_cast<calol2::FunkyMiniBus::const_iterator (calol2::FunkyMiniBus::*)() const>(&calol2::FunkyMiniBus::end))
      )
      .def("__len__", &calol2::FunkyMiniBus::size)
      .def("lock", &calol2::FunkyMiniBus::lock)
      .def("unlock", &calol2::FunkyMiniBus::unlock)
//      .def("autoConfigure", static_cast<void (calol2::FunkyMiniBus::*)(calol2::FunkyMiniBus::CallbackFn_t)>(&calol2::FunkyMiniBus::AutoConfigure))
      .def("autoConfigure", static_cast<void (calol2::FunkyMiniBus::*)(const calol2::FunkyMiniBus::CallbackFunctor&)>(&calol2::FunkyMiniBus::AutoConfigure))
      .def("readToFile", &calol2::FunkyMiniBus::ReadToFile)
    ;

    // Wrap FunkyMiniBus::Endpoint
    bpy::class_<calol2::FunkyMiniBus::Endpoint > ("Endpoint", bpy::no_init)
        .def(/*__str__*/ bpy::self_ns::str(bpy::self))
        .def("size", &calol2::FunkyMiniBus::Endpoint::size)
        .def("width", &calol2::FunkyMiniBus::Endpoint::width)
        .def("name", &calol2::FunkyMiniBus::Endpoint::name, bpy::return_value_policy<bpy::copy_const_reference>())
        .def("read", &calol2::FunkyMiniBus::Endpoint::read)
        .def("write", &calol2::FunkyMiniBus::Endpoint::write)
        .def("lock", &calol2::FunkyMiniBus::Endpoint::lock)
    ;
    
    // Abstract -> noncopiable
    bpy::class_<calol2::FunkyMiniBus::CallbackFunctor , boost::noncopyable > ("CallbackFunctor", bpy::no_init);

  }
  
  bpy::class_<calol2::utils::MPLUTFileAccess, bpy::bases<calol2::FunkyMiniBus::CallbackFunctor> > ("MPLUTFileAccess", bpy::init<const std::string&>());
  bpy::class_<calol2::utils::AllZeros, bpy::bases<calol2::FunkyMiniBus::CallbackFunctor> > ("AllZeros", bpy::init<>());


  bpy::class_<calol2::CaloL2Controller, bpy::bases<mp7::MP7Controller>, boost::noncopyable>("CaloL2Controller", bpy::init<const uhal::HwInterface& >())
      .def("funkyMgr", &calol2::CaloL2Controller::funkyMgr, bpy::return_internal_reference<>())
  ;
}