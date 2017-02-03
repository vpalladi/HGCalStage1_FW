import os

for filename in os.listdir( "ROMs" ):

	binfilepath = os.path.join( "ROMs" , filename )
	hexfilepath = os.path.join( "HexROMs" , filename )

	if not os.path.isfile( binfilepath ):
		continue

	with open( binfilepath , "r" ) as f:
		binfile = f.readlines()

	with open( hexfilepath , "w" ) as f:
		for i in reversed( binfile ):
			f.write( "0x%05X\n" % int( i , 2 ) )
