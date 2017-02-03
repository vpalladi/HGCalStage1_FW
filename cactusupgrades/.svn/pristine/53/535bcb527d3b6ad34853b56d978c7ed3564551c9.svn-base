from math import *

with open( "alpha_cos_8to9.mif" , "w" ) as f:
	for i in range( 256 ):
		if i < 144 :
			lCos = int( round( 255 * cos( i * 0.044 ) , 0 ) )
			f.write( "0x%05X\n" % ( lCos & 0x1FF ) )
		else:
			f.write( "0x%05X\n" % 255 )

with open( "beta_cosh_8to18.mif" , "w" ) as f:
	for i in range( 256 ):
		if i < 222 :
			lCosh = int( round( 262143 * cosh( i * 0.044 ) , 0 ) )
			f.write( "0x%05X\n" % ( lCosh & 0x3FFFF ) )
		else:
			f.write( "0x%05X\n" % 262143 )			