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


entity hgc2mp7Word is

  port (
    hgcWord : in  hgcWord := HGCWORD_NULL;
    mp7Word : out lword   := LWORD_NULL
    );

end entity hgc2mp7Word;


architecture behavioural of hgc2mp7Word is
    --signal z : std_logic_array( 14 downto 0 );
begin  -- architecture behavioural

  --  z <= (others => '0 ');
  
  --mp7word.data( (mp7Word.data'length-1) downto (ENERGY_OFFSET + ENERGY_WIDTH) ) <= "101111001011110" when hgcWord.EOE = '1' else (others => '0');
  --mp7Word.data( (ENERGY_OFFSET + ENERGY_WIDTH - 1) downto ENERGY_OFFSET )       <= "01011110"        when hgcWord.EOE = '1' else hgcWord.energy;
  --mp7Word.data( (WAFER_OFFSET + WAFER_WIDTH - 1) downto WAFER_OFFSET )          <= "010"             when hgcWord.EOE = '1' else hgcWord.address.wafer;
  --mp7Word.data( (ROW_OFFSET + ROW_WIDTH - 1) downto ROW_OFFSET )                <= "111"             when hgcWord.EOE = '1' else hgcWord.address.row;
  --mp7Word.data( (COL_OFFSET + COL_WIDTH - 1) downto COL_OFFSET )                <= "100"             when hgcWord.EOE = '1' else hgcWord.address.col;

  mp7Word.data <= x"FBFBFBFB" when hgcWord.SOE = '1' else
                  x"BCBCBCBC" when hgcWord.EOE = '1' else
                  "000000000000000" & hgcWord.energy & hgcWord.address.wafer & hgcWord.address.row & hgcWord.address.col;
  --                  z & hgcWord.energy & hgcWord.address.wafer & hgcWord.address.row & hgcWord.address.col;
  
  mp7Word.valid  <= hgcWord.valid;
  
  mp7Word.start  <= '0';
  mp7Word.strobe <= '0';

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


entity hgc2mp7FlaggedWord is

  port (
    hgcFlaggedWord : in  hgcFlaggedWord := HGCFLAGGEDWORD_NULL;
    mp7Word        : out lword          := LWORD_NULL
    );

end entity hgc2mp7FlaggedWord;


architecture behavioural of hgc2mp7FlaggedWord is

begin  -- architecture behavioural

  e_hgc2mp7Word: entity work.hgc2mp7Word
    port map (
      hgcWord => hgcFlaggedWord.word,
      mp7Word => mp7Word
      );
  
  --mp7word.data((mp7Word.data'length-1) downto (ENERGY_OFFSET + ENERGY_WIDTH)) <= "101111001011110" when hgcFlaggedWord.word.EOE = '1' else (others => '0');
  --mp7Word.data((ENERGY_OFFSET + ENERGY_WIDTH - 1) downto ENERGY_OFFSET)       <= "01011110"        when hgcFlaggedWord.word.EOE = '1' else hgcFlaggedWord.word.energy;
  --mp7Word.data((WAFER_OFFSET + WAFER_WIDTH - 1) downto WAFER_OFFSET)          <= "010"             when hgcFlaggedWord.word.EOE = '1' else hgcFlaggedWord.word.address.wafer;
  --mp7Word.data((ROW_OFFSET + ROW_WIDTH - 1) downto ROW_OFFSET)                <= "111"             when hgcFlaggedWord.word.EOE = '1' else hgcFlaggedWord.word.address.row;
  --mp7Word.data((COL_OFFSET + COL_WIDTH - 1) downto COL_OFFSET)                <= "100"             when hgcFlaggedWord.word.EOE = '1' else hgcFlaggedWord.word.address.col;
  --mp7Word.data(16)                                                             <= '0' when hgcFlaggedWord.word.EOE = '1' else hgcFlaggedWord.seedFlag;
  --mp7Word.data(31 downto 17) <= "101" & x"e5e" when hgcFlaggedWord.word.EOE = '1' else (others => '0');
  --mp7Word.valid                                                               <= hgcFlaggedWord.word.valid;

 

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


entity hgc2mp7FlaggedData is
  generic (
    nWords : integer := 72
    );
  port (
    hgcFlaggedData : in  hgcFlaggedData(nWords-1 downto 0) := (others => HGCFLAGGEDWORD_NULL);
    mp7Data        : out ldata(nWords-1 downto 0)          := (others => LWORD_NULL)
    );

end entity hgc2mp7FlaggedData;


architecture behavioural of hgc2mp7FlaggedData is

begin  -- architecture behavioural

  gen_links : for ilink in nWords-1 downto 0 generate

    e_hgc2mp7FlaggedWord : entity work.hgc2mp7FlaggedWord
      port map(
        hgcFlaggedWord => hgcFlaggedData(ilink),
        mp7Word        => mp7Data(ilink)
        );

    --mp7Data(ilink).data(  mp7Data(ilink).data'length-1 downto ( ENERGY_OFFSET + ENERGY_WIDTH ) ) <= "101111001011110" when hgcFlaggedData(ilink).word.EOE = '1' else (others => '0');                
    --mp7Data(ilink).data( ( ENERGY_OFFSET + ENERGY_WIDTH - 1 ) downto ENERGY_OFFSET )             <= "01011110" when hgcFlaggedData(ilink).word.EOE = '1' else hgcFlaggedData(ilink).energy;
    --mp7Data(ilink).data( ( WAFER_OFFSET  + WAFER_WIDTH - 1  ) downto WAFER_OFFSET  )             <= "010" when hgcFlaggedData(ilink).word.EOE = '1' else hgcFlaggedData(ilink).word.address.wafer;
    --mp7Data(ilink).data( ( ROW_OFFSET    + ROW_WIDTH - 1    ) downto ROW_OFFSET    )             <= "111" when hgcFlaggedData(ilink).word.EOE = '1' else hgcFlaggedData(ilink).word.address.row;
    --mp7Data(ilink).data( ( COL_OFFSET    + COL_WIDTH - 1    ) downto COL_OFFSET    )             <= "100" when hgcFlaggedData(ilink).word.EOE = '1' else hgcFlaggedData(ilink).word.address.col;
    ----mp7Data(ilink).data(16)                                                                      <= '0' when hgcFlaggedData(ilink).word.EOE = '1' else hgcFlaggedData(ilink).seedFlag;
    ----mp7Data(ilink).data(31 downto 17) <= "101" & x"e5e" when hgcFlaggedData(ilink).word.EOE = '1' else (others => '0');
    --mp7Data(ilink).word.valid  <= hgcFlaggedData(ilink).word.valid;
    --
    --mp7Data(ilink).start  <= '0';
    --mp7Data(ilink).strobe <= '0';

  end generate gen_links;

end architecture behavioural;



