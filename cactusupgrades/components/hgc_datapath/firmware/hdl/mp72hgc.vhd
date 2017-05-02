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

--! Using the Calo-L2 "mp7_data" data-types
use work.mp7_data_types.all;


entity mp72hgcWord is

  port (
    mp7Word : in  lword   := LWORD_NULL;
    hgcWord : out hgcWord := HGCWORD_NULL
    );

end entity mp72hgcWord;


architecture behavioural of mp72hgcWord is

begin  -- architecture behavioural

  hgcWord.valid         <= '1' when mp7Word.valid = '1' else '0';
  hgcWord.energy        <= (others => '0') when mp7Word.data = x"BCBCBCBC" or mp7Word.data = x"FBFBFBFB" else mp7Word.data((ENERGY_OFFSET + ENERGY_WIDTH - 1) downto ENERGY_OFFSET);
  hgcWord.address.wafer <= (others => '0') when mp7Word.data = x"BCBCBCBC" or mp7Word.data = x"FBFBFBFB" else mp7Word.data((WAFER_OFFSET + WAFER_WIDTH - 1) downto WAFER_OFFSET);
  hgcWord.address.col   <= (others => '0') when mp7Word.data = x"BCBCBCBC" or mp7Word.data = x"FBFBFBFB" else mp7Word.data((ROW_OFFSET + ROW_WIDTH - 1) downto ROW_OFFSET);
  hgcWord.address.row   <= (others => '0') when mp7Word.data = x"BCBCBCBC" or mp7Word.data = x"FBFBFBFB" else mp7Word.data((COL_OFFSET + COL_WIDTH - 1) downto COL_OFFSET);
  hgcWord.SOE           <= '1'             when mp7Word.data = x"FBFBFBFB" else '0';
  hgcWord.EOE           <= '1'             when mp7Word.data = x"BCBCBCBC" else '0';
  

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


entity mp72hgcFlaggedWord is

  port (
    mp7Word        : in  lword          := LWORD_NULL;
    hgcFlaggedWord : out hgcFlaggedWord 
    );

end entity mp72hgcFlaggedWord;


architecture behavioural of mp72hgcFlaggedWord is

begin

  e_mp72hgcWord : entity work.mp72hgcWord
    port map (
      mp7Word => mp7Word,
      hgcWord => hgcFlaggedWord.word
      );
  
  hgcFlaggedWord.dataFlag <= '0' ;
  hgcFlaggedWord.seedFlag <= '0' ; -- '0' when mp7Word.data = x"bcbcbcbc" else mp7Word.data(17);

end architecture behavioural;





