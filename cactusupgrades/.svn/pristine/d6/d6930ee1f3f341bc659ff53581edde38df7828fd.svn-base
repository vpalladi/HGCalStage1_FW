--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! @brief An entity providing a AccumulationCompletePipe
--! @details Detailed description
ENTITY AccumulationCompletePipe IS
  PORT(
    clk                      : IN STD_LOGIC                  := '0' ; --! The algorithm clock
    accumulationCompleteIn   : IN tAccumulationCompleteInEta := cEmptyAccumulationCompleteInEta;
    accumulationCompletePipe : OUT tAccumulationCompletePipe
  );
END AccumulationCompletePipe;

--! @brief Architecture definition for entity AccumulationCompletePipe
--! @details Detailed description
ARCHITECTURE behavioral OF AccumulationCompletePipe IS
    SIGNAL accumulationCompletePipeInternal : tAccumulationCompletePipe( accumulationCompletePipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta );
BEGIN

  accumulationCompletePipeInternal( 0 ) <= accumulationCompleteIn ; -- since the data is clocked out , no need to clock it in as well...

  gTowerPipe : FOR i IN accumulationCompletePipe'LENGTH-1 DOWNTO 1 GENERATE
    accumulationCompletePipeInternal( i ) <= accumulationCompletePipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gTowerPipe;

  accumulationCompletePipe <= accumulationCompletePipeInternal;


END ARCHITECTURE behavioral;
