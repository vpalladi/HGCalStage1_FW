/**
 * @file    Measurement.hpp
 * @author  Andrew Rose
 * @date    
 */

#ifndef MP7_MEASUREMENT_HPP
#define MP7_MEASUREMENT_HPP

#include <string>
#include <ostream>
#include <cmath>
#include <limits>

// #define NaN std::numeric_limits<double>::quiet_NaN()

namespace mp7 {

class Measurement {
public:

    static const double kNaN;

    Measurement(const double& aValue = kNaN, const std::string& aUnits = "", const double& aTolerence = kNaN, const std::string& aTolerenceUnits = "") : value(aValue), units(aUnits), tolerence(aTolerence), tolerence_units(aTolerenceUnits) {
    }

    double value;
    std::string units;

    double tolerence;
    std::string tolerence_units;

};

std::ostream& operator<<(std::ostream& aStream, const Measurement& aMeasurement);

}

#endif /* MP7_MEASUREMENT_HPP */

