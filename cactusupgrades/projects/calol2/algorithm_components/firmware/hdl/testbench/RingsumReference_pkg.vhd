
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.math_real.ALL ; -- for UNIFORM , TRUNC functions

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

--! Using the Calo-L2 "ring" helper functions
USE work.ring_functions.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! Using the Calo-L2 "helper" helper functions
USE work.helper_functions.ALL;

--! Using the Calo-L2 "Tower" testbench suite
USE work.TowerReference.ALL;
--! Using the Calo-L2 "Jet" testbench suite
USE work.JetReference.ALL;

--! Writing to and from files
USE STD.TEXTIO.ALL;
--! Writing to and from files
USE IEEE.STD_LOGIC_TEXTIO.ALL;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
PACKAGE RingsumReference IS

  CONSTANT latency_TowerCount                       : INTEGER := latency_towerFormer + 6;
  CONSTANT latency_ETandMETring                     : INTEGER := latency_towerFormer + 6;
  CONSTANT latency_HTandMHTring                     : INTEGER := latency_calibratedJets + 5;
  CONSTANT latency_accumulatedTowerCount            : INTEGER := latency_TowerCount + 1;
  CONSTANT latency_calibratedETandMETring           : INTEGER := latency_ETandMETring + 8;
  CONSTANT latency_accumulatedETandMETring          : INTEGER := latency_CalibratedETandMETring + 1;
  CONSTANT latency_accumulatedHTandMHTring          : INTEGER := latency_HTandMHTring + 1;

  CONSTANT latency_ClusterPileupEstimation          : INTEGER := latency_TowerCount + 8;

  CONSTANT latency_ETandMETPackedLink               : INTEGER := latency_accumulatedETandMETring + cTestbenchTowersInHalfEta;
  CONSTANT latency_HTandMHTPackedLink               : INTEGER := latency_accumulatedHTandMHTring + cTestbenchTowersInHalfEta;
  CONSTANT latency_AuxInfoPackedLink                : INTEGER := ( latency_accumulatedETandMETring - 5 ) + cTestbenchTowersInHalfEta;


  CONSTANT latency_DemuxAccumulatedETandMETring     : INTEGER := latency_ETandMETPackedLink + 26;
  CONSTANT latency_DemuxAccumulatedETandMETnoHFring : INTEGER := latency_ETandMETPackedLink + 27;
  CONSTANT latency_DemuxAccumulatedHTandMHTring     : INTEGER := latency_HTandMHTPackedLink + 12;
  CONSTANT latency_DemuxAccumulatedHTandMHTnoHFring : INTEGER := latency_HTandMHTPackedLink + 13;
  CONSTANT latency_polarETandMETring                : INTEGER := latency_DemuxAccumulatedETandMETring + 12;
  CONSTANT latency_polarETandMETnoHFring            : INTEGER := latency_DemuxAccumulatedETandMETnoHFring + 12;
  CONSTANT latency_polarHTandMHTring                : INTEGER := latency_DemuxAccumulatedHTandMHTring + 12;
  CONSTANT latency_polarHTandMHTnoHFring            : INTEGER := latency_DemuxAccumulatedHTandMHTnoHFring + 12;
  CONSTANT latency_gtFormattedETandMETring          : INTEGER := latency_polarETandMETring + 1;
  CONSTANT latency_gtFormattedETandMETnoHFring      : INTEGER := latency_polarETandMETnoHFring + 1;
  CONSTANT latency_gtFormattedHTandMHTring          : INTEGER := latency_polarHTandMHTring + 1;
  CONSTANT latency_gtFormattedHTandMHTnoHFring      : INTEGER := latency_polarHTandMHTnoHFring + 1;
  CONSTANT latency_DemuxETandMETPackedLink          : INTEGER := latency_gtFormattedETandMETring;
  CONSTANT latency_DemuxETandMETnoHFPackedLink      : INTEGER := latency_gtFormattedETandMETnoHFring;
  CONSTANT latency_DemuxHTandMHTPackedLink          : INTEGER := latency_gtFormattedHTandMHTring;
  CONSTANT latency_DemuxHTandMHTnoHFPackedLink      : INTEGER := latency_gtFormattedHTandMHTnoHFring;



  PROCEDURE RingsumReference
  (
    VARIABLE reference_Towers                            : IN tTowerPipe;
    VARIABLE reference_CalibratedJets                    : IN tJetPipe;
    VARIABLE reference_TowerCount                        : INOUT tRingSegmentPipe2;
    VARIABLE reference_ETandMETrings                     : INOUT tRingSegmentPipe2;
    VARIABLE reference_HTandMHTrings                     : INOUT tRingSegmentPipe2;
    VARIABLE reference_accumulatedTowerCount             : INOUT tRingSegmentPipe2;
    VARIABLE reference_calibratedETandMETrings           : INOUT tRingSegmentPipe2;
    VARIABLE reference_accumulatedETandMETrings          : INOUT tRingSegmentPipe2;
    VARIABLE reference_accumulatedHTandMHTrings          : INOUT tRingSegmentPipe2;
    VARIABLE reference_ClusterPileupEstimation           : INOUT tPileupEstimationPipe;
    VARIABLE reference_ETandMETPackedLink                : INOUT tPackedLinkPipe;
    VARIABLE reference_HTandMHTPackedLink                : INOUT tPackedLinkPipe;
    VARIABLE reference_AuxInfoPackedLink                 : INOUT tPackedLinkPipe;
    VARIABLE reference_demuxAccumulatedETandMETrings     : INOUT tRingSegmentPipe2;
    VARIABLE reference_demuxAccumulatedETandMETnoHFrings : INOUT tRingSegmentPipe2;
    VARIABLE reference_demuxAccumulatedHTandMHTrings     : INOUT tRingSegmentPipe2;
    VARIABLE reference_demuxAccumulatedHTandMHTnoHFrings : INOUT tRingSegmentPipe2;
    VARIABLE reference_polarETandMETrings                : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_polarETandMETnoHFrings            : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_polarHTandMHTrings                : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_polarHTandMHTnoHFrings            : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_gtFormattedETandMETrings          : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_gtFormattedETandMETnoHFrings      : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_gtFormattedHTandMHTrings          : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_gtFormattedHTandMHTnoHFrings      : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_DemuxETandMETPackedLink           : INOUT tPackedLinkPipe;
    VARIABLE reference_DemuxETandMETnoHFPackedLink       : INOUT tPackedLinkPipe;
    VARIABLE reference_DemuxHTandMHTPackedLink           : INOUT tPackedLinkPipe;
    VARIABLE reference_DemuxHTandMHTnoHFPackedLink       : INOUT tPackedLinkPipe
  );

  PROCEDURE RingsumChecker
  (
    VARIABLE clk_count                                   : IN INTEGER;
    CONSTANT timeout                                     : IN INTEGER;
-- -------------
    VARIABLE reference_TowerCount                        : IN tRingSegmentPipe2;
    SIGNAL TowerCountPipe                                : IN tRingSegmentPipe2;
    VARIABLE retvalTowerCount                            : INOUT tRetVal;
-- -------------
    VARIABLE reference_ETandMETrings                     : IN tRingSegmentPipe2;
    SIGNAL ETandMETringPipe                              : IN tRingSegmentPipe2;
    VARIABLE retvalETandMETrings                         : INOUT tRetVal;
-- -------------
    VARIABLE reference_HTandMHTrings                     : IN tRingSegmentPipe2;
    SIGNAL HTandMHTringPipe                              : IN tRingSegmentPipe2;
    VARIABLE retvalHTandMHTrings                         : INOUT tRetVal;
-- -------------
    VARIABLE reference_accumulatedTowerCount             : IN tRingSegmentPipe2;
    SIGNAL accumulatedTowerCountPipe                     : IN tRingSegmentPipe2;
    VARIABLE retvalAccumulatedTowerCount                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_calibratedETandMETrings           : IN tRingSegmentPipe2;
    SIGNAL calibratedETandMETringPipe                    : IN tRingSegmentPipe2;
    VARIABLE retvalCalibratedETandMETrings               : INOUT tRetVal;
-- -------------
    VARIABLE reference_accumulatedETandMETrings          : IN tRingSegmentPipe2;
    SIGNAL accumulatedETandMETringPipe                   : IN tRingSegmentPipe2;
    VARIABLE retvalAccumulatedETandMETrings              : INOUT tRetVal;
-- -------------
    VARIABLE reference_accumulatedHTandMHTrings          : IN tRingSegmentPipe2;
    SIGNAL accumulatedHTandMHTringPipe                   : IN tRingSegmentPipe2;
    VARIABLE retvalAccumulatedHTandMHTrings              : INOUT tRetVal;
-- -------------
    VARIABLE reference_ClusterPileupEstimation           : IN tPileupEstimationPipe;
    SIGNAL ClusterPileupEstimationPipe                   : IN tPileupEstimationPipe;
    VARIABLE retvalClusterPileupEstimation               : INOUT tRetVal;
---- -------------
    VARIABLE reference_ETandMETPackedLink                : IN tPackedLinkPipe;
    SIGNAL ETandMETPackedLinkPipe                        : IN tPackedLinkPipe;
    VARIABLE retvalETandMETPackedLink                    : INOUT tRetVal;
-- -------------
    VARIABLE reference_HTandMHTPackedLink                : IN tPackedLinkPipe;
    SIGNAL HTandMHTPackedLinkPipe                        : IN tPackedLinkPipe;
    VARIABLE retvalHTandMHTPackedLink                    : INOUT tRetVal;
-- -------------
    VARIABLE reference_AuxInfoPackedLink                 : IN tPackedLinkPipe;
    SIGNAL AuxInfoPackedLinkPipe                         : IN tPackedLinkPipe;
    VARIABLE retvalAuxInfoPackedLink                     : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedETandMETrings     : IN tRingSegmentPipe2;
    SIGNAL demuxAccumulatedETandMETringPipe              : IN tRingSegmentPipe2;
    VARIABLE retvalDemuxAccumulatedETandMETrings         : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedETandMETnoHFrings : IN tRingSegmentPipe2;
    SIGNAL demuxAccumulatedETandMETnoHFringPipe          : IN tRingSegmentPipe2;
    VARIABLE retvalDemuxAccumulatedETandMETnoHFrings     : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedHTandMHTrings     : IN tRingSegmentPipe2;
    SIGNAL demuxAccumulatedHTandMHTringPipe              : IN tRingSegmentPipe2;
    VARIABLE retvalDemuxAccumulatedHTandMHTrings         : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedHTandMHTnoHFrings : IN tRingSegmentPipe2;
    SIGNAL demuxAccumulatedHTandMHTnoHFringPipe          : IN tRingSegmentPipe2;
    VARIABLE retvalDemuxAccumulatedHTandMHTnoHFrings     : INOUT tRetVal;
-- -------------
    VARIABLE reference_PolarETandMETrings                : IN tPolarRingSegmentPipe;
    SIGNAL PolarETandMETringPipe                         : IN tPolarRingSegmentPipe;
    VARIABLE retvalPolarETandMETrings                    : INOUT tRetVal;
-- -------------
    VARIABLE reference_PolarETandMETnoHFrings            : IN tPolarRingSegmentPipe;
    SIGNAL PolarETandMETnoHFringPipe                     : IN tPolarRingSegmentPipe;
    VARIABLE retvalPolarETandMETnoHFrings                : INOUT tRetVal;
-- -------------
    VARIABLE reference_PolarHTandMHTrings                : IN tPolarRingSegmentPipe;
    SIGNAL PolarHTandMHTringPipe                         : IN tPolarRingSegmentPipe;
    VARIABLE retvalPolarHTandMHTrings                    : INOUT tRetVal;
-- -------------
    VARIABLE reference_PolarHTandMHTnoHFrings            : IN tPolarRingSegmentPipe;
    SIGNAL PolarHTandMHTnoHFringPipe                     : IN tPolarRingSegmentPipe;
    VARIABLE retvalPolarHTandMHTnoHFrings                : INOUT tRetVal;
-- -------------
    VARIABLE reference_GtFormattedETandMETrings          : IN tPolarRingSegmentPipe;
    SIGNAL GtFormattedETandMETringPipe                   : IN tPolarRingSegmentPipe;
    VARIABLE retvalGtFormattedETandMETrings              : INOUT tRetVal;
-- -------------
    VARIABLE reference_GtFormattedETandMETnoHFrings      : IN tPolarRingSegmentPipe;
    SIGNAL GtFormattedETandMETnoHFringPipe               : IN tPolarRingSegmentPipe;
    VARIABLE retvalGtFormattedETandMETnoHFrings          : INOUT tRetVal;
-- -------------
    VARIABLE reference_GtFormattedHTandMHTrings          : IN tPolarRingSegmentPipe;
    SIGNAL GtFormattedHTandMHTringPipe                   : IN tPolarRingSegmentPipe;
    VARIABLE retvalGtFormattedHTandMHTrings              : INOUT tRetVal;
-- -------------
    VARIABLE reference_GtFormattedHTandMHTnoHFrings      : IN tPolarRingSegmentPipe;
    SIGNAL GtFormattedHTandMHTnoHFringPipe               : IN tPolarRingSegmentPipe;
    VARIABLE retvalGtFormattedHTandMHTnoHFrings          : INOUT tRetVal;
-- -------------
    VARIABLE reference_DemuxETandMETPackedLink           : IN tPackedLinkPipe;
    SIGNAL DemuxETandMETPackedLinkPipe                   : IN tPackedLinkPipe;
    VARIABLE retvalDemuxETandMETPackedLink               : INOUT tRetVal;
-- -------------
    VARIABLE reference_DemuxETandMETnoHFPackedLink       : IN tPackedLinkPipe;
    SIGNAL DemuxETandMETnoHFPackedLinkPipe               : IN tPackedLinkPipe;
    VARIABLE retvalDemuxETandMETnoHFPackedLink           : INOUT tRetVal;
-- -------------
    VARIABLE reference_DemuxHTandMHTPackedLink           : IN tPackedLinkPipe;
    SIGNAL DemuxHTandMHTPackedLinkPipe                   : IN tPackedLinkPipe;
    VARIABLE retvalDemuxHTandMHTPackedLink               : INOUT tRetVal;
-- -------------
    VARIABLE reference_DemuxHTandMHTnoHFPackedLink       : IN tPackedLinkPipe;
    SIGNAL DemuxHTandMHTnoHFPackedLinkPipe               : IN tPackedLinkPipe;
    VARIABLE retvalDemuxHTandMHTnoHFPackedLink           : INOUT tRetVal;
-- -------------
    CONSTANT debug                                       : IN BOOLEAN := false
-- -------------
  );

  PROCEDURE RingsumReport
  (
    VARIABLE retvalTowerCount                        : IN tRetVal;
    VARIABLE retvalETandMETrings                     : IN tRetVal;
    VARIABLE retvalHTandMHTrings                     : IN tRetVal;
    VARIABLE retvalAccumulatedTowerCount             : IN tRetVal;
    VARIABLE retvalCalibratedETandMETrings           : IN tRetVal;
    VARIABLE retvalAccumulatedETandMETrings          : IN tRetVal;
    VARIABLE retvalAccumulatedHTandMHTrings          : IN tRetVal;
    VARIABLE retvalClusterPileupEstimation           : IN tRetVal;
    VARIABLE retvalETandMETPackedLink                : IN tRetVal;
    VARIABLE retvalHTandMHTPackedLink                : IN tRetVal;
    VARIABLE retvalAuxInfoPackedLink                 : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedETandMETrings     : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedETandMETnoHFrings : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedHTandMHTrings     : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedHTandMHTnoHFrings : IN tRetVal;
    VARIABLE retvalPolarETandMETrings                : IN tRetVal;
    VARIABLE retvalPolarETandMETNoHFrings            : IN tRetVal;
    VARIABLE retvalPolarHTandMHTrings                : IN tRetVal;
    VARIABLE retvalPolarHTandMHTnoHFrings            : IN tRetVal;
    VARIABLE retvalGtFormattedETandMETrings          : IN tRetVal;
    VARIABLE retvalGtFormattedETandMETNoHFrings      : IN tRetVal;
    VARIABLE retvalGtFormattedHTandMHTrings          : IN tRetVal;
    VARIABLE retvalGtFormattedHTandMHTnoHFrings      : IN tRetVal;
    VARIABLE retvalDemuxETandMETPackedLink           : IN tRetVal;
    VARIABLE retvalDemuxETandMETNoHFPackedLink       : IN tRetVal;
    VARIABLE retvalDemuxHTandMHTPackedLink           : IN tRetVal;
    VARIABLE retvalDemuxHTandMHTnoHFPackedLink       : IN tRetVal
  );

  FUNCTION CONSISTANT( Left , Right : tPolarRingSegment ) RETURN BOOLEAN;

END PACKAGE RingsumReference;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------



-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
PACKAGE BODY RingsumReference IS

  PROCEDURE RingsumReference
  (
    VARIABLE reference_Towers                            : IN tTowerPipe;
    VARIABLE reference_CalibratedJets                    : IN tJetPipe;
    VARIABLE reference_TowerCount                        : INOUT tRingSegmentPipe2;
    VARIABLE reference_ETandMETrings                     : INOUT tRingSegmentPipe2;
    VARIABLE reference_HTandMHTrings                     : INOUT tRingSegmentPipe2;
    VARIABLE reference_accumulatedTowerCount             : INOUT tRingSegmentPipe2;
    VARIABLE reference_calibratedETandMETrings           : INOUT tRingSegmentPipe2;
    VARIABLE reference_accumulatedETandMETrings          : INOUT tRingSegmentPipe2;
    VARIABLE reference_accumulatedHTandMHTrings          : INOUT tRingSegmentPipe2;
    VARIABLE reference_ClusterPileupEstimation           : INOUT tPileupEstimationPipe;
    VARIABLE reference_ETandMETPackedLink                : INOUT tPackedLinkPipe;
    VARIABLE reference_HTandMHTPackedLink                : INOUT tPackedLinkPipe;
    VARIABLE reference_AuxInfoPackedLink                 : INOUT tPackedLinkPipe;
    VARIABLE reference_demuxAccumulatedETandMETrings     : INOUT tRingSegmentPipe2;
    VARIABLE reference_demuxAccumulatedETandMETnoHFrings : INOUT tRingSegmentPipe2;
    VARIABLE reference_demuxAccumulatedHTandMHTrings     : INOUT tRingSegmentPipe2;
    VARIABLE reference_demuxAccumulatedHTandMHTnoHFrings : INOUT tRingSegmentPipe2;
    VARIABLE reference_polarETandMETrings                : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_polarETandMETnoHFrings            : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_polarHTandMHTrings                : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_polarHTandMHTnoHFrings            : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_gtFormattedETandMETrings          : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_gtFormattedETandMETnoHFrings      : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_gtFormattedHTandMHTrings          : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_gtFormattedHTandMHTnoHFrings      : INOUT tPolarRingSegmentPipe;
    VARIABLE reference_DemuxETandMETPackedLink           : INOUT tPackedLinkPipe;
    VARIABLE reference_DemuxETandMETnoHFPackedLink       : INOUT tPackedLinkPipe;
    VARIABLE reference_DemuxHTandMHTPackedLink           : INOUT tPackedLinkPipe;
    VARIABLE reference_DemuxHTandMHTnoHFPackedLink       : INOUT tPackedLinkPipe
  ) IS
    VARIABLE temp_real , realX , realY : REAL                    := 0.0;
    VARIABLE Energy , Ecal             : UNSIGNED( 15 DOWNTO 0 ) := ( OTHERS => '0' );

    FILE RomFile                       : TEXT;
    VARIABLE RomFileLine               : LINE;
    VARIABLE TEMP                      : CHARACTER;
    VARIABLE Value                     : STD_LOGIC_VECTOR( 19 DOWNTO 0 );

    TYPE mem_type_5to2 IS ARRAY( 0 TO( 2 ** 5 ) -1 ) OF STD_LOGIC_VECTOR( 1 DOWNTO 0 );
    VARIABLE EtaLUT_5to2 : mem_type_5to2;

    TYPE mem_type_5to4 IS ARRAY( 0 TO( 2 ** 5 ) -1 ) OF STD_LOGIC_VECTOR( 3 DOWNTO 0 );
    VARIABLE EtaLUT_5to4 : mem_type_5to4;

    TYPE mem_type_6to4 IS ARRAY( 0 TO( 2 ** 6 ) -1 ) OF STD_LOGIC_VECTOR( 3 DOWNTO 0 );
    VARIABLE EtaLUT_6to4 : mem_type_6to4;

    TYPE mem_type_10to5 IS ARRAY( 0 TO( 2 ** 10 ) -1 ) OF STD_LOGIC_VECTOR( 4 DOWNTO 0 );
    VARIABLE E_NttCompression_10to5 : mem_type_10to5;

    VARIABLE Count                  : STD_LOGIC_VECTOR( 3 DOWNTO 0 ) := ( OTHERS => '0' );

  BEGIN

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/E_NttCompression_10to5.mif" ) , READ_MODE );
    FOR i IN E_NttCompression_10to5'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      E_NttCompression_10to5( i ) := Value( 5-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/G_EtaCompression_5to2.mif" ) , READ_MODE );
    FOR i IN EtaLUT_5to2'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      EtaLUT_5to2( i ) := Value( 2-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/A_EtaCompression_5to4.mif" ) , READ_MODE );
    FOR i IN EtaLUT_5to4'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      EtaLUT_5to4( i ) := Value( 4-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    FILE_OPEN( RomFile , STRING' ( "../algorithm_components/firmware/HexROMs/J_EtaCompression_6to4.mif" ) , READ_MODE );
    FOR i IN EtaLUT_6to4'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      EtaLUT_6to4( i ) := Value( 4-1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta IN 0 TO( reference_HTandMHTrings'LENGTH - 1 ) LOOP
        FOR eta_half IN 0 TO cRegionInEta-1 LOOP
          reference_HTandMHTrings( eta )( eta_half )            := reference_HTandMHTrings( eta )( eta_half ) + ToRingSegment( reference_CalibratedJets( eta )( eta_half )( phi ) );
          reference_HTandMHTrings( eta )( eta_half ) .DataValid := TRUE;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta IN 0 TO( reference_ETandMETrings'LENGTH - 1 ) LOOP
      FOR phi IN 0 TO cTowerInPhi-1 LOOP
        reference_ETandMETrings( eta )( 0 ) := reference_ETandMETrings( eta )( 0 ) + ToRingSegment( GetTower( eta + 0 , phi , reference_Towers ) , "000000000" , phi );
        reference_ETandMETrings( eta )( 1 ) := reference_ETandMETrings( eta )( 1 ) + ToRingSegment( GetTower( -eta-1 , phi , reference_Towers ) , "000000000" , phi );
      END LOOP;
    END LOOP;


    FOR eta IN 0 TO( reference_ETandMETrings'LENGTH - 1 ) LOOP
      FOR phi IN 0 TO cTowerInPhi-1 LOOP
        IF GetTower( eta + 0 , phi , reference_Towers ) .Energy > "000000000" THEN
          reference_TowerCount( eta )( 0 ) .towerCount := reference_TowerCount( eta )( 0 ) .towerCount + TO_UNSIGNED( 1 , 12 );
        END IF;

        IF GetTower( -eta-1 , phi , reference_Towers ) .Energy > "000000000" THEN
          reference_TowerCount( eta )( 1 ) .towerCount := reference_TowerCount( eta )( 1 ) .towerCount + TO_UNSIGNED( 1 , 12 );
        END IF;

        reference_TowerCount( eta )( 0 ) .DataValid := TRUE;
        reference_TowerCount( eta )( 1 ) .DataValid := TRUE;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO cRegionInEta-1 LOOP
      FOR eta IN 0 TO( reference_ETandMETrings'LENGTH - 1 ) LOOP
-- DIRTY HACK - SHOULD BE FROM LUTS!-
        reference_CalibratedETandMETrings( eta )( eta_half ) := reference_ETandMETrings( eta )( eta_half );
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------



-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO cRegionInEta-1 LOOP
      reference_accumulatedETandMETrings( 0 )( eta_half ) .Energy     := reference_CalibratedETandMETrings( 0 )( eta_half ) .Energy;
      reference_accumulatedETandMETrings( 0 )( eta_half ) .Ecal       := reference_CalibratedETandMETrings( 0 )( eta_half ) .Ecal;
      reference_accumulatedETandMETrings( 0 )( eta_half ) .xComponent := reference_CalibratedETandMETrings( 0 )( eta_half ) .xComponent;
      reference_accumulatedETandMETrings( 0 )( eta_half ) .yComponent := reference_CalibratedETandMETrings( 0 )( eta_half ) .yComponent;
      reference_accumulatedETandMETrings( 0 )( eta_half ) .towerCount := reference_CalibratedETandMETrings( 0 )( eta_half ) .towerCount;
      reference_accumulatedETandMETrings( 0 )( eta_half ) .DataValid  := TRUE;

      FOR eta IN 1 TO( reference_accumulatedETandMETrings'LENGTH - 1 ) LOOP
        reference_accumulatedETandMETrings( eta )( eta_half ) .Energy     := reference_accumulatedETandMETrings( eta-1 )( eta_half ) .Energy + reference_CalibratedETandMETrings( eta )( eta_half ) .Energy;
        reference_accumulatedETandMETrings( eta )( eta_half ) .Ecal       := reference_accumulatedETandMETrings( eta-1 )( eta_half ) .Ecal + reference_CalibratedETandMETrings( eta )( eta_half ) .Ecal;
        reference_accumulatedETandMETrings( eta )( eta_half ) .xComponent := reference_accumulatedETandMETrings( eta-1 )( eta_half ) .xComponent + reference_CalibratedETandMETrings( eta )( eta_half ) .xComponent;
        reference_accumulatedETandMETrings( eta )( eta_half ) .yComponent := reference_accumulatedETandMETrings( eta-1 )( eta_half ) .yComponent + reference_CalibratedETandMETrings( eta )( eta_half ) .yComponent;
        reference_accumulatedETandMETrings( eta )( eta_half ) .towerCount := reference_accumulatedETandMETrings( eta-1 )( eta_half ) .towerCount + reference_CalibratedETandMETrings( eta )( eta_half ) .towerCount;
        reference_accumulatedETandMETrings( eta )( eta_half ) .DataValid  := TRUE;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO cRegionInEta-1 LOOP
      reference_accumulatedTowerCount( 0 )( eta_half ) .towerCount := reference_TowerCount( 0 )( eta_half ) .towerCount;
      reference_accumulatedTowerCount( 0 )( eta_half ) .DataValid  := TRUE;

      FOR eta IN 1 TO( reference_accumulatedETandMETrings'LENGTH - 1 ) LOOP
        reference_accumulatedTowerCount( eta )( eta_half ) .towerCount := reference_accumulatedTowerCount( eta-1 )( eta_half ) .towerCount + reference_TowerCount( eta )( eta_half ) .towerCount;
        reference_accumulatedTowerCount( eta )( eta_half ) .DataValid  := TRUE;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO cRegionInEta-1 LOOP
      reference_accumulatedHTandMHTrings( 0 )( eta_half ) .Energy     := reference_HTandMHTrings( 0 )( eta_half ) .Energy;
      reference_accumulatedHTandMHTrings( 0 )( eta_half ) .xComponent := reference_HTandMHTrings( 0 )( eta_half ) .xComponent;
      reference_accumulatedHTandMHTrings( 0 )( eta_half ) .yComponent := reference_HTandMHTrings( 0 )( eta_half ) .yComponent;
      reference_accumulatedHTandMHTrings( 0 )( eta_half ) .DataValid  := TRUE;

      FOR eta IN 1 TO( reference_accumulatedHTandMHTrings'LENGTH - 1 ) LOOP
        reference_accumulatedHTandMHTrings( eta )( eta_half ) .Energy     := reference_accumulatedHTandMHTrings( eta-1 )( eta_half ) .Energy + reference_HTandMHTrings( eta )( eta_half ) .Energy;
        reference_accumulatedHTandMHTrings( eta )( eta_half ) .xComponent := reference_accumulatedHTandMHTrings( eta-1 )( eta_half ) .xComponent + reference_HTandMHTrings( eta )( eta_half ) .xComponent;
        reference_accumulatedHTandMHTrings( eta )( eta_half ) .yComponent := reference_accumulatedHTandMHTrings( eta-1 )( eta_half ) .yComponent + reference_HTandMHTrings( eta )( eta_half ) .yComponent;
        reference_accumulatedHTandMHTrings( eta )( eta_half ) .DataValid  := TRUE;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
      FOR eta_half IN 0 TO cRegionInEta-1 LOOP
        FOR eta IN 0 TO( reference_ClusterPileupEstimation'LENGTH - 1 ) LOOP

            reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta2  := UNSIGNED( EtaLUT_5to2( ( eta + cCMScoordinateOffset ) MOD 32 ) );
            reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta4a := UNSIGNED( EtaLUT_5to4( ( eta + cCMScoordinateOffset ) MOD 32 ) );

          reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .compressedEta4j   := UNSIGNED( EtaLUT_6to4( eta + cCMScoordinateOffset ) );

          reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .towerCount        := UNSIGNED( E_NttCompression_10to5( TO_INTEGER( reference_accumulatedTowerCount( 3 )( 0 ) .towerCount + reference_accumulatedTowerCount( 3 )( 1 ) .towerCount ) ) );
          reference_ClusterPileupEstimation( eta )( eta_half )( phi ) .DataValid         := TRUE;
        END LOOP;
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO( cRegionInEta-1 ) LOOP
--FOR eta IN 0 TO( reference_accumulatedETandMETrings'LENGTH - 1 ) LOOP

      IF( reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( eta_half ) .Energy > x"FFFF" ) THEN
        Energy := x"FFFF";
      ELSE
        Energy := reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( eta_half ) .Energy( 15 DOWNTO 0 );
      END IF;

      IF( reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( eta_half ) .Ecal > x"FFFF" ) THEN
        Ecal := x"FFFF";
      ELSE
        Ecal := reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( eta_half ) .Ecal( 15 DOWNTO 0 );
      END IF;

      reference_ETandMETPackedLink( 0 )( ( 3 * eta_half ) + 0 ) .Data      := STD_LOGIC_VECTOR( Ecal & Energy );
      reference_ETandMETPackedLink( 0 )( ( 3 * eta_half ) + 1 ) .Data      := STD_LOGIC_VECTOR( reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( eta_half ) .xComponent );
      reference_ETandMETPackedLink( 0 )( ( 3 * eta_half ) + 2 ) .Data      := STD_LOGIC_VECTOR( reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( eta_half ) .yComponent );

      reference_ETandMETPackedLink( 0 )( ( 3 * eta_half ) + 0 ) .DataValid := reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( eta_half ) .DataValid;
      reference_ETandMETPackedLink( 0 )( ( 3 * eta_half ) + 1 ) .DataValid := reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( eta_half ) .DataValid;
      reference_ETandMETPackedLink( 0 )( ( 3 * eta_half ) + 2 ) .DataValid := reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( eta_half ) .DataValid;

-- -------

      IF( reference_accumulatedETandMETrings( cEcalTowersInHalfEta-1 )( eta_half ) .Energy > x"FFFF" ) THEN
        Energy := x"FFFF";
      ELSE
        Energy := reference_accumulatedETandMETrings( cEcalTowersInHalfEta-1 )( eta_half ) .Energy( 15 DOWNTO 0 );
      END IF;

      IF( reference_accumulatedETandMETrings( cEcalTowersInHalfEta-1 )( eta_half ) .Ecal > x"FFFF" ) THEN
        Ecal := x"FFFF";
      ELSE
        Ecal := reference_accumulatedETandMETrings( cEcalTowersInHalfEta-1 )( eta_half ) .Ecal( 15 DOWNTO 0 );
      END IF;

      reference_ETandMETPackedLink( 1 )( ( 3 * eta_half ) + 0 ) .Data      := STD_LOGIC_VECTOR( Ecal & Energy );
      reference_ETandMETPackedLink( 1 )( ( 3 * eta_half ) + 1 ) .Data      := STD_LOGIC_VECTOR( reference_accumulatedETandMETrings( cEcalTowersInHalfEta-1 )( eta_half ) .xComponent );
      reference_ETandMETPackedLink( 1 )( ( 3 * eta_half ) + 2 ) .Data      := STD_LOGIC_VECTOR( reference_accumulatedETandMETrings( cEcalTowersInHalfEta-1 )( eta_half ) .yComponent );

      reference_ETandMETPackedLink( 1 )( ( 3 * eta_half ) + 0 ) .DataValid := reference_accumulatedETandMETrings( cEcalTowersInHalfEta-1 )( eta_half ) .DataValid;
      reference_ETandMETPackedLink( 1 )( ( 3 * eta_half ) + 1 ) .DataValid := reference_accumulatedETandMETrings( cEcalTowersInHalfEta-1 )( eta_half ) .DataValid;
      reference_ETandMETPackedLink( 1 )( ( 3 * eta_half ) + 2 ) .DataValid := reference_accumulatedETandMETrings( cEcalTowersInHalfEta-1 )( eta_half ) .DataValid;


--END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO( cRegionInEta-1 ) LOOP
--FOR eta IN 0 TO( reference_accumulatedHTandMHTrings'LENGTH - 1 ) LOOP

      IF( reference_accumulatedHTandMHTrings( cTowersInHalfEta-1 )( eta_half ) .Energy > x"FFFF" ) THEN
        Energy := x"FFFF";
      ELSE
        Energy := reference_accumulatedHTandMHTrings( cTowersInHalfEta-1 )( eta_half ) .Energy( 15 DOWNTO 0 );
      END IF;

      reference_HTandMHTPackedLink( 0 )( ( 3 * eta_half ) + 0 ) .Data      := X"0000" & STD_LOGIC_VECTOR( Energy );
      reference_HTandMHTPackedLink( 0 )( ( 3 * eta_half ) + 1 ) .Data      := STD_LOGIC_VECTOR( reference_accumulatedHTandMHTrings( cTowersInHalfEta-1 )( eta_half ) .xComponent );
      reference_HTandMHTPackedLink( 0 )( ( 3 * eta_half ) + 2 ) .Data      := STD_LOGIC_VECTOR( reference_accumulatedHTandMHTrings( cTowersInHalfEta-1 )( eta_half ) .yComponent );

      reference_HTandMHTPackedLink( 0 )( ( 3 * eta_half ) + 0 ) .DataValid := reference_accumulatedHTandMHTrings( cTowersInHalfEta-1 )( eta_half ) .DataValid;
      reference_HTandMHTPackedLink( 0 )( ( 3 * eta_half ) + 1 ) .DataValid := reference_accumulatedHTandMHTrings( cTowersInHalfEta-1 )( eta_half ) .DataValid;
      reference_HTandMHTPackedLink( 0 )( ( 3 * eta_half ) + 2 ) .DataValid := reference_accumulatedHTandMHTrings( cTowersInHalfEta-1 )( eta_half ) .DataValid;

-- ----

      IF( reference_accumulatedHTandMHTrings( cEcalTowersInHalfEta-1 )( eta_half ) .Energy > x"FFFF" ) THEN
        Energy := x"FFFF";
      ELSE
        Energy := reference_accumulatedHTandMHTrings( cEcalTowersInHalfEta-1 )( eta_half ) .Energy( 15 DOWNTO 0 );
      END IF;

      reference_HTandMHTPackedLink( 1 )( ( 3 * eta_half ) + 0 ) .Data      := X"0000" & STD_LOGIC_VECTOR( Energy );
      reference_HTandMHTPackedLink( 1 )( ( 3 * eta_half ) + 1 ) .Data      := STD_LOGIC_VECTOR( reference_accumulatedHTandMHTrings( cEcalTowersInHalfEta-1 )( eta_half ) .xComponent );
      reference_HTandMHTPackedLink( 1 )( ( 3 * eta_half ) + 2 ) .Data      := STD_LOGIC_VECTOR( reference_accumulatedHTandMHTrings( cEcalTowersInHalfEta-1 )( eta_half ) .yComponent );

      reference_HTandMHTPackedLink( 1 )( ( 3 * eta_half ) + 0 ) .DataValid := reference_accumulatedHTandMHTrings( cEcalTowersInHalfEta-1 )( eta_half ) .DataValid;
      reference_HTandMHTPackedLink( 1 )( ( 3 * eta_half ) + 1 ) .DataValid := reference_accumulatedHTandMHTrings( cEcalTowersInHalfEta-1 )( eta_half ) .DataValid;
      reference_HTandMHTPackedLink( 1 )( ( 3 * eta_half ) + 2 ) .DataValid := reference_accumulatedHTandMHTrings( cEcalTowersInHalfEta-1 )( eta_half ) .DataValid;

--END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
--FOR eta IN 0 TO( reference_accumulatedETandMETrings'LENGTH - 1 ) LOOP
    reference_AuxInfoPackedLink( 0 )( 0 ) .Data( 4 DOWNTO 0 ) := STD_LOGIC_VECTOR( reference_ClusterPileupEstimation( cTowersInHalfEta-1 )( 0 )( 0 ) .towerCount );
    reference_AuxInfoPackedLink( 0 )( 0 ) .DataValid          := reference_ClusterPileupEstimation( cTowersInHalfEta-1 )( 0 )( 0 ) .DataValid;

    IF reference_accumulatedETandMETrings( 0 )( 1 ) .towerCount2 > x"F" THEN
      reference_AuxInfoPackedLink( 0 )( 1 ) .Data( 3 DOWNTO 0 ) := x"F";
    ELSE
      reference_AuxInfoPackedLink( 0 )( 1 ) .Data( 3 DOWNTO 0 ) := STD_LOGIC_VECTOR( reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( 1 ) .towerCount2( 3 DOWNTO 0 ) );
    END IF;

    IF reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( 0 ) .towerCount2 > x"F" THEN
      reference_AuxInfoPackedLink( 0 )( 1 ) .Data( 11 DOWNTO 8 ) := x"F";
    ELSE
      reference_AuxInfoPackedLink( 0 )( 1 ) .Data( 11 DOWNTO 8 ) := STD_LOGIC_VECTOR( reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( 0 ) .towerCount2( 3 DOWNTO 0 ) );
    END IF;

    IF reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( 1 ) .towerCount > x"F" THEN
      reference_AuxInfoPackedLink( 0 )( 1 ) .Data( 19 DOWNTO 16 ) := x"F";
    ELSE
      reference_AuxInfoPackedLink( 0 )( 1 ) .Data( 19 DOWNTO 16 ) := STD_LOGIC_VECTOR( reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( 1 ) .towerCount( 3 DOWNTO 0 ) );
    END IF;

    IF reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( 0 ) .towerCount > x"F" THEN
      reference_AuxInfoPackedLink( 0 )( 1 ) .Data( 27 DOWNTO 24 ) := x"F";
    ELSE
      reference_AuxInfoPackedLink( 0 )( 1 ) .Data( 27 DOWNTO 24 ) := STD_LOGIC_VECTOR( reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( 0 ) .towerCount( 3 DOWNTO 0 ) );
    END IF;

--reference_AuxInfoPackedLink( 0 )( 1 ) .AccumulationComplete := ( 0 = ( reference_accumulatedETandMETrings'LENGTH - 1 ) );
    reference_AuxInfoPackedLink( 0 )( 1 ) .DataValid := reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( 0 ) .DataValid;

    reference_AuxInfoPackedLink( 0 )( 2 ) .DataValid := TRUE;
    reference_AuxInfoPackedLink( 0 )( 3 ) .DataValid := TRUE;
    reference_AuxInfoPackedLink( 0 )( 4 ) .DataValid := TRUE;
    reference_AuxInfoPackedLink( 0 )( 5 ) .DataValid := TRUE;
--END LOOP;
-- -----------------------------------------------------------------------------------------------------




-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO( cRegionInEta-1 ) LOOP
      reference_demuxAccumulatedETandMETrings( 0 )( eta_half )                 := reference_accumulatedETandMETrings( cTowersInHalfEta-1 )( eta_half );
      reference_demuxAccumulatedETandMETrings( 0 )( eta_half ) .towerCount     := ( OTHERS => '0' );

      reference_demuxAccumulatedETandMETnoHFrings( 0 )( eta_half )             := reference_accumulatedETandMETrings( cEcalTowersInHalfEta-1 )( eta_half );
      reference_demuxAccumulatedETandMETnoHFrings( 0 )( eta_half ) .towerCount := ( OTHERS => '0' );

      reference_demuxAccumulatedHTandMHTrings( 0 )( eta_half )                 := reference_accumulatedHTandMHTrings( cTowersInHalfEta-1 )( eta_half );
      reference_demuxAccumulatedHTandMHTnoHFrings( 0 )( eta_half )             := reference_accumulatedHTandMHTrings( cEcalTowersInHalfEta-1 )( eta_half );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    realX     := REAL( TO_INTEGER( reference_demuxAccumulatedETandMETrings( 0 )( 0 ) .xComponent + reference_demuxAccumulatedETandMETrings( 0 )( 1 ) .xComponent ) );
    realY     := REAL( TO_INTEGER( reference_demuxAccumulatedETandMETrings( 0 )( 0 ) .yComponent + reference_demuxAccumulatedETandMETrings( 0 )( 1 ) .yComponent ) );
    temp_real := ARCTAN( -1.0 * realY , -1.0 * realX );
    IF temp_real < 0.0 THEN
      temp_real := temp_real + MATH_2_PI;
    END IF;
    reference_polarETandMETrings( 0 ) .VectorPhi       := TO_UNSIGNED( INTEGER( ROUND( 16.0 * 144.0 * temp_real / MATH_2_PI ) ) , 12 );

    temp_real                                          := SQRT( ( realX ** 2 ) + ( realY ** 2 ) );
    reference_polarETandMETrings( 0 ) .VectorMagnitude := TO_UNSIGNED( INTEGER( ROUND( temp_real ) ) , 32 );
    reference_polarETandMETrings( 0 ) .ScalarMagnitude := reference_demuxAccumulatedETandMETrings( 0 )( 0 ) .Energy( 16 DOWNTO 0 ) + reference_demuxAccumulatedETandMETrings( 0 )( 1 ) .Energy( 16 DOWNTO 0 );
    reference_polarETandMETrings( 0 ) .EcalMagnitude   := reference_demuxAccumulatedETandMETrings( 0 )( 0 ) .Ecal( 16 DOWNTO 0 ) + reference_demuxAccumulatedETandMETrings( 0 )( 1 ) .Ecal( 16 DOWNTO 0 );

    reference_polarETandMETrings( 0 ) .DataValid       := TRUE;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    realX                                              := REAL( TO_INTEGER( reference_demuxAccumulatedETandMETnoHFrings( 0 )( 0 ) .xComponent + reference_demuxAccumulatedETandMETnoHFrings( 0 )( 1 ) .xComponent ) );
    realY                                              := REAL( TO_INTEGER( reference_demuxAccumulatedETandMETnoHFrings( 0 )( 0 ) .yComponent + reference_demuxAccumulatedETandMETnoHFrings( 0 )( 1 ) .yComponent ) );
    temp_real                                          := ARCTAN( -1.0 * realY , -1.0 * realX );
    IF temp_real < 0.0 THEN
      temp_real := temp_real + MATH_2_PI;
    END IF;
    reference_polarETandMETnoHFrings( 0 ) .VectorPhi       := TO_UNSIGNED( INTEGER( ROUND( 16.0 * 144.0 * temp_real / MATH_2_PI ) ) , 12 );

    temp_real                                              := SQRT( ( realX ** 2 ) + ( realY ** 2 ) );
    reference_polarETandMETnoHFrings( 0 ) .VectorMagnitude := TO_UNSIGNED( INTEGER( ROUND( temp_real ) ) , 32 );
    reference_polarETandMETnoHFrings( 0 ) .ScalarMagnitude := reference_demuxAccumulatedETandMETnoHFrings( 0 )( 0 ) .Energy( 16 DOWNTO 0 ) + reference_demuxAccumulatedETandMETnoHFrings( 0 )( 1 ) .Energy( 16 DOWNTO 0 );
    reference_polarETandMETnoHFrings( 0 ) .EcalMagnitude   := reference_demuxAccumulatedETandMETnoHFrings( 0 )( 0 ) .Ecal( 16 DOWNTO 0 ) + reference_demuxAccumulatedETandMETnoHFrings( 0 )( 1 ) .Ecal( 16 DOWNTO 0 );

    reference_polarETandMETnoHFrings( 0 ) .DataValid       := TRUE;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    realX                                                  := REAL( TO_INTEGER( reference_demuxAccumulatedHTandMHTrings( 0 )( 0 ) .xComponent + reference_demuxAccumulatedHTandMHTrings( 0 )( 1 ) .xComponent ) );
    realY                                                  := REAL( TO_INTEGER( reference_demuxAccumulatedHTandMHTrings( 0 )( 0 ) .yComponent + reference_demuxAccumulatedHTandMHTrings( 0 )( 1 ) .yComponent ) );
    temp_real                                              := ARCTAN( -1.0 * realY , -1.0 * realX );
    IF temp_real < 0.0 THEN
      temp_real := temp_real + MATH_2_PI;
    END IF;
    reference_polarHTandMHTrings( 0 ) .VectorPhi       := TO_UNSIGNED( INTEGER( ROUND( 16.0 * 144.0 * temp_real / MATH_2_PI ) ) , 12 );

    temp_real                                          := SQRT( ( realX ** 2 ) + ( realY ** 2 ) );
    reference_polarHTandMHTrings( 0 ) .VectorMagnitude := TO_UNSIGNED( INTEGER( ROUND( temp_real ) ) , 32 );
    reference_polarHTandMHTrings( 0 ) .ScalarMagnitude := reference_demuxAccumulatedHTandMHTrings( 0 )( 0 ) .Energy( 16 DOWNTO 0 ) + reference_demuxAccumulatedHTandMHTrings( 0 )( 1 ) .Energy( 16 DOWNTO 0 );

    reference_polarHTandMHTrings( 0 ) .DataValid       := TRUE;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    realX                                              := REAL( TO_INTEGER( reference_demuxAccumulatedHTandMHTnoHFrings( 0 )( 0 ) .xComponent + reference_demuxAccumulatedHTandMHTnoHFrings( 0 )( 1 ) .xComponent ) );
    realY                                              := REAL( TO_INTEGER( reference_demuxAccumulatedHTandMHTnoHFrings( 0 )( 0 ) .yComponent + reference_demuxAccumulatedHTandMHTnoHFrings( 0 )( 1 ) .yComponent ) );
    temp_real                                          := ARCTAN( -1.0 * realY , -1.0 * realX );
    IF temp_real < 0.0 THEN
      temp_real := temp_real + MATH_2_PI;
    END IF;
    reference_polarHTandMHTnoHFrings( 0 ) .VectorPhi       := TO_UNSIGNED( INTEGER( ROUND( 16.0 * 144.0 * temp_real / MATH_2_PI ) ) , 12 );

    temp_real                                              := SQRT( ( realX ** 2 ) + ( realY ** 2 ) );
    reference_polarHTandMHTnoHFrings( 0 ) .VectorMagnitude := TO_UNSIGNED( INTEGER( ROUND( temp_real ) ) , 32 );
    reference_polarHTandMHTnoHFrings( 0 ) .ScalarMagnitude := reference_demuxAccumulatedHTandMHTnoHFrings( 0 )( 0 ) .Energy( 16 DOWNTO 0 ) + reference_demuxAccumulatedHTandMHTnoHFrings( 0 )( 1 ) .Energy( 16 DOWNTO 0 );

    reference_polarHTandMHTnoHFrings( 0 ) .DataValid       := TRUE;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    IF( reference_polarETandMETrings( 0 ) .VectorMagnitude( 31 DOWNTO 10 ) > x"FFF" ) THEN
      reference_GtFormattedETandMETrings( 0 ) .VectorMagnitude( 11 DOWNTO 0 ) := x"FFF";
    ELSE
      reference_GtFormattedETandMETrings( 0 ) .VectorMagnitude( 11 DOWNTO 0 ) := reference_polarETandMETrings( 0 ) .VectorMagnitude( 21 DOWNTO 10 );
    END IF;

    IF( reference_polarETandMETrings( 0 ) .ScalarMagnitude > x"FFF" ) THEN
      reference_GtFormattedETandMETrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) := x"FFF";
    ELSE
      reference_GtFormattedETandMETrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) := reference_polarETandMETrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 );
    END IF;

    IF( reference_polarETandMETrings( 0 ) .EcalMagnitude > x"FFF" ) THEN
      reference_GtFormattedETandMETrings( 0 ) .EcalMagnitude( 11 DOWNTO 0 ) := x"FFF";
    ELSE
      reference_GtFormattedETandMETrings( 0 ) .EcalMagnitude( 11 DOWNTO 0 ) := reference_polarETandMETrings( 0 ) .EcalMagnitude( 11 DOWNTO 0 );
    END IF;

    reference_GtFormattedETandMETrings( 0 ) .VectorPhi( 7 DOWNTO 0 ) := reference_polarETandMETrings( 0 ) .VectorPhi( 11 DOWNTO 4 );

    reference_GtFormattedETandMETrings( 0 ) .DataValid               := TRUE;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    IF( reference_polarETandMETNoHFrings( 0 ) .VectorMagnitude( 31 DOWNTO 10 ) > x"FFF" ) THEN
      reference_GtFormattedETandMETNoHFrings( 0 ) .VectorMagnitude( 11 DOWNTO 0 ) := x"FFF";
    ELSE
      reference_GtFormattedETandMETNoHFrings( 0 ) .VectorMagnitude( 11 DOWNTO 0 ) := reference_polarETandMETNoHFrings( 0 ) .VectorMagnitude( 21 DOWNTO 10 );
    END IF;

    IF( reference_polarETandMETNoHFrings( 0 ) .ScalarMagnitude > x"FFF" ) THEN
      reference_GtFormattedETandMETNoHFrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) := x"FFF";
    ELSE
      reference_GtFormattedETandMETNoHFrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) := reference_polarETandMETNoHFrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 );
    END IF;

    IF( reference_polarETandMETNoHFrings( 0 ) .EcalMagnitude > x"FFF" ) THEN
      reference_GtFormattedETandMETNoHFrings( 0 ) .EcalMagnitude( 11 DOWNTO 0 ) := x"FFF";
    ELSE
      reference_GtFormattedETandMETNoHFrings( 0 ) .EcalMagnitude( 11 DOWNTO 0 ) := reference_polarETandMETNoHFrings( 0 ) .EcalMagnitude( 11 DOWNTO 0 );
    END IF;

    reference_GtFormattedETandMETNoHFrings( 0 ) .VectorPhi( 7 DOWNTO 0 ) := reference_polarETandMETNoHFrings( 0 ) .VectorPhi( 11 DOWNTO 4 );

    reference_GtFormattedETandMETNoHFrings( 0 ) .DataValid               := TRUE;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    IF( reference_polarHTandMHTrings( 0 ) .VectorMagnitude( 31 DOWNTO 6 ) > x"FFF" ) THEN
      reference_GtFormattedHTandMHTrings( 0 ) .VectorMagnitude( 11 DOWNTO 0 ) := x"FFF";
    ELSE
      reference_GtFormattedHTandMHTrings( 0 ) .VectorMagnitude( 11 DOWNTO 0 ) := reference_polarHTandMHTrings( 0 ) .VectorMagnitude( 17 DOWNTO 6 );
    END IF;

    IF( reference_polarHTandMHTrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) > x"FFF" ) THEN
      reference_GtFormattedHTandMHTrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) := x"FFF";
    ELSE
      reference_GtFormattedHTandMHTrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) := reference_polarHTandMHTrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 );
    END IF;

    reference_GtFormattedHTandMHTrings( 0 ) .VectorPhi( 7 DOWNTO 0 ) := reference_polarHTandMHTrings( 0 ) .VectorPhi( 11 DOWNTO 4 );

    reference_GtFormattedHTandMHTrings( 0 ) .DataValid               := TRUE;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    IF( reference_polarHTandMHTnoHFrings( 0 ) .VectorMagnitude( 31 DOWNTO 6 ) > x"FFF" ) THEN
      reference_GtFormattedHTandMHTnoHFrings( 0 ) .VectorMagnitude( 11 DOWNTO 0 ) := x"FFF";
    ELSE
      reference_GtFormattedHTandMHTnoHFrings( 0 ) .VectorMagnitude( 11 DOWNTO 0 ) := reference_polarHTandMHTnoHFrings( 0 ) .VectorMagnitude( 17 DOWNTO 6 );
    END IF;

    IF( reference_polarHTandMHTnoHFrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) > x"FFF" ) THEN
      reference_GtFormattedHTandMHTnoHFrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) := x"FFF";
    ELSE
      reference_GtFormattedHTandMHTnoHFrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) := reference_polarHTandMHTnoHFrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 );
    END IF;

    reference_GtFormattedHTandMHTnoHFrings( 0 ) .VectorPhi( 7 DOWNTO 0 ) := reference_polarHTandMHTnoHFrings( 0 ) .VectorPhi( 11 DOWNTO 4 );

    reference_GtFormattedHTandMHTnoHFrings( 0 ) .DataValid               := TRUE;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    reference_DemuxETandMETPackedLink( 0 )( 0 ) .Data                    := reference_AuxInfoPackedLink( reference_AuxInfoPackedLink'LENGTH - 1 )( 1 ) .Data( 27 DOWNTO 24 )
                                                                          & "0000"
                                                                          & STD_LOGIC_VECTOR( reference_GtFormattedETandMETrings( 0 ) .EcalMagnitude( 11 DOWNTO 0 ) )
                                                                          & STD_LOGIC_VECTOR( reference_GtFormattedETandMETrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) );
    reference_DemuxETandMETPackedLink( 0 )( 1 ) .Data := reference_AuxInfoPackedLink( reference_AuxInfoPackedLink'LENGTH - 1 )( 1 ) .Data( 11 DOWNTO 8 )
                                                                          & "00000000"
                                                                          & STD_LOGIC_VECTOR( reference_GtFormattedETandMETrings( 0 ) .VectorPhi( 7 DOWNTO 0 ) ) & STD_LOGIC_VECTOR( reference_GtFormattedETandMETrings( 0 ) .VectorMagnitude( 11 DOWNTO 0 ) );

    reference_DemuxETandMETPackedLink( 0 )( 0 ) .DataValid := TRUE;
    reference_DemuxETandMETPackedLink( 0 )( 1 ) .DataValid := TRUE;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    reference_DemuxETandMETnoHFPackedLink( 0 )( 0 ) .Data  := reference_AuxInfoPackedLink( reference_AuxInfoPackedLink'LENGTH - 1 )( 1 ) .Data( 27 DOWNTO 24 )
                                                                          & "0000"
                                                                          & STD_LOGIC_VECTOR( reference_GtFormattedETandMETnoHFrings( 0 ) .EcalMagnitude( 11 DOWNTO 0 ) )
                                                                          & STD_LOGIC_VECTOR( reference_GtFormattedETandMETnoHFrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) );
    reference_DemuxETandMETnoHFPackedLink( 0 )( 1 ) .Data := reference_AuxInfoPackedLink( reference_AuxInfoPackedLink'LENGTH - 1 )( 1 ) .Data( 11 DOWNTO 8 )
                                                                          & "00000000" & STD_LOGIC_VECTOR( reference_GtFormattedETandMETnoHFrings( 0 ) .VectorPhi( 7 DOWNTO 0 ) )
                                                                          & STD_LOGIC_VECTOR( reference_GtFormattedETandMETnoHFrings( 0 ) .VectorMagnitude( 11 DOWNTO 0 ) );

    reference_DemuxETandMETnoHFPackedLink( 0 )( 0 ) .DataValid := TRUE;
    reference_DemuxETandMETnoHFPackedLink( 0 )( 1 ) .DataValid := TRUE;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    reference_DemuxHTandMHTPackedLink( 0 )( 0 ) .Data          := reference_AuxInfoPackedLink( reference_AuxInfoPackedLink'LENGTH - 1 )( 1 ) .Data( 19 DOWNTO 16 )
                                                                          & "0000"
                                                                          & STD_LOGIC_VECTOR( reference_GtFormattedHTandMHTrings( 0 ) .EcalMagnitude( 11 DOWNTO 0 ) )
                                                                          & STD_LOGIC_VECTOR( reference_GtFormattedHTandMHTrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) );
    reference_DemuxHTandMHTPackedLink( 0 )( 1 ) .Data := reference_AuxInfoPackedLink( reference_AuxInfoPackedLink'LENGTH - 1 )( 1 ) .Data( 3 DOWNTO 0 )
                                                                          & "00000000"
                                                                          & STD_LOGIC_VECTOR( reference_GtFormattedHTandMHTrings( 0 ) .VectorPhi( 7 DOWNTO 0 ) ) & STD_LOGIC_VECTOR( reference_GtFormattedHTandMHTrings( 0 ) .VectorMagnitude( 11 DOWNTO 0 ) );

    reference_DemuxHTandMHTPackedLink( 0 )( 0 ) .DataValid := TRUE;
    reference_DemuxHTandMHTPackedLink( 0 )( 1 ) .DataValid := TRUE;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    reference_DemuxHTandMHTnoHFPackedLink( 0 )( 0 ) .Data  := reference_AuxInfoPackedLink( reference_AuxInfoPackedLink'LENGTH - 1 )( 1 ) .Data( 19 DOWNTO 16 )
                                                                          & "0000"
                                                                          & STD_LOGIC_VECTOR( reference_GtFormattedHTandMHTnoHFrings( 0 ) .EcalMagnitude( 11 DOWNTO 0 ) )
                                                                          & STD_LOGIC_VECTOR( reference_GtFormattedHTandMHTnoHFrings( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) );
    reference_DemuxHTandMHTnoHFPackedLink( 0 )( 1 ) .Data := reference_AuxInfoPackedLink( reference_AuxInfoPackedLink'LENGTH - 1 )( 1 ) .Data( 3 DOWNTO 0 )
                                                                          & "00000000"
                                                                          & STD_LOGIC_VECTOR( reference_GtFormattedHTandMHTnoHFrings( 0 ) .VectorPhi( 7 DOWNTO 0 ) ) & STD_LOGIC_VECTOR( reference_GtFormattedHTandMHTnoHFrings( 0 ) .VectorMagnitude( 11 DOWNTO 0 ) );

    reference_DemuxHTandMHTnoHFPackedLink( 0 )( 0 ) .DataValid := TRUE;
    reference_DemuxHTandMHTnoHFPackedLink( 0 )( 1 ) .DataValid := TRUE;
-- -----------------------------------------------------------------------------------------------------
  END RingsumReference;


  PROCEDURE RingsumChecker
  (
    VARIABLE clk_count                                   : IN INTEGER;
    CONSTANT timeout                                     : IN INTEGER;
-- -------------
    VARIABLE reference_TowerCount                        : IN tRingSegmentPipe2;
    SIGNAL TowerCountPipe                                : IN tRingSegmentPipe2;
    VARIABLE retvalTowerCount                            : INOUT tRetVal;
-- -------------
    VARIABLE reference_ETandMETrings                     : IN tRingSegmentPipe2;
    SIGNAL ETandMETringPipe                              : IN tRingSegmentPipe2;
    VARIABLE retvalETandMETrings                         : INOUT tRetVal;
-- -------------
    VARIABLE reference_HTandMHTrings                     : IN tRingSegmentPipe2;
    SIGNAL HTandMHTringPipe                              : IN tRingSegmentPipe2;
    VARIABLE retvalHTandMHTrings                         : INOUT tRetVal;
-- -------------
    VARIABLE reference_accumulatedTowerCount             : IN tRingSegmentPipe2;
    SIGNAL accumulatedTowerCountPipe                     : IN tRingSegmentPipe2;
    VARIABLE retvalAccumulatedTowerCount                 : INOUT tRetVal;
-- -------------
    VARIABLE reference_calibratedETandMETrings           : IN tRingSegmentPipe2;
    SIGNAL calibratedETandMETringPipe                    : IN tRingSegmentPipe2;
    VARIABLE retvalCalibratedETandMETrings               : INOUT tRetVal;
-- -------------
    VARIABLE reference_accumulatedETandMETrings          : IN tRingSegmentPipe2;
    SIGNAL accumulatedETandMETringPipe                   : IN tRingSegmentPipe2;
    VARIABLE retvalAccumulatedETandMETrings              : INOUT tRetVal;
-- -------------
    VARIABLE reference_accumulatedHTandMHTrings          : IN tRingSegmentPipe2;
    SIGNAL accumulatedHTandMHTringPipe                   : IN tRingSegmentPipe2;
    VARIABLE retvalAccumulatedHTandMHTrings              : INOUT tRetVal;
-- -------------
    VARIABLE reference_ClusterPileupEstimation           : IN tPileupEstimationPipe;
    SIGNAL ClusterPileupEstimationPipe                   : IN tPileupEstimationPipe;
    VARIABLE retvalClusterPileupEstimation               : INOUT tRetVal;
---- -------------
    VARIABLE reference_ETandMETPackedLink                : IN tPackedLinkPipe;
    SIGNAL ETandMETPackedLinkPipe                        : IN tPackedLinkPipe;
    VARIABLE retvalETandMETPackedLink                    : INOUT tRetVal;
-- -------------
    VARIABLE reference_HTandMHTPackedLink                : IN tPackedLinkPipe;
    SIGNAL HTandMHTPackedLinkPipe                        : IN tPackedLinkPipe;
    VARIABLE retvalHTandMHTPackedLink                    : INOUT tRetVal;
-- -------------
    VARIABLE reference_AuxInfoPackedLink                 : IN tPackedLinkPipe;
    SIGNAL AuxInfoPackedLinkPipe                         : IN tPackedLinkPipe;
    VARIABLE retvalAuxInfoPackedLink                     : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedETandMETrings     : IN tRingSegmentPipe2;
    SIGNAL demuxAccumulatedETandMETringPipe              : IN tRingSegmentPipe2;
    VARIABLE retvalDemuxAccumulatedETandMETrings         : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedETandMETnoHFrings : IN tRingSegmentPipe2;
    SIGNAL demuxAccumulatedETandMETnoHFringPipe          : IN tRingSegmentPipe2;
    VARIABLE retvalDemuxAccumulatedETandMETnoHFrings     : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedHTandMHTrings     : IN tRingSegmentPipe2;
    SIGNAL demuxAccumulatedHTandMHTringPipe              : IN tRingSegmentPipe2;
    VARIABLE retvalDemuxAccumulatedHTandMHTrings         : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxAccumulatedHTandMHTnoHFrings : IN tRingSegmentPipe2;
    SIGNAL demuxAccumulatedHTandMHTnoHFringPipe          : IN tRingSegmentPipe2;
    VARIABLE retvalDemuxAccumulatedHTandMHTnoHFrings     : INOUT tRetVal;
-- -------------
    VARIABLE reference_PolarETandMETrings                : IN tPolarRingSegmentPipe;
    SIGNAL PolarETandMETringPipe                         : IN tPolarRingSegmentPipe;
    VARIABLE retvalPolarETandMETrings                    : INOUT tRetVal;
-- -------------
    VARIABLE reference_PolarETandMETnoHFrings            : IN tPolarRingSegmentPipe;
    SIGNAL PolarETandMETnoHFringPipe                     : IN tPolarRingSegmentPipe;
    VARIABLE retvalPolarETandMETnoHFrings                : INOUT tRetVal;
-- -------------
    VARIABLE reference_PolarHTandMHTrings                : IN tPolarRingSegmentPipe;
    SIGNAL PolarHTandMHTringPipe                         : IN tPolarRingSegmentPipe;
    VARIABLE retvalPolarHTandMHTrings                    : INOUT tRetVal;
-- -------------
    VARIABLE reference_PolarHTandMHTnoHFrings            : IN tPolarRingSegmentPipe;
    SIGNAL PolarHTandMHTnoHFringPipe                     : IN tPolarRingSegmentPipe;
    VARIABLE retvalPolarHTandMHTnoHFrings                : INOUT tRetVal;
-- -------------
    VARIABLE reference_GtFormattedETandMETrings          : IN tPolarRingSegmentPipe;
    SIGNAL GtFormattedETandMETringPipe                   : IN tPolarRingSegmentPipe;
    VARIABLE retvalGtFormattedETandMETrings              : INOUT tRetVal;
-- -------------
    VARIABLE reference_GtFormattedETandMETnoHFrings      : IN tPolarRingSegmentPipe;
    SIGNAL GtFormattedETandMETnoHFringPipe               : IN tPolarRingSegmentPipe;
    VARIABLE retvalGtFormattedETandMETnoHFrings          : INOUT tRetVal;
-- -------------
    VARIABLE reference_GtFormattedHTandMHTrings          : IN tPolarRingSegmentPipe;
    SIGNAL GtFormattedHTandMHTringPipe                   : IN tPolarRingSegmentPipe;
    VARIABLE retvalGtFormattedHTandMHTrings              : INOUT tRetVal;
-- -------------
    VARIABLE reference_GtFormattedHTandMHTnoHFrings      : IN tPolarRingSegmentPipe;
    SIGNAL GtFormattedHTandMHTnoHFringPipe               : IN tPolarRingSegmentPipe;
    VARIABLE retvalGtFormattedHTandMHTnoHFrings          : INOUT tRetVal;
-- -------------
    VARIABLE reference_DemuxETandMETPackedLink           : IN tPackedLinkPipe;
    SIGNAL DemuxETandMETPackedLinkPipe                   : IN tPackedLinkPipe;
    VARIABLE retvalDemuxETandMETPackedLink               : INOUT tRetVal;
-- -------------
    VARIABLE reference_DemuxETandMETnoHFPackedLink       : IN tPackedLinkPipe;
    SIGNAL DemuxETandMETnoHFPackedLinkPipe               : IN tPackedLinkPipe;
    VARIABLE retvalDemuxETandMETnoHFPackedLink           : INOUT tRetVal;
-- -------------
    VARIABLE reference_DemuxHTandMHTPackedLink           : IN tPackedLinkPipe;
    SIGNAL DemuxHTandMHTPackedLinkPipe                   : IN tPackedLinkPipe;
    VARIABLE retvalDemuxHTandMHTPackedLink               : INOUT tRetVal;
-- -------------
    VARIABLE reference_DemuxHTandMHTnoHFPackedLink       : IN tPackedLinkPipe;
    SIGNAL DemuxHTandMHTnoHFPackedLinkPipe               : IN tPackedLinkPipe;
    VARIABLE retvalDemuxHTandMHTnoHFPackedLink           : INOUT tRetVal;
-- -------------
    CONSTANT debug                                       : IN BOOLEAN := false
-- -------------
  ) IS BEGIN

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_ETandMETrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Tower Count" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_TowerCount , -- expected latency
                    timeout , -- timeout
                    retvalTowerCount( index ) , -- return value
                    ( reference_TowerCount( index ) = TowerCountPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_ETandMETrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "ET AND MET Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_ETandMETring , -- expected latency
                    timeout , -- timeout
                    retvalETandMETrings( index ) , -- return value
                    ( reference_ETandMETrings( index ) = ETandMETringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_HTandMHTrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "HT AND MHT Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_HTandMHTring , -- expected latency
                    timeout , -- timeout
                    retvalHTandMHTrings( index ) , -- return value
                    ( reference_HTandMHTrings( index ) = HTandMHTringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_accumulatedETandMETrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Accumulated Tower Count" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_accumulatedTowerCount , -- expected latency
                    timeout , -- timeout
                    retvalAccumulatedTowerCount( index ) , -- return value
                    ( reference_accumulatedTowerCount( index ) = accumulatedTowerCountPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_CalibratedETandMETrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Calibrated ET AND MET Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_CalibratedETandMETring , -- expected latency
                    timeout , -- timeout
                    retvalCalibratedETandMETrings( index ) , -- return value
                    ( reference_CalibratedETandMETrings( index ) = CalibratedETandMETringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_accumulatedETandMETrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Accumulated ET AND MET Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_accumulatedETandMETring , -- expected latency
                    timeout , -- timeout
                    retvalAccumulatedETandMETrings( index ) , -- return value
                    ( reference_accumulatedETandMETrings( index ) = accumulatedETandMETringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_accumulatedHTandMHTrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Accumulated HT AND MHT Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_accumulatedHTandMHTring , -- expected latency
                    timeout , -- timeout
                    retvalAccumulatedHTandMHTrings( index ) , -- return value
                    ( reference_accumulatedHTandMHTrings( index ) = accumulatedHTandMHTringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_ClusterPileupEstimation'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Cluster Pileup Estimation" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_ClusterPileupEstimation , -- expected latency
                    timeout , -- timeout
                    retvalClusterPileupEstimation( index ) , -- return value
                    ( reference_ClusterPileupEstimation( index ) = ClusterPileupEstimationPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_ETandMETPackedLink'LENGTH - 1 ) LOOP
      CHECK_RESULT( "ET AND MET Packed Link" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_ETandMETPackedLink , -- expected latency
                    timeout , -- timeout
                    retvalETandMETPackedLink( index ) , -- return value
                    ( reference_ETandMETPackedLink( index ) = ETandMETPackedLinkPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_HTandMHTPackedLink'LENGTH - 1 ) LOOP
      CHECK_RESULT( "HT AND MHT Packed Link" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_HTandMHTPackedLink , -- expected latency
                    timeout , -- timeout
                    retvalHTandMHTPackedLink( index ) , -- return value
                    ( reference_HTandMHTPackedLink( index ) = HTandMHTPackedLinkPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_AuxInfoPackedLink'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Aux Info Packed Link" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_AuxInfoPackedLink , -- expected latency
                    timeout , -- timeout
                    retvalAuxInfoPackedLink( index ) , -- return value
                    ( reference_AuxInfoPackedLink( index ) = AuxInfoPackedLinkPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_DemuxAccumulatedETandMETrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux Accumulated ET AND MET Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_DemuxAccumulatedETandMETring , -- expected latency
                    timeout , -- timeout
                    retvalDemuxAccumulatedETandMETrings( index ) , -- return value
                    ( reference_DemuxAccumulatedETandMETrings( index ) = DemuxAccumulatedETandMETringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_DemuxAccumulatedETandMETnoHFrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux Accumulated ET AND MET (No HF) Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_DemuxAccumulatedETandMETnoHFring , -- expected latency
                    timeout , -- timeout
                    retvalDemuxAccumulatedETandMETnoHFrings( index ) , -- return value
                    ( reference_DemuxAccumulatedETandMETnoHFrings( index ) = DemuxAccumulatedETandMETnoHFringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_DemuxAccumulatedHTandMHTrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux Accumulated HT AND MHT Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_DemuxAccumulatedHTandMHTring , -- expected latency
                    timeout , -- timeout
                    retvalDemuxAccumulatedHTandMHTrings( index ) , -- return value
                    ( reference_DemuxAccumulatedHTandMHTrings( index ) = DemuxAccumulatedHTandMHTringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_DemuxAccumulatedHTandMHTnoHFrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux Accumulated HT AND MHT (No HF) Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_DemuxAccumulatedHTandMHTnoHFring , -- expected latency
                    timeout , -- timeout
                    retvalDemuxAccumulatedHTandMHTnoHFrings( index ) , -- return value
                    ( reference_DemuxAccumulatedHTandMHTnoHFrings( index ) = DemuxAccumulatedHTandMHTnoHFringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_polarETandMETrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Polar ET AND MET Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_polarETandMETring , -- expected latency
                    timeout , -- timeout
                    retvalpolarETandMETrings( index ) , -- return value
                    CONSISTANT( reference_polarETandMETrings( index ) , polarETandMETringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_polarETandMETnoHFrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Polar ET AND MET (No HF) Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_polarETandMETnoHFring , -- expected latency
                    timeout , -- timeout
                    retvalpolarETandMETnoHFrings( index ) , -- return value
                    CONSISTANT( reference_polarETandMETnoHFrings( index ) , polarETandMETnoHFringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_polarHTandMHTrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Polar HT AND MHT Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_polarHTandMHTring , -- expected latency
                    timeout , -- timeout
                    retvalpolarHTandMHTrings( index ) , -- return value
                    CONSISTANT( reference_polarHTandMHTrings( index ) , polarHTandMHTringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_polarHTandMHTnoHFrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Polar HT AND MHT (No HF) Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_polarHTandMHTnoHFring , -- expected latency
                    timeout , -- timeout
                    retvalpolarHTandMHTnoHFrings( index ) , -- return value
                    CONSISTANT( reference_polarHTandMHTnoHFrings( index ) , polarHTandMHTnoHFringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_GtFormattedETandMETrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "GtFormatted ET AND MET Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_GtFormattedETandMETring , -- expected latency
                    timeout , -- timeout
                    retvalGtFormattedETandMETrings( index ) , -- return value
                    CONSISTANT( reference_GtFormattedETandMETrings( index ) , GtFormattedETandMETringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_GtFormattedETandMETnoHFrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "GtFormatted ET AND MET (No HF) Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_GtFormattedETandMETnoHFring , -- expected latency
                    timeout , -- timeout
                    retvalGtFormattedETandMETnoHFrings( index ) , -- return value
                    CONSISTANT( reference_GtFormattedETandMETnoHFrings( index ) , GtFormattedETandMETnoHFringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_GtFormattedHTandMHTrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "GtFormatted HT AND MHT Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_GtFormattedHTandMHTring , -- expected latency
                    timeout , -- timeout
                    retvalGtFormattedHTandMHTrings( index ) , -- return value
                    CONSISTANT( reference_GtFormattedHTandMHTrings( index ) , GtFormattedHTandMHTringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_GtFormattedHTandMHTnoHFrings'LENGTH - 1 ) LOOP
      CHECK_RESULT( "GtFormatted HT AND MHT (No HF) Rings" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_GtFormattedHTandMHTnoHFring , -- expected latency
                    timeout , -- timeout
                    retvalGtFormattedHTandMHTnoHFrings( index ) , -- return value
                    CONSISTANT( reference_GtFormattedHTandMHTnoHFrings( index ) , GtFormattedHTandMHTnoHFringPipe( 0 ) ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_DemuxETandMETPackedLink'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux ET AND MET Packed Link" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_DemuxETandMETPackedLink , -- expected latency
                    timeout , -- timeout
                    retvalDemuxETandMETPackedLink( index ) , -- return value
                    ( reference_DemuxETandMETPackedLink( index ) = DemuxETandMETPackedLinkPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_DemuxETandMETPackedLink'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux ET AND MET (No HF) Packed Link" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_DemuxETandMETnoHFPackedLink , -- expected latency
                    timeout , -- timeout
                    retvalDemuxETandMETnoHFPackedLink( index ) , -- return value
                    ( reference_DemuxETandMETnoHFPackedLink( index ) = DemuxETandMETnoHFPackedLinkPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_DemuxHTandMHTPackedLink'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux HT AND MHT Packed Link" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_DemuxHTandMHTPackedLink , -- expected latency
                    timeout , -- timeout
                    retvalDemuxHTandMHTPackedLink( index ) , -- return value
                    ( reference_DemuxHTandMHTPackedLink( index ) = DemuxHTandMHTPackedLinkPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_DemuxHTandMHTnoHFPackedLink'LENGTH - 1 ) LOOP
      CHECK_RESULT( "Demux HT AND MHT (No HF) Packed Link" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_DemuxHTandMHTnoHFPackedLink , -- expected latency
                    timeout , -- timeout
                    retvalDemuxHTandMHTnoHFPackedLink( index ) , -- return value
                    ( reference_DemuxHTandMHTnoHFPackedLink( index ) = DemuxHTandMHTnoHFPackedLinkPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

  END RingsumChecker;



  PROCEDURE RingsumReport
  (
    VARIABLE retvalTowerCount                        : IN tRetVal;
    VARIABLE retvalETandMETrings                     : IN tRetVal;
    VARIABLE retvalHTandMHTrings                     : IN tRetVal;
    VARIABLE retvalAccumulatedTowerCount             : IN tRetVal;
    VARIABLE retvalCalibratedETandMETrings           : IN tRetVal;
    VARIABLE retvalAccumulatedETandMETrings          : IN tRetVal;
    VARIABLE retvalAccumulatedHTandMHTrings          : IN tRetVal;
    VARIABLE retvalClusterPileupEstimation           : IN tRetVal;
    VARIABLE retvalETandMETPackedLink                : IN tRetVal;
    VARIABLE retvalHTandMHTPackedLink                : IN tRetVal;
    VARIABLE retvalAuxInfoPackedLink                 : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedETandMETrings     : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedETandMETnoHFrings : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedHTandMHTrings     : IN tRetVal;
    VARIABLE retvalDemuxAccumulatedHTandMHTnoHFrings : IN tRetVal;
    VARIABLE retvalPolarETandMETrings                : IN tRetVal;
    VARIABLE retvalPolarETandMETNoHFrings            : IN tRetVal;
    VARIABLE retvalPolarHTandMHTrings                : IN tRetVal;
    VARIABLE retvalPolarHTandMHTnoHFrings            : IN tRetVal;
    VARIABLE retvalGtFormattedETandMETrings          : IN tRetVal;
    VARIABLE retvalGtFormattedETandMETNoHFrings      : IN tRetVal;
    VARIABLE retvalGtFormattedHTandMHTrings          : IN tRetVal;
    VARIABLE retvalGtFormattedHTandMHTnoHFrings      : IN tRetVal;
    VARIABLE retvalDemuxETandMETPackedLink           : IN tRetVal;
    VARIABLE retvalDemuxETandMETNoHFPackedLink       : IN tRetVal;
    VARIABLE retvalDemuxHTandMHTPackedLink           : IN tRetVal;
    VARIABLE retvalDemuxHTandMHTNoHFPackedLink       : IN tRetVal
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    REPORT_RESULT( "Tower Count" , retvalTowerCount );
    REPORT_RESULT( "ET AND MET Rings" , retvalETandMETrings );
    REPORT_RESULT( "HT AND MHT Rings" , retvalHTandMHTrings );
    REPORT_RESULT( "Accumulated Tower Count" , retvalAccumulatedTowerCount );
    REPORT_RESULT( "Calibrated ET AND MET Rings" , retvalCalibratedETandMETrings );
    REPORT_RESULT( "Accumulated ET AND MET Rings" , retvalAccumulatedETandMETrings );
    REPORT_RESULT( "Accumulated HT AND MHT Rings" , retvalAccumulatedHTandMHTrings );
    REPORT_RESULT( "Cluster Pileup Estimation" , retvalClusterPileupEstimation );
    REPORT_RESULT( "ET AND MET Packed Link" , retvalETandMETPackedLink );
    REPORT_RESULT( "HT AND MHT Packed Link" , retvalHTandMHTPackedLink );
    REPORT_RESULT( "Aux Info Packed Link" , retvalAuxInfoPackedLink );
    REPORT_RESULT( "Demux Accumulated ET AND MET Rings" , retvalDemuxAccumulatedETandMETrings );
    REPORT_RESULT( "Demux Accumulated ET AND MET (No HF) Rings" , retvalDemuxAccumulatedETandMETnoHFrings );
    REPORT_RESULT( "Demux Accumulated HT AND MHT Rings" , retvalDemuxAccumulatedHTandMHTrings );
    REPORT_RESULT( "Demux Accumulated HT AND MHT (No HF) Rings" , retvalDemuxAccumulatedHTandMHTnoHFrings );
    REPORT_RESULT( "Polar ET AND MET Rings" , retvalPolarETandMETrings );
    REPORT_RESULT( "Polar ET AND MET (No HF) Rings" , retvalPolarETandMETnoHFrings );
    REPORT_RESULT( "Polar HT AND MHT Rings" , retvalPolarHTandMHTrings );
    REPORT_RESULT( "Polar HT AND MHT (No HF) Rings" , retvalPolarHTandMHTnoHFrings );
    REPORT_RESULT( "Gt Formatted ET AND MET Rings" , retvalGtFormattedETandMETrings );
    REPORT_RESULT( "Gt Formatted ET AND MET (No HF) Rings" , retvalGtFormattedETandMETnoHFrings );
    REPORT_RESULT( "Gt Formatted HT AND MHT Rings" , retvalGtFormattedHTandMHTrings );
    REPORT_RESULT( "Gt Formatted HT AND MHT (No HF) Rings" , retvalGtFormattedHTandMHTnoHFrings );
    REPORT_RESULT( "Demux ET AND MET Packed Link" , retvalDemuxETandMETPackedLink );
    REPORT_RESULT( "Demux ET AND MET (No HF) Packed Link" , retvalDemuxETandMETnoHFPackedLink );
    REPORT_RESULT( "Demux HT AND MHT Packed Link" , retvalDemuxHTandMHTPackedLink );
    REPORT_RESULT( "Demux HT AND MHT (No HF) Packed Link" , retvalDemuxHTandMHTNoHFPackedLink );
-- -----------------------------------------------------------------------------------------------------
  END RingsumReport;



  FUNCTION CONSISTANT( Left , Right : tPolarRingSegment ) RETURN BOOLEAN IS
  BEGIN
-- -----------------------------------------------------------------------------------------------------
    RETURN( Left.ScalarMagnitude = Right.ScalarMagnitude ) AND( Left.EcalMagnitude = Right.EcalMagnitude ) AND
           ( TO_INTEGER( Left.VectorMagnitude ) = 0 OR ABS( TO_INTEGER( Left.VectorPhi ) - TO_INTEGER( Right.VectorPhi ) ) <= 8 ) AND -- Zero magnitude -> undefined angle
           ( ABS( TO_INTEGER( Left.VectorMagnitude ) - TO_INTEGER( Right.VectorMagnitude ) )                               <= 8 ) AND
           ( Left.DataValid = Right.DataValid );
-- -----------------------------------------------------------------------------------------------------
  END FUNCTION;

END PACKAGE BODY RingsumReference;
