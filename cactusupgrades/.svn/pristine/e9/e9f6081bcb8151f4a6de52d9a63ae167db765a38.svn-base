--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! @brief An entity providing a MHTcoefficientPipe
--! @details Detailed description
ENTITY MHTcoefficientPipe IS
  PORT(
    clk                : IN STD_LOGIC               := '0' ; --! The algorithm clock
    MHTcoefficientsIn  : IN tMHTcoefficientInEtaPhi := cEmptyMHTcoefficientInEtaPhi;
    MHTcoefficientPipe : OUT tMHTcoefficientPipe
  );
END MHTcoefficientPipe;

--! @brief Architecture definition for entity MHTcoefficientPipe
--! @details Detailed description
ARCHITECTURE behavioral OF MHTcoefficientPipe IS
    SIGNAL MHTcoefficientPipeInternal : tMHTcoefficientPipe( MHTcoefficientPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyMHTcoefficientInEtaPhi );
BEGIN

  MHTcoefficientPipeInternal( 0 ) <= MHTcoefficientsIn ; -- since the data is clocked out , no need to clock it in as well...

  gTowerPipe : FOR i IN MHTcoefficientPipe'LENGTH-1 DOWNTO 1 GENERATE
    MHTcoefficientPipeInternal( i ) <= MHTcoefficientPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gTowerPipe;

  MHTcoefficientPipe <= MHTcoefficientPipeInternal;


END ARCHITECTURE behavioral;
