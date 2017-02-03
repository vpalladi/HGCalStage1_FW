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

--! Using the Calo-L2 "ring" helper functions
USE work.ring_functions.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! @brief An entity providing a MHTcoefficients
--! @details Detailed description
ENTITY MHTcoefficients IS
  GENERIC(
    jetVetoPipeOffset : INTEGER := 0 -- Offset for the Veto Pipe
  );
  PORT(
    clk                   : IN STD_LOGIC := '0' ;   --! The algorithm clock
    jetVetoPipeIn         : IN tComparisonPipe ;    --! A pipe of tComparison objects bringing in the jetVeto's
    MHTcoefficientPipeOut : OUT tMHTcoefficientPipe --! A pipe of tMHTcoefficient objects passing out the MHTcoefficient's
  );
END MHTcoefficients;

--! @brief Architecture definition for entity MHTcoefficients
--! @details Detailed description
ARCHITECTURE behavioral OF MHTcoefficients IS
  SIGNAL MHTcoefficientInEtaPhi : tMHTcoefficientInEtaPhi := cEmptyMHTcoefficientInEtaPhi;
BEGIN

  phi   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN

          IF( NOT jetVetoPipeIn( jetVetoPipeOffset )( j )( ( 4 * i ) + 0 ) .Data ) THEN
            MHTcoefficientInEtaPhi( j )( i ) .CosineCoefficients <= CosineCoefficient( MOD_PHI( ( 4 * i ) + 0 ) );
            MHTcoefficientInEtaPhi( j )( i ) .SineCoefficients   <= SineCoefficient( MOD_PHI( ( 4 * i ) + 0 ) );
          ELSIF( NOT jetVetoPipeIn( jetVetoPipeOffset )( j )( ( 4 * i ) + 1 ) .Data ) THEN
            MHTcoefficientInEtaPhi( j )( i ) .CosineCoefficients <= CosineCoefficient( MOD_PHI( ( 4 * i ) + 1 ) );
            MHTcoefficientInEtaPhi( j )( i ) .SineCoefficients   <= SineCoefficient( MOD_PHI( ( 4 * i ) + 1 ) );
          ELSIF( NOT jetVetoPipeIn( jetVetoPipeOffset )( j )( ( 4 * i ) + 2 ) .Data ) THEN
            MHTcoefficientInEtaPhi( j )( i ) .CosineCoefficients <= CosineCoefficient( MOD_PHI( ( 4 * i ) + 2 ) );
            MHTcoefficientInEtaPhi( j )( i ) .SineCoefficients   <= SineCoefficient( MOD_PHI( ( 4 * i ) + 2 ) );
          ELSIF( NOT jetVetoPipeIn( jetVetoPipeOffset )( j )( ( 4 * i ) + 3 ) .Data ) THEN
            MHTcoefficientInEtaPhi( j )( i ) .CosineCoefficients <= CosineCoefficient( MOD_PHI( ( 4 * i ) + 3 ) );
            MHTcoefficientInEtaPhi( j )( i ) .SineCoefficients   <= SineCoefficient( MOD_PHI( ( 4 * i ) + 3 ) );
          ELSE
            MHTcoefficientInEtaPhi( j )( i ) <= cEmptyMHTcoefficients;
          END IF;

        END IF;
      END PROCESS;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta;
  END GENERATE phi;

-- MHTcoefficientPipeOut <= MHTcoefficientInEtaPhi;

  MHTcoefficientPipeInstance : ENTITY work.MHTcoefficientPipe
  PORT MAP(
    clk                => clk ,
    MHTcoefficientsIn  => MHTcoefficientInEtaPhi ,
    MHTcoefficientPipe => MHTcoefficientPipeOut
  );

END ARCHITECTURE behavioral;
