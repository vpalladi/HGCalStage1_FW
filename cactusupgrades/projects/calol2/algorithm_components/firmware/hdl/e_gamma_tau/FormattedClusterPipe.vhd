--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;

--! @brief An entity providing a FormattedClusterPipe
--! @details Detailed description
ENTITY FormattedClusterPipe IS
  PORT(
    clk         : IN STD_LOGIC            := '0' ; --! The algorithm clock
    ClustersIn  : IN tGtFormattedClusters := cEmptyGtFormattedClusters;
    ClusterPipe : OUT tGtFormattedClusterPipe
  );
END FormattedClusterPipe;

--! @brief Architecture definition for entity FormattedClusterPipe
--! @details Detailed description
ARCHITECTURE behavioral OF FormattedClusterPipe IS
    SIGNAL ClusterPipeInternal : tGtFormattedClusterPipe( ClusterPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyGtFormattedClusters );
BEGIN

  ClusterPipeInternal( 0 ) <= ClustersIn ; -- since the data is clocked out , no need to clock it in as well...

  gTowerPipe : FOR i IN ClusterPipe'LENGTH-1 DOWNTO 1 GENERATE
    ClusterPipeInternal( i ) <= ClusterPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gTowerPipe;

  ClusterPipe <= ClusterPipeInternal;


END ARCHITECTURE behavioral;
