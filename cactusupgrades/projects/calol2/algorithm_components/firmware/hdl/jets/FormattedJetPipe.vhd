--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;

--! @brief An entity providing a FormattedJetPipe
--! @details Detailed description
ENTITY FormattedJetPipe IS
  PORT(
    clk     : IN STD_LOGIC        := '0' ; --! The algorithm clock
    jetIn   : IN tGtFormattedJets := cEmptyGtFormattedJets;
    jetPipe : OUT tGtFormattedJetPipe
  );
END FormattedJetPipe;

--! @brief Architecture definition for entity FormattedJetPipe
--! @details Detailed description
ARCHITECTURE behavioral OF FormattedJetPipe IS
    SIGNAL jetPipeInternal : tGtFormattedJetPipe( jetPipe'LENGTH-1 DOWNTO 0 ) := ( OTHERS => cEmptyGtFormattedJets );
BEGIN

  jetPipeInternal( 0 ) <= jetIn ; -- since the data is clocked out , no need to clock it in as well...

  gTowerPipe : FOR i IN jetPipe'LENGTH-1 DOWNTO 1 GENERATE
    jetPipeInternal( i ) <= jetPipeInternal( i-1 ) WHEN RISING_EDGE( clk );
  END GENERATE gTowerPipe;

  jetPipe <= jetPipeInternal;


END ARCHITECTURE behavioral;
