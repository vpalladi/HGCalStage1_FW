--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! using the HGC data types
use work.hgc_data_types.all;

--! using the HGC constants
use work.hgc_constants.all;


entity ram2hgcWord is

  port (
    ram     : in  std_logic_vector(19 downto 0);
    hgcWord : out hgcWord := HGCWORD_NULL
    );

end entity ram2hgcWord;


architecture behavioural of ram2hgcWord is

begin  -- architecture behavioural

  hgcWord.address.col   <= ram( 2 downto 0 );
  hgcWord.address.row   <= ram( 5 downto 3 );
  hgcWord.address.wafer <= ram( 8 downto 6 );
  hgcWord.energy        <= ram( 16 downto 9 );
  hgcWord.valid         <= ram( 17 );
  hgcWord.SOE           <= ram( 18 );
  hgcWord.EOE           <= ram( 19 );

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

--! Using the Calo-L2 "mp7_data" data-types
use work.mp7_data_types.all;


entity ram2hgcFlaggedWord is

  port (
    ram            : in  std_logic_vector(31 downto 0);
    hgcFlaggedWord : out hgcFlaggedWord 
    );

end entity ram2hgcFlaggedWord;


architecture behavioural of ram2hgcFlaggedWord is
begin

  e_ram2hgcWord : entity work.ram2hgcWord
    port map (
      ram     => ram(19 downto 0),
      hgcWord => hgcFlaggedWord.word
      );

  hgcFlaggedWord.bxId     <= ram(27 downto 20) ;
  hgcFlaggedWord.dataFlag <= ram(28) ;
  hgcFlaggedWord.seedFlag <= ram(29) ;

end architecture behavioural;





