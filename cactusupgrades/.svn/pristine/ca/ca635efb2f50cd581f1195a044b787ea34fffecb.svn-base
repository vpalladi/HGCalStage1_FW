--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;
--! Using the Calo-L2 "demux" data-types
USE work.demux_types.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using IPbus
USE work.ipbus.ALL;
--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;


--! @brief An entity providing a DemuxTop
--! @details Detailed description
ENTITY DemuxTop IS
  PORT(
    clk                                : IN STD_LOGIC ; --! The algorithm clock
    LinksIn                            : IN ldata( cNumberOfLinksIn-1 DOWNTO 0 )   := ( OTHERS => LWORD_NULL );
    LinksOut                           : OUT ldata( cNumberOfLinksIn-1 DOWNTO 0 )  := ( OTHERS => LWORD_NULL );
-- Configuration
    ipbus_clk                          : IN STD_LOGIC                              := '0' ; --! The IPbus clock
    ipbus_rst                          : IN STD_LOGIC                              := '0';
    ipbus_in                           : IN ipb_wbus                               := IPB_WBUS_NULL;
    ipbus_out                          : OUT ipb_rbus                              := IPB_RBUS_NULL;
-- Testbench Outputs
    LinksDemuxedOut                    : OUT ldata( ( 6 * 11 ) -1 DOWNTO 0 )       := ( OTHERS => LWORD_NULL );
    accumulatedSortedJetPipeOut        : OUT tJetPipe( 1 DOWNTO 0 )                := ( OTHERS => cEmptyJetInEtaPhi ) ;            --! A pipe of tJet objects passing out the accumulatedSortedJet's
    accumulatedSortedEgammaPipeOut     : OUT tClusterPipe( 1 DOWNTO 0 )            := ( OTHERS => cEmptyClusterInEtaPhi ) ;        --! A pipe of tCluster objects passing out the accumulatedSortedEgamma's
    accumulatedSortedTauPipeOut        : OUT tClusterPipe( 1 DOWNTO 0 )            := ( OTHERS => cEmptyClusterInEtaPhi ) ;        --! A pipe of tCluster objects passing out the accumulatedSortedTau's
    accumulatedHTandMHTringPipeOut     : OUT tRingSegmentPipe2( 1 DOWNTO 0 )       := ( OTHERS => cEmptyRingSegmentInEta ) ;       --! A pipe of tRingSegment objects passing out the accumulatedHTandMHTring's
    accumulatedHTandMHTnoHFringPipeOut : OUT tRingSegmentPipe2( 1 DOWNTO 0 )       := ( OTHERS => cEmptyRingSegmentInEta ) ;       --! A pipe of tRingSegment objects passing out the accumulatedHTandMHTring's
    accumulatedETandMETringPipeOut     : OUT tRingSegmentPipe2( 1 DOWNTO 0 )       := ( OTHERS => cEmptyRingSegmentInEta ) ;       --! A pipe of tRingSegment objects passing out the accumulatedETandMETring's
    accumulatedETandMETnoHFringPipeOut : OUT tRingSegmentPipe2( 1 DOWNTO 0 )       := ( OTHERS => cEmptyRingSegmentInEta ) ;       --! A pipe of tRingSegment objects passing out the accumulatedETandMETring's

    accumulatedRingPipeOut             : OUT tRingSegmentPipe2( 1 DOWNTO 0 )       := ( OTHERS => cEmptyRingSegmentInEta ) ;       --! A pipe of tRingSegment objects passing out the accumulatedETandMETring's

    PileUpEstimationPipeOut            : OUT tPileUpEstimationPipe2( 7 DOWNTO 0 )  := ( OTHERS => cEmptyPileUpEstimation ) ;       --! A pipe of tPileUpEstimation objects bringing in the PileUpEstimation's
    MinBiasPipeOut                     : OUT tRingSegmentPipe2( 7 DOWNTO 0 )       := ( OTHERS => cEmptyRingSegmentInEta ) ;       --! A pipe of tRingSegment objects bringing in the accumulatedRing's
    mergedSortedJetPipeOut             : OUT tJetPipe( 1 DOWNTO 0 )                := ( OTHERS => cEmptyJetInEtaPhi ) ;            --! A pipe of tJet objects passing out the mergedSortedJet's
    mergedSortedEgammaPipeOut          : OUT tClusterPipe( 1 DOWNTO 0 )            := ( OTHERS => cEmptyClusterInEtaPhi ) ;        --! A pipe of tCluster objects passing out the mergedSortedEgamma's
    mergedSortedTauPipeOut             : OUT tClusterPipe( 1 DOWNTO 0 )            := ( OTHERS => cEmptyClusterInEtaPhi ) ;        --! A pipe of tCluster objects passing out the mergedSortedTau's
    gtFormattedJetPipeOut              : OUT tGtFormattedJetPipe( 0 DOWNTO 0 )     := ( OTHERS => cEmptyGtFormattedJets ) ;        --! A pipe of tGtFormattedJet objects passing out the gtFormattedJet's
    JetPackedLinkPipeOut               : OUT tPackedLinkPipe( 11 DOWNTO 0 )        := ( OTHERS => cEmptyPackedLinkInCandidates ) ; --! A pipe of tPackedLink objects passing out the JetPackedLink's
    gtFormattedEgammaPipeOut           : OUT tGtFormattedClusterPipe( 0 DOWNTO 0 ) := ( OTHERS => cEmptyGtFormattedClusters ) ;    --! A pipe of tGtFormattedCluster objects passing out the gtFormattedEgamma's
    EgammaPackedLinkPipeOut            : OUT tPackedLinkPipe( 11 DOWNTO 0 )        := ( OTHERS => cEmptyPackedLinkInCandidates ) ; --! A pipe of tPackedLink objects passing out the EgammaPackedLink's
    gtFormattedTauPipeOut              : OUT tGtFormattedClusterPipe( 0 DOWNTO 0 ) := ( OTHERS => cEmptyGtFormattedClusters ) ;    --! A pipe of tGtFormattedCluster objects passing out the gtFormattedTau's
    TauPackedLinkPipeOut               : OUT tPackedLinkPipe( 11 DOWNTO 0 )        := ( OTHERS => cEmptyPackedLinkInCandidates ) ; --! A pipe of tPackedLink objects passing out the TauPackedLink's
    polarHTandMHTringPipeOut           : OUT tPolarRingSegmentPipe( 5 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment ) ;       --! A pipe of tPolarRingSegment objects passing out the polarHTandMHTring's
    polarHTandMHTNoHFringPipeOut       : OUT tPolarRingSegmentPipe( 5 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment ) ;       --! A pipe of tPolarRingSegment objects passing out the polarHTandMHTring's
    polarETandMETringPipeOut           : OUT tPolarRingSegmentPipe( 5 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment ) ;       --! A pipe of tPolarRingSegment objects passing out the polarETandMETring's
    polarETandMETNoHFringPipeOut       : OUT tPolarRingSegmentPipe( 5 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment ) ;       --! A pipe of tPolarRingSegment objects passing out the polarETandMETring's

    polarRingPipeOut                   : OUT tPolarRingSegmentPipe( 5 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment ) ;       --! A pipe of tPolarRingSegment objects passing out the polarETandMETring's

    gtFormattedHTandMHTringPipeOut     : OUT tPolarRingSegmentPipe( 0 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment ) ;       --! A pipe of tPolarRingSegment objects passing out the gtFormattedHTandMHTring's
    gtFormattedHTandMHTNoHFringPipeOut : OUT tPolarRingSegmentPipe( 0 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment ) ;       --! A pipe of tPolarRingSegment objects passing out the gtFormattedHTandMHTring's
    gtFormattedETandMETringPipeOut     : OUT tPolarRingSegmentPipe( 0 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment ) ;       --! A pipe of tPolarRingSegment objects passing out the gtFormattedETandMETring's
    gtFormattedETandMETNoHFringPipeOut : OUT tPolarRingSegmentPipe( 0 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment ) ;       --! A pipe of tPolarRingSegment objects passing out the gtFormattedETandMETring's

    gtFormattedRingPipeOut             : OUT tPolarRingSegmentPipe( 0 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment ) ;       --! A pipe of tPolarRingSegment objects passing out the gtFormattedETandMETring's

    HTandMHTPackedLinkPipeOut          : OUT tPackedLinkPipe( 7 DOWNTO 0 )         := ( OTHERS => cEmptyPackedLinkInCandidates ) ; --! A pipe of tPackedLink objects passing out the HTandMHTPackedLink's
    HTandMHTNoHFPackedLinkPipeOut      : OUT tPackedLinkPipe( 7 DOWNTO 0 )         := ( OTHERS => cEmptyPackedLinkInCandidates ) ; --! A pipe of tPackedLink objects passing out the HTandMHTPackedLink's
    ETandMETPackedLinkPipeOut          : OUT tPackedLinkPipe( 7 DOWNTO 0 )         := ( OTHERS => cEmptyPackedLinkInCandidates ) ; --! A pipe of tPackedLink objects passing out the ETandMETPackedLink's
    ETandMETNoHFPackedLinkPipeOut      : OUT tPackedLinkPipe( 7 DOWNTO 0 )         := ( OTHERS => cEmptyPackedLinkInCandidates ) ; --! A pipe of tPackedLink objects passing out the ETandMETPackedLink's

    RingPackedLinkPipeOut              : OUT tPackedLinkPipe( 7 DOWNTO 0 )         := ( OTHERS => cEmptyPackedLinkInCandidates )   --! A pipe of tPackedLink objects passing out the ETandMETPackedLink's
  );
END DemuxTop;


--! @brief Architecture definition for entity DemuxTop
--! @details Detailed description
ARCHITECTURE behavioral OF DemuxTop IS
  SIGNAL LinksDemuxed                    : ldata( ( 6 * 11 ) -1 DOWNTO 0 )       := ( OTHERS => LWORD_NULL );
  SIGNAL accumulatedSortedJetPipe        : tJetPipe( 1 DOWNTO 0 )                := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL accumulatedSortedEgammaPipe     : tClusterPipe( 1 DOWNTO 0 )            := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL accumulatedSortedTauPipe        : tClusterPipe( 1 DOWNTO 0 )            := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL accumulatedHTandMHTringPipe     : tRingSegmentPipe2( 1 DOWNTO 0 )       := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL accumulatedHTandMHTnoHFringPipe : tRingSegmentPipe2( 1 DOWNTO 0 )       := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL accumulatedETandMETringPipe     : tRingSegmentPipe2( 1 DOWNTO 0 )       := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL accumulatedETandMETnoHFringPipe : tRingSegmentPipe2( 1 DOWNTO 0 )       := ( OTHERS => cEmptyRingSegmentInEta );

  SIGNAL accumulatedRingPipe             : tRingSegmentPipe2( 1 DOWNTO 0 )       := ( OTHERS => cEmptyRingSegmentInEta );

  SIGNAL PileUpEstimationPipe            : tPileUpEstimationPipe2( 7 DOWNTO 0 )  := ( OTHERS => cEmptyPileUpEstimation );
  SIGNAL MinBiasPipe                     : tRingSegmentPipe2( 7 DOWNTO 0 )       := ( OTHERS => cEmptyRingSegmentInEta );
  SIGNAL mergedSortedJetPipe             : tJetPipe( 1 DOWNTO 0 )                := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL mergedSortedEgammaPipe          : tClusterPipe( 1 DOWNTO 0 )            := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL mergedSortedTauPipe             : tClusterPipe( 1 DOWNTO 0 )            := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL gtFormattedJetPipe              : tGtFormattedJetPipe( 0 DOWNTO 0 )     := ( OTHERS => cEmptyGtFormattedJets );
  SIGNAL JetPackedLinkPipe               : tPackedLinkPipe( 11 DOWNTO 0 )        := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL gtFormattedEgammaPipe           : tGtFormattedClusterPipe( 0 DOWNTO 0 ) := ( OTHERS => cEmptyGtFormattedClusters );
  SIGNAL EgammaPackedLinkPipe            : tPackedLinkPipe( 11 DOWNTO 0 )        := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL gtFormattedTauPipe              : tGtFormattedClusterPipe( 0 DOWNTO 0 ) := ( OTHERS => cEmptyGtFormattedClusters );
  SIGNAL TauPackedLinkPipe               : tPackedLinkPipe( 11 DOWNTO 0 )        := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL polarHTandMHTringPipe           : tPolarRingSegmentPipe( 5 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL polarHTandMHTNoHFringPipe       : tPolarRingSegmentPipe( 5 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL polarETandMETringPipe           : tPolarRingSegmentPipe( 5 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL polarETandMETNoHFringPipe       : tPolarRingSegmentPipe( 5 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment );

  SIGNAL polarRingPipe                   : tPolarRingSegmentPipe( 5 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment );

  SIGNAL gtFormattedHTandMHTringPipe     : tPolarRingSegmentPipe( 0 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL gtFormattedHTandMHTNoHFringPipe : tPolarRingSegmentPipe( 0 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL gtFormattedETandMETringPipe     : tPolarRingSegmentPipe( 0 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment );
  SIGNAL gtFormattedETandMETNoHFringPipe : tPolarRingSegmentPipe( 0 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment );

  SIGNAL gtFormattedRingPipe             : tPolarRingSegmentPipe( 0 DOWNTO 0 )   := ( OTHERS => cEmptyPolarRingSegment );

  SIGNAL HTandMHTPackedLinkPipe          : tPackedLinkPipe( 7 DOWNTO 0 )         := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL HTandMHTnoHFPackedLinkPipe      : tPackedLinkPipe( 7 DOWNTO 0 )         := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL ETandMETPackedLinkPipe          : tPackedLinkPipe( 7 DOWNTO 0 )         := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL ETandMETNoHFPackedLinkPipe      : tPackedLinkPipe( 7 DOWNTO 0 )         := ( OTHERS => cEmptyPackedLinkInCandidates );

  SIGNAL RingPackedLinkPipe              : tPackedLinkPipe( 7 DOWNTO 0 )         := ( OTHERS => cEmptyPackedLinkInCandidates );

  SUBTYPE BusAddresses IS NATURAL RANGE 0 TO 0;

  SIGNAL BusIn , BusOut : tFMBus( BusAddresses );
  SIGNAL BusClk         : STD_LOGIC := '0';

BEGIN


  LinksDemuxedOut                    <= LinksDemuxed;
  accumulatedSortedJetPipeOut        <= accumulatedSortedJetPipe;
  accumulatedSortedEgammaPipeOut     <= accumulatedSortedEgammaPipe;
  accumulatedSortedTauPipeOut        <= accumulatedSortedTauPipe;
  accumulatedHTandMHTringPipeOut     <= accumulatedRingPipe;
  accumulatedHTandMHTNoHFringPipeOut <= accumulatedRingPipe;
  accumulatedETandMETringPipeOut     <= accumulatedRingPipe;
  accumulatedETandMETnoHFringPipeOut <= accumulatedRingPipe;

  accumulatedRingPipeOut             <= accumulatedRingPipe;

  PileUpEstimationPipeOut            <= PileUpEstimationPipe;
  MinBiasPipeOut                     <= MinBiasPipe;
  mergedSortedJetPipeOut             <= mergedSortedJetPipe;
  mergedSortedEgammaPipeOut          <= mergedSortedEgammaPipe;
  mergedSortedTauPipeOut             <= mergedSortedTauPipe;
  gtFormattedJetPipeOut              <= gtFormattedJetPipe;
  gtFormattedEgammaPipeOut           <= gtFormattedEgammaPipe;
  gtFormattedTauPipeOut              <= gtFormattedTauPipe;
  polarHTandMHTringPipeOut           <= polarRingPipe;
  polarHTandMHTnoHFringPipeOut       <= polarRingPipe;
  polarETandMETringPipeOut           <= polarRingPipe;
  polarETandMETNoHFringPipeOut       <= polarRingPipe;

  polarRingPipeOut                   <= polarRingPipe;

  gtFormattedHTandMHTringPipeOut     <= gtFormattedRingPipe;
  gtFormattedHTandMHTNoHFringPipeOut <= gtFormattedRingPipe;
  gtFormattedETandMETringPipeOut     <= gtFormattedRingPipe;
  gtFormattedETandMETNoHFringPipeOut <= gtFormattedRingPipe;

  gtFormattedRingPipeOut             <= gtFormattedRingPipe;

  HTandMHTPackedLinkPipeOut          <= RingPackedLinkPipe;
  HTandMHTnoHFPackedLinkPipeOut      <= RingPackedLinkPipe;
  ETandMETPackedLinkPipeOut          <= RingPackedLinkPipe;
  ETandMETNoHFPackedLinkPipeOut      <= RingPackedLinkPipe;

  RingPackedLinkPipeOut              <= RingPackedLinkPipe;

  EgammaPackedLinkPipeOut            <= EgammaPackedLinkPipe;
  JetPackedLinkPipeOut               <= JetPackedLinkPipe;
  TauPackedLinkPipeOut               <= TauPackedLinkPipe;



---- ---------------------------------------------------------------------------------
-- IPbusToFunkyMiniBusInstance : ENTITY work.IPbusToFunkyMiniBus
-- PORT MAP(
-- ipbus_clk => ipbus_clk ,
-- ipbus_rst => ipbus_rst ,
-- ipbus_in => ipbus_in ,
-- ipbus_out => ipbus_out ,
-- BusIn => BusIn ,
-- BusOut => BusOut ,
-- BusClk => BusClk
-- );
---- ---------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  DemuxInstance : ENTITY work.demux
  GENERIC MAP(
    NumberOfMPs     => 12 ,
    LinksPerMPs     => 6 ,
    TapParameterSet => ( ( Offset => 0 ) , ( Offset => 1 ) , ( Offset => 2 ) , ( Offset => 3 ) , ( Offset => 4 ) , ( Offset => 5 ) , ( Offset => 6 ) , ( Offset => 7 ) , ( Offset => 8 ) , ( Offset => 9 ) , ( Offset => 10 ) )
  )
  PORT MAP(
    clk      => clk ,
    LinksIn  => LinksIn ,
    LinksOut => LinksDemuxed
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  LinksInInstance : ENTITY work.DemuxLinksIn
  GENERIC MAP(
    NumberOfFrames => 11
  )
  PORT MAP(
    clk                            => clk ,
    linksIn                        => LinksDemuxed ,
--accumulatedHTandMHTringPipeOut => accumulatedHTandMHTringPipe ,
--accumulatedHTandMHTnoHFringPipeOut => accumulatedHTandMHTnoHFringPipe ,
--accumulatedETandMETringPipeOut => accumulatedETandMETringPipe ,
--accumulatedETandMETnoHFringPipeOut => accumulatedETandMETnoHFringPipe ,

    accumulatedRingPipeOut         => accumulatedRingPipe ,

    accumulatedSortedJetPipeOut    => accumulatedSortedJetPipe ,
    accumulatedSortedEgammaPipeOut => accumulatedSortedEgammaPipe ,
    accumulatedSortedTauPipeOut    => accumulatedSortedTauPipe ,
    PileUpEstimationPipeOut        => PileUpEstimationPipe ,
    MinBiasPipeOut                 => MinBiasPipe
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  FinalBitonicSortJetPipesInstance : ENTITY work.FinalBitonicSortJetPipes
  GENERIC MAP(
    Size => 6
  )
  PORT MAP(
    clk        => clk ,
    JetPipeIn  => accumulatedSortedJetPipe ,
    JetPipeOut => mergedSortedJetPipe
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  FinalBitonicSortEgammaInstance : ENTITY work.FinalBitonicSortClusterPipes
  GENERIC MAP(
    Size => 6
  )
  PORT MAP(
    clk            => clk ,
    ClusterPipeIn  => accumulatedSortedEgammaPipe ,
    ClusterPipeOut => mergedSortedEgammaPipe
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  FinalBitonicSortTauInstance : ENTITY work.FinalBitonicSortClusterPipes
  GENERIC MAP(
    Size => 6
  )
  PORT MAP(
    clk            => clk ,
    ClusterPipeIn  => accumulatedSortedTauPipe ,
    ClusterPipeOut => mergedSortedTauPipe
  );
-- ------------------------------------------------------------------------------------

---- ------------------------------------------------------------------------------------
-- HTandMHTcoordinateConversionInstance : ENTITY work.FinalSumAndCoordinateConversion
-- GENERIC MAP(
-- BitShift => 6
-- )
-- PORT MAP(
-- clk => clk ,
-- ringPipeIn => accumulatedHTandMHTringPipe ,
-- polarRingPipeOut => polarHTandMHTringPipe
-- );
---- ------------------------------------------------------------------------------------

---- ------------------------------------------------------------------------------------
-- HTandMHTNoHFcoordinateConversionInstance : ENTITY work.FinalSumAndCoordinateConversion
-- GENERIC MAP(
-- BitShift => 6
-- )
-- PORT MAP(
-- clk => clk ,
-- ringPipeIn => accumulatedHTandMHTNoHFringPipe ,
-- polarRingPipeOut => polarHTandMHTNoHFringPipe
-- );
---- ------------------------------------------------------------------------------------

---- ------------------------------------------------------------------------------------
-- ETandMETcoordinateConversionInstance : ENTITY work.FinalSumAndCoordinateConversion
-- GENERIC MAP(
-- BitShift => 10
-- )
-- PORT MAP(
-- clk => clk ,
-- ringPipeIn => accumulatedETandMETringPipe ,
-- polarRingPipeOut => polarETandMETringPipe
-- );
---- ------------------------------------------------------------------------------------

---- ------------------------------------------------------------------------------------
-- ETandMETNoHFcoordinateConversionInstance : ENTITY work.FinalSumAndCoordinateConversion
-- GENERIC MAP(
-- BitShift => 10
-- )
-- PORT MAP(
-- clk => clk ,
-- ringPipeIn => accumulatedETandMETNoHFringPipe ,
-- polarRingPipeOut => polarETandMETNoHFringPipe
-- );
---- ------------------------------------------------------------------------------------


---- ------------------------------------------------------------------------------------
-- GtHTandMHTFormatterInstance : ENTITY work.GtRingSumFormatter
-- PORT MAP(
-- clk => clk ,
-- ringSegmentPipeIn => polarHTandMHTringPipe ,
-- ringSegmentPipeOut => gtFormattedHTandMHTringPipe
-- );
---- ------------------------------------------------------------------------------------

---- ------------------------------------------------------------------------------------
-- HTandMHTLinkPackerInstance : ENTITY work.DemuxRingSumLinkPacker
-- GENERIC MAP(
-- AuxInfoOffset => 5 ,
-- MinBiasEtaHalf => 1
-- )
-- PORT MAP(
-- clk => clk ,
-- polarRingPipeIn => gtFormattedHTandMHTringPipe ,
----
-- PileUpEstimationPipeIn => PileUpEstimationPipe ,
-- MinBiasPipeIn => MinBiasPipe ,
----
-- PackedRingSumPipeOut => HTandMHTpackedLinkPipe
-- );
---- ------------------------------------------------------------------------------------

---- ------------------------------------------------------------------------------------
-- GtHTandMHTnoHFFormatterInstance : ENTITY work.GtRingSumFormatter
-- PORT MAP(
-- clk => clk ,
-- ringSegmentPipeIn => polarHTandMHTnoHFringPipe ,
-- ringSegmentPipeOut => gtFormattedHTandMHTnoHFringPipe
-- );
---- ------------------------------------------------------------------------------------

---- ------------------------------------------------------------------------------------
-- HTandMHTnoHFLinkPackerInstance : ENTITY work.DemuxRingSumLinkPacker
-- GENERIC MAP(
-- AuxInfoOffset => 6 ,
-- MinBiasEtaHalf => 1
-- )
-- PORT MAP(
-- clk => clk ,
-- polarRingPipeIn => gtFormattedHTandMHTnoHFringPipe ,
----
-- PileUpEstimationPipeIn => PileUpEstimationPipe ,
-- MinBiasPipeIn => MinBiasPipe ,
----
-- PackedRingSumPipeOut => HTandMHTnoHFpackedLinkPipe
-- );
---- ------------------------------------------------------------------------------------


---- ------------------------------------------------------------------------------------
-- GtETandMETFormatterInstance : ENTITY work.GtRingSumFormatter
-- PORT MAP(
-- clk => clk ,
-- ringSegmentPipeIn => polarETandMETringPipe ,
-- ringSegmentPipeOut => gtFormattedETandMETringPipe
-- );
---- ------------------------------------------------------------------------------------

---- ------------------------------------------------------------------------------------
-- ETandMETLinkPackerInstance : ENTITY work.DemuxRingSumLinkPacker
-- GENERIC MAP(
-- AuxInfoOffset => 3 ,
-- MinBiasEtaHalf => 0
-- )
-- PORT MAP(
-- clk => clk ,
-- polarRingPipeIn => gtFormattedETandMETringPipe ,
----
-- PileUpEstimationPipeIn => PileUpEstimationPipe ,
-- MinBiasPipeIn => MinBiasPipe ,
----
-- PackedRingSumPipeOut => ETandMETpackedLinkPipe
-- );
---- ------------------------------------------------------------------------------------


---- ------------------------------------------------------------------------------------
-- GtETandMETNoHFFormatterInstance : ENTITY work.GtRingSumFormatter
-- PORT MAP(
-- clk => clk ,
-- ringSegmentPipeIn => polarETandMETNoHFringPipe ,
-- ringSegmentPipeOut => gtFormattedETandMETNoHFringPipe
-- );
---- ------------------------------------------------------------------------------------

---- ------------------------------------------------------------------------------------
-- ETandMETNoHFLinkPackerInstance : ENTITY work.DemuxRingSumLinkPacker
-- GENERIC MAP(
-- AuxInfoOffset => 4 ,
-- MinBiasEtaHalf => 0
-- )
-- PORT MAP(
-- clk => clk ,
-- polarRingPipeIn => gtFormattedETandMETNoHFringPipe ,
----
-- PileUpEstimationPipeIn => PileUpEstimationPipe ,
-- MinBiasPipeIn => MinBiasPipe ,
----
-- PackedRingSumPipeOut => ETandMETNoHFpackedLinkPipe
-- );
---- ------------------------------------------------------------------------------------






-- ------------------------------------------------------------------------------------
  RingCoordinateConversionInstance : ENTITY work.FinalSumAndCoordinateConversion
  PORT MAP(
    clk              => clk ,
    ringPipeIn       => accumulatedRingPipe ,
    polarRingPipeOut => polarRingPipe
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  RingFormatterInstance : ENTITY work.GtRingSumFormatter
  PORT MAP(
    clk                => clk ,
    ringSegmentPipeIn  => polarRingPipe ,
    ringSegmentPipeOut => gtFormattedRingPipe
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  RingLinkPackerInstance : ENTITY work.DemuxRingSumLinkPacker
  GENERIC MAP(
    AuxInfoOffset => 3
  )
  PORT MAP(
    clk                    => clk ,
    polarRingPipeIn        => gtFormattedRingPipe ,
--
    PileUpEstimationPipeIn => PileUpEstimationPipe ,
    MinBiasPipeIn          => MinBiasPipe ,
--
    PackedRingSumPipeOut   => RingPackedLinkPipe
  );
-- ------------------------------------------------------------------------------------






-- ------------------------------------------------------------------------------------
  GtJetFormatterInstance : ENTITY work.GtJetFormatter
  PORT MAP(
    clk        => clk ,
    jetPipeIn  => mergedSortedJetPipe ,
    jetPipeOut => gtFormattedJetPipe
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  JetLinkPackerInstance : ENTITY work.DemuxJetLinkPacker
  PORT MAP(
    clk                  => clk ,
    gtFormattedJetPipeIn => gtFormattedJetPipe ,
    PackedJetPipeOut     => JetPackedLinkPipe
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  GtEgammaFormatterInstance : ENTITY work.GtClusterFormatter
  PORT MAP(
    clk            => clk ,
    ClusterPipeIn  => mergedSortedEgammaPipe ,
    ClusterPipeOut => gtFormattedEgammaPipe
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  EgammaLinkPackerInstance : ENTITY work.DemuxClusterLinkPacker
  PORT MAP(
    clk                      => clk ,
    gtFormattedClusterPipeIn => gtFormattedEgammaPipe ,
    PackedClusterPipeOut     => EgammaPackedLinkPipe
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  GtTauFormatterInstance : ENTITY work.GtClusterFormatter
  PORT MAP(
    clk            => clk ,
    ClusterPipeIn  => mergedSortedTauPipe ,
    ClusterPipeOut => gtFormattedTauPipe
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  TauLinkPackerInstance : ENTITY work.DemuxClusterLinkPacker
  PORT MAP(
    clk                      => clk ,
    gtFormattedClusterPipeIn => gtFormattedTauPipe ,
    PackedClusterPipeOut     => TauPackedLinkPipe
  );
-- ------------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------------
  LinksOutInstance : ENTITY work.DemuxLinksOut
  GENERIC MAP(
--EtMetOffset => 2 ,
--EtMetNoHFOffset => 1 ,
--HtMhtOffset => 1 ,
--HtMhtNoHFOffset => 0 ,
    JetOffset    => 1 ,
    EgammaOffset => 5 ,
    TauOffset    => 3
  )
  PORT MAP(
    clk                 => clk ,
--PackedHTandMHTPipeIn => HTandMHTpackedLinkPipe ,
--PackedHTandMHTNoHFPipeIn => HTandMHTNoHFpackedLinkPipe ,
--PackedETandMETPipeIn => ETandMETpackedLinkPipe ,
--PackedETandMETNoHFPipeIn => ETandMETNoHFpackedLinkPipe ,
    PackedRingSumPipeIn => RingPackedLinkPipe ,
    PackedJetPipeIn     => JetPackedLinkPipe ,
    PackedEgammaPipeIn  => EgammaPackedLinkPipe ,
    PackedTauPipeIn     => TauPackedLinkPipe ,
    linksOut            => LinksOut ,
---
    BusIn               => BusIn ,
    BusOut              => BusOut ,
    BusClk              => BusClk
  );
-- ------------------------------------------------------------------------------------

END ARCHITECTURE behavioral;
