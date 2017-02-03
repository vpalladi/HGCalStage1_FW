--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;


--! @brief An entity providing a ClusterPipe
--! @details Detailed description
ENTITY ClusterPipe IS
  PORT(
    clk         : IN STD_LOGIC        := '0' ; --! The algorithm clock
    ClusterIn   : IN tClusterInEtaPhi := cEmptyClusterInEtaPhi;
    ClusterPipe : OUT tClusterPipe
  );
END ClusterPipe;


--! @brief Architecture definition for entity ClusterPipe
--! @details Detailed description
ARCHITECTURE behavioral OF ClusterPipe IS
    SIGNAL ClusterPipeInternal : tClusterPipe( ClusterPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyClusterInEtaPhi );
BEGIN

  ClusterPipeInternal( 0 ) <= ClusterIn ; -- since the data is clocked out , no need to clock it in as well...

  gClusterPipe : FOR i IN ClusterPipe'LENGTH-1 DOWNTO 1 GENERATE
    ClusterPipeInternal( i ) <= ClusterPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gClusterPipe;

  ClusterPipe <= ClusterPipeInternal;


END ARCHITECTURE behavioral;
