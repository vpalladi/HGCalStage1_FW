
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;


PACKAGE correlator_types IS

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

  TYPE tCandidate IS RECORD
    Energy    : UNSIGNED( 12 DOWNTO 0 );
    Phi       : UNSIGNED( 7 DOWNTO 0 );
    Eta       : SIGNED( 7 DOWNTO 0 );
    DataValid : BOOLEAN;
  END RECORD;

  TYPE tCandidatePipe IS ARRAY( NATURAL RANGE <> ) OF tCandidate;

  CONSTANT cEmptyCandidate : tCandidate := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , FALSE );

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------


END PACKAGE correlator_types;
