--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using STD_LOGIC_UNSIGNED
use IEEE.std_logic_unsigned.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! Using IPbus
use work.ipbus.all;
--! Using the Calo-L2 algorithm configuration bus
--USE work.FunkyMiniBus.ALL;

--! I/O
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;

--! MP7 datatypes
use work.mp7_data_types.all;


--! @brief An entity providing a MainProcessorTop
--! @details Detailed description
entity MainProcessorTop is
  generic(
    nLinks    : natural := 72
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

  signal cnt_rst : integer := 0;
  signal rst  : std_logic := '1';

  
begin


  
--  linksOut <= linksIn;
  
  -----------------------------------------------------------------------------
  -- generate all the links
  -----------------------------------------------------------------------------
  p_reset: process (clk) is
  begin  -- process p_reset
    if rising_edge(clk) then
      cnt_rst <= cnt_rst + 1;
    end if;

    if cnt_rst > 10 then
      rst <= '0';
    end if;
  end process p_reset;
  
  e_retmux: entity work.retmux
    generic map (
      tmux => 18
      )
    port map (
      rst      => rst,
      link_clk => clk,
      clk      => clk,
      linksIn  => linksIn,
      linksOut => linksOut
      );
  
end architecture behavioral;
