
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
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "cluster" helper functions
USE work.cluster_functions.ALL;

--! @brief An entity providing a ClusterSumFormer
--! @details Detailed description
ENTITY ClusterSumFormer IS
  GENERIC(
    ProtoClusterPipeOffset : INTEGER := 0
  );
  PORT(
    clk                : IN STD_LOGIC := '0' ;  --! The algorithm clock
    ClusterInputPipeIn : IN tClusterInputPipe ; --! A pipe of tClusterInput objects bringing in the ClusterInput's
    ProtoClusterPipeIn : IN tClusterPipe ;      --! A pipe of tCluster objects bringing in the ProtoCluster's
    ClusterPipeOut     : OUT tClusterPipe       --! A pipe of tCluster objects passing out the Cluster's
  );
END ENTITY ClusterSumFormer;


--! @brief Architecture definition for entity ClusterSumFormer
--! @details Detailed description
ARCHITECTURE behavioral OF ClusterSumFormer IS

  SIGNAL ClusterInput , ClusterInput2 : tClusterInputInEtaPhi := cEmptyClusterInputInEtaPhi;

  TYPE tPartialSums IS RECORD
    NorthWestOrEast : tCluster;
    WestOrEast      : tCluster;
    SouthWestOrEast : tCluster;
    Centre          : tCluster;
    Tails           : tCluster;
    North           : tCluster;
    South           : tCluster;
    R2North         : tCluster;
    R2South         : tCluster;
  END RECORD tPartialSums;

  TYPE tPartialSumInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF tPartialSums;
  TYPE tPartialSumInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tPartialSumInPhi;
  TYPE tPartialSumsPipe    IS ARRAY( NATURAL RANGE <> ) OF tPartialSumInEtaPhi;

  CONSTANT cEmptyPartialSums         : tPartialSums        := ( OTHERS => cEmptyCluster );
  CONSTANT cEmptyPartialSumInPhi     : tPartialSumInPhi    := ( OTHERS => cEmptyPartialSums );
  CONSTANT cEmptyPartialSumInEtaPhi  : tPartialSumInEtaPhi := ( OTHERS => cEmptyPartialSumInPhi );

  SIGNAL SumInput , Sum1             : tPartialSumInEtaPhi := cEmptyPartialSumInEtaPhi;
  SIGNAL Sum2 , Final                : tClusterInEtaPhi    := cEmptyClusterInEtaPhi;

  SIGNAL NorthGtSouth , NorthEqSouth : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;


-- SIGNAL PartialSumsPipe : tPartialSumsPipe( 3 downto 0 ) := ( OTHERS => cEmptyPartialSumInEtaPhi );
--
-- SIGNAL EastWestInputInEtaPhi : tClusterInEtaPhi := cEmptyClusterInEtaPhi;
-- SIGNAL ClusterSums : tClusterInEtaPhi := cEmptyClusterInEtaPhi;


BEGIN

  phi   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE

-- ------------------------------------------------------------------------
      SumInput( j )( i ) .Centre.Energy( 8 DOWNTO 0 )          <= ClusterInputPipeIn( 0 )( j )( i ) .Centre.Energy WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .HasSeed ELSE( OTHERS               => '0' );
      SumInput( j )( i ) .North.Energy( 8 DOWNTO 0 )           <= ClusterInputPipeIn( 0 )( j )( i ) .R1N.Energy WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .TrimmingFlags( 1 ) = '1' ELSE( OTHERS => '0' );
      SumInput( j )( i ) .South.Energy( 8 DOWNTO 0 )           <= ClusterInputPipeIn( 0 )( j )( i ) .R1S.Energy WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .TrimmingFlags( 0 ) = '1' ELSE( OTHERS => '0' );
      SumInput( j )( i ) .R2North.Energy( 8 DOWNTO 0 )         <= ClusterInputPipeIn( 0 )( j )( i ) .R2N.Energy WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .TrimmingFlags( 6 ) = '1' ELSE( OTHERS => '0' );
      SumInput( j )( i ) .R2South.Energy( 8 DOWNTO 0 )         <= ClusterInputPipeIn( 0 )( j )( i ) .R2S.Energy WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .TrimmingFlags( 5 ) = '1' ELSE( OTHERS => '0' );

      SumInput( j )( i ) .NorthWestOrEast.Energy( 8 DOWNTO 0 ) <= ClusterInputPipeIn( 0 )( j )( i ) .R1NW.Energy
                                                      WHEN( ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .TrimmingFlags( 4 ) = '1' AND ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .LateralPosition = West )
                                                      ELSE ClusterInputPipeIn( 0 )( j )( i ) .R1NE.Energy
                                                      WHEN( ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .TrimmingFlags( 4 ) = '1' AND ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .LateralPosition /= West )
                                                      ELSE( OTHERS => '0' );

      SumInput( j )( i ) .WestOrEast.Energy( 8 DOWNTO 0 ) <= ClusterInputPipeIn( 0 )( j )( i ) .R1W.Energy
                                                      WHEN( ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .TrimmingFlags( 2 ) = '1' AND ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .LateralPosition = West )
                                                      ELSE ClusterInputPipeIn( 0 )( j )( i ) .R1E.Energy
                                                      WHEN( ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .TrimmingFlags( 2 ) = '1' AND ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .LateralPosition /= West )
                                                      ELSE( OTHERS => '0' );

      SumInput( j )( i ) .SouthWestOrEast.Energy( 8 DOWNTO 0 ) <= ClusterInputPipeIn( 0 )( j )( i ) .R1SW.Energy
                                                      WHEN( ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .TrimmingFlags( 3 ) = '1' AND ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .LateralPosition = West )
                                                      ELSE ClusterInputPipeIn( 0 )( j )( i ) .R1SE.Energy
                                                      WHEN( ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .TrimmingFlags( 3 ) = '1' AND ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .LateralPosition /= West )
                                                      ELSE( OTHERS => '0' );
-- ------------------------------------------------------------------------

-- ------------------------------------------------------------------------
      SumInput( j )( i ) .Centre.Phi                <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .Phi;
      SumInput( j )( i ) .Centre.Eta                <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .Eta;
      SumInput( j )( i ) .Centre.EtaHalf            <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .EtaHalf;
      SumInput( j )( i ) .Centre.LateralPosition    <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .LateralPosition;
      SumInput( j )( i ) .Centre.VerticalPosition   <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .VerticalPosition;
      SumInput( j )( i ) .Centre.EgammaCandidate    <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .EgammaCandidate;
      SumInput( j )( i ) .Centre.HasEM              <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .HasEM;
      SumInput( j )( i ) .Centre.HasSeed            <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .HasSeed;
      SumInput( j )( i ) .Centre.Isolated           <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .Isolated;
      SumInput( j )( i ) .Centre.TauSite            <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .TauSite;
      SumInput( j )( i ) .Centre.TrimmingFlags      <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .TrimmingFlags;
      SumInput( j )( i ) .Centre.ShapeFlags         <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .ShapeFlags;
-- ------------------------------------------------------------------------

-- ------------------------------------------------------------------------
-- SumInput( j )( i ) .Centre.DataValid <= ClusterInputPipeIn( 0 )( j )( i ) .Centre.DataValid;
-- SumInput( j )( i ) .North.DataValid <= ClusterInputPipeIn( 0 )( j )( i ) .R1N.DataValid;
-- SumInput( j )( i ) .South.DataValid <= ClusterInputPipeIn( 0 )( j )( i ) .R1S.DataValid;
-- SumInput( j )( i ) .R2North.DataValid <= ClusterInputPipeIn( 0 )( j )( i ) .R2N.DataValid;
-- SumInput( j )( i ) .R2South.DataValid <= ClusterInputPipeIn( 0 )( j )( i ) .R2S.DataValid;
--
-- SumInput( j )( i ) .NorthWestOrEast.DataValid <= ClusterInputPipeIn( 0 )( j )( i ) .R1NW.DataValid WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .LateralPosition = West
-- ELSE ClusterInputPipeIn( 0 )( j )( i ) .R1NE.DataValid;
--
-- SumInput( j )( i ) .WestOrEast.DataValid <= ClusterInputPipeIn( 0 )( j )( i ) .R1W.DataValid WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .LateralPosition = West
-- ELSE ClusterInputPipeIn( 0 )( j )( i ) .R1E.DataValid;
--
-- SumInput( j )( i ) .SouthWestOrEast.DataValid <= ClusterInputPipeIn( 0 )( j )( i ) .R1SW.DataValid WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .LateralPosition = West
-- ELSE ClusterInputPipeIn( 0 )( j )( i ) .R1SE.DataValid;

      SumInput( j )( i ) .Centre.DataValid          <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .DataValid;
      SumInput( j )( i ) .North.DataValid           <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .DataValid;
      SumInput( j )( i ) .South.DataValid           <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .DataValid;
      SumInput( j )( i ) .R2North.DataValid         <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .DataValid;
      SumInput( j )( i ) .R2South.DataValid         <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .DataValid;
      SumInput( j )( i ) .NorthWestOrEast.DataValid <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .DataValid;
      SumInput( j )( i ) .WestOrEast.DataValid      <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .DataValid;
      SumInput( j )( i ) .SouthWestOrEast.DataValid <= ProtoClusterPipeIn( ProtoClusterPipeOffset )( j )( i ) .DataValid;
-- ------------------------------------------------------------------------

    END GENERATE eta;
  END GENERATE phi;

  phi2                  : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta2                : FOR j IN 0 TO cRegionInEta-1 GENERATE
      SumCentreInstance : ENTITY work.ClusterSum
      PORT MAP(
        Clk        => Clk ,
        ClusterIn1 => SumInput( j )( i ) .North ,
        ClusterIn2 => SumInput( j )( i ) .Centre ,
        ClusterIn3 => SumInput( j )( i ) .South ,
        ClusterOut => Sum1( j )( i ) .Centre
      );

      SumWestOrEastInstance : ENTITY work.ClusterSum
      PORT MAP(
        Clk        => Clk ,
        ClusterIn1 => SumInput( j )( i ) .NorthWestOrEast ,
        ClusterIn2 => SumInput( j )( i ) .WestOrEast ,
        ClusterIn3 => SumInput( j )( i ) .SouthWestOrEast ,
        ClusterOut => Sum1( j )( i ) .WestOrEast
      );

      SumTailsInstance : ENTITY work.ClusterSum2
      PORT MAP(
        Clk        => Clk ,
        ClusterIn1 => SumInput( j )( i ) .R2North ,
        ClusterIn2 => SumInput( j )( i ) .R2South ,
        ClusterOut => Sum1( j )( i ) .Tails
      );

      SumNorthInstance : ENTITY work.ClusterSum
      PORT MAP(
        Clk        => Clk ,
        ClusterIn1 => SumInput( j )( i ) .NorthWestOrEast ,
        ClusterIn2 => SumInput( j )( i ) .North ,
        ClusterIn3 => SumInput( j )( i ) .R2North ,
        ClusterOut => Sum1( j )( i ) .North
      );

      SumSouthInstance : ENTITY work.ClusterSum
      PORT MAP(
        Clk        => Clk ,
        ClusterIn1 => SumInput( j )( i ) .SouthWestOrEast ,
        ClusterIn2 => SumInput( j )( i ) .South ,
        ClusterIn3 => SumInput( j )( i ) .R2South ,
        ClusterOut => Sum1( j )( i ) .South
      );

      SumFinalInstance : ENTITY work.ClusterSum
      PORT MAP(
        Clk        => Clk ,
        ClusterIn1 => Sum1( j )( i ) .WestOrEast ,
        ClusterIn2 => Sum1( j )( i ) .Centre ,
        ClusterIn3 => Sum1( j )( i ) .Tails ,
        ClusterOut => Sum2( j )( i )
      );

      NorthGtSouth( j )( i ) .data <= ( Sum1( j )( i ) .North.Energy > Sum1( j )( i ) .South.Energy ) WHEN RISING_EDGE( clk );
      NorthEqSouth( j )( i ) .data <= ( Sum1( j )( i ) .North.Energy = Sum1( j )( i ) .South.Energy ) WHEN RISING_EDGE( clk );

    END GENERATE eta2;
  END GENERATE phi2;

  phi3   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta3 : FOR j IN 0 TO cRegionInEta-1 GENERATE
      PROCESS( CLK )
      BEGIN
        IF RISING_EDGE( CLK ) THEN

          Final( j )( i ) <= Sum2( j )( i );

          IF NorthGtSouth( j )( i ) .data THEN
            Final( j )( i ) .VerticalPosition <= North;
          ELSIF NorthEqSouth( j )( i ) .data THEN
            Final( j )( i ) .VerticalPosition <= Centre;
          ELSE
            Final( j )( i ) .VerticalPosition <= South;
          END IF;

        END IF;
      END PROCESS;
    END GENERATE eta3;
  END GENERATE phi3;

  ClusterPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => Final ,
    ClusterPipe => ClusterPipeOut
  );

END ARCHITECTURE behavioral;
