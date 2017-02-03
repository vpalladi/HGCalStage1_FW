/* 
 * File:   Frame.hpp
 * Author: ale
 *
 * Created on December 1, 2014, 5:29 PM
 */

#ifndef MP7_FRAME_HPP
#define	MP7_FRAME_HPP

#include <stdint.h>
#include <ostream>

namespace mp7 {
class Frame {
public:
    Frame();
    
    bool operator == ( const Frame& o) const;
    bool operator != ( const Frame& o) const;
    
    bool strobe;
    bool valid;
    uint32_t data;

};

std::ostream& operator<<(std::ostream& theStream, const mp7::Frame& frame);

} // namespace mp7

#endif	/* MP7_FRAME_HPP */

