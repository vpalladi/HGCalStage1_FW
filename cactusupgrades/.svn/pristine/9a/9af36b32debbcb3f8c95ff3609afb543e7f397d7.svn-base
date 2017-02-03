--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;

PACKAGE tower_functions IS
  FUNCTION "+" ( L , R      : tTower ) RETURN tTower;

  FUNCTION ToTower( Data    : STD_LOGIC_VECTOR( 15 DOWNTO 0 ) ; eta : INTEGER ) RETURN tTower;
  FUNCTION FromTower( Tower : tTower ) RETURN STD_LOGIC_VECTOR;

END PACKAGE tower_functions;

PACKAGE BODY tower_functions IS

  FUNCTION "+" ( L , R : tTower ) RETURN tTower IS
    VARIABLE ret       : tTower;
  BEGIN

      ret.EgammaCandidate := L.EgammaCandidate OR R.EgammaCandidate;
      ret.HcalFeature     := L.HcalFeature OR R.HcalFeature;
      ret.Ecal            := L.Ecal + R.Ecal;
      ret.Hcal            := L.Hcal + R.Hcal;
      ret.Energy          := L.Energy + R.Energy;
      ret.DataValid       := TRUE;

      RETURN ret;
  END "+";

  FUNCTION ToTower( Data                                   : STD_LOGIC_VECTOR( 15 DOWNTO 0 ) ; eta : INTEGER ) RETURN tTower IS
    VARIABLE lTower                                        : tTower  := cEmptyTower;
    VARIABLE DenominatorCoefficient , NumeratorCoefficient : INTEGER := 0;
  BEGIN
-- lTower.EgammaCandidate := ( Data( 15 ) ='0' );

    IF( Data( 13 ) = '0' ) THEN
      lTower.EgammaCandidate := FALSE;
    ELSIF( Data( 12 ) = '1' ) THEN
      lTower.EgammaCandidate := ( Data( 15 ) = '0' );
    ELSIF( eta < 15 ) THEN
      lTower.EgammaCandidate := ( Data( 15 ) = '0' ) AND( UNSIGNED( Data( 11 DOWNTO 9 ) ) > "100" );
    ELSE
      lTower.EgammaCandidate := ( Data( 15 ) = '0' ) AND( UNSIGNED( Data( 11 DOWNTO 9 ) ) > "011" );
    END IF;

    lTower.HasEM       := ( Data( 12 ) = '0' ) OR( Data( 13 ) = '1' );
    lTower.HcalFeature := ( Data( 14 ) ='1' );
    lTower.Energy      := UNSIGNED( Data( 8 DOWNTO 0 ) );

    IF( Data( 12 ) = '0' ) THEN
      CASE Data( 11 DOWNTO 9 ) IS
        WHEN "000" =>
          DenominatorCoefficient := 64;
          NumeratorCoefficient   := 64;
        WHEN "001" =>
          DenominatorCoefficient := 43;
          NumeratorCoefficient   := 85;
        WHEN "010" =>
          DenominatorCoefficient := 26;
          NumeratorCoefficient   := 102;
        WHEN "011" =>
          DenominatorCoefficient := 14;
          NumeratorCoefficient   := 114;
        WHEN "100" =>
          DenominatorCoefficient := 8;
          NumeratorCoefficient   := 120;
        WHEN "101" =>
          DenominatorCoefficient := 4;
          NumeratorCoefficient   := 124;
        WHEN "110" =>
          DenominatorCoefficient := 2;
          NumeratorCoefficient   := 126;
        WHEN "111" =>
          DenominatorCoefficient := 1;
          NumeratorCoefficient   := 127;
        WHEN OTHERS =>
          DenominatorCoefficient := 0;
          NumeratorCoefficient   := 0;
      END CASE;
    ELSE
      DenominatorCoefficient := 0;
      NumeratorCoefficient   := 128;
    END IF;

    IF Data( 13 ) = '1' THEN
        lTower.Hcal := TO_UNSIGNED( ( TO_INTEGER( lTower.Energy ) * DenominatorCoefficient ) / 128 , 9 );
        lTower.Ecal := TO_UNSIGNED( ( TO_INTEGER( lTower.Energy ) * NumeratorCoefficient ) / 128 , 9 );
    ELSE
        lTower.Hcal := TO_UNSIGNED( ( TO_INTEGER( lTower.Energy ) * NumeratorCoefficient ) / 128 , 9 );
        lTower.Ecal := TO_UNSIGNED( ( TO_INTEGER( lTower.Energy ) * DenominatorCoefficient ) / 128 , 9 );
    END IF;

    lTower.DataValid := TRUE;

    RETURN lTower;
  END ToTower;





  FUNCTION FromTower( Tower : tTower ) RETURN STD_LOGIC_VECTOR IS
    VARIABLE lLink          : STD_LOGIC_VECTOR( 15 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
    lLink( 15 )         := TO_STD_LOGIC( Tower.EgammaCandidate );
    lLink( 14 )         := TO_STD_LOGIC( Tower.HcalFeature );
    lLink( 13 )         := '1';
    lLink( 12 )         := '1';
-- Ignoring the Ecal Hcal ratio stuff...
    lLink( 8 DOWNTO 0 ) := STD_LOGIC_VECTOR( Tower.Energy );
    RETURN lLink;
  END FromTower;








END tower_functions;
