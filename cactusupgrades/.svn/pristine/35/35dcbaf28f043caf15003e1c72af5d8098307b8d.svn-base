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

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;


--! @brief An entity providing a ClusterLinkPacker
--! @details Detailed description
ENTITY ClusterLinkPacker IS
  PORT(
    clk                               : IN STD_LOGIC := '0' ;          --! The algorithm clock
    accumulatedSortedClusterPipeIn    : IN tClusterPipe ;              --! A pipe of tCluster objects bringing in the accumulatedSortedCluster's
    ClusterAccumulationCompletePipeIn : IN tAccumulationCompletePipe ; --! A pipe of tAccumulationComplete objects bringing in the ClusterAccumulationComplete's
    PackedClusterPipeOut              : OUT tPackedLinkPipe            --! A pipe of tPackedLink objects passing out the PackedCluster's
  );
END ClusterLinkPacker;

--! @brief Architecture definition for entity ClusterLinkPacker
--! @details Detailed description
ARCHITECTURE behavioral OF ClusterLinkPacker IS
  SIGNAL Clusters : tPackedLinkInCandidates := cEmptyPackedLinkInCandidates;
BEGIN


  eta          : FOR j IN 0 TO cRegionInEta-1 GENERATE
    candidates : FOR i IN 5 DOWNTO 0 GENERATE
      Clusters( ( 6 * j ) + i ) .Data <= STD_LOGIC_VECTOR( accumulatedSortedClusterPipeIn( 0 )( j )( i ) .Energy( 11 DOWNTO 0 ) ) &
                                          encodeVerticalPosition( accumulatedSortedClusterPipeIn( 0 )( j )( i ) .VerticalPosition ) &
                                          encodeLateralPosition( accumulatedSortedClusterPipeIn( 0 )( j )( i ) .LateralPosition ) &
                                          STD_LOGIC_VECTOR( TO_UNSIGNED( accumulatedSortedClusterPipeIn( 0 )( j )( i ) .Phi , 7 ) ) &
                                          STD_LOGIC_VECTOR( TO_UNSIGNED( accumulatedSortedClusterPipeIn( 0 )( j )( i ) .Eta , 6 ) ) &
                                          TO_STD_LOGIC( accumulatedSortedClusterPipeIn( 0 )( j )( i ) .Isolated2 ) &
                                          TO_STD_LOGIC( accumulatedSortedClusterPipeIn( 0 )( j )( i ) .Isolated ) &
                                          '0';

      Clusters( ( 6 * j ) + i ) .AccumulationComplete <= ClusterAccumulationCompletePipeIn( 0 )( j );

      Clusters( ( 6 * j ) + i ) .DataValid            <= accumulatedSortedClusterPipeIn( 0 )( j )( i ) .DataValid;

    END GENERATE candidates;
  END GENERATE eta;

  PackedLinkPipeInstance : ENTITY work.PackedLinkPipe
  PORT MAP(
    clk            => clk ,
    PackedLinkIn   => Clusters ,
    PackedLinkPipe => PackedClusterPipeOut
  );

END ARCHITECTURE behavioral;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;


--! @brief An entity providing a ClusterLinkPacker
--! @details Detailed description
ENTITY ClusterLinkUnpacker IS
  PORT(
    clk              : IN STD_LOGIC    := '0' ; --! The algorithm clock
    PackedClustersIn : tWordArrayInEta := cEmptyWordArrayInEta;
    ClusterPipeOut   : OUT tClusterPipe --! A pipe of tCluster objects bringing in the accumulatedSortedCluster's
  );
END ClusterLinkUnpacker;

--! @brief Architecture definition for entity ClusterLinkPacker
--! @details Detailed description
ARCHITECTURE behavioral OF ClusterLinkUnpacker IS
  SIGNAL Clusters : tClusterInEtaPhi := cEmptyClusterInEtaPhi;
BEGIN

-- ------------------------------------------------------------------------------------
  eta_half     : FOR j IN 0 TO 1 GENERATE
    candidates : FOR i IN 0 TO 5 GENERATE
      Clusters( j )( i ) .Energy( 11 DOWNTO 0 ) <= UNSIGNED( PackedClustersIn( j )( i ) .data( 31 DOWNTO 20 ) );
      Clusters( j )( i ) .VerticalPosition      <= Undefined WHEN PackedClustersIn( j )( i ) .data( 19 DOWNTO 18 ) = "00"
                                                                 ELSE North WHEN PackedClustersIn( j )( i ) .data( 19 DOWNTO 18 ) = "01"
                                                                 ELSE Centre WHEN PackedClustersIn( j )( i ) .data( 19 DOWNTO 18 ) = "10"
                                                                 ELSE South WHEN PackedClustersIn( j )( i ) .data( 19 DOWNTO 18 ) = "11";
      Clusters( j )( i ) .LateralPosition <= Undefined WHEN PackedClustersIn( j )( i ) .data( 17 DOWNTO 16 ) = "00"
                                                                ELSE West WHEN PackedClustersIn( j )( i ) .data( 17 DOWNTO 16 ) = "01"
                                                                ELSE Centre WHEN PackedClustersIn( j )( i ) .data( 17 DOWNTO 16 ) = "10"
                                                                ELSE East WHEN PackedClustersIn( j )( i ) .data( 17 DOWNTO 16 ) = "11";
      Clusters( j )( i ) .Phi       <= TO_INTEGER( UNSIGNED( PackedClustersIn( j )( i ) .data( 15 DOWNTO 9 ) ) );
      Clusters( j )( i ) .Eta       <= TO_INTEGER( UNSIGNED( PackedClustersIn( j )( i ) .data( 8 DOWNTO 3 ) ) );
      Clusters( j )( i ) .EtaHalf   <= j;

      Clusters( j )( i ) .Isolated2 <= PackedClustersIn( j )( i ) .data( 2 ) = '1';
      Clusters( j )( i ) .Isolated  <= PackedClustersIn( j )( i ) .data( 1 ) = '1';
--Clusters( j )( i ) .Saturated <= PackedClustersIn( j )( i ) .data( 0 ) = '1';

      Clusters( j )( i ) .DataValid <= PackedClustersIn( j )( i ) .valid = '1';
    END GENERATE candidates;
  END GENERATE eta_half;
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  ClusterPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    clusterIn   => Clusters ,
    clusterPipe => ClusterPipeOut
  );
-- ------------------------------------------------------------------------------------
END ARCHITECTURE behavioral;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;



--! @brief An entity providing a DemuxClusterLinkPacker
--! @details Detailed description
ENTITY DemuxClusterLinkPacker IS
  PORT(
    clk                      : IN STD_LOGIC := '0' ;        --! The algorithm clock
    gtFormattedClusterPipeIn : IN tGtFormattedClusterPipe ; --! A pipe of tGtFormattedCluster objects bringing in the gtFormattedCluster's
    PackedClusterPipeOut     : OUT tPackedLinkPipe          --! A pipe of tPackedLink objects passing out the PackedCluster's
  );
END DemuxClusterLinkPacker;

--! @brief Architecture definition for entity DemuxClusterLinkPacker
--! @details Detailed description
ARCHITECTURE behavioral OF DemuxClusterLinkPacker IS
  SIGNAL Clusters : tPackedLinkInCandidates := cEmptyPackedLinkInCandidates;
BEGIN


  candidates : FOR i IN 11 DOWNTO 0 GENERATE
    Clusters( i ) .Data <= "00000" &
                           TO_STD_LOGIC( gtFormattedClusterPipeIn( 0 )( i ) .Isolated2 ) &
                           TO_STD_LOGIC( gtFormattedClusterPipeIn( 0 )( i ) .Isolated ) &
                           STD_LOGIC_VECTOR( gtFormattedClusterPipeIn( 0 )( i ) .Phi ) &
                           STD_LOGIC_VECTOR( gtFormattedClusterPipeIn( 0 )( i ) .Eta ) &
                           STD_LOGIC_VECTOR( gtFormattedClusterPipeIn( 0 )( i ) .Energy );
    Clusters( i ) .DataValid <= gtFormattedClusterPipeIn( 0 )( i ) .DataValid;
  END GENERATE candidates;

  PackedLinkPipeInstance : ENTITY work.PackedLinkPipe
  PORT MAP(
    clk            => clk ,
    PackedLinkIn   => Clusters ,
    PackedLinkPipe => PackedClusterPipeOut
  );

END ARCHITECTURE behavioral;
