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
    nClusters : natural;
    nRows     : integer;
    nColumns  : integer
    );

  port (
    clk                  : in std_logic;
    rst                  : in std_logic := '1';
    enaSeed              : in std_logic_array(nClusters-1 downto 0); 
    seedingFlaggedWordIn : in hgcFlaggedWord;
    delayedFlaggedWordIn : in hgcFlaggedWord;

    --send : in std_logic_array(nClusters-1 downto 0);

    readyToAcquire : out std_logic_array(nClusters-1 downto 0);
    --readyToSend    : out std_logic_array(nClusters-1 downto 0);

    --sent           : out std_logic_array(nClusters-1 downto 0);
    
    --flaggedWordOut : out hgcFlaggedData_cluOut(nClusters-1 downto 0)
    flaggedWordOut : out hgcFlaggedWord := HGCFLAGGEDWORD_NULL
    );

end entity clusters;


architecture arch_clusters of clusters is

  type std_logic_matrix_array is array (nClusters-1 downto 0) of std_logic_matrix(0 to nRows-1, 0 to nColumns-1);
  
  -- clusters
  signal current_clu : natural := 0;
  signal clu_occupancy      : std_logic_matrix_array;
  signal clu_readyToCompute : std_logic_array(nClusters-1 downto 0);
  signal clu_computed       : std_logic_array(nClusters-1 downto 0);
  signal send               : std_logic_array(nClusters-1 downto 0) := (others => '0');
  signal clu_readyToSend    : std_logic_array(nClusters-1 downto 0);
  signal sent               : std_logic_array(nClusters-1 downto 0);
  signal clu_flaggedDataOut : hgcFlaggedData(nClusters-1 downto 0);

  -- compute occupancy
  type fsm is (fsm_testCluster, fsm_computing, fsm_computed, fsm_clean);
  --signal state : fsm := fsm_clean;
  
  signal comp_clean : std_logic := '0';
  signal comp_compute : std_logic := '0';
  signal comp_computed : std_logic := '0';
  signal comp_occupancyMap : std_logic_matrix(0 to nRows-1, 0 to nColumns-1) := (others => (others => '0'));
  signal comp_occupancy : std_logic_matrix(0 to nRows-1, 0 to nColumns-1) := (others => (others => '0'));

  signal bah : std_logic;
begin  -- architecture arch_1
  

  -----------------------------------------------------------------------------
  -- clusters generation
  -----------------------------------------------------------------------------
  clu_computed(current_clu) <= comp_computed;
  
  g_clusters : for i_clu in nClusters-1 downto 0 generate

      e_cluster : entity work.cluster
        generic map (
          nRows    => nRows,
          nColumns => nColumns
          )
        port map (
          clk                     => clk,
          rst                     => rst,
          enaSeed                 => enaSeed(i_clu),
          seedingFlaggedWordIn    => seedingFlaggedWordIn,
          delayedFlaggedWordIn    => delayedFlaggedWordIn,

          occupancy               => clu_occupancy(i_clu),
          occupancyComputed       => comp_occupancy,
          readyToCompute          => clu_readyToCompute(i_clu),
          computed                => clu_computed(i_clu),
          
          send                    => send(i_clu),

          readyToAcquire          => readyToAcquire(i_clu),
          readyToSend             => clu_readyToSend(i_clu),
          sent                    => sent(i_clu),
          flaggedWordOut          => clu_flaggedDataOut(i_clu)
          );
      
      
  end generate g_clusters;


  -----------------------------------------------------------------------------
  -- compute cluster occupancy
  -----------------------------------------------------------------------------
  bah <= clu_readyToCompute(current_clu);
  -- FSM
  p_fsm: process (clk) is
    variable state : fsm;
  begin  -- process process_fsm
    if rising_edge(clk) then

      case state is
        when fsm_testCluster =>
          if clu_readyToCompute(current_clu) = '1' then
            state := fsm_computing;
          else
            state := fsm_testCluster; 
          end if;
        when fsm_computing =>
          if comp_computed = '1' then
            state := fsm_computed;
          else
            state := state;
          end if;
        when fsm_computed =>
            state := fsm_clean;
        when fsm_clean =>
          state := fsm_testCluster;
      end case;

      if rst = '0' or current_clu = nClusters-1 then
        current_clu <= 0;
      elsif state = fsm_testCluster then
        current_clu <= current_clu + 1;
      else
        current_clu <= current_clu;
      end if;

      if state = fsm_clean then
        comp_clean <= '1';
      else
        comp_clean <= '0';
      end if;

      if state = fsm_computing then
        comp_compute <= '1';
      else
        comp_compute <= '0';
      end if;
      
    end if;
  end process p_fsm;

--  -- increment the cluster selector
--  p_clusterSelector: process (clk, rst) is
--  begin  -- process p_clusterSelector
--    if rising_edge(clk) then  -- rising clock edge
--      if rst = '0' or current_clu = nClusters-1 then
--        current_clu <= 0;
--      elsif state = fsm_testCluster then
--        current_clu <= current_clu + 1;
--      else
--        current_clu <= current_clu;
--      end if;
--    end if;
--  end process p_clusterSelector;
  
  -- Computing engine
--  comp_clean <= '1' when state = fsm_clean else '0';
--  comp_compute <= '1' when state = fsm_computing else '0';
  comp_occupancyMap <= clu_occupancy(current_clu);
  
  e_computeClu : entity work.computeClu
    generic map (
      nRows    => nRows,
      nColumns => nColumns
      )
    port map (
      clk          => clk,
      clean        => comp_clean,
      compute      => comp_compute,
      occupancyMap => comp_occupancyMap,
      computed     => comp_computed,
      cluster      => comp_occupancy
      );


  -----------------------------------------------------------------------------
  -- send cluster
  -----------------------------------------------------------------------------
  p_send_clu : process (clk) is
    variable cc : integer := 0;
  begin  -- process
    if rising_edge(clk) then

      if rst = '0' then
        cc := 0;
      elsif sent(cc) = '1' then
        send(cc) <= '0';
        if cc = nClusters-1 then
          cc := 0;
        else
          cc := cc + 1;
        end if;
      elsif clu_readyToSend(cc) = '1' then
        send(cc) <= '1';
      end if;

      flaggedWordOut <= clu_flaggedDataOut(cc);
      
    end if;
  end process;
  
      
end architecture arch_clusters;

