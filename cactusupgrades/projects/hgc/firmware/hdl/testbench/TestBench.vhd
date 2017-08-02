-- Using the IEEE Library
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

-- I/O
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

-- common constants
use work.constants.all;

-- "mp7_data" data-types
use work.mp7_data_types.all;

-- "hgc_data" data-types
use work.hgc_data_types.all;

-- common types
use work.common_types.all;

--
use work.LinkReference.all;
use work.LinkType.all;

-- Test bench entity 
entity TestBench is
  generic(

    sourcefile : string := "./data/out.mp7";
    destinationfile : string := "./results/out.mp7";
    csvLatencyFile : string := "./latency.csv" 
    
    );
end TestBench;

-- Architecture begin
architecture behavioral of TestBench is

  signal DEBUG : boolean := false;

  signal clk, ipbus_clk : std_logic          := '1';
  signal linksIn        : ldata(71 downto 0) := (others => LWORD_NULL);
  signal linksIn_0      : ldata(71 downto 0) := (others => LWORD_NULL);
  signal linksIn_1      : ldata(71 downto 0) := (others => LWORD_NULL);
  signal linksIn_2      : ldata(71 downto 0) := (others => LWORD_NULL);
  signal linksIn_3      : ldata(71 downto 0) := (others => LWORD_NULL);
  signal linksOut       : ldata(71 downto 0) := (others => LWORD_NULL);
 
--  signal flaggedWordTranslate : hgcFlaggedWord;
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
  --signal flaggedWordIn  : hgcFlaggedWord;
  --signal flaggedWordOut : hgcFlaggedWord;
  --signal bxCounter      : natural;
--  signal weSeed         : std_logic_array(nClusters downto 0);
  --signal weSeed         : std_logic_array(9 downto 0);

begin

-------------------------------------------------------------------------------
-- clocks
-------------------------------------------------------------------------------
  clk       <= not clk       after 2083 ps;  -- 500MHz
  ipbus_clk <= not ipbus_clk after 30 ns;    -- 33MHz
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Main process
-------------------------------------------------------------------------------
  main : process (clk) is

    variable reference_Links : tLinkPipe(10000 downto 0);
    variable L               : line;
    variable clk_count       : integer := -1;

    --file out_csv : text open write_mode is csvLatencyFile;
    
  begin

    if(RISING_EDGE(clk)) then

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      if(clk_count = -1) then
        SourceLinkDataFile(sourcefile, 0, 0, 0, 1000, DEBUG, reference_Links);  --For aggregated captures
        --WRITE(L, string' ("sAcquired,") );
        --WRITE(L, string' ("beginComputing,") );
        --WRITE(L, string' ("endComputing,") );
        --WRITE(L, string' ("beginSend,") );
        --WRITE(L, string' ("endSend") );
        --writeline( out_csv, L );
      end if;

      -- Link Stimulus 
      LinkStimulus
        (
          clk_count,
          reference_Links,
          linksIn
          );

      if DEBUG then
        WRITE(L, string' ("in "));
        HWRITE(L, linksIn(0).data);
        WRITELINE(OUTPUT, L);
        WRITE(L, string' ("out "));
        HWRITE(L, linksOut(0).data);
        WRITELINE(OUTPUT, L);
      end if;

      clk_count := clk_count + 1;

    end if;
  end process;
  
---- =========================================================================================================================================================================================
---- THE ALGORITHMS UNDER TEST
---- =========================================================================================================================================================================================
---- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  -- purpose: delay the input links 
  p_LinksInDelay : process (clk) is
  begin  -- process pLinksInDelay
    if rising_edge(clk) then
      linksIn_1 <= linksIn;
      linksIn_2 <= linksIn_1;
      linksIn_3 <= linksIn_2;
    end if;
  end process p_LinksInDelay;

----
----  
----  -- translate in hgc flagged words
----  mp72flagged : entity work.mp72hgcFlaggedWord
----    port map(
----      mp7Word        => linksIn(0),
----      hgcFlaggedWord => flaggedWordTranslate
----      );
----
----
----  
----  e_seedDistributor: entity work.seedDistributor
----    generic map (
----      nClusters => 10
----      )
----    port map (
----      clk            => clk,
----      rst            => '1',
----      flaggedWordIn  => flaggedWordTranslate,
----      flaggedWordOut => flaggedWordOut,
----      bxCounter      => bxCounter,
----      weSeed         => weSeed
----      );
  
  e_MainProcessor : entity work.MainProcessorTop
    port map(
      clk       => clk,
      linksIn   => linksIn_3,
      linksOut  => linksOut,
-- Configuration
      ipbus_clk => ipbus_clk
      );

  e_MP7CaptureFileWriterInstance : entity work.MP7CaptureFileWriter
    generic map(
      FileName      => destinationfile,
      DebugMessages => true
      )
    port map(
      clk, linksOut
      );

end architecture behavioral;
