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

    clk : in std_logic;
    energyThreshold : in std_logic_vector(7 downto 0);
    
    linksIn         : in  ldata  ( 71 DOWNTO 0 )        := (others => LWORD_NULL);
    flaggedDataOut  : out hgcFlaggedData( 71 DOWNTO 0 ) := (others => HGCFLAGGEDWORD_NULL)
    
  );

end entity SeedingLinks;

architecture behavioral of SeedingLinks is

begin  -- architecture behavioral

  gen_LinksIn: for ilink in 71 downto 0 generate

    flagSeed : entity work.SeedingLink
      port map (
        clk                => clk,
        energyThreshold    => energyThreshold,
        mp7wordIn          => linksIn(ilink),
        flaggedWordOut     => flaggedDataOut(ilink)
        );
    
  end generate gen_LinksIn;

end architecture behavioral;
