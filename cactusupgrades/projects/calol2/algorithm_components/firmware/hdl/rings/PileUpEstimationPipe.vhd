--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;


--! @brief An entity providing a PileupEstimationPipe
--! @details Detailed description
ENTITY PileupEstimationPipe IS
  PORT(
    clk                  : IN STD_LOGIC                 := '0' ; --! The algorithm clock
    PileupEstimationIn   : IN tPileupEstimationInEtaPhi := cEmptyPileupEstimationInEtaPhi;
    PileupEstimationPipe : OUT tPileupEstimationPipe
  );
END PileupEstimationPipe;


--! @brief Architecture definition for entity PileupEstimationPipe
--! @details Detailed description
ARCHITECTURE behavioral OF PileupEstimationPipe IS
    SIGNAL PileupEstimationPipeInternal : tPileupEstimationPipe( PileupEstimationPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyPileupEstimationInEtaPhi );
BEGIN

  PileupEstimationPipeInternal( 0 ) <= PileupEstimationIn ; -- since the data is clocked out , no need to clock it in as well...

  gPileupEstimationPipe : FOR i IN PileupEstimationPipe'LENGTH-1 DOWNTO 1 GENERATE
    PileupEstimationPipeInternal( i ) <= PileupEstimationPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gPileupEstimationPipe;

  PileupEstimationPipe <= PileupEstimationPipeInternal;


END ARCHITECTURE behavioral;




--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;


--! @brief An entity providing a PileupEstimationPipe2
--! @details Detailed description
ENTITY PileupEstimationPipe2 IS
  PORT(
    clk                  : IN STD_LOGIC         := '0' ; --! The algorithm clock
    PileupEstimationIn   : IN tPileupEstimation := cEmptyPileupEstimation;
    PileupEstimationPipe : OUT tPileupEstimationPipe2
  );
END PileupEstimationPipe2;


--! @brief Architecture definition for entity PileupEstimationPipe2
--! @details Detailed description
ARCHITECTURE behavioral OF PileupEstimationPipe2 IS
    SIGNAL PileupEstimationPipeInternal : tPileupEstimationPipe2( PileupEstimationPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyPileupEstimation );
BEGIN

  PileupEstimationPipeInternal( 0 ) <= PileupEstimationIn ; -- since the data is clocked out , no need to clock it in as well...

  gPileupEstimationPipe : FOR i IN PileupEstimationPipe'LENGTH-1 DOWNTO 1 GENERATE
    PileupEstimationPipeInternal( i ) <= PileupEstimationPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gPileupEstimationPipe;

  PileupEstimationPipe <= PileupEstimationPipeInternal;


END ARCHITECTURE behavioral;
