
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
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;

PACKAGE cluster_types IS

-- -----------------------------------------------------------------------------------------------------------------------------
  TYPE tLateralPosition IS( Undefined , West , Centre , East );
  TYPE tEncodeLateralPosition IS ARRAY( tLateralPosition ) OF STD_LOGIC_VECTOR( 1 DOWNTO 0 );
  CONSTANT encodeLateralPosition : tEncodeLateralPosition := ( Undefined => "00" , West => "01" , Centre => "10" , East => "11" );

  TYPE tVerticalPosition IS( Undefined , North , Centre , South );
  TYPE tEncodeVerticalPosition IS ARRAY( tVerticalPosition ) OF STD_LOGIC_VECTOR( 1 DOWNTO 0 );
  CONSTANT encodeVerticalPosition : tEncodeVerticalPosition := ( Undefined => "00" , North => "01" , Centre => "10" , South => "11" );


  TYPE tCluster IS RECORD
    Energy           : UNSIGNED( 12 DOWNTO 0 );

    Phi              : INTEGER RANGE 0 TO cTowerInPhi;
    Eta              : INTEGER RANGE 0 TO cTowersInHalfEta;
    EtaHalf          : INTEGER RANGE 0 TO 1;
    LateralPosition  : tLateralPosition;
    VerticalPosition : tVerticalPosition;

    EgammaCandidate  : BOOLEAN;
    HasEM            : BOOLEAN;
    HasSeed          : BOOLEAN;

    Isolated         : BOOLEAN;
    Isolated2        : BOOLEAN;

    NoSecondary      : BOOLEAN;
    TauSite          : INTEGER RANGE 0 TO 7;
    TrimmingFlags    : STD_LOGIC_VECTOR( 6 DOWNTO 0 );
    ShapeFlags       : STD_LOGIC_VECTOR( 3 DOWNTO 0 );

    DataValid        : BOOLEAN ; -- Indicate that incoming data is valid
  END RECORD tCluster;

  TYPE tClusterInPhi    IS ARRAY( NATURAL RANGE <> ) OF tCluster;
  TYPE tClusterInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tClusterInPhi( 0 TO cTowerInPhi-1 );
  TYPE tClusterPipe     IS ARRAY( NATURAL RANGE <> ) OF tClusterInEtaPhi;

  CONSTANT cEmptyCluster         : tCluster         := ( ( OTHERS => '0' ) , 0 , 0 , 0 , Undefined , Undefined , FALSE , FALSE , FALSE , FALSE , FALSE , FALSE , 0 , ( OTHERS => '0' ) , ( OTHERS => '0' ) , FALSE );
-- CONSTANT cEmptyClusterInPhi : tClusterInPhi := ( OTHERS => cEmptyCluster );
  CONSTANT cEmptyClusterInEtaPhi : tClusterInEtaPhi := ( OTHERS   => ( OTHERS => cEmptyCluster ) );
-- -----------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------
  TYPE tIsolationRegion IS RECORD
    Energy    : UNSIGNED( 15 DOWNTO 0 );
    DataValid : BOOLEAN ; -- Indicate that incoming data is valid
  END RECORD tIsolationRegion;

  TYPE tIsolationRegionInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF tIsolationRegion;
  TYPE tIsolationRegionInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tIsolationRegionInPhi;
  TYPE tIsolationRegionPipe     IS ARRAY( NATURAL RANGE <> ) OF tIsolationRegionInEtaPhi;

  CONSTANT cEmptyIsolationRegion         : tIsolationRegion         := ( ( OTHERS => '0' ) , FALSE );
  CONSTANT cEmptyIsolationRegionInPhi    : tIsolationRegionInPhi    := ( OTHERS   => cEmptyIsolationRegion );
  CONSTANT cEmptyIsolationRegionInEtaPhi : tIsolationRegionInEtaPhi := ( OTHERS   => cEmptyIsolationRegionInPhi );
-- -----------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------
  TYPE tGtFormattedCluster IS RECORD
    Energy    : UNSIGNED( 8 DOWNTO 0 );
    Phi       : UNSIGNED( 7 DOWNTO 0 );
    Eta       : SIGNED( 7 DOWNTO 0 );
    Isolated2 : BOOLEAN;
    Isolated  : BOOLEAN;
    DataValid : BOOLEAN;
  END RECORD;

  TYPE tGtFormattedClusters    IS ARRAY( 11 DOWNTO 0 ) OF tGtFormattedCluster;
  TYPE tGtFormattedClusterPipe IS ARRAY( NATURAL RANGE <> ) OF tGtFormattedClusters ; -- Rough length of the pipe , since any unused cells should be synthesized away

  CONSTANT cEmptyGtFormattedCluster  : tGtFormattedCluster  := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , FALSE , FALSE , FALSE );
  CONSTANT cEmptyGtFormattedClusters : tGtFormattedClusters := ( OTHERS   => cEmptyGtFormattedCluster );
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------
  TYPE tClusterInput IS RECORD
    Centre : tTower ; -- Central seed of cluster

    R1N    : tTower ; -- North of Tower
    R1NW   : tTower ; -- North West of Tower
    R1W    : tTower ; -- West Tower of Tower
    R1SW   : tTower ; -- South West of Tower
    R1S    : tTower ; -- South of Tower
    R1SE   : tTower ; -- South East of Tower
    R1E    : tTower ; -- East Tower of Tower
    R1NE   : tTower ; -- North East of Tower

    R2N    : tTower ; -- North of second ring of Tower
    R2S    : tTower ; -- South of second ring of cluster

    R2NW   : tTower ; -- North of second ring of Tower
    R2NE   : tTower ; -- North of second ring of Tower
    R2SW   : tTower ; -- South of second ring of cluster
    R2SE   : tTower ; -- South of second ring of cluster

  END RECORD tClusterInput;

  TYPE tClusterInputInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF tClusterInput ; -- Two halves in eta
  TYPE tClusterInputInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tClusterInputInPhi ; -- Two halves in eta
  TYPE tClusterInputPipe     IS ARRAY( NATURAL RANGE <> ) OF tClusterInputInEtaPhi;

  CONSTANT cEmptyClusterInput         : tClusterInput         := ( OTHERS => cEmptyTower );
  CONSTANT cEmptyClusterInputInPhi    : tClusterInputInPhi    := ( OTHERS => cEmptyClusterInput );
  CONSTANT cEmptyClusterInputInEtaPhi : tClusterInputInEtaPhi := ( OTHERS => cEmptyClusterInputInPhi );
-- -----------------------------------------------------------------------------------------------------------------------------

END PACKAGE cluster_types;
