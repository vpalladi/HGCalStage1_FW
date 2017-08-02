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


entity Link_test is
  generic (
    nClusters : natural := 5
    );
  port (
    clk    : in std_logic;
    rst    : in std_logic;
    
    -- seeding 
    energyThreshold    : in std_logic_vector(7 downto 0);

    mp7wordIn          : in  lword;         -- 8b address 8b data(energy)

    flaggedWordOut : out hgcFlaggedWord 
    
    );

end entity Link_test;

architecture Link_arch of Link_test is

  signal data : hgcFlaggedData(0 to 9);
  signal selector : natural := 0;
  
begin  -- architecture Link_arch

  data(0).word.energy <= x"00";
  data(1).word.energy <= x"01";
  data(2).word.energy <= x"02";
  data(3).word.energy <= x"03";
  data(4).word.energy <= x"04";
  data(5).word.energy <= x"05";
  data(6).word.energy <= x"06";
  data(7).word.energy <= x"07";
  data(8).word.energy <= x"08";
  data(9).word.energy <= x"09";

  p_counter: process (clk) is
  begin  -- process p_counter
    if rising_edge(clk) then                 -- asynchronous reset (active low)
      if selector = 9 then
        selector <= 0;
      else
        selector <= selector + 1;
      end if;
      
    end if;
  end process p_counter;

  MUX_1: entity work.MUX
    generic map (
      nInputs => 10
      )
    port map (
      inputs   => data,
      selector => selector,
      output   => flaggedWordOut
      );
      
end architecture Link_arch;

