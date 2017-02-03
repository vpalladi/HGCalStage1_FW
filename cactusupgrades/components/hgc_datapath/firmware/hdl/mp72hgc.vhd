--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! using the HGC data types
USE work.hgc_data_types.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;


entity mp72hgcWord is
  
  port (
    mp7Word : in lword := LWORD_NULL;
    hgcWord : out hgcWord := HGCWORD_NULL
  );

end entity mp72hgcWord;


architecture behavioural of mp72hgcWord is

begin  -- architecture behavioural
  
  hgcWord.energy  <= mp7Word.data(7 downto 0);
  hgcWord.address.row <= mp7Word.data(15 downto 12);
  hgcWord.address.col <= mp7Word.data(11 downto 8);
  hgcWord.valid <= mp7Word.valid;
  
end architecture behavioural;


--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! using the HGC data types
USE work.hgc_data_types.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;


entity mp72hgcFlaggedWord is
  
  port (
    mp7Word : in lword := LWORD_NULL;
    hgcFlaggedWord : out hgcFlaggedWord := HGCFLAGGEDWORD_NULL
  );

end entity mp72hgcFlaggedWord;


architecture behavioural of mp72hgcFlaggedWord is

begin
  
  hgcFlaggedWord.energy      <= (others => '0') when mp7Word.data = x"bcbcbcbc" else
                                mp7Word.data(7 downto 0);
  hgcFlaggedWord.address.col <= (others => '0') when mp7Word.data = x"bcbcbcbc" else
                                mp7Word.data(15 downto 12);
  hgcFlaggedWord.address.row <= (others => '0') when mp7Word.data = x"bcbcbcbc" else
                                mp7Word.data(11 downto 8);
  hgcFlaggedWord.valid       <= mp7Word.valid;
  hgcFlaggedWord.dataFlag <= '0';
  hgcFlaggedWord.seedFlag <= '0' when mp7Word.data = x"bcbcbcbc" else
                             mp7Word.data(17);
  hgcFlaggedWord.EOE <= '1' when mp7Word.data = x"bcbcbcbc" else
                        '0';

  
end architecture behavioural;





