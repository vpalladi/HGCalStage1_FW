--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

-- generate a 1 clk pulse every rising edge of input
entity EdgeDetection IS
  port(
        clk      : IN STD_LOGIC ; --! The algorithm clock
        input    : IN STD_LOGIC;
        output   : OUT STD_LOGIC
      );
end entity EdgeDetection;

architecture behavioral of EdgeDetection is

  signal input_1 : STD_LOGIC;
  
begin

  p_delay : process (clk) is
  begin  -- process
    if rising_edge(clk) then  -- rising clock edge
      input_1 <= input;
    end if;
  end process;

  output <= (not input_1) and input;

end architecture behavioral;
