--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using STD_LOGIC_UNSIGNED
--use IEEE.std_logic_unsigned.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! Using the Calo-L2 "mp7_data" data-types
use work.mp7_data_types.all;

--! hgc data types
use work.hgc_data_types.all;


entity seedDistributor is
  generic (
    nClusters : natural := 56
    );
  port (
    clk            : in  std_logic;
    rst            : in  std_logic;
    flaggedWordIn  : in  hgcFlaggedWord;
    flaggedWordOut : out hgcFlaggedWord;
    --bxCounter      : out natural;
    enaClusters    : out std_logic_array(nClusters-1 downto 0) := (others => '0')
    );

end entity seedDistributor;


architecture seedDistributor_arch of seedDistributor is

  signal bxCounter : natural := 0;
  signal seedCounter       : natural;

begin  -- architecture seedDistributore_arch

  -----------------------------------------------------------------------------
  -- exernal signals
  -----------------------------------------------------------------------------

  --bxCounter <= internalBxCounter;


  -----------------------------------------------------------------------------
  -- counting the bx
  -----------------------------------------------------------------------------

  process_bxCounter : process (clk, rst) is
  begin  -- process
    if rising_edge(clk) then

      if rst = '0' then
        bxCounter <= 0;
      elsif flaggedWordIn.word.EOE = '1' then
        bxCounter <= bxCounter + 1;
      end if;

    end if;
  end process;


 -----------------------------------------------------------------------------
 -- counting seeds and addressing clusters
 -----------------------------------------------------------------------------

  flaggedWordOut <= flaggedWordIn;
  
  p_seedDistribution : process (clk, rst) is
    variable currentCluster : natural range 0 to nClusters-1 := 0;
    --variable activeClustersMap : std_logic_array( nClusters-1 downto 0 ) := (others => '0');
  begin  -- process process_seedCounter

    if rising_edge( clk ) then

      if rst = '0' then
        currentCluster := 0;
      elsif flaggedWordIn.seedFlag = '1' then
        if currentCluster = nClusters-1 then
          currentCluster := 0;         
        else
          currentCluster := currentCluster + 1;  
        end if;
      else
        currentCluster := currentCluster;
      end if;
      
      for i in 0 to nClusters-1 loop
        if i = currentCluster then
          enaClusters( i ) <= '1';  
        else
          enaClusters( i ) <= '0';
        end if;
      end loop;

    end if;

  end process;
  
  
end architecture seedDistributor_arch;
