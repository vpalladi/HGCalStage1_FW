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


entity SeedingLinks is
  
  port (

    clk : in STD_LOGIC;
    
    energyThreshold : in std_logic_vector(7 downto 0);
    
    linksIn                               : IN  ldata  ( 71 DOWNTO 0 )        := (others => LWORD_NULL);
    flaggedDataOut                            : OUT hgcFlaggedData( 71 DOWNTO 0 ) := (others => HGCFLAGGEDWORD_NULL)
    
  );

end entity SeedingLinks;

architecture behavioral of SeedingLinks is

  signal hgcDataIn : hgcData( 71 DOWNTO 0 );
  
begin  -- architecture behavioral

  genLinksIn: for ilink in 71 downto 0 generate

    e_mp72hgcWord: entity work.mp72hgcWord
      port map (
        mp7Word => linksIn(ilink),
        hgcWord => hgcDataIn(ilink)
        );
    
    flagSeed : entity work.SeedingLink
      port map (
        clk                => clk,
        energyThreshold    => energyThreshold,
        wordIn          => hgcDataIn(ilink),
        flaggedWordOut  => flaggedDataOut(ilink)
        );
    
  end generate genLinksIn;

end architecture behavioral;
