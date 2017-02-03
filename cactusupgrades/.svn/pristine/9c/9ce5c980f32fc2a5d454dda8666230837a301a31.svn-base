--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;


--! @brief An entity providing a IsolationPipe
--! @details Detailed description
ENTITY IsolationPipe IS
  PORT(
    clk           : IN STD_LOGIC                := '0' ; --! The algorithm clock
    IsolationIn   : IN tIsolationRegionInEtaPhi := cEmptyIsolationRegionInEtaPhi;
    IsolationPipe : OUT tIsolationRegionPipe
  );
END IsolationPipe;


--! @brief Architecture definition for entity IsolationPipe
--! @details Detailed description
ARCHITECTURE behavioral OF IsolationPipe IS
    SIGNAL IsolationPipeInternal : tIsolationRegionPipe( IsolationPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyIsolationRegionInEtaPhi );
BEGIN

  IsolationPipeInternal( 0 ) <= IsolationIn ; -- since the data is clocked out , no need to clock it in as well...

  gIsolationPipe : FOR i IN IsolationPipe'LENGTH-1 DOWNTO 1 GENERATE
    IsolationPipeInternal( i ) <= IsolationPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gIsolationPipe;

  IsolationPipe <= IsolationPipeInternal;


END ARCHITECTURE behavioral;
