--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! using the HGC constants
use work.hgc_constants.all;
--! using the HGC data types
use work.hgc_data_types.all;

entity hgc2ram is

  port (
    hgcWord : in  hgcWord := HGCWORD_NULL;
    ram     : out std_logic_vector(19 downto 0)
    );

end entity hgc2ram;


architecture behavioural of hgc2ram is
begin

  ram <= hgcWord.EOE & hgcWord.SOE & hgcWord.energy & hgcWord.address.col & hgcWord.address.row & hgcWord.address.wafer & hgcWord.valid;

end architecture behavioural;



--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! using the HGC constants
use work.hgc_constants.all;
--! using the HGC data types
use work.hgc_data_types.all;


entity hgcFlagged2ram is

  port (
    hgcFlaggedWord : in  hgcFlaggedWord := HGCFLAGGEDWORD_NULL;
    ram            : out std_logic_vector(31 downto 0)
    );

end entity hgcFlagged2ram;

architecture behavioural of hgcFlagged2ram is
begin

  e_hgc2ram: entity work.hgc2ram
    port map (
      hgcWord => hgcFlaggedWord.word,
      ram     => ram(19 downto 0)
      );

  ram(31 downto 20) <= "00" & hgcFlaggedWord.seedFlag & hgcFlaggedWord.dataFlag & hgcFlaggedWord.bxId;
  
end architecture behavioural;

