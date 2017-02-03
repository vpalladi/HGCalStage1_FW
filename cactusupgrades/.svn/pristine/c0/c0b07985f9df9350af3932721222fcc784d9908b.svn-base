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
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;



--! @brief An entity providing a JetLinkPacker
--! @details Detailed description
ENTITY JetLinkPacker IS
  PORT(
    clk                           : IN STD_LOGIC := '0' ;          --! The algorithm clock
    accumulatedSortedJetPipeIn    : IN tJetPipe ;                  --! A pipe of tJet objects bringing in the accumulatedSortedJet's
    jetAccumulationCompletePipeIn : IN tAccumulationCompletePipe ; --! A pipe of tAccumulationComplete objects bringing in the jetAccumulationComplete's
    PackedJetPipeOut              : OUT tPackedLinkPipe            --! A pipe of tPackedLink objects passing out the PackedJet's
  );
END JetLinkPacker;

--! @brief Architecture definition for entity JetLinkPacker
--! @details Detailed description
ARCHITECTURE behavioral OF JetLinkPacker IS
  SIGNAL Jets : tPackedLinkInCandidates := cEmptyPackedLinkInCandidates;
BEGIN


  eta          : FOR j IN 0 TO cRegionInEta-1 GENERATE
    candidates : FOR i IN 5 DOWNTO 0 GENERATE
      Jets( ( 6 * j ) + i ) .Data <= "00" & TO_STD_LOGIC( accumulatedSortedJetPipeIn( 0 )( j )( i ) .LargePileUp ) &
                                            STD_LOGIC_VECTOR( accumulatedSortedJetPipeIn( 0 )( j )( i ) .Energy ) &
                                            STD_LOGIC_VECTOR( TO_UNSIGNED( accumulatedSortedJetPipeIn( 0 )( j )( i ) .Phi , 7 ) ) &
                                            STD_LOGIC_VECTOR( TO_UNSIGNED( accumulatedSortedJetPipeIn( 0 )( j )( i ) .Eta , 6 ) );

      Jets( ( 6 * j ) + i ) .AccumulationComplete <= jetAccumulationCompletePipeIn( 0 )( j );

      Jets( ( 6 * j ) + i ) .DataValid            <= accumulatedSortedJetPipeIn( 0 )( j )( i ) .DataValid;

    END GENERATE candidates;
  END GENERATE eta;

  PackedLinkPipeInstance : ENTITY work.PackedLinkPipe
  PORT MAP(
    clk            => clk ,
    PackedLinkIn   => Jets ,
    PackedLinkPipe => PackedJetPipeOut
  );

END ARCHITECTURE behavioral;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;


--! @brief An entity providing a JetLinkPacker
--! @details Detailed description
ENTITY JetLinkUnpacker IS
  PORT(
    clk          : IN STD_LOGIC    := '0' ; --! The algorithm clock
    PackedJetsIn : tWordArrayInEta := cEmptyWordArrayInEta;
    JetPipeOut   : OUT tJetPipe --! A pipe of tJet objects bringing in the accumulatedSortedJet's
  );
END JetLinkUnpacker;

--! @brief Architecture definition for entity JetLinkPacker
--! @details Detailed description
ARCHITECTURE behavioral OF JetLinkUnpacker IS
  SIGNAL Jets : tJetInEtaPhi := cEmptyJetInEtaPhi;
BEGIN

-- ------------------------------------------------------------------------------------
  eta_half     : FOR j IN 0 TO 1 GENERATE
    candidates : FOR i IN 0 TO 5 GENERATE
      Jets( j )( i ) .LargePileUp <= PackedJetsIn( j )( i ) .data( 29 ) = '1';
      Jets( j )( i ) .Energy      <= UNSIGNED( PackedJetsIn( j )( i ) .data( 28 DOWNTO 13 ) );
      Jets( j )( i ) .Phi         <= TO_INTEGER( UNSIGNED( PackedJetsIn( j )( i ) .data( 12 DOWNTO 6 ) ) );
      Jets( j )( i ) .Eta         <= TO_INTEGER( UNSIGNED( PackedJetsIn( j )( i ) .data( 5 DOWNTO 0 ) ) );
      Jets( j )( i ) .EtaHalf     <= j;
      Jets( j )( i ) .DataValid   <= PackedJetsIn( j )( i ) .valid = '1';
    END GENERATE candidates;
  END GENERATE eta_half;
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  JetPipeInstance : ENTITY work.JetPipe
  PORT MAP(
    clk     => clk ,
    jetIn   => Jets ,
    jetPipe => JetPipeOut
  );
-- ------------------------------------------------------------------------------------
END ARCHITECTURE behavioral;


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;



--! @brief An entity providing a DemuxJetLinkPacker
--! @details Detailed description
ENTITY DemuxJetLinkPacker IS
  PORT(
    clk                  : IN STD_LOGIC := '0' ;    --! The algorithm clock
    gtFormattedJetPipeIn : IN tGtFormattedJetPipe ; --! A pipe of tGtFormattedJet objects bringing in the gtFormattedJet's
    PackedJetPipeOut     : OUT tPackedLinkPipe      --! A pipe of tPackedLink objects passing out the PackedJet's
  );
END DemuxJetLinkPacker;

--! @brief Architecture definition for entity DemuxJetLinkPacker
--! @details Detailed description
ARCHITECTURE behavioral OF DemuxJetLinkPacker IS
  SIGNAL Jets : tPackedLinkInCandidates := cEmptyPackedLinkInCandidates;
BEGIN


  candidates : FOR i IN 11 DOWNTO 0 GENERATE
    Jets( i ) .Data <= "00000" &
                        STD_LOGIC_VECTOR( gtFormattedJetPipeIn( 0 )( i ) .Phi ) &
                        STD_LOGIC_VECTOR( gtFormattedJetPipeIn( 0 )( i ) .Eta ) &
                        STD_LOGIC_VECTOR( gtFormattedJetPipeIn( 0 )( i ) .Energy );
    Jets( i ) .DataValid <= gtFormattedJetPipeIn( 0 )( i ) .DataValid;
  END GENERATE candidates;

  PackedLinkPipeInstance : ENTITY work.PackedLinkPipe
  PORT MAP(
    clk            => clk ,
    PackedLinkIn   => Jets ,
    PackedLinkPipe => PackedJetPipeOut
  );

END ARCHITECTURE behavioral;
