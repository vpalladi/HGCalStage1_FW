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


--! @brief An entity providing a MainProcessorTop
--! @details Detailed description
entity MainProcessorTop is
  generic(
    linkId    : natural := 0;
--    nClusters : natural := 56
    nClusters : natural := 1
    );
  port(
    clk       : in  std_logic;                  --! The algorithm clock
    linksIn   : in  ldata(71 downto 0) := (others => LWORD_NULL);
    linksOut  : out ldata(71 downto 0) := (others => LWORD_NULL);
-- Configuration
    ipbus_clk : in  std_logic          := '0';  --! The IPbus clock
    ipbus_rst : in  std_logic          := '0';
    ipbus_in  : in  ipb_wbus           := IPB_WBUS_NULL;
    ipbus_out : out ipb_rbus           := IPB_RBUS_NULL
-- Testbench Outputs    
    );
end MainProcessorTop;


architecture behavioral of MainProcessorTop is

  --type std_logic_array is array (71 downto 0) of std_logic;

  signal flaggedData            : hgcFlaggedData(71 downto 0);
  signal delayed_flaggedDataOut : hgcFlaggedData(71 downto 0);

  signal thr : std_logic_vector (7 downto 0) := "00000101";

  -----------------------------------------------------------------------------
  -- dynamic delay
  -----------------------------------------------------------------------------
  signal ddelay_EOE : std_logic_array(71 downto 0);
  --signal ddelay_we  : std_logic_array(71 downto 0);

  -----------------------------------------------------------------------------
  -- seed distributor
  -----------------------------------------------------------------------------
  type std_logic_2Darray is array (natural range <>) of std_logic_array(nClusters-1 downto 0);
  type hgcFlaggedData_cluOut is array (nClusters downto 0) of hgcFlaggedWord;
  --type hgcFlaggedData_cluOut is array (nClusters downto 0) of hgcFlaggedData(4 downto 0);
  type hgcFlaggedData_2Darray is array (natural range <>) of hgcFlaggedData_cluOut;

  --signal sdist_flaggedWordIn  : hgcFlaggedWord;
  signal sdist_flaggedDataOut : hgcFlaggedData(71 downto 0);
  --signal sdist_bxCounter      : natural_array(71 downto 0);
  signal sdist_weSeed         : std_logic_2Darray(71 downto 0);

  -----------------------------------------------------------------------------
  -- clusters
  -----------------------------------------------------------------------------
  --signal clu_weWord         : std_logic_;
  --signal clu_EOE            : std_logic := '0';
  --signal clu_send           : std_logic;
  signal clu_seedAcquired   : std_logic_2Darray(71 downto 0);
  signal clu_readyToAcquire : std_logic_2Darray(71 downto 0);
  signal clu_readyToSend    : std_logic_2Darray(71 downto 0);
  signal clu_send           : std_logic_2Darray(71 downto 0);
  signal clu_sent           : std_logic_2Darray(71 downto 0);
  signal clu_flaggedDataIn  : hgcFlaggedData(71 downto 0);
  signal clu_flaggedDataOut : hgcFlaggedData_2Darray(71 downto 0);
  --signal clu_flaggedDataOut : hgcFlaggedData(71 downto 0);

  -------------------------------------------------------------------------------
  -- helpers  
  -------------------------------------------------------------------------------
  signal helper_flaggedDataOut : hgcFlaggedData(71 downto 0);


begin

--test  linksOut <= linksIn;

  
  -----------------------------------------------------------------------------
  -- seeding the links
  -----------------------------------------------------------------------------
  e_seedinglinks : entity work.Seedinglinks
    port map (
      clk             => clk,
      rst             => '1',
      energyThreshold => thr,
      linksIn         => linksIn,
      flaggedDataOut  => flaggedData
      );

  -----------------------------------------------------------------------------
  -- generate all the links
  -----------------------------------------------------------------------------
  g_data_delay_links : for i_link in 71 downto 0 generate

    -- delay the data
    e_dataVariableDelay : entity work.DataVariableDelay
      port map (
        clk            => clk,
        rst            => '1',
        flaggedWordIn  => flaggedData(i_link),
        flaggedWordOut => delayed_flaggedDataOut(i_link),
        EOE            => ddelay_EOE(i_link)
--        we             => ddelay_we(i_link)
        );

    -- distribute the seeds among the clusters
    e_seedDistributor : entity work.seedDistributor
      generic map (
        nClusters => nClusters
        )
      port map (
        clk            => clk,
        rst            => '1',
        flaggedWordIn  => flaggedData(i_link),
        flaggedWordOut => clu_flaggedDataIn(i_link),--sdist_flaggedDataOut(i_link),
        --bxCounter      => sdist_bxCounter(i_link),
        enaClusters    => sdist_weSeed(i_link)
        );
    
--    -- distribute the seeds among the clusters
--    e_dataDistributor : entity work.seedDistributor
--      generic map (
--        nClusters => nClusters
--        )
--      port map (
--        clk            => clk,
--        rst            => '1',
--        flaggedWordIn  => delayed_flaggedDataOut(i_link),
--        flaggedWordOut => clu_flaggedDataIn(i_link),
--        --bxCounter      => sdist_bxCounter(i_link),
--        we             => sdist_weSeed(i_link)
--        );
    
    ---------------------------------------------------------------------------
    -- clusters
    g_clusters : for i_clu in nClusters-1 downto 0 generate

      e_cluster : entity work.cluster
        generic map (
          nRows    => 5,
          nColumns => 5
          )
        port map (
          clk                     => clk,
          rst                     => '1',
          enaSeed                 => sdist_weSeed(i_link)(i_clu),
          seedingFlaggedWordIn    => clu_flaggedDataIn(i_link),
          delayedFlaggedWordIn    => delayed_flaggedDataOut(i_link),
          
          --weWord                  => ddelay_we(i_link),
          --EOE                     => ddelay_EOE(i_link),
          send                    => clu_send(i_link)(i_clu),
          --seedAcquired            => clu_seedAcquired(i_link)(i_clu),
          readyToAcquire          => clu_readyToAcquire(i_link)(i_clu),
          readyToSend             => clu_readyToSend(i_link)(i_clu),
          sent                    => clu_sent(i_link)(i_clu),
          flaggedWordOut          => clu_flaggedDataOut(i_link)(i_clu)
          );

      p_send_clu : process (clk) is
      begin  -- process
        if rising_edge(clk) then
          if clu_sent(i_link)(i_clu) = '1' then
            clu_send(i_link)(i_clu) <= '0'; 
          elsif clu_readyToSend(i_link)(i_clu) = '1' then
            clu_send(i_link)(i_clu) <= '1';
          end if;
        end if;
      end process;

      --g_rows : for i_row in 4 downto 0 generate
      --  helper_flaggedDataOut(i_link).word.valid       <= helper_flaggedDataOut(i_link).word.valid or clu_flaggedDataOut(i_link)(i_clu)(i_row).word.valid;
      --  helper_flaggedDataOut(i_link).word.address.row <= helper_flaggedDataOut(i_link).word.address.row or clu_flaggedDataOut(i_link)(i_clu)(i_row).word.address.row;
      --  helper_flaggedDataOut(i_link).word.address.col <= helper_flaggedDataOut(i_link).word.address.col or clu_flaggedDataOut(i_link)(i_clu)(i_row).word.address.col;
      --  helper_flaggedDataOut(i_link).word.energy      <= helper_flaggedDataOut(i_link).word.energy or clu_flaggedDataOut(i_link)(i_clu)(i_row).word.energy;
      --  helper_flaggedDataOut(i_link).word.EOE         <= helper_flaggedDataOut(i_link).word.EOE or clu_flaggedDataOut(i_link)(i_clu)(i_row).word.EOE;
      --  helper_flaggedDataOut(i_link).dataFlag         <= helper_flaggedDataOut(i_link).dataFlag or clu_flaggedDataOut(i_link)(i_clu)(i_row).dataFlag;
      --  helper_flaggedDataOut(i_link).seedFlag         <= helper_flaggedDataOut(i_link).seedFlag or clu_flaggedDataOut(i_link)(i_clu)(i_row).seedFlag;
      --
      --end generate g_rows;

    end generate g_clusters;

    e_hgc2mp7Out : entity work.hgc2mp7FlaggedWord
      port map (
        hgcFlaggedWord => clu_flaggedDataOut(i_link)(0),--clu_flaggedDataOut(0)(0),
        --hgcFlaggedData => sdist_flaggedDataOut,
        mp7Word => linksOut(i_link)
        );

  end generate g_data_delay_links;
  
  -- translate data from HGC to MP7 format 
  --e_hgc2mp7Out : entity work.hgc2mp7FlaggedData
  --  port map (
  --    hgcFlaggedData => clu_flaggedDataOut(0)(0),
  --    --hgcFlaggedData => sdist_flaggedDataOut,
  --    mp7Data => linksOut
  --    );


--  readProc: process (clk) is
-- --   variable L : line;
-- --   variable energy : natural;
-- --   variable wafer : natural;
-- --   variable triggerCell : natural;
-- --   variable X : integer;
-- --   variable Y : integer;
--  begin  -- process readProc
--
--    if rising_edge(clk) then  -- rising clock edge
--        linksOut(71 downto 0) <= linksIn(71 downto 0);  
--
-- --       energy := to_integer(unsigned( linksIn(linkId).data(7 downto 0) ) ); 
-- --       triggerCell :=  to_integer(unsigned( linksIn(linkId).data(14 downto 8) ) ); 
-- --       wafer :=  to_integer(unsigned( linksIn(linkId).data(24 downto 15) ) );
-- --
-- --       X := to_integer(signed(TCx));
-- --       Y := to_integer(signed(TCy));
-- --
-- --       WRITE(L, STRING'("a0x") );              
-- --       HWRITE(L, linksIn(linkId).data(24 downto 8) );
-- --       WRITE(L, STRING'(" a") );              
-- --       WRITE(L, to_integer(unsigned(linksIn(linkId).data(24 downto 8) )) );  
-- --       WRITE(L, STRING'(" w") );              
-- --       WRITE(L, wafer);
-- --       WRITE(L, STRING'(" c") );              
-- --       WRITE(L, triggerCell);
-- --       WRITE(L, STRING' (" 0x") );       
-- --       HWRITE(L, TCx);
-- --       WRITE(L, STRING' (" ") );       
-- --       WRITE(L, X);         
-- --       WRITELINE(OUTPUT, L);
-- --       
--    end if;
--  end process readProc;

end architecture behavioral;
