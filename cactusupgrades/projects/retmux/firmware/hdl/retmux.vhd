--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using STD_LOGIC_UNSIGNED
use IEEE.std_logic_unsigned.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

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

--! MP7 datatypes
use work.mp7_data_types.all;

--! HGC datatypes
use work.hgc_data_types.all;


entity retmux is
  generic(
    tmux : natural := 18
    );
  port(
    rst      : in std_logic;
    link_clk : in std_logic;            --! the links clock
    clk      : in std_logic;            --! The algorithm clock
    linksIn  : in ldata(71 downto 0) := (others => LWORD_NULL);

    linksOut : out ldata(71 downto 0) := (others => LWORD_NULL)
    );
end retmux;

architecture arch_retmux of retmux is

  -- front end
  signal fe_dValid : std_logic;
  signal fe_output : std_logic_vector(127 downto 0);

  -- backend 
  signal be_readyToTransmit : std_logic;
  signal be_rena            : std_logic;
  signal be_linksOut        : ldata(71 downto 0) := (others => LWORD_NULL);

  
begin  -- architecture arch_retmux

  
  -----------------------------------------------------------------------------
  -- output signals
  -----------------------------------------------------------------------------
  linksOut <= be_linksOut;


  -----------------------------------------------------------------------------
  -- input stage
  -----------------------------------------------------------------------------
  e_inputStage : entity work.inputStage
    generic map (
      tmux => tmux
      )
    port map (
      clkLink     => link_clk,
      clk         => clk,
      rst         => rst,
      linksIn     => linksIn,
      dValid      => fe_dValid,
      output      => fe_output
      );

  
  -----------------------------------------------------------------------------
  -- output stage
  -----------------------------------------------------------------------------
  e_outputStage : entity work.outputStage
    generic map (
      nFifosOut => tmux
      )
    port map (
      clk             => clk,
      rst             => rst,
      dValid          => fe_dValid,
      dIn             => fe_output,
      readyToTransmit => be_readyToTransmit,
      rena            => be_rena,
      linksOut        => be_linksOut
      );

  be_rena <= '1' when be_readyToTransmit = '1'
             else '0';
  
  
end architecture arch_retmux;


