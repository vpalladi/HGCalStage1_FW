
--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

PACKAGE LinkType IS

  TYPE tLinkPipe IS ARRAY( NATURAL RANGE <> ) OF ldata( cNumberOfLinksIn-1 DOWNTO 0 ) ; -- ( timeslice )( link number )
  CONSTANT cEmptyLinks : ldata( cNumberOfLinksIn-1 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );

END PACKAGE LinkType;
