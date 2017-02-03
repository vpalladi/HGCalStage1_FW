--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;

--! @brief An entity providing a TowerSum
--! @details Detailed description
ENTITY TowerSum IS
  PORT(
    clk      : IN STD_LOGIC := '0' ; --! The algorithm clock
    towerIn1 : IN tTower    := cEmptyTower;
    towerIn2 : IN tTower    := cEmptyTower;
    towerOut : OUT tTower   := cEmptyTower
  );
END TowerSum;

--! @brief Architecture definition for entity TowerSum
--! @details Detailed description
ARCHITECTURE behavioral OF TowerSum IS
BEGIN
  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF( NOT towerIn1.DataValid OR NOT towerIn2.DataValid ) THEN
        towerOut <= cEmptyTower;
      ELSE
        towerOut.EgammaCandidate       <= towerIn1.EgammaCandidate OR towerIn2.EgammaCandidate;
        towerOut.HcalFeature           <= towerIn1.HcalFeature OR towerIn2.HcalFeature;
        towerOut.Ecal( 17 DOWNTO 0 )   <= towerIn1.Ecal + towerIn2.Ecal;
        towerOut.Hcal( 17 DOWNTO 0 )   <= towerIn1.Hcal + towerIn2.Hcal;
        towerOut.Energy( 10 DOWNTO 0 ) <= towerIn1.Energy + towerIn2.Energy;
        towerOut.DataValid             <= TRUE;
      END IF;
    END IF;
  END PROCESS;
END ARCHITECTURE behavioral;
