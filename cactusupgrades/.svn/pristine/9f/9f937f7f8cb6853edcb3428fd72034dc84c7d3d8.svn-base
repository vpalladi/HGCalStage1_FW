from math import radians, degrees, atan, sqrt, sin , cos, pi


phi_bits = 12
phi_scale = 2304

mag_bits = 12
hypoteneuse_scale =  1<<mag_bits      # can by any large number including powers of two

n = 8               # more iterations give more accuracy


def mag_renormalization():
  val = 1.0
  for i in range(n):
    val = val / ((1+(4**-i))**0.5);
  return round( hypoteneuse_scale * val )


def rotation( i ):
  return round( phi_scale * atan( 2**-i ) / (2*pi) )



def to_polar(x, y):
  
  if( x >= 0 and y >= 0 ) :
    phi = 0
    sign = True
    x = x
    y = y
  elif( x < 0 and y >= 0 ) :
    phi = ( 0.5 * phi_scale )
    sign = False
    x = -x
    y = y
  elif( x < 0 and y < 0 ) :
    phi = ( 0.5 * phi_scale )
    sign = True
    x = -x
    y = -y    
  else:
    phi = ( phi_scale )
    sign = False
    x = x
    y = -y    

  #print " | " , phi , "..." , x , y

  for i in range(n):
    
    if y<0:
      new_x = x - (y >> i)
      new_y = y + (x >> i)
    else:    
      new_x = x + (y >> i)
      new_y = y - (x >> i)

    if (y < 0) == sign :
      new_phi = phi - rotation( i )
    else:    
      new_phi = phi + rotation( i )

    x = new_x
    y = new_y
    phi = new_phi
         
    #print " > " , phi , "..." , x , y
    #print rotation(i)

  #print " > " , phi , (int(x * mag_renormalization()) >> mag_bits) , x , y

  return int(phi) , int(x * mag_renormalization()) >> mag_bits



#arctan , hypoteneuse = to_polar( int(+x*hypoteneuse_scale) , int(+y*hypoteneuse_scale) )
#print "x+ y+ : " , arctan/float(hypoteneuse_scale) , degrees( atan( +y/ +x) )

#arctan , hypoteneuse = to_polar( int(+x*hypoteneuse_scale) , int(-y*hypoteneuse_scale) )
#print "x+ y- : " , arctan/float(hypoteneuse_scale) , degrees( atan( -y/ +x) )

#arctan , hypoteneuse = to_polar( int(-x*hypoteneuse_scale) , int(+y*hypoteneuse_scale) )
#print "x- y+ : " , arctan/float(hypoteneuse_scale) , degrees( atan( +y/ -x) )

#arctan , hypoteneuse = to_polar( int(-x*hypoteneuse_scale) , int(-y*hypoteneuse_scale) )
#print "x- y- : " , arctan/float(hypoteneuse_scale) , degrees( atan( -y/ -x) )

#print "HYPOTENEUSE : " , hypoteneuse/float(hypoteneuse_scale) , sqrt( (x*x)+(y*y) )


for phi in range( 360 ):
  
  x = 5*cos( radians( phi ) )
  y = 5*sin( radians( phi ) )
  
  arctan , hypoteneuse = to_polar( int(x*hypoteneuse_scale) , int(y*hypoteneuse_scale) )

  #d_arctan = arctan/float(hypoteneuse_scale) - phi
  #d_arctan = arctan/float(hypoteneuse_scale) - towers( atan(y/x) )
  #d_hypoteneuse = hypoteneuse/float(hypoteneuse_scale) - sqrt( (x*x)+(y*y) )
  #print "{1}\t{2}\t{0}\t|\t{3}\t{4}\t|\t{5}\t{6}".format( phi , (x < 0) , (y < 0) , arctan , arctan/float(phi_scale) , hypoteneuse , hypoteneuse/float(hypoteneuse_scale)  )
  print "{0}\t|\t{1}\t{2}".format( phi , arctan , arctan*360./float(phi_scale)  )

  #print "phi {0} : {1}\t{2}".format( phi , arctan , hypoteneuse )

