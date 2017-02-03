--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! using the HGC data types
use work.hgc_data_types.all;

--! Using the Calo-L2 "mp7_data" data-types
use work.mp7_data_types.all;



entity hgc2mp7Word is

  port (
    hgcWord : in  hgcWord := HGCWORD_NULL;
    mp7Word : out lword := LWORD_NULL
    );

end entity hgc2mp7Word;


architecture behavioural of hgc2mp7Word is

begin  -- architecture behavioural

  mp7Word.data(7 downto 0)  <= hgcWord.energy;
  mp7Word.data(15 downto 8) <= hgcWord.address.row & hgcWord.address.col;

end architecture behavioural;



--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

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
    mp7Data(ilink).data(7 downto 0)  <= x"bc" when hgcFlaggedData(ilink).EOE = '1' else
                                        hgcFlaggedData(ilink).energy;
    mp7Data(ilink).data(15 downto 8) <= x"bc" when hgcFlaggedData(ilink).EOE = '1' else
                                        hgcFlaggedData(ilink).address.col & hgcFlaggedData(ilink).address.row;
    mp7Data(ilink).data(16) <= '0' when hgcFlaggedData(ilink).EOE = '1' else
                               hgcFlaggedData(ilink).seedFlag;
    mp7Data(ilink).data(31 downto 17) <= "101" & x"e5e" when hgcFlaggedData(ilink).EOE = '1' else
    (others => '0');      
    mp7Data(ilink).valid  <= '1';
    mp7Data(ilink).start  <= '0';
    mp7Data(ilink).strobe  <= '0';
  end generate gen_links;

end architecture behavioural;


