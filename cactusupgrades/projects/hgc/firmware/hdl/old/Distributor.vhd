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

-------------------------------------------------------------------------------
-- temporary
-------------------------------------------------------------------------------
-- I/O
use IEEE.STD_LOGIC_TEXTIO.all;
use STD.TEXTIO.all;


entity distributor is
  
  generic (
    nClusters : integer := 56);

  port (
    clk           : in  std_logic;
    rst           : in  std_logic;
    flaggedWordIn : in  hgcFlaggedWord;
    bxCounter     : out std_logic_vector(31 downto 0));

end entity distributor;

architecture distributor_arch of distributor is

  signal bxCounter_internal : std_logic_vector(31 downto 0) := (others => '0');
  signal wrSeedPtr : std_logic_vector := (others => '0');
  signal wrWordPtr : std_logic_vector := (others => '0');

begin  -- architecture distributor_arch

  bxCounter <= bxCounter_internal;

  process_countingBx: process (clk, rst) is
  begin
    if rising_edge(clk) then  -- rising clock edge
      if rst = '0' then
        bxCounter_internal <= (others => '0');
      else
        if flaggedWordIn =  then
          
        end if;
      end if;
      
    end if;
  end process process_countingBx;

  

end architecture distributor_arch;
