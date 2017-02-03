--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;


--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;

--! Using the Calo-L2 "ring" helper functions
USE work.ring_functions.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! @brief An entity providing a TowerCount
--! @details Detailed description
ENTITY TowerCount IS
  PORT(
    clk                   : IN STD_LOGIC := '0' ; --! The algorithm clock
    towerThresholdsPipeIn : IN tTowerFlagsPipe ;  --! A pipe of tTowerFlags objects passing out the TowerThresholds's
    towerCountPipeOut     : OUT tRingSegmentPipe2 --! A pipe of tRingSegment objects passing out the towerCount's
  );
END TowerCount;

--! @brief Architecture definition for entity TowerCount
--! @details Detailed description
ARCHITECTURE behavioral OF TowerCount IS

  SIGNAL TowerCount1x1InEtaPhi  : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL TowerCount3x1InEtaPhi  : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL TowerCount9x1InEtaPhi  : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL TowerCount18x1InEtaPhi : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL TowerCount36x1InEtaPhi : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL TowerCount72x1InEtaPhi : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;

  SIGNAL TowerCount72x1InEta    : tRingSegmentInEta    := cEmptyRingSegmentInEta;

BEGIN

  phi   : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE
      TowerCount1x1InEtaPhi( j )( i ) .towerCount( 0 ) <= TO_STD_LOGIC( towerThresholdsPipeIn( 0 )( j )( i ) .PileUpThreshold );
      TowerCount1x1InEtaPhi( j )( i ) .DataValid       <= towerThresholdsPipeIn( 0 )( j )( i ) .DataValid;
    END GENERATE eta;
  END GENERATE phi;

  phi2               : FOR i IN 0 TO( cTowerInPhi / 3 ) -1 GENERATE
    eta2             : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Sum3x1Instance : ENTITY work.RingSegment3Sum
      PORT MAP(
        clk            => clk ,
        RingSegmentIn1 => TowerCount1x1InEtaPhi( j )( ( 3 * i ) ) ,
        RingSegmentIn2 => TowerCount1x1InEtaPhi( j )( ( 3 * i ) + 1 ) ,
        RingSegmentIn3 => TowerCount1x1InEtaPhi( j )( ( 3 * i ) + 2 ) ,
        RingSegmentOut => TowerCount3x1InEtaPhi( j )( i )
      );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta2;
  END GENERATE phi2;

  phi3               : FOR i IN 0 TO( cTowerInPhi / 9 ) -1 GENERATE
    eta3             : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Sum9x1Instance : ENTITY work.RingSegment3Sum
      PORT MAP(
        clk            => clk ,
        RingSegmentIn1 => TowerCount3x1InEtaPhi( j )( ( 3 * i ) ) ,
        RingSegmentIn2 => TowerCount3x1InEtaPhi( j )( ( 3 * i ) + 1 ) ,
        RingSegmentIn3 => TowerCount3x1InEtaPhi( j )( ( 3 * i ) + 2 ) ,
        RingSegmentOut => TowerCount9x1InEtaPhi( j )( i )
      );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta3;
  END GENERATE phi3;

  phi4                : FOR i IN 0 TO( cTowerInPhi / 18 ) -1 GENERATE
    eta4              : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Sum18x1Instance : ENTITY work.RingSegmentSum
      PORT MAP(
        clk            => clk ,
        RingSegmentIn1 => TowerCount9x1InEtaPhi( j )( ( 2 * i ) ) ,
        RingSegmentIn2 => TowerCount9x1InEtaPhi( j )( ( 2 * i ) + 1 ) ,
        RingSegmentOut => TowerCount18x1InEtaPhi( j )( i )
      );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta4;
  END GENERATE phi4;

  phi5                : FOR i IN 0 TO( cTowerInPhi / 36 ) -1 GENERATE
    eta5              : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Sum36x1Instance : ENTITY work.RingSegmentSum
      PORT MAP(
        clk            => clk ,
        RingSegmentIn1 => TowerCount18x1InEtaPhi( j )( ( 2 * i ) ) ,
        RingSegmentIn2 => TowerCount18x1InEtaPhi( j )( ( 2 * i ) + 1 ) ,
        RingSegmentOut => TowerCount36x1InEtaPhi( j )( i )
      );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta5;
  END GENERATE phi5;

  phi6                : FOR i IN 0 TO( cTowerInPhi / 72 ) -1 GENERATE
    eta6              : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Sum72x1Instance : ENTITY work.RingSegmentSum
      PORT MAP(
        clk            => clk ,
        RingSegmentIn1 => TowerCount36x1InEtaPhi( j )( ( 2 * i ) ) ,
        RingSegmentIn2 => TowerCount36x1InEtaPhi( j )( ( 2 * i ) + 1 ) ,
        RingSegmentOut => TowerCount72x1InEtaPhi( j )( i )
      );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta6;
  END GENERATE phi6;

  eta7 : FOR j IN 0 TO cRegionInEta-1 GENERATE
    TowerCount72x1InEta( j ) <= TowerCount72x1InEtaPhi( j )( 0 );
  END GENERATE eta7;

  RingPipeInstance : ENTITY work.RingPipe2
  PORT MAP(
    clk      => clk ,
    RingsIn  => TowerCount72x1InEta ,
    RingPipe => towerCountPipeOut
  );

END ARCHITECTURE behavioral;
