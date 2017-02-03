--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;

--! @brief An entity providing a JetSum
--! @details Detailed description
ENTITY JetSum IS
  PORT(
    clk    : IN STD_LOGIC := '0' ; --! The algorithm clock
    jetIn1 : IN tJet      := cEmptyJet;
    jetIn2 : IN tJet      := cEmptyJet;
    jetIn3 : IN tJet      := cEmptyJet;
    jetOut : OUT tJet     := cEmptyJet
  );
END JetSum;

--! @brief Architecture definition for entity JetSum
--! @details Detailed description
ARCHITECTURE behavioral OF JetSum IS
  SIGNAL jetTmp              : tJet := cEmptyJet;
  SIGNAL EnergyTmp , EcalTmp : STD_LOGIC_VECTOR( 21 DOWNTO 0 );
BEGIN
  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF( NOT jetIn1.DataValid ) THEN
        jetOut <= cEmptyJet;
      ELSE
        jetOut.Energy( 15 DOWNTO 0 ) <= jetIn1.Energy + jetIn2.Energy + jetIn3.Energy;
        jetOut.Ecal( 15 DOWNTO 0 )   <= jetIn1.Ecal + jetIn2.Ecal + jetIn3.Ecal;
        jetOut.DataValid             <= TRUE;
      END IF;
    END IF;
  END PROCESS;


-- ThreeInputEnergySum : entity work.ThreeInputAdd
-- PORT MAP(
-- clk => clk ,
-- a => std_logic_vector( "0000" & jetIn1.Energy ) ,
-- c => std_logic_vector( "0000" & jetIn2.Energy ) ,
-- d => std_logic_vector( "0000" & jetIn3.Energy ) ,
-- p => EnergyTmp
-- );
--
--
-- ThreeInputEcalSum : entity work.ThreeInputAdd
-- PORT MAP(
-- clk => clk ,
-- a => std_logic_vector( "0000" & jetIn1.Ecal ) ,
-- c => std_logic_vector( "0000" & jetIn2.Ecal ) ,
-- d => std_logic_vector( "0000" & jetIn3.Ecal ) ,
-- p => EcalTmp
-- );
--
-- jetTmp.Energy <= unsigned( EnergyTmp( 15 DOWNTO 0 ) );
-- jetTmp.Ecal <= unsigned( EcalTmp( 15 DOWNTO 0 ) );
-- jetTmp.DataValid <= ( jetIn1.DataValid AND jetIn2.DataValid AND jetIn3.DataValid ) when RISING_EDGE( clk );
--
-- jetOut <= jetTmp when jetTmp.DataValid else cEmptyJet;

END ARCHITECTURE behavioral;

-- ----------------------------------------------------------------------------------------------

--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;

--! @brief An entity providing a JetSum2
--! @details Detailed description
ENTITY JetSum2 IS
  PORT(
    clk    : IN STD_LOGIC := '0' ; --! The algorithm clock
    jetIn1 : IN tJet      := cEmptyJet;
    jetIn2 : IN tJet      := cEmptyJet;
    jetOut : OUT tJet     := cEmptyJet
  );
END JetSum2;

--! @brief Architecture definition for entity JetSum2
--! @details Detailed description
ARCHITECTURE behavioral OF JetSum2 IS
  SIGNAL jetTmp              : tJet := cEmptyJet;
  SIGNAL EnergyTmp , EcalTmp : STD_LOGIC_VECTOR( 21 DOWNTO 0 );
BEGIN
  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF( NOT jetIn1.DataValid OR NOT jetIn2.DataValid ) THEN
        jetOut <= cEmptyJet;
      ELSE
        jetOut.Energy( 15 DOWNTO 0 ) <= jetIn1.Energy + jetIn2.Energy;
        jetOut.Ecal( 15 DOWNTO 0 )   <= jetIn1.Ecal + jetIn2.Ecal;
        jetOut.DataValid             <= TRUE;
      END IF;
    END IF;
  END PROCESS;

-- TwoInputEnergySum : entity work.TwoInputAdd
-- PORT MAP(
-- clk => clk ,
-- a => std_logic_vector( "0000" & jetIn1.Energy ) ,
-- d => std_logic_vector( "0000" & jetIn2.Energy ) ,
-- p => EnergyTmp
-- );
--
-- TwoInputEcalSum : entity work.TwoInputAdd
-- PORT MAP(
-- clk => clk ,
-- a => std_logic_vector( "0000" & jetIn1.Ecal ) ,
-- d => std_logic_vector( "0000" & jetIn2.Ecal ) ,
-- p => EcalTmp
-- );
--
-- jetTmp.Energy <= unsigned( EnergyTmp( 15 DOWNTO 0 ) );
-- jetTmp.Ecal <= unsigned( EcalTmp( 15 DOWNTO 0 ) );
-- jetTmp.DataValid <= ( jetIn1.DataValid AND jetIn2.DataValid ) when RISING_EDGE( clk );
--
-- jetOut <= jetTmp when jetTmp.DataValid else cEmptyJet;

END ARCHITECTURE behavioral;
