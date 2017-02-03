
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

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "cluster" helper functions
USE work.cluster_functions.ALL;

--! @brief An entity providing a ProtoClusterFormer
--! @details Detailed description
ENTITY ProtoClusterFormer IS
  GENERIC(
    TowerPipeOffset : INTEGER := 0;
    thresholdOffset : INTEGER := 0
  );
  PORT(
    clk                   : IN STD_LOGIC := '0' ; --! The algorithm clock
    TowerPipeIn           : IN tTowerPipe ;       --! A pipe of tTower objects bringing in the Tower's
    TowerThresholdsPipeIn : IN tTowerFlagsPipe ;  --! A pipe of tTowerFlags objects bringing in the TowerThresholds's
    ClusterPipeOut        : OUT tClusterPipe      --! A pipe of tCluster objects passing out the Cluster's
  );
END ENTITY ProtoClusterFormer;


--! @brief Architecture definition for entity ProtoClusterFormer
--! @details Detailed description
ARCHITECTURE behavioral OF ProtoClusterFormer IS

  SIGNAL Cluster1x1InEtaPhi , Cluster3x1InEtaPhi , Cluster5x1InEtaPhiTemp , Cluster5x1InEtaPhi : tClusterInEtaPhi           := cEmptyClusterInEtaPhi;
  SIGNAL ClusterTailNInEtaPhi , ClusterTailSInEtaPhi                                           : tClusterInEtaPhi           := cEmptyClusterInEtaPhi;

  SIGNAL Cluster3x1PipeInt                                                                     : tClusterPipe( 2 DOWNTO 0 ) := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL Cluster5x1PipeInt                                                                     : tClusterPipe( 2 DOWNTO 0 ) := ( OTHERS => cEmptyClusterInEtaPhi );
  SIGNAL PreProtoClusterPipeInt                                                                : tClusterPipe( 2 DOWNTO 0 ) := ( OTHERS => cEmptyClusterInEtaPhi );

  SIGNAL ClusterInput1 , ClusterInput2 , ClusterInput3                                         : tClusterInEtaPhi           := cEmptyClusterInEtaPhi;
  SIGNAL PreProtoCluster                                                                       : tClusterInEtaPhi           := cEmptyClusterInEtaPhi;

  TYPE tClusteringFlags         IS ARRAY( 10 DOWNTO 0 ) OF BOOLEAN;
  TYPE tClusteringFlagsInPhi    IS ARRAY( 0 TO cTowerInPhi-1 ) OF tClusteringFlags;
  TYPE tClusteringFlagsInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tClusteringFlagsInPhi;

  SIGNAL WestGtEast , WestEqEast : tComparisonInEtaPhi      := cEmptyComparisonInEtaPhi;

  SIGNAL ClusteringFlags         : tClusteringFlagsInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => FALSE ) ) );

  SIGNAL ProtoCluster            : tClusterInEtaPhi         := cEmptyClusterInEtaPhi;

BEGIN

-- -------------------------------------------------------------------------------------------------------
  phi1   : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    eta1 : FOR j IN 0 TO cRegionInEta-1 GENERATE

      Cluster1x1InEtaPhi( j )( i ) .Energy( 8 DOWNTO 0 ) <= TowerPipeIn( TowerPipeOffset )( j )( i ) .Energy WHEN TowerThresholdsPipeIn( thresholdOffset + 0 )( j )( i ) .ClusterThreshold ELSE( OTHERS => '0' );
      Cluster1x1InEtaPhi( j )( i ) .HasSeed              <= TowerThresholdsPipeIn( thresholdOffset + 0 )( j )( i ) .ClusterSeedThreshold;
      Cluster1x1InEtaPhi( j )( i ) .EgammaCandidate      <= TowerPipeIn( TowerPipeOffset )( j )( i ) .EgammaCandidate;
      Cluster1x1InEtaPhi( j )( i ) .HasEM                <= TowerPipeIn( TowerPipeOffset )( j )( i ) .HasEM;
      Cluster1x1InEtaPhi( j )( i ) .DataValid            <= TowerPipeIn( TowerPipeOffset )( j )( i ) .DataValid;

      Sum3x1Instance : ENTITY work.ClusterSum
      PORT MAP(
        Clk        => Clk ,
        ClusterIn1 => Cluster1x1InEtaPhi( j )( MOD_PHI( i - 1 ) ) ,
        ClusterIn2 => Cluster1x1InEtaPhi( j )( MOD_PHI( i + 0 ) ) ,
        ClusterIn3 => Cluster1x1InEtaPhi( j )( MOD_PHI( i + 1 ) ) ,
        ClusterOut => Cluster3x1InEtaPhi( j )( i )
      );
    END GENERATE eta1;
  END GENERATE phi1;
-- -------------------------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------------------------------
  phi2   : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    eta2 : FOR j IN 0 TO cRegionInEta-1 GENERATE
      ClusterTailNInEtaPhi( j )( i ) .Energy( 8 DOWNTO 0 ) <= TowerPipeIn( TowerPipeOffset + 1 )( j )( MOD_PHI( i + 2 ) ) .Energy
                                          WHEN TowerThresholdsPipeIn( thresholdOffset + 1 )( j )( MOD_PHI( i + 1 ) ) .ClusterThreshold AND TowerThresholdsPipeIn( thresholdOffset + 1 )( j )( MOD_PHI( i + 2 ) ) .ClusterThreshold
                                          ELSE( OTHERS => '0' );

      ClusterTailNInEtaPhi( j )( i ) .HasEM <= TowerPipeIn( TowerPipeOffset + 1 )( j )( MOD_PHI( i + 2 ) ) .HasEM
                                          WHEN TowerThresholdsPipeIn( thresholdOffset + 1 )( j )( MOD_PHI( i + 1 ) ) .ClusterThreshold AND TowerThresholdsPipeIn( thresholdOffset + 1 )( j )( MOD_PHI( i + 2 ) ) .ClusterThreshold
                                          ELSE FALSE;

      ClusterTailNInEtaPhi( j )( i ) .DataValid            <= TowerPipeIn( TowerPipeOffset + 1 )( j )( MOD_PHI( i + 1 ) ) .DataValid AND TowerPipeIn( TowerPipeOffset + 1 )( j )( MOD_PHI( i + 2 ) ) .DataValid;

      ClusterTailSInEtaPhi( j )( i ) .Energy( 8 DOWNTO 0 ) <= TowerPipeIn( TowerPipeOffset + 1 )( j )( MOD_PHI( i - 2 ) ) .Energy
                                          WHEN TowerThresholdsPipeIn( thresholdOffset + 1 )( j )( MOD_PHI( i - 1 ) ) .ClusterThreshold AND TowerThresholdsPipeIn( thresholdOffset + 1 )( j )( MOD_PHI( i - 2 ) ) .ClusterThreshold
                                          ELSE( OTHERS => '0' );

      ClusterTailSInEtaPhi( j )( i ) .HasEM <= TowerPipeIn( TowerPipeOffset + 1 )( j )( MOD_PHI( i - 2 ) ) .HasEM
                                          WHEN TowerThresholdsPipeIn( thresholdOffset + 1 )( j )( MOD_PHI( i - 1 ) ) .ClusterThreshold AND TowerThresholdsPipeIn( thresholdOffset + 1 )( j )( MOD_PHI( i - 2 ) ) .ClusterThreshold
                                          ELSE FALSE;

      ClusterTailSInEtaPhi( j )( i ) .DataValid <= TowerPipeIn( TowerPipeOffset + 1 )( j )( MOD_PHI( i - 1 ) ) .DataValid AND TowerPipeIn( TowerPipeOffset + 1 )( j )( MOD_PHI( i - 2 ) ) .DataValid;

      Sum5x1Instance : ENTITY work.ClusterSum
      PORT MAP(
        Clk        => Clk ,
        ClusterIn1 => ClusterTailNInEtaPhi( j )( i ) ,
        ClusterIn2 => Cluster3x1PipeInt( 0 )( j )( i ) ,
        ClusterIn3 => ClusterTailSInEtaPhi( j )( i ) ,
        ClusterOut => Cluster5x1InEtaPhi( j )( i )
      );

    END GENERATE eta2;
  END GENERATE phi2;
-- -------------------------------------------------------------------------------------------------------

-- -------------------------------------------------------------------------------------------------------
  phi3 : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    ClusterInput1( 0 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT cluster3x1PipeInt( 1 )( 0 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE cluster3x1PipeInt( 0 )( 0 )( i );

    ClusterInput2( 0 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT cluster5x1PipeInt( 0 )( 0 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE cluster5x1PipeInt( 0 )( 0 )( i );

    ClusterInput3( 0 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT cluster3x1PipeInt( 1 )( 0 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE cluster3x1PipeInt( 1 )( OPP_ETA( 0 ) )( i ) WHEN NOT cluster3x1PipeInt( 2 )( 0 )( i ) .DataValid
                          ELSE cluster3x1PipeInt( 2 )( 0 )( i );

    ClusterInput1( 1 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT cluster3x1PipeInt( 1 )( 1 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE cluster3x1PipeInt( 1 )( OPP_ETA( 1 ) )( i ) WHEN NOT cluster3x1PipeInt( 2 )( 1 )( i ) .DataValid
                          ELSE cluster3x1PipeInt( 2 )( 1 )( i );

    ClusterInput2( 1 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT cluster5x1PipeInt( 0 )( 1 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE cluster5x1PipeInt( 0 )( 1 )( i );

    ClusterInput3( 1 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT cluster3x1PipeInt( 1 )( 1 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE cluster3x1PipeInt( 0 )( 1 )( i );


    eta3                 : FOR j IN 0 TO cRegionInEta-1 GENERATE
      ClusterSumInstance : ENTITY work.ClusterSum
      PORT MAP(
        Clk        => Clk ,
        ClusterIn1 => ClusterInput1( j )( i ) ,
        ClusterIn2 => ClusterInput2( j )( i ) ,
        ClusterIn3 => ClusterInput3( j )( i ) ,
        ClusterOut => PreProtoCluster( j )( i )
      );

      WestGtEast( j )( i ) .data <= ( ClusterInput3( j )( i ) .Energy > ClusterInput1( j )( i ) .Energy ) WHEN RISING_EDGE( clk );
      WestEqEast( j )( i ) .data <= ( ClusterInput3( j )( i ) .Energy = ClusterInput1( j )( i ) .Energy ) WHEN RISING_EDGE( clk );
    END GENERATE eta3;

  END GENERATE phi3;
-- -------------------------------------------------------------------------------------------------------


-- -------------------------------------------------------------------------------------------------------
  phi4 : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    ClusteringFlags( 0 )( i )( 0 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i + 0 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i + 0 ) ) .ClusterThreshold;

    ClusteringFlags( 0 )( i )( 1 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i + 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( OPP_ETA( 0 ) )( MOD_PHI( i + 1 ) ) .ClusterThreshold WHEN NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 2 )( 0 )( MOD_PHI( i + 1 ) ) .DataValid
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 2 )( 0 )( MOD_PHI( i + 1 ) ) .ClusterThreshold;

    ClusteringFlags( 0 )( i )( 2 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i + 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i + 1 ) ) .ClusterThreshold;

    ClusteringFlags( 0 )( i )( 3 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i + 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 0 )( 0 )( MOD_PHI( i + 1 ) ) .ClusterThreshold;

    ClusteringFlags( 0 )( i )( 4 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i + 0 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 0 )( 0 )( MOD_PHI( i + 0 ) ) .ClusterThreshold;

    ClusteringFlags( 0 )( i )( 5 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i - 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 0 )( 0 )( MOD_PHI( i - 1 ) ) .ClusterThreshold;

    ClusteringFlags( 0 )( i )( 6 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i - 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i - 1 ) ) .ClusterThreshold;

    ClusteringFlags( 0 )( i )( 7 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i - 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( OPP_ETA( 0 ) )( MOD_PHI( i - 1 ) ) .ClusterThreshold WHEN NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 2 )( 0 )( MOD_PHI( i - 1 ) ) .DataValid
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 2 )( 0 )( MOD_PHI( i - 1 ) ) .ClusterThreshold;

    ClusteringFlags( 0 )( i )( 8 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i + 0 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( OPP_ETA( 0 ) )( MOD_PHI( i + 0 ) ) .ClusterThreshold WHEN NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 2 )( 0 )( MOD_PHI( i + 0 ) ) .DataValid
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 2 )( 0 )( MOD_PHI( i + 0 ) ) .ClusterThreshold;

    ClusteringFlags( 0 )( i )( 9 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i + 1 ) ) .ClusterThreshold AND TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i + 2 ) ) .ClusterThreshold;

    ClusteringFlags( 0 )( i )( 10 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i - 1 ) ) .ClusterThreshold AND TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 0 )( MOD_PHI( i - 2 ) ) .ClusterThreshold;


    ClusteringFlags( 1 )( i )( 0 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i + 0 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i + 0 ) ) .ClusterThreshold;

    ClusteringFlags( 1 )( i )( 3 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i + 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( OPP_ETA( 1 ) )( MOD_PHI( i + 1 ) ) .ClusterThreshold WHEN NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 2 )( 1 )( MOD_PHI( i + 1 ) ) .DataValid
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 2 )( 1 )( MOD_PHI( i + 1 ) ) .ClusterThreshold;

    ClusteringFlags( 1 )( i )( 2 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i + 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i + 1 ) ) .ClusterThreshold;

    ClusteringFlags( 1 )( i )( 1 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i + 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 0 )( 1 )( MOD_PHI( i + 1 ) ) .ClusterThreshold;

    ClusteringFlags( 1 )( i )( 8 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i + 0 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 0 )( 1 )( MOD_PHI( i + 0 ) ) .ClusterThreshold;

    ClusteringFlags( 1 )( i )( 7 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i - 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 0 )( 1 )( MOD_PHI( i - 1 ) ) .ClusterThreshold;

    ClusteringFlags( 1 )( i )( 6 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i - 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i - 1 ) ) .ClusterThreshold;

    ClusteringFlags( 1 )( i )( 5 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i - 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( OPP_ETA( 1 ) )( MOD_PHI( i - 1 ) ) .ClusterThreshold WHEN NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 2 )( 1 )( MOD_PHI( i - 1 ) ) .DataValid
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 2 )( 1 )( MOD_PHI( i - 1 ) ) .ClusterThreshold;

    ClusteringFlags( 1 )( i )( 4 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i + 0 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( OPP_ETA( 1 ) )( MOD_PHI( i + 0 ) ) .ClusterThreshold WHEN NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 2 )( 1 )( MOD_PHI( i + 0 ) ) .DataValid
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 2 )( 1 )( MOD_PHI( i + 0 ) ) .ClusterThreshold;

    ClusteringFlags( 1 )( i )( 9 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i + 1 ) ) .ClusterThreshold AND TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i + 2 ) ) .ClusterThreshold;

    ClusteringFlags( 1 )( i )( 10 ) <= FALSE WHEN( cIncludeNullState AND NOT TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                          ELSE TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i - 1 ) ) .ClusterThreshold AND TowerThresholdsPipeIn( thresholdOffset + 2 + 1 )( 1 )( MOD_PHI( i - 2 ) ) .ClusterThreshold;


    eta4 : FOR j IN 0 TO cRegionInEta-1 GENERATE
      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN

          IF NOT PreProtoClusterPipeInt( 0 )( j )( i ) .HasSeed THEN
            ProtoCluster( j )( i )            <= cEmptyCluster;
            ProtoCluster( j )( i ) .DataValid <= PreProtoClusterPipeInt( 0 )( j )( i ) .DataValid;
          ELSE
            ProtoCluster( j )( i )                     <= PreProtoClusterPipeInt( 0 )( j )( i );

            ProtoCluster( j )( i ) .TrimmingFlags( 6 ) <= TO_STD_LOGIC( ClusteringFlags( j )( i )( 9 ) );
            ProtoCluster( j )( i ) .TrimmingFlags( 5 ) <= TO_STD_LOGIC( ClusteringFlags( j )( i )( 10 ) );

            IF WestGtEast( j )( i ) .data THEN
              ProtoCluster( j )( i ) .TrimmingFlags( 4 ) <= TO_STD_LOGIC( ClusteringFlags( j )( i )( 1 ) );
              ProtoCluster( j )( i ) .TrimmingFlags( 3 ) <= TO_STD_LOGIC( ClusteringFlags( j )( i )( 7 ) );
              ProtoCluster( j )( i ) .TrimmingFlags( 2 ) <= TO_STD_LOGIC( ClusteringFlags( j )( i )( 8 ) );
            ELSE
              ProtoCluster( j )( i ) .TrimmingFlags( 4 ) <= TO_STD_LOGIC( ClusteringFlags( j )( i )( 3 ) );
              ProtoCluster( j )( i ) .TrimmingFlags( 3 ) <= TO_STD_LOGIC( ClusteringFlags( j )( i )( 5 ) );
              ProtoCluster( j )( i ) .TrimmingFlags( 2 ) <= TO_STD_LOGIC( ClusteringFlags( j )( i )( 4 ) );
            END IF;

            ProtoCluster( j )( i ) .TrimmingFlags( 1 ) <= TO_STD_LOGIC( ClusteringFlags( j )( i )( 2 ) );
            ProtoCluster( j )( i ) .TrimmingFlags( 0 ) <= TO_STD_LOGIC( ClusteringFlags( j )( i )( 6 ) );

            IF WestGtEast( j )( i ) .data THEN
              ProtoCluster( j )( i ) .LateralPosition <= West;
            ELSIF WestEqEast( j )( i ) .data THEN
              ProtoCluster( j )( i ) .LateralPosition <= Centre;
            ELSE
              ProtoCluster( j )( i ) .LateralPosition <= East;
            END IF;
          END IF;

        END IF;
      END PROCESS;

    END GENERATE eta4;

  END GENERATE phi4;

-- -------------------------------------------------------------------------------------------------------


-- -------------------------------------------------------------------------------------------------------
  Cluster3x1PipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => Cluster3x1InEtaPhi ,
    ClusterPipe => Cluster3x1PipeInt
  );

  Cluster5x1PipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => Cluster5x1InEtaPhi ,
    ClusterPipe => Cluster5x1PipeInt
  );

  PreProtoClusterPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => PreProtoCluster ,
    ClusterPipe => PreProtoClusterPipeInt
  );

  ClusterPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => ProtoCluster ,
    ClusterPipe => ClusterPipeOut
  );
-- -------------------------------------------------------------------------------------------------------

END ARCHITECTURE behavioral;
