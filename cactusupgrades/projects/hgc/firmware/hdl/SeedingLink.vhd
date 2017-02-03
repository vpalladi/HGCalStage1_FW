--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! using the HGC data types
USE work.hgc_data_types.ALL;


entity SeedingLink is
  
  port (

    clk : in STD_LOGIC;
    
    energyThreshold : in std_logic_vector(7 downto 0);
    
    wordIn  : in hgcWord ;  -- 8b address 8b data(energy)
    flaggedWordOut : out hgcFlaggedWord
    
  );

end entity SeedingLink;

architecture behavioral of SeedingLink is

begin  -- architecture behavioral

  proccessSeedFlag : process (clk) is
    
  begin

    if rising_edge(clk) then 

      if wordIn.energy > energyThreshold then 
        flaggedWordOut.seedFlag <= '1';       
      else
        flaggedWordOut.seedFlag <= '0';
      end if;
      flaggedWordOut.dataFlag <= '0';      
      
      
      flaggedWordOut.address <= wordIn.address;
      flaggedWordOut.energy  <= wordIn.energy;
      flaggedWordOut.valid  <= wordIn.valid;
      flaggedWordOut.EOE  <= wordIn.EOE;
        
    end if;
    
  end process proccessSeedFlag;

end architecture behavioral;
