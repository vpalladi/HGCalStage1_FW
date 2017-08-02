--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using STD_LOGIC_UNSIGNED
use IEEE.std_logic_unsigned.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! Using the Calo-L2 "mp7_data" data-types
use work.mp7_data_types.all;

--! hgc data types
use work.hgc_data_types.all;

--! Using IPbus
use work.ipbus.all;
--! Using the Calo-L2 algorithm configuration bus
--USE work.FunkyMiniBus.ALL;


-- I/O
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;


entity Link is
  generic (
    nClusters : natural := 5;
    nRows : natural := 5;
    nColumns : natural := 5;    
    csvLatencyFile : string := "./latency.csv"
    );
  port (
    clk    : in std_logic;
    rst    : in std_logic;
    
    -- seeding 
    energyThreshold    : in std_logic_vector(7 downto 0);

    mp7wordIn          : in  lword;         -- 8b address 8b data(energy)

    flaggedWordOut : out hgcFlaggedWord := HGCFLAGGEDWORD_NULL
    
    );

end entity Link;

architecture Link_arch of Link is

  -----------------------------------------------------------------------------
  -- data flagging 
  -----------------------------------------------------------------------------
  signal flag_flaggedWordOut : hgcFlaggedWord;

  -----------------------------------------------------------------------------
  -- data variable delay 
  -----------------------------------------------------------------------------
  signal ddelay_EOE : std_logic;
  signal ddelay_flaggedWordOut : hgcFlaggedWord;
  
  -----------------------------------------------------------------------------
  -- seed distributor
  -----------------------------------------------------------------------------
--  type std_logic_2Darray is array (natural range <>) of std_logic_array(nClusters-1 downto 0);
--  type hgcFlaggedData_cluOut is array (nClusters downto 0) of hgcFlaggedWord;
--  type hgcFlaggedData_2Darray is array (natural range <>) of hgcFlaggedData_cluOut;

  signal sdist_flaggedWordOut : hgcFlaggedWord;
  signal sdist_weSeed         : std_logic_array(nClusters-1 downto 0);

  -----------------------------------------------------------------------------
  -- clusters
  -----------------------------------------------------------------------------
--  signal clu_seedAcquired   : std_logic_array(nClusters-1 downto 0);
  signal clu_readyToAcquire : std_logic_array(nClusters-1 downto 0);
--  signal clu_readyToSend    : std_logic_array(nClusters-1 downto 0);
--  signal clu_send           : std_logic_array(nClusters-1 downto 0);
--  signal clu_sent           : std_logic_array(nClusters-1 downto 0);
--  signal clu_flaggedWordIn  : hgcFlaggedWord;
--  signal clu_flaggedDataOut : hgcFlaggedData_cluOut(nClusters-1 downto 0);

begin  -- architecture Link_arch

  
  -----------------------------------------------------------------------------
  -- FLAG the data stream
  -----------------------------------------------------------------------------
  e_flag_stream : entity work.SeedingLink
    port map (
      clk                => clk,
      rst                => rst,
      energyThreshold    => energyThreshold,
      mp7wordIn          => mp7wordIn,
      flaggedWordOut     => flag_flaggedWordOut
      );
    
  -----------------------------------------------------------------------------
  -- DELAY the data stream depending on the data in the BX
  -----------------------------------------------------------------------------
  e_dataVariableDelay : entity work.DataVariableDelay
    port map (
      clk            => clk,
      rst            => '1',
      flaggedWordIn  => flag_flaggedWordOut,
      flaggedWordOut => ddelay_flaggedWordOut,
      EOE            => ddelay_EOE
      );

  -----------------------------------------------------------------------------
  -- SEED DISTRIBUTION among the clusters
  -----------------------------------------------------------------------------
  e_seedDistributor : entity work.seedDistributor
    generic map (
      nClusters => nClusters
      )
    port map (
      clk            => clk,
      rst            => '1',
      flaggedWordIn  => flag_flaggedWordOut,
      flaggedWordOut => sdist_flaggedWordOut,
      enaClusters    => sdist_weSeed
      );

  -----------------------------------------------------------------------------
  -- CLUSTERS generation 
  -----------------------------------------------------------------------------

  e_clusters : entity work.clusters
    generic map (
      nClusters => nClusters,
      nRows    => nRows,
      nColumns => nColumns
      )
    port map (
      clk                     => clk,
      rst                     => '1',
      enaSeed                 => sdist_weSeed,
      seedingFlaggedWordIn    => sdist_flaggedWordOut,
      delayedFlaggedWordIn    => ddelay_flaggedWordOut,
      
      --send                    => clu_send(i_clu),
      
      readyToAcquire          => clu_readyToAcquire,
      --readyToSend             => clu_readyToSend,
      --sent                    => clu_sent,
      flaggedWordOut          => flaggedWordOut
      );
      
end architecture Link_arch;

