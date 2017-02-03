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

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "cluster" helper functions
USE work.cluster_functions.ALL;

--! @brief An entity providing a TauClusterTrimming
--! @details Detailed description
ENTITY TauClusterTrimming IS
  PORT(
    clk                    : IN STD_LOGIC := '0' ; --! The algorithm clock
    ProtoClusterPipeIn     : IN tClusterPipe ;     --! A pipe of tCluster objects bringing in the ProtoCluster's
    TauSecondariesPipeIn   : IN tClusterPipe ;     --! A pipe of tCluster objects bringing in the TauSecondaries's
    TauProtoClusterPipeOut : OUT tClusterPipe      --! A pipe of tCluster objects passing out the TauProtoCluster's
  );
END ENTITY TauClusterTrimming;


--! @brief Architecture definition for entity TauClusterTrimming
--! @details Detailed description
ARCHITECTURE behavioral OF TauClusterTrimming IS
  SIGNAL TauProtoCluster : tClusterInEtaPhi := cEmptyClusterInEtaPhi;

  TYPE tVectorInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF STD_LOGIC_VECTOR( 7 DOWNTO 0 );
  TYPE tVectorInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tVectorInPhi;
  SIGNAL ProtoClusterFlagsPlusEta , DoubleCountingMask : tVectorInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );

BEGIN

  phi   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE

      ProtoClusterFlagsPlusEta( j )( i )( 7 DOWNTO 5 ) <= STD_LOGIC_VECTOR( TO_UNSIGNED( TauSecondariesPipeIn( 0 )( j )( i ) .TauSite , 3 ) );
      ProtoClusterFlagsPlusEta( j )( i )( 4 )          <= TO_STD_LOGIC( ProtoClusterPipeIn( 0 )( j )( i ) .LateralPosition = west );
      ProtoClusterFlagsPlusEta( j )( i )( 3 )          <= ProtoClusterPipeIn( 0 )( j )( i ) .TrimmingFlags( 6 );
      ProtoClusterFlagsPlusEta( j )( i )( 2 )          <= ProtoClusterPipeIn( 0 )( j )( i ) .TrimmingFlags( 5 );
      ProtoClusterFlagsPlusEta( j )( i )( 1 )          <= TauSecondariesPipeIn( 0 )( j )( i ) .TrimmingFlags( 6 );
      ProtoClusterFlagsPlusEta( j )( i )( 0 )          <= TauSecondariesPipeIn( 0 )( j )( i ) .TrimmingFlags( 5 );

      ClusterFlagTrimLutInstance : ENTITY work.GenRomClocked
      GENERIC MAP(
        FileName => "P_TauTrimming_8to7.mif"
      )
      PORT MAP(
        clk       => Clk ,
        AddressIn => ProtoClusterFlagsPlusEta( j )( i )( 7 DOWNTO 0 ) ,
        DataOut   => DoubleCountingMask( j )( i )( 6 DOWNTO 0 )
      );

      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN
          TauProtoCluster( j )( i ) .Energy           <= ProtoClusterPipeIn( 0 )( j )( i ) .Energy;
          TauProtoCluster( j )( i ) .Phi              <= ProtoClusterPipeIn( 0 )( j )( i ) .Phi;
          TauProtoCluster( j )( i ) .Eta              <= ProtoClusterPipeIn( 0 )( j )( i ) .Eta;
          TauProtoCluster( j )( i ) .EtaHalf          <= ProtoClusterPipeIn( 0 )( j )( i ) .EtaHalf;
          TauProtoCluster( j )( i ) .LateralPosition  <= ProtoClusterPipeIn( 0 )( j )( i ) .LateralPosition;
          TauProtoCluster( j )( i ) .VerticalPosition <= ProtoClusterPipeIn( 0 )( j )( i ) .VerticalPosition;
          TauProtoCluster( j )( i ) .EgammaCandidate  <= ProtoClusterPipeIn( 0 )( j )( i ) .EgammaCandidate;
          TauProtoCluster( j )( i ) .HasEM            <= ProtoClusterPipeIn( 0 )( j )( i ) .HasEM;
          TauProtoCluster( j )( i ) .HasSeed          <= ProtoClusterPipeIn( 0 )( j )( i ) .HasSeed;
          TauProtoCluster( j )( i ) .Isolated         <= ProtoClusterPipeIn( 0 )( j )( i ) .Isolated;
          TauProtoCluster( j )( i ) .TauSite          <= ProtoClusterPipeIn( 0 )( j )( i ) .TauSite;
          TauProtoCluster( j )( i ) .DataValid        <= ProtoClusterPipeIn( 0 )( j )( i ) .DataValid;
        END IF;
      END PROCESS;

      TauProtoCluster( j )( i ) .TrimmingFlags <= ( ProtoClusterPipeIn( 1 )( j )( i ) .TrimmingFlags AND DoubleCountingMask( j )( i )( 6 DOWNTO 0 ) ) WHEN TauSecondariesPipeIn( 1 )( j )( i ) .HasSeed ELSE( ProtoClusterPipeIn( 1 )( j )( i ) .TrimmingFlags );

    END GENERATE eta;
  END GENERATE phi;


  ProtoClusterPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => TauProtoCluster ,
    ClusterPipe => TauProtoClusterPipeOut
  );

END ARCHITECTURE behavioral;
