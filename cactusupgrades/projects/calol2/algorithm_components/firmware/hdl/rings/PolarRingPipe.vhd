--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! @brief An entity providing a PolarRingPipe
--! @details Detailed description
ENTITY PolarRingPipe IS
  PORT(
    clk           : IN STD_LOGIC         := '0' ; --! The algorithm clock
    PolarRingIn   : IN tPolarRingSegment := cEmptyPolarRingSegment;
    PolarRingPipe : OUT tPolarRingSegmentPipe
  );
END PolarRingPipe;

--! @brief Architecture definition for entity PolarRingPipe
--! @details Detailed description
ARCHITECTURE behavioral OF PolarRingPipe IS
    SIGNAL PolarRingPipeInternal : tPolarRingSegmentPipe( PolarRingPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyPolarRingSegment );
BEGIN

  PolarRingPipeInternal( 0 ) <= PolarRingIn ; -- since the data is clocked out , no need to clock it in as well...

  gTowerPipe : FOR i IN PolarRingPipe'LENGTH-1 DOWNTO 1 GENERATE
    PolarRingPipeInternal( i ) <= PolarRingPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gTowerPipe;

  PolarRingPipe <= PolarRingPipeInternal;

END ARCHITECTURE behavioral;
