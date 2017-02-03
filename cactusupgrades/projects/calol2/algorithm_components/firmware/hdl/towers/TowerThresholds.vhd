
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

--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;

--! @brief An entity providing a TowerThresholds
--! @details Detailed description
ENTITY TowerThresholds IS
    GENERIC(
      ThresholdFormingOffset : INTEGER := 0
    );
    PORT(
      clk                    : IN STD_LOGIC;
      towerPipeIn            : IN tTowerPipe ;       --! A pipe of tTower objects bringing in the tower's
      TowerThresholdsPipeOut : OUT tTowerFlagsPipe ; --! A pipe of tTowerFlags objects passing out the TowerThresholds's
      BusIn                  : IN tFMBus;
      BusOut                 : OUT tFMBus;
      BusClk                 : IN STD_LOGIC := '0'
    );
END ENTITY TowerThresholds;

--! @brief Architecture definition for entity TowerThresholds
--! @details Detailed description
ARCHITECTURE behavioral OF TowerThresholds IS

---------------------------------
-- Signal Declarations --
---------------------------------
  SIGNAL TowerThresholdsInt                                                           : tTowerFlagInEtaPhi             := cEmptyTowerFlagInEtaPhi;

-- THRESHOLDS.
  SIGNAL JetSeedThreshold , ClusterSeedThreshold , ClusterThreshold , PileUpThreshold : STD_LOGIC_VECTOR( 8 DOWNTO 0 ) := ( OTHERS => '0' );

  CONSTANT x                                                                          : INTEGER                        := BusOut'LOW;
  SUBTYPE JetSeedThresholdAddress     IS NATURAL RANGE x + 0 TO x + 0;
  SUBTYPE ClusterSeedThresholdAddress IS NATURAL RANGE x + 1 TO x + 1;
  SUBTYPE ClusterThresholdAddress     IS NATURAL RANGE x + 2 TO x + 2;
  SUBTYPE PileUpThresholdAddress      IS NATURAL RANGE x + 3 TO x + 3;

BEGIN


-- --------------------------------------------------
  JetSeedThresholdInstance : ENTITY work.GenRegister
  GENERIC MAP(
    BusName      => "JetSeedThr" ,
    DefaultValue => DefaultJetSeedThreshold ,
    Registering  => 2
  )
  PORT MAP(
    DataOut => JetSeedThreshold ,
    BusIn   => BusIn( JetSeedThresholdAddress ) ,
    BusOut  => BusOut( JetSeedThresholdAddress ) ,
    BusClk  => BusClk
  );
-- --------------------------------------------------
  ClusterSeedThresholdInstance : ENTITY work.GenRegister
  GENERIC MAP(
    BusName      => "ClstrSeedThr" ,
    DefaultValue => DefaultClusterSeedThreshold ,
    Registering  => 2
  )
  PORT MAP(
    DataOut => ClusterSeedThreshold ,
    BusIn   => BusIn( ClusterSeedThresholdAddress ) ,
    BusOut  => BusOut( ClusterSeedThresholdAddress ) ,
    BusClk  => BusClk
  );
-- --------------------------------------------------
  ClusterThresholdInstance : ENTITY work.GenRegister
  GENERIC MAP(
    BusName      => "ClstrThr" ,
    DefaultValue => DefaultClusterThreshold ,
    Registering  => 2
  )
  PORT MAP(
    DataOut => ClusterThreshold ,
    BusIn   => BusIn( ClusterThresholdAddress ) ,
    BusOut  => BusOut( ClusterThresholdAddress ) ,
    BusClk  => BusClk
  );
-- --------------------------------------------------
  PileUpThresholdInstance : ENTITY work.GenRegister
  GENERIC MAP(
    BusName      => "PileUpThr" ,
    DefaultValue => DefaultPileUpThreshold ,
    Registering  => 2
  )
  PORT MAP(
    DataOut => PileUpThreshold ,
    BusIn   => BusIn( PileUpThresholdAddress ) ,
    BusOut  => BusOut( PileUpThresholdAddress ) ,
    BusClk  => BusClk
  );
-- --------------------------------------------------


  phi   : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE

      PROCESS( CLK )
      BEGIN
        IF RISING_EDGE( CLK ) THEN

          IF NOT towerPipeIn( ThresholdFormingOffset )( j )( i ) .DataValid THEN
            TowerThresholdsInt( j )( i ) <= cEmptyTowerFlags;
          ELSE
            TowerThresholdsInt( j )( i ) .JetSeedThreshold     <= ( towerPipeIn( ThresholdFormingOffset )( j )( i ) .Energy >= UNSIGNED( JetSeedThreshold ) );
            TowerThresholdsInt( j )( i ) .ClusterSeedThreshold <= ( towerPipeIn( ThresholdFormingOffset )( j )( i ) .Energy >= UNSIGNED( ClusterSeedThreshold ) );
            TowerThresholdsInt( j )( i ) .ClusterThreshold     <= ( towerPipeIn( ThresholdFormingOffset )( j )( i ) .Energy >= UNSIGNED( ClusterThreshold ) );
            TowerThresholdsInt( j )( i ) .PileUpThreshold      <= ( towerPipeIn( ThresholdFormingOffset )( j )( i ) .Energy > UNSIGNED( PileUpThreshold ) );
            TowerThresholdsInt( j )( i ) .DataValid            <= TRUE;
          END IF;
        END IF;
      END PROCESS;

    END GENERATE eta;
  END GENERATE phi;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  TowerFlagPipeInstance : ENTITY work.TowerFlagPipe
  PORT MAP(
    clk           => clk ,
    TowerFlagsIn  => TowerThresholdsInt ,
    TowerFlagPipe => TowerThresholdsPipeOut
  );


END ARCHITECTURE behavioral;
