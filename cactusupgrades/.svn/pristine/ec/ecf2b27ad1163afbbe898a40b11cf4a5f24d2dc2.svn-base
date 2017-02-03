--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.math_real.ALL ; -- for UNIFORM , TRUNC functions

--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;

--! Writing to and from files
USE STD.TEXTIO.ALL;

PACKAGE jet_functions IS
  FUNCTION "+" ( L , R               : tJet ) RETURN tJet;
  FUNCTION "-" ( L , R               : tJet ) RETURN tJet;

  FUNCTION ToJet( aTower             : tTower ) RETURN tJet;

  FUNCTION ToJet( aJet               : tJet ) RETURN tJet;
  FUNCTION ToJet( aJet               : tJet ; aEta , aPhi : INTEGER ) RETURN tJet;

  FUNCTION ToJetNoEcal( aJet         : tJet ) RETURN tJet;
  FUNCTION ToJetNoEcal( aJet         : tJet ; aEta , aPhi : INTEGER ) RETURN tJet;


  FUNCTION ">" ( Left , Right        : tJet ) RETURN BOOLEAN;

-- FUNCTION "=" ( Left , Right : tJet ) RETURN BOOLEAN;
  FUNCTION "=" ( Left , Right        : tJetInPhi ) RETURN BOOLEAN;
  FUNCTION "=" ( Left , Right        : tJetInEtaPhi ) RETURN BOOLEAN;

  FUNCTION InsertionSort( Curr , Acc : tJet ; Carry : tJetInPhi ) RETURN tJetInPhi;


END PACKAGE jet_functions;

PACKAGE BODY jet_functions IS

  FUNCTION "+" ( L , R : tJet ) RETURN tJet IS
    VARIABLE ret       : tJet;
  BEGIN

      ret.Energy( 15 DOWNTO 0 ) := L.Energy + R.Energy;
      ret.Ecal( 15 DOWNTO 0 )   := L.Ecal + R.Ecal;
      ret.DataValid             := TRUE;

      RETURN ret;
  END "+";

  FUNCTION "-" ( L , R : tJet ) RETURN tJet IS
    VARIABLE energy    : INTEGER;
    VARIABLE ret       : tJet := cEmptyJet;
  BEGIN

       energy := TO_INTEGER( L.Energy ) - TO_INTEGER( R.Energy );

      IF( energy > 0 ) THEN
        ret.Energy := TO_UNSIGNED( energy , 16 );
      END IF;

      ret.DataValid := TRUE;

      RETURN ret;
  END "-";

  FUNCTION ToJet( aTower : tTower ) RETURN tJet IS
    VARIABLE ret         : tJet;
  BEGIN
      ret.Energy    := "0000000" & aTower.Energy;
      ret.Ecal      := "0000000" & aTower.Ecal;
      ret.DataValid := aTower.DataValid;
      RETURN ret;
  END ToJet;

  FUNCTION ToJet( aJet : tJet ) RETURN tJet IS
    VARIABLE ret       : tJet;
  BEGIN
      ret.Energy    := aJet.Energy;
      ret.Ecal      := aJet.Ecal;
      ret.DataValid := aJet.DataValid;

      ret.Eta       := 0;
      ret.Phi       := 0;
      ret.EtaHalf   := 0;

      RETURN ret;
  END ToJet;

  FUNCTION ToJet( aJet : tJet ; aEta , aPhi : INTEGER ) RETURN tJet IS
    VARIABLE ret       : tJet;
  BEGIN
      ret.Energy    := aJet.Energy;
      ret.Ecal      := aJet.Ecal;
      ret.DataValid := aJet.DataValid;

      ret.Eta       := aEta;
      ret.Phi       := aPhi;
      ret.EtaHalf   := 0;

      RETURN ret;
  END ToJet;


  FUNCTION ToJetNoEcal( aJet : tJet ) RETURN tJet IS
    VARIABLE ret             : tJet;
  BEGIN
      ret.Energy    := aJet.Energy;
      ret.Ecal      := ( OTHERS => '0' );
      ret.DataValid := aJet.DataValid;

      ret.Eta       := 0;
      ret.Phi       := 0;
      ret.EtaHalf   := 0;

      RETURN ret;
  END ToJetNoEcal;

  FUNCTION ToJetNoEcal( aJet : tJet ; aEta , aPhi : INTEGER ) RETURN tJet IS
    VARIABLE ret             : tJet;
  BEGIN
      ret.Energy    := aJet.Energy;
      ret.Ecal      := ( OTHERS => '0' );
      ret.DataValid := aJet.DataValid;

      ret.Eta       := aEta;
      ret.Phi       := aPhi;
      ret.EtaHalf   := 0;

      RETURN ret;
  END ToJetNoEcal;


  FUNCTION ">" ( Left , Right : tJet ) RETURN BOOLEAN IS
  BEGIN
    IF( NOT Left.DataValid ) THEN
      RETURN FALSE;
    END IF;

    IF( NOT Right.DataValid ) THEN
      RETURN TRUE;
    END IF;

    IF for_synthesis THEN
      RETURN( Left.Energy > Right.Energy );
    ELSE
      IF( Left.Energy /= Right.Energy ) THEN RETURN Left.Energy > Right.Energy ; END IF;
      IF( Left.EtaHalf /= Right.EtaHalf ) THEN RETURN Left.EtaHalf > Right.EtaHalf ; END IF;
      IF( Left.Eta /= Right.Eta ) THEN RETURN Left.Eta > Right.Eta ; END IF;
      IF( Left.Phi /= Right.Phi ) THEN RETURN Left.Phi > Right.Phi ; END IF;
      IF( Left.LargePileup /= Right.LargePileup ) THEN RETURN Left.LargePileup ; END IF;

      RETURN TRUE;
    END IF;

  END FUNCTION;


-- FUNCTION "=" ( Left , Right : tJet ) RETURN BOOLEAN IS
-- BEGIN
-- IF( Left.DataValid /= Right.DataValid ) OR( Left.Energy /= Right.Energy ) THEN
-- RETURN FALSE;
-- END IF;
--
-- RETURN( Left.Energy = 0 ) OR( ( Left.Phi = Right.Phi ) AND( Left.Eta = Right.Eta ) AND( Left.EtaHalf = Right.EtaHalf ) );
-- END FUNCTION;

  FUNCTION "=" ( Left , Right : tJetInPhi ) RETURN BOOLEAN IS
    VARIABLE retval           : BOOLEAN := true;
  BEGIN
    FOR i IN Left'LENGTH-1 DOWNTO 0 LOOP
      retval := retval AND( Left( i ) = Right( i ) );
    END LOOP;
  RETURN retval;
  END FUNCTION;

  FUNCTION "=" ( Left , Right : tJetInEtaPhi ) RETURN BOOLEAN IS
    VARIABLE retval           : BOOLEAN := true;
  BEGIN
    FOR i IN 0 TO cRegionInEta-1 LOOP
      retval := retval AND( Left( i ) = Right( i ) );
    END LOOP;
    RETURN retval;
  END FUNCTION;


  FUNCTION InsertionSort( Curr , Acc : tJet ; Carry : tJetInPhi ) RETURN tJetInPhi IS
    VARIABLE input                   : tJetInPhi( 1 DOWNTO 0 )                := ( OTHERS => cEmptyJet );
    VARIABLE retval                  : tJetInPhi( Carry'LENGTH + 1 DOWNTO 0 ) := ( OTHERS => cEmptyJet );

    VARIABLE input_index             : INTEGER RANGE 0 TO 2                   := 0;
    VARIABLE carry_index             : INTEGER RANGE 0 TO Carry'LENGTH        := 0;
  BEGIN

    IF Curr > Acc THEN
      input( 0 ) := Curr;
      input( 1 ) := Acc;
    ELSE
      input( 0 ) := Acc;
      input( 1 ) := Curr;
    END IF;

    input_index := 0;
    carry_index := 0;

    L1 : FOR retval_index IN 0 TO Carry'LENGTH + 1 LOOP
      IF input_index = 2 THEN
        retval( retval_index ) := carry( carry_index );
        carry_index            := carry_index + 1;
      ELSIF carry_index = Carry'LENGTH THEN
        retval( retval_index ) := input( input_index );
        input_index            := input_index + 1;
      ELSIF input( input_index ) > carry( carry_index ) THEN
        retval( retval_index ) := input( input_index );
        input_index            := input_index + 1;
      ELSE
        retval( retval_index ) := carry( carry_index );
        carry_index            := carry_index + 1;
      END IF;
    END LOOP;

    RETURN retval;
  END FUNCTION;

END jet_functions;
