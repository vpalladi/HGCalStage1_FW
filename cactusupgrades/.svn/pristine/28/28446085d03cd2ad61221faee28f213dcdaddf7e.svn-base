--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! @brief An entity providing a RingPipe
--! @details Detailed description
ENTITY RingPipe IS
  PORT(
    clk      : IN STD_LOGIC            := '0' ; --! The algorithm clock
    RingsIn  : IN tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
    RingPipe : OUT tRingSegmentPipe
  );
END RingPipe;

--! @brief Architecture definition for entity RingPipe
--! @details Detailed description
ARCHITECTURE behavioral OF RingPipe IS
    SIGNAL RingPipeInternal : tRingSegmentPipe( RingPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyRingSegmentInEtaPhi );
BEGIN

  RingPipeInternal( 0 ) <= RingsIn ; -- since the data is clocked out , no need to clock it in as well...

  gTowerPipe : FOR i IN RingPipe'LENGTH-1 DOWNTO 1 GENERATE
    RingPipeInternal( i ) <= RingPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gTowerPipe;

  RingPipe <= RingPipeInternal;

END ARCHITECTURE behavioral;

-- -----------------------------------------------------------------------------------------------------------------------------------------

--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! @brief An entity providing a RingPipe2
--! @details Detailed description
ENTITY RingPipe2 IS
  PORT(
    clk      : IN STD_LOGIC         := '0' ; --! The algorithm clock
    RingsIn  : IN tRingSegmentInEta := cEmptyRingSegmentInEta;
    RingPipe : OUT tRingSegmentPipe2
  );
END RingPipe2;

--! @brief Architecture definition for entity RingPipe2
--! @details Detailed description
ARCHITECTURE behavioral OF RingPipe2 IS
    SIGNAL RingPipeInternal : tRingSegmentPipe2( RingPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyRingSegmentInEta );
BEGIN

  RingPipeInternal( 0 ) <= RingsIn ; -- since the data is clocked out , no need to clock it in as well...

  gTowerPipe : FOR i IN RingPipe'LENGTH-1 DOWNTO 1 GENERATE
    RingPipeInternal( i ) <= RingPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gTowerPipe;

  RingPipe <= RingPipeInternal;

END ARCHITECTURE behavioral;
