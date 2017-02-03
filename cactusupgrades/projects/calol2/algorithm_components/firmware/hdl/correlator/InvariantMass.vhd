--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 "correlator" data-types
USE work.correlator_types.ALL;

ENTITY InvariantMass IS
  PORT(
    clk                     : IN STD_LOGIC  := '0' ; --! The algorithm clock
    Candidate1 , Candidate2 : IN tCandidate := cEmptyCandidate
  );
END InvariantMass;

ARCHITECTURE behavioral OF InvariantMass IS
  SIGNAL AbsDPhi , AbsDEta : STD_LOGIC_VECTOR( 7 DOWNTO 0 )  := ( OTHERS => '0' );
  SIGNAL CosAbsDPhi        : STD_LOGIC_VECTOR( 9 DOWNTO 0 )  := ( OTHERS => '0' );
  SIGNAL CoshAbsDEta       : STD_LOGIC_VECTOR( 20 DOWNTO 0 ) := ( OTHERS => '0' );

BEGIN

  p1 : PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
-- -----------------------
      IF Candidate1.Phi > Candidate2.Phi THEN
        AbsDPhi <= STD_LOGIC_VECTOR( Candidate1.Phi - Candidate2.Phi );
      ELSE
        AbsDPhi <= STD_LOGIC_VECTOR( Candidate2.Phi - Candidate1.Phi );
      END IF;
-- -----------------------
      IF Candidate1.Eta > Candidate2.Eta THEN
        AbsDEta <= STD_LOGIC_VECTOR( Candidate1.Eta - Candidate2.Eta );
      ELSE
        AbsDEta <= STD_LOGIC_VECTOR( Candidate2.Eta - Candidate1.Eta );
      END IF;
-- -----------------------
    END IF;
  END PROCESS;

  CosLutInstance : ENTITY work.GenRomClocked
  GENERIC MAP(
    FileName => "alpha_cos_8to9.mif"
  )
  PORT MAP
  (
    clk       => Clk ,
    AddressIn => AbsDPhi ,
    DataOut   => CosAbsDPhi
  );

  CoshLutInstance : ENTITY work.GenRomClocked
  GENERIC MAP(
    FileName => "beta_cosh_8to18.mif"
  )
  PORT MAP
  (
    clk       => Clk ,
    AddressIn => AbsDEta ,
    DataOut   => CosAbsDEta( 20 DOWNTO 3 )
  );

END ARCHITECTURE behavioral;
