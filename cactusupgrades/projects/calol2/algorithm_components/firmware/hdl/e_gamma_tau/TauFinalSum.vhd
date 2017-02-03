
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

--! @brief An entity providing a TauFinalSum
--! @details Detailed description
ENTITY TauFinalSum IS
  GENERIC(
    TauSecondaryPipeOffset : INTEGER := 0
  );
  PORT(
    clk                : IN STD_LOGIC := '0' ; --! The algorithm clock
    TauPrimaryPipeIn   : IN tClusterPipe ;     --! A pipe of tCluster objects bringing in the TauPrimary's
    TauSecondaryPipeIn : IN tClusterPipe ;     --! A pipe of tCluster objects bringing in the TauSecondary's
    FinalTauPipeOut    : OUT tClusterPipe      --! A pipe of tCluster objects passing out the FinalTau's
  );
END ENTITY TauFinalSum;


--! @brief Architecture definition for entity TauFinalSum
--! @details Detailed description
ARCHITECTURE behavioral OF TauFinalSum IS
  SIGNAL ClusterSums : tClusterInEtaPhi := cEmptyClusterInEtaPhi;
BEGIN

  phi                    : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta                  : FOR j IN 0 TO cRegionInEta-1 GENERATE

      ClusterSumInstance : ENTITY work.ClusterSum2
      PORT MAP(
        Clk        => Clk ,
        ClusterIn1 => TauSecondaryPipeIn( TauSecondaryPipeOffset )( j )( i ) ,
        ClusterIn2 => TauPrimaryPipeIn( 0 )( j )( i ) ,
        ClusterOut => ClusterSums( j )( i )
      );

    END GENERATE eta;
  END GENERATE phi;

  ClusterPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => ClusterSums ,
    ClusterPipe => FinalTauPipeOut
  );

END ARCHITECTURE behavioral;
