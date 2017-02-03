--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;
--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! @brief An entity providing a MaximaFinder9x3
--! @details Detailed description
ENTITY MaximaFinder9x3 IS
  GENERIC(
    Offset : INTEGER := 0
  );
  PORT(
    clk                  : IN STD_LOGIC := '0' ; --! The algorithm clock
    Maxima3x3PipeIn      : IN tMaximaPipe ;      --! A pipe of tMaxima objects bringing in the Maxima3x3's
    maxima9x3PipeOut     : OUT tMaximaPipe ;     --! A pipe of tMaxima objects passing out the maxima9x3's
    MaximaFlag9x3PipeOut : OUT tComparisonPipe   --! A pipe of tComparison objects passing out the MaximaFlag9x3's
  );
END MaximaFinder9x3;

--! @brief Architecture definition for entity MaximaFinder9x3
--! @details Detailed description
ARCHITECTURE behavioral OF MaximaFinder9x3 IS

  TYPE tSelectionInPhi    IS ARRAY( 0 TO cTowerInPhi-1 ) OF INTEGER RANGE 0 TO 2 ; -- cTowerInPhi wide
  TYPE tSelectionInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tSelectionInPhi ; -- Two halves in eta

-- ------------------------------------------------------------------------------
-- comparisons for convenience
  SIGNAL comparisonPhiPlus3InEtaPhi , comparisonPhiPlus6InEtaPhi : tComparisonInEtaPhi;

-- 9x3 maxima and pipe
  SIGNAL maxima9x3InEtaPhi                                       : tMaximaInEtaPhi     := cEmptyMaximaInEtaPhi;

-- 9x3 maxima flag which will be output
  SIGNAL maximaflag9x3InEtaPhi                                   : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;
-- ------------------------------------------------------------------------------


BEGIN

  phi   : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      PROCESS( clk )
      BEGIN

        IF( RISING_EDGE( clk ) ) THEN

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Perform the comparisons for the 9x3 region
-- We are using this as a tool of convenience , DataValid handled by the select function
            comparisonPhiPlus3InEtaPhi( j )( i ) .Data <= ( maxima3x3PipeIn( Offset + 0 )( j )( i ) .Max > maxima3x3PipeIn( Offset + 0 )( j )( MOD_PHI( i + 3 ) ) .Max );
            comparisonPhiPlus6InEtaPhi( j )( i ) .Data <= ( maxima3x3PipeIn( Offset + 0 )( j )( i ) .Max > maxima3x3PipeIn( Offset + 0 )( j )( MOD_PHI( i + 6 ) ) .Max );
-- End of the comparisons for the 9x3 region
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--IF( NOT maxima3x3PipeIn( Offset + 1 )( j )( MOD_PHI( i + 0 ) ) .DataValid
-- OR NOT maxima3x3PipeIn( Offset + 1 )( j )( MOD_PHI( i + 3 ) ) .DataValid
-- OR NOT maxima3x3PipeIn( Offset + 1 )( j )( MOD_PHI( i + 6 ) ) .DataValid ) THEN
-- maxima9x3InEtaPhi( j )( i ) <= cEmptyMaxima;
--ELSE
-- Select the maxima for the 9x3 region
            IF( comparisonPhiPlus6InEtaPhi( j )( i ) .Data AND comparisonPhiPlus3InEtaPhi( j )( i ) .Data ) THEN
-- Sel = 0
              maxima9x3InEtaPhi( j )( i ) .Eta <= maxima3x3PipeIn( Offset + 1 )( j )( MOD_PHI( i + 0 ) ) .Eta;
              maxima9x3InEtaPhi( j )( i ) .Phi <= maxima3x3PipeIn( Offset + 1 )( j )( MOD_PHI( i + 0 ) ) .Phi;
              maxima9x3InEtaPhi( j )( i ) .Max <= maxima3x3PipeIn( Offset + 1 )( j )( MOD_PHI( i + 0 ) ) .Max;
            ELSIF( ( comparisonPhiPlus3InEtaPhi( j )( MOD_PHI( i + 3 ) ) .Data ) AND NOT( comparisonPhiPlus3InEtaPhi( j )( i ) .Data ) ) THEN
-- Sel = 1
              maxima9x3InEtaPhi( j )( i ) .Eta <= maxima3x3PipeIn( Offset + 1 )( j )( MOD_PHI( i + 3 ) ) .Eta;
              maxima9x3InEtaPhi( j )( i ) .Phi <= maxima3x3PipeIn( Offset + 1 )( j )( MOD_PHI( i + 3 ) ) .Phi + 3;
              maxima9x3InEtaPhi( j )( i ) .Max <= maxima3x3PipeIn( Offset + 1 )( j )( MOD_PHI( i + 3 ) ) .Max;
            ELSE
-- Sel = 2
              maxima9x3InEtaPhi( j )( i ) .Eta <= maxima3x3PipeIn( Offset + 1 )( j )( MOD_PHI( i + 6 ) ) .Eta;
              maxima9x3InEtaPhi( j )( i ) .Phi <= maxima3x3PipeIn( Offset + 1 )( j )( MOD_PHI( i + 6 ) ) .Phi + 6;
              maxima9x3InEtaPhi( j )( i ) .Max <= maxima3x3PipeIn( Offset + 1 )( j )( MOD_PHI( i + 6 ) ) .Max;
            END IF;
            maxima9x3InEtaPhi( j )( i ) .DataValid <= maxima3x3PipeIn( Offset + 1 )( j )( MOD_PHI( i + 3 ) ) .DataValid ; --TRUE;
-- End of select the maxima for the 9x3 region
--END IF;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- When getting rid of the JetCentreOffset constant , the choice was to
-- swap the inputs from + 3 , + 6 to -3 , + 3 and change the logic accordingly <<< OR >>> just add the phi offset here.
-- I chose the latter
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          IF( NOT maxima9x3InEtaPhi( j )( i ) .DataValid ) THEN
            maximaflag9x3InEtaPhi( j )( MOD_PHI( i + 4 ) ) <= cEmptyComparison;
          ELSE
-- Final comparison for the 9x3 region
            maximaflag9x3InEtaPhi( j )( MOD_PHI( i + 4 ) ) .Data      <= ( ( maxima9x3InEtaPhi( j )( i ) .Eta /= 1 ) OR( maxima9x3InEtaPhi( j )( i ) .Phi /= 4 ) );
            maximaflag9x3InEtaPhi( j )( MOD_PHI( i + 4 ) ) .DataValid <= TRUE;
-- End of final comparison for the 9x3 region
          END IF;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        END IF;
      END PROCESS;
    END GENERATE eta;
  END GENERATE phi;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  Strip9x3PipeInstance : ENTITY work.MaximaPipe
  PORT MAP(
    clk        => clk ,
    MaximaIn   => maxima9x3InEtaPhi ,
    MaximaPipe => maxima9x3PipeOut
  );

  MaximaFlag9x3PipeInstance : ENTITY work.ComparisonPipe
  PORT MAP(
    clk            => clk ,
    ComparisonIn   => maximaflag9x3InEtaPhi ,
    ComparisonPipe => MaximaFlag9x3PipeOut
  );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

END ARCHITECTURE behavioral;
