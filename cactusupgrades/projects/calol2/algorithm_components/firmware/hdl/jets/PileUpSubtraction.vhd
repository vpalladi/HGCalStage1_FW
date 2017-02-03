--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;

--! @brief An entity providing a PileUpSubtraction
--! @details Detailed description
ENTITY PileUpSubtraction IS
  GENERIC(
    filteredJetPipeOffset : INTEGER := 0
  );
  PORT(
    clk                        : IN STD_LOGIC := '0' ; --! The algorithm clock
    filteredJetPipeIn          : IN tJetPipe ;         --! A pipe of tJet objects bringing in the filteredJet's
    filteredPileUpPipeIn       : IN tJetPipe ;         --! A pipe of tJet objects bringing in the filteredPileUp's
    pileUpSubtractedJetPipeOut : OUT tJetPipe          --! A pipe of tJet objects passing out the pileUpSubtractedJet's
  );
END PileUpSubtraction;

--! @brief Architecture definition for entity PileUpSubtraction
--! @details Detailed description
ARCHITECTURE behavioral OF PileUpSubtraction IS
  SIGNAL pileUpSubtractedJetInEtaPhi : tJetInEtaPhi := cEmptyJetInEtaPhi;
BEGIN

  phi   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

      PROCESS( clk )
        VARIABLE lEnergy : INTEGER := 0;
      BEGIN

        IF( RISING_EDGE( clk ) ) THEN
          IF( NOT filteredJetPipeIn( filteredJetPipeOffset )( j )( i ) .DataValid OR NOT filteredPileUpPipeIn( 0 )( j )( i ) .DataValid ) THEN
            pileUpSubtractedJetInEtaPhi( j )( i ) <= cEmptyJet;
          ELSE
            lEnergy := TO_INTEGER( filteredJetPipeIn( filteredJetPipeOffset )( j )( i ) .Energy ) - TO_INTEGER( filteredPileUpPipeIn( 0 )( j )( i ) .Energy );
            IF( lEnergy >= 0 ) THEN
              pileUpSubtractedJetInEtaPhi( j )( i ) .Energy( 15 DOWNTO 0 ) <= TO_UNSIGNED( lEnergy , 16 );
            ELSE
              pileUpSubtractedJetInEtaPhi( j )( i ) .Energy( 15 DOWNTO 0 ) <= ( OTHERS => '0' );
            END IF;

-- Flag if PileUp estimation > 25% Jet Energy
            IF( filteredPileUpPipeIn( 0 )( j )( i ) .Energy > filteredJetPipeIn( filteredJetPipeOffset )( j )( i ) .Energy( 15 DOWNTO 2 ) ) THEN
              pileUpSubtractedJetInEtaPhi( j )( i ) .LargePileUp <= TRUE;
            ELSE
              pileUpSubtractedJetInEtaPhi( j )( i ) .LargePileUp <= FALSE;
            END IF;

            pileUpSubtractedJetInEtaPhi( j )( i ) .Eta       <= filteredJetPipeIn( filteredJetPipeOffset )( j )( i ) .Eta;
            pileUpSubtractedJetInEtaPhi( j )( i ) .Phi       <= filteredJetPipeIn( filteredJetPipeOffset )( j )( i ) .Phi;
            pileUpSubtractedJetInEtaPhi( j )( i ) .DataValid <= TRUE;
          END IF;
        END IF;

      END PROCESS;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta;
  END GENERATE phi;

  JetPipeInstance : ENTITY work.JetPipe
  PORT MAP(
    clk     => clk ,
    jetIn   => pileUpSubtractedJetInEtaPhi ,
    jetPipe => pileUpSubtractedJetPipeOut
  );

END ARCHITECTURE behavioral;
