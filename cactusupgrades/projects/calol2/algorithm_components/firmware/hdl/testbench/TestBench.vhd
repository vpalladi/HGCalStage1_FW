--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

USE STD.TEXTIO.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;
--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! Using the Calo-L2 "helper" helper functions
USE work.helper_functions.ALL;

USE work.LinkType.ALL;
--! Using the Calo-L2 "Link" testbench suite
USE work.LinkReference.ALL;
--! Using the Calo-L2 "Tower" testbench suite
USE work.TowerReference.ALL;
--! Using the Calo-L2 "Jet" testbench suite
USE work.JetReference.ALL;

--! Using the Calo-L2 "Cluster" testbench suite
USE work.ClusterReference.ALL;
--! Using the Calo-L2 "Egamma" testbench suite
USE work.EgammaReference.ALL;
--! Using the Calo-L2 "Tau" testbench suite
USE work.TauReference.ALL;

--! Using the Calo-L2 "Ringsum" testbench suite
USE work.RingsumReference.ALL;


--! @brief An entity providing a TestBench
--! @details Detailed description
ENTITY TestBench IS
GENERIC(
  timeout               : INTEGER := cTestbenchTowersInHalfEta + 70;
  numberOfFrames        : INTEGER := cTestbenchTowersInHalfEta;
  sourcefile            : STRING;
  tower_latency_debug   : BOOLEAN := FALSE;
  jet_latency_debug     : BOOLEAN := FALSE;
  cluster_latency_debug : BOOLEAN := FALSE;
  egamma_latency_debug  : BOOLEAN := FALSE;
  tau_latency_debug     : BOOLEAN := FALSE;
  sum_latency_debug     : BOOLEAN := FALSE;
  link_latency_debug    : BOOLEAN := FALSE;
  create_intermediates  : BOOLEAN := FALSE;
  tower_intermediates   : BOOLEAN := FALSE;
  cluster_intermediates : BOOLEAN := FALSE;
  egamma_intermediates  : BOOLEAN := FALSE;
  tau_intermediates     : BOOLEAN := FALSE

);
END TestBench;

--! @brief Architecture definition for entity TestBench
--! @details Detailed description
ARCHITECTURE behavioral OF TestBench IS





  SIGNAL clk , ipbus_clk                      : STD_LOGIC                               := '1';
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- LINK SIGNALS
  SIGNAL links_in                             : ldata( cNumberOfLinksIn-1 DOWNTO 0 )    := ( OTHERS => LWORD_NULL );
  SIGNAL links_int_1 , links_int_2            : ldata( cNumberOfLinksIn-1 DOWNTO 0 )    := ( OTHERS => LWORD_NULL );
  SIGNAL links_demuxed                        : ldata( ( 6 * 11 ) -1 DOWNTO 0 )         := ( OTHERS => LWORD_NULL );
  SIGNAL links_out                            : ldata( cNumberOfLinksIn-1 DOWNTO 0 )    := ( OTHERS => LWORD_NULL );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TOWER SIGNALS
  SIGNAL towerPipe                            : tTowerPipe( 15 DOWNTO 0 )               := ( OTHERS => cEmptyTowerInEtaPhi );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- JET SIGNALS
  SIGNAL sum3x3Pipe                           : tJetPipe( 9 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL sum3x9Pipe                           : tJetPipe( 0 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL sum9x3Pipe                           : tJetPipe( 12 DOWNTO 0 )                 := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL jets9x9VetoPipe                      : tComparisonPipe( 13 DOWNTO 0 )          := ( OTHERS => cEmptyComparisonInEtaPhi );
  SIGNAL filteredJetPipe                      : tJetPipe( 4 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL filteredPileUpPipe                   : tJetPipe( 1 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL pileUpSubtractedJetPipe              : tJetPipe( 4 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL CalibratedJetPipe                    : tJetPipe( 1 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL sortedJetPipe                        : tJetPipe( 1 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL accumulatedSortedJetPipe             : tJetPipe( 3 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL jetAccumulationCompletePipe          : tAccumulationCompletePipe( 3 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta );
  SIGNAL jetPackedLinkPipe                    : tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );

  SIGNAL demuxAccumulatedSortedJetPipe        : tJetPipe( 1 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL mergedSortedJetPipe                  : tJetPipe( 1 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL gtFormattedJetPipe                   : tGtFormattedJetPipe( 0 DOWNTO 0 )       := ( OTHERS => cEmptyGtFormattedJets );
  SIGNAL DemuxJetPackedLinkPipe               : tPackedLinkPipe( 11 DOWNTO 0 )          := ( OTHERS => cEmptyPackedLinkInCandidates );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMMON CLUSTER SIGNALS
  SIGNAL tau3x3VetoPipe                       : tComparisonPipe( 7 DOWNTO 0 )           := ( OTHERS => cEmptyComparisonInEtaPhi );
  SIGNAL egamma9x3VetoPipe                    : tComparisonPipe( 7 DOWNTO 0 )           := ( OTHERS => cEmptyComparisonInEtaPhi );
  SIGNAL towerThresholdsPipe                  : tTowerFlagsPipe( 15 DOWNTO 0 )          := ( OTHERS => cEmptyTowerFlagInEtaPhi );
  SIGNAL ProtoClusterPipe                     : tClusterPipe( 3 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL FilteredProtoClusterPipe             : tClusterPipe( 4 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL ClusterInputPipe                     : tClusterInputPipe( 0 DOWNTO 0 )         := ( OTHERS => cEmptyClusterInputInEtaPhi );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- E / GAMMA SIGNALS
  SIGNAL EgammaProtoClusterPipe               : tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL EgammaClusterPipe                    : tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL EgammaIsolationRegionPipe            : tIsolationRegionPipe( 7 DOWNTO 0 )      := ( OTHERS => cEmptyIsolationRegionInEtaPhi );
  SIGNAL Isolation9x6Pipe                     : tIsolationRegionPipe( 7 DOWNTO 0 )      := ( OTHERS => cEmptyIsolationRegionInEtaPhi );
  SIGNAL Isolation5x2Pipe                     : tIsolationRegionPipe( 7 DOWNTO 0 )      := ( OTHERS => cEmptyIsolationRegionInEtaPhi );

  SIGNAL ClusterPileupEstimationPipe          : tPileupEstimationPipe( 9 DOWNTO 0 )     := ( OTHERS => cEmptyPileupEstimationInEtaPhi );
  SIGNAL ClusterPileupEstimationPipe2         : tPileupEstimationPipe2( 9 DOWNTO 0 )    := ( OTHERS => cEmptyPileupEstimation );
-- SIGNAL EgammaIsolationFlagPipe : tComparisonPipe( 7 DOWNTO 0 ) := ( OTHERS => cEmptyComparisonInEtaPhi );

  SIGNAL CalibratedEgammaPipe                 : tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL SortedEgammaPipe                     : tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL accumulatedSortedEgammaPipe          : tClusterPipe( 4 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL EgammaAccumulationCompletePipe       : tAccumulationCompletePipe( 4 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta );
  SIGNAL EgammaPackedLinkPipe                 : tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL demuxAccumulatedSortedEgammaPipe     : tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL mergedSortedEgammaPipe               : tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL GtFormattedEgammaPipe                : tGtFormattedClusterPipe( 0 DOWNTO 0 )   := ( OTHERS => cEmptyGtFormattedClusters );
  SIGNAL DemuxEgammaPackedLinkPipe            : tPackedLinkPipe( 11 DOWNTO 0 )          := ( OTHERS => cEmptyPackedLinkInCandidates );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TAU SIGNALS
  SIGNAL TauSecondariesPipe                   : tClusterPipe( 0 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL FilteredTauSecondariesPipe           : tClusterPipe( 5 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL TauProtoClusterPipe                  : tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL TauPrimaryPipe                       : tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL TauIsolationRegionPipe               : tIsolationRegionPipe( 7 DOWNTO 0 )      := ( OTHERS => cEmptyIsolationRegionInEtaPhi );
  SIGNAL FinalTauPipe                         : tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL CalibratedTauPipe                    : tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL SortedTauPipe                        : tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL accumulatedSortedTauPipe             : tClusterPipe( 4 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL TauAccumulationCompletePipe          : tAccumulationCompletePipe( 4 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta );
  SIGNAL TauPackedLinkPipe                    : tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );

  SIGNAL demuxAccumulatedSortedTauPipe        : tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL mergedSortedTauPipe                  : tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL GtFormattedTauPipe                   : tGtFormattedClusterPipe( 0 DOWNTO 0 )   := ( OTHERS => cEmptyGtFormattedClusters );
  SIGNAL DemuxTauPackedLinkPipe               : tPackedLinkPipe( 11 DOWNTO 0 )          := ( OTHERS => cEmptyPackedLinkInCandidates );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RINGSUM SIGNALS
  SIGNAL TowerCountPipe                       : tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL accumulatedTowerCountPipe            : tRingSegmentPipe2( 8 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );

  SIGNAL ETandMETringPipe                     : tRingSegmentPipe2( 10 DOWNTO 0 )        := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL HTandMHTringPipe                     : tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL calibratedETandMETringPipe           : tRingSegmentPipe2( 8 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL accumulatedETandMETringPipe          : tRingSegmentPipe2( 8 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL accumulatedHTandMHTringPipe          : tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL HTandMHTaccumulationCompletePipe     : tAccumulationCompletePipe( 1 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta );
  SIGNAL ETandMETaccumulationCompletePipe     : tAccumulationCompletePipe( 8 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta );
  SIGNAL HTandMHTPackedLinkPipe               : tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL ETandMETPackedLinkPipe               : tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );

  SIGNAL AuxInfoPackedLinkPipe                : tPackedLinkPipe( 0 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );

  SIGNAL demuxAccumulatedHTandMHTringPipe     : tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL demuxAccumulatedHTandMHTnoHFringPipe : tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL demuxAccumulatedETandMETringPipe     : tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL demuxAccumulatedETandMETnoHFringPipe : tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL polarHTandMHTringPipe                : tPolarRingSegmentPipe( 5 DOWNTO 0 )     := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL polarHTandMHTnoHFringPipe            : tPolarRingSegmentPipe( 5 DOWNTO 0 )     := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL polarETandMETringPipe                : tPolarRingSegmentPipe( 5 DOWNTO 0 )     := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL polarETandMETnoHFringPipe            : tPolarRingSegmentPipe( 5 DOWNTO 0 )     := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL GtFormattedHTandMHTringPipe          : tPolarRingSegmentPipe( 0 DOWNTO 0 )     := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL GtFormattedHTandMHTnoHFringPipe      : tPolarRingSegmentPipe( 0 DOWNTO 0 )     := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL GtFormattedETandMETringPipe          : tPolarRingSegmentPipe( 0 DOWNTO 0 )     := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL GtFormattedETandMETnoHFringPipe      : tPolarRingSegmentPipe( 0 DOWNTO 0 )     := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL DemuxHTandMHTPackedLinkPipe          : tPackedLinkPipe( 7 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL DemuxHTandMHTNoHFPackedLinkPipe      : tPackedLinkPipe( 7 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL DemuxETandMETPackedLinkPipe          : tPackedLinkPipe( 7 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL DemuxETandMETnoHFPackedLinkPipe      : tPackedLinkPipe( 7 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );

  SIGNAL PileUpEstimationPipe                 : tPileUpEstimationPipe2( 7 DOWNTO 0 )    := ( OTHERS => cEmptyPileUpEstimation );
  SIGNAL MinBiasPipe                          : tRingSegmentPipe2( 7 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


BEGIN

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    clk       <= NOT clk AFTER 2083 ps;
    ipbus_clk <= NOT ipbus_clk AFTER 30 ns;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- =========================================================================================================================================================================================
-- GENERATION OF REFERENCE SIGNALS AND CROSS-CHECKING
-- =========================================================================================================================================================================================
  references                                             : PROCESS( clk )

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CLOCK COUNTER
    VARIABLE clk_count                                   : INTEGER                                                                    := -1;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- LINK VARIABLES
-- INPUT
    VARIABLE reference_Links                             : tLinkPipe( NumberOfFrames-1 DOWNTO 0 )                                     := ( OTHERS => cEmptyLinks );
-- OUTPUTS
    VARIABLE reference_mpLinkOut                         : tLinkPipe( 10 DOWNTO 0 )                                                   := ( OTHERS => cEmptyLinks );
    VARIABLE retvalMpLinkOut                             : tRetVal( reference_mpLinkOut'LENGTH - 1 DOWNTO 0 )                         := ( OTHERS => 0 );

    VARIABLE reference_demuxLinkOut                      : tLinkPipe( 5 DOWNTO 0 )                                                    := ( OTHERS => cEmptyLinks );
    VARIABLE retvalDemuxLinkOut                          : tRetVal( reference_demuxLinkOut'LENGTH - 1 DOWNTO 0 )                      := ( OTHERS => 0 );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TOWER VARIABLES
    VARIABLE reference_Towers                            : tTowerPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                         := ( OTHERS => cEmptyTowerInEtaPhi );
    VARIABLE retvalTowers                                : tRetVal( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => 0 );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- JET VARIABLES
    VARIABLE reference_3x3Sum                            : tJetPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                           := ( OTHERS => cEmptyJetInEtaPhi );
    VARIABLE retval3x3Sum                                : tRetVal( reference_3x3Sum'LENGTH - 1 DOWNTO 0 )                            := ( OTHERS => 0 );

    VARIABLE reference_9x3Sum                            : tJetPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                           := ( OTHERS => cEmptyJetInEtaPhi );
    VARIABLE retval9x3Sum                                : tRetVal( reference_9x3Sum'LENGTH - 1 DOWNTO 0 )                            := ( OTHERS => 0 );

    VARIABLE reference_3x9Sum                            : tJetPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                           := ( OTHERS => cEmptyJetInEtaPhi );
    VARIABLE retval3x9Sum                                : tRetVal( reference_3x9Sum'LENGTH - 1 DOWNTO 0 )                            := ( OTHERS => 0 );

    VARIABLE reference_9x9Veto                           : tComparisonPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                    := ( OTHERS => cEmptyComparisonInEtaPhi );
    VARIABLE retval9x9Veto                               : tRetVal( reference_9x9Veto'LENGTH - 1 DOWNTO 0 )                           := ( OTHERS => 0 );

    VARIABLE reference_JetSum                            : tJetPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                           := ( OTHERS => cEmptyJetInEtaPhi );
    VARIABLE retvalJetSum                                : tRetVal( reference_JetSum'LENGTH - 1 DOWNTO 0 )                            := ( OTHERS => 0 );

    VARIABLE reference_JetPUestimate                     : tJetPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                           := ( OTHERS => cEmptyJetInEtaPhi );
    VARIABLE retvalJetPUestimate                         : tRetVal( reference_JetPUestimate'LENGTH - 1 DOWNTO 0 )                     := ( OTHERS => 0 );

    VARIABLE reference_PUsubJet                          : tJetPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                           := ( OTHERS => cEmptyJetInEtaPhi );
    VARIABLE retvalPUsubJet                              : tRetVal( reference_PUsubJet'LENGTH - 1 DOWNTO 0 )                          := ( OTHERS => 0 );

    VARIABLE reference_CalibratedJet                     : tJetPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                           := ( OTHERS => cEmptyJetInEtaPhi );
    VARIABLE retvalCalibratedJet                         : tRetVal( reference_CalibratedJet'LENGTH - 1 DOWNTO 0 )                     := ( OTHERS => 0 );

    VARIABLE reference_sortedJet                         : tJetPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                           := ( OTHERS => cEmptyJetInEtaPhi );
    VARIABLE retvalSortedJet                             : tRetVal( reference_sortedJet'LENGTH - 1 DOWNTO 0 )                         := ( OTHERS => 0 );

    VARIABLE reference_accumulatedsortedJet              : tJetPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                           := ( OTHERS => cEmptyJetInEtaPhi );
    VARIABLE retvalAccumulatedsortedJet                  : tRetVal( reference_accumulatedsortedJet'LENGTH - 1 DOWNTO 0 )              := ( OTHERS => 0 );

    VARIABLE reference_jetPackedLink                     : tPackedLinkPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                    := ( OTHERS => cEmptyPackedLinkInCandidates );
    VARIABLE retvalJetPackedLink                         : tRetVal( reference_jetPackedLink'LENGTH - 1 DOWNTO 0 )                     := ( OTHERS => 0 );

    VARIABLE reference_demuxAccumulatedsortedJet         : tJetPipe( 0 DOWNTO 0 )                                                     := ( OTHERS => cEmptyJetInEtaPhi );
    VARIABLE retvalDemuxAccumulatedsortedJet             : tRetVal( reference_demuxAccumulatedsortedJet'LENGTH - 1 DOWNTO 0 )         := ( OTHERS => 0 );

    VARIABLE reference_mergedsortedJet                   : tJetPipe( 0 DOWNTO 0 )                                                     := ( OTHERS => cEmptyJetInEtaPhi );
    VARIABLE retvalMergedsortedJet                       : tRetVal( reference_mergedsortedJet'LENGTH - 1 DOWNTO 0 )                   := ( OTHERS => 0 );

    VARIABLE reference_gtFormattedJet                    : tGtFormattedJetPipe( 0 DOWNTO 0 )                                          := ( OTHERS => cEmptyGtFormattedJets );
    VARIABLE retvalGtFormattedJet                        : tRetVal( reference_gtFormattedJet'LENGTH - 1 DOWNTO 0 )                    := ( OTHERS => 0 );

    VARIABLE reference_DemuxJetPackedLink                : tPackedLinkPipe( 0 DOWNTO 0 )                                              := ( OTHERS => cEmptyPackedLinkInCandidates );
    VARIABLE retvalDemuxJetPackedLink                    : tRetVal( reference_DemuxJetPackedLink'LENGTH - 1 DOWNTO 0 )                := ( OTHERS => 0 );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RING VARIABLES
    VARIABLE reference_TowerCount                        : tRingSegmentPipe2( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                  := ( OTHERS => cEmptyRingSegmentInEta );
    VARIABLE retvalTowerCount                            : tRetVal( reference_TowerCount'LENGTH - 1 DOWNTO 0 )                        := ( OTHERS => 0 );

    VARIABLE reference_accumulatedTowerCount             : tRingSegmentPipe2( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                  := ( OTHERS => cEmptyRingSegmentInEta );
    VARIABLE retvalAccumulatedTowerCount                 : tRetVal( reference_accumulatedTowerCount'LENGTH - 1 DOWNTO 0 )             := ( OTHERS => 0 );

    VARIABLE reference_ETandMETrings                     : tRingSegmentPipe2( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                  := ( OTHERS => cEmptyRingSegmentInEta );
    VARIABLE retvalETandMETrings                         : tRetVal( reference_ETandMETrings'LENGTH - 1 DOWNTO 0 )                     := ( OTHERS => 0 );

    VARIABLE reference_HTandMHTrings                     : tRingSegmentPipe2( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                  := ( OTHERS => cEmptyRingSegmentInEta );
    VARIABLE retvalHTandMHTrings                         : tRetVal( reference_HTandMHTrings'LENGTH - 1 DOWNTO 0 )                     := ( OTHERS => 0 );

    VARIABLE reference_calibratedETandMETrings           : tRingSegmentPipe2( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                  := ( OTHERS => cEmptyRingSegmentInEta );
    VARIABLE retvalCalibratedETandMETrings               : tRetVal( reference_calibratedETandMETrings'LENGTH - 1 DOWNTO 0 )           := ( OTHERS => 0 );

    VARIABLE reference_accumulatedETandMETrings          : tRingSegmentPipe2( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                  := ( OTHERS => cEmptyRingSegmentInEta );
    VARIABLE retvalAccumulatedETandMETrings              : tRetVal( reference_accumulatedETandMETrings'LENGTH - 1 DOWNTO 0 )          := ( OTHERS => 0 );

    VARIABLE reference_accumulatedHTandMHTrings          : tRingSegmentPipe2( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                  := ( OTHERS => cEmptyRingSegmentInEta );
    VARIABLE retvalAccumulatedHTandMHTrings              : tRetVal( reference_accumulatedHTandMHTrings'LENGTH - 1 DOWNTO 0 )          := ( OTHERS => 0 );

    VARIABLE reference_ETandMETPackedLink                : tPackedLinkPipe( 1 DOWNTO 0 )                                              := ( OTHERS => cEmptyPackedLinkInCandidates );
    VARIABLE retvalETandMETPackedLink                    : tRetVal( reference_ETandMETPackedLink'LENGTH - 1 DOWNTO 0 )                := ( OTHERS => 0 );

    VARIABLE reference_HTandMHTPackedLink                : tPackedLinkPipe( 1 DOWNTO 0 )                                              := ( OTHERS => cEmptyPackedLinkInCandidates );
    VARIABLE retvalHTandMHTPackedLink                    : tRetVal( reference_HTandMHTPackedLink'LENGTH - 1 DOWNTO 0 )                := ( OTHERS => 0 );

    VARIABLE reference_AuxInfoPackedLink                 : tPackedLinkPipe( 0 DOWNTO 0 )                                              := ( OTHERS => cEmptyPackedLinkInCandidates );
    VARIABLE retvalAuxInfoPackedLink                     : tRetVal( reference_AuxInfoPackedLink'LENGTH - 1 DOWNTO 0 )                 := ( OTHERS => 0 );

    VARIABLE reference_demuxAccumulatedETandMETrings     : tRingSegmentPipe2( 0 DOWNTO 0 )                                            := ( OTHERS => cEmptyRingSegmentInEta );
    VARIABLE retvalDemuxAccumulatedETandMETrings         : tRetVal( reference_demuxAccumulatedETandMETrings'LENGTH - 1 DOWNTO 0 )     := ( OTHERS => 0 );

    VARIABLE reference_demuxAccumulatedETandMETnoHFrings : tRingSegmentPipe2( 0 DOWNTO 0 )                                            := ( OTHERS => cEmptyRingSegmentInEta );
    VARIABLE retvalDemuxAccumulatedETandMETnoHFrings     : tRetVal( reference_demuxAccumulatedETandMETnoHFrings'LENGTH - 1 DOWNTO 0 ) := ( OTHERS => 0 );

    VARIABLE reference_demuxAccumulatedHTandMHTrings     : tRingSegmentPipe2( 0 DOWNTO 0 )                                            := ( OTHERS => cEmptyRingSegmentInEta );
    VARIABLE retvalDemuxAccumulatedHTandMHTrings         : tRetVal( reference_demuxAccumulatedHTandMHTrings'LENGTH - 1 DOWNTO 0 )     := ( OTHERS => 0 );

    VARIABLE reference_demuxAccumulatedHTandMHTnoHFrings : tRingSegmentPipe2( 0 DOWNTO 0 )                                            := ( OTHERS => cEmptyRingSegmentInEta );
    VARIABLE retvalDemuxAccumulatedHTandMHTnoHFrings     : tRetVal( reference_demuxAccumulatedHTandMHTnoHFrings'LENGTH - 1 DOWNTO 0 ) := ( OTHERS => 0 );

    VARIABLE reference_polarETandMETrings                : tPolarRingSegmentPipe( 0 DOWNTO 0 )                                        := ( OTHERS => cEmptyPolarRingSegment );
    VARIABLE retvalpolarETandMETrings                    : tRetVal( reference_polarETandMETrings'LENGTH - 1 DOWNTO 0 )                := ( OTHERS => 0 );

    VARIABLE reference_polarETandMETNoHFrings            : tPolarRingSegmentPipe( 0 DOWNTO 0 )                                        := ( OTHERS => cEmptyPolarRingSegment );
    VARIABLE retvalpolarETandMETNoHFrings                : tRetVal( reference_polarETandMETNoHFrings'LENGTH - 1 DOWNTO 0 )            := ( OTHERS => 0 );

    VARIABLE reference_polarHTandMHTrings                : tPolarRingSegmentPipe( 0 DOWNTO 0 )                                        := ( OTHERS => cEmptyPolarRingSegment );
    VARIABLE retvalpolarHTandMHTrings                    : tRetVal( reference_polarHTandMHTrings'LENGTH - 1 DOWNTO 0 )                := ( OTHERS => 0 );

    VARIABLE reference_polarHTandMHTnoHFrings            : tPolarRingSegmentPipe( 0 DOWNTO 0 )                                        := ( OTHERS => cEmptyPolarRingSegment );
    VARIABLE retvalpolarHTandMHTnoHFrings                : tRetVal( reference_polarHTandMHTnoHFrings'LENGTH - 1 DOWNTO 0 )            := ( OTHERS => 0 );

    VARIABLE reference_GtFormattedETandMETrings          : tPolarRingSegmentPipe( 0 DOWNTO 0 )                                        := ( OTHERS => cEmptyPolarRingSegment );
    VARIABLE retvalGtFormattedETandMETrings              : tRetVal( reference_GtFormattedETandMETrings'LENGTH - 1 DOWNTO 0 )          := ( OTHERS => 0 );

    VARIABLE reference_GtFormattedETandMETNoHFrings      : tPolarRingSegmentPipe( 0 DOWNTO 0 )                                        := ( OTHERS => cEmptyPolarRingSegment );
    VARIABLE retvalGtFormattedETandMETNoHFrings          : tRetVal( reference_GtFormattedETandMETNoHFrings'LENGTH - 1 DOWNTO 0 )      := ( OTHERS => 0 );

    VARIABLE reference_GtFormattedHTandMHTrings          : tPolarRingSegmentPipe( 0 DOWNTO 0 )                                        := ( OTHERS => cEmptyPolarRingSegment );
    VARIABLE retvalGtFormattedHTandMHTrings              : tRetVal( reference_GtFormattedHTandMHTrings'LENGTH - 1 DOWNTO 0 )          := ( OTHERS => 0 );

    VARIABLE reference_GtFormattedHTandMHTnoHFrings      : tPolarRingSegmentPipe( 0 DOWNTO 0 )                                        := ( OTHERS => cEmptyPolarRingSegment );
    VARIABLE retvalGtFormattedHTandMHTnoHFrings          : tRetVal( reference_GtFormattedHTandMHTnoHFrings'LENGTH - 1 DOWNTO 0 )      := ( OTHERS => 0 );

    VARIABLE reference_DemuxETandMETPackedLink           : tPackedLinkPipe( 0 DOWNTO 0 )                                              := ( OTHERS => cEmptyPackedLinkInCandidates );
    VARIABLE retvalDemuxETandMETPackedLink               : tRetVal( reference_DemuxETandMETPackedLink'LENGTH - 1 DOWNTO 0 )           := ( OTHERS => 0 );

    VARIABLE reference_DemuxETandMETNoHFPackedLink       : tPackedLinkPipe( 0 DOWNTO 0 )                                              := ( OTHERS => cEmptyPackedLinkInCandidates );
    VARIABLE retvalDemuxETandMETNoHFPackedLink           : tRetVal( reference_DemuxETandMETNoHFPackedLink'LENGTH - 1 DOWNTO 0 )       := ( OTHERS => 0 );

    VARIABLE reference_DemuxHTandMHTPackedLink           : tPackedLinkPipe( 0 DOWNTO 0 )                                              := ( OTHERS => cEmptyPackedLinkInCandidates );
    VARIABLE retvalDemuxHTandMHTPackedLink               : tRetVal( reference_DemuxHTandMHTPackedLink'LENGTH - 1 DOWNTO 0 )           := ( OTHERS => 0 );

    VARIABLE reference_DemuxHTandMHTnoHFPackedLink       : tPackedLinkPipe( 0 DOWNTO 0 )                                              := ( OTHERS => cEmptyPackedLinkInCandidates );
    VARIABLE retvalDemuxHTandMHTnoHFPackedLink           : tRetVal( reference_DemuxHTandMHTnoHFPackedLink'LENGTH - 1 DOWNTO 0 )       := ( OTHERS => 0 );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMMON CLUSTER VARIABLES
    VARIABLE reference_3x3Veto                           : tComparisonPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                    := ( OTHERS => cEmptyComparisonInEtaPhi );
    VARIABLE retval3x3Veto                               : tRetVal( reference_3x3Veto'LENGTH - 1 DOWNTO 0 )                           := ( OTHERS => 0 );

    VARIABLE reference_9x3Veto                           : tComparisonPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                    := ( OTHERS => cEmptyComparisonInEtaPhi );
    VARIABLE retval9x3Veto                               : tRetVal( reference_9x3Veto'LENGTH - 1 DOWNTO 0 )                           := ( OTHERS => 0 );

    VARIABLE reference_TowerThresholds                   : tTowerFlagsPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )                    := ( OTHERS => cEmptyTowerFlagInEtaPhi );
    VARIABLE retvalTowerThresholds                       : tRetVal( reference_TowerThresholds'LENGTH - 1 DOWNTO 0 )                   := ( OTHERS => 0 );

    VARIABLE reference_ProtoClusters                     : tClusterPipe( cTestbenchTowersInHalfEta-2 DOWNTO 0 )                       := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalProtoClusters                         : tRetVal( reference_ProtoClusters'LENGTH - 1 DOWNTO 0 )                     := ( OTHERS => 0 );

    VARIABLE reference_FilteredProtoClusters             : tClusterPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalFilteredProtoClusters                 : tRetVal( reference_FilteredProtoClusters'LENGTH - 1 DOWNTO 0 )             := ( OTHERS => 0 );

    VARIABLE reference_ClusterInput                      : tClusterInputPipe( cTestbenchTowersInHalfEta-2 DOWNTO 0 )                  := ( OTHERS => cEmptyClusterInputInEtaPhi );
    VARIABLE retvalClusterInput                          : tRetVal( reference_ClusterInput'LENGTH - 1 DOWNTO 0 )                      := ( OTHERS => 0 );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- E / GAMMA VARIABLES
    VARIABLE reference_EgammaProtoCluster                : tClusterPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalEgammaProtoCluster                    : tRetVal( reference_EgammaProtoCluster'LENGTH - 1 DOWNTO 0 )                := ( OTHERS => 0 );

    VARIABLE reference_EgammaCluster                     : tClusterPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalEgammaCluster                         : tRetVal( reference_EgammaCluster'LENGTH - 1 DOWNTO 0 )                     := ( OTHERS => 0 );

    VARIABLE reference_Isolation9x6                      : tIsolationRegionPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                    := ( OTHERS => cEmptyIsolationRegionInEtaPhi );
    VARIABLE retvalIsolation9x6                          : tRetVal( reference_Isolation9x6'LENGTH - 1 DOWNTO 0 )                      := ( OTHERS => 0 );

    VARIABLE reference_Isolation5x2                      : tIsolationRegionPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                    := ( OTHERS => cEmptyIsolationRegionInEtaPhi );
    VARIABLE retvalIsolation5x2                          : tRetVal( reference_Isolation5x2'LENGTH - 1 DOWNTO 0 )                      := ( OTHERS => 0 );

    VARIABLE reference_EgammaIsolationRegion             : tIsolationRegionPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                    := ( OTHERS => cEmptyIsolationRegionInEtaPhi );
    VARIABLE retvalEgammaIsolationRegion                 : tRetVal( reference_EgammaIsolationRegion'LENGTH - 1 DOWNTO 0 )             := ( OTHERS => 0 );

    VARIABLE reference_ClusterPileupEstimation           : tPileupEstimationPipe( cTestbenchTowersInHalfEta-1 DOWNTO 0 )              := ( OTHERS => cEmptyPileupEstimationInEtaPhi );
    VARIABLE retvalClusterPileupEstimation               : tRetVal( reference_ClusterPileupEstimation'LENGTH - 1 DOWNTO 0 )           := ( OTHERS => 0 );

    VARIABLE reference_CalibratedEgamma                  : tClusterPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalCalibratedEgamma                      : tRetVal( reference_CalibratedEgamma'LENGTH - 1 DOWNTO 0 )                  := ( OTHERS => 0 );

    VARIABLE reference_sortedEgamma                      : tClusterPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalSortedEgamma                          : tRetVal( reference_sortedEgamma'LENGTH - 1 DOWNTO 0 )                      := ( OTHERS => 0 );

    VARIABLE reference_accumulatedSortedEgamma           : tClusterPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalAccumulatedSortedEgamma               : tRetVal( reference_accumulatedSortedEgamma'LENGTH - 1 DOWNTO 0 )           := ( OTHERS => 0 );

    VARIABLE reference_EgammaPackedLink                  : tPackedLinkPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                         := ( OTHERS => cEmptyPackedLinkInCandidates );
    VARIABLE retvalEgammaPackedLink                      : tRetVal( reference_EgammaPackedLink'LENGTH - 1 DOWNTO 0 )                  := ( OTHERS => 0 );

    VARIABLE reference_demuxAccumulatedSortedEgamma      : tClusterPipe( 0 DOWNTO 0 )                                                 := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalDemuxAccumulatedSortedEgamma          : tRetVal( reference_demuxAccumulatedSortedEgamma'LENGTH - 1 DOWNTO 0 )      := ( OTHERS => 0 );

    VARIABLE reference_mergedSortedEgamma                : tClusterPipe( 0 DOWNTO 0 )                                                 := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalMergedSortedEgamma                    : tRetVal( reference_mergedSortedEgamma'LENGTH - 1 DOWNTO 0 )                := ( OTHERS => 0 );

    VARIABLE reference_GtFormattedEgamma                 : tGtFormattedClusterPipe( 0 DOWNTO 0 )                                      := ( OTHERS => cEmptyGtFormattedClusters );
    VARIABLE retvalGtFormattedEgamma                     : tRetVal( reference_GtFormattedEgamma'LENGTH - 1 DOWNTO 0 )                 := ( OTHERS => 0 );

    VARIABLE reference_DemuxEgammaPackedLink             : tPackedLinkPipe( 0 DOWNTO 0 )                                              := ( OTHERS => cEmptyPackedLinkInCandidates );
    VARIABLE retvalDemuxEgammaPackedLink                 : tRetVal( reference_DemuxEgammaPackedLink'LENGTH - 1 DOWNTO 0 )             := ( OTHERS => 0 );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------





-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TAU VARIABLES
    VARIABLE reference_TauSecondaries                    : tClusterPipe( cTestbenchTowersInHalfEta-3 DOWNTO 0 )                       := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalTauSecondaries                        : tRetVal( reference_TauSecondaries'LENGTH - 1 DOWNTO 0 )                    := ( OTHERS => 0 );

    VARIABLE reference_FilteredTauSecondaries            : tClusterPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalFilteredTauSecondaries                : tRetVal( reference_FilteredTauSecondaries'LENGTH - 1 DOWNTO 0 )            := ( OTHERS => 0 );

    VARIABLE reference_TauProtoCluster                   : tClusterPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalTauProtoCluster                       : tRetVal( reference_TauProtoCluster'LENGTH - 1 DOWNTO 0 )                   := ( OTHERS => 0 );

    VARIABLE reference_TauPrimary                        : tClusterPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalTauPrimary                            : tRetVal( reference_TauPrimary'LENGTH - 1 DOWNTO 0 )                        := ( OTHERS => 0 );

    VARIABLE reference_FinalTau                          : tClusterPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalFinalTau                              : tRetVal( reference_FinalTau'LENGTH - 1 DOWNTO 0 )                          := ( OTHERS => 0 );

    VARIABLE reference_TauIsolationRegion                : tIsolationRegionPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                    := ( OTHERS => cEmptyIsolationRegionInEtaPhi );
    VARIABLE retvalTauIsolationRegion                    : tRetVal( reference_EgammaIsolationRegion'LENGTH - 1 DOWNTO 0 )             := ( OTHERS => 0 );

    VARIABLE reference_CalibratedTau                     : tClusterPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalCalibratedTau                         : tRetVal( reference_CalibratedTau'LENGTH - 1 DOWNTO 0 )                     := ( OTHERS => 0 );

    VARIABLE reference_sortedTau                         : tClusterPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalSortedTau                             : tRetVal( reference_sortedTau'LENGTH - 1 DOWNTO 0 )                         := ( OTHERS => 0 );

    VARIABLE reference_accumulatedSortedTau              : tClusterPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                            := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalAccumulatedSortedTau                  : tRetVal( reference_accumulatedSortedTau'LENGTH - 1 DOWNTO 0 )              := ( OTHERS => 0 );

    VARIABLE reference_TauPackedLink                     : tPackedLinkPipe( cEcalTowersInHalfEta-1 DOWNTO 0 )                         := ( OTHERS => cEmptyPackedLinkInCandidates );
    VARIABLE retvalTauPackedLink                         : tRetVal( reference_TauPackedLink'LENGTH - 1 DOWNTO 0 )                     := ( OTHERS => 0 );

    VARIABLE reference_demuxAccumulatedSortedTau         : tClusterPipe( 0 DOWNTO 0 )                                                 := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalDemuxAccumulatedSortedTau             : tRetVal( reference_demuxAccumulatedSortedTau'LENGTH - 1 DOWNTO 0 )         := ( OTHERS => 0 );

    VARIABLE reference_mergedSortedTau                   : tClusterPipe( 0 DOWNTO 0 )                                                 := ( OTHERS => cEmptyClusterInEtaPhi );
    VARIABLE retvalMergedSortedTau                       : tRetVal( reference_mergedSortedTau'LENGTH - 1 DOWNTO 0 )                   := ( OTHERS => 0 );

    VARIABLE reference_GtFormattedTau                    : tGtFormattedClusterPipe( 0 DOWNTO 0 )                                      := ( OTHERS => cEmptyGtFormattedClusters );
    VARIABLE retvalGtFormattedTau                        : tRetVal( reference_GtFormattedTau'LENGTH - 1 DOWNTO 0 )                    := ( OTHERS => 0 );

    VARIABLE reference_DemuxTauPackedLink                : tPackedLinkPipe( 0 DOWNTO 0 )                                              := ( OTHERS => cEmptyPackedLinkInCandidates );
    VARIABLE retvalDemuxTauPackedLink                    : tRetVal( reference_DemuxTauPackedLink'LENGTH - 1 DOWNTO 0 )                := ( OTHERS => 0 );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    VARIABLE L                                           : LINE;


  BEGIN

    IF( RISING_EDGE( clk ) ) THEN

      WRITE( L , clk_count );
      WRITELINE( OUTPUT , L );


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      IF( clk_count = -1 ) THEN


--SourceLinkData( reference_Links );
--SourceLinkDataFile( sourcefile , 6 , 14 , 0 , 40 , FALSE , reference_Links ) ; --For direct capture
SourceLinkDataFile( sourcefile , 1 , 14 , 0 , 40 , FALSE , reference_Links ) ; --For aggregated captures
--SourceLinkDataFile( sourcefile , 0 , 6 , 0 , 40 , FALSE , reference_Links ) ; --Thomas' wierd file


        TowerReference
        (
          reference_Links ,
          reference_Towers
        );

        ClusterReference
        (
          reference_Towers ,
          reference_3x3Veto ,
          reference_9x3Veto ,
          reference_TowerThresholds ,
          reference_ProtoClusters ,
          reference_FilteredProtoClusters ,
          reference_ClusterInput ,
          reference_Isolation9x6
        );

        JetReference
        (
          reference_Towers ,
          reference_TowerThresholds ,
          reference_3x3Sum ,
          reference_9x3Sum ,
          reference_3x9Sum ,
          reference_9x9Veto ,
          reference_JetSum ,
          reference_JetPUestimate ,
          reference_PUsubJet ,
          reference_CalibratedJet ,
          reference_sortedJet ,
          reference_accumulatedsortedJet ,
          reference_jetPackedLink ,
          reference_demuxAccumulatedsortedJet ,
          reference_mergedsortedJet ,
          reference_gtFormattedJet ,
          reference_demuxJetPackedLink
        );

        RingsumReference
        (
          reference_Towers ,
          reference_CalibratedJet ,
          reference_TowerCount ,
          reference_ETandMETrings ,
          reference_HTandMHTrings ,
          reference_accumulatedTowerCount ,
          reference_calibratedETandMETrings ,
          reference_accumulatedETandMETrings ,
          reference_accumulatedHTandMHTrings ,
          reference_ClusterPileupEstimation ,
          reference_ETandMETPackedLink ,
          reference_HTandMHTPackedLink ,
          reference_AuxInfoPackedLink ,
          reference_demuxAccumulatedETandMETrings ,
          reference_demuxAccumulatedETandMETnoHFrings ,
          reference_demuxAccumulatedHTandMHTrings ,
          reference_demuxAccumulatedHTandMHTnoHFrings ,
          reference_polarETandMETrings ,
          reference_polarETandMETNoHFrings ,
          reference_polarHTandMHTrings ,
          reference_polarHTandMHTnoHFrings ,
          reference_GtFormattedETandMETrings ,
          reference_GtFormattedETandMETNoHFrings ,
          reference_GtFormattedHTandMHTrings ,
          reference_GtFormattedHTandMHTnoHFrings ,
          reference_DemuxETandMETPackedLink ,
          reference_DemuxETandMETNoHFPackedLink ,
          reference_DemuxHTandMHTPackedLink ,
          reference_DemuxHTandMHTnoHFPackedLink
        );

        EgammaReference
        (
          reference_Towers ,
          reference_3x3Veto ,
          reference_9x3Veto ,
          reference_TowerThresholds ,
          reference_FilteredProtoClusters ,
          reference_ClusterInput ,
          reference_EgammaProtoCluster ,
          reference_EgammaCluster ,
          reference_Isolation9x6 ,
          reference_Isolation5x2 ,
          reference_EgammaIsolationRegion ,
          reference_ClusterPileupEstimation ,
          reference_CalibratedEgamma ,
          reference_sortedEgamma ,
          reference_accumulatedSortedEgamma ,
          reference_EgammaPackedLink ,
          reference_demuxAccumulatedSortedEgamma ,
          reference_mergedSortedEgamma ,
          reference_GtFormattedEgamma ,
          reference_DemuxEgammaPackedLink
        );

        TauReference
        (
          reference_Towers ,
          reference_accumulatedETandMETrings ,
          reference_3x3Veto ,
          reference_9x3Veto ,
          reference_TowerThresholds ,
          reference_ProtoClusters ,
          reference_FilteredProtoClusters ,
          reference_ClusterInput ,

          reference_TauSecondaries ,
          reference_FilteredTauSecondaries ,
          reference_TauProtoCluster ,
          reference_TauPrimary ,
          reference_FinalTau ,
          reference_Isolation9x6 ,
          reference_ClusterPileupEstimation ,
          reference_TauIsolationRegion ,

          reference_CalibratedTau ,
          reference_sortedTau ,
          reference_accumulatedSortedTau ,
          reference_TauPackedLink ,
          reference_demuxAccumulatedSortedTau ,
          reference_mergedSortedTau ,
          reference_GtFormattedTau ,
          reference_DemuxTauPackedLink
        );


        LinkReference
        (
          reference_JetPackedLink ,
          reference_EgammaPackedLink ,
          reference_TauPackedLink ,
          reference_ETandMETPackedLink ,
          reference_HTandMHTPackedLink ,
          reference_AuxInfoPackedLink ,
          reference_mpLinkOut ,
          reference_DemuxETandMETPackedLink ,
          reference_DemuxETandMETNoHFPackedLink ,
          reference_DemuxHTandMHTPackedLink ,
          reference_DemuxHTandMHTNoHFPackedLink ,
          reference_DemuxJetPackedLink ,
          reference_DemuxEgammaPackedLink ,
          reference_DemuxTauPackedLink ,
          reference_demuxLinkOut
        );

      END IF;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      LinkStimulus
      (
        clk_count ,
        reference_Links ,
        links_in
      );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      IF( clk_count < timeout ) THEN
        IF tower_latency_debug OR jet_latency_debug OR sum_latency_debug OR cluster_latency_debug OR egamma_latency_debug OR tau_latency_debug OR link_latency_debug THEN
          PRINT_CLOCK( clk_count );
        END IF;

        TowerChecker
        (
          clk_count ,
          timeout ,
          reference_Towers , TowerPipe , retvalTowers ,
          tower_latency_debug
        );

        JetChecker
        (
          clk_count ,
          timeout ,
          reference_3x3Sum , sum3x3Pipe , retval3x3Sum ,
          reference_9x3Sum , sum9x3Pipe , retval9x3Sum ,
          reference_3x9Sum , sum3x9Pipe , retval3x9Sum ,
          reference_9x9Veto , jets9x9VetoPipe , retval9x9Veto ,
          reference_JetSum , filteredJetPipe , retvalJetSum ,
          reference_JetPUestimate , filteredPileUpPipe , retvalJetPUestimate ,
          reference_PUsubJet , pileUpSubtractedJetPipe , retvalPUsubJet ,
          reference_CalibratedJet , CalibratedJetPipe , retvalCalibratedJet ,
          reference_sortedJet , sortedJetPipe , retvalSortedJet ,
          reference_accumulatedsortedJet , accumulatedSortedJetPipe , retvalAccumulatedsortedJet ,
          reference_jetPackedLink , jetPackedLinkPipe , retvalJetPackedLink ,
          reference_demuxAccumulatedsortedJet , demuxAccumulatedSortedJetPipe , retvalDemuxAccumulatedsortedJet ,
          reference_mergedsortedJet , mergedSortedJetPipe , retvalMergedsortedJet ,
          reference_gtFormattedJet , gtFormattedJetPipe , retvalGtFormattedJet ,
          reference_demuxjetPackedLink , demuxjetPackedLinkPipe , retvaldemuxJetPackedLink ,
          jet_latency_debug
        );

        RingsumChecker
        (
          clk_count ,
          timeout ,
          reference_TowerCount , TowerCountPipe , retvalTowerCount ,
          reference_ETandMETrings , ETandMETringPipe , retvalETandMETrings ,
          reference_HTandMHTrings , HTandMHTringPipe , retvalHTandMHTrings ,
          reference_accumulatedTowerCount , accumulatedTowerCountPipe , retvalAccumulatedTowerCount ,
          reference_calibratedETandMETrings , calibratedETandMETringPipe , retvalCalibratedETandMETrings ,
          reference_accumulatedETandMETrings , accumulatedETandMETringPipe , retvalAccumulatedETandMETrings ,
          reference_accumulatedHTandMHTrings , accumulatedHTandMHTringPipe , retvalAccumulatedHTandMHTrings ,
          reference_ClusterPileupEstimation , ClusterPileupEstimationPipe , retvalClusterPileupEstimation ,
          reference_ETandMETPackedLink , ETandMETPackedLinkPipe , retvalETandMETPackedLink ,
          reference_HTandMHTPackedLink , HTandMHTPackedLinkPipe , retvalHTandMHTPackedLink ,
          reference_AuxInfoPackedLink , AuxInfoPackedLinkPipe , retvalAuxInfoPackedLink ,
          reference_demuxAccumulatedETandMETrings , demuxAccumulatedETandMETringPipe , retvalDemuxAccumulatedETandMETrings ,
          reference_demuxAccumulatedETandMETnoHFrings , demuxAccumulatedETandMETnoHFringPipe , retvalDemuxAccumulatedETandMETnoHFrings ,
          reference_demuxAccumulatedHTandMHTrings , demuxAccumulatedHTandMHTringPipe , retvalDemuxAccumulatedHTandMHTrings ,
          reference_demuxAccumulatedHTandMHTnoHFrings , demuxAccumulatedHTandMHTnoHFringPipe , retvalDemuxAccumulatedHTandMHTnoHFrings ,
          reference_PolarETandMETrings , PolarETandMETringPipe , retvalPolarETandMETrings ,
          reference_PolarETandMETnoHFrings , PolarETandMETnoHFringPipe , retvalPolarETandMETnoHFrings ,
          reference_PolarHTandMHTrings , PolarHTandMHTringPipe , retvalPolarHTandMHTrings ,
          reference_PolarHTandMHTnoHFrings , PolarHTandMHTnoHFringPipe , retvalPolarHTandMHTnoHFrings ,
          reference_GtFormattedETandMETrings , GtFormattedETandMETringPipe , retvalGtFormattedETandMETrings ,
          reference_GtFormattedETandMETnoHFrings , GtFormattedETandMETnoHFringPipe , retvalGtFormattedETandMETnoHFrings ,
          reference_GtFormattedHTandMHTrings , GtFormattedHTandMHTringPipe , retvalGtFormattedHTandMHTrings ,
          reference_GtFormattedHTandMHTnoHFrings , GtFormattedHTandMHTnoHFringPipe , retvalGtFormattedHTandMHTnoHFrings ,
          reference_DemuxETandMETPackedLink , DemuxETandMETPackedLinkPipe , retvalDemuxETandMETPackedLink ,
          reference_DemuxETandMETnoHFPackedLink , DemuxETandMETnoHFPackedLinkPipe , retvalDemuxETandMETnoHFPackedLink ,
          reference_DemuxHTandMHTPackedLink , DemuxHTandMHTPackedLinkPipe , retvalDemuxHTandMHTPackedLink ,
          reference_DemuxHTandMHTnoHFPackedLink , DemuxHTandMHTnoHFPackedLinkPipe , retvalDemuxHTandMHTnoHFPackedLink ,
          sum_latency_debug
        );

        ClusterChecker
        (
          clk_count ,
          timeout ,
          reference_3x3Veto , tau3x3VetoPipe , retval3x3Veto ,
          reference_9x3Veto , egamma9x3VetoPipe , retval9x3Veto ,
          reference_TowerThresholds , TowerThresholdsPipe , retvalTowerThresholds ,
          reference_ProtoClusters , ProtoClusterPipe , retvalProtoClusters ,
          reference_FilteredProtoClusters , FilteredProtoClusterPipe , retvalFilteredProtoClusters ,
          reference_ClusterInput , ClusterInputPipe , retvalClusterInput ,
          reference_Isolation9x6 , Isolation9x6Pipe , retvalIsolation9x6 ,
          cluster_latency_debug
        );


        EgammaChecker
        (
          clk_count ,
          timeout ,
          reference_EgammaProtoCluster , EgammaProtoClusterPipe , retvalEgammaProtoCluster ,
          reference_EgammaCluster , EgammaClusterPipe , retvalEgammaCluster ,
          reference_Isolation5x2 , Isolation5x2Pipe , retvalIsolation5x2 ,
          reference_EgammaIsolationRegion , EgammaIsolationRegionPipe , retvalEgammaIsolationRegion ,
          reference_CalibratedEgamma , CalibratedEgammaPipe , retvalCalibratedEgamma ,
          reference_sortedEgamma , SortedEgammaPipe , retvalSortedEgamma ,
          reference_accumulatedSortedEgamma , accumulatedSortedEgammaPipe , retvalAccumulatedSortedEgamma ,
          reference_EgammaPackedLink , EgammaPackedLinkPipe , retvalEgammaPackedLink ,
          reference_demuxAccumulatedSortedEgamma , demuxAccumulatedSortedEgammaPipe , retvalDemuxAccumulatedSortedEgamma ,
          reference_mergedSortedEgamma , mergedSortedEgammaPipe , retvalMergedSortedEgamma ,
          reference_GtFormattedEgamma , GtFormattedEgammaPipe , retvalGtFormattedEgamma ,
          reference_DemuxEgammaPackedLink , DemuxEgammaPackedLinkPipe , retvalDemuxEgammaPackedLink ,
          egamma_latency_debug
        );

        TauChecker
        (
          clk_count ,
          timeout ,
          reference_TauSecondaries , TauSecondariesPipe , retvalTauSecondaries ,
          reference_FilteredTauSecondaries , FilteredTauSecondariesPipe , retvalFilteredTauSecondaries ,
          reference_TauProtoCluster , TauProtoClusterPipe , retvalTauProtoCluster ,
          reference_TauPrimary , TauPrimaryPipe , retvalTauPrimary ,
          reference_FinalTau , FinalTauPipe , retvalFinalTau ,
          reference_TauIsolationRegion , TauIsolationRegionPipe , retvalTauIsolationRegion ,
          reference_CalibratedTau , CalibratedTauPipe , retvalCalibratedTau ,
          reference_sortedTau , SortedTauPipe , retvalSortedTau ,
          reference_accumulatedSortedTau , accumulatedSortedTauPipe , retvalAccumulatedSortedTau ,
          reference_TauPackedLink , TauPackedLinkPipe , retvalTauPackedLink ,
          reference_demuxAccumulatedSortedTau , demuxAccumulatedSortedTauPipe , retvalDemuxAccumulatedSortedTau ,
          reference_mergedSortedTau , mergedSortedTauPipe , retvalMergedSortedTau ,
          reference_GtFormattedTau , GtFormattedTauPipe , retvalGtFormattedTau ,
          reference_DemuxTauPackedLink , DemuxTauPackedLinkPipe , retvalDemuxTauPackedLink ,
          tau_latency_debug
        );

        LinkChecker
        (
          clk_count ,
          timeout ,
          reference_mpLinkOut , links_int_1 , retvalMpLinkOut ,
          reference_demuxLinkOut , links_out , retvalDemuxLinkOut ,
          link_latency_debug
        );

      ELSIF( clk_count = timeout ) THEN
        CREATE_REPORT;

        TowerReport
        (
          retvalTowers
        );

        JetReport
        (
          retval3x3Sum ,
          retval9x3Sum ,
          retval3x9Sum ,
          retval9x9Veto ,
          retvalJetSum ,
          retvalJetPUestimate ,
          retvalPUsubJet ,
          retvalCalibratedJet ,
          retvalSortedJet ,
          retvalAccumulatedsortedJet ,
          retvalJetPackedLink ,
          retvalDemuxAccumulatedsortedJet ,
          retvalMergedsortedJet ,
          retvalGtFormattedJet ,
          retvalDemuxJetPackedLink
        );

        RingsumReport
        (
          retvalTowerCount ,
          retvalETandMETrings ,
          retvalHTandMHTrings ,
          retvalAccumulatedTowerCount ,
          retvalCalibratedETandMETrings ,
          retvalAccumulatedETandMETrings ,
          retvalAccumulatedHTandMHTrings ,
          retvalClusterPileupEstimation ,
          retvalETandMETPackedLink ,
          retvalHTandMHTPackedLink ,
          retvalAuxInfoPackedLink ,
          retvalDemuxAccumulatedETandMETrings ,
          retvalDemuxAccumulatedETandMETnoHFrings ,
          retvalDemuxAccumulatedHTandMHTrings ,
          retvalDemuxAccumulatedHTandMHTnoHFrings ,
          retvalPolarETandMETrings ,
          retvalPolarETandMETnoHFrings ,
          retvalPolarHTandMHTrings ,
          retvalPolarHTandMHTnoHFrings ,
          retvalGtFormattedETandMETrings ,
          retvalGtFormattedETandMETnoHFrings ,
          retvalGtFormattedHTandMHTrings ,
          retvalGtFormattedHTandMHTnoHFrings ,
          retvalDemuxETandMETPackedLink ,
          retvalDemuxETandMETnoHFPackedLink ,
          retvalDemuxHTandMHTPackedLink ,
          retvalDemuxHTandMHTnoHFPackedLink
        );

        ClusterReport
        (
          retval3x3Veto ,
          retval9x3Veto ,
          retvalTowerThresholds ,
          retvalProtoClusters ,
          retvalFilteredProtoClusters ,
          retvalClusterInput ,
          retvalIsolation9x6
        );

        EgammaReport
        (
          retvalEgammaProtoCluster ,
          retvalEgammaCluster ,
          retvalIsolation5x2 ,
          retvalEgammaIsolationRegion ,
-- retvalClusterPileupEstimation ,
-- retvalEgammaIsolationFlag ,
          retvalCalibratedEgamma ,
          retvalSortedEgamma ,
          retvalAccumulatedSortedEgamma ,
          retvalEgammaPackedLink ,
          retvalDemuxAccumulatedSortedEgamma ,
          retvalMergedSortedEgamma ,
          retvalGtFormattedEgamma ,
          retvalDemuxEgammaPackedLink
        );

        TauReport
        (
          retvalTauSecondaries ,
          retvalFilteredTauSecondaries ,
          retvalTauProtoCluster ,
          retvalTauPrimary ,
          retvalFinalTau ,
          retvalTauIsolationRegion ,
          retvalCalibratedTau ,
          retvalSortedTau ,
          retvalAccumulatedSortedTau ,
          retvalTauPackedLink ,
          retvalDemuxAccumulatedSortedTau ,
          retvalMergedSortedTau ,
          retvalGtFormattedTau ,
          retvalDemuxTauPackedLink
        );

        LinkReport
        (
          retvalMpLinkOut ,
          retvalDemuxLinkOut
        );

        CLOSE_REPORT;
      END IF;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      TowerDebug( clk_count ,
                  TowerPipe ,
                  tower_intermediates );

      ClusterDebug( clk_count ,
                    tau3x3VetoPipe ,
                    egamma9x3VetoPipe ,
                    ProtoClusterPipe ,
                    FilteredProtoClusterPipe ,
                    Isolation9x6Pipe ,
                    cluster_intermediates );

      EgammaDebug( clk_count ,
                   Isolation5x2Pipe ,
                   EgammaIsolationRegionPipe ,
                   ClusterPileupEstimationPipe ,
                   EgammaProtoClusterPipe ,
                   EgammaClusterPipe ,
                   CalibratedEgammaPipe ,
                   SortedEgammaPipe ,
                   accumulatedSortedEgammaPipe ,
                   egamma_intermediates );

      TauDebug( clk_count ,
                TauSecondariesPipe ,
                FilteredTauSecondariesPipe ,
                TauProtoClusterPipe ,
                TauPrimaryPipe ,
                FinalTauPipe ,
                TauIsolationRegionPipe ,
                CalibratedTauPipe ,
                SortedTauPipe ,
                accumulatedSortedTauPipe ,
                tau_intermediates );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      clk_count := clk_count + 1;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    END IF;
  END PROCESS;
-- =========================================================================================================================================================================================



-- =========================================================================================================================================================================================
-- THE ALGORITHMS UNDER TEST
-- =========================================================================================================================================================================================
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  MainProcessorInstance : ENTITY work.MainProcessorTop
  PORT MAP(
    clk                                 => clk ,
    LinksIn                             => links_in ,
    LinksOut                            => links_int_1 ,
-- IPbus
    ipbus_clk                           => ipbus_clk ,
-- Testbench Outputs
    towerPipeOut                        => towerPipe , -- Debugging output
-- ---
    sum3x3PipeOut                       => sum3x3Pipe ,
    sum3x9PipeOut                       => sum3x9Pipe ,
    sum9x3PipeOut                       => sum9x3Pipe ,
    jets9x9VetoPipeOut                  => jets9x9VetoPipe ,
    filteredJetPipeOut                  => filteredJetPipe ,
    filteredPileUpPipeOut               => filteredPileUpPipe ,
    pileUpSubtractedJetPipeOut          => pileUpSubtractedJetPipe ,
    CalibratedJetPipeOut                => CalibratedJetPipe ,
    sortedJetPipeOut                    => sortedJetPipe ,
    accumulatedSortedJetPipeOut         => accumulatedSortedJetPipe ,
    jetAccumulationCompletePipeOut      => jetAccumulationCompletePipe ,
    jetPackedLinkPipeOut                => jetPackedLinkPipe ,
-- ---
    egamma9x3VetoPipeOut                => egamma9x3VetoPipe ,
    tau3x3VetoPipeOut                   => tau3x3VetoPipe ,
    towerThresholdsPipeOut              => towerThresholdsPipe ,

    ProtoClusterPipeOut                 => ProtoClusterPipe , -- Debugging output
    FilteredProtoClusterPipeOut         => FilteredProtoClusterPipe , -- Debugging output
    ClusterInputPipeOut                 => ClusterInputPipe , -- Debugging output

    EgammaProtoClusterPipeOut           => EgammaProtoClusterPipe , -- Debugging output
    EgammaClusterPipeOut                => EgammaClusterPipe , -- Debugging output
    EgammaIsolationRegionPipeOut        => EgammaIsolationRegionPipe , -- Debugging output
    Isolation9x6PipeOut                 => Isolation9x6Pipe , -- Debugging output
    Isolation5x2PipeOut                 => Isolation5x2Pipe , -- Debugging output
    ClusterPileupEstimationPipeOut      => ClusterPileupEstimationPipe , -- Debugging output
    ClusterPileupEstimationPipe2Out     => ClusterPileupEstimationPipe2 ,
-- EgammaIsolationFlagPipeOut => EgammaIsolationFlagPipe ,
    CalibratedEgammaPipeOut             => CalibratedEgammaPipe , -- Debugging output
    SortedEgammaPipeOut                 => SortedEgammaPipe , -- Debugging output
    accumulatedSortedEgammaPipeOut      => accumulatedSortedEgammaPipe , -- Debugging output
    EgammaAccumulationCompletePipeOut   => EgammaAccumulationCompletePipe ,
    EgammaPackedLinkPipeOut             => EgammaPackedLinkPipe ,

    TauSecondariesPipeOut               => TauSecondariesPipe , -- Debugging output
    FilteredTauSecondariesPipeOut       => FilteredTauSecondariesPipe , -- Debugging output
    TauPrimaryPipeOut                   => TauPrimaryPipe , -- Debugging output
    TauProtoClusterPipeOut              => TauProtoClusterPipe , -- Debugging output
    TauIsolationRegionPipeOut           => TauIsolationRegionPipe ,
    FinalTauPipeOut                     => FinalTauPipe , -- Debugging output
    CalibratedTauPipeOut                => CalibratedTauPipe , -- Debugging output
    SortedTauPipeOut                    => SortedTauPipe , -- Debugging output
    accumulatedSortedTauPipeOut         => accumulatedSortedTauPipe , -- Debugging output
    TauAccumulationCompletePipeOut      => TauAccumulationCompletePipe ,
    TauPackedLinkPipeOut                => TauPackedLinkPipe ,
-- ---
    TowerCountPipeOut                   => TowerCountPipe ,
    accumulatedTowerCountPipeOut        => accumulatedTowerCountPipe ,
-- ---
    HTandMHTringPipeOut                 => HTandMHTringPipe ,
    accumulatedHTandMHTringPipeOut      => accumulatedHTandMHTringPipe ,
    HTandMHTaccumulationCompletePipeOut => HTandMHTaccumulationCompletePipe ,
    HTandMHTPackedLinkPipeOut           => HTandMHTPackedLinkPipe ,
-- ---
    ETandMETringPipeOut                 => ETandMETringPipe ,
    calibratedETandMETringPipeOut       => calibratedETandMETringPipe ,
    accumulatedETandMETringPipeOut      => accumulatedETandMETringPipe ,
    ETandMETaccumulationCompletePipeOut => ETandMETaccumulationCompletePipe ,
    ETandMETPackedLinkPipeOut           => ETandMETPackedLinkPipe ,
-- ---
    AuxInfoPackedLinkPipeOut            => AuxInfoPackedLinkPipe
  );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

 links_int_2( 0 )  <= links_int_1( 61 );
 links_int_2( 6 )  <= links_int_1( 60 );
 links_int_2( 12 ) <= links_int_1( 63 );
 links_int_2( 18 ) <= links_int_1( 62 );
 links_int_2( 24 ) <= links_int_1( 65 );
 links_int_2( 30 ) <= links_int_1( 64 );

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  DemuxInstance : ENTITY work.DemuxTop
  PORT MAP(
    clk                                => clk ,
    LinksIn                            => links_int_2 ,
    LinksOut                           => links_out ,
-- Testbench Outputs
    linksDemuxedOut                    => links_demuxed ,
    accumulatedSortedJetPipeOut        => demuxAccumulatedSortedJetPipe ,
    accumulatedSortedEgammaPipeOut     => demuxAccumulatedSortedEgammaPipe ,
    accumulatedSortedTauPipeOut        => demuxAccumulatedSortedTauPipe ,
    accumulatedHTandMHTringPipeOut     => demuxAccumulatedHTandMHTringPipe ,
    accumulatedHTandMHTnoHFringPipeOut => demuxAccumulatedHTandMHTnoHFringPipe ,
    accumulatedETandMETringPipeOut     => demuxAccumulatedETandMETringPipe ,
    accumulatedETandMETnoHFringPipeOut => demuxAccumulatedETandMETnoHFringPipe ,
    PileUpEstimationPipeOut            => PileUpEstimationPipe ,
    MinBiasPipeOut                     => MinBiasPipe ,
    mergedSortedJetPipeOut             => mergedSortedJetPipe ,
    mergedSortedEgammaPipeOut          => mergedSortedEgammaPipe ,
    mergedSortedTauPipeOut             => mergedSortedTauPipe ,
    gtFormattedJetPipeOut              => gtFormattedJetPipe ,
    JetPackedLinkPipeOut               => DemuxJetPackedLinkPipe ,
    GtFormattedEgammaPipeOut           => GtFormattedEgammaPipe ,
    EgammaPackedLinkPipeOut            => DemuxEgammaPackedLinkPipe ,
    GtFormattedTauPipeOut              => GtFormattedTauPipe ,
    TauPackedLinkPipeOut               => DemuxTauPackedLinkPipe ,
    polarHTandMHTringPipeOut           => polarHTandMHTringPipe ,
    polarHTandMHTnoHFringPipeOut       => polarHTandMHTnoHFringPipe ,
    polarETandMETringPipeOut           => polarETandMETringPipe ,
    polarETandMETnoHFringPipeOut       => polarETandMETnoHFringPipe ,
    GtFormattedHTandMHTringPipeOut     => GtFormattedHTandMHTringPipe ,
    GtFormattedHTandMHTnoHFringPipeOut => GtFormattedHTandMHTnoHFringPipe ,
    GtFormattedETandMETringPipeOut     => GtFormattedETandMETringPipe ,
    GtFormattedETandMETnoHFringPipeOut => GtFormattedETandMETnoHFringPipe ,
    ETandMETPackedLinkPipeOut          => DemuxETandMETPackedLinkPipe ,
    ETandMETnoHFPackedLinkPipeOut      => DemuxETandMETnoHFPackedLinkPipe ,
    HTandMHTPackedLinkPipeOut          => DemuxHTandMHTPackedLinkPipe ,
    HTandMHTnoHFPackedLinkPipeOut      => DemuxHTandMHTnoHFPackedLinkPipe
  );
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


  MP7CaptureFileWriterInstance1 : ENTITY work.MP7CaptureFileWriter
  GENERIC MAP(
    FileName      => STRING' ( "IntermediateSteps/mp_tx_summary.txt" ) ,
    DebugMessages => FALSE
  )
  PORT MAP( clk , links_int_1 );

  MP7CaptureFileWriterInstance2 : ENTITY work.MP7CaptureFileWriter
  GENERIC MAP(
    FileName      => STRING' ( "IntermediateSteps/demux_rx_summary.txt" ) ,
    DebugMessages => FALSE
  )
  PORT MAP( clk , links_int_2 );

  MP7CaptureFileWriterInstance3 : ENTITY work.MP7CaptureFileWriter
  GENERIC MAP(
    FileName      => STRING' ( "IntermediateSteps/demux_tx_summary.txt" ) ,
    DebugMessages => FALSE
  )
  PORT MAP( clk , links_out );

-- =========================================================================================================================================================================================

END ARCHITECTURE behavioral;
