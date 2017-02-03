--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;

--! Using the Calo-L2 "ring" helper functions
USE work.ring_functions.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;


--! @brief An entity providing a HTandMHTsums
--! @details Detailed description
ENTITY HTandMHTsums IS
  GENERIC(
    pileUpSubtractedJetOffset : INTEGER := 0
  );
  PORT(
    clk                       : IN STD_LOGIC := '0' ;    --! The algorithm clock
    pileUpSubtractedJetPipeIn : IN tJetPipe ;            --! A pipe of tJet objects bringing in the pileUpSubtractedJet's
    MHTcoefficientPipeIn      : IN tMHTcoefficientPipe ; --! A pipe of tMHTcoefficient objects bringing in the MHTcoefficient's
    ringPipeOut               : OUT tRingSegmentPipe2 ;  --! A pipe of tRingSegment objects passing out the ring's
    BusIn                     : IN tFMBus;
    BusOut                    : OUT tFMBus;
    BusClk                    : IN STD_LOGIC := '0'
  );
END HTandMHTsums;

--! @brief Architecture definition for entity HTandMHTsums
--! @details Detailed description
ARCHITECTURE behavioral OF HTandMHTsums IS
-- SIGNAL PileupSubtractedJetsDelayed : tJetInEtaPhi := cEmptyJetInEtaPhi;

  SIGNAL HtRings4x1InEtaPhi  : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL HtRings12x1InEtaPhi : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL HtRings36x1InEtaPhi : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL HtRings72x1InEtaPhi : tRingSegmentInEtaPhi := cEmptyRingSegmentInEtaPhi;
  SIGNAL HtRings72x1InEta    : tRingSegmentInEta    := cEmptyRingSegmentInEta;

  TYPE tSLVInPhi    IS ARRAY( 0 TO cTowerInPhi-1 ) OF STD_LOGIC_VECTOR( 35 DOWNTO 0 );
  TYPE tSLVInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tSLVInPhi ; -- Two halves in eta

  SIGNAL jetEnergyInEtaPhi                   : tSLVInEtaPhi                    := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL xMultOutInEtaPhi , yMultOutInEtaPhi : tSLVInEtaPhi                    := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );

  SIGNAL HT_Threshold , MHT_Threshold        : STD_LOGIC_VECTOR( 15 DOWNTO 0 ) := ( OTHERS => '0' );

  CONSTANT x                                 : INTEGER                         := BusOut'LOW;
  SUBTYPE HT  IS NATURAL RANGE x + 0 TO x + 0;
  SUBTYPE MHT IS NATURAL RANGE x + 1 TO x + 1;
BEGIN

-- --------------------------------------------------
  HTThresholdInstance : ENTITY work.GenRegister
  GENERIC MAP(
    BusName      => "HT_Thr" ,
    DefaultValue => DefaultHTThreshold ,
    Registering  => 2
  )
  PORT MAP(
    DataOut => HT_Threshold ,
    BusIn   => BusIn( HT ) ,
    BusOut  => BusOut( HT ) ,
    BusClk  => BusClk
  );
-- --------------------------------------------------

-- --------------------------------------------------
  MHTThresholdInstance : ENTITY work.GenRegister
  GENERIC MAP(
    BusName      => "MHT_Thr" ,
    DefaultValue => DefaultMHTThreshold ,
    Registering  => 2
  )
  PORT MAP(
    DataOut => MHT_Threshold ,
    BusIn   => BusIn( MHT ) ,
    BusOut  => BusOut( MHT ) ,
    BusClk  => BusClk
  );
-- --------------------------------------------------

  phi   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE

      jetEnergyInEtaPhi( j )( i )( 15 DOWNTO 0 ) <= STD_LOGIC_VECTOR( pileUpSubtractedJetPipeIn( pileUpSubtractedJetOffset )( j )( i ) .Energy )
                                                    WHEN( pileUpSubtractedJetPipeIn( pileUpSubtractedJetOffset )( j )( i ) .Energy > UNSIGNED( MHT_Threshold ) )
                                                    ELSE( OTHERS => '0' );

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      XcomponentMultiplier : ENTITY work.multiplier16Ux11S
      PORT MAP(
        clk => clk ,
        a   => jetEnergyInEtaPhi( j )( i )( 15 DOWNTO 0 ) ,
        b   => STD_LOGIC_VECTOR( MHTcoefficientPipeIn( 0 )( j )( i ) .CosineCoefficients ) ,
        p   => xMultOutInEtaPhi( j )( i ) -- ( 26 downto 0 ) are valid data
      );

      YcomponentMultiplier : ENTITY work.multiplier16Ux11S
      PORT MAP(
        clk => clk ,
        a   => jetEnergyInEtaPhi( j )( i )( 15 DOWNTO 0 ) ,
        b   => STD_LOGIC_VECTOR( MHTcoefficientPipeIn( 0 )( j )( i ) .SineCoefficients ) ,
        p   => yMultOutInEtaPhi( j )( i ) -- ( 26 downto 0 ) are valid data
      );

      HtRings4x1InEtaPhi( j )( i ) .xComponent <= SIGNED( xMultOutInEtaPhi( j )( i )( 35 DOWNTO 4 ) ) ; -- ( 22 downto 0 ) are valid data , data shifted by 6
      HtRings4x1InEtaPhi( j )( i ) .yComponent <= SIGNED( yMultOutInEtaPhi( j )( i )( 35 DOWNTO 4 ) ) ; -- ( 22 downto 0 ) are valid data , data shifted by 6

      prc : PROCESS( Clk )
      BEGIN
        IF RISING_EDGE( Clk ) THEN
          IF( pileUpSubtractedJetPipeIn( pileUpSubtractedJetOffset )( j )( i ) .Energy > UNSIGNED( HT_Threshold ) ) THEN
            HtRings4x1InEtaPhi( j )( i ) .Energy <= "0000000" & pileUpSubtractedJetPipeIn( pileUpSubtractedJetOffset )( j )( i ) .Energy;
          ELSE
            HtRings4x1InEtaPhi( j )( i ) .Energy <= ( OTHERS => '0' );
          END IF;
          HtRings4x1InEtaPhi( j )( i ) .DataValid <= pileUpSubtractedJetPipeIn( pileUpSubtractedJetOffset )( j )( i ) .DataValid;
        END IF;
      END PROCESS;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta;
  END GENERATE phi;

  phi2                : FOR i IN 0 TO( cTowerInPhi / 12 ) -1 GENERATE
    eta2              : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Sum12x1Instance : ENTITY work.RingSegment3Sum
      GENERIC MAP(
        Size => 25
      )
      PORT MAP(
        clk            => clk ,
        ringSegmentIn1 => HtRings4x1InEtaPhi( j )( ( 3 * i ) ) ,
        ringSegmentIn2 => HtRings4x1InEtaPhi( j )( ( 3 * i ) + 1 ) ,
        ringSegmentIn3 => HtRings4x1InEtaPhi( j )( ( 3 * i ) + 2 ) ,
        ringSegmentOut => HtRings12x1InEtaPhi( j )( i )
      );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta2;
  END GENERATE phi2;

  phi3                : FOR i IN 0 TO( cTowerInPhi / 36 ) -1 GENERATE
    eta3              : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Sum36x1Instance : ENTITY work.RingSegment3Sum
      GENERIC MAP(
        Size => 25
      )
      PORT MAP(
        clk            => clk ,
        ringSegmentIn1 => HtRings12x1InEtaPhi( j )( ( 3 * i ) ) ,
        ringSegmentIn2 => HtRings12x1InEtaPhi( j )( ( 3 * i ) + 1 ) ,
        ringSegmentIn3 => HtRings12x1InEtaPhi( j )( ( 3 * i ) + 2 ) ,
        ringSegmentOut => HtRings36x1InEtaPhi( j )( i )
      );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta3;
  END GENERATE phi3;

  phi4                : FOR i IN 0 TO( cTowerInPhi / 72 ) -1 GENERATE
    eta4              : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      Sum72x1Instance : ENTITY work.RingSegmentSum
      GENERIC MAP(
        Size => 25
      )
      PORT MAP(
        clk            => clk ,
        ringSegmentIn1 => HtRings36x1InEtaPhi( j )( ( 2 * i ) ) ,
        ringSegmentIn2 => HtRings36x1InEtaPhi( j )( ( 2 * i ) + 1 ) ,
        ringSegmentOut => HtRings72x1InEtaPhi( j )( i )
      );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta4;
  END GENERATE phi4;

  eta5 : FOR j IN 0 TO cRegionInEta-1 GENERATE
    HtRings72x1InEta( j ) <= HtRings72x1InEtaPhi( j )( 0 ) ; -- ( 24 downto 0 ) are valid data , data shifted by 6
  END GENERATE eta5;

  RingPipeInstance : ENTITY work.RingPipe2
  PORT MAP(
    clk      => clk ,
    RingsIn  => HtRings72x1InEta ,
    RingPipe => ringPipeOut
  );

END ARCHITECTURE behavioral;
