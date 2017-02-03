--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;

--! @brief An entity providing a TowerPipe
--! @details Detailed description
ENTITY TowerPipe IS
  PORT(
    clk       : IN STD_LOGIC      := '0' ; --! The algorithm clock
    towersIn  : IN tTowerInEtaPhi := cEmptyTowerInEtaPhi;
    towerPipe : OUT tTowerPipe
  );
END TowerPipe;

--! @brief Architecture definition for entity TowerPipe
--! @details Detailed description
ARCHITECTURE behavioral OF TowerPipe IS
    SIGNAL towerPipeInternal : tTowerPipe( towerPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyTowerInEtaPhi );
BEGIN

  towerPipeInternal( 0 ) <= towersIn ; -- since the data is clocked out , no need to clock it in as well...

  gTowerPipe : FOR i IN( towerPipe'LENGTH-1 ) DOWNTO 1 GENERATE
    towerPipeInternal( i ) <= towerPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gTowerPipe;

  towerPipe <= towerPipeInternal;


END ARCHITECTURE behavioral;
