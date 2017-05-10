--! Using the IEEE Library
library IEEE;
--! Using STD_LOGIC
use IEEE.STD_LOGIC_1164.all;
--! Using NUMERIC TYPES
use IEEE.NUMERIC_STD.all;

--! using the HGC data types
use work.hgc_data_types.all;

--! using the HGC data types
use work.mp7_data_types.all;


entity SeedingLink is

  port (

    clk : in std_logic;
    rst : in std_logic;
    
    energyThreshold : in std_logic_vector(7 downto 0);

    mp7wordIn      : in  lword;         -- 8b address 8b data(energy)
    flaggedWordOut : out hgcFlaggedWord

    );

end entity SeedingLink;

architecture behavioral of SeedingLink is

  signal wordIn : hgcWord := HGCWORD_NULL;
    
begin  -- architecture behavioral

  -- translate into HGC format
  e_mp72hgcWord : entity work.mp72hgcWord
    port map (
      mp7Word => mp7wordIn,
      hgcWord => wordIn
      );

  -- seeding the data
  p_SeedFlag : process (clk) is
    variable bxId : std_logic_vector(7 downto 0) := (others => '0');
  begin
    if rising_edge(clk) then

      flaggedWordOut.word <= wordIn;
      flaggedWordOut.bxId <= bxId;
      
      if rst = '0' then
        bxId := (others => '0');
      elsif wordIn.EOE = '0' and wordIn.energy > energyThreshold then
        flaggedWordOut.seedFlag <= '1';
        flaggedWordOut.dataFlag <= '0';
      elsif wordin.EOE = '0' then
        flaggedWordOut.seedFlag <= '0';
        flaggedWordOut.dataFlag <= '1';
      elsif wordIn.EOE = '1' then
        bxId := std_logic_vector( unsigned(bxId) + 1 );        
      end if;

      
      
    end if;
  end process;

end architecture behavioral;
