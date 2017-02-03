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

--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;

--! Writing to and from files
USE STD.TEXTIO.ALL;

PACKAGE ring_functions IS
  FUNCTION "+" ( L , R                                     : tRingSegment ) RETURN tRingSegment;

   FUNCTION ToRingSegment( aTower                          : tTower ; aThreshold : UNSIGNED ; phi : INTEGER ) RETURN tRingSegment;
   FUNCTION ToRingSegment( aJet                            : tJet ) RETURN tRingSegment;

  FUNCTION SineCoefficient( aInputVal                      : INTEGER ) RETURN SIGNED;
  FUNCTION CosineCoefficient( aInputVal                    : INTEGER ) RETURN SIGNED;

  FUNCTION CordicRotation( step , phi_scale                : INTEGER ) RETURN INTEGER;
  FUNCTION CordicRenormalization( number_steps , hyp_scale : INTEGER ) RETURN INTEGER;

END PACKAGE ring_functions;

PACKAGE BODY ring_functions IS

  FUNCTION "+" ( L , R : tRingSegment ) RETURN tRingSegment IS
    VARIABLE ret       : tRingSegment := cEmptyRingSegment;
  BEGIN

      ret.xComponent := L.xComponent + R.xComponent;
      ret.yComponent := L.yComponent + R.yComponent;
      ret.towerCount := L.towerCount + R.towerCount;
      ret.Energy     := L.Energy + R.Energy;
      ret.Ecal       := L.Ecal + R.Ecal;
      ret.DataValid  := TRUE;

      RETURN ret;
  END "+";

  FUNCTION SineCoefficient( aInputVal : INTEGER ) RETURN SIGNED IS
    TYPE tLUT IS ARRAY( 0 TO 71 ) OF INTEGER;
    CONSTANT LUT : tLUT := ( 0 , 89 , 178 , 265 , 350 , 432 , 512 , 587 , 658 , 723 , 784 , 838 , 886 , 927 , 961 , 988 , 1007 , 1019 ,
                             1023 , 1019 , 1007 , 988 , 961 , 927 , 886 , 838 , 784 , 723 , 658 , 587 , 512 , 432 , 350 , 265 , 178 , 89 ,
                             0 , -89 , -178 , -265 , -350 , -432 , -512 , -587 , -658 , -723 , -784 , -838 , -886 , -927 , -961 , -988 , -1007 , -1019 ,
                             -1023 , -1019 , -1007 , -988 , -961 , -927 , -886 , -838 , -784 , -723 , -658 , -587 , -512 , -432 , -350 , -265 , -178 , -89
                           );
  BEGIN
    RETURN TO_SIGNED( LUT( MOD_PHI( aInputVal ) ) , 11 );
  END SineCoefficient;

  FUNCTION CosineCoefficient( aInputVal : INTEGER ) RETURN SIGNED IS
    TYPE tLUT IS ARRAY( 0 TO 71 ) OF INTEGER;
    CONSTANT LUT : tLUT := ( 1023 , 1019 , 1007 , 988 , 961 , 927 , 886 , 838 , 784 , 723 , 658 , 587 , 512 , 432 , 350 , 265 , 178 , 89 ,
                             0 , -89 , -178 , -265 , -350 , -432 , -512 , -587 , -658 , -723 , -784 , -838 , -886 , -927 , -961 , -988 , -1007 , -1019 ,
                             -1023 , -1019 , -1007 , -988 , -961 , -927 , -886 , -838 , -784 , -723 , -658 , -587 , -512 , -432 , -350 , -265 , -178 , -89 ,
                             0 , 89 , 178 , 265 , 350 , 432 , 511 , 587 , 658 , 723 , 784 , 838 , 886 , 927 , 961 , 988 , 1007 , 1019
                            );
  BEGIN
    RETURN TO_SIGNED( LUT( MOD_PHI( aInputVal ) ) , 11 );
  END CosineCoefficient;


  FUNCTION CordicRotation( step , phi_scale : INTEGER ) RETURN INTEGER IS
  BEGIN
    RETURN INTEGER( ROUND( REAL( phi_scale ) * ARCTAN( 2.0 ** REAL( -step ) ) / MATH_2_PI ) );
  END CordicRotation;

  FUNCTION CordicRenormalization( number_steps , hyp_scale : INTEGER ) RETURN INTEGER IS
    VARIABLE val                                           : REAL;
  BEGIN
    val := 1.0;
    FOR i IN 0 TO( number_steps-1 ) LOOP
      val := val / SQRT( 1.0 + ( 4.0 ** REAL( -i ) ) );
    END LOOP;
    RETURN INTEGER( ROUND( REAL( hyp_scale ) * val ) ) ; -- val converges on 0.60725293501
  END CordicRenormalization;


  FUNCTION ToRingSegment( aTower : tTower ; aThreshold : UNSIGNED ; phi : INTEGER ) RETURN tRingSegment IS
    VARIABLE ret                 : tRingSegment := cEmptyRingSegment;
  BEGIN

      IF( aTower.HcalFeature ) THEN
        ret.towerCount( 0 ) := '1';
      ELSE
        ret.towerCount( 0 ) := '0';
      END IF;

      ret.Energy( 8 DOWNTO 0 ) := aTower.Energy;
      ret.Ecal( 8 DOWNTO 0 )   := aTower.Ecal;

      ret.xComponent           := TO_SIGNED( TO_INTEGER( CosineCoefficient( phi ) ) * TO_INTEGER( aTower.Energy ) , 32 );
      ret.yComponent           := TO_SIGNED( TO_INTEGER( SineCoefficient( phi ) ) * TO_INTEGER( aTower.Energy ) , 32 );

      ret.DataValid            := TRUE;

      RETURN ret;
  END ToRingSegment;

  FUNCTION ToRingSegment( aJet : tJet ) RETURN tRingSegment IS
    VARIABLE ret               : tRingSegment := cEmptyRingSegment;
  BEGIN
      ret.towerCount( 0 ) := '0';

      IF( aJet.Energy > 60 ) THEN
        ret.Energy( 15 DOWNTO 0 ) := aJet.Energy;
        ret.xComponent            := TO_SIGNED( TO_INTEGER( CosineCoefficient( aJet.Phi - cCMScoordinateOffset ) ) * TO_INTEGER( aJet.Energy ) , 36 )( 35 DOWNTO 4 );
        ret.yComponent            := TO_SIGNED( TO_INTEGER( SineCoefficient( aJet.Phi - cCMScoordinateOffset ) ) * TO_INTEGER( aJet.Energy ) , 36 )( 35 DOWNTO 4 );
      END IF;

      ret.DataValid := TRUE;

      RETURN ret;
  END ToRingSegment;



END ring_functions;
