--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "cluster" data-types
USE work.tower_types.ALL;


--! @brief An entity providing a TowerFlagPipe
--! @details Detailed description
ENTITY TowerFlagPipe IS
  PORT(
    clk           : IN STD_LOGIC          := '0' ; --! The algorithm clock
    TowerFlagsIn  : IN tTowerFlagInEtaPhi := cEmptyTowerFlagInEtaPhi;
    TowerFlagPipe : OUT tTowerFlagsPipe
  );
END TowerFlagPipe;


--! @brief Architecture definition for entity TowerFlagPipe
--! @details Detailed description
ARCHITECTURE behavioral OF TowerFlagPipe IS
    SIGNAL TowerFlagPipeInternal : tTowerFlagsPipe( TowerFlagPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyTowerFlagInEtaPhi );
BEGIN

  TowerFlagPipeInternal( 0 ) <= TowerFlagsIn ; -- since the data is clocked out , no need to clock it in as well...

  gTowerPipe : FOR i IN TowerFlagPipe'LENGTH-1 DOWNTO 1 GENERATE
    TowerFlagPipeInternal( i ) <= TowerFlagPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gTowerPipe;

  TowerFlagPipe <= TowerFlagPipeInternal;


END ARCHITECTURE behavioral;
