
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

PACKAGE demux_types IS

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TYPE tLdataPipe is array( 11 downto 0 ) of ldata( cNumberOfLinksIn-1 DOWNTO 0 );

  TYPE tCounters      IS ARRAY( NATURAL RANGE <> ) OF INTEGER RANGE 0 TO 127 ; -- in a 12-card TMT can never be above 71

  TYPE tTapParameters IS RECORD
    Offset : INTEGER;
  END RECORD;

  TYPE tTapParametersSet IS ARRAY( NATURAL RANGE <> ) OF tTapParameters;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

END PACKAGE demux_types;
