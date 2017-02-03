#ifndef __CALOL2_UTILITIES_HPP__
#define __CALOL2_UTILITIES_HPP__

// C++ Headers
#include <stdint.h>
#include <vector>

// CaloL2 Headers
#include "calol2/FunkyMiniBus.hpp"

// Boost Headers
#include <boost/filesystem.hpp>

#include "mp7/exception.hpp"

namespace calol2 {
namespace utils {

MP7ExceptionClass( NoSuchFile , "No such file exists" );

std::vector< uint32_t > VectorToBLOB(const std::vector< uint32_t >& aVector, const uint32_t& aWidth);
std::vector< uint32_t > BLOBtoVector(const std::vector< uint32_t >& aBlob, const uint32_t& aWidth);

class MPLUTFileAccess : public FunkyMiniBus::CallbackFunctor {
public:
  boost::filesystem::path mPath;
  const boost::unordered_map< std::string, std::string > mMap;

  MPLUTFileAccess(const std::string& aPath);

  void operator()(const std::string& aName, std::vector< uint32_t >& aData) const;

};


class AllZeros : public FunkyMiniBus::CallbackFunctor {
public:
  AllZeros();

  void operator()(const std::string& aName, std::vector< uint32_t >& aData) const;

};

} // namespace utils
} // namespace calol2

#endif /* __CALOL2_UTILITIES_HPP__ */
