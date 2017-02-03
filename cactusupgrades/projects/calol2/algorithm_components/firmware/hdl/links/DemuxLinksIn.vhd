--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 common types
USE work.common_types.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;


--! @brief An entity providing a DemuxLinksIn
--! @details Detailed description
ENTITY DemuxLinksIn IS
  GENERIC(
    NumberOfFrames : INTEGER
  );
  PORT(
    clk                            : IN STD_LOGIC ; --! The algorithm clock
    LinksIn                        : IN ldata( ( 6 * NumberOfFrames ) -1 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );
--accumulatedHTandMHTringPipeOut : OUT tRingSegmentPipe2 ; --! A pipe of tRingSegment objects passing out the accumulatedHTandMHTring's
--accumulatedHTandMHTnoHFringPipeOut : OUT tRingSegmentPipe2 ; --! A pipe of tRingSegment objects passing out the accumulatedHTandMHTring's
--accumulatedETandMETringPipeOut : OUT tRingSegmentPipe2 ; --! A pipe of tRingSegment objects passing out the accumulatedETandMETring's
--accumulatedETandMETnoHFringPipeOut : OUT tRingSegmentPipe2 ; --! A pipe of tRingSegment objects passing out the accumulatedETandMETring's
    accumulatedRingPipeOut         : OUT tRingSegmentPipe2 ;      --! A pipe of tRingSegment objects passing out the accumulatedETandMETring's
    accumulatedSortedJetPipeOut    : OUT tJetPipe ;               --! A pipe of tJet objects passing out the accumulatedSortedJet's
    accumulatedSortedEgammaPipeOut : OUT tClusterPipe ;           --! A pipe of tCluster objects passing out the accumulatedSortedEgamma's
    accumulatedSortedTauPipeOut    : OUT tClusterPipe ;           --! A pipe of tCluster objects passing out the accumulatedSortedTau's
    PileUpEstimationPipeOut        : OUT tPileUpEstimationPipe2 ; --! A pipe of tPileUpEstimation objects bringing in the PileUpEstimation's
    MinBiasPipeOut                 : OUT tRingSegmentPipe2        --! A pipe of tRingSegment objects bringing in the accumulatedRing's
  );
END DemuxLinksIn;

--! @brief Architecture definition for entity DemuxLinksIn
--! @details Detailed description
ARCHITECTURE behavioral OF DemuxLinksIn IS

  SIGNAL ET , ETnoHF , HT , HTnoHF       : tWordArrayInEta   := cEmptyWordArrayInEta;
  SIGNAL eg , eg2                        : tWordArrayInEta   := cEmptyWordArrayInEta;
  SIGNAL tau , tau2                      : tWordArrayInEta   := cEmptyWordArrayInEta;
  SIGNAL jet , jet2                      : tWordArrayInEta   := cEmptyWordArrayInEta;
  SIGNAL aux                             : tWordArray        := cEmptyWordArray;

  CONSTANT FIBRE_0                       : INTEGER           := NumberOfFrames * 0;
  CONSTANT FIBRE_1                       : INTEGER           := NumberOfFrames * 1;
  CONSTANT FIBRE_2                       : INTEGER           := NumberOfFrames * 2;
  CONSTANT FIBRE_3                       : INTEGER           := NumberOfFrames * 3;
  CONSTANT FIBRE_4                       : INTEGER           := NumberOfFrames * 4;
  CONSTANT FIBRE_5                       : INTEGER           := NumberOfFrames * 5;

  CONSTANT TAP_0                         : INTEGER           := 0;
  CONSTANT TAP_1                         : INTEGER           := 1;
  CONSTANT TAP_2                         : INTEGER           := 2;
  CONSTANT TAP_3                         : INTEGER           := 3;
  CONSTANT TAP_4                         : INTEGER           := 4;
  CONSTANT TAP_5                         : INTEGER           := 5;
  CONSTANT TAP_6                         : INTEGER           := 6;
  CONSTANT TAP_7                         : INTEGER           := 7;
  CONSTANT TAP_8                         : INTEGER           := 8;
  CONSTANT TAP_9                         : INTEGER           := 9;
  CONSTANT TAP_10                        : INTEGER           := 10;

  SIGNAL accumulatedSortedJetInEtaPhi    : tJetInEtaPhi      := cEmptyJetInEtaPhi;
  SIGNAL accumulatedSortedEgammaInEtaPhi : tClusterInEtaPhi  := cEmptyClusterInEtaPhi;
  SIGNAL accumulatedSortedTauInEtaPhi    : tClusterInEtaPhi  := cEmptyClusterInEtaPhi;
  SIGNAL accumulatedETandMETringInEta    : tRingSegmentInEta := cEmptyRingSegmentInEta;
  SIGNAL accumulatedHTandMHTringInEta    : tRingSegmentInEta := cEmptyRingSegmentInEta;

  SIGNAL CandatateMultiplexedSums        : tWordArrayInEta   := cEmptyWordArrayInEta;

BEGIN

-- ------------------------------------------------------------------------------------
  ET( 0 )( 0 )     <= LinksIn( FIBRE_0 + TAP_0 ) ; ET( 0 )( 1 ) <= LinksIn( FIBRE_1 + TAP_0 ) ; ET( 0 )( 2 ) <= LinksIn( FIBRE_2 + TAP_0 );
  ETnoHF( 0 )( 0 ) <= LinksIn( FIBRE_0 + TAP_1 ) ; ETnoHF( 0 )( 1 ) <= LinksIn( FIBRE_1 + TAP_1 ) ; ETnoHF( 0 )( 2 ) <= LinksIn( FIBRE_2 + TAP_1 );
  HT( 0 )( 0 )     <= LinksIn( FIBRE_0 + TAP_2 ) ; HT( 0 )( 1 ) <= LinksIn( FIBRE_1 + TAP_2 ) ; HT( 0 )( 2 ) <= LinksIn( FIBRE_2 + TAP_2 );
  HTnoHF( 0 )( 0 ) <= LinksIn( FIBRE_0 + TAP_3 ) ; HTnoHF( 0 )( 1 ) <= LinksIn( FIBRE_1 + TAP_3 ) ; HTnoHF( 0 )( 2 ) <= LinksIn( FIBRE_2 + TAP_3 );
  eg( 0 )( 0 )     <= LinksIn( FIBRE_0 + TAP_4 ) ; eg( 0 )( 1 ) <= LinksIn( FIBRE_1 + TAP_4 ) ; eg( 0 )( 2 ) <= LinksIn( FIBRE_2 + TAP_4 );
  eg( 0 )( 3 )     <= LinksIn( FIBRE_0 + TAP_5 ) ; eg( 0 )( 4 ) <= LinksIn( FIBRE_1 + TAP_5 ) ; eg( 0 )( 5 ) <= LinksIn( FIBRE_2 + TAP_5 );
  tau( 0 )( 0 )    <= LinksIn( FIBRE_0 + TAP_6 ) ; tau( 0 )( 1 ) <= LinksIn( FIBRE_1 + TAP_6 ) ; tau( 0 )( 2 ) <= LinksIn( FIBRE_2 + TAP_6 );
  tau( 0 )( 3 )    <= LinksIn( FIBRE_0 + TAP_7 ) ; tau( 0 )( 4 ) <= LinksIn( FIBRE_1 + TAP_7 ) ; tau( 0 )( 5 ) <= LinksIn( FIBRE_2 + TAP_7 );
  jet( 0 )( 0 )    <= LinksIn( FIBRE_0 + TAP_8 ) ; jet( 0 )( 1 ) <= LinksIn( FIBRE_1 + TAP_8 ) ; jet( 0 )( 2 ) <= LinksIn( FIBRE_2 + TAP_8 );
  jet( 0 )( 3 )    <= LinksIn( FIBRE_0 + TAP_9 ) ; jet( 0 )( 4 ) <= LinksIn( FIBRE_1 + TAP_9 ) ; jet( 0 )( 5 ) <= LinksIn( FIBRE_2 + TAP_9 );
  aux( 0 )         <= LinksIn( FIBRE_0 + TAP_10 ) ; aux( 1 ) <= LinksIn( FIBRE_1 + TAP_10 ) ; aux( 2 ) <= LinksIn( FIBRE_2 + TAP_10 );

  ET( 1 )( 0 )     <= LinksIn( FIBRE_3 + TAP_0 ) ; ET( 1 )( 1 ) <= LinksIn( FIBRE_4 + TAP_0 ) ; ET( 1 )( 2 ) <= LinksIn( FIBRE_5 + TAP_0 );
  ETnoHF( 1 )( 0 ) <= LinksIn( FIBRE_3 + TAP_1 ) ; ETnoHF( 1 )( 1 ) <= LinksIn( FIBRE_4 + TAP_1 ) ; ETnoHF( 1 )( 2 ) <= LinksIn( FIBRE_5 + TAP_1 );
  HT( 1 )( 0 )     <= LinksIn( FIBRE_3 + TAP_2 ) ; HT( 1 )( 1 ) <= LinksIn( FIBRE_4 + TAP_2 ) ; HT( 1 )( 2 ) <= LinksIn( FIBRE_5 + TAP_2 );
  HTnoHF( 1 )( 0 ) <= LinksIn( FIBRE_3 + TAP_3 ) ; HTnoHF( 1 )( 1 ) <= LinksIn( FIBRE_4 + TAP_3 ) ; HTnoHF( 1 )( 2 ) <= LinksIn( FIBRE_5 + TAP_3 );
  eg( 1 )( 0 )     <= LinksIn( FIBRE_3 + TAP_4 ) ; eg( 1 )( 1 ) <= LinksIn( FIBRE_4 + TAP_4 ) ; eg( 1 )( 2 ) <= LinksIn( FIBRE_5 + TAP_4 );
  eg( 1 )( 3 )     <= LinksIn( FIBRE_3 + TAP_5 ) ; eg( 1 )( 4 ) <= LinksIn( FIBRE_4 + TAP_5 ) ; eg( 1 )( 5 ) <= LinksIn( FIBRE_5 + TAP_5 );
  tau( 1 )( 0 )    <= LinksIn( FIBRE_3 + TAP_6 ) ; tau( 1 )( 1 ) <= LinksIn( FIBRE_4 + TAP_6 ) ; tau( 1 )( 2 ) <= LinksIn( FIBRE_5 + TAP_6 );
  tau( 1 )( 3 )    <= LinksIn( FIBRE_3 + TAP_7 ) ; tau( 1 )( 4 ) <= LinksIn( FIBRE_4 + TAP_7 ) ; tau( 1 )( 5 ) <= LinksIn( FIBRE_5 + TAP_7 );
  jet( 1 )( 0 )    <= LinksIn( FIBRE_3 + TAP_8 ) ; jet( 1 )( 1 ) <= LinksIn( FIBRE_4 + TAP_8 ) ; jet( 1 )( 2 ) <= LinksIn( FIBRE_5 + TAP_8 );
  jet( 1 )( 3 )    <= LinksIn( FIBRE_3 + TAP_9 ) ; jet( 1 )( 4 ) <= LinksIn( FIBRE_4 + TAP_9 ) ; jet( 1 )( 5 ) <= LinksIn( FIBRE_5 + TAP_9 );
  aux( 3 )         <= LinksIn( FIBRE_3 + TAP_10 ) ; aux( 4 ) <= LinksIn( FIBRE_4 + TAP_10 ) ; aux( 5 ) <= LinksIn( FIBRE_5 + TAP_10 );
-- ------------------------------------------------------------------------------------



-- ------------------------------------------------------------------------------------
  eta_half      : FOR j IN 0 TO 1 GENERATE
-- ------------------------------------------------------------------------------------
    candidates1 : FOR i IN 0 TO 2 GENERATE
      jet2( j )( i ) <= jet( j )( i ) WHEN RISING_EDGE( clk );
      tau2( j )( i ) <= tau( j )( i ) WHEN RISING_EDGE( clk );
      eg2( j )( i )  <= eg( j )( i ) WHEN RISING_EDGE( clk );
    END GENERATE candidates1;

    candidates2 : FOR i IN 3 TO 5 GENERATE
      jet2( j )( i ) <= jet( j )( i );
      tau2( j )( i ) <= tau( j )( i );
      eg2( j )( i )  <= eg( j )( i );
    END GENERATE candidates2;

    SumMultiplexer : FOR i IN 0 TO 2 GENERATE
      CandatateMultiplexedSums( j )( i ) <= ET( j )( i ) WHEN( ET( j )( i ) .valid = '1' )
                                   ELSE ETnoHF( j )( i ) WHEN( ETnoHF( j )( i ) .valid = '1' )
                                   ELSE HT( j )( i ) WHEN( HT( j )( i ) .valid = '1' )
                                   ELSE HTnoHF( j )( i ) WHEN( HTnoHF( j )( i ) .valid = '1' )
                                   ELSE LWORD_NULL;
    END GENERATE SumMultiplexer;
-- ------------------------------------------------------------------------------------
  END GENERATE eta_half;
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  EgammaLinkUnpackerInstance : ENTITY WORK.ClusterLinkUnpacker
  PORT MAP(
    clk              => clk ,
    PackedClustersIn => eg2 ,
    ClusterPipeOut   => accumulatedSortedEgammaPipeOut
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  TauLinkUnpackerInstance : ENTITY WORK.ClusterLinkUnpacker
  PORT MAP(
    clk              => clk ,
    PackedClustersIn => tau2 ,
    ClusterPipeOut   => accumulatedSortedTauPipeOut
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  JetLinkUnpackerInstance : ENTITY WORK.JetLinkUnpacker
  PORT MAP(
    clk          => clk ,
    PackedJetsIn => jet2 ,
    JetPipeOut   => accumulatedSortedJetPipeOut
  );
-- ------------------------------------------------------------------------------------

---- ------------------------------------------------------------------------------------
-- EtLinkUnpackerInstance : ENTITY WORK.RingSumLinkUnpacker
-- PORT MAP(
-- clk => clk ,
-- PackedRingsIn => ET ,
-- RingPipeOut => accumulatedETandMETringPipeOut
-- );
---- ------------------------------------------------------------------------------------

---- ------------------------------------------------------------------------------------
-- EtNoHFLinkUnpackerInstance : ENTITY WORK.RingSumLinkUnpacker
-- PORT MAP(
-- clk => clk ,
-- PackedRingsIn => ETnoHF ,
-- RingPipeOut => accumulatedETandMETnoHFringPipeOut
-- );
---- ------------------------------------------------------------------------------------

---- ------------------------------------------------------------------------------------
-- HtLinkUnpackerInstance : ENTITY WORK.RingSumLinkUnpacker
-- PORT MAP(
-- clk => clk ,
-- PackedRingsIn => HT ,
-- RingPipeOut => accumulatedHTandMHTringPipeOut
-- );
---- ------------------------------------------------------------------------------------

---- ------------------------------------------------------------------------------------
-- HtNoHFLinkUnpackerInstance : ENTITY WORK.RingSumLinkUnpacker
-- PORT MAP(
-- clk => clk ,
-- PackedRingsIn => HTNoHF ,
-- RingPipeOut => accumulatedHTandMHTNoHFringPipeOut
-- );
---- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  CandatateMultiplexedSumUnpackerInstance : ENTITY WORK.RingSumLinkUnpacker
  PORT MAP(
    clk           => clk ,
    PackedRingsIn => CandatateMultiplexedSums ,
    RingPipeOut   => accumulatedRingPipeOut
  );
-- ------------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------------
  AuxLinkUnpackerInstance : ENTITY WORK.AuxLinkUnpacker
  PORT MAP(
    clk                     => clk ,
    PackedAuxInfoIn         => Aux ,
    PileUpEstimationPipeOut => PileUpEstimationPipeOut ,
    RingPipeOut             => MinBiasPipeOut
  );
-- ------------------------------------------------------------------------------------

END ARCHITECTURE behavioral;
