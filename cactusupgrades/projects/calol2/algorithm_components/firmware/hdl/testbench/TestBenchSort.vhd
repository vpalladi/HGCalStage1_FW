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
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;

--! Using the Calo-L2 "helper" helper functions
USE work.helper_functions.ALL;


--! @brief An entity providing a TestBenchSort
--! @details Detailed description
ENTITY TestBenchSort IS
END TestBenchSort;

--! @brief Architecture definition for entity TestBenchSort
--! @details Detailed description
ARCHITECTURE behavioral OF TestBenchSort IS

  SIGNAL clk              : STD_LOGIC                               := '1';

  SIGNAL inputJetPipe     : tJetPipe( 0 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL sort1JetPipe     : tJetPipe( 0 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL sort2JetPipe     : tJetPipe( 0 DOWNTO 0 )                  := ( OTHERS => cEmptyJetInEtaPhi );
  SIGNAL accumulationPipe : tAccumulationCompletePipe( 0 DOWNTO 0 ) := ( OTHERS => cEmptyAccumulationCompleteInEta );

BEGIN

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    clk <= NOT clk AFTER 4166 ps;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  references           : PROCESS( clk )
    VARIABLE clk_count : INTEGER := 0;
  BEGIN

    IF( RISING_EDGE( clk ) ) THEN
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
        FOR eta IN 0 TO cRegionInEta-1 LOOP
          inputJetPipe( 0 )( eta )( phi ) <= cEmptyJet;
        END LOOP;
      END LOOP;

      IF( clk_count = 0 ) THEN
        inputJetPipe( 0 )( 0 )( 5 ) .Energy  <= x"0088";
        inputJetPipe( 0 )( 0 )( 5 ) .Phi     <= 5;
        inputJetPipe( 0 )( 0 )( 5 ) .Eta     <= 1;

        inputJetPipe( 0 )( 0 )( 10 ) .Energy <= x"0080";
        inputJetPipe( 0 )( 0 )( 10 ) .Phi    <= 10;
        inputJetPipe( 0 )( 0 )( 10 ) .Eta    <= 1;

        inputJetPipe( 0 )( 0 )( 12 ) .Energy <= x"0008";
        inputJetPipe( 0 )( 0 )( 12 ) .Phi    <= 7;
        inputJetPipe( 0 )( 0 )( 12 ) .Eta    <= 1;

      FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
        FOR eta IN 0 TO cRegionInEta-1 LOOP
          inputJetPipe( 0 )( eta )( phi ) .DataValid <= TRUE;
        END LOOP;
      END LOOP;

      ELSIF( clk_count = 1 ) THEN
        inputJetPipe( 0 )( 0 )( 5 ) .Energy  <= x"0081";
        inputJetPipe( 0 )( 0 )( 5 ) .Phi     <= 6;
        inputJetPipe( 0 )( 0 )( 5 ) .Eta     <= 3;

        inputJetPipe( 0 )( 0 )( 10 ) .Energy <= x"0008";
        inputJetPipe( 0 )( 0 )( 10 ) .Phi    <= 11;
        inputJetPipe( 0 )( 0 )( 10 ) .Eta    <= 3;

        inputJetPipe( 0 )( 0 )( 12 ) .Energy <= x"0088";
        inputJetPipe( 0 )( 0 )( 12 ) .Phi    <= 8;
        inputJetPipe( 0 )( 0 )( 12 ) .Eta    <= 3;

        FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
          FOR eta IN 0 TO cRegionInEta-1 LOOP
            inputJetPipe( 0 )( eta )( phi ) .DataValid <= TRUE;
          END LOOP;
        END LOOP;

      ELSIF( clk_count = 2 ) THEN
        inputJetPipe( 0 )( 0 )( 5 ) .Energy  <= x"0081";
        inputJetPipe( 0 )( 0 )( 5 ) .Phi     <= 6;
        inputJetPipe( 0 )( 0 )( 5 ) .Eta     <= 3;

        inputJetPipe( 0 )( 0 )( 10 ) .Energy <= x"0001";
        inputJetPipe( 0 )( 0 )( 10 ) .Phi    <= 11;
        inputJetPipe( 0 )( 0 )( 10 ) .Eta    <= 3;

        inputJetPipe( 0 )( 0 )( 12 ) .Energy <= x"0001";
        inputJetPipe( 0 )( 0 )( 12 ) .Phi    <= 8;
        inputJetPipe( 0 )( 0 )( 12 ) .Eta    <= 3;

        FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
          FOR eta IN 0 TO cRegionInEta-1 LOOP
            inputJetPipe( 0 )( eta )( phi ) .DataValid <= TRUE;
          END LOOP;
        END LOOP;

      ELSE
        FOR phi IN 0 TO( cTowerInPhi / 4 ) -1 LOOP
          FOR eta IN 0 TO cRegionInEta-1 LOOP
            inputJetPipe( 0 )( eta )( phi ) .DataValid <= FALSE;
          END LOOP;
        END LOOP;
      END IF;

      clk_count := clk_count + 1;
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    END IF;
  END PROCESS;
-- =========================================================================================================================================================================================


-- ---------------------------------------------------------------------------------
-- Sort the jets in the phi-direction
  BitonicSortJetsInstance : ENTITY work.BitonicSortJetPipes
  GENERIC MAP(
    Size => 6
  )
  PORT MAP(
    clk               => clk ,
    filteredJetPipeIn => inputJetPipe ,
    sortedJetPipeOut  => sort1JetPipe
  );
-- ---------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------
-- Sort the jets in the eta-direction
  AccumulatingBitonicSortJetsInstance : ENTITY work.AccumulatingBitonicSortJetPipes
  GENERIC MAP(
    Size => 6
  )
  PORT MAP(
    clk                         => clk ,
    sortedJetPipeIn             => sort1JetPipe ,
    accumulatedSortedJetPipeOut => sort2JetPipe ,
    accumulationCompletePipeOut => accumulationPipe
  );
-- ---------------------------------------------------------------------------------



END ARCHITECTURE behavioral;
