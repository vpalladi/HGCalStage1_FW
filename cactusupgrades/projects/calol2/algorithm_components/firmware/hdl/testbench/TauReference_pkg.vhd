
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

--! Using the Calo-L2 "Cluster" testbench suite
USE work.ClusterReference.ALL;

--! Writing to and from files
USE STD.TEXTIO.ALL;
--! Writing to and from files
USE IEEE.STD_LOGIC_TEXTIO.ALL;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
PACKAGE TauReference IS

  CONSTANT latency_TauSecondaries             : INTEGER := latency_ProtoClusters + 3;
  CONSTANT latency_FilteredTauSecondaries     : INTEGER := latency_Egamma9x3Veto + 1;

  CONSTANT latency_TauProtoCluster            : INTEGER := latency_FilteredProtoClusters + 1;
  CONSTANT latency_TauPrimary                 : INTEGER := latency_TauProtoCluster + 4;
  CONSTANT latency_FinalTau                   : INTEGER := latency_TauPrimary + 1;

  CONSTANT latency_TauIsolationRegion         : INTEGER := latency_FinalTau + 1;

  CONSTANT latency_CalibratedTau              : INTEGER := latency_FinalTau + 5;
  CONSTANT latency_SortedTau                  : INTEGER := latency_CalibratedTau + 14;
  CONSTANT latency_accumulatedSortedTau       : INTEGER := latency_SortedTau + 8;
  CONSTANT latency_TauPackedLink              : INTEGER := latency_accumulatedSortedTau;

  CONSTANT latency_demuxAccumulatedSortedTaus : INTEGER := latency_accumulatedSortedTau + cEcalTowersInHalfEta + 16;
  CONSTANT latency_mergedSortedTaus           : INTEGER := latency_demuxAccumulatedSortedTaus + 4;
  CONSTANT latency_GtFormattedTaus            : INTEGER := latency_mergedSortedTaus + 1;

  CONSTANT latency_DemuxTauPackedLink         : INTEGER := latency_GtFormattedTaus;


  FILE TauSecondariesFile                     : TEXT OPEN write_mode IS "IntermediateSteps/TauSecondariesPipe.txt";
  FILE FilteredTauSecondariesFile             : TEXT OPEN write_mode IS "IntermediateSteps/FilteredTauSecondariesPipe.txt";
  FILE TauProtoClusterFile                    : TEXT OPEN write_mode IS "IntermediateSteps/TauProtoClusterPipe.txt";
  FILE TauPrimaryFile                         : TEXT OPEN write_mode IS "IntermediateSteps/TauPrimaryPipe.txt";
  FILE FinalTauFile                           : TEXT OPEN write_mode IS "IntermediateSteps/FinalTauPipe.txt";
  FILE TauIsolationFile                       : TEXT OPEN write_mode IS "IntermediateSteps/TauIsolationRegionPipe.txt";
  FILE CalibratedTauFile                      : TEXT OPEN write_mode IS "IntermediateSteps/CalibratedTauPipe.txt";
  FILE SortedTauFile                          : TEXT OPEN write_mode IS "IntermediateSteps/SortedTauPipe.txt";
  FILE accumulatedSortedTauFile               : TEXT OPEN write_mode IS "IntermediateSteps/AccumulatedSortedTauPipe.txt";


  PROCEDURE TauReference
  (
    VARIABLE reference_Towers                    : IN tTowerPipe;
    VARIABLE reference_accumulatedETandMETrings  : IN tRingSegmentPipe2;
    VARIABLE reference_3x3Veto                   : IN tComparisonPipe;
    VARIABLE reference_9x3Veto                   : IN tComparisonPipe;
    VARIABLE reference_TowerThresholds           : IN tTowerFlagsPipe;
    VARIABLE reference_ProtoClusters             : IN tClusterPipe;
    VARIABLE reference_FilteredProtoClusters     : IN tClusterPipe;
    VARIABLE reference_ClusterInput              : IN tClusterInputPipe;

    VARIABLE reference_TauSecondaries            : INOUT tClusterPipe;
    VARIABLE reference_FilteredTauSecondaries    : INOUT tClusterPipe;
    VARIABLE reference_TauProtoCluster           : INOUT tClusterPipe;
    VARIABLE reference_TauPrimary                : INOUT tClusterPipe;
    VARIABLE reference_FinalTau                  : INOUT tClusterPipe;
    VARIABLE reference_Isolation9x6              : IN tIsolationRegionPipe;
    VARIABLE reference_ClusterPileupEstimation   : IN tPileupEstimationPipe;
    VARIABLE reference_TauIsolationRegion        : INOUT tIsolationRegionPipe;

    VARIABLE reference_CalibratedTau             : INOUT tClusterPipe;
    VARIABLE reference_sortedTau                 : INOUT tClusterPipe;
    VARIABLE reference_accumulatedSortedTau      : INOUT tClusterPipe;
    VARIABLE reference_TauPackedLink             : INOUT tPackedLinkPipe;
    VARIABLE reference_demuxAccumulatedSortedTau : INOUT tClusterPipe;
    VARIABLE reference_mergedSortedTau           : INOUT tClusterPipe;
    VARIABLE reference_GtFormattedTau            : INOUT tGtFormattedClusterPipe;
    VARIABLE reference_DemuxTauPackedLink        : INOUT tPackedLinkPipe
  );


  PROCEDURE TauChecker
  (
    VARIABLE clk_count                           : IN INTEGER;
    CONSTANT timeout                             : IN INTEGER;
-- -------------
    VARIABLE reference_TauSecondaries            : IN tClusterPipe;
    SIGNAL TauSecondariesPipe                    : IN tClusterPipe;
    VARIABLE retvalTauSecondaries                : INOUT tRetVal;
-- -------------
    VARIABLE reference_FilteredTauSecondaries    : IN tClusterPipe;
    SIGNAL FilteredTauPipe                       : IN tClusterPipe;
    VARIABLE retvalFilteredTauSecondaries        : INOUT tRetVal;
-- -------------
    VARIABLE reference_TauProtoCluster           : IN tClusterPipe;
    SIGNAL TauProtoClusterPipe                   : IN tClusterPipe;
    VARIABLE retvalTauProtoCluster               : INOUT tRetVal;
-- -------------
    VARIABLE reference_TauPrimary                : IN tClusterPipe;
    SIGNAL TauPrimaryPipe                        : IN tClusterPipe;
    VARIABLE retvalTauPrimary                    : INOUT tRetVal;
-- -------------
    VARIABLE reference_FinalTau                  : IN tClusterPipe;
    SIGNAL FinalTauPipe                          : IN tClusterPipe;
    VARIABLE retvalFinalTau                      : INOUT tRetVal;
-- -------------
    VARIABLE reference_TauIsolationRegion        : IN tIsolationRegionPipe;
    SIGNAL TauIsolationRegionPipe                : IN tIsolationRegionPipe;
    VARIABLE retvalTauIsolationRegion            : INOUT tRetVal;
-- -------------
    VARIABLE reference_CalibratedTau             : IN tClusterPipe;
    SIGNAL CalibratedTauPipe                     : IN tClusterPipe;
    VARIABLE retvalCalibratedTau                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_sortedTau                 : IN tClusterPipe;
    SIGNAL SortedTauPipe                         : IN tClusterPipe;
    VARIABLE retvalSortedTau                     : INOUT tRetVal;
-- -------------
    VARIABLE reference_accumulatedSortedTau      : IN tClusterPipe;
    SIGNAL accumulatedSortedTauPipe              : IN tClusterPipe;
    VARIABLE retvalAccumulatedSortedTau          : INOUT tRetVal;
-- -------------
    VARIABLE reference_TauPackedLink             : IN tPackedLinkPipe;
    SIGNAL TauPackedLinkPipe                     : IN tPackedLinkPipe;
    VARIABLE retvalTauPackedLink                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedSortedTau : IN tClusterPipe;
    SIGNAL demuxAccumulatedSortedTauPipe         : IN tClusterPipe;
    VARIABLE retvalDemuxAccumulatedSortedTau     : INOUT tRetVal;
-- -------------
    VARIABLE reference_mergedSortedTau           : IN tClusterPipe;
    SIGNAL mergedSortedTauPipe                   : IN tClusterPipe;
    VARIABLE retvalMergedSortedTau               : INOUT tRetVal;
-- -------------
    VARIABLE reference_GtFormattedTau            : IN tGtFormattedClusterPipe;
    SIGNAL GtFormattedTauPipe                    : IN tGtFormattedClusterPipe;
    VARIABLE retvalGtFormattedTau                : INOUT tRetVal;
-- -------------
    VARIABLE reference_DemuxTauPackedLink        : IN tPackedLinkPipe;
    SIGNAL DemuxTauPackedLinkPipe                : IN tPackedLinkPipe;
    VARIABLE retvalDemuxTauPackedLink            : INOUT tRetVal;
-- -------------
    CONSTANT debug                               : IN BOOLEAN := false
-- -------------
  );

  PROCEDURE TauDebug
  (
    VARIABLE clk_count                : IN INTEGER;
    SIGNAL TauSecondariesPipe         : IN tClusterPipe;
    SIGNAL FilteredTauSecondariesPipe : IN tClusterPipe;
    SIGNAL TauProtoClusterPipe        : IN tClusterPipe;
    SIGNAL TauPrimaryPipe             : IN tClusterPipe;
    SIGNAL FinalTauPipe               : IN tClusterPipe;
    SIGNAL TauIsolationRegionPipe     : IN tIsolationRegionPipe;
    SIGNAL CalibratedTauPipe          : IN tClusterPipe;
    SIGNAL SortedTauPipe              : IN tClusterPipe;
    SIGNAL accumulatedSortedTauPipe   : IN tClusterPipe;
    CONSTANT debug                    : IN BOOLEAN := false
  );

  PROCEDURE TauReport
  (
    VARIABLE retvalTauSecondaries            : IN tRetVal;
    VARIABLE retvalFilteredTauSecondaries    : IN tRetVal;
    VARIABLE retvalTauProtoCluster           : IN tRetVal;
    VARIABLE retvalTauPrimary                : IN tRetVal;
    VARIABLE retvalFinalTau                  : IN tRetVal;
    VARIABLE retvalTauIsolationRegion        : IN tRetVal;
    VARIABLE retvalCalibratedTau             : IN tRetVal;
    VARIABLE retvalSortedTau                 : IN tRetVal;
    VARIABLE retvalAccumulatedSortedTau      : IN tRetVal;
    VARIABLE retvalTauPackedLink             : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedSortedTau : IN tRetVal;
    VARIABLE retvalMergedSortedTau           : IN tRetVal;
    VARIABLE retvalGtFormattedTau            : IN tRetVal;
    VARIABLE retvalDemuxTauPackedLink        : IN tRetVal
  );

  FUNCTION TauSecondaries( Eta : INTEGER ; Phi : INTEGER ; ProtoClusters : tClusterPipe ; TauVetos : tComparisonPipe ) RETURN tCluster;

END PACKAGE TauReference;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------



-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
PACKAGE BODY TauReference IS

  PROCEDURE TauReference
  (
    VARIABLE reference_Towers                    : IN tTowerPipe;
    VARIABLE reference_accumulatedETandMETrings  : IN tRingSegmentPipe2;
    VARIABLE reference_3x3Veto                   : IN tComparisonPipe;
    VARIABLE reference_9x3Veto                   : IN tComparisonPipe;
    VARIABLE reference_TowerThresholds           : IN tTowerFlagsPipe;
    VARIABLE reference_ProtoClusters             : IN tClusterPipe;
    VARIABLE reference_FilteredProtoClusters     : IN tClusterPipe;
    VARIABLE reference_ClusterInput              : IN tClusterInputPipe;

    VARIABLE reference_TauSecondaries            : INOUT tClusterPipe;
    VARIABLE reference_FilteredTauSecondaries    : INOUT tClusterPipe;
    VARIABLE reference_TauProtoCluster           : INOUT tClusterPipe;
    VARIABLE reference_TauPrimary                : INOUT tClusterPipe;
    VARIABLE reference_FinalTau                  : INOUT tClusterPipe;
    VARIABLE reference_Isolation9x6              : IN tIsolationRegionPipe;
    VARIABLE reference_ClusterPileupEstimation   : IN tPileupEstimationPipe;
    VARIABLE reference_TauIsolationRegion        : INOUT tIsolationRegionPipe;

    VARIABLE reference_CalibratedTau             : INOUT tClusterPipe;
    VARIABLE reference_sortedTau                 : INOUT tClusterPipe;
    VARIABLE reference_accumulatedSortedTau      : INOUT tClusterPipe;
    VARIABLE reference_TauPackedLink             : INOUT tPackedLinkPipe;
    VARIABLE reference_demuxAccumulatedSortedTau : INOUT tClusterPipe;
    VARIABLE reference_mergedSortedTau           : INOUT tClusterPipe;
    VARIABLE reference_GtFormattedTau            : INOUT tGtFormattedClusterPipe;
    VARIABLE reference_DemuxTauPackedLink        : INOUT tPackedLinkPipe
  ) IS

    TYPE mem_type_8to7 IS ARRAY( 0 TO( 2 ** 8 ) -1 ) OF STD_LOGIC_VECTOR( 6 DOWNTO 0 );
    VARIABLE FlagTrimLUT_8to7 : mem_type_8to7;

    TYPE mem_type_9to8 IS ARRAY( 0 TO( 2 ** 9 ) -1 ) OF STD_LOGIC_VECTOR( 7 DOWNTO 0 );
    VARIABLE Y_localEtaToGT_9to8 , Z_localPhiToGT_9to8 : mem_type_9to8;

    TYPE mem_type_8to5 IS ARRAY( 0 TO( 2 ** 8 ) -1 ) OF STD_LOGIC_VECTOR( 4 DOWNTO 0 );
    VARIABLE F_TauEnergyCompression_8to5 : mem_type_8to5;

    TYPE mem_type_11to18 IS ARRAY( 0 TO( 2 ** 11 ) -1 ) OF STD_LOGIC_VECTOR( 17 DOWNTO 0 );
    VARIABLE I_TauCalibration_11to18 : mem_type_11to18;

    TYPE mem_type_12to9 IS ARRAY( 0 TO( 2 ** 12 ) -1 ) OF STD_LOGIC_VECTOR( 8 DOWNTO 0 );
    VARIABLE H_TauIsolation_12to9 , H_TauIsolation2_12to9 : mem_type_12to9;


    FILE RomFile                                          : TEXT;
    VARIABLE RomFileLine                                  : LINE;
    VARIABLE TEMP                                         : CHARACTER;
    VARIABLE Value                                        : STD_LOGIC_VECTOR( 19 DOWNTO 0 );

    VARIABLE Trimming                                     : UNSIGNED( 7 DOWNTO 0 ) := ( OTHERS => '0' );

    VARIABLE Energy                                       : UNSIGNED( 8 DOWNTO 0 ) := ( OTHERS => '0' );
    VARIABLE TauMultiplier                                : UNSIGNED( 9 DOWNTO 0 ) := ( OTHERS => '0' );
    VARIABLE TauOffset                                    : SIGNED( 7 DOWNTO 0 )   := ( OTHERS => '0' );
    VARIABLE TauIsolationThreshold                        : UNSIGNED( 7 DOWNTO 0 ) := ( OTHERS => '0' );
    VARIABLE TauIsolationFlag                             : STD_LOGIC              := '0';         
    VARIABLE TempEnergy                                   : SIGNED( 22 DOWNTO 0 )  := ( OTHERS => '0' );

    VARIABLE IntEnergy                                    : INTEGER                := 0;

    VARIABLE L                                            : LINE;

  BEGIN
-- -----------------------------------------------------------------------------------------------------
    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/P_TauTrimming_8to7.mif" ) , READ_MODE );
    FOR i IN FlagTrimLUT_8to7'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      FlagTrimLUT_8to7( i ) := Value( 7-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/H_TauIsolation1_12to9.mif" ) , READ_MODE );
    FOR i IN H_TauIsolation_12to9'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      H_TauIsolation_12to9( i ) := Value( 9-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/H_TauIsolation2_12to9.mif" ) , READ_MODE );
    FOR i IN H_TauIsolation2_12to9'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      H_TauIsolation2_12to9( i ) := Value( 9-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/F_TauEnergyCompression_8to5.mif" ) , READ_MODE );
    FOR i IN F_TauEnergyCompression_8to5'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      F_TauEnergyCompression_8to5( i ) := Value( 5-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/I_TauCalibration_11to18.mif" ) , READ_MODE );
    FOR i IN I_TauCalibration_11to18'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      I_TauCalibration_11to18( i ) := Value( 18-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/Y_localEtaToGT_9to8.mif" ) , READ_MODE );
    FOR i IN Y_localEtaToGT_9to8'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      Y_localEtaToGT_9to8( i ) := Value( 8-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/Z_localPhiToGT_9to8.mif" ) , READ_MODE );
    FOR i IN Z_localPhiToGT_9to8'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      Z_localPhiToGT_9to8( i ) := Value( 8-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO cTowerInPhi-1 LOOP
      FOR eta IN 0 TO( reference_TauSecondaries'LENGTH - 1 ) LOOP
        reference_TauSecondaries( eta )( 0 )( phi ) := TauSecondaries( eta , phi , reference_ProtoClusters , reference_3x3Veto );
        reference_TauSecondaries( eta )( 1 )( phi ) := TauSecondaries( ( -eta-1 ) , phi , reference_ProtoClusters , reference_3x3Veto );
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta_half IN 0 TO cRegionInEta-1 LOOP
        FOR eta IN 0 TO( reference_FilteredTauSecondaries'LENGTH - 1 ) LOOP

          IF( NOT reference_9x3Veto( eta )( eta_half )( ( 4 * phi ) + 0 ) .Data ) THEN
            reference_FilteredTauSecondaries( eta )( eta_half )( phi )      := reference_TauSecondaries( eta )( eta_half )( MOD_PHI( ( 4 * phi ) + 0 ) );
            reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .eta := eta + cCMScoordinateOffset;
            reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .phi := MOD_PHI( ( 4 * phi ) + 0 ) + cCMScoordinateOffset;
          ELSIF( NOT reference_9x3Veto( eta )( eta_half )( ( 4 * phi ) + 1 ) .Data ) THEN
            reference_FilteredTauSecondaries( eta )( eta_half )( phi )      := reference_TauSecondaries( eta )( eta_half )( MOD_PHI( ( 4 * phi ) + 1 ) );
            reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .eta := eta + cCMScoordinateOffset;
            reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .phi := MOD_PHI( ( 4 * phi ) + 1 ) + cCMScoordinateOffset;
          ELSIF( NOT reference_9x3Veto( eta )( eta_half )( ( 4 * phi ) + 2 ) .Data ) THEN
            reference_FilteredTauSecondaries( eta )( eta_half )( phi )      := reference_TauSecondaries( eta )( eta_half )( MOD_PHI( ( 4 * phi ) + 2 ) );
            reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .eta := eta + cCMScoordinateOffset;
            reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .phi := MOD_PHI( ( 4 * phi ) + 2 ) + cCMScoordinateOffset;
          ELSIF( NOT reference_9x3Veto( eta )( eta_half )( ( 4 * phi ) + 3 ) .Data ) THEN
            reference_FilteredTauSecondaries( eta )( eta_half )( phi )      := reference_TauSecondaries( eta )( eta_half )( MOD_PHI( ( 4 * phi ) + 3 ) );
            reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .eta := eta + cCMScoordinateOffset;
            reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .phi := MOD_PHI( ( 4 * phi ) + 3 ) + cCMScoordinateOffset;
          ELSE
            reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .eta       := eta + cCMScoordinateOffset;
            reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .DataValid := True;
          END IF;

        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
  FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
    FOR eta_half IN 0 TO cRegionInEta-1 LOOP
      FOR eta IN 0 TO( reference_TauProtoCluster'LENGTH - 1 ) LOOP

        reference_TauProtoCluster( eta )( eta_half )( phi ) := reference_FilteredProtoClusters( eta )( eta_half )( phi );

-- Map data to LUT inputs
        Trimming( 7 DOWNTO 5 )                              := TO_UNSIGNED( reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .TauSite , 3 );
        Trimming( 4 )                                       := TO_STD_LOGIC( reference_FilteredProtoClusters( eta )( eta_half )( phi ) .LateralPosition = west );
        Trimming( 3 )                                       := reference_FilteredProtoClusters( eta )( eta_half )( phi ) .TrimmingFlags( 6 );
        Trimming( 2 )                                       := reference_FilteredProtoClusters( eta )( eta_half )( phi ) .TrimmingFlags( 5 );
        Trimming( 1 )                                       := reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .TrimmingFlags( 6 );
        Trimming( 0 )                                       := reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .TrimmingFlags( 5 );

-- Run the LUT
        IF reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .HasSeed THEN
          reference_TauProtoCluster( eta )( eta_half )( phi ) .TrimmingFlags := FlagTrimLUT_8to7( TO_INTEGER( Trimming ) ) AND reference_FilteredProtoClusters( eta )( eta_half )( phi ) .TrimmingFlags;
        ELSE
          reference_TauProtoCluster( eta )( eta_half )( phi ) .TrimmingFlags := reference_FilteredProtoClusters( eta )( eta_half )( phi ) .TrimmingFlags;
        END IF;

      END LOOP;
    END LOOP;
  END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
  FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
    FOR eta_half IN 0 TO cRegionInEta-1 LOOP
      FOR eta IN 0 TO( reference_TauPrimary'LENGTH - 1 ) LOOP
        reference_TauPrimary( eta )( eta_half )( phi ) := CLUSTER( reference_ClusterInput( eta )( eta_half )( phi ) , reference_TauProtoCluster( eta )( eta_half )( phi ) );
      END LOOP;
    END LOOP;
  END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta IN 0 TO( reference_finalTau'LENGTH - 1 ) LOOP
        FOR eta_half IN 0 TO cRegionInEta-1 LOOP
          reference_finalTau( eta )( eta_half )( phi )              := reference_TauPrimary( eta )( eta_half )( phi );
          reference_finalTau( eta )( eta_half )( phi ) .NoSecondary := reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .NoSecondary;
          reference_finalTau( eta )( eta_half )( phi ) .HasEM       := reference_TauPrimary( eta )( eta_half )( phi ) .HasEM OR reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .HasEM;
          reference_finalTau( eta )( eta_half )( phi ) .Energy      := reference_TauPrimary( eta )( eta_half )( phi ) .Energy + reference_FilteredTauSecondaries( eta )( eta_half )( phi ) .Energy;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta IN 0 TO( reference_TauIsolationRegion'LENGTH - 1 ) LOOP
        FOR eta_half IN 0 TO cRegionInEta-1 LOOP

          IntEnergy := TO_INTEGER( reference_Isolation9x6( eta )( eta_half )( phi ) .Energy ) - TO_INTEGER( reference_finalTau( eta )( eta_half )( phi ) .Energy );

          IF IntEnergy < 0 THEN
            reference_TauIsolationRegion( eta )( eta_half )( phi ) .Energy := ( OTHERS => '0' );
          ELSE
            reference_TauIsolationRegion( eta )( eta_half )( phi ) .Energy := TO_UNSIGNED( IntEnergy , 16 );
          END IF;

          reference_TauIsolationRegion( eta )( eta_half )( phi ) .DataValid := True;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------





-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta IN 0 TO( reference_finalTau'LENGTH - 1 ) LOOP
        FOR eta_half IN 0 TO cRegionInEta-1 LOOP

          IF( reference_finalTau( eta )( eta_half )( phi ) .Energy > x"100" ) THEN
            Energy( 7 DOWNTO 0 ) := "11111111";
          ELSE
            Energy( 7 DOWNTO 0 ) := reference_finalTau( eta )( eta_half )( phi ) .Energy( 7 DOWNTO 0 );
          END IF;

          reference_CalibratedTau( eta )( eta_half )( phi ) := reference_finalTau( eta )( eta_half )( phi );

          TauMultiplier                                     := UNSIGNED( I_TauCalibration_11to18( TO_INTEGER(
                                                                      reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta2
                                                                      & UNSIGNED( F_TauEnergyCompression_8to5( TO_INTEGER( Energy( 7 DOWNTO 0 ) ) ) )
                                                                      & TO_STD_LOGIC( reference_finalTau( eta )( eta_half )( phi ) .HasEM )
                                                                      & TO_STD_LOGIC( NOT reference_finalTau( eta )( eta_half )( phi ) .NoSecondary )
                                                              ) )( 9 DOWNTO 0 ) );

          TauOffset := SIGNED( I_TauCalibration_11to18( TO_INTEGER(
                                                                      reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta2
                                                                      & UNSIGNED( F_TauEnergyCompression_8to5( TO_INTEGER( Energy( 7 DOWNTO 0 ) ) ) )
                                                                      & TO_STD_LOGIC( reference_finalTau( eta )( eta_half )( phi ) .HasEM )
                                                                      & TO_STD_LOGIC( NOT reference_finalTau( eta )( eta_half )( phi ) .NoSecondary )
                                                              ) )( 17 DOWNTO 10 ) );


          TempEnergy := SIGNED( SHIFT_RIGHT( ( reference_finalTau( eta )( eta_half )( phi ) .Energy * TauMultiplier ) , 9 ) ) + TauOffset;

          IF TempEnergy( 22 DOWNTO 12 ) /= "00000000000" THEN
            reference_CalibratedTau( eta )( eta_half )( phi ) .Energy( 11 DOWNTO 0 ) := ( OTHERS => '1' );
          ELSE
            reference_CalibratedTau( eta )( eta_half )( phi ) .Energy( 11 DOWNTO 0 ) := UNSIGNED( TempEnergy( 11 DOWNTO 0 ) );
          END IF;


          TauIsolationThreshold := UNSIGNED( H_TauIsolation_12to9( TO_INTEGER(
                                            reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta2
                                            & UNSIGNED( F_TauEnergyCompression_8to5( TO_INTEGER( Energy( 7 DOWNTO 0 ) ) ) )
                                            & reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .towerCount
                                    ) )( 7 DOWNTO 0 ) );

          TauIsolationFlag := H_TauIsolation_12to9( TO_INTEGER(
                                            reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta2
                                            & UNSIGNED( F_TauEnergyCompression_8to5( TO_INTEGER( Energy( 7 DOWNTO 0 ) ) ) )
                                            & reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .towerCount
                                    ) )( 8 );

          reference_CalibratedTau( eta )( eta_half )( phi ) .Isolated := ( reference_TauIsolationRegion( eta )( eta_half )( phi ) .Energy < TauIsolationThreshold )
                                                                      OR ( TauIsolationFlag = '1' );

          TauIsolationThreshold := UNSIGNED( H_TauIsolation2_12to9( TO_INTEGER(
                                            reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta2
                                            & UNSIGNED( F_TauEnergyCompression_8to5( TO_INTEGER( Energy( 7 DOWNTO 0 ) ) ) )
                                            & reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .towerCount
                                    ) )( 7 DOWNTO 0 ) );

          TauIsolationFlag := H_TauIsolation_12to9( TO_INTEGER(
                                            reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta2
                                            & UNSIGNED( F_TauEnergyCompression_8to5( TO_INTEGER( Energy( 7 DOWNTO 0 ) ) ) )
                                            & reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .towerCount
                                    ) )( 8 );

          reference_CalibratedTau( eta )( eta_half )( phi ) .Isolated2 := ( reference_TauIsolationRegion( eta )( eta_half )( phi ) .Energy < TauIsolationThreshold )
                                                                       OR ( TauIsolationFlag = '1' );
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta IN 0 TO( reference_sortedTau'LENGTH - 1 ) LOOP
      FOR eta_half IN 0 TO cRegionInEta-1 LOOP
        reference_sortedTau( eta )( eta_half ) := reference_CalibratedTau( eta )( eta_half );
        CLUSTER_BITONIC_SORT( reference_sortedTau( eta )( eta_half )( 0 TO( cTowerInPhi / 4 ) -1 ) , 0 , ( cTowerInPhi / 4 ) , false );
        reference_sortedTau( eta )( eta_half )( 6 TO( cTowerInPhi / 4 ) -1 ) := ( OTHERS => cEmptyCluster );
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO( cRegionInEta-1 ) LOOP
      reference_accumulatedSortedTau( 0 )( eta_half )( 0 TO 5 ) := reference_sortedTau( 0 )( eta_half )( 0 TO 5 );
      FOR eta IN 1 TO( reference_accumulatedSortedTau'LENGTH - 1 ) LOOP
        reference_accumulatedSortedTau( eta )( eta_half )( 0 TO 5 )  := reference_accumulatedSortedTau( eta-1 )( eta_half )( 0 TO 5 );
        reference_accumulatedSortedTau( eta )( eta_half )( 6 TO 11 ) := reference_sortedTau( eta )( eta_half )( 0 TO 5 );
        CLUSTER_BITONIC_SORT( reference_accumulatedSortedTau( eta )( eta_half )( 0 TO( cTowerInPhi / 4 ) -1 ) , 0 , 12 , false );
        reference_accumulatedSortedTau( eta )( eta_half )( 6 TO( cTowerInPhi / 4 ) -1 ) := ( OTHERS => cEmptyCluster );
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO( cRegionInEta-1 ) LOOP
      FOR eta IN 0 TO( reference_accumulatedSortedTau'LENGTH - 1 ) LOOP
        FOR candidate IN 0 TO 5 LOOP
          reference_TauPackedLink( eta )( ( 6 * eta_half ) + candidate ) .Data := STD_LOGIC_VECTOR( reference_accumulatedSortedTau( eta )( eta_half )( candidate ) .Energy( 11 DOWNTO 0 ) ) &
                                                                                  encodeVerticalPosition( reference_accumulatedSortedTau( eta )( eta_half )( candidate ) .VerticalPosition ) &
                                                                                  encodeLateralPosition( reference_accumulatedSortedTau( eta )( eta_half )( candidate ) .LateralPosition ) &
                                                                                  STD_LOGIC_VECTOR( TO_UNSIGNED( reference_accumulatedSortedTau( eta )( eta_half )( candidate ) .Phi , 7 ) ) &
                                                                                  STD_LOGIC_VECTOR( TO_UNSIGNED( reference_accumulatedSortedTau( eta )( eta_half )( candidate ) .Eta , 6 ) ) &
                                                                                  TO_STD_LOGIC( reference_accumulatedSortedTau( eta )( eta_half )( candidate ) .Isolated2 ) &
                                                                                  TO_STD_LOGIC( reference_accumulatedSortedTau( eta )( eta_half )( candidate ) .Isolated ) &
                                                                                  '0';
          reference_TauPackedLink( eta )( ( 6 * eta_half ) + candidate ) .AccumulationComplete := ( eta = ( reference_accumulatedSortedTau'LENGTH - 1 ) );
          reference_TauPackedLink( eta )( ( 6 * eta_half ) + candidate ) .DataValid            := reference_accumulatedSortedTau( eta )( eta_half )( candidate ) .DataValid;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO( cRegionInEta-1 ) LOOP
      FOR index IN 0 TO 5 LOOP
        reference_demuxAccumulatedSortedTau( 0 )( eta_half )( index )                  := reference_accumulatedSortedTau( reference_accumulatedSortedTau'LENGTH - 1 )( eta_half )( index );
        reference_demuxAccumulatedSortedTau( 0 )( eta_half )( index ) .TrimmingFlags   := ( OTHERS => '0' );
        reference_demuxAccumulatedSortedTau( 0 )( eta_half )( index ) .ShapeFlags      := ( OTHERS => '0' );
        reference_demuxAccumulatedSortedTau( 0 )( eta_half )( index ) .HasSeed         := FALSE;
        reference_demuxAccumulatedSortedTau( 0 )( eta_half )( index ) .EgammaCandidate := FALSE;
        reference_demuxAccumulatedSortedTau( 0 )( eta_half )( index ) .HasEM           := FALSE;
        reference_demuxAccumulatedSortedTau( 0 )( eta_half )( index ) .NoSecondary     := FALSE;
        reference_demuxAccumulatedSortedTau( 0 )( eta_half )( index ) .TauSite         := 0;
        reference_demuxAccumulatedSortedTau( 0 )( eta_half )( index ) .EtaHalf         := eta_half;
      END LOOP;

    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    reference_mergedSortedTau( 0 )( 0 )( 0 TO 5 )  := reference_demuxAccumulatedSortedTau( 0 )( 0 )( 0 TO 5 );
    reference_mergedSortedTau( 0 )( 0 )( 6 TO 11 ) := reference_demuxAccumulatedSortedTau( 0 )( 1 )( 0 TO 5 );
    CLUSTER_BITONIC_SORT( reference_mergedSortedTau( 0 )( 0 )( 0 TO( cTowerInPhi / 4 ) -1 ) , 0 , 12 , false );
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO 11 LOOP
      IF( reference_mergedSortedTau( 0 )( 0 )( index ) .EtaHalf = 1 ) THEN
        reference_GtFormattedTau( 0 )( index ) .Eta := SIGNED( Y_localEtaToGT_9to8(
          TO_INTEGER( '1' & TO_UNSIGNED( reference_mergedSortedTau( 0 )( 0 )( index ) .Eta , 6 ) & UNSIGNED( encodeLateralPosition( reference_mergedSortedTau( 0 )( 0 )( index ) .LateralPosition ) ) )
        ) );
      ELSE
        reference_GtFormattedTau( 0 )( index ) .Eta := SIGNED( Y_localEtaToGT_9to8(
          TO_INTEGER( '0' & TO_UNSIGNED( reference_mergedSortedTau( 0 )( 0 )( index ) .Eta , 6 ) & UNSIGNED( encodeLateralPosition( reference_mergedSortedTau( 0 )( 0 )( index ) .LateralPosition ) ) )
        ) );
      END IF;

      reference_GtFormattedTau( 0 )( index ) .Phi := UNSIGNED( Z_localPhiToGT_9to8(
        TO_INTEGER( TO_UNSIGNED( reference_mergedSortedTau( 0 )( 0 )( index ) .Phi , 7 ) & UNSIGNED( encodeVerticalPosition( reference_mergedSortedTau( 0 )( 0 )( index ) .VerticalPosition ) ) )
      ) );

      IF reference_mergedSortedTau( 0 )( 0 )( index ) .Energy > x"01FF" THEN
        reference_GtFormattedTau( 0 )( index ) .Energy := ( OTHERS => '1' );
      ELSE
        reference_GtFormattedTau( 0 )( index ) .Energy := reference_mergedSortedTau( 0 )( 0 )( index ) .Energy( 8 DOWNTO 0 ) ; -- We saturate at output of MP
      END IF;

      reference_GtFormattedTau( 0 )( index ) .Isolated2 := reference_mergedSortedTau( 0 )( 0 )( index ) .Isolated2;
      reference_GtFormattedTau( 0 )( index ) .Isolated  := reference_mergedSortedTau( 0 )( 0 )( index ) .Isolated;

      reference_GtFormattedTau( 0 )( index ) .DataValid := reference_mergedSortedTau( 0 )( 0 )( index ) .DataValid;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO 11 LOOP
      reference_DemuxTauPackedLink( 0 )( index ) .Data := "00000" &
                                                          TO_STD_LOGIC( reference_GtFormattedTau( 0 )( index ) .Isolated2 ) &
                                                          TO_STD_LOGIC( reference_GtFormattedTau( 0 )( index ) .Isolated ) &
                                                          STD_LOGIC_VECTOR( reference_GtFormattedTau( 0 )( index ) .Phi ) &
                                                          STD_LOGIC_VECTOR( reference_GtFormattedTau( 0 )( index ) .Eta ) &
                                                          STD_LOGIC_VECTOR( reference_GtFormattedTau( 0 )( index ) .Energy );
      reference_DemuxTauPackedLink( 0 )( index ) .DataValid := reference_GtFormattedTau( 0 )( index ) .DataValid;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


  END TauReference;



  PROCEDURE TauChecker
  (
    VARIABLE clk_count                           : IN INTEGER;
    CONSTANT timeout                             : IN INTEGER;
-- -------------
    VARIABLE reference_TauSecondaries            : IN tClusterPipe;
    SIGNAL TauSecondariesPipe                    : IN tClusterPipe;
    VARIABLE retvalTauSecondaries                : INOUT tRetVal;
-- -------------
    VARIABLE reference_FilteredTauSecondaries    : IN tClusterPipe;
    SIGNAL FilteredTauPipe                       : IN tClusterPipe;
    VARIABLE retvalFilteredTauSecondaries        : INOUT tRetVal;
-- -------------
    VARIABLE reference_TauProtoCluster           : IN tClusterPipe;
    SIGNAL TauProtoClusterPipe                   : IN tClusterPipe;
    VARIABLE retvalTauProtoCluster               : INOUT tRetVal;
-- -------------
    VARIABLE reference_TauPrimary                : IN tClusterPipe;
    SIGNAL TauPrimaryPipe                        : IN tClusterPipe;
    VARIABLE retvalTauPrimary                    : INOUT tRetVal;
-- -------------
    VARIABLE reference_FinalTau                  : IN tClusterPipe;
    SIGNAL FinalTauPipe                          : IN tClusterPipe;
    VARIABLE retvalFinalTau                      : INOUT tRetVal;
-- -------------
    VARIABLE reference_TauIsolationRegion        : IN tIsolationRegionPipe;
    SIGNAL TauIsolationRegionPipe                : IN tIsolationRegionPipe;
    VARIABLE retvalTauIsolationRegion            : INOUT tRetVal;
-- -------------
    VARIABLE reference_CalibratedTau             : IN tClusterPipe;
    SIGNAL CalibratedTauPipe                     : IN tClusterPipe;
    VARIABLE retvalCalibratedTau                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_sortedTau                 : IN tClusterPipe;
    SIGNAL SortedTauPipe                         : IN tClusterPipe;
    VARIABLE retvalSortedTau                     : INOUT tRetVal;
-- -------------
    VARIABLE reference_accumulatedSortedTau      : IN tClusterPipe;
    SIGNAL accumulatedSortedTauPipe              : IN tClusterPipe;
    VARIABLE retvalAccumulatedSortedTau          : INOUT tRetVal;
-------------
    VARIABLE reference_TauPackedLink             : IN tPackedLinkPipe;
    SIGNAL TauPackedLinkPipe                     : IN tPackedLinkPipe;
    VARIABLE retvalTauPackedLink                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedSortedTau : IN tClusterPipe;
    SIGNAL demuxAccumulatedSortedTauPipe         : IN tClusterPipe;
    VARIABLE retvalDemuxAccumulatedSortedTau     : INOUT tRetVal;
-- -------------
    VARIABLE reference_mergedSortedTau           : IN tClusterPipe;
    SIGNAL mergedSortedTauPipe                   : IN tClusterPipe;
    VARIABLE retvalMergedSortedTau               : INOUT tRetVal;
-- -------------
    VARIABLE reference_GtFormattedTau            : IN tGtFormattedClusterPipe;
    SIGNAL GtFormattedTauPipe                    : IN tGtFormattedClusterPipe;
    VARIABLE retvalGtFormattedTau                : INOUT tRetVal;
-------------
    VARIABLE reference_DemuxTauPackedLink        : IN tPackedLinkPipe;
    SIGNAL DemuxTauPackedLinkPipe                : IN tPackedLinkPipe;
    VARIABLE retvalDemuxTauPackedLink            : INOUT tRetVal;
-- -------------
    CONSTANT debug                               : IN BOOLEAN := false
-- -------------
  ) IS BEGIN

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_TauSecondaries'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Tau Secondaries" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_TauSecondaries , -- expected latency
                    timeout , -- timeout
                    retvalTauSecondaries( index ) , -- return value
                    ( reference_TauSecondaries( index ) = TauSecondariesPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_FilteredTauSecondaries'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Filtered Tau Secondaries" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_FilteredTauSecondaries , -- expected latency
                    timeout , -- timeout
                    retvalFilteredTauSecondaries( index ) , -- return value
                    ( reference_FilteredTauSecondaries( index ) = FilteredTauPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_TauProtoCluster'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Tau ProtoCluster" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_TauProtoCluster , -- expected latency
                    timeout , -- timeout
                    retvalTauProtoCluster( index ) , -- return value
                    ( reference_TauProtoCluster( index ) = TauProtoClusterPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_TauPrimary'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Tau Cluster" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_TauPrimary , -- expected latency
                    timeout , -- timeout
                    retvalTauPrimary( index ) , -- return value
                    ( reference_TauPrimary( index ) = TauPrimaryPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_FinalTau'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Final Tau" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_FinalTau , -- expected latency
                    timeout , -- timeout
                    retvalFinalTau( index ) , -- return value
                    ( reference_FinalTau( index ) = FinalTauPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_TauIsolationRegion'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Tau Isolation Regions" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_TauIsolationRegion , -- expected latency
                    timeout , -- timeout
                    retvalTauIsolationRegion( index ) , -- return value
                    ( reference_TauIsolationRegion( index ) = TauIsolationRegionPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_CalibratedTau'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Calibrated Tau" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_CalibratedTau , -- expected latency
                    timeout , -- timeout
                    retvalCalibratedTau( index ) , -- return value
                    ( reference_CalibratedTau( index ) = CalibratedTauPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_sortedTau'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Sorted Taus" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_SortedTau , -- expected latency
                    timeout , -- timeout
                    retvalSortedTau( index ) , -- return value
                    ( reference_sortedTau( index ) = SortedTauPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_accumulatedSortedTau'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Accumulated Sorted Taus" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_accumulatedSortedTau , -- expected latency
                    timeout , -- timeout
                    retvalAccumulatedSortedTau( index ) , -- return value
                    ( reference_accumulatedSortedTau( index ) = accumulatedSortedTauPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_TauPackedLink'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Tau Packed Link" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_TauPackedLink , -- expected latency
                    timeout , -- timeout
                    retvalTauPackedLink( index ) , -- return value
                    ( reference_TauPackedLink( index ) = TauPackedLinkPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_demuxAccumulatedSortedTau'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux Accumulated Sorted Taus" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_demuxAccumulatedSortedTaus , -- expected latency
                    timeout , -- timeout
                    retvalDemuxAccumulatedSortedTau( index ) , -- return value
                    ( reference_demuxAccumulatedSortedTau( index ) = demuxAccumulatedSortedTauPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_MergedSortedTau'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Merged Sorted Taus" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_MergedSortedTaus , -- expected latency
                    timeout , -- timeout
                    retvalMergedSortedTau( index ) , -- return value
                    reference_MergedSortedTau( index ) = MergedSortedTauPipe( 0 ) , -- test condition
                    debug
    );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_GtFormattedTau'LENGTH - 1 ) LOOP
      CHECK_RESULT( "GT Formatted Taus" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_GtFormattedTaus , -- expected latency
                    timeout , -- timeout
                    retvalGtFormattedTau( index ) , -- return value
                    ( reference_GtFormattedTau( index ) = GtFormattedTauPipe( 0 ) ) , -- test condition
                    debug
    );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_DemuxTauPackedLink'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux Tau Packed Link" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_DemuxTauPackedLink , -- expected latency
                    timeout , -- timeout
                    retvalDemuxTauPackedLink( index ) , -- return value
                    ( reference_DemuxTauPackedLink( index ) = DemuxTauPackedLinkPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

  END TauChecker;



  PROCEDURE TauDebug
  (
    VARIABLE clk_count                : IN INTEGER;
    SIGNAL TauSecondariesPipe         : IN tClusterPipe;
    SIGNAL FilteredTauSecondariesPipe : IN tClusterPipe;
    SIGNAL TauProtoClusterPipe        : IN tClusterPipe;
    SIGNAL TauPrimaryPipe             : IN tClusterPipe;
    SIGNAL FinalTauPipe               : IN tClusterPipe;
    SIGNAL TauIsolationRegionPipe     : IN tIsolationRegionPipe;
    SIGNAL CalibratedTauPipe          : IN tClusterPipe;
    SIGNAL SortedTauPipe              : IN tClusterPipe;
    SIGNAL accumulatedSortedTauPipe   : IN tClusterPipe;
    CONSTANT debug                    : IN BOOLEAN := false
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    IF debug THEN
      OutputCandidate( clk_count , latency_TauSecondaries , TauSecondariesPipe( 0 ) , TauSecondariesFile );
      OutputCandidate( clk_count , latency_FilteredTauSecondaries , FilteredTauSecondariesPipe( 0 ) , FilteredTauSecondariesFile );
      OutputCandidate( clk_count , latency_TauProtoCluster , TauProtoClusterPipe( 0 ) , TauProtoClusterFile );
      OutputCandidate( clk_count , latency_TauPrimary , TauPrimaryPipe( 0 ) , TauPrimaryFile );
      OutputCandidate( clk_count , latency_FinalTau , FinalTauPipe( 0 ) , FinalTauFile );
      OutputCandidate( clk_count , latency_TauIsolationRegion , TauIsolationRegionPipe( 0 ) , TauIsolationFile );
      OutputCandidate( clk_count , latency_CalibratedTau , CalibratedTauPipe( 0 ) , CalibratedTauFile );
      OutputCandidate( clk_count , latency_SortedTau , SortedTauPipe( 0 ) , SortedTauFile );
      OutputCandidate( clk_count , latency_accumulatedSortedTau , accumulatedSortedTauPipe( 0 ) , accumulatedSortedTauFile );
    END IF;
-- -----------------------------------------------------------------------------------------------------
  END TauDebug;


  PROCEDURE TauReport
  (
    VARIABLE retvalTauSecondaries            : IN tRetVal;
    VARIABLE retvalFilteredTauSecondaries    : IN tRetVal;
    VARIABLE retvalTauProtoCluster           : IN tRetVal;
    VARIABLE retvalTauPrimary                : IN tRetVal;
    VARIABLE retvalFinalTau                  : IN tRetVal;
    VARIABLE retvalTauIsolationRegion        : IN tRetVal;
    VARIABLE retvalCalibratedTau             : IN tRetVal;
    VARIABLE retvalSortedTau                 : IN tRetVal;
    VARIABLE retvalAccumulatedSortedTau      : IN tRetVal;
    VARIABLE retvalTauPackedLink             : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedSortedTau : IN tRetVal;
    VARIABLE retvalMergedSortedTau           : IN tRetVal;
    VARIABLE retvalGtFormattedTau            : IN tRetVal;
    VARIABLE retvalDemuxTauPackedLink        : IN tRetVal
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    REPORT_RESULT( "Tau Secondaries" , retvalTauSecondaries );
    REPORT_RESULT( "Filtered Tau Secondaries" , retvalFilteredTauSecondaries );
    REPORT_RESULT( "Tau ProtoClusters" , retvalTauProtoCluster );
    REPORT_RESULT( "Tau Clusters" , retvalTauPrimary );
    REPORT_RESULT( "Final Tau" , retvalFinalTau );
    REPORT_RESULT( "Tau Isolation Regions" , retvalTauIsolationRegion );
    REPORT_RESULT( "Calibrated Tau" , retvalCalibratedTau );
    REPORT_RESULT( "Sorted Taus" , retvalSortedTau );
    REPORT_RESULT( "Accumulated Sorted Taus" , retvalAccumulatedSortedTau );
    REPORT_RESULT( "Tau Packed Link" , retvalTauPackedLink );
    REPORT_RESULT( "Demux Accumulated Sorted Taus" , retvalDemuxAccumulatedSortedTau );
    REPORT_RESULT( "Merged Sorted Taus" , retvalMergedSortedTau );
    REPORT_RESULT( "GT Formatted Taus" , retvalGtFormattedTau );
    REPORT_RESULT( "Demux Tau Packed Link" , retvalDemuxTauPackedLink );
-- -----------------------------------------------------------------------------------------------------
  END TauReport;










  FUNCTION TauSecondaries( Eta : INTEGER ; Phi : INTEGER ; ProtoClusters : tClusterPipe ; TauVetos : tComparisonPipe ) RETURN tCluster IS
    VARIABLE DeltaEta          : INTEGER  := 0;
    VARIABLE N , S             : tCluster := cEmptyCluster;
  BEGIN

    IF Eta < 0 THEN
      DeltaEta := -1;
    ELSE
      DeltaEta := + 1;
    END IF;


    IF( GetCluster( Eta , Phi + 3 , ProtoClusters ) .HasSeed AND NOT GetVeto( Eta , Phi + 3 , TauVetos ) .Data ) THEN
      N         := GetCluster( Eta , Phi + 3 , ProtoClusters );
      N.TauSite := 0;
    ELSIF( GetCluster( Eta , Phi + 2 , ProtoClusters ) .HasSeed AND NOT GetVeto( Eta , Phi + 2 , TauVetos ) .Data AND GetCluster( Eta , Phi , ProtoClusters ) .TrimmingFlags( 5 ) ='0' ) THEN -- "has NN"
      N         := GetCluster( Eta , Phi + 2 , ProtoClusters );
      N.TauSite := 2;
    ELSIF( ( GetCluster( Eta-DeltaEta , Phi + 2 , ProtoClusters ) .HasSeed AND NOT GetVeto( Eta-DeltaEta , Phi + 2 , TauVetos ) .Data ) AND( GetCluster( Eta + DeltaEta , Phi + 2 , ProtoClusters ) .HasSeed AND NOT GetVeto( Eta + DeltaEta , Phi + 2 , TauVetos ) .Data ) ) THEN
      IF( GetCluster( Eta-DeltaEta , Phi + 2 , ProtoClusters ) .Energy >= GetCluster( Eta + DeltaEta , Phi + 2 , ProtoClusters ) .Energy ) THEN
        N         := GetCluster( Eta-DeltaEta , Phi + 2 , ProtoClusters );
        N.TauSite := 2-DeltaEta;
      ELSE
        N         := GetCluster( Eta + DeltaEta , Phi + 2 , ProtoClusters );
        N.TauSite := 2 + DeltaEta;
      END IF;
    ELSIF( GetCluster( Eta-1 , Phi + 2 , ProtoClusters ) .HasSeed AND NOT GetVeto( Eta-1 , Phi + 2 , TauVetos ) .Data ) THEN
      N         := GetCluster( Eta-1 , Phi + 2 , ProtoClusters );
      N.TauSite := 1;
    ELSIF( GetCluster( Eta + 1 , Phi + 2 , ProtoClusters ) .HasSeed AND NOT GetVeto( Eta + 1 , Phi + 2 , TauVetos ) .Data ) THEN
      N         := GetCluster( Eta + 1 , Phi + 2 , ProtoClusters );
      N.TauSite := 3;
    ELSE
      N.NoSecondary := TRUE;
      N.DataValid   := TRUE;
    END IF;

    IF( GetCluster( Eta , Phi-3 , ProtoClusters ) .HasSeed AND NOT GetVeto( Eta , Phi-3 , TauVetos ) .Data ) THEN
      S         := GetCluster( Eta , Phi-3 , ProtoClusters );
      S.TauSite := 7;
    ELSIF( GetCluster( Eta , Phi-2 , ProtoClusters ) .HasSeed AND NOT GetVeto( Eta , Phi-2 , TauVetos ) .Data AND GetCluster( Eta , Phi , ProtoClusters ) .TrimmingFlags( 6 ) ='0' ) THEN -- "has SS"
      S         := GetCluster( Eta , Phi-2 , ProtoClusters );
      S.TauSite := 5;
    ELSIF( ( GetCluster( Eta-DeltaEta , Phi-2 , ProtoClusters ) .HasSeed AND NOT GetVeto( Eta-DeltaEta , Phi-2 , TauVetos ) .Data ) AND( GetCluster( Eta + DeltaEta , Phi-2 , ProtoClusters ) .HasSeed AND NOT GetVeto( Eta + DeltaEta , Phi-2 , TauVetos ) .Data ) ) THEN
      IF( GetCluster( Eta-DeltaEta , Phi-2 , ProtoClusters ) .Energy >= GetCluster( Eta + DeltaEta , Phi-2 , ProtoClusters ) .Energy ) THEN
        S         := GetCluster( Eta-DeltaEta , Phi-2 , ProtoClusters );
        S.TauSite := 5-DeltaEta;
      ELSE
        S         := GetCluster( Eta + DeltaEta , Phi-2 , ProtoClusters );
        S.TauSite := 5 + DeltaEta;
      END IF;
    ELSIF( GetCluster( Eta-1 , Phi-2 , ProtoClusters ) .HasSeed AND NOT GetVeto( Eta-1 , Phi-2 , TauVetos ) .Data ) THEN
      S         := GetCluster( Eta-1 , Phi-2 , ProtoClusters );
      S.TauSite := 4;
    ELSIF( GetCluster( Eta + 1 , Phi-2 , ProtoClusters ) .HasSeed AND NOT GetVeto( Eta + 1 , Phi-2 , TauVetos ) .Data ) THEN
      S         := GetCluster( Eta + 1 , Phi-2 , ProtoClusters );
      S.TauSite := 6;
    ELSE
      S.NoSecondary := TRUE;
      S.DataValid   := TRUE;
    END IF;

    IF( N.Energy > S.Energy ) THEN
      RETURN N;
    ELSE
      RETURN S;
    END IF;
  END TauSecondaries;


END PACKAGE BODY TauReference;
