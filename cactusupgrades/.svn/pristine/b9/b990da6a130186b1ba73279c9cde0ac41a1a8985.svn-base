--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! @brief An entity providing a ComparisonPipe
--! @details Detailed description
ENTITY ComparisonPipe IS
  PORT(
    clk            : IN STD_LOGIC           := '0' ; --! The algorithm clock
    ComparisonIn   : IN tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;
    ComparisonPipe : OUT tComparisonPipe
  );
END ComparisonPipe;

--! @brief Architecture definition for entity ComparisonPipe
--! @details Detailed description
ARCHITECTURE behavioral OF ComparisonPipe IS
    SIGNAL ComparisonPipeInternal : tComparisonPipe( ComparisonPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyComparisonInEtaPhi );
BEGIN

  ComparisonPipeInternal( 0 ) <= ComparisonIn ; -- since the data is clocked out , no need to clock it in as well...

  gTowerPipe : FOR i IN ComparisonPipe'LENGTH-1 DOWNTO 1 GENERATE
    ComparisonPipeInternal( i ) <= ComparisonPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gTowerPipe;

  ComparisonPipe <= ComparisonPipeInternal;


END ARCHITECTURE behavioral;
