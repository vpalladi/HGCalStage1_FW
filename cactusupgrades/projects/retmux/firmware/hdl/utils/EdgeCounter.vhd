--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;


entity EdgeCounter IS
  generic(
    max : natural
    );
  port(
    clk      : in std_logic ; --! The algorithm clock
    rst      : in std_logic ;
    input    : in std_logic;
    output   : inout std_logic;

    counter  : out natural
    );
end entity EdgeCounter;

architecture behavioral of EdgeCounter is

  signal input_1 : std_logic;
  --signal output  : std_logic;
  
begin

  -- detect edges
  e_EdgeDetection: entity work.EdgeDetection
    port map (
      clk    => clk,
      input  => input,
      output => output
      );

  --counter
  e_Counter: entity work.Counter
    generic map (
      max => max
      )
    port map (
      clk     => clk,
      rst     => rst,
      ena     => output,
      counter => counter
      );

end architecture behavioral;
