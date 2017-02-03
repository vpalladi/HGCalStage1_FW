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

--! @brief An entity providing a EgammaClusterTrimming
--! @details Detailed description
ENTITY EgammaClusterTrimming IS
  PORT(
    clk                       : IN STD_LOGIC := '0' ; --! The algorithm clock
    ProtoClusterPipeIn        : IN tClusterPipe ;     --! A pipe of tCluster objects bringing in the ProtoCluster's
    EgammaProtoClusterPipeOut : OUT tClusterPipe      --! A pipe of tCluster objects passing out the EgammaProtoCluster's
  );
END ENTITY EgammaClusterTrimming;


--! @brief Architecture definition for entity EgammaClusterTrimming
--! @details Detailed description
ARCHITECTURE behavioral OF EgammaClusterTrimming IS
  SIGNAL EgammaProtoCluster : tClusterInEtaPhi := cEmptyClusterInEtaPhi;

  TYPE tVectorInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF STD_LOGIC_VECTOR( 11 DOWNTO 0 );
  TYPE tVectorInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tVectorInPhi;
  SIGNAL ProtoClusterFlagsPlusEta : tVectorInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL ClusterShapeFlags        : tVectorInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );

BEGIN

  phi   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE

      ProtoClusterFlagsPlusEta( j )( i )( 11 DOWNTO 7 ) <= STD_LOGIC_VECTOR( TO_UNSIGNED( ProtoClusterPipeIn( 0 )( j )( i ) .Eta , 5 ) );
      ProtoClusterFlagsPlusEta( j )( i )( 6 DOWNTO 0 )  <= ProtoClusterPipeIn( 0 )( j )( i ) .TrimmingFlags( 6 DOWNTO 0 );

      ClusterFlagTrimLutInstance : ENTITY work.GenRomClocked
      GENERIC MAP(
        FileName => "N_EgammaTrimming_12to7.mif"
      )
      PORT MAP(
        clk       => Clk ,
        AddressIn => ProtoClusterFlagsPlusEta( j )( i )( 11 DOWNTO 0 ) ,
        DataOut   => EgammaProtoCluster( j )( i ) .TrimmingFlags
      );

-- ----------------------------------------------------------------------
      ClusterShapeFlags( j )( i )( 7 )          <= '1' WHEN ProtoClusterPipeIn( 0 )( j )( i ) .LateralPosition = West ELSE '0';
      ClusterShapeFlags( j )( i )( 6 DOWNTO 0 ) <= ProtoClusterPipeIn( 0 )( j )( i ) .TrimmingFlags( 6 DOWNTO 0 );

      ClusterFlagCompressionLutInstance : ENTITY work.GenRomClocked
      GENERIC MAP(
        FileName => "O_EgammaShapeFlags_8to4.mif"
      )
      PORT MAP(
        clk       => Clk ,
        AddressIn => ClusterShapeFlags( j )( i )( 7 DOWNTO 0 ) ,
        DataOut   => EgammaProtoCluster( j )( i ) .ShapeFlags
      );
-- ----------------------------------------------------------------------


      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN
          EgammaProtoCluster( j )( i ) .Energy           <= ProtoClusterPipeIn( 0 )( j )( i ) .Energy;
          EgammaProtoCluster( j )( i ) .Phi              <= ProtoClusterPipeIn( 0 )( j )( i ) .Phi;
          EgammaProtoCluster( j )( i ) .Eta              <= ProtoClusterPipeIn( 0 )( j )( i ) .Eta;
          EgammaProtoCluster( j )( i ) .EtaHalf          <= ProtoClusterPipeIn( 0 )( j )( i ) .EtaHalf;
          EgammaProtoCluster( j )( i ) .LateralPosition  <= ProtoClusterPipeIn( 0 )( j )( i ) .LateralPosition;
          EgammaProtoCluster( j )( i ) .VerticalPosition <= ProtoClusterPipeIn( 0 )( j )( i ) .VerticalPosition;
          EgammaProtoCluster( j )( i ) .EgammaCandidate  <= ProtoClusterPipeIn( 0 )( j )( i ) .EgammaCandidate;
          EgammaProtoCluster( j )( i ) .HasEM            <= ProtoClusterPipeIn( 0 )( j )( i ) .HasEM;
          EgammaProtoCluster( j )( i ) .HasSeed          <= ProtoClusterPipeIn( 0 )( j )( i ) .HasSeed;
          EgammaProtoCluster( j )( i ) .Isolated         <= ProtoClusterPipeIn( 0 )( j )( i ) .Isolated;
          EgammaProtoCluster( j )( i ) .TauSite          <= ProtoClusterPipeIn( 0 )( j )( i ) .TauSite;
          EgammaProtoCluster( j )( i ) .DataValid        <= ProtoClusterPipeIn( 0 )( j )( i ) .DataValid;
        END IF;
      END PROCESS;

    END GENERATE eta;
  END GENERATE phi;


  ProtoClusterPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => EgammaProtoCluster ,
    ClusterPipe => EgammaProtoClusterPipeOut
  );

END ARCHITECTURE behavioral;
