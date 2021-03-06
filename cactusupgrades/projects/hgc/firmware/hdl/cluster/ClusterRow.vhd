
-------------------------------------------------------------------------------
-- to-do-list 
-------------------------------------------------------------------------------
-- while reading a row the previous element must be set to 0
-- 
-- 
-------------------------------------------------------------------------------

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

entity clusterRow is
  generic (
    nColumns : integer := 7
    );
  port (
    clk : in std_logic;

    flaggedSeedWordIn : in hgcFlaggedWord;
    flaggedWordIn     : in hgcFlaggedWord;

    we   : in std_logic;
    send : in std_logic;

    sent : out std_logic;
    flaggedWordOut : out hgcFlaggedWord;
    dataValid      : out std_logic := '0'
--    sent       : out std_logic := '0'

    );
end entity clusterRow;


architecture arch_cluster_1 of clusterRow is

  -- rd fsm
-- type fsm_state is (fsm_acquisition, fsm_sending, fsm_sent);
-- signal state : state := fsm_acquisition;

  signal internalSent : std_logic := '0';
  
  signal erase_ptr    : std_logic_vector(3 downto 0);
  signal erase        : std_logic;
  
  -- distributed mem
  signal dmem_a_wr    : std_logic_vector(3 downto 0);
  signal dmem_d_in    : std_logic_vector(31 downto 0);
  signal dmem_a_rd    : std_logic_vector(3 downto 0);
  signal dmem_a_rd_1  : std_logic_vector(3 downto 0); 
  signal dmem_clk     : std_logic;
  signal dmem_we      : std_logic;
  signal dmem_d_out_a : std_logic_vector(31 downto 0);
  signal dmem_d_out_b : std_logic_vector(31 downto 0);

  --helpers
  --signal mp7WordFromDRAM : lword := LWORD_NULL;
  
begin  -- architecture arch_cluster_1

  sent <= internalSent;
  
  -----------------------------------------------------------------------------
  -- distributed memory 
  -----------------------------------------------------------------------------
  dmem_clk  <= clk;
  dmem_we   <= we or erase;
  dmem_a_wr <= '0' & flaggedWordIn.word.address.col-flaggedSeedWordIn.word.address.col+(nColumns-1)/2 when we = '1' else
               erase_ptr;               -- must be updated
  --dmem_d_in <= flaggedWordIn.seedFlag & flaggedWordIn.word.energy when we = '1' else
  --             (others => '0');
  e_hgcFlagged2ram : entity work.hgcFlagged2ram
    port map (
      hgcFlaggedWord => flaggedWordIn,
      ram            => dmem_d_in
      );
  
  -- handling the read pointer
  process_increment_rd_ptr : process (clk) is
    variable increment_ptr : std_logic := '0';
  begin
    if rising_edge(clk) then

      if send = '1' then
        increment_ptr := '1';
        dataValid <= '1';
      elsif internalSent = '1' then
        increment_ptr := '0';
        dataValid <= '0';
      end if;
      
      if increment_ptr = '1' then
        dmem_a_rd <= std_logic_vector( unsigned(dmem_a_rd)+1 );
      else
        dmem_a_rd <= (others => '0');
      end if;

      if dmem_a_rd = integer(nColumns) then
        internalSent <= '1';
      else
        internalSent <= '0';
      end if;
        
    end if;
  end process process_increment_rd_ptr;

  -- delay the send signal and pointer of 1clk to erase the memory
  process_erase_memory: process (clk) is
  begin
    if rising_edge(clk) then
      erase_ptr <= dmem_a_rd;
      erase <= send;
    end if;
  end process process_erase_memory;

  clu_dist_mem_row_2 : entity work.clu_dist_mem_row
    port map (
      a    => dmem_a_wr,
      d    => dmem_d_in,
      dpra => dmem_a_rd,
      clk  => dmem_clk,
      we   => dmem_we,
      spo  => dmem_d_out_a,
      dpo  => dmem_d_out_b
      );

 -- mp7WordFromDRAM.data <= dmem_d_out_b;
 -- 
 -- e_fromRAM : entity work.mp72hgcFlaggedWord
 --   port map(
 --     mp7Word        => mp7WordFromDRAM,
 --     hgcFlaggedWord => flaggedWordOut
 --     );
  
  ram2hgcFlaggedWord_1: entity work.ram2hgcFlaggedWord
    port map (
      ram            => dmem_d_out_b,
      hgcFlaggedWord => flaggedWordOut
      );
  
  --flaggedWordOut.word.energy   <= dmem_d_out_b(7 downto 0);
  --flaggedWordOut.seedFlag <= dmem_d_out_b(8);
  --flaggedWordOut.word.address.col <= dmem_a_rd(2 downto 0) + flaggedSeedWordIn.word.address.col - (nColumns-1)/2;
  --flaggedWordOut.word.valid    <= '1';

end architecture arch_cluster_1;
