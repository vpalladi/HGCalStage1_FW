
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE IEEE.MATH_REAL.ALL;


--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;
--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "jet" helper functions
USE work.jet_functions.ALL;

--! Using the Calo-L2 "helper" helper functions
USE work.helper_functions.ALL;

--! Using the Calo-L2 "Tower" testbench suite
USE work.TowerReference.ALL;

--! Writing to and from files
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
PACKAGE JetReference IS

---- CONSTANT latency_strips9x1 : INTEGER := latency_towerFormer + 2;
-- CONSTANT latency_strips1x9 : INTEGER := latency_towerFormer + 6;
-- CONSTANT latency_jets9x9Sum : INTEGER := latency_strips9x1 + 6 + 6 ; -- there is a configurable delay + an intrinsic latency


  CONSTANT latency_sum3x3                     : INTEGER := latency_towerFormer + 3 + 5;

  CONSTANT latency_strips9x3                  : INTEGER := latency_sum3x3 + 1;
  CONSTANT latency_strips3x9                  : INTEGER := latency_sum3x3 + 4 + 3;

  CONSTANT latency_jets9x9Veto                : INTEGER := latency_towerFormer + 14;

-- CONSTANT latency_isoRegion : INTEGER := latency_jets9x3Veto + 1;

  CONSTANT latency_filteredJets               : INTEGER := latency_jets9x9Veto + 3;
  CONSTANT latency_pileup                     : INTEGER := latency_jets9x9Veto + 5;

  CONSTANT latency_pileUpSubtractedJets       : INTEGER := latency_pileup + 1;
  CONSTANT latency_CalibratedJets             : INTEGER := latency_pileUpSubtractedJets + 5;
  CONSTANT latency_sortedJets                 : INTEGER := latency_CalibratedJets + 14;
  CONSTANT latency_accumulatedSortedJets      : INTEGER := latency_sortedJets + 8;
  CONSTANT latency_jetPackedLink              : INTEGER := latency_accumulatedSortedJets;

  CONSTANT latency_demuxAccumulatedSortedJets : INTEGER := latency_accumulatedSortedJets + cTestbenchTowersInHalfEta + 3;
  CONSTANT latency_mergedSortedJets           : INTEGER := latency_demuxAccumulatedSortedJets + 4;
  CONSTANT latency_gtFormattedJets            : INTEGER := latency_mergedSortedJets + 1;
  CONSTANT latency_demuxJetPackedLink         : INTEGER := latency_gtFormattedJets;



  PROCEDURE JetReference
  (
    VARIABLE reference_Towers                    : IN tTowerPipe;
    VARIABLE reference_TowerThresholds           : IN tTowerFlagsPipe;
    VARIABLE reference_3x3Sum                    : INOUT tJetPipe;
    VARIABLE reference_9x3Sum                    : INOUT tJetPipe;
    VARIABLE reference_3x9Sum                    : INOUT tJetPipe;
    VARIABLE reference_9x9Veto                   : INOUT tComparisonPipe;
-- VARIABLE reference_9x3FilteredSum : INOUT tJetPipe;
    VARIABLE reference_JetSum                    : INOUT tJetPipe;
    VARIABLE reference_JetPUestimate             : INOUT tJetPipe;
    VARIABLE reference_PUsubJet                  : INOUT tJetPipe;
    VARIABLE reference_CalibratedJet             : INOUT tJetPipe;
    VARIABLE reference_sortedJet                 : INOUT tJetPipe;
    VARIABLE reference_accumulatedsortedJet      : INOUT tJetPipe;
    VARIABLE reference_jetPackedLink             : INOUT tPackedLinkPipe;
    VARIABLE reference_demuxAccumulatedsortedJet : INOUT tJetPipe;
    VARIABLE reference_mergedsortedJet           : INOUT tJetPipe;
    VARIABLE reference_gtFormattedJet            : INOUT tGtFormattedJetPipe;
    VARIABLE reference_demuxJetPackedLink        : INOUT tPackedLinkPipe
  );


  PROCEDURE JetChecker
  (
    VARIABLE clk_count                           : IN INTEGER;
    CONSTANT timeout                             : IN INTEGER;
-- -------------
    VARIABLE reference_3x3Sum                    : IN tJetPipe;
    SIGNAL sum3x3Pipe                            : IN tJetPipe;
    VARIABLE retval3x3Sum                        : INOUT tRetVal;
-- -------------
    VARIABLE reference_9x3Sum                    : IN tJetPipe;
    SIGNAL strips9x3Pipe                         : IN tJetPipe;
    VARIABLE retval9x3Sum                        : INOUT tRetVal;
-- -------------
    VARIABLE reference_3x9Sum                    : IN tJetPipe;
    SIGNAL strips3x9Pipe                         : IN tJetPipe;
    VARIABLE retval3x9Sum                        : INOUT tRetVal;
-- -------------
    VARIABLE reference_9x9Veto                   : IN tComparisonPipe;
    SIGNAL jets9x9VetoPipe                       : IN tComparisonPipe;
    VARIABLE retval9x9Veto                       : INOUT tRetVal;
-- -------------
    VARIABLE reference_JetSum                    : IN tJetPipe;
    SIGNAL filteredJetPipe                       : IN tJetPipe;
    VARIABLE retvalJetSum                        : INOUT tRetVal;
-- -------------
    VARIABLE reference_JetPUestimate             : IN tJetPipe;
    SIGNAL filteredPileUpPipe                    : IN tJetPipe;
    VARIABLE retvalJetPUestimate                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_PUsubJet                  : IN tJetPipe;
    SIGNAL pileUpSubtractedJetPipe               : IN tJetPipe;
    VARIABLE retvalPUsubJet                      : INOUT tRetVal;
-- -------------
    VARIABLE reference_CalibratedJet             : IN tJetPipe;
    SIGNAL CalibratedJetPipe                     : IN tJetPipe;
    VARIABLE retvalCalibratedJet                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_sortedJet                 : IN tJetPipe;
    SIGNAL sortedJetPipe                         : IN tJetPipe;
    VARIABLE retvalSortedJet                     : INOUT tRetVal;
-- -------------
    VARIABLE reference_accumulatedsortedJet      : IN tJetPipe;
    SIGNAL accumulatedSortedJetPipe              : IN tJetPipe;
    VARIABLE retvalAccumulatedsortedJet          : INOUT tRetVal;
-- -------------
    VARIABLE reference_jetPackedLink             : IN tPackedLinkPipe;
    SIGNAL jetPackedLinkPipe                     : IN tPackedLinkPipe;
    VARIABLE retvalJetPackedLink                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedsortedJet : IN tJetPipe;
    SIGNAL demuxAccumulatedSortedJetPipe         : IN tJetPipe;
    VARIABLE retvalDemuxAccumulatedsortedJet     : INOUT tRetVal;
-- -------------
    VARIABLE reference_mergedsortedJet           : IN tJetPipe;
    SIGNAL mergedSortedJetPipe                   : IN tJetPipe;
    VARIABLE retvalMergedsortedJet               : INOUT tRetVal;
-- -------------
    VARIABLE reference_gtFormattedJet            : IN tGtFormattedJetPipe;
    SIGNAL gtFormattedJetPipe                    : IN tGtFormattedJetPipe;
    VARIABLE retvalGtFormattedJet                : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxjetPackedLink        : IN tPackedLinkPipe;
    SIGNAL demuxjetPackedLinkPipe                : IN tPackedLinkPipe;
    VARIABLE retvaldemuxJetPackedLink            : INOUT tRetVal;
-- -------------
    CONSTANT debug                               : IN BOOLEAN := false
-- -------------
  );


  PROCEDURE JetReport
  (
    VARIABLE retval3x3Sum                    : IN tRetVal;
    VARIABLE retval9x3Sum                    : IN tRetVal;
    VARIABLE retval3x9Sum                    : IN tRetVal;
    VARIABLE retval9x9Veto                   : IN tRetVal;
    VARIABLE retvalJetSum                    : IN tRetVal;
    VARIABLE retvalJetPUestimate             : IN tRetVal;
    VARIABLE retvalPUsubJet                  : IN tRetVal;
    VARIABLE retvalCalibratedJet             : IN tRetVal;
    VARIABLE retvalSortedJet                 : IN tRetVal;
    VARIABLE retvalAccumulatedsortedJet      : IN tRetVal;
    VARIABLE retvalJetPackedLink             : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedsortedJet : IN tRetVal;
    VARIABLE retvalMergedsortedJet           : IN tRetVal;
    VARIABLE retvalGtFormattedJet            : IN tRetVal;
    VARIABLE retvalDemuxJetPackedLink        : IN tRetVal
  );


  IMPURE FUNCTION PileUpEstimate( aStrip1 , aStrip2 , aStrip3 , aStrip4 : tJet ) RETURN tJet;

  IMPURE FUNCTION JET_OVERLAP_VETO( EtaCentre                           : INTEGER ; PhiCentre : INTEGER ; Towers : tTowerPipe ) RETURN BOOLEAN;

  PROCEDURE JET_BITONIC_SORT( VARIABLE a                                : INOUT tJetInPhi ; lo , n : IN INTEGER ; dir : IN BOOLEAN );
  PROCEDURE JET_BITONIC_MERGE( VARIABLE a                               : INOUT tJetInPhi ; lo , n : IN INTEGER ; dir : IN BOOLEAN );

  PROCEDURE OutputCandidate( VARIABLE clk                               : IN INTEGER ; CONSTANT latency : IN INTEGER ; SIGNAL data : IN tComparisonInEtaPhi ; FILE f : TEXT );

  FUNCTION CompareSortedJets( Left , Right                              : tJetInEtaPhi ) RETURN BOOLEAN;


END PACKAGE JetReference;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------



-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
PACKAGE BODY JetReference IS

  PROCEDURE JetReference
  (
    VARIABLE reference_Towers                    : IN tTowerPipe;
    VARIABLE reference_TowerThresholds           : IN tTowerFlagsPipe;
    VARIABLE reference_3x3Sum                    : INOUT tJetPipe;
    VARIABLE reference_9x3Sum                    : INOUT tJetPipe;
    VARIABLE reference_3x9Sum                    : INOUT tJetPipe;
    VARIABLE reference_9x9Veto                   : INOUT tComparisonPipe;
    VARIABLE reference_JetSum                    : INOUT tJetPipe;
    VARIABLE reference_JetPUestimate             : INOUT tJetPipe;
    VARIABLE reference_PUsubJet                  : INOUT tJetPipe;
    VARIABLE reference_CalibratedJet             : INOUT tJetPipe;
    VARIABLE reference_sortedJet                 : INOUT tJetPipe;
    VARIABLE reference_accumulatedsortedJet      : INOUT tJetPipe;
    VARIABLE reference_jetPackedLink             : INOUT tPackedLinkPipe;
    VARIABLE reference_demuxAccumulatedsortedJet : INOUT tJetPipe;
    VARIABLE reference_mergedsortedJet           : INOUT tJetPipe;
    VARIABLE reference_gtFormattedJet            : INOUT tGtFormattedJetPipe;
    VARIABLE reference_demuxJetPackedLink        : INOUT tPackedLinkPipe
  ) IS
    VARIABLE reference_PUestimate : tJetPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 ) := ( OTHERS => cEmptyJetInEtaPhi );
    VARIABLE reference_9x9Sum     : tJetPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 ) := ( OTHERS => cEmptyJetInEtaPhi );
    VARIABLE s                    : LINE;

    TYPE mem_type_6to4 IS ARRAY( 0 TO( 2 ** 6 ) -1 ) OF STD_LOGIC_VECTOR( 3 DOWNTO 0 );
    VARIABLE EtaLUT_6to4 : mem_type_6to4;

    TYPE mem_type_8to4 IS ARRAY( 0 TO( 2 ** 8 ) -1 ) OF STD_LOGIC_VECTOR( 3 DOWNTO 0 );
    VARIABLE EnergyCompressionLUT_8to4 : mem_type_8to4;

    TYPE mem_type_11to18 IS ARRAY( 0 TO( 2 ** 11 ) -1 ) OF STD_LOGIC_VECTOR( 17 DOWNTO 0 );
    VARIABLE L_JetCalibration_11to18 : mem_type_11to18;

    TYPE mem_type_9to8 IS ARRAY( 0 TO( 2 ** 9 ) -1 ) OF STD_LOGIC_VECTOR( 7 DOWNTO 0 );
    VARIABLE Y_localEtaToGT_9to8 , Z_localPhiToGT_9to8 : mem_type_9to8;

    FILE RomFile                                       : TEXT;
    VARIABLE RomFileLine                               : LINE;
    VARIABLE TEMP                                      : CHARACTER;
    VARIABLE Value                                     : STD_LOGIC_VECTOR( 19 DOWNTO 0 );

    VARIABLE SignedEnergy                              : INTEGER;
    VARIABLE Energy                                    : UNSIGNED( 15 DOWNTO 0 ) := ( OTHERS => '0' );
    VARIABLE JetMultiplier                             : UNSIGNED( 9 DOWNTO 0 )  := ( OTHERS => '0' );
    VARIABLE JetOffset                                 : SIGNED( 7 DOWNTO 0 )    := ( OTHERS => '0' );
    VARIABLE TempEnergy                                : SIGNED( 25 DOWNTO 0 )   := ( OTHERS => '0' );

    VARIABLE L                                         : LINE;

  BEGIN


    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/J_EtaCompression_6to4.mif" ) , READ_MODE );
    FOR i IN EtaLUT_6to4'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      EtaLUT_6to4( i ) := Value( 4-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/K_EnergyCompression_8to4.mif" ) , READ_MODE );
    FOR i IN EnergyCompressionLUT_8to4'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      EnergyCompressionLUT_8to4( i ) := Value( 4-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/L_JetCalibration_11to18.mif" ) , READ_MODE );
    FOR i IN L_JetCalibration_11to18'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      L_JetCalibration_11to18( i ) := Value( 18-1 DOWNTO 0 );
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
      FOR eta IN 0 TO( reference_9x9Sum'LENGTH - 1 ) LOOP

        FOR delta_eta IN -4 TO 4 LOOP
          FOR delta_phi IN -4 TO 4 LOOP
            reference_9x9Sum( eta )( 0 )( phi ) := reference_9x9Sum( eta )( 0 )( phi ) + ToJet( GetTower( eta + delta_eta , phi + delta_phi , reference_Towers ) );
            reference_9x9Sum( eta )( 1 )( phi ) := reference_9x9Sum( eta )( 1 )( phi ) + ToJet( GetTower( -eta + delta_eta-1 , phi + delta_phi , reference_Towers ) );
          END LOOP;
        END LOOP;

      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO cTowerInPhi-1 LOOP
      FOR eta IN 0 TO( reference_3x3Sum'LENGTH - 1 ) LOOP

        FOR delta_eta IN -1 TO 1 LOOP
          FOR delta_phi IN -1 TO 1 LOOP
            reference_3x3Sum( eta )( 0 )( phi ) := reference_3x3Sum( eta )( 0 )( phi ) + ToJet( GetTower( eta + delta_eta , phi + delta_phi , reference_Towers ) );
            reference_3x3Sum( eta )( 1 )( phi ) := reference_3x3Sum( eta )( 1 )( phi ) + ToJet( GetTower( -eta + delta_eta-1 , phi + delta_phi , reference_Towers ) );
          END LOOP;
        END LOOP;

      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO cTowerInPhi-1 LOOP
      FOR eta IN 0 TO( reference_9x3Sum'LENGTH - 1 ) LOOP

        FOR delta_eta IN -1 TO 1 LOOP
          FOR delta_phi IN -4 TO 4 LOOP
            reference_9x3Sum( eta )( 0 )( phi ) := reference_9x3Sum( eta )( 0 )( phi ) + ToJet( GetTower( eta + delta_eta , phi + delta_phi , reference_Towers ) );
            reference_9x3Sum( eta )( 1 )( phi ) := reference_9x3Sum( eta )( 1 )( phi ) + ToJet( GetTower( -eta + delta_eta-1 , phi + delta_phi , reference_Towers ) );
          END LOOP;
        END LOOP;

      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO cTowerInPhi-1 LOOP
      FOR eta IN 0 TO( reference_3x9Sum'LENGTH - 1 ) LOOP

        FOR delta_eta IN -4 TO 4 LOOP
          FOR delta_phi IN -1 TO 1 LOOP
            reference_3x9Sum( eta )( 0 )( phi ) := reference_3x9Sum( eta )( 0 )( phi ) + ToJet( GetTower( eta + delta_eta , phi + delta_phi , reference_Towers ) );
            reference_3x9Sum( eta )( 1 )( phi ) := reference_3x9Sum( eta )( 1 )( phi ) + ToJet( GetTower( -eta + delta_eta-1 , phi + delta_phi , reference_Towers ) );
          END LOOP;
        END LOOP;

      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO cTowerInPhi-1 LOOP
      FOR eta IN 0 TO( reference_9x9Veto'LENGTH - 1 ) LOOP
        reference_9x9Veto( eta )( 0 )( phi ) .Data      := JET_OVERLAP_VETO( eta , phi , reference_Towers );
        reference_9x9Veto( eta )( 1 )( phi ) .Data      := JET_OVERLAP_VETO( -eta-1 , phi , reference_Towers );
        reference_9x9Veto( eta )( 0 )( phi ) .DataValid := TRUE;
        reference_9x9Veto( eta )( 1 )( phi ) .DataValid := TRUE;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO cTowerInPhi-1 LOOP
      FOR eta IN 0 TO( reference_PUestimate'LENGTH - 1 ) LOOP
        FOR eta_half IN 0 TO cRegionInEta-1 LOOP

          IF( eta < 6 ) THEN
            reference_PUestimate( eta )( eta_half )( phi ) := PileUpEstimate( reference_3x9Sum( eta )( eta_half )( MOD_PHI( phi-6 ) ) ,
                                                                              reference_3x9Sum( eta )( eta_half )( MOD_PHI( phi + 6 ) ) ,
                                                                              reference_9x3Sum( 5-eta )( OPP_ETA( eta_half ) )( phi ) ,
                                                                              reference_9x3Sum( eta + 6 )( eta_half )( phi ) );
          ELSIF( eta < ( reference_9x3Sum'LENGTH - 6 ) ) THEN
            reference_PUestimate( eta )( eta_half )( phi ) := PileUpEstimate( reference_3x9Sum( eta )( eta_half )( MOD_PHI( phi-6 ) ) ,
                                                                              reference_3x9Sum( eta )( eta_half )( MOD_PHI( phi + 6 ) ) ,
                                                                              reference_9x3Sum( eta-6 )( eta_half )( phi ) ,
                                                                              reference_9x3Sum( eta + 6 )( eta_half )( phi ) );
          ELSE
            reference_PUestimate( eta )( eta_half )( phi ) := PileUpEstimate( reference_3x9Sum( eta )( eta_half )( MOD_PHI( phi-6 ) ) ,
                                                                              reference_3x9Sum( eta )( eta_half )( MOD_PHI( phi + 6 ) ) ,
                                                                              reference_9x3Sum( eta-6 )( eta_half )( phi ) ,
                                                                              cEmptyJet );
          END IF;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta IN 0 TO( reference_JetPUestimate'LENGTH - 1 ) LOOP
        FOR eta_half IN 0 TO cRegionInEta-1 LOOP
          IF( NOT reference_9x9Veto( eta )( eta_half )( ( 4 * phi ) + 0 ) .Data ) THEN
            reference_JetPUestimate( eta )( eta_half )( phi ) := ToJetNoEcal( reference_PUestimate( eta )( eta_half )( ( 4 * phi ) + 0 ) , 0 , 0 );
          ELSIF( NOT reference_9x9Veto( eta )( eta_half )( ( 4 * phi ) + 1 ) .Data ) THEN
            reference_JetPUestimate( eta )( eta_half )( phi ) := ToJetNoEcal( reference_PUestimate( eta )( eta_half )( ( 4 * phi ) + 1 ) , 0 , 0 );
          ELSIF( NOT reference_9x9Veto( eta )( eta_half )( ( 4 * phi ) + 2 ) .Data ) THEN
            reference_JetPUestimate( eta )( eta_half )( phi ) := ToJetNoEcal( reference_PUestimate( eta )( eta_half )( ( 4 * phi ) + 2 ) , 0 , 0 );
          ELSIF( NOT reference_9x9Veto( eta )( eta_half )( ( 4 * phi ) + 3 ) .Data ) THEN
            reference_JetPUestimate( eta )( eta_half )( phi ) := ToJetNoEcal( reference_PUestimate( eta )( eta_half )( ( 4 * phi ) + 3 ) , 0 , 0 );
          END IF;
          reference_JetPUestimate( eta )( eta_half )( phi ) .DataValid := TRUE;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta IN 0 TO( reference_JetSum'LENGTH - 1 ) LOOP
        FOR eta_half IN 0 TO cRegionInEta-1 LOOP
          IF( NOT reference_9x9Veto( eta )( eta_half )( ( 4 * phi ) + 0 ) .Data AND reference_TowerThresholds( eta )( eta_half )( ( 4 * phi ) + 0 ) .JetSeedThreshold ) THEN
            reference_JetSum( eta )( eta_half )( phi ) := ToJetNoEcal( reference_9x9Sum( eta )( eta_half )( ( 4 * phi ) + 0 ) , eta + 1 , MOD_PHI( ( 4 * phi ) + 0 ) + cCMScoordinateOffset );
          ELSIF( NOT reference_9x9Veto( eta )( eta_half )( ( 4 * phi ) + 1 ) .Data AND reference_TowerThresholds( eta )( eta_half )( ( 4 * phi ) + 1 ) .JetSeedThreshold ) THEN
            reference_JetSum( eta )( eta_half )( phi ) := ToJetNoEcal( reference_9x9Sum( eta )( eta_half )( ( 4 * phi ) + 1 ) , eta + 1 , MOD_PHI( ( 4 * phi ) + 1 ) + cCMScoordinateOffset );
          ELSIF( NOT reference_9x9Veto( eta )( eta_half )( ( 4 * phi ) + 2 ) .Data AND reference_TowerThresholds( eta )( eta_half )( ( 4 * phi ) + 2 ) .JetSeedThreshold ) THEN
            reference_JetSum( eta )( eta_half )( phi ) := ToJetNoEcal( reference_9x9Sum( eta )( eta_half )( ( 4 * phi ) + 2 ) , eta + 1 , MOD_PHI( ( 4 * phi ) + 2 ) + cCMScoordinateOffset );
          ELSIF( NOT reference_9x9Veto( eta )( eta_half )( ( 4 * phi ) + 3 ) .Data AND reference_TowerThresholds( eta )( eta_half )( ( 4 * phi ) + 3 ) .JetSeedThreshold ) THEN
            reference_JetSum( eta )( eta_half )( phi ) := ToJetNoEcal( reference_9x9Sum( eta )( eta_half )( ( 4 * phi ) + 3 ) , eta + 1 , MOD_PHI( ( 4 * phi ) + 3 ) + cCMScoordinateOffset );
          END IF;

          reference_JetSum( eta )( eta_half )( phi ) .eta       := eta + cCMScoordinateOffset;
          reference_JetSum( eta )( eta_half )( phi ) .DataValid := TRUE;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta IN 0 TO( reference_PUsubJet'LENGTH - 1 ) LOOP
        FOR eta_half IN 0 TO cRegionInEta-1 LOOP

          reference_PUsubJet( eta )( eta_half )( phi ) .Eta := reference_JetSum( eta )( eta_half )( phi ) .Eta;
          reference_PUsubJet( eta )( eta_half )( phi ) .Phi := reference_JetSum( eta )( eta_half )( phi ) .Phi;

          SignedEnergy                                      := TO_INTEGER( reference_JetSum( eta )( eta_half )( phi ) .Energy ) - TO_INTEGER( reference_JetPUestimate( eta )( eta_half )( phi ) .Energy );

          IF SignedEnergy < 0 THEN
            reference_PUsubJet( eta )( eta_half )( phi ) .Energy := ( OTHERS => '0' );
          ELSE
            reference_PUsubJet( eta )( eta_half )( phi ) .Energy := TO_UNSIGNED( SignedEnergy , 16 );
          END IF;

          IF( reference_JetPUestimate( eta )( eta_half )( phi ) .Energy > reference_JetSum( eta )( eta_half )( phi ) .Energy( 15 DOWNTO 2 ) ) THEN
            reference_PUsubJet( eta )( eta_half )( phi ) .LargePileUp := TRUE;
          ELSE
            reference_PUsubJet( eta )( eta_half )( phi ) .LargePileUp := FALSE;
          END IF;

          reference_PUsubJet( eta )( eta_half )( phi ) .DataValid := TRUE;
        END LOOP;


      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta IN 0 TO( reference_PUsubJet'LENGTH - 1 ) LOOP
        FOR eta_half IN 0 TO cRegionInEta-1 LOOP

          IF( reference_PUsubJet( eta )( eta_half )( phi ) .Energy >= x"200" ) THEN
            Energy( 7 DOWNTO 0 ) := "11111111";
          ELSE
            Energy( 7 DOWNTO 0 ) := reference_PUsubJet( eta )( eta_half )( phi ) .Energy( 8 DOWNTO 1 );
          END IF;

          JetMultiplier := UNSIGNED( L_JetCalibration_11to18( TO_INTEGER(
                                                                   UNSIGNED( EtaLUT_6to4( TO_INTEGER( TO_UNSIGNED( reference_PUsubJet( eta )( eta_half )( phi ) .eta , 6 ) ) ) )
                                                                 & UNSIGNED( EnergyCompressionLUT_8to4( TO_INTEGER( Energy( 7 DOWNTO 0 ) ) ) )
                                                              ) )( 9 DOWNTO 0 ) );

          JetOffset := SIGNED( L_JetCalibration_11to18( TO_INTEGER(
                                                                   UNSIGNED( EtaLUT_6to4( TO_INTEGER( TO_UNSIGNED( reference_PUsubJet( eta )( eta_half )( phi ) .eta , 6 ) ) ) )
                                                                 & UNSIGNED( EnergyCompressionLUT_8to4( TO_INTEGER( Energy( 7 DOWNTO 0 ) ) ) )
                                                              ) )( 17 DOWNTO 10 ) );


          reference_CalibratedJet( eta )( eta_half )( phi ) := reference_PUsubJet( eta )( eta_half )( phi );

          TempEnergy                                        := SIGNED( SHIFT_RIGHT( ( reference_PUsubJet( eta )( eta_half )( phi ) .Energy * JetMultiplier ) , 9 ) ) + JetOffset;

          IF TempEnergy( 25 DOWNTO 16 ) /= "0000000000" THEN
            reference_CalibratedJet( eta )( eta_half )( phi ) .Energy := ( OTHERS => '1' );
          ELSE
            reference_CalibratedJet( eta )( eta_half )( phi ) .Energy := UNSIGNED( TempEnergy( 15 DOWNTO 0 ) );
          END IF;

        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR eta IN 0 TO( reference_sortedJet'LENGTH - 1 ) LOOP
      FOR eta_half IN 0 TO cRegionInEta-1 LOOP
        reference_sortedJet( eta )( eta_half ) := reference_CalibratedJet( eta )( eta_half );

        JET_BITONIC_SORT( reference_sortedJet( eta )( eta_half ) , 0 , ( cTowerInPhi / 4 ) , false );
        reference_sortedJet( eta )( eta_half )( 6 TO( cTowerInPhi / 4 ) -1 ) := ( OTHERS => cEmptyJet );
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO( cRegionInEta-1 ) LOOP
      reference_accumulatedsortedJet( 0 )( eta_half )( 0 TO 5 ) := reference_sortedJet( 0 )( eta_half )( 0 TO 5 );
      FOR eta IN 1 TO( reference_accumulatedsortedJet'LENGTH - 1 ) LOOP
        reference_accumulatedsortedJet( eta )( eta_half )( 0 TO 5 )  := reference_accumulatedsortedJet( eta-1 )( eta_half )( 0 TO 5 );
        reference_accumulatedsortedJet( eta )( eta_half )( 6 TO 11 ) := reference_sortedJet( eta )( eta_half )( 0 TO 5 );
        JET_BITONIC_SORT( reference_accumulatedsortedJet( eta )( eta_half ) , 0 , 12 , false );
        reference_accumulatedsortedJet( eta )( eta_half )( 6 TO( cTowerInPhi / 4 ) -1 ) := ( OTHERS => cEmptyJet );
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO( cRegionInEta-1 ) LOOP
      FOR eta IN 0 TO( reference_jetPackedLink'LENGTH - 1 ) LOOP
        FOR candidate IN 0 TO 5 LOOP
          reference_jetPackedLink( eta )( ( 6 * eta_half ) + candidate ) .Data := "00" & TO_STD_LOGIC( reference_accumulatedsortedJet( eta )( eta_half )( candidate ) .LargePileUp ) &
                                                                                         STD_LOGIC_VECTOR( reference_accumulatedsortedJet( eta )( eta_half )( candidate ) .Energy ) &
                                                                                         STD_LOGIC_VECTOR( TO_UNSIGNED( reference_accumulatedsortedJet( eta )( eta_half )( candidate ) .Phi , 7 ) ) &
                                                                                         STD_LOGIC_VECTOR( TO_UNSIGNED( reference_accumulatedsortedJet( eta )( eta_half )( candidate ) .Eta , 6 ) );
          reference_jetPackedLink( eta )( ( 6 * eta_half ) + candidate ) .AccumulationComplete := ( eta = ( reference_accumulatedsortedJet'LENGTH - 1 ) );
          reference_jetPackedLink( eta )( ( 6 * eta_half ) + candidate ) .DataValid            := reference_accumulatedsortedJet( eta )( eta_half )( candidate ) .DataValid;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO( cRegionInEta-1 ) LOOP
      reference_demuxAccumulatedsortedJet( 0 )( eta_half )( 0 TO 5 ) := reference_accumulatedsortedJet( reference_accumulatedsortedJet'LENGTH - 1 )( eta_half )( 0 TO 5 );
    END LOOP;

    FOR index IN 0 TO 5 LOOP
      reference_demuxAccumulatedsortedJet( 0 )( 1 )( index ) .EtaHalf := 1;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
  reference_mergedsortedJet( 0 )( 0 )( 0 TO 5 )  := reference_demuxAccumulatedsortedJet( 0 )( 0 )( 0 TO 5 );
  reference_mergedsortedJet( 0 )( 0 )( 6 TO 11 ) := reference_demuxAccumulatedsortedJet( 0 )( 1 )( 0 TO 5 );
  JET_BITONIC_SORT( reference_mergedsortedJet( 0 )( 0 ) , 0 , 12 , false );
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
  FOR index IN 0 TO 11 LOOP

    IF( reference_mergedSortedJet( 0 )( 0 )( index ) .EtaHalf = 1 ) THEN
      reference_GtFormattedJet( 0 )( index ) .Eta := SIGNED( Y_localEtaToGT_9to8(
        TO_INTEGER( '1' & TO_UNSIGNED( reference_mergedSortedJet( 0 )( 0 )( index ) .Eta , 6 ) & "10" ) ) );
    ELSE
      reference_GtFormattedJet( 0 )( index ) .Eta := SIGNED( Y_localEtaToGT_9to8(
        TO_INTEGER( '0' & TO_UNSIGNED( reference_mergedSortedJet( 0 )( 0 )( index ) .Eta , 6 ) & "10" ) ) );
    END IF;

    reference_GtFormattedJet( 0 )( index ) .Phi := UNSIGNED( Z_localPhiToGT_9to8(
      TO_INTEGER( TO_UNSIGNED( reference_mergedSortedJet( 0 )( 0 )( index ) .Phi , 7 ) & "10" )
    ) );

    IF( reference_mergedsortedJet( 0 )( 0 )( index ) .Energy > x"07FF" ) THEN
      reference_gtFormattedJet( 0 )( index ) .Energy := ( OTHERS => '1' );
    ELSE
      reference_gtFormattedJet( 0 )( index ) .Energy := reference_mergedsortedJet( 0 )( 0 )( index ) .Energy( 10 DOWNTO 0 );
    END IF;

    reference_gtFormattedJet( 0 )( index ) .DataValid := reference_mergedsortedJet( 0 )( 0 )( index ) .DataValid;
  END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
  FOR index IN 0 TO 11 LOOP
    reference_demuxjetPackedLink( 0 )( index ) .Data := "00000" &
                                                        STD_LOGIC_VECTOR( reference_gtFormattedJet( 0 )( index ) .Phi ) &
                                                        STD_LOGIC_VECTOR( reference_gtFormattedJet( 0 )( index ) .Eta ) &
                                                        STD_LOGIC_VECTOR( reference_gtFormattedJet( 0 )( index ) .Energy );
    reference_demuxjetPackedLink( 0 )( index ) .DataValid := reference_gtFormattedJet( 0 )( index ) .DataValid;
  END LOOP;
-- -----------------------------------------------------------------------------------------------------


  END JetReference;



  PROCEDURE JetChecker
  (
    VARIABLE clk_count                           : IN INTEGER;
    CONSTANT timeout                             : IN INTEGER;
-- -------------
    VARIABLE reference_3x3Sum                    : IN tJetPipe;
    SIGNAL sum3x3Pipe                            : IN tJetPipe;
    VARIABLE retval3x3Sum                        : INOUT tRetVal;
-- -------------
    VARIABLE reference_9x3Sum                    : IN tJetPipe;
    SIGNAL strips9x3Pipe                         : IN tJetPipe;
    VARIABLE retval9x3Sum                        : INOUT tRetVal;
-- -------------
    VARIABLE reference_3x9Sum                    : IN tJetPipe;
    SIGNAL strips3x9Pipe                         : IN tJetPipe;
    VARIABLE retval3x9Sum                        : INOUT tRetVal;
-- -------------
    VARIABLE reference_9x9Veto                   : IN tComparisonPipe;
    SIGNAL jets9x9VetoPipe                       : IN tComparisonPipe;
    VARIABLE retval9x9Veto                       : INOUT tRetVal;
-- -------------
    VARIABLE reference_JetSum                    : IN tJetPipe;
    SIGNAL filteredJetPipe                       : IN tJetPipe;
    VARIABLE retvalJetSum                        : INOUT tRetVal;
-- -------------
    VARIABLE reference_JetPUestimate             : IN tJetPipe;
    SIGNAL filteredPileUpPipe                    : IN tJetPipe;
    VARIABLE retvalJetPUestimate                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_PUsubJet                  : IN tJetPipe;
    SIGNAL pileUpSubtractedJetPipe               : IN tJetPipe;
    VARIABLE retvalPUsubJet                      : INOUT tRetVal;
-- -------------
    VARIABLE reference_CalibratedJet             : IN tJetPipe;
    SIGNAL CalibratedJetPipe                     : IN tJetPipe;
    VARIABLE retvalCalibratedJet                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_sortedJet                 : IN tJetPipe;
    SIGNAL sortedJetPipe                         : IN tJetPipe;
    VARIABLE retvalSortedJet                     : INOUT tRetVal;
-- -------------
    VARIABLE reference_accumulatedsortedJet      : IN tJetPipe;
    SIGNAL accumulatedSortedJetPipe              : IN tJetPipe;
    VARIABLE retvalAccumulatedsortedJet          : INOUT tRetVal;
-- -------------
    VARIABLE reference_jetPackedLink             : IN tPackedLinkPipe;
    SIGNAL jetPackedLinkPipe                     : IN tPackedLinkPipe;
    VARIABLE retvalJetPackedLink                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedsortedJet : IN tJetPipe;
    SIGNAL demuxAccumulatedSortedJetPipe         : IN tJetPipe;
    VARIABLE retvalDemuxAccumulatedsortedJet     : INOUT tRetVal;
-- -------------
    VARIABLE reference_mergedsortedJet           : IN tJetPipe;
    SIGNAL mergedSortedJetPipe                   : IN tJetPipe;
    VARIABLE retvalMergedsortedJet               : INOUT tRetVal;
-- -------------
    VARIABLE reference_gtFormattedJet            : IN tGtFormattedJetPipe;
    SIGNAL gtFormattedJetPipe                    : IN tGtFormattedJetPipe;
    VARIABLE retvalGtFormattedJet                : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxjetPackedLink        : IN tPackedLinkPipe;
    SIGNAL demuxjetPackedLinkPipe                : IN tPackedLinkPipe;
    VARIABLE retvaldemuxJetPackedLink            : INOUT tRetVal;
-- -------------
    CONSTANT debug                               : IN BOOLEAN := false
-- -------------
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_3x3Sum'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Jets 3x3 Sum" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_sum3x3 , -- expected latency
                    timeout , -- timeout
                    retval3x3Sum( index ) , -- return value
                    ( reference_3x3Sum( index ) = sum3x3Pipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_9x3Sum'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Jets 9x3 Sum" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_strips9x3 , -- expected latency
                    timeout , -- timeout
                    retval9x3Sum( index ) , -- return value
                    ( reference_9x3Sum( index ) = strips9x3Pipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_3x9Sum'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Jets 3x9 Sum" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_strips3x9 , -- expected latency
                    timeout , -- timeout
                    retval3x9Sum( index ) , -- return value
                    ( reference_3x9Sum( index ) = strips3x9Pipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_9x9Veto'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Jets 9x9 Veto" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_jets9x9Veto , -- expected latency
                    timeout , -- timeout
                    retval9x9Veto( index ) , -- return value
                    ( reference_9x9Veto( index ) = jets9x9VetoPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_JetSum'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Jets 9x9 Filtered" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_filteredJets , -- expected latency
                    timeout , -- timeout
                    retvalJetSum( index ) , -- return value
                    ( reference_JetSum( index ) = filteredJetPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_JetPUestimate'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Jets Filtered PU estimate" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_pileup , -- expected latency
                    timeout , -- timeout
                    retvalJetPUestimate( index ) , -- return value
                    ( reference_JetPUestimate( index ) = FilteredPileUpPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_PUsubJet'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Jets 9x9 PU subtracted Sum" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_pileUpSubtractedJets , -- expected latency
                    timeout , -- timeout
                    retvalPUsubJet( index ) , -- return value
                    ( reference_PUsubJet( index ) = pileUpSubtractedJetPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_CalibratedJet'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Jets 9x9 Calibrated Sum" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_CalibratedJets , -- expected latency
                    timeout , -- timeout
                    retvalCalibratedJet( index ) , -- return value
                    ( reference_CalibratedJet( index ) = CalibratedJetPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_sortedJet'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Sorted Jets 9x9" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_sortedJets , -- expected latency
                    timeout , -- timeout
                    retvalSortedJet( index ) , -- return value
                    CompareSortedJets( reference_sortedJet( index ) , sortedJetPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_accumulatedsortedJet'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Accumulated Sorted Jets 9x9" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_accumulatedSortedJets , -- expected latency
                    timeout , -- timeout
                    retvalAccumulatedsortedJet( index ) , -- return value
                    CompareSortedJets( reference_accumulatedsortedJet( index ) , accumulatedSortedJetPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_jetPackedLink'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Jet Packed Link" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_jetPackedLink , -- expected latency
                    timeout , -- timeout
                    retvalJetPackedLink( index ) , -- return value
                    ( reference_jetPackedLink( index ) = jetPackedLinkPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_demuxAccumulatedsortedJet'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux Accumulated Sorted Jets 9x9" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_demuxAccumulatedSortedJets , -- expected latency
                    timeout , -- timeout
                    retvalDemuxAccumulatedsortedJet( index ) , -- return value
                    ( reference_demuxAccumulatedsortedJet( index ) = demuxAccumulatedSortedJetPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_MergedsortedJet'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Merged Sorted Jets 9x9" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_MergedSortedJets , -- expected latency
                    timeout , -- timeout
                    retvalMergedsortedJet( index ) , -- return value
                    CompareSortedJets( reference_MergedsortedJet( index ) , MergedSortedJetPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_gtFormattedJet'LENGTH - 1 ) LOOP
      CHECK_RESULT( "GT Formatted Jets 9x9" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_gtFormattedJets , -- expected latency
                    timeout , -- timeout
                    retvalGtFormattedJet( index ) , -- return value
                    ( reference_gtFormattedJet( index ) = gtFormattedJetPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_DemuxjetPackedLink'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux Jet Packed Link" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_DemuxjetPackedLink , -- expected latency
                    timeout , -- timeout
                    retvalDemuxJetPackedLink( index ) , -- return value
                    ( reference_DemuxjetPackedLink( index ) = DemuxjetPackedLinkPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

  END JetChecker;



  PROCEDURE JetReport
  (
    VARIABLE retval3x3Sum                    : IN tRetVal;
    VARIABLE retval9x3Sum                    : IN tRetVal;
    VARIABLE retval3x9Sum                    : IN tRetVal;
    VARIABLE retval9x9Veto                   : IN tRetVal;
    VARIABLE retvalJetSum                    : IN tRetVal;
    VARIABLE retvalJetPUestimate             : IN tRetVal;
    VARIABLE retvalPUsubJet                  : IN tRetVal;
    VARIABLE retvalCalibratedJet             : IN tRetVal;
    VARIABLE retvalSortedJet                 : IN tRetVal;
    VARIABLE retvalAccumulatedsortedJet      : IN tRetVal;
    VARIABLE retvalJetPackedLink             : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedsortedJet : IN tRetVal;
    VARIABLE retvalMergedsortedJet           : IN tRetVal;
    VARIABLE retvalGtFormattedJet            : IN tRetVal;
    VARIABLE retvalDemuxJetPackedLink        : IN tRetVal
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    REPORT_RESULT( "Jets 3x3 Sum" , retval3x3Sum );
    REPORT_RESULT( "Jets 9x3 Sum" , retval9x3Sum );
    REPORT_RESULT( "Jets 3x9 Sum" , retval3x9Sum );
    REPORT_RESULT( "Jets Veto" , retval9x9Veto );
    REPORT_RESULT( "Jet Sum" , retvalJetSum );
    REPORT_RESULT( "Jet PU estimate" , retvalJetPUestimate );
    REPORT_RESULT( "PU subtracted Jet Sum" , retvalPUsubJet );
    REPORT_RESULT( "Calibrated Jet Sum" , retvalCalibratedJet );
    REPORT_RESULT( "Sorted Jets" , retvalSortedJet );
    REPORT_RESULT( "Accumulated Sorted Jets" , retvalAccumulatedsortedJet );
    REPORT_RESULT( "Jet Packed Link" , retvalJetPackedLink );
    REPORT_RESULT( "Demux Accumulated Sorted Jets" , retvalDemuxAccumulatedsortedJet );
    REPORT_RESULT( "Merged Sorted Jets" , retvalMergedsortedJet );
    REPORT_RESULT( "GT Formatted Jets" , retvalGtFormattedJet );
    REPORT_RESULT( "Demux Jet Packed Link" , retvalDemuxJetPackedLink );
-- -----------------------------------------------------------------------------------------------------
  END JetReport;



  IMPURE FUNCTION PileUpEstimate( aStrip1 , aStrip2 , aStrip3 , aStrip4 : tJet ) RETURN tJet IS
    VARIABLE lStrip1 , lStrip2 , lStrip3 , lStrip4                      : tJet;
    VARIABLE temp                                                       : tJet;
  BEGIN

-- -----------------------------------------------------------------------------------------------------
      IF( aStrip1.Energy < aStrip2.Energy ) THEN
        lStrip1 := aStrip1;
        lStrip2 := aStrip2;
      ELSE
        lStrip1 := aStrip2;
        lStrip2 := aStrip1;
      END IF;
-- lStrip1 < lStrip2

      IF( aStrip3.Energy < aStrip4.Energy ) THEN
        lStrip3 := aStrip3;
        lStrip4 := aStrip4;
      ELSE
        lStrip3 := aStrip4;
        lStrip4 := aStrip3;
      END IF;
-- lStrip3 < lStrip4

-- SO... lStrip2 or lStrip4 must be the highest

-- If lStrip2 > lStrip4 swap them
      IF( lStrip2.Energy > lStrip4.Energy ) THEN
        temp    := lStrip2;
        lStrip2 := lStrip4;
        lStrip4 := temp;
      END IF;

-- SO... lStrip4 must be the highest

        temp.Energy    := lStrip1.Energy + lStrip2.Energy + lStrip3.Energy;
-- temp.Energy := temp.Energy( 13 DOWNTO 0 ) & "00";
        temp.DataValid := TRUE;

      RETURN temp;
-- -----------------------------------------------------------------------------------------------------
  END PileUpEstimate;


  IMPURE FUNCTION JET_OVERLAP_VETO( EtaCentre : INTEGER ; PhiCentre : INTEGER ; Towers : tTowerPipe ) RETURN BOOLEAN IS
    VARIABLE s                                : LINE;
    VARIABLE Central , Comparison             : tJet;
    VARIABLE Veto                             : BOOLEAN := FALSE;

    TYPE tMaskX IS ARRAY( -4 TO 4 ) OF BOOLEAN;
    TYPE tMask  IS ARRAY( -4 TO 4 ) OF tMaskX;

    CONSTANT GTmask : tMask :=
    (
      ( TRUE , TRUE , TRUE , TRUE , TRUE , TRUE , TRUE , TRUE , TRUE ) ,
      ( TRUE , TRUE , TRUE , TRUE , TRUE , TRUE , TRUE , TRUE , FALSE ) ,
      ( TRUE , TRUE , TRUE , TRUE , TRUE , TRUE , TRUE , FALSE , FALSE ) ,
      ( TRUE , TRUE , TRUE , TRUE , TRUE , TRUE , FALSE , FALSE , FALSE ) ,
      ( TRUE , TRUE , TRUE , TRUE , TRUE , FALSE , FALSE , FALSE , FALSE ) ,
      ( TRUE , TRUE , TRUE , FALSE , FALSE , FALSE , FALSE , FALSE , FALSE ) ,
      ( TRUE , TRUE , FALSE , FALSE , FALSE , FALSE , FALSE , FALSE , FALSE ) ,
      ( TRUE , FALSE , FALSE , FALSE , FALSE , FALSE , FALSE , FALSE , FALSE ) ,
      ( FALSE , FALSE , FALSE , FALSE , FALSE , FALSE , FALSE , FALSE , FALSE )
    );

  BEGIN
-- -----------------------------------------------------------------------------------------------------
    Central := ToJet( GetTower( EtaCentre , PhiCentre , Towers ) );

    IF Central.Energy = 0 THEN -- Will always be less than or equal to its neighbours
      RETURN True;
    END IF;

    FOR DeltaEta IN -4 TO 4 LOOP
      FOR DeltaPhi IN -4 TO 4 LOOP
        Comparison := ToJet( GetTower( EtaCentre + DeltaEta , PhiCentre + DeltaPhi , Towers ) );

        IF GTmask( DeltaEta )( DeltaPhi ) THEN
          Veto := Veto OR( Central.Energy < Comparison .Energy );
        ELSE
          Veto := Veto OR( Central.Energy <= Comparison .Energy );
        END IF;

      END LOOP;
    END LOOP;

    RETURN Veto;
-- -----------------------------------------------------------------------------------------------------
  END JET_OVERLAP_VETO;


  PROCEDURE JET_BITONIC_SORT( VARIABLE a : INOUT tJetInPhi ; lo , n : IN INTEGER ; dir : IN BOOLEAN ) IS
    VARIABLE m                           : INTEGER;
  BEGIN
-- -----------------------------------------------------------------------------------------------------
    IF n > 1 THEN
        m := n / 2;
        JET_BITONIC_SORT( a , lo , m , NOT dir );
        JET_BITONIC_SORT( a , lo + m , n-m , dir );
        JET_BITONIC_MERGE( a , lo , n , dir );
    END IF;
-- -----------------------------------------------------------------------------------------------------
  END JET_BITONIC_SORT;

  PROCEDURE JET_BITONIC_MERGE( VARIABLE a : INOUT tJetInPhi ; lo , n : IN INTEGER ; dir : IN BOOLEAN ) IS
    VARIABLE m                            : INTEGER;
    VARIABLE temp                         : tJet;
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
      JET_BITONIC_MERGE( a , lo , m , dir );
      JET_BITONIC_MERGE( a , lo + m , n-m , dir );
    END IF;
-- -----------------------------------------------------------------------------------------------------
  END JET_BITONIC_MERGE;


  FUNCTION CompareSortedJets( Left , Right : tJetInEtaPhi ) RETURN BOOLEAN IS
  BEGIN
    RETURN left = right;
--FOR j IN 0 TO cRegionInEta-1 LOOP
-- FOR i IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
-- IF( ( Left( j )( i ) .Energy /= Right( j )( i ) .Energy ) OR( Left( j )( i ) .Eta /= Right( j )( i ) .Eta ) OR( Left( j )( i ) .Phi /= Right( j )( i ) .Phi ) ) THEN
-- RETURN false;
-- END IF;
-- END LOOP;
--END LOOP;
--RETURN true;
  END CompareSortedJets;



-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE OutputCandidate( VARIABLE clk : IN INTEGER ; CONSTANT latency : IN INTEGER ; SIGNAL data : IN tComparisonInEtaPhi ; FILE f : TEXT ) IS
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
      WRITE( s , STRING' ( "Data" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "DataValid" ) , RIGHT , 11 );
      WRITELINE( f , s );

    ELSE

      algotime := clk-latency-1;
      frame    := algotime MOD 54;
      event    := algotime / 54;

      FOR j IN 0 TO( cRegionInEta-1 ) LOOP
        FOR i IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
          IF NOT data( j )( i ) .Data THEN
            WRITE( s , clk , RIGHT , 11 );
            WRITE( s , algotime , RIGHT , 11 );
            WRITE( s , event , RIGHT , 11 );
            WRITE( s , frame , RIGHT , 11 );
            WRITE( s , j , RIGHT , 11 );
            WRITE( s , i , RIGHT , 11 );
            WRITE( s , STRING' ( "|" ) , RIGHT , 11 );
            WRITE( s , data( j )( i ) .Data , RIGHT , 11 );
            WRITE( s , data( j )( i ) .DataValid , RIGHT , 11 );
            WRITELINE( f , s );
          END IF;
        END LOOP;
      END LOOP;
    END IF;
  END OutputCandidate;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


END PACKAGE BODY JetReference;
