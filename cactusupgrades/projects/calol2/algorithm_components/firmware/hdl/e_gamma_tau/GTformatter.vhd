--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;
--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "Cluster" helper functions
USE work.Cluster_functions.ALL;
--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;

--! @brief An entity providing a GtClusterFormatter
--! @details Detailed description
ENTITY GtClusterFormatter IS
  PORT(
    clk            : IN STD_LOGIC := '0' ;       --! The algorithm clock
    ClusterPipeIn  : IN tClusterPipe ;           --! A pipe of tCluster objects bringing in the Cluster's
    ClusterPipeOut : OUT tGtFormattedClusterPipe --! A pipe of tGtFormattedCluster objects passing out the Cluster's
  );
END GtClusterFormatter;

--! @brief Architecture definition for entity GtClusterFormatter
--! @details Detailed description
ARCHITECTURE behavioral OF GtClusterFormatter IS
  SIGNAL GtFormattedClusters : tGtFormattedClusters := cEmptyGtFormattedClusters;

  TYPE tVectorInCandidates IS ARRAY( 11 DOWNTO 0 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );
  SIGNAL LocalEtaIn , GtEtaOut : tVectorInCandidates := ( OTHERS => ( OTHERS => '0' ) );
  SIGNAL LocalPhiIn , GtPhiOut : tVectorInCandidates := ( OTHERS => ( OTHERS => '0' ) );

BEGIN


candidates : FOR i IN 11 DOWNTO 0 GENERATE

  LocalEtaIn( i )( 8 DOWNTO 0 ) <= STD_LOGIC_VECTOR( TO_UNSIGNED( ClusterPipeIn( 0 )( 0 )( i ) .EtaHalf , 1 ) )
                                & STD_LOGIC_VECTOR( TO_UNSIGNED( ClusterPipeIn( 0 )( 0 )( i ) .Eta , 6 ) )
                                & encodeLateralPosition( ClusterPipeIn( 0 )( 0 )( i ) .LateralPosition );

  EtaLutInstance : ENTITY work.GenRomClocked
  GENERIC MAP(
    FileName => "Y_localEtaToGT_9to8.mif"
  )
  PORT MAP(
    clk       => clk ,
    AddressIn => LocalEtaIn( i )( 8 DOWNTO 0 ) ,
    DataOut   => GtEtaOut( i )( 7 DOWNTO 0 )
  );

  GtFormattedClusters( i ) .Eta <= SIGNED( GtEtaOut( i )( 7 DOWNTO 0 ) );

  LocalPhiIn( i )( 8 DOWNTO 0 ) <= STD_LOGIC_VECTOR( TO_UNSIGNED( ClusterPipeIn( 0 )( 0 )( i ) .Phi , 7 ) )
                                 & encodeVerticalPosition( ClusterPipeIn( 0 )( 0 )( i ) .VerticalPosition );

  PhiLutInstance : ENTITY work.GenRomClocked
  GENERIC MAP(
    FileName => "Z_localPhiToGT_9to8.mif"
  )
  PORT MAP(
    clk       => clk ,
    AddressIn => LocalPhiIn( i )( 8 DOWNTO 0 ) ,
    DataOut   => GtPhiOut( i )( 7 DOWNTO 0 )
  );

  GtFormattedClusters( i ) .Phi <= UNSIGNED( GtPhiOut( i )( 7 DOWNTO 0 ) );

  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN

      IF( ClusterPipeIn( 0 )( 0 )( i ) .Energy > x"01FF" ) THEN
        GtFormattedClusters( i ) .Energy <= ( OTHERS => '1' );
      ELSE
        GtFormattedClusters( i ) .Energy <= ClusterPipeIn( 0 )( 0 )( i ) .Energy( 8 DOWNTO 0 );
      END IF;

      GtFormattedClusters( i ) .Isolated2 <= ClusterPipeIn( 0 )( 0 )( i ) .Isolated2;
      GtFormattedClusters( i ) .Isolated  <= ClusterPipeIn( 0 )( 0 )( i ) .Isolated;
      GtFormattedClusters( i ) .DataValid <= ClusterPipeIn( 0 )( 0 )( i ) .DataValid;
    END IF;
  END PROCESS;
END GENERATE;


  ClusterPipeInstance : ENTITY work.FormattedClusterPipe
  PORT MAP(
    clk         => clk ,
    ClustersIn  => GtFormattedClusters ,
    ClusterPipe => ClusterPipeOut
  );

END ARCHITECTURE behavioral;
