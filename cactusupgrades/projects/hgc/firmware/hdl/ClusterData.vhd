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



entity cluster_data is
  
  port (
    clk            : in  std_logic;
    rst            : in  std_logic;
    
    we             : in std_logic;
    row            : in std_logic_vector(2 downto 0);
    col            : in std_logic_vector(2 downto 0);
    flaggedWordIn  : in  hgcFlaggedWord;
    send           : in  std_logic;
    
    sent           : out std_logic;
    flaggedWordOut : out hgcFlaggedWord;
    dataValid      : out std_logic
    );

end entity cluster_data;


architecture arch_cluster_data of cluster_data is

  signal addrA     : std_logic_vector(5 downto 0);
  signal dataA_in  : std_logic_vector(31 downto 0);
  signal addrB     : std_logic_vector(5 downto 0);
  --signal a_rd_1  : std_logic_vector(3 downto 0); 
  signal clk       : std_logic;
  signal weA       : std_logic;
  signal dataA_out : std_logic_vector(31 downto 0);
  signal daraB_out : std_logic_vector(31 downto 0);

  signal erase        : std_logic;
  
begin  -- architecture arch_cluster_data

  -----------------------------------------------------------------------------
  -- input to ram
  -----------------------------------------------------------------------------

  -- port A
  weA   <= we or erase; 
  addrA <= row & col; 
  
  e_hgcFlagged2ram : entity work.hgcFlagged2ram
    port map (
      hgcFlaggedWord => flaggedWordIn,
      ram            => dataA_in
      );

  -- port B
  p_addrB : process (clk) is
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
  
  -----------------------------------------------------------------------------
  -- Dram
  -----------------------------------------------------------------------------
  e_clu_data_ram: entity work.clu_data_ram
    port map (
      a    => addrA,     -- address
      d    => dataA_in,  -- data in
      dpra => addrB,     -- dual port address
      clk  => clk,       
      we   => we,        -- wr enable
      spo  => dataA_out, -- output of port a
      dpo  => dataB_out  -- otput of port dpra
    );
  
  -----------------------------------------------------------------------------
  -- output to ram
  -----------------------------------------------------------------------------
  ram2hgcFlaggedWord_1: entity work.ram2hgcFlaggedWord
    port map (
      ram            => dataB_out,
      hgcFlaggedWord => flaggedWordOut
      );
  
end architecture arch_cluster_data;
