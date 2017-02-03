--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;


--! @brief An entity providing a ClusterInputPipe
--! @details Detailed description
ENTITY ClusterInputPipe IS
  PORT(
    clk              : IN STD_LOGIC             := '0' ; --! The algorithm clock
    ClusterInputIn   : IN tClusterInputInEtaPhi := cEmptyClusterInputInEtaPhi;
    ClusterInputPipe : OUT tClusterInputPipe
  );
END ClusterInputPipe;


--! @brief Architecture definition for entity ClusterInputPipe
--! @details Detailed description
ARCHITECTURE behavioral OF ClusterInputPipe IS
    SIGNAL ClusterInputPipeInternal : tClusterInputPipe( ClusterInputPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyClusterInputInEtaPhi );
BEGIN

  ClusterInputPipeInternal( 0 ) <= ClusterInputIn ; -- since the data is clocked out , no need to clock it in as well...

  gClusterInputPipe : FOR i IN ClusterInputPipe'LENGTH-1 DOWNTO 1 GENERATE
    ClusterInputPipeInternal( i ) <= ClusterInputPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gClusterInputPipe;

  ClusterInputPipe <= ClusterInputPipeInternal;


END ARCHITECTURE behavioral;
