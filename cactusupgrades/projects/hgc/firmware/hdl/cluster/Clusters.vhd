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

--! I/O
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

--! hgc constants
use work.hgc_constants.all;

entity clusters is

  generic (
    nClusters : natural := 1;
    nRows     : integer := 5;
    nColumns  : integer := 5
    );

  port (
    clk                  : in std_logic;
    rst                  : in std_logic;
    enaSeed              : in std_logic_array(nClusters-1 downto 0); 
    seedingFlaggedWordIn : in hgcFlaggedWord;
    delayedFlaggedWordIn : in hgcFlaggedWord;

    --send : in std_logic_array(nClusters-1 downto 0);

    readyToAcquire : out std_logic_array(nClusters-1 downto 0);
    --readyToSend    : out std_logic_array(nClusters-1 downto 0);

    --sent           : out std_logic_array(nClusters-1 downto 0);

    --flaggedWordOut : out hgcFlaggedData_cluOut(nClusters-1 downto 0)
    flaggedWordOut : out hgcFlaggedWord
    );

end entity clusters;


architecture arch_clusters of clusters is

  -- clusters  
  signal clu_flaggedDataOut : hgcFlaggedData(nClusters-1 downto 0);
  signal send        : std_logic_array(nClusters-1 downto 0);
  signal sent        : std_logic_array(nClusters-1 downto 0);
  signal readyToSend : std_logic_array(nClusters-1 downto 0);
  
begin  -- architecture arch_1
  

  -----------------------------------------------------------------------------
  -- clusters generation
  -----------------------------------------------------------------------------
  g_clusters : for i_clu in nClusters-1 downto 0 generate

      e_cluster : entity work.cluster
        generic map (
          nRows    => 5,
          nColumns => 5
          )
        port map (
          clk                     => clk,
          rst                     => rst,
          enaSeed                 => enaSeed(i_clu),
          seedingFlaggedWordIn    => seedingFlaggedWordIn,
          delayedFlaggedWordIn    => delayedFlaggedWordIn,
          
          send                    => send(i_clu),

          readyToAcquire          => readyToAcquire(i_clu),
          readyToSend             => readyToSend(i_clu),
          sent                    => sent(i_clu),
          flaggedWordOut          => clu_flaggedDataOut(i_clu)
          );
      
  end generate g_clusters;


  -----------------------------------------------------------------------------
  -- compiute cluster occupancy
  -----------------------------------------------------------------------------

  
  
  
  -----------------------------------------------------------------------------
  -- send cluster
  -----------------------------------------------------------------------------
  p_send_clu : process (clk) is
    variable current_cluster : integer := 0;
  begin  -- process
    if rising_edge(clk) then

      if rst = '0' then
        current_cluster := 0;
      elsif sent(current_cluster) = '1' then
        send(current_cluster) <= '0';
      elsif readyToSend(current_cluster) = '1' then
        send(current_cluster) <= '1';
        if current_cluster = nClusters-1 then
          current_cluster := 0;
        else
          current_cluster := current_cluster + 1;
        end if;
      end if;

      flaggedWordOut <= clu_flaggedDataOut(current_cluster);
      
    end if;
  end process;



      
end architecture arch_clusters;

