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

-- common types
use work.common_types.all;

--
use work.LinkReference.all;
use work.LinkType.all;

-- Test bench entity 
entity TestBench is
  generic(

    sourcefile : string := "/home/vpalladi/FW/MP7/hgc_sim/RawDataGenerator/mp7data/base.mp7"

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


-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------
  signal flaggedWordIn  : hgcFlaggedWord;
  signal flaggedWordOut : hgcFlaggedWord;
  signal bxCounter      : natural;
  signal weSeed         : std_logic_array(nClusters downto 0);
  
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

  begin

    if(RISING_EDGE(clk)) then

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      if(clk_count = -1) then
        SourceLinkDataFile(sourcefile, 0, 0, 0, 1000, DEBUG, reference_Links);  --For aggregated captures
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
-- =========================================================================================================================================================================================
-- THE ALGORITHMS UNDER TEST
-- =========================================================================================================================================================================================
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  -- purpose: delay the input links 
  -- type   : combinational
  -- inputs : clk
  -- outputs: 
  pLinksInDelay : process (clk) is
  begin  -- process pLinksInDelay
    if rising_edge(clk) then
      linksIn_1 <= linksIn;
      linksIn_2 <= linksIn_1;
      linksIn_3 <= linksIn_2;
    end if;
  end process pLinksInDelay;


  -- translate in hgc flagged words
  mp72flagged : entity work.mp72hgcFlaggedWord
    port map(
      mp7Word        => linksIn(linkId),
      hgcFlaggedWord => flaggedWordTranslate
      );



  seedDistributor_1: entity work.seedDistributor
    port map (
      clk            => clk,
      rst            => '1',
      flaggedWordIn  => flaggedWordTranslate,
      flaggedWordOut => flaggedWordOut,
      bxCounter      => bxCounter,
      weSeed         => weSeed
      );

  
--  MainProcessor : entity work.MainProcessorTop
--    port map(
--      clk       => clk,
--      LinksIn   => linksIn_3,
--      LinksOut  => linksOut,
---- Configuration
--      ipbus_clk => ipbus_clk
--      );

  MP7CaptureFileWriterInstance1 : entity work.MP7CaptureFileWriter
    generic map(
      FileName      => string' ("test.txt"),
      DebugMessages => false
      )
    port map(clk, linksOut);

end architecture behavioral;
