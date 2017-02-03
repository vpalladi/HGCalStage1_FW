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

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;
--! Using the Calo-L2 "tower" helper functions
USE work.tower_functions.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "jet" helper functions
USE work.jet_functions.ALL;

--! Using the Calo-L2 "ring" helper functions
USE work.ring_functions.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! Using the Calo-L2 "cluster" helper functions
USE work.cluster_functions.ALL;
--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;

--! Using IPbus
USE work.ipbus.ALL;
--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;


--! @brief An entity providing a MainProcessorTop
--! @details Detailed description
ENTITY MainProcessorTop IS
  PORT(
    clk                                 : IN STD_LOGIC ; --! The algorithm clock
    LinksIn                             : IN ldata( cNumberOfLinksIn-1 DOWNTO 0 )     := ( OTHERS => LWORD_NULL );
    LinksOut                            : OUT ldata( cNumberOfLinksIn-1 DOWNTO 0 )    := ( OTHERS => LWORD_NULL );
-- Configuration
    ipbus_clk                           : IN STD_LOGIC                                := '0' ; --! The IPbus clock
    ipbus_rst                           : IN STD_LOGIC                                := '0';
    ipbus_in                            : IN ipb_wbus                                 := IPB_WBUS_NULL;
    ipbus_out                           : OUT ipb_rbus                                := IPB_RBUS_NULL;
-- Testbench Outputs
    towerPipeOut                        : OUT tTowerPipe( 15 DOWNTO 0 )               := ( OTHERS => cEmptyTowerInEtaPhi ) ;             --! A pipe of tTower objects passing out the tower's
    sum3x3PipeOut                       : OUT tJetPipe( 9 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi ) ;               --! A pipe of tJet objects passing out the sum3x3's
    sum3x9PipeOut                       : OUT tJetPipe( 0 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi ) ;               --! A pipe of tJet objects passing out the sum3x9's
    sum9x3PipeOut                       : OUT tJetPipe( 12 DOWNTO 0 )                 := ( OTHERS => cEmptyJetInEtaPhi ) ;               --! A pipe of tJet objects passing out the sum9x3's
    jets9x9VetoPipeOut                  : OUT tComparisonPipe( 13 DOWNTO 0 )          := ( OTHERS => cEmptyComparisonInEtaPhi ) ;        --! A pipe of tComparison objects passing out the jets9x9Veto's
    filteredJetPipeOut                  : OUT tJetPipe( 4 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi ) ;               --! A pipe of tJet objects passing out the filteredJet's
    filteredPileUpPipeOut               : OUT tJetPipe( 1 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi ) ;               --! A pipe of tJet objects passing out the filteredPileUp's
    pileUpSubtractedJetPipeOut          : OUT tJetPipe( 4 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi ) ;               --! A pipe of tJet objects passing out the pileUpSubtractedJet's
    calibratedJetPipeOut                : OUT tJetPipe( 1 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi ) ;               --! A pipe of tJet objects passing out the calibratedJet's
    sortedJetPipeOut                    : OUT tJetPipe( 1 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi ) ;               --! A pipe of tJet objects passing out the sortedJet's
    accumulatedSortedJetPipeOut         : OUT tJetPipe( 3 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi ) ;               --! A pipe of tJet objects passing out the accumulatedSortedJet's
    jetAccumulationCompletePipeOut      : OUT tAccumulationCompletePipe( 3 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta ) ; --! A pipe of tAccumulationComplete objects passing out the jetAccumulationComplete's
    jetPackedLinkPipeOut                : OUT tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates ) ;    --! A pipe of tPackedLink objects passing out the jetPackedLink's

    tau3x3VetoPipeOut                   : OUT tComparisonPipe( 7 DOWNTO 0 )           := ( OTHERS => cEmptyComparisonInEtaPhi ) ;        --! A pipe of tComparison objects passing out the tau3x3Veto's
    egamma9x3VetoPipeOut                : OUT tComparisonPipe( 7 DOWNTO 0 )           := ( OTHERS => cEmptyComparisonInEtaPhi ) ;        --! A pipe of tComparison objects passing out the egamma9x3Veto's

    towerThresholdsPipeOut              : OUT tTowerFlagsPipe( 15 DOWNTO 0 )          := ( OTHERS => cEmptyTowerFlagInEtaPhi ) ;         --! A pipe of tTowerFlags objects passing out the towerThresholds's
    ProtoClusterPipeOut                 : OUT tClusterPipe( 3 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the ProtoCluster's
    FilteredProtoClusterPipeOut         : OUT tClusterPipe( 4 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the FilteredProtoCluster's
    TauSecondariesPipeOut               : OUT tClusterPipe( 0 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the TauSecondaries's
    FilteredTauSecondariesPipeOut       : OUT tClusterPipe( 5 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the FilteredTauSecondaries's
    ClusterInputPipeOut                 : OUT tClusterInputPipe( 0 DOWNTO 0 )         := ( OTHERS => cEmptyClusterInputInEtaPhi ) ;      --! A pipe of tClusterInput objects passing out the ClusterInput's
    EgammaProtoClusterPipeOut           : OUT tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the EgammaProtoCluster's
    TauProtoClusterPipeOut              : OUT tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the TauProtoCluster's
    EgammaClusterPipeOut                : OUT tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the EgammaCluster's
    TauPrimaryPipeOut                   : OUT tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the TauPrimary's
    Isolation9x6PipeOut                 : OUT tIsolationRegionPipe( 7 DOWNTO 0 )      := ( OTHERS => cEmptyIsolationRegionInEtaPhi ) ;   --! A pipe of tIsolationRegion objects passing out the Isolation9x6's
    Isolation5x2PipeOut                 : OUT tIsolationRegionPipe( 7 DOWNTO 0 )      := ( OTHERS => cEmptyIsolationRegionInEtaPhi ) ;   --! A pipe of tIsolationRegion objects passing out the Isolation5x2's
    EgammaIsolationRegionPipeOut        : OUT tIsolationRegionPipe( 7 DOWNTO 0 )      := ( OTHERS => cEmptyIsolationRegionInEtaPhi ) ;   --! A pipe of tIsolationRegion objects passing out the EgammaIsolationRegion's
    ClusterPileupEstimationPipeOut      : OUT tPileupEstimationPipe( 9 DOWNTO 0 )     := ( OTHERS => cEmptyPileupEstimationInEtaPhi ) ;  --! A pipe of tPileupEstimation objects passing out the ClusterPileupEstimation's
    ClusterPileupEstimationPipe2Out     : OUT tPileupEstimationPipe2( 9 DOWNTO 0 )    := ( OTHERS => cEmptyPileupEstimation );

    CalibratedEgammaPipeOut             : OUT tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the CalibratedEgamma's
    SortedEgammaPipeOut                 : OUT tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the SortedEgamma's
    accumulatedSortedEgammaPipeOut      : OUT tClusterPipe( 4 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the accumulatedSortedEgamma's
    EgammaAccumulationCompletePipeOut   : OUT tAccumulationCompletePipe( 4 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta ) ; --! A pipe of tAccumulationComplete objects passing out the EgammaAccumulationComplete's
    EgammaPackedLinkPipeOut             : OUT tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates ) ;    --! A pipe of tPackedLink objects passing out the EgammaPackedLink's

    FinalTauPipeOut                     : OUT tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the FinalTau's
    TauIsolationRegionPipeOut           : OUT tIsolationRegionPipe( 7 DOWNTO 0 )      := ( OTHERS => cEmptyIsolationRegionInEtaPhi ) ;   --! A pipe of tIsolationRegion objects passing out the TauIsolationRegion's
    CalibratedTauPipeOut                : OUT tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the CalibratedTau's
    SortedTauPipeOut                    : OUT tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the SortedTau's
    accumulatedSortedTauPipeOut         : OUT tClusterPipe( 4 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi ) ;           --! A pipe of tCluster objects passing out the accumulatedSortedTau's
    TauAccumulationCompletePipeOut      : OUT tAccumulationCompletePipe( 4 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta ) ; --! A pipe of tAccumulationComplete objects passing out the TauAccumulationComplete's
    TauPackedLinkPipeOut                : OUT tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates ) ;    --! A pipe of tPackedLink objects passing out the TauPackedLink's

    TowerCountPipeOut                   : OUT tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta ) ;          --! A pipe of tRingSegment objects passing out the TowerCount's
    accumulatedTowerCountPipeOut        : OUT tRingSegmentPipe2( 8 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta ) ;          --! A pipe of tRingSegment objects passing out the accumulatedTowerCount's

    MHTcoefficientPipeOut               : OUT tMHTcoefficientPipe( 1 DOWNTO 0 )       := ( OTHERS => cEmptyMHTcoefficientInEtaPhi ) ;    --! A pipe of tMHTcoefficient objects passing out the MHTcoefficient's
    HTandMHTringPipeOut                 : OUT tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta ) ;          --! A pipe of tRingSegment objects passing out the HTandMHTring's
    accumulatedHTandMHTringPipeOut      : OUT tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta ) ;          --! A pipe of tRingSegment objects passing out the accumulatedHTandMHTring's
    confAccumulatedHTandMHTringPipeOut  : OUT tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta ) ;          --! A pipe of tRingSegment objects passing out the accumulatedHTandMHTring's
    HTandMHTaccumulationCompletePipeOut : OUT tAccumulationCompletePipe( 1 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta ) ; --! A pipe of tAccumulationComplete objects passing out the HTandMHTaccumulationComplete's
    HTandMHTPackedLinkPipeOut           : OUT tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates ) ;    --! A pipe of tPackedLink objects passing out the HTandMHTPackedLink's

    ETandMETringPipeOut                 : OUT tRingSegmentPipe2( 10 DOWNTO 0 )        := ( OTHERS => cEmptyRingSegmentInEta ) ;          --! A pipe of tRingSegment objects passing out the ETandMETring's
    calibratedETandMETringPipeOut       : OUT tRingSegmentPipe2( 8 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta ) ;          --! A pipe of tRingSegment objects passing out the calibratedETandMETring's
    accumulatedETandMETringPipeOut      : OUT tRingSegmentPipe2( 8 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta ) ;          --! A pipe of tRingSegment objects passing out the accumulatedETandMETring's
    confAccumulatedETandMETringPipeOut  : OUT tRingSegmentPipe2( 8 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta ) ;          --! A pipe of tRingSegment objects passing out the accumulatedETandMETring's
    ETandMETaccumulationCompletePipeOut : OUT tAccumulationCompletePipe( 8 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta ) ; --! A pipe of tAccumulationComplete objects passing out the ETandMETaccumulationComplete's
    ETandMETPackedLinkPipeOut           : OUT tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates ) ;    --! A pipe of tPackedLink objects passing out the ETandMETPackedLink's

    AuxInfoPackedLinkPipeOut            : OUT tPackedLinkPipe( 0 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates )      --! A pipe of tPackedLink objects passing out the ETandMETPackedLink's
  );
END MainProcessorTop;


--! @brief Architecture definition for entity MainProcessorTop
--! @details Detailed description
ARCHITECTURE behavioral OF MainProcessorTop IS
  SIGNAL towerPipe                          : tTowerPipe( 15 DOWNTO 0 )               := ( OTHERS => cEmptyTowerInEtaPhi );
  SIGNAL sum3x3Pipe                         : tJetPipe( 9 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL sum3x9Pipe                         : tJetPipe( 0 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL sum9x3Pipe                         : tJetPipe( 12 DOWNTO 0 )                 := ( OTHERS => cEmptyJetInEtaPhi );

  SIGNAL jets9x9VetoPipe                    : tComparisonPipe( 13 DOWNTO 0 )          := ( OTHERS => cEmptyComparisonInEtaPhi );
  SIGNAL pileUpPipe                         : tJetPipe( 4 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL filteredJetPipe                    : tJetPipe( 4 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL filteredPileUpPipe                 : tJetPipe( 1 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL pileUpSubtractedJetPipe            : tJetPipe( 4 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL CalibratedJetPipe                  : tJetPipe( 1 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL sortedJetPipe                      : tJetPipe( 1 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL accumulatedSortedJetPipe           : tJetPipe( 3 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL jetAccumulationCompletePipe        : tAccumulationCompletePipe( 3 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta );
  SIGNAL jetPackedLinkPipe                  : tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );

  SIGNAL maxima3x3Pipe                      : tMaximaPipe( 7 DOWNTO 0 )               := ( OTHERS => cEmptyMaximaInEtaPhi );
  SIGNAL maxima9x3Pipe                      : tMaximaPipe( 7 DOWNTO 0 )               := ( OTHERS => cEmptyMaximaInEtaPhi );

  SIGNAL tau3x3VetoPipe                     : tComparisonPipe( 7 DOWNTO 0 )           := ( OTHERS => cEmptyComparisonInEtaPhi );
  SIGNAL egamma9x3VetoPipe                  : tComparisonPipe( 7 DOWNTO 0 )           := ( OTHERS => cEmptyComparisonInEtaPhi );

  SIGNAL towerThresholdsPipe                : tTowerFlagsPipe( 15 DOWNTO 0 )          := ( OTHERS => cEmptyTowerFlagInEtaPhi ) ; -- cluster tower
  SIGNAL ProtoClusterPipe                   : tClusterPipe( 3 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL FilteredProtoClusterPipe           : tClusterPipe( 4 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );

  SIGNAL TauSecondariesPipe                 : tClusterPipe( 0 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL FilteredTauSecondariesPipe         : tClusterPipe( 5 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL ClusterInputPipe                   : tClusterInputPipe( 0 DOWNTO 0 )         := ( OTHERS => cEmptyClusterInputInEtaPhi );
  SIGNAL EgammaProtoClusterPipe             : tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL TauProtoClusterPipe                : tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL EgammaClusterPipe                  : tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL TauPrimaryPipe                     : tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL Isolation9x6Pipe                   : tIsolationRegionPipe( 7 DOWNTO 0 )      := ( OTHERS => cEmptyIsolationRegionInEtaPhi );
  SIGNAL Isolation5x2Pipe                   : tIsolationRegionPipe( 7 DOWNTO 0 )      := ( OTHERS => cEmptyIsolationRegionInEtaPhi );
  SIGNAL EgammaIsolationRegionPipe          : tIsolationRegionPipe( 7 DOWNTO 0 )      := ( OTHERS => cEmptyIsolationRegionInEtaPhi );
  SIGNAL ClusterPileupEstimationPipe        : tPileupEstimationPipe( 9 DOWNTO 0 )     := ( OTHERS => cEmptyPileupEstimationInEtaPhi );
  SIGNAL ClusterPileupEstimationPipe2       : tPileupEstimationPipe2( 9 DOWNTO 0 )    := ( OTHERS => cEmptyPileupEstimation );

  SIGNAL CalibratedEgammaPipe               : tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL SortedEgammaPipe                   : tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL accumulatedSortedEgammaPipe        : tClusterPipe( 4 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL EgammaAccumulationCompletePipe     : tAccumulationCompletePipe( 4 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta );
  SIGNAL EgammaPackedLinkPipe               : tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL FinalTauPipe                       : tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL TauIsolationRegionPipe             : tIsolationRegionPipe( 7 DOWNTO 0 )      := ( OTHERS => cEmptyIsolationRegionInEtaPhi );
  SIGNAL CalibratedTauPipe                  : tClusterPipe( 7 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL SortedTauPipe                      : tClusterPipe( 1 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL accumulatedSortedTauPipe           : tClusterPipe( 4 DOWNTO 0 )              := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL TauAccumulationCompletePipe        : tAccumulationCompletePipe( 4 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta );
  SIGNAL TauPackedLinkPipe                  : tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );

  SIGNAL TowerCountPipe                     : tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL accumulatedTowerCountPipe          : tRingSegmentPipe2( 8 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL dummyTowerCountPipe                : tRingSegmentPipe2( 0 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL TowerCountaccumulationCompletePipe : tAccumulationCompletePipe( 0 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta );

  SIGNAL MHTcoefficientPipe                 : tMHTcoefficientPipe( 1 DOWNTO 0 )       := ( OTHERS => cEmptyMHTcoefficientInEtaPhi );
  SIGNAL HTandMHTringPipe                   : tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL accumulatedHTandMHTringPipe        : tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL confAccumulatedHTandMHTringPipe    : tRingSegmentPipe2( 1 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL HTandMHTaccumulationCompletePipe   : tAccumulationCompletePipe( 1 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta );
  SIGNAL HTandMHTPackedLinkPipe             : tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );

  SIGNAL ETandMETringPipe                   : tRingSegmentPipe2( 10 DOWNTO 0 )        := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL calibratedETandMETringPipe         : tRingSegmentPipe2( 8 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL accumulatedETandMETringPipe        : tRingSegmentPipe2( 8 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL confAccumulatedETandMETringPipe    : tRingSegmentPipe2( 8 DOWNTO 0 )         := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL ETandMETaccumulationCompletePipe   : tAccumulationCompletePipe( 8 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta );
  SIGNAL ETandMETPackedLinkPipe             : tPackedLinkPipe( 1 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );

  SIGNAL AuxInfoPackedLinkPipe              : tPackedLinkPipe( 0 DOWNTO 0 )           := ( OTHERS => cEmptyPackedLinkInCandidates );

-- ------------------------

  SUBTYPE JetCalibrationAddresses     IS NATURAL RANGE 0 TO 35;
  SUBTYPE EgammaCalibrationAddresses  IS NATURAL RANGE 36 TO 108;
  SUBTYPE TauCalibrationAddresses     IS NATURAL RANGE 109 TO 216;
  SUBTYPE RingSumCalibrationAddresses IS NATURAL RANGE 217 TO 224;
  SUBTYPE LinkMaskAddress             IS NATURAL RANGE 225 TO 225;
  SUBTYPE TowerThresholdAddresses     IS NATURAL RANGE 226 TO 229;
  SUBTYPE JetEtaLimitAddress          IS NATURAL RANGE 230 TO 230;
  SUBTYPE EgammaEtaLimitAddress       IS NATURAL RANGE 231 TO 231;
  SUBTYPE TauEtaLimitAddress          IS NATURAL RANGE 232 TO 232;
  SUBTYPE HTThresholdAddresses        IS NATURAL RANGE 233 TO 234;
  SUBTYPE HTMHTEtaMaxAddress          IS NATURAL RANGE 235 TO 235;
  SUBTYPE ETMETEtaMaxAddress          IS NATURAL RANGE 236 TO 236;

  SUBTYPE BusAddresses                IS NATURAL RANGE JetCalibrationAddresses'LOW TO ETMETEtaMaxAddress'HIGH;

  SIGNAL BusIn , BusOut           : tFMBus( BusAddresses );
  SIGNAL BusClk                   : STD_LOGIC := '0';


  SIGNAL DummyBusIn , DummyBusOut : tDummyFMBus;

BEGIN

-- ---------------------------------------------------------------------------------
  IPbusToFunkyMiniBusInstance : ENTITY work.IPbusToFunkyMiniBus
  PORT MAP(
    ipbus_clk => ipbus_clk ,
    ipbus_rst => ipbus_rst ,
    ipbus_in  => ipbus_in ,
    ipbus_out => ipbus_out ,
    BusIn     => BusIn ,
    BusOut    => BusOut ,
    BusClk    => BusClk
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Connect internal signals to the Testbench outputs
    towerPipeOut                        <= towerPipe;
    sum3x3PipeOut                       <= sum3x3Pipe;
    sum3x9PipeOut                       <= sum3x9Pipe;
    sum9x3PipeOut                       <= sum9x3Pipe;
    tau3x3VetoPipeOut                   <= tau3x3VetoPipe;
    egamma9x3VetoPipeOut                <= egamma9x3VetoPipe;
    jets9x9VetoPipeOut                  <= jets9x9VetoPipe;
    filteredJetPipeOut                  <= filteredJetPipe;
    filteredPileUpPipeOut               <= filteredPileUpPipe;
    pileUpSubtractedJetPipeOut          <= pileUpSubtractedJetPipe;
    CalibratedJetPipeOut                <= CalibratedJetPipe;
    sortedJetPipeOut                    <= sortedJetPipe;
    accumulatedSortedJetPipeOut         <= accumulatedSortedJetPipe;
    jetAccumulationCompletePipeOut      <= jetAccumulationCompletePipe;
    jetPackedLinkPipeOut                <= jetPackedLinkPipe;

    towerThresholdsPipeOut              <= towerThresholdsPipe;
    ProtoClusterPipeOut                 <= ProtoClusterPipe;
    FilteredProtoClusterPipeOut         <= FilteredProtoClusterPipe;
    TauSecondariesPipeOut               <= TauSecondariesPipe;
    FilteredTauSecondariesPipeOut       <= FilteredTauSecondariesPipe;
    ClusterInputPipeOut                 <= ClusterInputPipe;
    EgammaProtoClusterPipeOut           <= EgammaProtoClusterPipe;
    TauProtoClusterPipeOut              <= TauProtoClusterPipe;
    EgammaClusterPipeOut                <= EgammaClusterPipe;
    TauPrimaryPipeOut                   <= TauPrimaryPipe;

    Isolation9x6PipeOut                 <= Isolation9x6Pipe;
    Isolation5x2PipeOut                 <= Isolation5x2Pipe;
    EgammaIsolationRegionPipeOut        <= EgammaIsolationRegionPipe;
    ClusterPileupEstimationPipeOut      <= ClusterPileupEstimationPipe;
    ClusterPileupEstimationPipe2Out     <= ClusterPileupEstimationPipe2;

    CalibratedEgammaPipeOut             <= CalibratedEgammaPipe;
    SortedEgammaPipeOut                 <= SortedEgammaPipe;
    accumulatedSortedEgammaPipeOut      <= accumulatedSortedEgammaPipe;
    EgammaAccumulationCompletePipeOut   <= EgammaAccumulationCompletePipe;
    EgammaPackedLinkPipeOut             <= EgammaPackedLinkPipe;

    FinalTauPipeOut                     <= FinalTauPipe;
    TauIsolationRegionPipeOut           <= TauIsolationRegionPipe;
    CalibratedTauPipeOut                <= CalibratedTauPipe;
    SortedTauPipeOut                    <= SortedTauPipe;
    accumulatedSortedTauPipeOut         <= accumulatedSortedTauPipe;
    TauAccumulationCompletePipeOut      <= TauAccumulationCompletePipe;
    TauPackedLinkPipeOut                <= TauPackedLinkPipe;

    TowerCountPipeOut                   <= TowerCountPipe;
    accumulatedTowerCountPipeOut        <= accumulatedTowerCountPipe;

    MHTcoefficientPipeOut               <= MHTcoefficientPipe;
    HTandMHTringPipeOut                 <= HTandMHTringPipe;
    accumulatedHTandMHTringPipeOut      <= accumulatedHTandMHTringPipe;
    confAccumulatedHTandMHTringPipeOut  <= confAccumulatedHTandMHTringPipe;
    HTandMHTaccumulationCompletePipeOut <= HTandMHTaccumulationCompletePipe;
    HTandMHTPackedLinkPipeOut           <= HTandMHTPackedLinkPipe;

    ETandMETringPipeOut                 <= ETandMETringPipe;
    calibratedETandMETringPipeOut       <= calibratedETandMETringPipe;
    accumulatedETandMETringPipeOut      <= accumulatedETandMETringPipe;
    confAccumulatedETandMETringPipeOut  <= confAccumulatedETandMETringPipe;
    ETandMETaccumulationCompletePipeOut <= ETandMETaccumulationCompletePipe;
    ETandMETPackedLinkPipeOut           <= ETandMETPackedLinkPipe;

    AuxInfoPackedLinkPipeOut            <= AuxInfoPackedLinkPipe;
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Convert the raw links in to Calo-Tower objects
  LinksInInstance : ENTITY work.LinksIn
  PORT MAP(
    clk          => clk ,
    linksIn      => LinksIn ,
    towerPipeOut => towerPipe ,
    BusIn        => BusIn( LinkMaskAddress ) ,
    BusOut       => BusOut( LinkMaskAddress ) ,
    BusClk       => BusClk
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
-- Data format Interface / Seed Finding --
  TowerThresholdsInstance : ENTITY work.TowerThresholds
  GENERIC MAP(
    ThresholdFormingOffset => 0
  )
  PORT MAP(
    CLK                    => CLK ,
    towerPipeIn            => towerPipe ,
    TowerThresholdsPipeOut => TowerThresholdsPipe ,
    BusIn                  => BusIn( TowerThresholdAddresses ) ,
    BusOut                 => BusOut( TowerThresholdAddresses ) ,
    BusClk                 => BusClk
  );
-- ---------------------------------------------------------------------------------



-- ---------------------------------------------------------------------------------
-- Form sum 3 in phi by 3 in eta
  Sum3x3FormerInstance : ENTITY work.Sum3x3Former
  GENERIC MAP(
    Offset => 5
  )
  PORT MAP(
    clk           => clk ,
    towerPipeIn   => towerPipe ,
    sum3x3PipeOut => sum3x3Pipe
  );

  StripFormerInstance : ENTITY work.StripFormer
  GENERIC MAP(
    sum3x9Offset => 3 ,
    sum9x3Offset => 0
  )
  PORT MAP(
    clk           => clk ,
    sum3x3PipeIn  => sum3x3Pipe ,
    sum9x3PipeOut => sum9x3Pipe ,
    sum3x9PipeOut => sum3x9Pipe
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
-- Find maximum tower in a region 3 in phi by 3 in eta
  MaximaFinder3x3Instance : ENTITY work.MaximaFinder3x3
  GENERIC MAP(
    Offset => 0
  )
  PORT MAP(
    clk                  => clk ,
    towerPipeIn          => towerPipe ,
    maxima3x3PipeOut     => maxima3x3Pipe ,
    MaximaFlag3x3PipeOut => tau3x3VetoPipe
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Find maximum tower in a region 9 in phi by 3 in eta
  MaximaFinder9x3Instance : ENTITY work.MaximaFinder9x3
  GENERIC MAP(
    Offset => 1
  )
  PORT MAP(
    clk                  => clk ,
    Maxima3x3PipeIn      => maxima3x3Pipe ,
    maxima9x3PipeOut     => maxima9x3Pipe ,
    MaximaFlag9x3PipeOut => egamma9x3VetoPipe
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Find maximum tower in a region 9 in phi by 9 in eta
  MaximaFinder9x9Instance : ENTITY work.MaximaFinder9x9
  GENERIC MAP(
    Offset => 0
  )
  PORT MAP(
    clk                  => clk ,
    Maxima9x3PipeIn      => maxima9x3Pipe ,
    MaximaFlag9x9PipeOut => jets9x9VetoPipe
  );
-- ---------------------------------------------------------------------------------



-- ---------------------------------------------------------------------------------
  PileUpEstimatorInstance : ENTITY work.PileUpEstimator
  GENERIC MAP(
    vetoOffset => 1
  )
  PORT MAP(
    clk            => clk ,
    jetVetoPipeIn  => jets9x9VetoPipe ,
    strip9x3PipeIn => sum9x3Pipe ,
    strip3x9PipeIn => sum3x9Pipe ,
    pileUpPipeOut  => filteredPileUpPipe
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
  JetFormerInstance : ENTITY work.JetFormer
  GENERIC MAP(
    vetoOffset      => 1 ,
    thresholdOffset => 14
  )
  PORT MAP(
    clk                   => clk ,
    jetVetoPipeIn         => jets9x9VetoPipe ,
    strip3x9PipeIn        => sum3x9Pipe ,
    TowerThresholdsPipeIn => TowerThresholdsPipe ,
    filteredJetPipeOut    => filteredJetPipe ,
    BusIn                 => BusIn( JetEtaLimitAddress ) ,
    BusOut                => BusOut( JetEtaLimitAddress ) ,
    BusClk                => BusClk
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Subtract the pile-up from the jet
  PileUpSubtractionInstance : ENTITY work.PileUpSubtraction
  GENERIC MAP(
    filteredJetPipeOffset => 2
  )
  PORT MAP(
    clk                        => clk ,
    filteredJetPipeIn          => filteredJetPipe ,
    filteredPileUpPipeIn       => filteredPileUpPipe ,
    pileUpSubtractedJetPipeOut => pileUpSubtractedJetPipe
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
  JetCalibrationInstance : ENTITY work.JetCalibration
  GENERIC MAP(
    PileupEstimationOffset => 7
  )
  PORT MAP(
    Clk                    => clk ,
    JetPipeIn              => pileUpSubtractedJetPipe ,
    PileupEstimationPipeIn => ClusterPileupEstimationPipe ,
    CalibratedJetPipeOut   => CalibratedJetPipe ,
    BusIn                  => BusIn( JetCalibrationAddresses ) ,
    BusOut                 => BusOut( JetCalibrationAddresses ) ,
    BusClk                 => BusClk
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Sort the jets in the phi-direction
  BitonicSortJetsInstance : ENTITY work.BitonicSortJetPipes
  GENERIC MAP(
    Size => 6
  )
  PORT MAP(
    clk               => clk ,
    filteredJetPipeIn => CalibratedJetPipe ,
    sortedJetPipeOut  => sortedJetPipe
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Sort the jets in the eta-direction
  AccumulatingBitonicSortJetsInstance : ENTITY work.AccumulatingBitonicSortJetPipes
  GENERIC MAP(
    Size => 6
  )
  PORT MAP(
    clk                         => clk ,
    sortedJetPipeIn             => sortedJetPipe ,
    accumulatedSortedJetPipeOut => accumulatedSortedJetPipe ,
    accumulationCompletePipeOut => jetAccumulationCompletePipe
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
  JetLinkPackerInstance : ENTITY work.JetLinkPacker
  PORT MAP(
    clk                           => clk ,
    accumulatedSortedJetPipeIn    => accumulatedSortedJetPipe ,
    jetAccumulationCompletePipeIn => jetAccumulationCompletePipe ,
    PackedJetPipeOut              => jetPackedLinkPipe
  );
-- ---------------------------------------------------------------------------------



-- ---------------------------------------------------------------------------------
  ProtoClusterInstance : ENTITY work.ProtoClusterFormer
  GENERIC MAP(
    TowerPipeOffset => 3 ,
    thresholdOffset => 2
  )
  PORT MAP(
    Clk                   => CLK ,
    TowerPipeIn           => towerPipe ,
    TowerThresholdsPipeIn => TowerThresholdsPipe ,
    ClusterPipeOut        => ProtoClusterPipe
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
  ProtoClusterFilterInstance : ENTITY work.ProtoClusterFilter
  GENERIC MAP(
    ProtoClusterOffset => 3 ,
    ObjectType         => "Egamma"
  )
  PORT MAP(
    clk                         => CLK ,
    ProtoClusterPipeIn          => ProtoClusterPipe ,
    Veto9x3PipeIn               => egamma9x3VetoPipe ,
    FilteredProtoClusterPipeOut => FilteredProtoClusterPipe ,
    BusIn                       => BusIn( EgammaEtaLimitAddress ) ,
    BusOut                      => BusOut( EgammaEtaLimitAddress ) ,
    BusClk                      => BusClk
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
  EgammaClusterTrimmingInstance : ENTITY work.EgammaClusterTrimming
  PORT MAP(
    Clk                       => clk ,
    ProtoClusterPipeIn        => FilteredProtoClusterPipe ,
    EgammaProtoClusterPipeOut => EgammaProtoClusterPipe
  );
-- ---------------------------------------------------------------------------------



-- ---------------------------------------------------------------------------------
  TauSecondariesInstance : ENTITY work.TauSecondaries
  GENERIC MAP(
    TauVetoOffset      => 0 ,
    ProtoClusterOffset => 0
  )
  PORT MAP(
    Clk                   => CLK ,
    ProtoClusterPipeIn    => ProtoClusterPipe ,
    tauVetoPipeIn         => tau3x3VetoPipe ,
    tauSecondariesPipeOut => TauSecondariesPipe
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
  TauSecondaryFilterInstance : ENTITY work.ProtoClusterFilter
  GENERIC MAP(
    ProtoClusterOffset => 0 ,
    ObjectType         => "Tau"
  )
  PORT MAP(
    clk                         => CLK ,
    ProtoClusterPipeIn          => TauSecondariesPipe ,
    Veto9x3PipeIn               => egamma9x3VetoPipe ,
    FilteredProtoClusterPipeOut => FilteredTauSecondariesPipe ,
    BusIn                       => BusIn( TauEtaLimitAddress ) ,
    BusOut                      => BusOut( TauEtaLimitAddress ) ,
    BusClk                      => BusClk
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
  TauClusterTrimmingInstance : ENTITY work.TauClusterTrimming
  PORT MAP(
    Clk                    => clk ,
    ProtoClusterPipeIn     => FilteredProtoClusterPipe ,
    tauSecondariesPipeIn   => FilteredTauSecondariesPipe ,
    TauProtoClusterPipeOut => TauProtoClusterPipe
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
  ClusterInputFormerInstance : ENTITY work.ClusterInputFormer
  GENERIC MAP(
    TowerPipeOffset  => 11 ,
    EgammaVetoOffset => 2
  )
  PORT MAP(
    Clk                 => clk ,
    TowerPipeIn         => towerPipe ,
    egamma9x3VetoPipeIn => egamma9x3VetoPipe ,
    ClusterInputPipeOut => ClusterInputPipe
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
  EgammaClusterSumFormerInstance : ENTITY work.ClusterSumFormer
  GENERIC MAP(
    ProtoClusterPipeOffset => 1
  )
  PORT MAP(
    Clk                => clk ,
    ClusterInputPipeIn => ClusterInputPipe ,
    ProtoClusterPipeIn => EgammaProtoClusterPipe ,
    ClusterPipeOut     => EgammaClusterPipe
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
  TauClusterSumFormerInstance : ENTITY work.ClusterSumFormer
  GENERIC MAP(
    ProtoClusterPipeOffset => 1
  )
  PORT MAP(
    Clk                => clk ,
    ClusterInputPipeIn => ClusterInputPipe ,
    ProtoClusterPipeIn => TauProtoClusterPipe ,
    ClusterPipeOut     => TauPrimaryPipe
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
  IsolationRegion9x6FormerInstance : ENTITY work.IsolationRegion9x6Former
  GENERIC MAP(
    strip9x3PipeOffset     => 3 ,
    veto9x3PipeOffset      => 4 ,
    protoclusterPipeOffset => 4
  )
  PORT MAP(
    Clk                 => clk ,
    strip9x3PipeIn      => sum9x3Pipe ,
    egammaVetoPipeIn    => egamma9x3VetoPipe ,
    ProtoClusterPipeIn  => FilteredProtoClusterPipe ,
    Isolation9x6PipeOut => Isolation9x6Pipe
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
  IsolationRegion5x2FormerInstance : ENTITY work.IsolationRegion5x2Former
  GENERIC MAP(
    ProtoClusterPipeOffset => 2
  )
  PORT MAP(
    Clk                 => clk ,
    ClusterInputPipeIn  => ClusterInputPipe ,
    ProtoClusterPipeIn  => FilteredProtoClusterPipe ,
    Isolation5x2PipeOut => Isolation5x2Pipe
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
  EgammaIsolationRegionFormerInstance : ENTITY work.EgammaIsolationRegionFormer
  PORT MAP(
    Clk                => clk ,
    Isolation9x6PipeIn => Isolation9x6Pipe ,
    Isolation5x2PipeIn => Isolation5x2Pipe ,
    IsolationPipeOut   => EgammaIsolationRegionPipe
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
  EgammaCalibrationInstance : ENTITY work.EgammaCalibration
  GENERIC MAP(
    PileupEstimationOffset => 3
  )
  PORT MAP(
    Clk                     => clk ,
    EgammaPipeIn            => EgammaClusterPipe ,
    IsolationRegionPipeIn   => EgammaIsolationRegionPipe ,
    PileupEstimationPipeIn  => ClusterPileupEstimationPipe ,
    CalibratedEgammaPipeOut => CalibratedEgammaPipe ,
    BusIn                   => BusIn( EgammaCalibrationAddresses ) ,
    BusOut                  => BusOut( EgammaCalibrationAddresses ) ,
    BusClk                  => BusClk
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Sort the Clusters in the phi-direction
  BitonicSortEgammasInstance : ENTITY work.BitonicSortClusterPipes
  GENERIC MAP(
    Size => 6
  )
  PORT MAP(
    clk                   => clk ,
    FilteredClusterPipeIn => CalibratedEgammaPipe ,
    SortedClusterPipeOut  => SortedEgammaPipe
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Sort the Clusters in the eta-direction
  AccumulatingBitonicSortEgammasInstance : ENTITY work.AccumulatingBitonicSortClusterPipes
  GENERIC MAP(
    Size => 6
  )
  PORT MAP(
    clk                             => clk ,
    SortedClusterPipeIn             => SortedEgammaPipe ,
    accumulatedSortedClusterPipeOut => accumulatedSortedEgammaPipe ,
    accumulationCompletePipeOut     => EgammaAccumulationCompletePipe
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
  EgammaLinkPackerInstance : ENTITY work.ClusterLinkPacker
  PORT MAP(
    clk                               => clk ,
    accumulatedSortedClusterPipeIn    => accumulatedSortedEgammaPipe ,
    ClusterAccumulationCompletePipeIn => EgammaAccumulationCompletePipe ,
    PackedClusterPipeOut              => EgammaPackedLinkPipe
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
  TauFinalSumInstance : ENTITY work.TauFinalSum
  GENERIC MAP(
   TauSecondaryPipeOffset => 5
  )
  PORT MAP(
    Clk                => clk ,
    TauPrimaryPipeIn   => TauPrimaryPipe ,
    TauSecondaryPipeIn => FilteredTauSecondariesPipe ,
    FinalTauPipeOut    => FinalTauPipe
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
  TauIsolationRegionFormerInstance : ENTITY work.TauIsolationRegionFormer
  PORT MAP(
    Clk                => clk ,
    Isolation9x6PipeIn => Isolation9x6Pipe ,
    FinalTauPipeIn     => FinalTauPipe ,
    IsolationPipeOut   => TauIsolationRegionPipe
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
  TauCalibrationInstance : ENTITY work.TauCalibration
  GENERIC MAP(
    PileupEstimationOffset => 4
  )
  PORT MAP(
    Clk                    => clk ,
    TauPipeIn              => FinalTauPipe ,
    IsolationRegionPipeIn  => TauIsolationRegionPipe ,
    PileupEstimationPipeIn => ClusterPileupEstimationPipe ,
    CalibratedTauPipeOut   => CalibratedTauPipe ,
    BusIn                  => BusIn( TauCalibrationAddresses ) ,
    BusOut                 => BusOut( TauCalibrationAddresses ) ,
    BusClk                 => BusClk
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
-- Sort the Clusters in the phi-direction
  BitonicSortTausInstance : ENTITY work.BitonicSortClusterPipes
  GENERIC MAP(
    Size => 6
  )
  PORT MAP(
    clk                   => clk ,
    FilteredClusterPipeIn => CalibratedTauPipe ,
    SortedClusterPipeOut  => SortedTauPipe
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Sort the Clusters in the eta-direction
  AccumulatingBitonicSortTausInstance : ENTITY work.AccumulatingBitonicSortClusterPipes
  GENERIC MAP(
    Size => 6
  )
  PORT MAP(
    clk                             => clk ,
    SortedClusterPipeIn             => SortedTauPipe ,
    accumulatedSortedClusterPipeOut => accumulatedSortedTauPipe ,
    accumulationCompletePipeOut     => TauAccumulationCompletePipe
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
  TauLinkPackerInstance : ENTITY work.ClusterLinkPacker
  PORT MAP(
    clk                               => clk ,
    accumulatedSortedClusterPipeIn    => accumulatedSortedTauPipe ,
    ClusterAccumulationCompletePipeIn => TauAccumulationCompletePipe ,
    PackedClusterPipeOut              => TauPackedLinkPipe
  );
-- ---------------------------------------------------------------------------------





-- ---------------------------------------------------------------------------------
-- IMPLEMENTATION NOTE!
-- Had to increase all offsets by 1 to add an extra register between the comparisons
-- and the jet overlap filter to make the build meet timing

-- Calculate the trigonometric coefficients from the positions of the non-vetoed jets
  MHTcoefficientsInstance : ENTITY work.MHTcoefficients
  GENERIC MAP(
    jetVetoPipeOffset => 11
  )
  PORT MAP(
    clk                   => clk ,
    jetVetoPipeIn         => jets9x9VetoPipe ,
    MHTcoefficientPipeOut => MHTcoefficientPipe
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Calculate the scalar and vector HT sums for the entire ring in phi
  HTandMHTsumsInstance : ENTITY work.HTandMHTsums
  GENERIC MAP(
    pileUpSubtractedJetOffset => 1
  )
  PORT MAP(
    clk                       => clk ,
    pileUpSubtractedJetPipeIn => CalibratedJetPipe ,
    MHTcoefficientPipeIn      => MHTcoefficientPipe ,
    ringPipeOut               => HTandMHTringPipe ,
    BusIn                     => BusIn( HTThresholdAddresses ) ,
    BusOut                    => BusOut( HTThresholdAddresses ) ,
    BusClk                    => BusClk
  );

-- Accumulate the scalar and vector HT sums for each half in eta
  HTandMHTaccumulatorsInstance : ENTITY work.RingAccumulators
  GENERIC MAP(
    ObjectType => "HTMHT"
  )
  PORT MAP(
    clk                         => clk ,
    ringPipeIn                  => HTandMHTringPipe ,
    AccumulatedRingPipeOut      => accumulatedHTandMHTringPipe ,
    confAccumulatedRingPipeOut  => confAccumulatedHTandMHTringPipe ,
    accumulationCompletePipeOut => HTandMHTaccumulationCompletePipe ,
    BusIn                       => BusIn( HTMHTEtaMaxAddress ) ,
    BusOut                      => BusOut( HTMHTEtaMaxAddress ) ,
    BusClk                      => BusClk
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
  HTandMHTLinkPackerInstance : ENTITY work.RingSumLinkPacker
  PORT MAP(
    clk                        => clk ,
    AccumulatedRingPipeIn      => accumulatedHTandMHTringPipe ,
    confAccumulatedRingPipeIn  => confAccumulatedHTandMHTringPipe ,
    accumulationCompletePipeIn => HTandMHTaccumulationCompletePipe ,
    PackedRingSumPipeOut       => HTandMHTPackedLinkPipe
  );
-- ---------------------------------------------------------------------------------



-- ---------------------------------------------------------------------------------
  TowerCountInstance : ENTITY work.TowerCount
  PORT MAP(
    clk                   => clk ,
    towerThresholdsPipeIn => TowerThresholdsPipe ,
    towerCountPipeOut     => TowerCountPipe
  );

  TowerCountaccumulatorsInstance : ENTITY work.RingAccumulators
  PORT MAP(
    clk                         => clk ,
    ringPipeIn                  => TowerCountPipe ,
    AccumulatedRingPipeOut      => accumulatedTowerCountPipe ,
    confAccumulatedRingPipeOut  => dummyTowerCountPipe ,
    accumulationCompletePipeOut => TowerCountaccumulationCompletePipe ,
    BusIn                       => DummyBusIn ,
    BusOut                      => DummyBusOut ,
    BusClk                      => BusClk
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
  ClusterPileupEstimationInstance : ENTITY work.ClusterPileupEstimation
  PORT MAP(
    Clk                      => CLK ,
    AccumulatedRingPipeIn    => accumulatedTowerCountPipe ,
    PileupEstimationPipeOut  => ClusterPileupEstimationPipe ,
    PileupEstimationPipe2Out => ClusterPileupEstimationPipe2
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Calculate the scalar and vector ET sums for the entire ring in phi
  ETandMETsumsInstance : ENTITY work.ETandMETsums
  PORT MAP(
    clk         => clk ,
    towerPipeIn => towerPipe ,
    ringPipeOut => ETandMETringPipe
  );


-- Calibrate the ET / MET
  ETandMETcalibrationInstance : ENTITY work.RingCalibration
  GENERIC MAP(
    ringPipeOffset => 5
  )
  PORT MAP(
    clk                    => clk ,
    ringPipeIn             => ETandMETringPipe ,
    PileupEstimationPipeIn => ClusterPileupEstimationPipe2 ,
    ringPipeOut            => CalibratedETandMETringPipe ,
    BusIn                  => BusIn( RingSumCalibrationAddresses ) ,
    BusOut                 => BusOut( RingSumCalibrationAddresses ) ,
    BusClk                 => BusClk
  );


-- Accumulate the scalar and vector ET sums for each half in eta
  ETandMETaccumulatorsInstance : ENTITY work.RingAccumulators
  GENERIC MAP(
    ObjectType => "ETMET"
  )
  PORT MAP(
    clk                         => clk ,
    ringPipeIn                  => CalibratedETandMETringPipe ,
    AccumulatedRingPipeOut      => accumulatedETandMETringPipe ,
    confAccumulatedRingPipeOut  => confAccumulatedETandMETringPipe ,
    accumulationCompletePipeOut => ETandMETaccumulationCompletePipe ,
    BusIn                       => BusIn( ETMETEtaMaxAddress ) ,
    BusOut                      => BusOut( ETMETEtaMaxAddress ) ,
    BusClk                      => BusClk
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
  ETandMETLinkPackerInstance : ENTITY work.RingSumLinkPacker
  PORT MAP(
    clk                        => clk ,
    accumulatedringPipeIn      => accumulatedETandMETringPipe ,
    confAccumulatedRingPipeIn  => confAccumulatedETandMETringPipe ,
    accumulationCompletePipeIn => ETandMETaccumulationCompletePipe ,
    PackedRingSumPipeOut       => ETandMETPackedLinkPipe
  );
-- ---------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------
  AuxLinkPackerInstance : ENTITY work.AuxLinkPacker
  GENERIC MAP(
    PileUpEstimationOffset => 3
  )
  PORT MAP(
    clk                        => CLK ,
    PileUpEstimationPipeIn     => ClusterPileupEstimationPipe2 ,
    accumulatedringPipeIn      => accumulatedETandMETringPipe ,
    accumulationCompletePipeIn => ETandMETaccumulationCompletePipe ,
    PackedAuxInfoPipeOut       => AuxInfoPackedLinkPipe
  );
-- ---------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Convert the calo-objects to raw links out
  LinksOutInstance : ENTITY work.LinksOut
  GENERIC MAP(
    EtMetOffset         => 23 ,
    HtMhtOffset         => 9 ,
    JetOffset           => 0 ,
    EgammaOffset        => 12 ,
    TauOffset           => 13 ,
    AuxOffset( 0 TO 5 ) => ( 35 , 33 , 0 , 0 , 0 , 0 ) -- Links 2-5 are unused , link 1 is the + / - HF Tower Counts from ET / MET( but 9 frames later )
  )
  PORT MAP(
    clk                  => clk ,
    PackedETandMETPipeIn => ETandMETPackedLinkPipe ,
    PackedHTandMHTPipeIn => HTandMHTPackedLinkPipe ,
    PackedJetPipeIn      => JetPackedLinkPipe ,
    PackedEgammaPipeIn   => EgammaPackedLinkPipe ,
    PackedTauPipeIn      => TauPackedLinkPipe ,
    PackedAuxPipeIn      => AuxInfoPackedLinkPipe ,
    linksOut             => LinksOut
  );
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------

END ARCHITECTURE behavioral;
