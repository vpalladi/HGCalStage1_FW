-- Using the IEEE Library
LIBRARY IEEE;

USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- I/O
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

-- common constants
USE work.constants.ALL;

-- "mp7_data" data-types
USE work.mp7_data_types.ALL;

-- common types
USE work.common_types.ALL;

--
USE work.LinkReference.ALL;
USE work.LinkType.ALL;

--! hgc data types
use work.hgc_data_types.all;

-- Test bench entity 
ENTITY TestBench_clu IS

END TestBench_clu;

-- Architecture begin
ARCHITECTURE behavioral OF TestBench_clu IS

  signal DEBUG : boolean := false;
  
  SIGNAL clk , ipbus_clk                      : STD_LOGIC                               := '1';

  signal pos       : std_logic_vector(2 downto 0);
  signal dataIn    : hgcWord;
  signal wen       : std_logic;
  signal rdRow     : std_logic;
  signal dataOut   : std_logic_vector(7 downto 0);
  signal dataValid : std_logic;

BEGIN

-------------------------------------------------------------------------------
-- clocks
-------------------------------------------------------------------------------
    clk       <= NOT clk AFTER 2083 ps;  -- 500MHz
    ipbus_clk <= NOT ipbus_clk AFTER 30 ns;  -- 33MHz
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Main process
-------------------------------------------------------------------------------



  main: process (clk) is
   
  BEGIN

    IF( RISING_EDGE( clk ) ) THEN
      
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      -- Stimulus 
      
    END IF;
  END PROCESS;
-- =========================================================================================================================================================================================
-- THE ALGORITHMS UNDER TEST
-- =========================================================================================================================================================================================
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


    
    cluster_inst: entity work.cluster
      port map (
        clk       => clk,
        pos       => pos,
        dataIn    => dataIn,
        wen       => wen,
        rdRow     => rdRow,
        dataOut   => dataOut,
        dataValid => dataValid

        );
    
    
    
END ARCHITECTURE behavioral;
