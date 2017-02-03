--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! @brief An entity providing a MaximaPipe
--! @details Detailed description
ENTITY MaximaPipe IS
  PORT(
    clk        : IN STD_LOGIC       := '0' ; --! The algorithm clock
    MaximaIn   : IN tMaximaInEtaPhi := cEmptyMaximaInEtaPhi;
    MaximaPipe : OUT tMaximaPipe
  );
END MaximaPipe;

--! @brief Architecture definition for entity MaximaPipe
--! @details Detailed description
ARCHITECTURE behavioral OF MaximaPipe IS
    SIGNAL MaximaPipeInternal : tMaximaPipe( MaximaPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyMaximaInEtaPhi );
BEGIN

  MaximaPipeInternal( 0 ) <= MaximaIn ; -- since the data is clocked out , no need to clock it in as well...

  gTowerPipe : FOR i IN MaximaPipe'LENGTH-1 DOWNTO 1 GENERATE
    MaximaPipeInternal( i ) <= MaximaPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gTowerPipe;

  MaximaPipe <= MaximaPipeInternal;


END ARCHITECTURE behavioral;
