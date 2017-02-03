
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

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;
--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! Using the Calo-L2 "helper" helper functions
USE work.helper_functions.ALL;
--! Using the Calo-L2 "cluster" helper functions
USE work.cluster_functions.ALL;

--! Using the Calo-L2 "Tower" testbench suite
USE work.TowerReference.ALL;
--! Using the Calo-L2 "Jet" testbench suite
USE work.JetReference.ALL;
--! Using the Calo-L2 "Ringsum" testbench suite
USE work.RingsumReference.ALL;

--! Writing to and from files
USE IEEE.STD_LOGIC_TEXTIO.ALL;
--! Writing to and from files
USE STD.TEXTIO.ALL;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
PACKAGE ClusterReference IS

  CONSTANT latency_tau3x3Veto            : INTEGER := latency_towerFormer + 7;
  CONSTANT latency_egamma9x3Veto         : INTEGER := latency_towerFormer + 10;
  CONSTANT latency_TowerThresholds       : INTEGER := latency_towerFormer + 1;
  CONSTANT latency_ProtoClusters         : INTEGER := latency_TowerThresholds + 4 + 2 ; -- Manual offset
  CONSTANT latency_FilteredProtoClusters : INTEGER := latency_egamma9x3Veto + 1;
  CONSTANT latency_ClusterInput          : INTEGER := latency_egamma9x3Veto + 1 + 2;
  CONSTANT latency_Isolation9x6          : INTEGER := latency_egamma9x3Veto + 2 + 4;


  FILE tau3x3VetoFile                    : TEXT OPEN write_mode IS "IntermediateSteps/Tau3x3VetoPipe.txt";
  FILE egamma9x3VetoFile                 : TEXT OPEN write_mode IS "IntermediateSteps/Egamma9x3VetoPipe.txt";
  FILE ProtoClusterFile                  : TEXT OPEN write_mode IS "IntermediateSteps/ProtoClusterPipe.txt";
  FILE FilteredProtoClusterFile          : TEXT OPEN write_mode IS "IntermediateSteps/FilteredProtoClusterPipe.txt";
  FILE Isolation9x6File                  : TEXT OPEN write_mode IS "IntermediateSteps/Isolation9x6Pipe.txt";



  PROCEDURE ClusterReference
  (
    VARIABLE reference_Towers                : IN tTowerPipe;
    VARIABLE reference_3x3Veto               : INOUT tComparisonPipe;
    VARIABLE reference_9x3Veto               : INOUT tComparisonPipe;
    VARIABLE reference_TowerThresholds       : INOUT tTowerFlagsPipe;
    VARIABLE reference_ProtoClusters         : INOUT tClusterPipe;
    VARIABLE reference_FilteredProtoClusters : INOUT tClusterPipe;
    VARIABLE reference_ClusterInput          : INOUT tClusterInputPipe;
    VARIABLE reference_Isolation9x6          : INOUT tIsolationRegionPipe
  );


  PROCEDURE ClusterChecker
  (
    VARIABLE clk_count                       : IN INTEGER;
    CONSTANT timeout                         : IN INTEGER;
-- -------------
    VARIABLE reference_3x3Veto               : IN tComparisonPipe;
    SIGNAL tau3x3VetoPipe                    : IN tComparisonPipe;
    VARIABLE retval3x3Veto                   : INOUT tRetVal;
-- -------------
    VARIABLE reference_9x3Veto               : IN tComparisonPipe;
    SIGNAL egamma9x3VetoPipe                 : IN tComparisonPipe;
    VARIABLE retval9x3Veto                   : INOUT tRetVal;
-------------
    VARIABLE reference_TowerThresholds       : IN tTowerFlagsPipe;
    SIGNAL ClusterTowerPipe                  : IN tTowerFlagsPipe;
    VARIABLE retvalTowerThresholds           : INOUT tRetVal;
-- -------------
    VARIABLE reference_ProtoClusters         : IN tClusterPipe;
    SIGNAL ProtoClusterPipe                  : IN tClusterPipe;
    VARIABLE retvalProtoClusters             : INOUT tRetVal;
-- -------------
    VARIABLE reference_FilteredProtoClusters : IN tClusterPipe;
    SIGNAL FilteredProtoClusterPipe          : IN tClusterPipe;
    VARIABLE retvalFilteredProtoClusters     : INOUT tRetVal;
-- -------------
    VARIABLE reference_ClusterInput          : IN tClusterInputPipe;
    SIGNAL ClusterInputPipe                  : IN tClusterInputPipe;
    VARIABLE retvalClusterInput              : INOUT tRetVal;
-- -------------
    VARIABLE reference_Isolation9x6          : IN tIsolationRegionPipe;
    SIGNAL Isolation9x6Pipe                  : IN tIsolationRegionPipe;
    VARIABLE retvalIsolation9x6              : INOUT tRetVal;
-- -------------
    CONSTANT debug                           : IN BOOLEAN := false
-- -------------
  );



  PROCEDURE ClusterDebug
  (
-- -------------
    VARIABLE clk_count              : IN INTEGER;
-- -------------
    SIGNAL tau3x3VetoPipe           : IN tComparisonPipe;
    SIGNAL egamma9x3VetoPipe        : IN tComparisonPipe;
-- SIGNAL ClusterTowerPipe : IN tTowerFlagsPipe;
    SIGNAL ProtoClusterPipe         : IN tClusterPipe;
    SIGNAL FilteredProtoClusterPipe : IN tClusterPipe;
    SIGNAL Isolation9x6Pipe         : IN tIsolationRegionPipe;
-- SIGNAL ClusterInputPipe : IN tClusterInputPipe;
-- -------------
    CONSTANT debug                  : IN BOOLEAN := false
-- -------------
  );



  PROCEDURE ClusterReport
  (
    VARIABLE retval3x3Veto               : IN tRetVal;
    VARIABLE retval9x3Veto               : IN tRetVal;
    VARIABLE retvalTowerThresholds       : IN tRetVal;
    VARIABLE retvalProtoClusters         : IN tRetVal;
    VARIABLE retvalFilteredProtoClusters : IN tRetVal;
    VARIABLE retvalClusterInput          : IN tRetVal;
    VARIABLE retvalIsolation9x6          : IN tRetVal
  );

  IMPURE FUNCTION EGAMMA_OVERLAP_VETO( EtaCentre : INTEGER ; PhiCentre : INTEGER ; Towers : tTowerPipe ) RETURN BOOLEAN;
  IMPURE FUNCTION TAU_OVERLAP_VETO( EtaCentre    : INTEGER ; PhiCentre : INTEGER ; Towers : tTowerPipe ) RETURN BOOLEAN;

  FUNCTION GetTower( Eta                         : INTEGER ; Phi : INTEGER ; TowerThresholds : tTowerFlagsPipe ) RETURN tTowerFlags;
  FUNCTION GetVeto( Eta                          : INTEGER ; Phi : INTEGER ; Vetos : tComparisonPipe ) RETURN tComparison;
  FUNCTION GetCluster( Eta                       : INTEGER ; Phi : INTEGER ; Cluster : tClusterPipe ) RETURN tCluster;

  FUNCTION PROTOCLUSTERS( Eta                    : INTEGER ; Phi : INTEGER ; Towers : tTowerPipe ; TowerThresholds : tTowerFlagsPipe ) RETURN tCluster;
  FUNCTION CLUSTER( ClusterInput                 : tClusterInput ; ProtoCluster : tCluster ) RETURN tCluster;

  PROCEDURE CLUSTER_BITONIC_SORT( VARIABLE a     : INOUT tClusterInPhi( 0 TO( cTowerInPhi / 4 ) -1 ) ; lo , n : IN INTEGER ; dir : IN BOOLEAN );
  PROCEDURE CLUSTER_BITONIC_MERGE( VARIABLE a    : INOUT tClusterInPhi( 0 TO( cTowerInPhi / 4 ) -1 ) ; lo , n : IN INTEGER ; dir : IN BOOLEAN );

  PROCEDURE OutputCandidate( VARIABLE clk        : IN INTEGER ; CONSTANT latency : IN INTEGER ; SIGNAL data : IN tClusterInEtaPhi ; FILE f : TEXT );
  PROCEDURE OutputCandidate( VARIABLE clk        : IN INTEGER ; CONSTANT latency : IN INTEGER ; SIGNAL data : IN tIsolationRegionInEtaPhi ; FILE f : TEXT );
  PROCEDURE OutputCandidate( VARIABLE clk        : IN INTEGER ; CONSTANT latency : IN INTEGER ; SIGNAL data : IN tPileupEstimationInEtaPhi ; FILE f : TEXT );

END PACKAGE ClusterReference;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------



-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
PACKAGE BODY ClusterReference IS

  PROCEDURE ClusterReference
  (
    VARIABLE reference_Towers                : IN tTowerPipe;
    VARIABLE reference_3x3Veto               : INOUT tComparisonPipe;
    VARIABLE reference_9x3Veto               : INOUT tComparisonPipe;
    VARIABLE reference_TowerThresholds       : INOUT tTowerFlagsPipe;
    VARIABLE reference_ProtoClusters         : INOUT tClusterPipe;
    VARIABLE reference_FilteredProtoClusters : INOUT tClusterPipe;
    VARIABLE reference_ClusterInput          : INOUT tClusterInputPipe;
    VARIABLE reference_Isolation9x6          : INOUT tIsolationRegionPipe
  ) IS
  BEGIN

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO cTowerInPhi-1 LOOP
      FOR eta IN 0 TO( reference_3x3Veto'LENGTH - 1 ) LOOP
        reference_3x3Veto( eta )( 0 )( phi ) .Data      := TAU_OVERLAP_VETO( eta , phi , reference_Towers );
        reference_3x3Veto( eta )( 1 )( phi ) .Data      := TAU_OVERLAP_VETO( -eta-1 , phi , reference_Towers );
        reference_3x3Veto( eta )( 0 )( phi ) .DataValid := TRUE;
        reference_3x3Veto( eta )( 1 )( phi ) .DataValid := TRUE;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO cTowerInPhi-1 LOOP
      FOR eta IN 0 TO( reference_9x3Veto'LENGTH - 1 ) LOOP
        reference_9x3Veto( eta )( 0 )( phi ) .Data      := EGAMMA_OVERLAP_VETO( eta , phi , reference_Towers );
        reference_9x3Veto( eta )( 1 )( phi ) .Data      := EGAMMA_OVERLAP_VETO( -eta-1 , phi , reference_Towers );
        reference_9x3Veto( eta )( 0 )( phi ) .DataValid := TRUE;
        reference_9x3Veto( eta )( 1 )( phi ) .DataValid := TRUE;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO cTowerInPhi-1 LOOP
      FOR eta_half IN 0 TO cRegionInEta-1 LOOP
        FOR eta IN 0 TO( reference_TowerThresholds'LENGTH - 1 ) LOOP
          reference_TowerThresholds( eta )( eta_half )( phi ) .JetSeedThreshold     := ( reference_Towers( eta )( eta_half )( phi ) .Energy >= "00001000" );
          reference_TowerThresholds( eta )( eta_half )( phi ) .ClusterSeedThreshold := ( reference_Towers( eta )( eta_half )( phi ) .Energy >= "00000100" );
          reference_TowerThresholds( eta )( eta_half )( phi ) .ClusterThreshold     := ( reference_Towers( eta )( eta_half )( phi ) .Energy >= "00000010" );
          reference_TowerThresholds( eta )( eta_half )( phi ) .PileUpThreshold      := ( reference_Towers( eta )( eta_half )( phi ) .Energy > "00000000" );
          reference_TowerThresholds( eta )( eta_half )( phi ) .DataValid            := TRUE;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO cTowerInPhi-1 LOOP
      FOR eta IN 0 TO( reference_ProtoClusters'LENGTH - 1 ) LOOP
        reference_ProtoClusters( eta )( 0 )( phi ) := PROTOCLUSTERS( eta , phi , reference_Towers , reference_TowerThresholds );
        reference_ProtoClusters( eta )( 1 )( phi ) := PROTOCLUSTERS( ( -eta-1 ) , phi , reference_Towers , reference_TowerThresholds );
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta_half IN 0 TO cRegionInEta-1 LOOP
        FOR eta IN 0 TO( reference_FilteredProtoClusters'LENGTH - 1 ) LOOP

          IF( NOT reference_9x3Veto( eta )( eta_half )( ( 4 * phi ) + 0 ) .Data ) THEN
            reference_FilteredProtoClusters( eta )( eta_half )( phi )      := reference_ProtoClusters( eta )( eta_half )( MOD_PHI( ( 4 * phi ) + 0 ) );
            reference_FilteredProtoClusters( eta )( eta_half )( phi ) .eta := eta + cCMScoordinateOffset;
            reference_FilteredProtoClusters( eta )( eta_half )( phi ) .phi := MOD_PHI( ( 4 * phi ) + 0 ) + cCMScoordinateOffset;
          ELSIF( NOT reference_9x3Veto( eta )( eta_half )( ( 4 * phi ) + 1 ) .Data ) THEN
            reference_FilteredProtoClusters( eta )( eta_half )( phi )      := reference_ProtoClusters( eta )( eta_half )( MOD_PHI( ( 4 * phi ) + 1 ) );
            reference_FilteredProtoClusters( eta )( eta_half )( phi ) .eta := eta + cCMScoordinateOffset;
            reference_FilteredProtoClusters( eta )( eta_half )( phi ) .phi := MOD_PHI( ( 4 * phi ) + 1 ) + cCMScoordinateOffset;
          ELSIF( NOT reference_9x3Veto( eta )( eta_half )( ( 4 * phi ) + 2 ) .Data ) THEN
            reference_FilteredProtoClusters( eta )( eta_half )( phi )      := reference_ProtoClusters( eta )( eta_half )( MOD_PHI( ( 4 * phi ) + 2 ) );
            reference_FilteredProtoClusters( eta )( eta_half )( phi ) .eta := eta + cCMScoordinateOffset;
            reference_FilteredProtoClusters( eta )( eta_half )( phi ) .phi := MOD_PHI( ( 4 * phi ) + 2 ) + cCMScoordinateOffset;
          ELSIF( NOT reference_9x3Veto( eta )( eta_half )( ( 4 * phi ) + 3 ) .Data ) THEN
            reference_FilteredProtoClusters( eta )( eta_half )( phi )      := reference_ProtoClusters( eta )( eta_half )( MOD_PHI( ( 4 * phi ) + 3 ) );
            reference_FilteredProtoClusters( eta )( eta_half )( phi ) .eta := eta + cCMScoordinateOffset;
            reference_FilteredProtoClusters( eta )( eta_half )( phi ) .phi := MOD_PHI( ( 4 * phi ) + 3 ) + cCMScoordinateOffset;
          ELSE
            reference_FilteredProtoClusters( eta )( eta_half )( phi ) .eta       := eta + cCMScoordinateOffset;
            reference_FilteredProtoClusters( eta )( eta_half )( phi ) .DataValid := True;
          END IF;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta IN 0 TO( reference_ClusterInput'LENGTH - 1 ) LOOP

            IF( NOT reference_9x3Veto( eta )( 0 )( ( 4 * phi ) + 0 ) .Data ) THEN
            reference_ClusterInput( eta )( 0 )( phi ) .Centre := GetTower( eta + 0 , ( 4 * phi ) + 0 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1NW   := GetTower( eta - 1 , ( 4 * phi ) + 1 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1N    := GetTower( eta + 0 , ( 4 * phi ) + 1 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1NE   := GetTower( eta + 1 , ( 4 * phi ) + 1 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1E    := GetTower( eta + 1 , ( 4 * phi ) + 0 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1SE   := GetTower( eta + 1 , ( 4 * phi ) - 1 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1S    := GetTower( eta + 0 , ( 4 * phi ) - 1 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1SW   := GetTower( eta - 1 , ( 4 * phi ) - 1 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1W    := GetTower( eta - 1 , ( 4 * phi ) + 0 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2N    := GetTower( eta + 0 , ( 4 * phi ) + 2 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2S    := GetTower( eta + 0 , ( 4 * phi ) - 2 + 0 , reference_Towers );

            reference_ClusterInput( eta )( 0 )( phi ) .R2NW   := GetTower( eta - 1 , ( 4 * phi ) + 2 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2NE   := GetTower( eta + 1 , ( 4 * phi ) + 2 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2SW   := GetTower( eta - 1 , ( 4 * phi ) - 2 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2SE   := GetTower( eta + 1 , ( 4 * phi ) - 2 + 0 , reference_Towers );

        ELSIF( NOT reference_9x3Veto( eta )( 0 )( ( 4 * phi ) + 1 ) .Data ) THEN
            reference_ClusterInput( eta )( 0 )( phi ) .Centre := GetTower( eta + 0 , ( 4 * phi ) + 0 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1NW   := GetTower( eta - 1 , ( 4 * phi ) + 1 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1N    := GetTower( eta + 0 , ( 4 * phi ) + 1 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1NE   := GetTower( eta + 1 , ( 4 * phi ) + 1 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1E    := GetTower( eta + 1 , ( 4 * phi ) + 0 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1SE   := GetTower( eta + 1 , ( 4 * phi ) - 1 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1S    := GetTower( eta + 0 , ( 4 * phi ) - 1 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1SW   := GetTower( eta - 1 , ( 4 * phi ) - 1 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1W    := GetTower( eta - 1 , ( 4 * phi ) + 0 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2N    := GetTower( eta + 0 , ( 4 * phi ) + 2 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2S    := GetTower( eta + 0 , ( 4 * phi ) - 2 + 1 , reference_Towers );

            reference_ClusterInput( eta )( 0 )( phi ) .R2NW   := GetTower( eta - 1 , ( 4 * phi ) + 2 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2NE   := GetTower( eta + 1 , ( 4 * phi ) + 2 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2SW   := GetTower( eta - 1 , ( 4 * phi ) - 2 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2SE   := GetTower( eta + 1 , ( 4 * phi ) - 2 + 1 , reference_Towers );

        ELSIF( NOT reference_9x3Veto( eta )( 0 )( ( 4 * phi ) + 2 ) .Data ) THEN
            reference_ClusterInput( eta )( 0 )( phi ) .Centre := GetTower( eta + 0 , ( 4 * phi ) + 0 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1NW   := GetTower( eta - 1 , ( 4 * phi ) + 1 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1N    := GetTower( eta + 0 , ( 4 * phi ) + 1 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1NE   := GetTower( eta + 1 , ( 4 * phi ) + 1 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1E    := GetTower( eta + 1 , ( 4 * phi ) + 0 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1SE   := GetTower( eta + 1 , ( 4 * phi ) - 1 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1S    := GetTower( eta + 0 , ( 4 * phi ) - 1 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1SW   := GetTower( eta - 1 , ( 4 * phi ) - 1 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1W    := GetTower( eta - 1 , ( 4 * phi ) + 0 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2N    := GetTower( eta + 0 , ( 4 * phi ) + 2 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2S    := GetTower( eta + 0 , ( 4 * phi ) - 2 + 2 , reference_Towers );

            reference_ClusterInput( eta )( 0 )( phi ) .R2NW   := GetTower( eta - 1 , ( 4 * phi ) + 2 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2NE   := GetTower( eta + 1 , ( 4 * phi ) + 2 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2SW   := GetTower( eta - 1 , ( 4 * phi ) - 2 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2SE   := GetTower( eta + 1 , ( 4 * phi ) - 2 + 2 , reference_Towers );

        ELSIF( NOT reference_9x3Veto( eta )( 0 )( ( 4 * phi ) + 3 ) .Data ) THEN
            reference_ClusterInput( eta )( 0 )( phi ) .Centre := GetTower( eta + 0 , ( 4 * phi ) + 0 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1NW   := GetTower( eta - 1 , ( 4 * phi ) + 1 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1N    := GetTower( eta + 0 , ( 4 * phi ) + 1 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1NE   := GetTower( eta + 1 , ( 4 * phi ) + 1 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1E    := GetTower( eta + 1 , ( 4 * phi ) + 0 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1SE   := GetTower( eta + 1 , ( 4 * phi ) - 1 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1S    := GetTower( eta + 0 , ( 4 * phi ) - 1 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1SW   := GetTower( eta - 1 , ( 4 * phi ) - 1 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R1W    := GetTower( eta - 1 , ( 4 * phi ) + 0 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2N    := GetTower( eta + 0 , ( 4 * phi ) + 2 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2S    := GetTower( eta + 0 , ( 4 * phi ) - 2 + 3 , reference_Towers );

            reference_ClusterInput( eta )( 0 )( phi ) .R2NW   := GetTower( eta - 1 , ( 4 * phi ) + 2 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2NE   := GetTower( eta + 1 , ( 4 * phi ) + 2 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2SW   := GetTower( eta - 1 , ( 4 * phi ) - 2 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 0 )( phi ) .R2SE   := GetTower( eta + 1 , ( 4 * phi ) - 2 + 3 , reference_Towers );

        ELSE
            reference_ClusterInput( eta )( 0 )( phi )                   := cEmptyClusterInput;
            reference_ClusterInput( eta )( 0 )( phi ) .Centre.DataValid := TRUE;
            reference_ClusterInput( eta )( 0 )( phi ) .R1NW.DataValid   := TRUE;
            reference_ClusterInput( eta )( 0 )( phi ) .R1N.DataValid    := TRUE;
            reference_ClusterInput( eta )( 0 )( phi ) .R1NE.DataValid   := TRUE;
            reference_ClusterInput( eta )( 0 )( phi ) .R1E.DataValid    := TRUE;
            reference_ClusterInput( eta )( 0 )( phi ) .R1SE.DataValid   := TRUE;
            reference_ClusterInput( eta )( 0 )( phi ) .R1S.DataValid    := TRUE;
            reference_ClusterInput( eta )( 0 )( phi ) .R1SW.DataValid   := TRUE;
            reference_ClusterInput( eta )( 0 )( phi ) .R1W.DataValid    := TRUE;
            reference_ClusterInput( eta )( 0 )( phi ) .R2N.DataValid    := TRUE;
            reference_ClusterInput( eta )( 0 )( phi ) .R2S.DataValid    := TRUE;

            reference_ClusterInput( eta )( 0 )( phi ) .R2NW.DataValid   := TRUE;
            reference_ClusterInput( eta )( 0 )( phi ) .R2NE.DataValid   := TRUE;
            reference_ClusterInput( eta )( 0 )( phi ) .R2SW.DataValid   := TRUE;
            reference_ClusterInput( eta )( 0 )( phi ) .R2SE.DataValid   := TRUE;

        END IF;

            IF( NOT reference_9x3Veto( eta )( 1 )( ( 4 * phi ) + 0 ) .Data ) THEN
            reference_ClusterInput( eta )( 1 )( phi ) .Centre := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) + 0 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1NW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) + 1 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1N    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) + 1 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1NE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) + 1 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1E    := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) + 0 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1SE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) - 1 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1S    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) - 1 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1SW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) - 1 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1W    := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) + 0 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2N    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) + 2 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2S    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) - 2 + 0 , reference_Towers );

            reference_ClusterInput( eta )( 1 )( phi ) .R2NW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) + 2 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2NE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) + 2 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2SW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) - 2 + 0 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2SE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) - 2 + 0 , reference_Towers );

        ELSIF( NOT reference_9x3Veto( eta )( 1 )( ( 4 * phi ) + 1 ) .Data ) THEN
            reference_ClusterInput( eta )( 1 )( phi ) .Centre := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) + 0 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1NW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) + 1 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1N    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) + 1 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1NE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) + 1 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1E    := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) + 0 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1SE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) - 1 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1S    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) - 1 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1SW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) - 1 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1W    := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) + 0 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2N    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) + 2 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2S    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) - 2 + 1 , reference_Towers );

            reference_ClusterInput( eta )( 1 )( phi ) .R2NW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) + 2 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2NE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) + 2 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2SW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) - 2 + 1 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2SE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) - 2 + 1 , reference_Towers );

        ELSIF( NOT reference_9x3Veto( eta )( 1 )( ( 4 * phi ) + 2 ) .Data ) THEN
            reference_ClusterInput( eta )( 1 )( phi ) .Centre := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) + 0 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1NW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) + 1 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1N    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) + 1 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1NE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) + 1 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1E    := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) + 0 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1SE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) - 1 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1S    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) - 1 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1SW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) - 1 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1W    := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) + 0 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2N    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) + 2 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2S    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) - 2 + 2 , reference_Towers );

            reference_ClusterInput( eta )( 1 )( phi ) .R2NW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) + 2 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2NE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) + 2 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2SW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) - 2 + 2 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2SE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) - 2 + 2 , reference_Towers );

        ELSIF( NOT reference_9x3Veto( eta )( 1 )( ( 4 * phi ) + 3 ) .Data ) THEN
            reference_ClusterInput( eta )( 1 )( phi ) .Centre := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) + 0 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1NW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) + 1 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1N    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) + 1 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1NE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) + 1 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1E    := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) + 0 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1SE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) - 1 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1S    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) - 1 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1SW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) - 1 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R1W    := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) + 0 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2N    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) + 2 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2S    := GetTower( ( -eta-1 ) + 0 , ( 4 * phi ) - 2 + 3 , reference_Towers );

            reference_ClusterInput( eta )( 1 )( phi ) .R2NW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) + 2 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2NE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) + 2 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2SW   := GetTower( ( -eta-1 ) - 1 , ( 4 * phi ) - 2 + 3 , reference_Towers );
            reference_ClusterInput( eta )( 1 )( phi ) .R2SE   := GetTower( ( -eta-1 ) + 1 , ( 4 * phi ) - 2 + 3 , reference_Towers );

        ELSE
            reference_ClusterInput( eta )( 1 )( phi )                   := cEmptyClusterInput;
            reference_ClusterInput( eta )( 1 )( phi ) .Centre.DataValid := TRUE;
            reference_ClusterInput( eta )( 1 )( phi ) .R1NW.DataValid   := TRUE;
            reference_ClusterInput( eta )( 1 )( phi ) .R1N.DataValid    := TRUE;
            reference_ClusterInput( eta )( 1 )( phi ) .R1NE.DataValid   := TRUE;
            reference_ClusterInput( eta )( 1 )( phi ) .R1E.DataValid    := TRUE;
            reference_ClusterInput( eta )( 1 )( phi ) .R1SE.DataValid   := TRUE;
            reference_ClusterInput( eta )( 1 )( phi ) .R1S.DataValid    := TRUE;
            reference_ClusterInput( eta )( 1 )( phi ) .R1SW.DataValid   := TRUE;
            reference_ClusterInput( eta )( 1 )( phi ) .R1W.DataValid    := TRUE;
            reference_ClusterInput( eta )( 1 )( phi ) .R2N.DataValid    := TRUE;
            reference_ClusterInput( eta )( 1 )( phi ) .R2S.DataValid    := TRUE;

            reference_ClusterInput( eta )( 1 )( phi ) .R2NW.DataValid   := TRUE;
            reference_ClusterInput( eta )( 1 )( phi ) .R2NE.DataValid   := TRUE;
            reference_ClusterInput( eta )( 1 )( phi ) .R2SW.DataValid   := TRUE;
            reference_ClusterInput( eta )( 1 )( phi ) .R2SE.DataValid   := TRUE;

        END IF;

    END LOOP;
  END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta IN 0 TO( reference_Isolation9x6'LENGTH - 1 ) LOOP
        FOR delta_eta IN -2 TO 3 LOOP
          FOR delta_phi IN -4 TO 4 LOOP

            IF reference_FilteredProtoClusters( eta )( 0 )( phi ) .LateralPosition = west THEN
                 IF( NOT reference_9x3Veto( eta )( 0 )( ( 4 * phi ) + 0 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 0 )( phi ) .Energy := reference_Isolation9x6( eta )( 0 )( phi ) .Energy + GetTower( eta + delta_eta - 1 , ( 4 * phi ) + delta_phi + 0 , reference_towers ) .Energy;
              ELSIF( NOT reference_9x3Veto( eta )( 0 )( ( 4 * phi ) + 1 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 0 )( phi ) .Energy := reference_Isolation9x6( eta )( 0 )( phi ) .Energy + GetTower( eta + delta_eta - 1 , ( 4 * phi ) + delta_phi + 1 , reference_towers ) .Energy;
              ELSIF( NOT reference_9x3Veto( eta )( 0 )( ( 4 * phi ) + 2 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 0 )( phi ) .Energy := reference_Isolation9x6( eta )( 0 )( phi ) .Energy + GetTower( eta + delta_eta - 1 , ( 4 * phi ) + delta_phi + 2 , reference_towers ) .Energy;
              ELSIF( NOT reference_9x3Veto( eta )( 0 )( ( 4 * phi ) + 3 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 0 )( phi ) .Energy := reference_Isolation9x6( eta )( 0 )( phi ) .Energy + GetTower( eta + delta_eta - 1 , ( 4 * phi ) + delta_phi + 3 , reference_towers ) .Energy;
              END IF;
            ELSE
                 IF( NOT reference_9x3Veto( eta )( 0 )( ( 4 * phi ) + 0 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 0 )( phi ) .Energy := reference_Isolation9x6( eta )( 0 )( phi ) .Energy + GetTower( eta + delta_eta + 0 , ( 4 * phi ) + delta_phi + 0 , reference_towers ) .Energy;
              ELSIF( NOT reference_9x3Veto( eta )( 0 )( ( 4 * phi ) + 1 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 0 )( phi ) .Energy := reference_Isolation9x6( eta )( 0 )( phi ) .Energy + GetTower( eta + delta_eta + 0 , ( 4 * phi ) + delta_phi + 1 , reference_towers ) .Energy;
              ELSIF( NOT reference_9x3Veto( eta )( 0 )( ( 4 * phi ) + 2 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 0 )( phi ) .Energy := reference_Isolation9x6( eta )( 0 )( phi ) .Energy + GetTower( eta + delta_eta + 0 , ( 4 * phi ) + delta_phi + 2 , reference_towers ) .Energy;
              ELSIF( NOT reference_9x3Veto( eta )( 0 )( ( 4 * phi ) + 3 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 0 )( phi ) .Energy := reference_Isolation9x6( eta )( 0 )( phi ) .Energy + GetTower( eta + delta_eta + 0 , ( 4 * phi ) + delta_phi + 3 , reference_towers ) .Energy;
              END IF;
            END IF;

            reference_Isolation9x6( eta )( 0 )( phi ) .DataValid := TRUE;


            IF reference_FilteredProtoClusters( eta )( 1 )( phi ) .LateralPosition = west THEN
                 IF( NOT reference_9x3Veto( eta )( 1 )( ( 4 * phi ) + 0 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 1 )( phi ) .Energy := reference_Isolation9x6( eta )( 1 )( phi ) .Energy + GetTower( ( -eta-1 ) + delta_eta - 1 , ( 4 * phi ) + delta_phi + 0 , reference_towers ) .Energy;
              ELSIF( NOT reference_9x3Veto( eta )( 1 )( ( 4 * phi ) + 1 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 1 )( phi ) .Energy := reference_Isolation9x6( eta )( 1 )( phi ) .Energy + GetTower( ( -eta-1 ) + delta_eta - 1 , ( 4 * phi ) + delta_phi + 1 , reference_towers ) .Energy;
              ELSIF( NOT reference_9x3Veto( eta )( 1 )( ( 4 * phi ) + 2 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 1 )( phi ) .Energy := reference_Isolation9x6( eta )( 1 )( phi ) .Energy + GetTower( ( -eta-1 ) + delta_eta - 1 , ( 4 * phi ) + delta_phi + 2 , reference_towers ) .Energy;
              ELSIF( NOT reference_9x3Veto( eta )( 1 )( ( 4 * phi ) + 3 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 1 )( phi ) .Energy := reference_Isolation9x6( eta )( 1 )( phi ) .Energy + GetTower( ( -eta-1 ) + delta_eta - 1 , ( 4 * phi ) + delta_phi + 3 , reference_towers ) .Energy;
              END IF;
            ELSE
                 IF( NOT reference_9x3Veto( eta )( 1 )( ( 4 * phi ) + 0 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 1 )( phi ) .Energy := reference_Isolation9x6( eta )( 1 )( phi ) .Energy + GetTower( ( -eta-1 ) + delta_eta + 0 , ( 4 * phi ) + delta_phi + 0 , reference_towers ) .Energy;
              ELSIF( NOT reference_9x3Veto( eta )( 1 )( ( 4 * phi ) + 1 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 1 )( phi ) .Energy := reference_Isolation9x6( eta )( 1 )( phi ) .Energy + GetTower( ( -eta-1 ) + delta_eta + 0 , ( 4 * phi ) + delta_phi + 1 , reference_towers ) .Energy;
              ELSIF( NOT reference_9x3Veto( eta )( 1 )( ( 4 * phi ) + 2 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 1 )( phi ) .Energy := reference_Isolation9x6( eta )( 1 )( phi ) .Energy + GetTower( ( -eta-1 ) + delta_eta + 0 , ( 4 * phi ) + delta_phi + 2 , reference_towers ) .Energy;
              ELSIF( NOT reference_9x3Veto( eta )( 1 )( ( 4 * phi ) + 3 ) .Data ) THEN
                  reference_Isolation9x6( eta )( 1 )( phi ) .Energy := reference_Isolation9x6( eta )( 1 )( phi ) .Energy + GetTower( ( -eta-1 ) + delta_eta + 0 , ( 4 * phi ) + delta_phi + 3 , reference_towers ) .Energy;
              END IF;
            END IF;

            reference_Isolation9x6( eta )( 1 )( phi ) .DataValid := TRUE;

          END LOOP;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------



  END ClusterReference;



  PROCEDURE ClusterChecker
  (
    VARIABLE clk_count                       : IN INTEGER;
    CONSTANT timeout                         : IN INTEGER;
-- -------------
    VARIABLE reference_3x3Veto               : IN tComparisonPipe;
    SIGNAL tau3x3VetoPipe                    : IN tComparisonPipe;
    VARIABLE retval3x3Veto                   : INOUT tRetVal;
-- -------------
    VARIABLE reference_9x3Veto               : IN tComparisonPipe;
    SIGNAL egamma9x3VetoPipe                 : IN tComparisonPipe;
    VARIABLE retval9x3Veto                   : INOUT tRetVal;
-------------
    VARIABLE reference_TowerThresholds       : IN tTowerFlagsPipe;
    SIGNAL ClusterTowerPipe                  : IN tTowerFlagsPipe;
    VARIABLE retvalTowerThresholds           : INOUT tRetVal;
-- -------------
    VARIABLE reference_ProtoClusters         : IN tClusterPipe;
    SIGNAL ProtoClusterPipe                  : IN tClusterPipe;
    VARIABLE retvalProtoClusters             : INOUT tRetVal;
-- -- -------------
    VARIABLE reference_FilteredProtoClusters : IN tClusterPipe;
    SIGNAL FilteredProtoClusterPipe          : IN tClusterPipe;
    VARIABLE retvalFilteredProtoClusters     : INOUT tRetVal;
-- -------------
    VARIABLE reference_ClusterInput          : IN tClusterInputPipe;
    SIGNAL ClusterInputPipe                  : IN tClusterInputPipe;
    VARIABLE retvalClusterInput              : INOUT tRetVal;
-- -------------
    VARIABLE reference_Isolation9x6          : IN tIsolationRegionPipe;
    SIGNAL Isolation9x6Pipe                  : IN tIsolationRegionPipe;
    VARIABLE retvalIsolation9x6              : INOUT tRetVal;
-- -------------
    CONSTANT debug                           : IN BOOLEAN := false
-- -------------
  ) IS BEGIN
-----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_3x3Veto'LENGTH - 1 ) LOOP
      CHECK_RESULT( "tau 3x3 Veto" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_tau3x3Veto , -- expected latency
                    timeout , -- timeout
                    retval3x3Veto( index ) , -- return value
                    ( reference_3x3Veto( index ) = tau3x3VetoPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_9x3Veto'LENGTH - 1 ) LOOP
      CHECK_RESULT( "egamma 9x3 Veto" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_egamma9x3Veto , -- expected latency
                    timeout , -- timeout
                    retval9x3Veto( index ) , -- return value
                    ( reference_9x3Veto( index ) = egamma9x3VetoPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_TowerThresholds'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Tower Thresholds" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_TowerThresholds , -- expected latency
                    timeout , -- timeout
                    retvalTowerThresholds( index ) , -- return value
                    ( reference_TowerThresholds( index ) = ClusterTowerPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_ProtoClusters'LENGTH - 1 ) LOOP
      CHECK_RESULT( "ProtoClusters" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_ProtoClusters , -- expected latency
                    timeout , -- timeout
                    retvalProtoClusters( index ) , -- return value
                    ( reference_ProtoClusters( index ) = ProtoClusterPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_FilteredProtoClusters'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Filtered ProtoClusters" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_FilteredProtoClusters , -- expected latency
                    timeout , -- timeout
                    retvalFilteredProtoClusters( index ) , -- return value
                    ( reference_FilteredProtoClusters( index ) = FilteredProtoClusterPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_ClusterInput'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Cluster Inputs" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_ClusterInput , -- expected latency
                    timeout , -- timeout
                    retvalClusterInput( index ) , -- return value
                    ( reference_ClusterInput( index ) = ClusterInputPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_Isolation9x6'LENGTH - 1 ) LOOP
      CHECK_RESULT( "9x6 Isolation Regions" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_Isolation9x6 , -- expected latency
                    timeout , -- timeout
                    retvalIsolation9x6( index ) , -- return value
                    ( reference_Isolation9x6( index ) = Isolation9x6Pipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

  END ClusterChecker;




  PROCEDURE ClusterDebug
  (
    VARIABLE clk_count              : IN INTEGER;
    SIGNAL tau3x3VetoPipe           : IN tComparisonPipe;
    SIGNAL egamma9x3VetoPipe        : IN tComparisonPipe;
    SIGNAL ProtoClusterPipe         : IN tClusterPipe;
    SIGNAL FilteredProtoClusterPipe : IN tClusterPipe;
    SIGNAL Isolation9x6Pipe         : IN tIsolationRegionPipe;
    CONSTANT debug                  : IN BOOLEAN := false
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    IF debug THEN
      OutputCandidate( clk_count , latency_tau3x3Veto , tau3x3VetoPipe( 0 ) , tau3x3VetoFile );
      OutputCandidate( clk_count , latency_egamma9x3Veto , egamma9x3VetoPipe( 0 ) , egamma9x3VetoFile );
      OutputCandidate( clk_count , latency_ProtoClusters , ProtoClusterPipe( 0 ) , ProtoClusterFile );
      OutputCandidate( clk_count , latency_FilteredProtoClusters , FilteredProtoClusterPipe( 0 ) , FilteredProtoClusterFile );
      OutputCandidate( clk_count , latency_Isolation9x6 , Isolation9x6Pipe( 0 ) , Isolation9x6File );
    END IF;
-- -----------------------------------------------------------------------------------------------------
  END ClusterDebug;




  PROCEDURE ClusterReport
  (
    VARIABLE retval3x3Veto               : IN tRetVal;
    VARIABLE retval9x3Veto               : IN tRetVal;
    VARIABLE retvalTowerThresholds       : IN tRetVal;
    VARIABLE retvalProtoClusters         : IN tRetVal;
    VARIABLE retvalFilteredProtoClusters : IN tRetVal;
    VARIABLE retvalClusterInput          : IN tRetVal;
    VARIABLE retvalIsolation9x6          : IN tRetVal
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    REPORT_RESULT( "tau 3x3 Veto" , retval3x3Veto );
    REPORT_RESULT( "egamma 9x3 Veto" , retval9x3Veto );
    REPORT_RESULT( "Tower Thresholds" , retvalTowerThresholds );
    REPORT_RESULT( "ProtoClusters" , retvalProtoClusters );
    REPORT_RESULT( "Filtered ProtoClusters" , retvalFilteredProtoClusters );
    REPORT_RESULT( "Cluster Inputs" , retvalClusterInput );
    REPORT_RESULT( "9x6 Isolation Regions" , retvalIsolation9x6 );
-- -----------------------------------------------------------------------------------------------------
  END ClusterReport;






  IMPURE FUNCTION EGAMMA_OVERLAP_VETO( EtaCentre : INTEGER ; PhiCentre : INTEGER ; Towers : tTowerPipe ) RETURN BOOLEAN IS
    VARIABLE s                                   : LINE;
    VARIABLE Central , Comparison                : tTower;
    VARIABLE Veto                                : BOOLEAN := FALSE;

    TYPE tMaskX IS ARRAY( -4 TO 4 ) OF BOOLEAN;
    TYPE tMask  IS ARRAY( -1 TO 1 ) OF tMaskX;

    CONSTANT GTmask : tMask :=
    (
      ( TRUE , TRUE , TRUE , TRUE , TRUE , TRUE , FALSE , FALSE , FALSE ) ,
      ( TRUE , TRUE , TRUE , TRUE , TRUE , FALSE , FALSE , FALSE , FALSE ) ,
      ( TRUE , TRUE , TRUE , FALSE , FALSE , FALSE , FALSE , FALSE , FALSE )
    );

  BEGIN
-- -----------------------------------------------------------------------------------------------------
    Central := GetTower( EtaCentre , PhiCentre , Towers );

    IF Central.Energy = 0 THEN -- Will always be less than or equal to its neighbours
      RETURN True;
    END IF;

    FOR DeltaEta IN -1 TO 1 LOOP
      FOR DeltaPhi IN -4 TO 4 LOOP
        Comparison := GetTower( EtaCentre + DeltaEta , PhiCentre + DeltaPhi , Towers );

        IF GTmask( DeltaEta )( DeltaPhi ) THEN
          Veto := Veto OR( Central.Energy < Comparison .Energy );
        ELSE
          Veto := Veto OR( Central.Energy <= Comparison .Energy );
        END IF;

      END LOOP;
    END LOOP;

    RETURN Veto;
-- -----------------------------------------------------------------------------------------------------
  END EGAMMA_OVERLAP_VETO;


  IMPURE FUNCTION TAU_OVERLAP_VETO( EtaCentre : INTEGER ; PhiCentre : INTEGER ; Towers : tTowerPipe ) RETURN BOOLEAN IS
    VARIABLE s                                : LINE;
    VARIABLE Central , Comparison             : tTower;
    VARIABLE Veto                             : BOOLEAN := FALSE;

    TYPE tMaskX IS ARRAY( -1 TO 1 ) OF BOOLEAN;
    TYPE tMask  IS ARRAY( -1 TO 1 ) OF tMaskX;

    CONSTANT GTmask : tMask :=
    (
      ( TRUE , TRUE , TRUE ) ,
      ( TRUE , TRUE , FALSE ) ,
      ( FALSE , FALSE , FALSE )
    );

  BEGIN
-- -----------------------------------------------------------------------------------------------------
    Central := GetTower( EtaCentre , PhiCentre , Towers );

    IF Central.Energy = 0 THEN -- Will always be less than or equal to its neighbours
      RETURN True;
    END IF;

    FOR DeltaEta IN -1 TO 1 LOOP
      FOR DeltaPhi IN -1 TO 1 LOOP
        Comparison := GetTower( EtaCentre + DeltaEta , PhiCentre + DeltaPhi , Towers );

        IF GTmask( DeltaEta )( DeltaPhi ) THEN
          Veto := Veto OR( Central.Energy < Comparison .Energy );
        ELSE
          Veto := Veto OR( Central.Energy <= Comparison .Energy );
        END IF;

      END LOOP;
    END LOOP;

    RETURN Veto;
-- -----------------------------------------------------------------------------------------------------
  END TAU_OVERLAP_VETO;




  FUNCTION GetTower( Eta : INTEGER ; Phi : INTEGER ; TowerThresholds : tTowerFlagsPipe ) RETURN tTowerFlags IS
    VARIABLE EtaSign     : INTEGER := 0;
    VARIABLE AbsEta      : INTEGER := 0;
  BEGIN
    IF( ( Eta < -cTestbenchTowersInHalfEta ) OR( Eta >= cTestbenchTowersInHalfEta ) ) THEN
     RETURN cEmptyTowerFlags;
    END IF;

    IF( Eta >= 0 ) THEN
      EtaSign := 0;
      AbsEta  := Eta;
    ELSE
      EtaSign := 1;
      AbsEta  := ABS( Eta ) -1;
    END IF;

    RETURN TowerThresholds( AbsEta )( EtaSign )( MOD_PHI( Phi ) );
  END GetTower;


  FUNCTION GetVeto( Eta : INTEGER ; Phi : INTEGER ; Vetos : tComparisonPipe ) RETURN tComparison IS
    VARIABLE EtaSign    : INTEGER := 0;
    VARIABLE AbsEta     : INTEGER := 0;
  BEGIN
    IF( ( Eta < -cTestbenchTowersInHalfEta ) OR( Eta >= cTestbenchTowersInHalfEta ) ) THEN
     RETURN cEmptyComparison;
    END IF;

    IF( Eta >= 0 ) THEN
      EtaSign := 0;
      AbsEta  := Eta;
    ELSE
      EtaSign := 1;
      AbsEta  := ABS( Eta ) -1;
    END IF;

    RETURN Vetos( AbsEta )( EtaSign )( MOD_PHI( Phi ) );
  END GetVeto;


  FUNCTION GetCluster( Eta : INTEGER ; Phi : INTEGER ; Cluster : tClusterPipe ) RETURN tCluster IS
    VARIABLE EtaSign       : INTEGER := 0;
    VARIABLE AbsEta        : INTEGER := 0;
  BEGIN
    IF( ( Eta < - ( cTestbenchTowersInHalfEta-1 ) ) OR( Eta >= ( cTestbenchTowersInHalfEta-1 ) ) ) THEN
     RETURN cEmptyCluster;
    END IF;

    IF( Eta >= 0 ) THEN
      EtaSign := 0;
      AbsEta  := Eta;
    ELSE
      EtaSign := 1;
      AbsEta  := ABS( Eta ) -1;
    END IF;

    RETURN Cluster( AbsEta )( EtaSign )( MOD_PHI( Phi ) );
  END GetCluster;


  FUNCTION PROTOCLUSTERS( Eta : INTEGER ; Phi : INTEGER ; Towers : tTowerPipe ; TowerThresholds : tTowerFlagsPipe ) RETURN tCluster IS
    VARIABLE ret              : tCluster                := cEmptyCluster;
    VARIABLE left , right     : UNSIGNED( 12 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN

      IF NOT GetTower( eta + 0 , phi + 0 , TowerThresholds ) .ClusterSeedThreshold THEN
        ret           := cEmptyCluster;
        ret.DataValid := TRUE;
        RETURN ret;
      END IF;

      IF( GetTower( eta-1 , phi-1 , TowerThresholds ) .ClusterThreshold ) THEN
        ret.Energy := ret.Energy + GetTower( eta-1 , phi-1 , Towers ) .Energy;
--ret.HasEM := ret.HasEM OR GetTower( eta-1 , phi-1 , Towers ) .HasEM;
        left       := left + GetTower( eta-1 , phi-1 , Towers ) .Energy;
      END IF;
      IF( GetTower( eta-1 , phi + 0 , TowerThresholds ) .ClusterThreshold ) THEN
        ret.Energy := ret.Energy + GetTower( eta-1 , phi + 0 , Towers ) .Energy;
--ret.HasEM := ret.HasEM OR GetTower( eta-1 , phi + 0 , Towers ) .HasEM;
        left       := left + GetTower( eta-1 , phi + 0 , Towers ) .Energy;
      END IF;
      IF( GetTower( eta-1 , phi + 1 , TowerThresholds ) .ClusterThreshold ) THEN
        ret.Energy := ret.Energy + GetTower( eta-1 , phi + 1 , Towers ) .Energy;
--ret.HasEM := ret.HasEM OR GetTower( eta-1 , phi + 1 , Towers ) .HasEM;
        left       := left + GetTower( eta-1 , phi + 1 , Towers ) .Energy;
      END IF;
      IF( GetTower( eta + 0 , phi-2 , TowerThresholds ) .ClusterThreshold AND GetTower( eta + 0 , phi-1 , TowerThresholds ) .ClusterThreshold ) THEN
        ret.Energy := ret.Energy + GetTower( eta + 0 , phi-2 , Towers ) .Energy;
--ret.HasEM := ret.HasEM OR GetTower( eta + 0 , phi-2 , Towers ) .HasEM;
      END IF;
      IF( GetTower( eta + 0 , phi-1 , TowerThresholds ) .ClusterThreshold ) THEN
        ret.Energy := ret.Energy + GetTower( eta + 0 , phi-1 , Towers ) .Energy;
--ret.HasEM := ret.HasEM OR GetTower( eta + 0 , phi-1 , Towers ) .HasEM;
      END IF;
      IF( GetTower( eta + 0 , phi + 0 , TowerThresholds ) .ClusterThreshold ) THEN
        ret.Energy := ret.Energy + GetTower( eta + 0 , phi + 0 , Towers ) .Energy;
--ret.HasEM := ret.HasEM OR GetTower( eta + 0 , phi + 0 , Towers ) .HasEM;
      END IF;
      IF( GetTower( eta + 0 , phi + 1 , TowerThresholds ) .ClusterThreshold ) THEN
        ret.Energy := ret.Energy + GetTower( eta + 0 , phi + 1 , Towers ) .Energy;
--ret.HasEM := ret.HasEM OR GetTower( eta + 0 , phi + 1 , Towers ) .HasEM;
      END IF;
      IF( GetTower( eta + 0 , phi + 2 , TowerThresholds ) .ClusterThreshold AND GetTower( eta + 0 , phi + 1 , TowerThresholds ) .ClusterThreshold ) THEN
        ret.Energy := ret.Energy + GetTower( eta + 0 , phi + 2 , Towers ) .Energy;
--ret.HasEM := ret.HasEM OR GetTower( eta + 0 , phi + 2 , Towers ) .HasEM;
      END IF;
      IF( GetTower( eta + 1 , phi-1 , TowerThresholds ) .ClusterThreshold ) THEN
        ret.Energy := ret.Energy + GetTower( eta + 1 , phi-1 , Towers ) .Energy;
--ret.HasEM := ret.HasEM OR GetTower( eta + 1 , phi-1 , Towers ) .HasEM;
        right      := right + GetTower( eta + 1 , phi-1 , Towers ) .Energy;
      END IF;
      IF( GetTower( eta + 1 , phi + 0 , TowerThresholds ) .ClusterThreshold ) THEN
        ret.Energy := ret.Energy + GetTower( eta + 1 , phi + 0 , Towers ) .Energy;
--ret.HasEM := ret.HasEM OR GetTower( eta + 1 , phi + 0 , Towers ) .HasEM;
        right      := right + GetTower( eta + 1 , phi + 0 , Towers ) .Energy;
      END IF;
      IF( GetTower( eta + 1 , phi + 1 , TowerThresholds ) .ClusterThreshold ) THEN
        ret.Energy := ret.Energy + GetTower( eta + 1 , phi + 1 , Towers ) .Energy;
--ret.HasEM := ret.HasEM OR GetTower( eta + 1 , phi + 1 , Towers ) .HasEM;
        right      := right + GetTower( eta + 1 , phi + 1 , Towers ) .Energy;
      END IF;

      ret.HasSeed         := GetTower( eta + 0 , phi + 0 , TowerThresholds ) .ClusterSeedThreshold;
      ret.EgammaCandidate := GetTower( eta + 0 , phi + 0 , Towers ) .EgammaCandidate;
      ret.HasEM           := GetTower( eta + 0 , phi + 0 , Towers ) .HasEM;

      IF( left > right ) THEN
        ret.LateralPosition := West;
      ELSIF( left = right ) THEN
        ret.LateralPosition := Centre;
      ELSE
        ret.LateralPosition := East;
      END IF;


      ret.TrimmingFlags( 6 ) := TO_STD_LOGIC( GetTower( eta + 0 , phi + 2 , TowerThresholds ) .ClusterThreshold AND GetTower( eta + 0 , phi + 1 , TowerThresholds ) .ClusterThreshold );
      ret.TrimmingFlags( 5 ) := TO_STD_LOGIC( GetTower( eta + 0 , phi-2 , TowerThresholds ) .ClusterThreshold AND GetTower( eta + 0 , phi-1 , TowerThresholds ) .ClusterThreshold );
      IF ret.LateralPosition = West THEN
        ret.TrimmingFlags( 4 ) := TO_STD_LOGIC( GetTower( eta-1 , phi + 1 , TowerThresholds ) .ClusterThreshold );
        ret.TrimmingFlags( 3 ) := TO_STD_LOGIC( GetTower( eta-1 , phi-1 , TowerThresholds ) .ClusterThreshold );
        ret.TrimmingFlags( 2 ) := TO_STD_LOGIC( GetTower( eta-1 , phi + 0 , TowerThresholds ) .ClusterThreshold );
      ELSE
        ret.TrimmingFlags( 4 ) := TO_STD_LOGIC( GetTower( eta + 1 , phi + 1 , TowerThresholds ) .ClusterThreshold );
        ret.TrimmingFlags( 3 ) := TO_STD_LOGIC( GetTower( eta + 1 , phi-1 , TowerThresholds ) .ClusterThreshold );
        ret.TrimmingFlags( 2 ) := TO_STD_LOGIC( GetTower( eta + 1 , phi + 0 , TowerThresholds ) .ClusterThreshold );
      END IF;
      ret.TrimmingFlags( 1 ) := TO_STD_LOGIC( GetTower( eta + 0 , phi + 1 , TowerThresholds ) .ClusterThreshold );
      ret.TrimmingFlags( 0 ) := TO_STD_LOGIC( GetTower( eta + 0 , phi-1 , TowerThresholds ) .ClusterThreshold );

      ret.DataValid          := TRUE;

    RETURN ret;
  END PROTOCLUSTERS;


  FUNCTION CLUSTER( ClusterInput : tClusterInput ; ProtoCluster : tCluster ) RETURN tCluster IS
    VARIABLE SumN , SumS         : UNSIGNED( 12 DOWNTO 0 ) := ( OTHERS => '0' );
    VARIABLE ret                 : tCluster                := cEmptyCluster;
  BEGIN

      ret := ProtoCluster;

      IF ProtoCluster.HasSeed THEN
        ret.Energy := "0000" & ClusterInput.Centre.Energy;
        ret.HasEM  := ClusterInput.Centre.HasEM;
      END IF;

      IF ProtoCluster.LateralPosition = West THEN
        IF ProtoCluster.TrimmingFlags( 4 ) = '1' THEN -- R1NW
          SumN       := SumN + ClusterInput.R1NW.Energy;
          ret.Energy := ret.Energy + ClusterInput.R1NW.Energy;
          ret.HasEM  := ret.HasEM OR ClusterInput.R1NW.HasEM;
        END IF;

        IF ProtoCluster.TrimmingFlags( 2 ) = '1' THEN -- R1W
          ret.Energy := ret.Energy + ClusterInput.R1W.Energy;
          ret.HasEM  := ret.HasEM OR ClusterInput.R1W.HasEM;
        END IF;

        IF ProtoCluster.TrimmingFlags( 3 ) = '1' THEN -- R1SW
          SumS       := SumS + ClusterInput.R1SW.Energy;
          ret.Energy := ret.Energy + ClusterInput.R1SW.Energy;
          ret.HasEM  := ret.HasEM OR ClusterInput.R1SW.HasEM;
        END IF;
      ELSE
        IF ProtoCluster.TrimmingFlags( 4 ) = '1' THEN -- R1NE
          SumN       := SumN + ClusterInput.R1NE.Energy;
          ret.Energy := ret.Energy + ClusterInput.R1NE.Energy;
          ret.HasEM  := ret.HasEM OR ClusterInput.R1NE.HasEM;
        END IF;

        IF ProtoCluster.TrimmingFlags( 2 ) = '1' THEN -- R1E
          ret.Energy := ret.Energy + ClusterInput.R1E.Energy;
          ret.HasEM  := ret.HasEM OR ClusterInput.R1E.HasEM;
        END IF;

        IF ProtoCluster.TrimmingFlags( 3 ) = '1' THEN -- R1SE
          SumS       := SumS + ClusterInput.R1SE.Energy;
          ret.Energy := ret.Energy + ClusterInput.R1SE.Energy;
          ret.HasEM  := ret.HasEM OR ClusterInput.R1SE.HasEM;
        END IF;
      END IF;

      IF ProtoCluster.TrimmingFlags( 1 ) = '1' THEN -- R1N
        SumN       := SumN + ClusterInput.R1N.Energy;
        ret.Energy := ret.Energy + ClusterInput.R1N.Energy;
        ret.HasEM  := ret.HasEM OR ClusterInput.R1N.HasEM;
      END IF;

      IF ProtoCluster.TrimmingFlags( 0 ) = '1' THEN -- R1S
        SumS       := SumS + ClusterInput.R1S.Energy;
        ret.Energy := ret.Energy + ClusterInput.R1S.Energy;
        ret.HasEM  := ret.HasEM OR ClusterInput.R1S.HasEM;
      END IF;

      IF ProtoCluster.TrimmingFlags( 6 ) = '1' THEN -- R2N
        SumN       := SumN + ClusterInput.R2N.Energy;
        ret.Energy := ret.Energy + ClusterInput.R2N.Energy;
        ret.HasEM  := ret.HasEM OR ClusterInput.R2N.HasEM;
      END IF;

      IF ProtoCluster.TrimmingFlags( 5 ) = '1' THEN -- R2S
        SumS       := SumS + ClusterInput.R2S.Energy;
        ret.Energy := ret.Energy + ClusterInput.R2S.Energy;
        ret.HasEM  := ret.HasEM OR ClusterInput.R2S.HasEM;
      END IF;

      IF SumN > SumS THEN
        ret.VerticalPosition := North;
      ELSIF SumN = SumS THEN
        ret.VerticalPosition := Centre;
      ELSE
        ret.VerticalPosition := South;
      END IF;

    RETURN ret;
  END CLUSTER;


  PROCEDURE CLUSTER_BITONIC_SORT( VARIABLE a : INOUT tClusterInPhi( 0 TO( cTowerInPhi / 4 ) -1 ) ; lo , n : IN INTEGER ; dir : IN BOOLEAN ) IS
    VARIABLE m                               : INTEGER;
  BEGIN
-- -----------------------------------------------------------------------------------------------------
    IF n > 1 THEN
        m := n / 2;
        CLUSTER_BITONIC_SORT( a , lo , m , NOT dir );
        CLUSTER_BITONIC_SORT( a , lo + m , n-m , dir );
        CLUSTER_BITONIC_MERGE( a , lo , n , dir );
    END IF;
-- -----------------------------------------------------------------------------------------------------
  END CLUSTER_BITONIC_SORT;

  PROCEDURE CLUSTER_BITONIC_MERGE( VARIABLE a : INOUT tClusterInPhi( 0 TO( cTowerInPhi / 4 ) -1 ) ; lo , n : IN INTEGER ; dir : IN BOOLEAN ) IS
    VARIABLE m                                : INTEGER;
    VARIABLE temp                             : tCluster;
  BEGIN
-- -----------------------------------------------------------------------------------------------------
    IF n > 1 THEN
      m := PowerOf2LessThan( n );
      FOR i IN lo TO( lo + n-m-1 ) LOOP
        IF( dir = ( a( i ) > a( i + m ) ) ) THEN
          temp       := a( i );
          a( i )     := a( i + m );
          a( i + m ) := temp;
        END IF;
      END LOOP;
      CLUSTER_BITONIC_MERGE( a , lo , m , dir );
      CLUSTER_BITONIC_MERGE( a , lo + m , n-m , dir );
    END IF;
-- -----------------------------------------------------------------------------------------------------
  END CLUSTER_BITONIC_MERGE;



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE OutputCandidate( VARIABLE clk : IN INTEGER ; CONSTANT latency : IN INTEGER ; SIGNAL data : IN tClusterInEtaPhi ; FILE f : TEXT ) IS
    VARIABLE s                            : LINE;
    VARIABLE algotime , event , frame     : INTEGER;
  BEGIN

    IF clk < 0 THEN
      WRITE( s , STRING' ( "Clock" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "AlgoClock" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Event" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Frame" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Eta-Half" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Phi" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "|" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Energy" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Phi" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Eta" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Eta-Half" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Lat-Pos" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Vert-Pos" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "EgammaCandidate" ) , RIGHT , 16 );
      WRITE( s , STRING' ( "No Secondary" ) , RIGHT , 13 );
      WRITE( s , STRING' ( "HasEM" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "HasSeed" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Isolated" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Isolated2" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "TauSite" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "TrimFlags" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "ShapeFlags" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "DataValid" ) , RIGHT , 11 );
      WRITELINE( f , s );

    ELSE

      algotime := clk-latency-1;
      frame    := algotime MOD 54;
      event    := algotime / 54;

      FOR j IN 0 TO( cRegionInEta-1 ) LOOP
        FOR i IN 0 TO( cTowerInPhi-1 ) LOOP
          IF data( j )( i ) .Energy > 0 THEN
            WRITE( s , clk , RIGHT , 11 );
            WRITE( s , algotime , RIGHT , 11 );
            WRITE( s , event , RIGHT , 11 );
            WRITE( s , frame , RIGHT , 11 );
            WRITE( s , j , RIGHT , 11 );
            WRITE( s , i , RIGHT , 11 );
            WRITE( s , STRING' ( "|" ) , RIGHT , 11 );
            WRITE( s , TO_INTEGER( data( j )( i ) .Energy ) , RIGHT , 11 );
            WRITE( s , data( j )( i ) .Phi , RIGHT , 11 );
            WRITE( s , data( j )( i ) .Eta , RIGHT , 11 );
            WRITE( s , data( j )( i ) .EtaHalf , RIGHT , 11 );
            WRITE( s , encodeLateralPosition( data( j )( i ) .LateralPosition ) , RIGHT , 11 );
            WRITE( s , encodeVerticalPosition( data( j )( i ) .VerticalPosition ) , RIGHT , 11 );
            WRITE( s , data( j )( i ) .EgammaCandidate , RIGHT , 16 );
            WRITE( s , data( j )( i ) .NoSecondary , RIGHT , 13 );
            WRITE( s , data( j )( i ) .HasEM , RIGHT , 11 );
            WRITE( s , data( j )( i ) .HasSeed , RIGHT , 11 );
            WRITE( s , data( j )( i ) .Isolated , RIGHT , 11 );
            WRITE( s , data( j )( i ) .Isolated2 , RIGHT , 11 );
            WRITE( s , data( j )( i ) .TauSite , RIGHT , 11 );
            WRITE( s , data( j )( i ) .TrimmingFlags , RIGHT , 11 );
            WRITE( s , data( j )( i ) .ShapeFlags , RIGHT , 11 );
            WRITE( s , data( j )( i ) .DataValid , RIGHT , 11 );
            WRITELINE( f , s );
          END IF;
        END LOOP;
      END LOOP;
    END IF;
  END OutputCandidate;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------




-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE OutputCandidate( VARIABLE clk : IN INTEGER ; CONSTANT latency : IN INTEGER ; SIGNAL data : IN tIsolationRegionInEtaPhi ; FILE f : TEXT ) IS
    VARIABLE s                            : LINE;
    VARIABLE algotime , event , frame     : INTEGER;
  BEGIN

    IF clk < 0 THEN
      WRITE( s , STRING' ( "Clock" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "AlgoClock" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Event" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Frame" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Eta-Half" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Phi" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "|" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Energy" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "DataValid" ) , RIGHT , 11 );
      WRITELINE( f , s );

    ELSE

      algotime := clk-latency-1;
      frame    := algotime MOD 54;
      event    := algotime / 54;

      FOR j IN 0 TO( cRegionInEta-1 ) LOOP
        FOR i IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
          IF data( j )( i ) .Energy > 0 THEN
            WRITE( s , clk , RIGHT , 11 );
            WRITE( s , algotime , RIGHT , 11 );
            WRITE( s , event , RIGHT , 11 );
            WRITE( s , frame , RIGHT , 11 );
            WRITE( s , j , RIGHT , 11 );
            WRITE( s , i , RIGHT , 11 );
            WRITE( s , STRING' ( "|" ) , RIGHT , 11 );
            WRITE( s , TO_INTEGER( data( j )( i ) .Energy ) , RIGHT , 11 );
            WRITE( s , data( j )( i ) .DataValid , RIGHT , 11 );
            WRITELINE( f , s );
          END IF;
        END LOOP;
      END LOOP;
    END IF;
  END OutputCandidate;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  PROCEDURE OutputCandidate( VARIABLE clk : IN INTEGER ; CONSTANT latency : IN INTEGER ; SIGNAL data : IN tPileupEstimationInEtaPhi ; FILE f : TEXT ) IS
    VARIABLE s                            : LINE;
    VARIABLE algotime , event , frame     : INTEGER;
  BEGIN

    IF clk < 0 THEN
      WRITE( s , STRING' ( "Clock" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "AlgoClock" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Event" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Frame" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Eta-Half" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Phi" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "|" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Compressed-Eta (5:2bit)" ) , RIGHT , 24 );
      WRITE( s , STRING' ( "Compressed-Eta (5:4bit)" ) , RIGHT , 24 );
      WRITE( s , STRING' ( "Compressed-Eta (6:4bit)" ) , RIGHT , 24 );
      WRITE( s , STRING' ( "Towers-Over-Threshold" ) , RIGHT , 22 );
      WRITE( s , STRING' ( "DataValid" ) , RIGHT , 11 );
      WRITELINE( f , s );

    ELSE

      algotime := clk-latency-1;
      frame    := algotime MOD 54;
      event    := algotime / 54;

      FOR j IN 0 TO( cRegionInEta-1 ) LOOP
        FOR i IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
          WRITE( s , clk , RIGHT , 11 );
          WRITE( s , algotime , RIGHT , 11 );
          WRITE( s , event , RIGHT , 11 );
          WRITE( s , frame , RIGHT , 11 );
          WRITE( s , j , RIGHT , 11 );
          WRITE( s , i , RIGHT , 11 );
          WRITE( s , STRING' ( "|" ) , RIGHT , 11 );
          WRITE( s , TO_INTEGER( data( j )( i ) .CompressedEta2 ) , RIGHT , 24 );
          WRITE( s , TO_INTEGER( data( j )( i ) .CompressedEta4a ) , RIGHT , 24 );
          WRITE( s , TO_INTEGER( data( j )( i ) .CompressedEta4j ) , RIGHT , 24 );
          WRITE( s , TO_INTEGER( data( j )( i ) .towerCount ) , RIGHT , 22 );
          WRITE( s , data( j )( i ) .DataValid , RIGHT , 11 );
          WRITELINE( f , s );
        END LOOP;
      END LOOP;
    END IF;
  END OutputCandidate;


END PACKAGE BODY ClusterReference;
