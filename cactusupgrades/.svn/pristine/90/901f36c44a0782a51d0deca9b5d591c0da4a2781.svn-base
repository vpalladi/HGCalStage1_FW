----------------------------------------------------------------------------------
-- oSLB to tower mapping
-- THIS IS CURRENTLY AN EDUCATED GUESS , SINCE I CAN FIND NO DOCUMENTATION...
----------------------------------------------------------------------------------

--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;
--! Using the Calo-L2 "preprocessor" data-types
USE work.preprocessor_types.ALL;
--! Using the Calo-L2 "preprocessor" helper functions
USE work.preprocessor_functions.ALL;

--! @brief An entity providing a oSLBs
--! @details Detailed description
ENTITY oSLBs IS
    PORT( clk         : IN STD_LOGIC                  := '0';
           links_in   : IN ldata( 31 DOWNTO 0 )       := ( OTHERS => LWORD_NULL );
           towers_out : OUT tEcalTowersInRegionEtaPhi := cEmptyOSLBregion
          );
END oSLBs;

--! @brief Architecture definition for entity oSLBs
--! @details Detailed description
ARCHITECTURE behavioral OF oSLBs IS
  TYPE tOSLBregions IS ARRAY( 31 DOWNTO 0 ) OF tOSLBregion;
  SIGNAL lRegions : tOSLBregions := ( OTHERS => cEmptyOSLBregion );
BEGIN

  gOSLBs         : FOR i IN 31 DOWNTO 0 GENERATE
    oSLBinstance : ENTITY work.oSLB
    PORT MAP
    (
      clk        => clk ,
      links_in   => links_in( i ) ,
      region_out => lRegions( i )
    );
  END GENERATE gOSLBs;

  gPhi               : FOR i IN 3 DOWNTO 0 GENERATE
    gEta             : FOR j IN 1 DOWNTO 0 GENERATE
      gRegion        : FOR k IN 1 DOWNTO 0 GENERATE

        gBarrelCards : FOR l IN 7 DOWNTO 0 GENERATE
          tEcalTowersInRegionEtaPhi( k )( ( 2 * l ) + j )( i ) <= ToEcalTower( lRegions( ( 16 * k ) + l ) , ( 4 * l ) + i );
        END GENERATE gBarrelCards;

        gOverlapCards : FOR l IN 9 DOWNTO 8 GENERATE
-- tEcalTowersInRegionEtaPhi( k )( ( 2 * l ) + j )( i ) <= ToEcalTower( lRegions( ( 16 * k ) + l ) , ( 4 * l ) + i );
        END GENERATE gOverlapCards;

        gEndcapCards : FOR l IN 15 DOWNTO 10 GENERATE
          tEcalTowersInRegionEtaPhi( k )( ( 2 * l ) + j )( i ) <= ToEcalTower( lRegions( ( 16 * k ) + l ) , ( 4 * l ) + i );
        END GENERATE gEndcapCards;

      END GENERATE gRegion;
    END GENERATE gEta;
  END GENERATE gPhi;

END ARCHITECTURE behavioral;
