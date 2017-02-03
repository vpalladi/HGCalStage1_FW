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

--! Using the Calo-L2 "ring" helper functions
USE work.ring_functions.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! @brief An entity providing a ETandMETsums
--! @details Detailed description
ENTITY ETandMETsums IS
  PORT(
    clk         : IN STD_LOGIC := '0' ; --! The algorithm clock
    towerPipeIn : IN tTowerPipe ;       --! A pipe of tTower objects bringing in the tower's
    ringPipeOut : OUT tRingSegmentPipe2 --! A pipe of tRingSegment objects passing out the ring's
  );
END ETandMETsums;

--! @brief Architecture definition for entity ETandMETsums
--! @details Detailed description
ARCHITECTURE behavioral OF ETandMETsums IS


  TYPE tSLVInPhi    IS ARRAY( 0 TO cTowerInPhi-1 ) OF STD_LOGIC_VECTOR( 35 DOWNTO 0 );
  TYPE tSLVInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tSLVInPhi ; -- Two halves in eta

  SIGNAL towerEnergyInEtaPhi                 : tSLVInEtaPhi         := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL xMultOutInEtaPhi , yMultOutInEtaPhi : tSLVInEtaPhi         := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );

  SIGNAL EtRings1x1InEtaPhi                  : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL EtRings3x1InEtaPhi                  : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL EtRings9x1InEtaPhi                  : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL EtRings18x1InEtaPhi                 : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL EtRings36x1InEtaPhi                 : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL EtRings72x1InEtaPhi                 : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;

  SIGNAL EtRings72x1InEta                    : tRingSegmentInEta    := cEmptyRingSegmentInEta;

BEGIN

  phi   : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE

      towerEnergyInEtaPhi( j )( i )( 8 DOWNTO 0 ) <= STD_LOGIC_VECTOR( towerPipeIn( 0 )( j )( i ) .Energy );

      XcomponentMultiplier : ENTITY work.multiplier16Ux11S
      PORT MAP(
        clk => clk ,
        a   => towerEnergyInEtaPhi( j )( i )( 15 DOWNTO 0 ) ,
        b   => STD_LOGIC_VECTOR( CosineCoefficient( i ) ) ,
        p   => xMultOutInEtaPhi( j )( i ) -- ( 19 downto 0 ) are valid data
      );

      YcomponentMultiplier : ENTITY work.multiplier16Ux11S
      PORT MAP(
        clk => clk ,
        a   => towerEnergyInEtaPhi( j )( i )( 15 DOWNTO 0 ) ,
        b   => STD_LOGIC_VECTOR( SineCoefficient( i ) ) ,
        p   => yMultOutInEtaPhi( j )( i ) -- ( 19 downto 0 ) are valid data
      );

      EtRings1x1InEtaPhi( j )( i ) .xComponent <= SIGNED( xMultOutInEtaPhi( j )( i )( 31 DOWNTO 0 ) ) ; -- ( 19 downto 0 ) are valid data , data shifted by 10
      EtRings1x1InEtaPhi( j )( i ) .yComponent <= SIGNED( yMultOutInEtaPhi( j )( i )( 31 DOWNTO 0 ) ) ; -- ( 19 downto 0 ) are valid data , data shifted by 10

      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN
          IF( NOT towerPipeIn( 0 )( j )( i ) .DataValid ) THEN
            EtRings1x1InEtaPhi( j )( i ) .Energy     <= ( OTHERS => '0' );
            EtRings1x1InEtaPhi( j )( i ) .Ecal       <= ( OTHERS => '0' );
            EtRings1x1InEtaPhi( j )( i ) .towerCount <= ( OTHERS => '0' );
            EtRings1x1InEtaPhi( j )( i ) .DataValid  <= FALSE;
          ELSE
            EtRings1x1InEtaPhi( j )( i ) .Energy( 8 DOWNTO 0 ) <= towerPipeIn( 0 )( j )( i ) .Energy;
            EtRings1x1InEtaPhi( j )( i ) .Ecal( 8 DOWNTO 0 )   <= towerPipeIn( 0 )( j )( i ) .Ecal;
            EtRings1x1InEtaPhi( j )( i ) .DataValid            <= TRUE;

            IF towerPipeIn( 0 )( j )( i ) .HcalFeature THEN
              EtRings1x1InEtaPhi( j )( i ) .towerCount( 0 ) <= '1';
            ELSE
              EtRings1x1InEtaPhi( j )( i ) .towerCount( 0 ) <= '0';
            END IF;

          END IF;
        END IF;
      END PROCESS;

    END GENERATE eta;
  END GENERATE phi;

  phi2               : FOR i IN 0 TO( cTowerInPhi / 3 ) -1 GENERATE
    eta2             : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Sum3x1Instance : ENTITY work.RingSegment3Sum
      GENERIC MAP(
        Size => 25
      )
      PORT MAP(
        clk            => clk ,
        ringSegmentIn1 => EtRings1x1InEtaPhi( j )( ( 3 * i ) ) ,
        ringSegmentIn2 => EtRings1x1InEtaPhi( j )( ( 3 * i ) + 1 ) ,
        ringSegmentIn3 => EtRings1x1InEtaPhi( j )( ( 3 * i ) + 2 ) ,
        ringSegmentOut => EtRings3x1InEtaPhi( j )( i )
      );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta2;
  END GENERATE phi2;

  phi3               : FOR i IN 0 TO( cTowerInPhi / 9 ) -1 GENERATE
    eta3             : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Sum9x1Instance : ENTITY work.RingSegment3Sum
      GENERIC MAP(
        Size => 25
      )
      PORT MAP(
        clk            => clk ,
        ringSegmentIn1 => EtRings3x1InEtaPhi( j )( ( 3 * i ) ) ,
        ringSegmentIn2 => EtRings3x1InEtaPhi( j )( ( 3 * i ) + 1 ) ,
        ringSegmentIn3 => EtRings3x1InEtaPhi( j )( ( 3 * i ) + 2 ) ,
        ringSegmentOut => EtRings9x1InEtaPhi( j )( i )
      );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta3;
  END GENERATE phi3;

  phi4                : FOR i IN 0 TO( cTowerInPhi / 18 ) -1 GENERATE
    eta4              : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Sum18x1Instance : ENTITY work.RingSegmentSum
      GENERIC MAP(
        Size => 25
      )
      PORT MAP(
        clk            => clk ,
        ringSegmentIn1 => EtRings9x1InEtaPhi( j )( ( 2 * i ) ) ,
        ringSegmentIn2 => EtRings9x1InEtaPhi( j )( ( 2 * i ) + 1 ) ,
        ringSegmentOut => EtRings18x1InEtaPhi( j )( i )
      );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta4;
  END GENERATE phi4;

  phi5                : FOR i IN 0 TO( cTowerInPhi / 36 ) -1 GENERATE
    eta5              : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Sum36x1Instance : ENTITY work.RingSegmentSum
      GENERIC MAP(
        Size => 25
      )
      PORT MAP(
        clk            => clk ,
        ringSegmentIn1 => EtRings18x1InEtaPhi( j )( ( 2 * i ) ) ,
        ringSegmentIn2 => EtRings18x1InEtaPhi( j )( ( 2 * i ) + 1 ) ,
        ringSegmentOut => EtRings36x1InEtaPhi( j )( i )
      );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta5;
  END GENERATE phi5;

  phi6                : FOR i IN 0 TO( cTowerInPhi / 72 ) -1 GENERATE
    eta6              : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Sum72x1Instance : ENTITY work.RingSegmentSum
      GENERIC MAP(
        Size => 25
      )
      PORT MAP(
        clk            => clk ,
        ringSegmentIn1 => EtRings36x1InEtaPhi( j )( ( 2 * i ) ) ,
        ringSegmentIn2 => EtRings36x1InEtaPhi( j )( ( 2 * i ) + 1 ) ,
        ringSegmentOut => EtRings72x1InEtaPhi( j )( i )
      );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta6;
  END GENERATE phi6;

  eta7 : FOR j IN 0 TO cRegionInEta-1 GENERATE
    EtRings72x1InEta( j ) <= EtRings72x1InEtaPhi( j )( 0 ) ; -- ( 24 downto 0 ) are valid data , data shifted by 10
  END GENERATE eta7;

  RingPipeInstance : ENTITY work.RingPipe2
  PORT MAP(
    clk      => clk ,
    RingsIn  => EtRings72x1InEta ,
    RingPipe => ringPipeOut
  );

END ARCHITECTURE behavioral;
