
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

PACKAGE ring_types IS

-- If ISE or VIVADO actually supported VHDL-2008 , then I would USE unconstrained records here , as it is
-- STD_LOGIC_VECTORs are simply "big enough"

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

  TYPE tRingSegment IS RECORD
    Energy      : UNSIGNED( 22 DOWNTO 0 );
    Ecal        : UNSIGNED( 22 DOWNTO 0 );
    xComponent  : SIGNED( 31 DOWNTO 0 );
    yComponent  : SIGNED( 31 DOWNTO 0 );
    towerCount  : UNSIGNED( 11 DOWNTO 0 );
    towerCount2 : UNSIGNED( 11 DOWNTO 0 );
    DataValid   : BOOLEAN;
  END RECORD;

  TYPE tRingSegmentInPhi    IS ARRAY( 0 TO cTowerInPhi-1 ) OF tRingSegment ; -- Towers in phi
  TYPE tRingSegmentInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tRingSegmentInPhi ; -- Two halves in eta
  TYPE tRingSegmentPipe     IS ARRAY( NATURAL RANGE <> ) OF tRingSegmentInEtaPhi ; -- Rough length of the pipe , since any unused cells should be synthesized away

  TYPE tRingSegmentInEta    IS ARRAY( 0 TO cRegionInEta-1 ) OF tRingSegment ; -- Two halves in eta
  TYPE tRingSegmentPipe2    IS ARRAY( NATURAL RANGE <> ) OF tRingSegmentInEta ; -- Rough length of the pipe , since any unused cells should be synthesized away

  CONSTANT cEmptyRingSegment         : tRingSegment         := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , FALSE );
  CONSTANT cEmptyRingSegmentInPhi    : tRingSegmentInPhi    := ( OTHERS   => cEmptyRingSegment );
  CONSTANT cEmptyRingSegmentInEta    : tRingSegmentInEta    := ( OTHERS   => cEmptyRingSegment );
  CONSTANT cEmptyRingSegmentInEtaPhi : tRingSegmentInEtaPhi := ( OTHERS   => cEmptyRingSegmentInPhi );
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------
  TYPE tPileupEstimation IS RECORD
    CompressedEta2  : UNSIGNED( 1 DOWNTO 0 );
    CompressedEta4a : UNSIGNED( 3 DOWNTO 0 );
    CompressedEta4j : UNSIGNED( 3 DOWNTO 0 );
    towerCount      : UNSIGNED( 4 DOWNTO 0 );
    DataValid       : BOOLEAN ; -- Indicate that incoming data is valid
  END RECORD tPileupEstimation;

  TYPE tPileupEstimationInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF tPileupEstimation;
  TYPE tPileupEstimationInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tPileupEstimationInPhi;
  TYPE tPileupEstimationPipe     IS ARRAY( NATURAL RANGE <> ) OF tPileupEstimationInEtaPhi;

  TYPE tPileupEstimationPipe2    IS ARRAY( NATURAL RANGE <> ) OF tPileupEstimation;

  CONSTANT cEmptyPileupEstimation         : tPileupEstimation         := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , FALSE );
  CONSTANT cEmptyPileupEstimationInPhi    : tPileupEstimationInPhi    := ( OTHERS   => cEmptyPileupEstimation );
  CONSTANT cEmptyPileupEstimationInEtaPhi : tPileupEstimationInEtaPhi := ( OTHERS   => cEmptyPileupEstimationInPhi );
-- -----------------------------------------------------------------------------------------------------------------------------


-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
  TYPE tMHTcoefficients IS RECORD
    CosineCoefficients : SIGNED( 10 DOWNTO 0 );
    SineCoefficients   : SIGNED( 10 DOWNTO 0 );
  END RECORD;

  TYPE tMHTcoefficientInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF tMHTcoefficients ; -- cTowerInPhi / 4 wide
  TYPE tMHTcoefficientInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tMHTcoefficientInPhi ; -- Two halves in eta
  TYPE tMHTcoefficientPipe     IS ARRAY( NATURAL RANGE <> ) OF tMHTcoefficientInEtaPhi ; -- Rough length of the pipe , since any unused cells should be synthesized away

  CONSTANT cEmptyMHTcoefficients        : tMHTcoefficients        := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) );
  CONSTANT cEmptyMHTcoefficientInPhi    : tMHTcoefficientInPhi    := ( OTHERS   => cEmptyMHTcoefficients );
  CONSTANT cEmptyMHTcoefficientInEtaPhi : tMHTcoefficientInEtaPhi := ( OTHERS   => cEmptyMHTcoefficientInPhi );

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

  TYPE tPolarRingSegment IS RECORD
    ScalarMagnitude : UNSIGNED( 16 DOWNTO 0 );
    EcalMagnitude   : UNSIGNED( 16 DOWNTO 0 );
    VectorPhi       : UNSIGNED( 11 DOWNTO 0 );
    VectorMagnitude : UNSIGNED( 31 DOWNTO 0 );
    DataValid       : BOOLEAN;
  END RECORD;

  TYPE tPolarRingSegmentPipe IS ARRAY( NATURAL RANGE <> ) OF tPolarRingSegment ; -- Rough length of the pipe , since any unused cells should be synthesized away

  CONSTANT cEmptyPolarRingSegment : tPolarRingSegment := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , FALSE );

END PACKAGE ring_types;
