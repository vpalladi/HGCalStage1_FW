--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;


entity Counter IS
  generic(
    max : natural
    );
  port(
    clk      : in std_logic ; --! The algorithm clock
    rst      : in std_logic ;
    ena      : in std_logic ;
    
    counter  : out natural
    );
end entity Counter;

architecture arch_counter of Counter is

  signal output  : std_logic;
  
begin

  -- counter
  p_counting: process (clk, rst) is
    variable c : natural := 0;
  begin  -- process p_counting
    if rising_edge(clk) then  -- rising clock edge
      if rst = '1' or c = max then
        c := 0;
      elsif ena = '1' then
        c := c + 1;
      end if;
      counter <= c;
    end if;
  end process p_counting;
  
end architecture arch_counter;
