
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
PACKAGE EgammaReference IS

  CONSTANT latency_EgammaProtoCluster            : INTEGER := latency_FilteredProtoClusters + 1;
  CONSTANT latency_EgammaCluster                 : INTEGER := latency_EgammaProtoCluster + 4;

  CONSTANT latency_Isolation5x2                  : INTEGER := latency_egamma9x3Veto + 6;
  CONSTANT latency_EgammaIsolationRegion         : INTEGER := latency_Isolation5x2 + 1;
-- CONSTANT latency_EgammaIsolationFlag : INTEGER := latency_EgammaIsolationRegion + 1;

  CONSTANT latency_CalibratedEgamma              : INTEGER := latency_EgammaCluster + 5;
  CONSTANT latency_SortedEgamma                  : INTEGER := latency_CalibratedEgamma + 14;
  CONSTANT latency_accumulatedSortedEgamma       : INTEGER := latency_SortedEgamma + 8;
  CONSTANT latency_EgammaPackedLink              : INTEGER := latency_accumulatedSortedEgamma;

  CONSTANT latency_demuxAccumulatedSortedEgammas : INTEGER := latency_accumulatedSortedEgamma + cEcalTowersInHalfEta + 15;
  CONSTANT latency_mergedSortedEgammas           : INTEGER := latency_demuxAccumulatedSortedEgammas + 4;
  CONSTANT latency_GtFormattedEgammas            : INTEGER := latency_mergedSortedEgammas + 1;

  CONSTANT latency_DemuxEgammaPackedLink         : INTEGER := latency_GtFormattedEgammas;


  FILE Isolation5x2File                          : TEXT OPEN write_mode IS "IntermediateSteps/Isolation5x2Pipe.txt";
  FILE EgammaIsolationFile                       : TEXT OPEN write_mode IS "IntermediateSteps/EgammaIsolationRegionPipe.txt";
  FILE ClusterPileupEstimationFile               : TEXT OPEN write_mode IS "IntermediateSteps/ClusterPileupEstimationPipe.txt";

  FILE EgammaProtoClusterFile                    : TEXT OPEN write_mode IS "IntermediateSteps/EgammaProtoClusterPipe.txt";
  FILE EgammaClusterFile                         : TEXT OPEN write_mode IS "IntermediateSteps/EgammaClusterPipe.txt";
  FILE CalibratedEgammaFile                      : TEXT OPEN write_mode IS "IntermediateSteps/CalibratedEgammaClusterPipe.txt";
  FILE SortedEgammaFile                          : TEXT OPEN write_mode IS "IntermediateSteps/SortedEgammaPipe.txt";
  FILE accumulatedSortedEgammaFile               : TEXT OPEN write_mode IS "IntermediateSteps/AccumulatedSortedEgammaPipe.txt";



  PROCEDURE EgammaReference
  (
    VARIABLE reference_Towers                       : IN tTowerPipe;
    VARIABLE reference_3x3Veto                      : IN tComparisonPipe;
    VARIABLE reference_9x3Veto                      : IN tComparisonPipe;
    VARIABLE reference_TowerThresholds              : IN tTowerFlagsPipe;
    VARIABLE reference_FilteredProtoClusters        : IN tClusterPipe;
    VARIABLE reference_ClusterInput                 : IN tClusterInputPipe;

    VARIABLE reference_EgammaProtoCluster           : INOUT tClusterPipe;
    VARIABLE reference_EgammaCluster                : INOUT tClusterPipe;
    VARIABLE reference_Isolation9x6                 : IN tIsolationRegionPipe;
    VARIABLE reference_Isolation5x2                 : INOUT tIsolationRegionPipe;
    VARIABLE reference_EgammaIsolationRegion        : INOUT tIsolationRegionPipe;
    VARIABLE reference_ClusterPileupEstimation      : IN tPileupEstimationPipe;
-- VARIABLE reference_EgammaIsolationFlag : INOUT tComparisonPipe;
    VARIABLE reference_CalibratedEgamma             : INOUT tClusterPipe;
    VARIABLE reference_sortedEgamma                 : INOUT tClusterPipe;
    VARIABLE reference_accumulatedSortedEgamma      : INOUT tClusterPipe;
    VARIABLE reference_EgammaPackedLink             : INOUT tPackedLinkPipe;
    VARIABLE reference_demuxAccumulatedSortedEgamma : INOUT tClusterPipe;
    VARIABLE reference_mergedSortedEgamma           : INOUT tClusterPipe;
    VARIABLE reference_GtFormattedEgamma            : INOUT tGtFormattedClusterPipe;
    VARIABLE reference_DemuxEgammaPackedLink        : INOUT tPackedLinkPipe
  );


  PROCEDURE EgammaChecker
  (
    VARIABLE clk_count                              : IN INTEGER;
    CONSTANT timeout                                : IN INTEGER;
-- -------------
    VARIABLE reference_EgammaProtoCluster           : IN tClusterPipe;
    SIGNAL EgammaProtoClusterPipe                   : IN tClusterPipe;
    VARIABLE retvalEgammaProtoCluster               : INOUT tRetVal;
-- -------------
    VARIABLE reference_EgammaCluster                : IN tClusterPipe;
    SIGNAL EgammaClusterPipe                        : IN tClusterPipe;
    VARIABLE retvalEgammaCluster                    : INOUT tRetVal;
-- -------------
    VARIABLE reference_Isolation5x2                 : IN tIsolationRegionPipe;
    SIGNAL Isolation5x2Pipe                         : IN tIsolationRegionPipe;
    VARIABLE retvalIsolation5x2                     : INOUT tRetVal;
-- -------------
    VARIABLE reference_EgammaIsolationRegion        : IN tIsolationRegionPipe;
    SIGNAL EgammaIsolationRegionPipe                : IN tIsolationRegionPipe;
    VARIABLE retvalEgammaIsolationRegion            : INOUT tRetVal;
-- -------------
-- VARIABLE reference_ClusterPileupEstimation : IN tPileupEstimationPipe;
-- SIGNAL ClusterPileupEstimationPipe : IN tPileupEstimationPipe;
-- VARIABLE retvalClusterPileupEstimation : INOUT tRetVal;
---- -------------
-- VARIABLE reference_EgammaIsolationFlag : IN tComparisonPipe;
-- SIGNAL EgammaIsolationFlagPipe : IN tComparisonPipe;
-- VARIABLE retvalEgammaIsolationFlag : INOUT tRetVal;
-- -------------
    VARIABLE reference_CalibratedEgamma             : IN tClusterPipe;
    SIGNAL CalibratedEgammaPipe                     : IN tClusterPipe;
    VARIABLE retvalCalibratedEgamma                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_sortedEgamma                 : IN tClusterPipe;
    SIGNAL SortedEgammaPipe                         : IN tClusterPipe;
    VARIABLE retvalSortedEgamma                     : INOUT tRetVal;
-- -------------
    VARIABLE reference_accumulatedSortedEgamma      : IN tClusterPipe;
    SIGNAL accumulatedSortedEgammaPipe              : IN tClusterPipe;
    VARIABLE retvalAccumulatedSortedEgamma          : INOUT tRetVal;
-- -------------
    VARIABLE reference_EgammaPackedLink             : IN tPackedLinkPipe;
    SIGNAL EgammaPackedLinkPipe                     : IN tPackedLinkPipe;
    VARIABLE retvalEgammaPackedLink                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedSortedEgamma : IN tClusterPipe;
    SIGNAL demuxAccumulatedSortedEgammaPipe         : IN tClusterPipe;
    VARIABLE retvalDemuxAccumulatedSortedEgamma     : INOUT tRetVal;
-- -------------
    VARIABLE reference_mergedSortedEgamma           : IN tClusterPipe;
    SIGNAL mergedSortedEgammaPipe                   : IN tClusterPipe;
    VARIABLE retvalMergedSortedEgamma               : INOUT tRetVal;
-- -------------
    VARIABLE reference_GtFormattedEgamma            : IN tGtFormattedClusterPipe;
    SIGNAL GtFormattedEgammaPipe                    : IN tGtFormattedClusterPipe;
    VARIABLE retvalGtFormattedEgamma                : INOUT tRetVal;
-- -------------
    VARIABLE reference_DemuxEgammaPackedLink        : IN tPackedLinkPipe;
    SIGNAL DemuxEgammaPackedLinkPipe                : IN tPackedLinkPipe;
    VARIABLE retvalDemuxEgammaPackedLink            : INOUT tRetVal;
-- -------------
    CONSTANT debug                                  : IN BOOLEAN := false
-- -------------
  );


  PROCEDURE EgammaDebug
  (
    VARIABLE clk_count                 : IN INTEGER;
    SIGNAL Isolation5x2Pipe            : IN tIsolationRegionPipe;
    SIGNAL EgammaIsolationRegionPipe   : IN tIsolationRegionPipe;
    SIGNAL ClusterPileupEstimationPipe : IN tPileupEstimationPipe;
    SIGNAL EgammaProtoClusterPipe      : IN tClusterPipe;
    SIGNAL EgammaClusterPipe           : IN tClusterPipe;
    SIGNAL CalibratedEgammaPipe        : IN tClusterPipe;
    SIGNAL SortedEgammaPipe            : IN tClusterPipe;
    SIGNAL accumulatedSortedEgammaPipe : IN tClusterPipe;
    CONSTANT debug                     : IN BOOLEAN := false
  );

  PROCEDURE EgammaReport
  (
    VARIABLE retvalEgammaProtoCluster           : IN tRetVal;
    VARIABLE retvalEgammaCluster                : IN tRetVal;
    VARIABLE retvalIsolation5x2                 : IN tRetVal;
    VARIABLE retvalEgammaIsolationRegion        : IN tRetVal;
-- VARIABLE retvalClusterPileupEstimation : IN tRetVal;
-- VARIABLE retvalEgammaIsolationFlag : IN tRetVal;
    VARIABLE retvalCalibratedEgamma             : IN tRetVal;
    VARIABLE retvalSortedEgamma                 : IN tRetVal;
    VARIABLE retvalAccumulatedSortedEgamma      : IN tRetVal;
    VARIABLE retvalEgammaPackedLink             : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedSortedEgamma : IN tRetVal;
    VARIABLE retvalMergedSortedEgamma           : IN tRetVal;
    VARIABLE retvalGtFormattedEgamma            : IN tRetVal;
    VARIABLE retvalDemuxEgammaPackedLink        : IN tRetVal
  );

END PACKAGE EgammaReference;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------


-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
PACKAGE BODY EgammaReference IS

  PROCEDURE EgammaReference
  (
    VARIABLE reference_Towers                       : IN tTowerPipe;
    VARIABLE reference_3x3Veto                      : IN tComparisonPipe;
    VARIABLE reference_9x3Veto                      : IN tComparisonPipe;
    VARIABLE reference_TowerThresholds              : IN tTowerFlagsPipe;
    VARIABLE reference_FilteredProtoClusters        : IN tClusterPipe;
    VARIABLE reference_ClusterInput                 : IN tClusterInputPipe;

    VARIABLE reference_EgammaProtoCluster           : INOUT tClusterPipe;
    VARIABLE reference_EgammaCluster                : INOUT tClusterPipe;
    VARIABLE reference_Isolation9x6                 : IN tIsolationRegionPipe;
    VARIABLE reference_Isolation5x2                 : INOUT tIsolationRegionPipe;
    VARIABLE reference_EgammaIsolationRegion        : INOUT tIsolationRegionPipe;
    VARIABLE reference_ClusterPileupEstimation      : IN tPileupEstimationPipe;
-- VARIABLE reference_EgammaIsolationFlag : INOUT tComparisonPipe;
    VARIABLE reference_CalibratedEgamma             : INOUT tClusterPipe;
    VARIABLE reference_sortedEgamma                 : INOUT tClusterPipe;
    VARIABLE reference_accumulatedSortedEgamma      : INOUT tClusterPipe;
    VARIABLE reference_EgammaPackedLink             : INOUT tPackedLinkPipe;
    VARIABLE reference_demuxAccumulatedSortedEgamma : INOUT tClusterPipe;
    VARIABLE reference_mergedSortedEgamma           : INOUT tClusterPipe;
    VARIABLE reference_GtFormattedEgamma            : INOUT tGtFormattedClusterPipe;
    VARIABLE reference_DemuxEgammaPackedLink        : INOUT tPackedLinkPipe
  ) IS

    VARIABLE PileupEstimation : UNSIGNED( 6 DOWNTO 0 ) := ( OTHERS => '0' );

    TYPE mem_type_8to4 IS ARRAY( 0 TO( 2 ** 8 ) -1 ) OF STD_LOGIC_VECTOR( 3 DOWNTO 0 );
    VARIABLE FlagCompressLUTv2_8to4  : mem_type_8to4;
    VARIABLE TriggerCompressLUT_8to4 : mem_type_8to4;

    TYPE mem_type_12to7 IS ARRAY( 0 TO( 2 ** 12 ) -1 ) OF STD_LOGIC_VECTOR( 6 DOWNTO 0 );
    VARIABLE FlagTrimLUT_12to7 : mem_type_12to7;

    TYPE mem_type_13to9 IS ARRAY( 0 TO( 2 ** 13 ) -1 ) OF STD_LOGIC_VECTOR( 8 DOWNTO 0 );
    VARIABLE EgammaIsolThresholdLUT_13to9 : mem_type_13to9;

    TYPE mem_type_12to9 IS ARRAY( 0 TO( 2 ** 12 ) -1 ) OF STD_LOGIC_VECTOR( 8 DOWNTO 0 );
    VARIABLE IdentAndCorrectionLUT_12to9 : mem_type_12to9;

    TYPE mem_type_12to18 IS ARRAY( 0 TO( 2 ** 12 ) -1 ) OF STD_LOGIC_VECTOR( 17 DOWNTO 0 );
    VARIABLE IdentAndCorrectionLUT_12to18 : mem_type_12to18;

    TYPE mem_type_9to8 IS ARRAY( 0 TO( 2 ** 9 ) -1 ) OF STD_LOGIC_VECTOR( 7 DOWNTO 0 );
    VARIABLE Y_localEtaToGT_9to8 , Z_localPhiToGT_9to8 : mem_type_9to8;

    FILE RomFile                                       : TEXT;
    VARIABLE RomFileLine                               : LINE;
    VARIABLE TEMP                                      : CHARACTER;
    VARIABLE Value                                     : STD_LOGIC_VECTOR( 19 DOWNTO 0 );

    VARIABLE Trimming                                  : UNSIGNED( 11 DOWNTO 0 ) := ( OTHERS => '0' );
    VARIABLE Flags                                     : UNSIGNED( 7 DOWNTO 0 )  := ( OTHERS => '0' );
    VARIABLE Energy                                    : UNSIGNED( 8 DOWNTO 0 )  := ( OTHERS => '0' );
    VARIABLE EgammaShape                               : STD_LOGIC               := '0';
    VARIABLE EgammaMultiplier                          : UNSIGNED( 8 DOWNTO 0 )  := ( OTHERS => '0' );
    VARIABLE EgammaOffset                              : SIGNED( 7 DOWNTO 0 )    := ( OTHERS => '0' );
    VARIABLE EgammaIsolationThreshold                  : UNSIGNED( 7 DOWNTO 0 )  := ( OTHERS => '0' );
    VARIABLE EgammaIsolationFlag                       : STD_LOGIC               := '0';        
    VARIABLE TempEnergy                                : SIGNED( 21 DOWNTO 0 )   := ( OTHERS => '0' );
  BEGIN
-- -----------------------------------------------------------------------------------------------------
    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/N_EgammaTrimming_12to7.mif" ) , READ_MODE );
    FOR i IN FlagTrimLUT_12to7'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      FlagTrimLUT_12to7( i ) := Value( 7-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/D_EgammaIsolation_13to9.mif" ) , READ_MODE );
    FOR i IN EgammaIsolThresholdLUT_13to9'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      EgammaIsolThresholdLUT_13to9( i ) := Value( 9-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/O_EgammaShapeFlags_8to4.mif" ) , READ_MODE );
    FOR i IN FlagCompressLUTv2_8to4'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      FlagCompressLUTv2_8to4( i ) := Value( 4-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/B_EnergyCompression_8to4.mif" ) , READ_MODE );
    FOR i IN TriggerCompressLUT_8to4'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      TriggerCompressLUT_8to4( i ) := Value( 4-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/C_EgammaCalibration_12to18.mif" ) , READ_MODE );
    FOR i IN IdentAndCorrectionLUT_12to18'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      IdentAndCorrectionLUT_12to18( i ) := Value( 18-1 DOWNTO 0 );
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
  FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
    FOR eta_half IN 0 TO cRegionInEta-1 LOOP
      FOR eta IN 0 TO( reference_EgammaProtoCluster'LENGTH - 1 ) LOOP

        reference_EgammaProtoCluster( eta )( eta_half )( phi )                := reference_FilteredProtoClusters( eta )( eta_half )( phi );

-- Map data to LUT inputs
        Trimming( 11 DOWNTO 7 )                                               := TO_UNSIGNED( reference_FilteredProtoClusters( eta )( eta_half )( phi ) .Eta , 5 );
        Trimming( 6 DOWNTO 0 )                                                := UNSIGNED( reference_FilteredProtoClusters( eta )( eta_half )( phi ) .TrimmingFlags );
-- Run the LUT
        reference_EgammaProtoCluster( eta )( eta_half )( phi ) .TrimmingFlags := FlagTrimLUT_12to7( TO_INTEGER( Trimming( 11 DOWNTO 0 ) ) );

-- Map data to LUT inputs
        IF reference_FilteredProtoClusters( eta )( eta_half )( phi ) .LateralPosition = West THEN
          Trimming( 7 ) := '1';
        ELSE
          Trimming( 7 ) := '0';
        END IF;
-- Run the LUT
        reference_EgammaProtoCluster( eta )( eta_half )( phi ) .ShapeFlags := FlagCompressLUTv2_8to4( TO_INTEGER( Trimming( 7 DOWNTO 0 ) ) );

      END LOOP;
    END LOOP;
  END LOOP;
-- -- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
  FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
    FOR eta_half IN 0 TO cRegionInEta-1 LOOP
      FOR eta IN 0 TO( reference_EgammaCluster'LENGTH - 1 ) LOOP
        reference_EgammaCluster( eta )( eta_half )( phi ) := CLUSTER( reference_ClusterInput( eta )( eta_half )( phi ) , reference_EgammaProtoCluster( eta )( eta_half )( phi ) );
      END LOOP;
    END LOOP;
  END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta IN 0 TO( reference_Isolation5x2'LENGTH - 1 ) LOOP
        FOR eta_half IN 0 TO cRegionInEta-1 LOOP

          reference_Isolation5x2( eta )( eta_half )( phi ) .DataValid := TRUE;

          IF reference_FilteredProtoClusters( eta )( eta_half )( phi ) .LateralPosition = west THEN
            reference_Isolation5x2( eta )( eta_half )( phi ) .Energy := reference_Isolation5x2( eta )( eta_half )( phi ) .Energy +
                                                                        reference_ClusterInput( eta )( eta_half )( phi ) .R2NW.Ecal +
                                                                        reference_ClusterInput( eta )( eta_half )( phi ) .R1NW.Ecal +
                                                                        reference_ClusterInput( eta )( eta_half )( phi ) .R1W.Ecal +
                                                                        reference_ClusterInput( eta )( eta_half )( phi ) .R1SW.Ecal +
                                                                        reference_ClusterInput( eta )( eta_half )( phi ) .R2SW.Ecal;
          ELSE
            reference_Isolation5x2( eta )( eta_half )( phi ) .Energy := reference_Isolation5x2( eta )( eta_half )( phi ) .Energy +
                                                                        reference_ClusterInput( eta )( eta_half )( phi ) .R2NE.Ecal +
                                                                        reference_ClusterInput( eta )( eta_half )( phi ) .R1NE.Ecal +
                                                                        reference_ClusterInput( eta )( eta_half )( phi ) .R1E.Ecal +
                                                                        reference_ClusterInput( eta )( eta_half )( phi ) .R1SE.Ecal +
                                                                        reference_ClusterInput( eta )( eta_half )( phi ) .R2SE.Ecal;
          END IF;
        END LOOP;

        reference_Isolation5x2( eta )( 0 )( phi ) .Energy := reference_Isolation5x2( eta )( 0 )( phi ) .Energy +
                                                             reference_ClusterInput( eta )( 0 )( phi ) .R2N.Ecal +
                                                             reference_ClusterInput( eta )( 0 )( phi ) .R1N.Energy +
                                                             reference_ClusterInput( eta )( 0 )( phi ) .Centre.Energy +
                                                             reference_ClusterInput( eta )( 0 )( phi ) .R1S.Ecal +
                                                             reference_ClusterInput( eta )( 0 )( phi ) .R2S.Ecal;

        reference_Isolation5x2( eta )( 1 )( phi ) .Energy := reference_Isolation5x2( eta )( 1 )( phi ) .Energy +
                                                             reference_ClusterInput( eta )( 1 )( phi ) .R2N.Ecal +
                                                             reference_ClusterInput( eta )( 1 )( phi ) .R1N.Ecal +
                                                             reference_ClusterInput( eta )( 1 )( phi ) .Centre.Energy +
                                                             reference_ClusterInput( eta )( 1 )( phi ) .R1S.Energy +
                                                             reference_ClusterInput( eta )( 1 )( phi ) .R2S.Ecal;

      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta IN 0 TO( reference_EgammaIsolationRegion'LENGTH - 1 ) LOOP
        FOR eta_half IN 0 TO cRegionInEta-1 LOOP
          reference_EgammaIsolationRegion( eta )( eta_half )( phi ) .Energy    := reference_Isolation9x6( eta )( eta_half )( phi ) .Energy - reference_Isolation5x2( eta )( eta_half )( phi ) .Energy;
          reference_EgammaIsolationRegion( eta )( eta_half )( phi ) .DataValid := True;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------




-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta_half IN 0 TO cRegionInEta-1 LOOP
        FOR eta IN 0 TO( reference_CalibratedEgamma'LENGTH - 1 ) LOOP

          IF reference_EgammaCluster( eta )( eta_half )( phi ) .LateralPosition = West THEN
            Flags( 7 ) := '1';
          ELSE
            Flags( 7 ) := '0';
          END IF;

          Flags( 6 DOWNTO 0 ) := UNSIGNED( reference_EgammaCluster( eta )( eta_half )( phi ) .TrimmingFlags( 6 DOWNTO 0 ) );


          IF( reference_EgammaCluster( eta )( eta_half )( phi ) .Energy >= x"100" ) THEN
            Energy( 7 DOWNTO 0 ) := "11111111";
          ELSE
            Energy( 7 DOWNTO 0 ) := reference_EgammaCluster( eta )( eta_half )( phi ) .Energy( 7 DOWNTO 0 );
          END IF;

          EgammaMultiplier := UNSIGNED( IdentAndCorrectionLUT_12to18( TO_INTEGER(
                                                                      reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta4a
                                                                      & UNSIGNED( TriggerCompressLUT_8to4( TO_INTEGER( Energy( 7 DOWNTO 0 ) ) ) )
                                                                      & UNSIGNED( reference_EgammaCluster( eta )( eta_half )( phi ) .ShapeFlags )
                                                              ) )( 8 DOWNTO 0 ) );

          EgammaShape := IdentAndCorrectionLUT_12to18( TO_INTEGER(
                                                                      reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta4a
                                                                      & UNSIGNED( TriggerCompressLUT_8to4( TO_INTEGER( Energy( 7 DOWNTO 0 ) ) ) )
                                                                      & UNSIGNED( reference_EgammaCluster( eta )( eta_half )( phi ) .ShapeFlags )
                                                              ) )( 9 );

          EgammaOffset := SIGNED( IdentAndCorrectionLUT_12to18( TO_INTEGER(
                                                                      reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta4a
                                                                      & UNSIGNED( TriggerCompressLUT_8to4( TO_INTEGER( Energy( 7 DOWNTO 0 ) ) ) )
                                                                      & UNSIGNED( reference_EgammaCluster( eta )( eta_half )( phi ) .ShapeFlags )
                                                              ) )( 17 DOWNTO 10 ) );

          EgammaIsolationThreshold := UNSIGNED( EgammaIsolThresholdLUT_13to9( TO_INTEGER(
                                                                      reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta4a
                                                                      & UNSIGNED( TriggerCompressLUT_8to4( TO_INTEGER( Energy( 7 DOWNTO 0 ) ) ) )
                                                                      & reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .towerCount
                                                              ) )( 7 DOWNTO 0 ) );

          EgammaIsolationFlag := EgammaIsolThresholdLUT_13to9( TO_INTEGER(
                                                                      reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta4a
                                                                      & UNSIGNED( TriggerCompressLUT_8to4( TO_INTEGER( Energy( 7 DOWNTO 0 ) ) ) )
                                                                      & reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .towerCount
                                                              ) )( 8 );


          reference_CalibratedEgamma( eta )( eta_half )( phi ) := reference_EgammaCluster( eta )( eta_half )( phi );

          TempEnergy                                           := SIGNED( SHIFT_RIGHT( ( reference_EgammaCluster( eta )( eta_half )( phi ) .Energy * EgammaMultiplier ) , 8 ) ) + EgammaOffset;

          IF( EgammaShape = '1' ) AND reference_EgammaCluster( eta )( eta_half )( phi ) .EgammaCandidate THEN
            IF TempEnergy( 21 DOWNTO 12 ) /= "0000000000" THEN
              reference_CalibratedEgamma( eta )( eta_half )( phi ) .Energy( 11 DOWNTO 0 ) := ( OTHERS => '1' );
            ELSE
              reference_CalibratedEgamma( eta )( eta_half )( phi ) .Energy( 11 DOWNTO 0 ) := UNSIGNED( TempEnergy( 11 DOWNTO 0 ) );
            END IF;
          ELSE
            reference_CalibratedEgamma( eta )( eta_half )( phi ) .Energy := ( OTHERS => '0' );
          END IF;

          reference_CalibratedEgamma( eta )( eta_half )( phi ) .Isolated := ( reference_EgammaIsolationRegion( eta )( eta_half )( phi ) .Energy < EgammaIsolationThreshold )
                                                                         OR ( EgammaIsolationFlag = '1' );

        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR eta IN 0 TO( reference_sortedEgamma'LENGTH - 1 ) LOOP
      FOR eta_half IN 0 TO cRegionInEta-1 LOOP
        reference_sortedEgamma( eta )( eta_half ) := reference_CalibratedEgamma( eta )( eta_half );
        CLUSTER_BITONIC_SORT( reference_sortedEgamma( eta )( eta_half )( 0 TO( cTowerInPhi / 4 ) -1 ) , 0 , ( cTowerInPhi / 4 ) , false );
        reference_sortedEgamma( eta )( eta_half )( 6 TO( cTowerInPhi / 4 ) -1 ) := ( OTHERS => cEmptyCluster );
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO( cRegionInEta-1 ) LOOP
      reference_accumulatedSortedEgamma( 0 )( eta_half )( 0 TO 5 ) := reference_sortedEgamma( 0 )( eta_half )( 0 TO 5 );
      FOR eta IN 1 TO( reference_accumulatedSortedEgamma'LENGTH - 1 ) LOOP
        reference_accumulatedSortedEgamma( eta )( eta_half )( 0 TO 5 )  := reference_accumulatedSortedEgamma( eta-1 )( eta_half )( 0 TO 5 );
        reference_accumulatedSortedEgamma( eta )( eta_half )( 6 TO 11 ) := reference_sortedEgamma( eta )( eta_half )( 0 TO 5 );
        CLUSTER_BITONIC_SORT( reference_accumulatedSortedEgamma( eta )( eta_half )( 0 TO( cTowerInPhi / 4 ) -1 ) , 0 , 12 , false );
        reference_accumulatedSortedEgamma( eta )( eta_half )( 6 TO( cTowerInPhi / 4 ) -1 ) := ( OTHERS => cEmptyCluster );
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO( cRegionInEta-1 ) LOOP
      FOR eta IN 0 TO( reference_accumulatedSortedEgamma'LENGTH - 1 ) LOOP
        FOR candidate IN 0 TO 5 LOOP
          reference_EgammaPackedLink( eta )( ( 6 * eta_half ) + candidate ) .Data := STD_LOGIC_VECTOR( reference_accumulatedSortedEgamma( eta )( eta_half )( candidate ) .Energy( 11 DOWNTO 0 ) ) &
                                                                                     encodeVerticalPosition( reference_accumulatedSortedEgamma( eta )( eta_half )( candidate ) .VerticalPosition ) &
                                                                                     encodeLateralPosition( reference_accumulatedSortedEgamma( eta )( eta_half )( candidate ) .LateralPosition ) &
                                                                                     STD_LOGIC_VECTOR( TO_UNSIGNED( reference_accumulatedSortedEgamma( eta )( eta_half )( candidate ) .Phi , 7 ) ) &
                                                                                     STD_LOGIC_VECTOR( TO_UNSIGNED( reference_accumulatedSortedEgamma( eta )( eta_half )( candidate ) .Eta , 6 ) ) &
                                                                                     TO_STD_LOGIC( reference_accumulatedSortedEgamma( eta )( eta_half )( candidate ) .Isolated2 ) &
                                                                                     TO_STD_LOGIC( reference_accumulatedSortedEgamma( eta )( eta_half )( candidate ) .Isolated ) &
                                                                                     '0';
          reference_EgammaPackedLink( eta )( ( 6 * eta_half ) + candidate ) .AccumulationComplete := ( eta = ( reference_accumulatedSortedEgamma'LENGTH - 1 ) );
          reference_EgammaPackedLink( eta )( ( 6 * eta_half ) + candidate ) .DataValid            := reference_accumulatedSortedEgamma( eta )( eta_half )( candidate ) .DataValid;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO( cRegionInEta-1 ) LOOP
      FOR index IN 0 TO 5 LOOP
      reference_demuxAccumulatedSortedEgamma( 0 )( eta_half )( index )                    := reference_accumulatedSortedEgamma( reference_accumulatedSortedEgamma'LENGTH - 1 )( eta_half )( index );
        reference_demuxAccumulatedSortedEgamma( 0 )( eta_half )( index ) .TrimmingFlags   := ( OTHERS => '0' );
        reference_demuxAccumulatedSortedEgamma( 0 )( eta_half )( index ) .ShapeFlags      := ( OTHERS => '0' );
        reference_demuxAccumulatedSortedEgamma( 0 )( eta_half )( index ) .HasSeed         := FALSE;
        reference_demuxAccumulatedSortedEgamma( 0 )( eta_half )( index ) .EgammaCandidate := FALSE;
        reference_demuxAccumulatedSortedEgamma( 0 )( eta_half )( index ) .HasEM           := FALSE;
        reference_demuxAccumulatedSortedEgamma( 0 )( eta_half )( index ) .NoSecondary     := TRUE;
        reference_demuxAccumulatedSortedEgamma( 0 )( eta_half )( index ) .TauSite         := 0;
        reference_demuxAccumulatedSortedEgamma( 0 )( eta_half )( index ) .EtaHalf         := eta_half;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    reference_mergedSortedEgamma( 0 )( 0 )( 0 TO 5 )  := reference_demuxAccumulatedSortedEgamma( 0 )( 0 )( 0 TO 5 );
    reference_mergedSortedEgamma( 0 )( 0 )( 6 TO 11 ) := reference_demuxAccumulatedSortedEgamma( 0 )( 1 )( 0 TO 5 );
    CLUSTER_BITONIC_SORT( reference_mergedSortedEgamma( 0 )( 0 )( 0 TO( cTowerInPhi / 4 ) -1 ) , 0 , 12 , false );
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO 11 LOOP
      IF( reference_mergedSortedEgamma( 0 )( 0 )( index ) .EtaHalf = 1 ) THEN
        reference_GtFormattedEgamma( 0 )( index ) .Eta := SIGNED( Y_localEtaToGT_9to8(
          TO_INTEGER( '1' & TO_UNSIGNED( reference_mergedSortedEgamma( 0 )( 0 )( index ) .Eta , 6 ) & UNSIGNED( encodeLateralPosition( reference_mergedSortedEgamma( 0 )( 0 )( index ) .LateralPosition ) ) )
        ) );
      ELSE
        reference_GtFormattedEgamma( 0 )( index ) .Eta := SIGNED( Y_localEtaToGT_9to8(
          TO_INTEGER( '0' & TO_UNSIGNED( reference_mergedSortedEgamma( 0 )( 0 )( index ) .Eta , 6 ) & UNSIGNED( encodeLateralPosition( reference_mergedSortedEgamma( 0 )( 0 )( index ) .LateralPosition ) ) )
        ) );
      END IF;

      reference_GtFormattedEgamma( 0 )( index ) .Phi := UNSIGNED( Z_localPhiToGT_9to8(
        TO_INTEGER( TO_UNSIGNED( reference_mergedSortedEgamma( 0 )( 0 )( index ) .Phi , 7 ) & UNSIGNED( encodeVerticalPosition( reference_mergedSortedEgamma( 0 )( 0 )( index ) .VerticalPosition ) ) )
      ) );

      IF reference_mergedSortedEgamma( 0 )( 0 )( index ) .Energy > x"01FF" THEN
        reference_GtFormattedEgamma( 0 )( index ) .Energy := ( OTHERS => '1' );
      ELSE
        reference_GtFormattedEgamma( 0 )( index ) .Energy := reference_mergedSortedEgamma( 0 )( 0 )( index ) .Energy( 8 DOWNTO 0 ) ; -- We saturate at output of MP
      END IF;

      reference_GtFormattedEgamma( 0 )( index ) .Isolated2 := reference_mergedSortedEgamma( 0 )( 0 )( index ) .Isolated2;
      reference_GtFormattedEgamma( 0 )( index ) .Isolated  := reference_mergedSortedEgamma( 0 )( 0 )( index ) .Isolated;

      reference_GtFormattedEgamma( 0 )( index ) .DataValid := reference_mergedSortedEgamma( 0 )( 0 )( index ) .DataValid;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO 11 LOOP
      reference_DemuxEgammaPackedLink( 0 )( index ) .Data := "00000" &
                                                          TO_STD_LOGIC( reference_GtFormattedEgamma( 0 )( index ) .Isolated2 ) &
                                                          TO_STD_LOGIC( reference_GtFormattedEgamma( 0 )( index ) .Isolated ) &
                                                          STD_LOGIC_VECTOR( reference_GtFormattedEgamma( 0 )( index ) .Phi ) &
                                                          STD_LOGIC_VECTOR( reference_GtFormattedEgamma( 0 )( index ) .Eta ) &
                                                          STD_LOGIC_VECTOR( reference_GtFormattedEgamma( 0 )( index ) .Energy );
      reference_DemuxEgammaPackedLink( 0 )( index ) .DataValid := reference_GtFormattedEgamma( 0 )( index ) .DataValid;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

  END EgammaReference;



  PROCEDURE EgammaChecker
  (
    VARIABLE clk_count                              : IN INTEGER;
    CONSTANT timeout                                : IN INTEGER;
-- -------------
    VARIABLE reference_EgammaProtoCluster           : IN tClusterPipe;
    SIGNAL EgammaProtoClusterPipe                   : IN tClusterPipe;
    VARIABLE retvalEgammaProtoCluster               : INOUT tRetVal;
-- -------------
    VARIABLE reference_EgammaCluster                : IN tClusterPipe;
    SIGNAL EgammaClusterPipe                        : IN tClusterPipe;
    VARIABLE retvalEgammaCluster                    : INOUT tRetVal;
-- -------------
    VARIABLE reference_Isolation5x2                 : IN tIsolationRegionPipe;
    SIGNAL Isolation5x2Pipe                         : IN tIsolationRegionPipe;
    VARIABLE retvalIsolation5x2                     : INOUT tRetVal;
-- -------------
    VARIABLE reference_EgammaIsolationRegion        : IN tIsolationRegionPipe;
    SIGNAL EgammaIsolationRegionPipe                : IN tIsolationRegionPipe;
    VARIABLE retvalEgammaIsolationRegion            : INOUT tRetVal;
-- -------------
-- VARIABLE reference_EgammaIsolationFlag : IN tComparisonPipe;
-- SIGNAL EgammaIsolationFlagPipe : IN tComparisonPipe;
-- VARIABLE retvalEgammaIsolationFlag : INOUT tRetVal;
-- -------------
    VARIABLE reference_CalibratedEgamma             : IN tClusterPipe;
    SIGNAL CalibratedEgammaPipe                     : IN tClusterPipe;
    VARIABLE retvalCalibratedEgamma                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_sortedEgamma                 : IN tClusterPipe;
    SIGNAL SortedEgammaPipe                         : IN tClusterPipe;
    VARIABLE retvalSortedEgamma                     : INOUT tRetVal;
-- -------------
    VARIABLE reference_accumulatedSortedEgamma      : IN tClusterPipe;
    SIGNAL accumulatedSortedEgammaPipe              : IN tClusterPipe;
    VARIABLE retvalAccumulatedSortedEgamma          : INOUT tRetVal;
-------------
    VARIABLE reference_EgammaPackedLink             : IN tPackedLinkPipe;
    SIGNAL EgammaPackedLinkPipe                     : IN tPackedLinkPipe;
    VARIABLE retvalEgammaPackedLink                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedSortedEgamma : IN tClusterPipe;
    SIGNAL demuxAccumulatedSortedEgammaPipe         : IN tClusterPipe;
    VARIABLE retvalDemuxAccumulatedSortedEgamma     : INOUT tRetVal;
-- -------------
    VARIABLE reference_mergedSortedEgamma           : IN tClusterPipe;
    SIGNAL mergedSortedEgammaPipe                   : IN tClusterPipe;
    VARIABLE retvalMergedSortedEgamma               : INOUT tRetVal;
-- -------------
    VARIABLE reference_GtFormattedEgamma            : IN tGtFormattedClusterPipe;
    SIGNAL GtFormattedEgammaPipe                    : IN tGtFormattedClusterPipe;
    VARIABLE retvalGtFormattedEgamma                : INOUT tRetVal;
-- -------------
    VARIABLE reference_DemuxEgammaPackedLink        : IN tPackedLinkPipe;
    SIGNAL DemuxEgammaPackedLinkPipe                : IN tPackedLinkPipe;
    VARIABLE retvalDemuxEgammaPackedLink            : INOUT tRetVal;
-- -------------
    CONSTANT debug                                  : IN BOOLEAN := false
-- -------------
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_EgammaProtoCluster'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Egamma ProtoCluster" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_EgammaProtoCluster , -- expected latency
                    timeout , -- timeout
                    retvalEgammaProtoCluster( index ) , -- return value
                    ( reference_EgammaProtoCluster( index ) = EgammaProtoClusterPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_EgammaCluster'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Egamma Cluster" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_EgammaCluster , -- expected latency
                    timeout , -- timeout
                    retvalEgammaCluster( index ) , -- return value
                    ( reference_EgammaCluster( index ) = EgammaClusterPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_Isolation5x2'LENGTH - 1 ) LOOP
      CHECK_RESULT( "5x2 Isolation Regions" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_Isolation5x2 , -- expected latency
                    timeout , -- timeout
                    retvalIsolation5x2( index ) , -- return value
                    ( reference_Isolation5x2( index ) = Isolation5x2Pipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_EgammaIsolationRegion'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Egamma Isolation Regions" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_EgammaIsolationRegion , -- expected latency
                    timeout , -- timeout
                    retvalEgammaIsolationRegion( index ) , -- return value
                    ( reference_EgammaIsolationRegion( index ) = EgammaIsolationRegionPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

---- -----------------------------------------------------------------------------------------------------
-- FOR index IN 0 TO( reference_EgammaIsolationFlag'LENGTH - 1 ) LOOP
-- CHECK_RESULT( "Egamma Isolation Flags" , -- name
-- index , -- index
-- clk_count , -- clock counter
-- latency_EgammaIsolationFlag , -- expected latency
-- timeout , -- timeout
-- retvalEgammaIsolationFlag( index ) , -- return value
-- ( reference_EgammaIsolationFlag( index ) = EgammaIsolationFlagPipe( 0 ) ) , -- test condition
-- debug
-- );
-- END LOOP;
---- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_CalibratedEgamma'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Calibrated Egamma" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_CalibratedEgamma , -- expected latency
                    timeout , -- timeout
                    retvalCalibratedEgamma( index ) , -- return value
                    ( reference_CalibratedEgamma( index ) = CalibratedEgammaPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_sortedEgamma'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Sorted Egammas" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_SortedEgamma , -- expected latency
                    timeout , -- timeout
                    retvalSortedEgamma( index ) , -- return value
                    ( reference_sortedEgamma( index ) = SortedEgammaPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_accumulatedSortedEgamma'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Accumulated Sorted Egammas" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_accumulatedSortedEgamma , -- expected latency
                    timeout , -- timeout
                    retvalAccumulatedSortedEgamma( index ) , -- return value
                    ( reference_accumulatedSortedEgamma( index ) = accumulatedSortedEgammaPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_EgammaPackedLink'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Egamma Packed Link" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_EgammaPackedLink , -- expected latency
                    timeout , -- timeout
                    retvalEgammaPackedLink( index ) , -- return value
                    ( reference_EgammaPackedLink( index ) = EgammaPackedLinkPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_demuxAccumulatedSortedEgamma'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux Accumulated Sorted Egammas" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_demuxAccumulatedSortedEgammas , -- expected latency
                    timeout , -- timeout
                    retvalDemuxAccumulatedSortedEgamma( index ) , -- return value
                    ( reference_demuxAccumulatedSortedEgamma( index ) = demuxAccumulatedSortedEgammaPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_MergedSortedEgamma'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Merged Sorted Egammas" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_MergedSortedEgammas , -- expected latency
                    timeout , -- timeout
                    retvalMergedSortedEgamma( index ) , -- return value
                    reference_MergedSortedEgamma( index ) = MergedSortedEgammaPipe( 0 ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_GtFormattedEgamma'LENGTH - 1 ) LOOP
      CHECK_RESULT( "GT Formatted Egammas" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_GtFormattedEgammas , -- expected latency
                    timeout , -- timeout
                    retvalGtFormattedEgamma( index ) , -- return value
                    ( reference_GtFormattedEgamma( index ) = GtFormattedEgammaPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_DemuxEgammaPackedLink'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux Egamma Packed Link" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_DemuxEgammaPackedLink , -- expected latency
                    timeout , -- timeout
                    retvalDemuxEgammaPackedLink( index ) , -- return value
                    ( reference_DemuxEgammaPackedLink( index ) = DemuxEgammaPackedLinkPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

  END EgammaChecker;



  PROCEDURE EgammaDebug
  (
    VARIABLE clk_count                 : IN INTEGER;
    SIGNAL Isolation5x2Pipe            : IN tIsolationRegionPipe;
    SIGNAL EgammaIsolationRegionPipe   : IN tIsolationRegionPipe;
    SIGNAL ClusterPileupEstimationPipe : IN tPileupEstimationPipe;
    SIGNAL EgammaProtoClusterPipe      : IN tClusterPipe;
    SIGNAL EgammaClusterPipe           : IN tClusterPipe;
    SIGNAL CalibratedEgammaPipe        : IN tClusterPipe;
    SIGNAL SortedEgammaPipe            : IN tClusterPipe;
    SIGNAL accumulatedSortedEgammaPipe : IN tClusterPipe;
    CONSTANT debug                     : IN BOOLEAN := false
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    IF debug THEN

      OutputCandidate( clk_count , latency_Isolation5x2 , Isolation5x2Pipe( 0 ) , Isolation5x2File );
      OutputCandidate( clk_count , latency_EgammaIsolationRegion , EgammaIsolationRegionPipe( 0 ) , EgammaIsolationFile );
      OutputCandidate( clk_count , latency_ClusterPileupEstimation , ClusterPileupEstimationPipe( 0 ) , ClusterPileupEstimationFile );
      OutputCandidate( clk_count , latency_EgammaProtoCluster , EgammaProtoClusterPipe( 0 ) , EgammaProtoClusterFile );
      OutputCandidate( clk_count , latency_EgammaCluster , EgammaClusterPipe( 0 ) , EgammaClusterFile );
      OutputCandidate( clk_count , latency_CalibratedEgamma , CalibratedEgammaPipe( 0 ) , CalibratedEgammaFile );
      OutputCandidate( clk_count , latency_SortedEgamma , SortedEgammaPipe( 0 ) , SortedEgammaFile );
      OutputCandidate( clk_count , latency_accumulatedSortedEgamma , accumulatedSortedEgammaPipe( 0 ) , accumulatedSortedEgammaFile );
    END IF;
-- -----------------------------------------------------------------------------------------------------
  END EgammaDebug;


  PROCEDURE EgammaReport
  (
    VARIABLE retvalEgammaProtoCluster           : IN tRetVal;
    VARIABLE retvalEgammaCluster                : IN tRetVal;
    VARIABLE retvalIsolation5x2                 : IN tRetVal;
    VARIABLE retvalEgammaIsolationRegion        : IN tRetVal;
-- VARIABLE retvalEgammaIsolationFlag : IN tRetVal;
    VARIABLE retvalCalibratedEgamma             : IN tRetVal;
    VARIABLE retvalSortedEgamma                 : IN tRetVal;
    VARIABLE retvalAccumulatedSortedEgamma      : IN tRetVal;
    VARIABLE retvalEgammaPackedLink             : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedSortedEgamma : IN tRetVal;
    VARIABLE retvalMergedSortedEgamma           : IN tRetVal;
    VARIABLE retvalGtFormattedEgamma            : IN tRetVal;
    VARIABLE retvalDemuxEgammaPackedLink        : IN tRetVal
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    REPORT_RESULT( "Egamma ProtoClusters" , retvalEgammaProtoCluster );
    REPORT_RESULT( "Egamma Clusters" , retvalEgammaCluster );
    REPORT_RESULT( "5x2 Isolation Regions" , retvalIsolation5x2 );
    REPORT_RESULT( "Egamma Isolation Regions" , retvalEgammaIsolationRegion );
-- REPORT_RESULT( "Egamma Isolation Flags" , retvalEgammaIsolationFlag );
    REPORT_RESULT( "Calibrated Egamma" , retvalCalibratedEgamma );
    REPORT_RESULT( "Sorted Egammas" , retvalSortedEgamma );
    REPORT_RESULT( "Accumulated Sorted Egammas" , retvalAccumulatedSortedEgamma );
    REPORT_RESULT( "Egamma Packed Link" , retvalEgammaPackedLink );
    REPORT_RESULT( "Demux Accumulated Sorted Egammas" , retvalDemuxAccumulatedSortedEgamma );
    REPORT_RESULT( "Merged Sorted Egammas" , retvalMergedSortedEgamma );
    REPORT_RESULT( "GT Formatted Egammas" , retvalGtFormattedEgamma );
    REPORT_RESULT( "Demux Egamma Packed Link" , retvalDemuxEgammaPackedLink );
-- -----------------------------------------------------------------------------------------------------
  END EgammaReport;


END PACKAGE BODY EgammaReference;
