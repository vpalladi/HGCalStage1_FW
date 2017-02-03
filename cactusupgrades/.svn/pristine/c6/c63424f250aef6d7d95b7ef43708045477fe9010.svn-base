--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.math_real.ALL ; -- for UNIFORM , TRUNC functions

--! Writing to and from files
USE STD.TEXTIO.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

PACKAGE functions IS
  FUNCTION TO_STD_LOGIC( ARG               : BOOLEAN ) RETURN std_ulogic;

  FUNCTION PowerOf2LessThan( ARG           : INTEGER ) RETURN INTEGER;

  FUNCTION LatencyOfBitonicMerge( Size     : INTEGER ) RETURN INTEGER;
-- FUNCTION LatencyOfBitonicSort( Size : INTEGER ) RETURN INTEGER;
  FUNCTION LatencyOfBitonicSort( InSize    : INTEGER ; OutSize : INTEGER ) RETURN INTEGER;


  FUNCTION MAXIMUM( L , R                  : INTEGER ) RETURN INTEGER;
  FUNCTION MINIMUM( L , R                  : INTEGER ) RETURN INTEGER;

  FUNCTION MOD_PHI( MOD_PHI                : INTEGER ) RETURN INTEGER;
  FUNCTION OPP_ETA( ETA                    : INTEGER ) RETURN INTEGER;

  PROCEDURE SET_RANDOM_SIG( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; SIGNAL RESULT : OUT SIGNED );
  PROCEDURE SET_RANDOM_SIG( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; SIGNAL RESULT : OUT UNSIGNED );
  PROCEDURE SET_RANDOM_SIG( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; SIGNAL RESULT : OUT STD_LOGIC_VECTOR );
  PROCEDURE SET_RANDOM_SIG( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; SIGNAL RESULT : OUT STD_LOGIC );

  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT SIGNED );
  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT UNSIGNED );
  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT STD_LOGIC_VECTOR );
  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT STD_LOGIC );

  FUNCTION IS_IN_CIRCLE( k                 : INTEGER ; l : INTEGER ; Diameter : INTEGER ) RETURN BOOLEAN;

END PACKAGE functions;

PACKAGE BODY functions IS

  FUNCTION TO_STD_LOGIC( ARG : BOOLEAN ) RETURN std_ulogic IS
  BEGIN
      IF ARG THEN
          RETURN( '1' );
      ELSE
          RETURN( '0' );
      END IF;
  END FUNCTION To_Std_Logic;

  FUNCTION PowerOf2LessThan( ARG : INTEGER ) RETURN INTEGER IS
    VARIABLE comp                : INTEGER := 1;
  BEGIN
    FOR i IN 0 TO 63 LOOP
      IF ARG <= comp THEN
        RETURN comp / 2;
      END IF;
      comp := comp * 2;
    END LOOP;
    RETURN -1;
  END FUNCTION PowerOf2LessThan;

  FUNCTION LatencyOfBitonicMerge( Size     : INTEGER ) RETURN INTEGER IS
    VARIABLE Merge1Latency , Merge2Latency : INTEGER := 0;
  BEGIN
    IF size <= 1 THEN
      RETURN 0;
    ELSE
      Merge1Latency := LatencyOfBitonicMerge( PowerOf2LessThan( Size ) );
      Merge2Latency := LatencyOfBitonicMerge( Size - PowerOf2LessThan( Size ) );
      RETURN 1 + MAXIMUM( Merge1Latency , Merge2Latency );
    END IF;
  END FUNCTION LatencyOfBitonicMerge;

-- FUNCTION LatencyOfBitonicSort( Size : INTEGER ) RETURN INTEGER IS
-- VARIABLE Sort1Latency , Sort2Latency : INTEGER := 0;
-- VARIABLE MergeLatency : INTEGER := 0;
-- BEGIN
-- IF size <= 1 THEN
-- RETURN 0;
-- ELSE
-- Sort1Latency := LatencyOfBitonicSort( Size / 2 );
-- Sort2Latency := LatencyOfBitonicSort( Size - ( Size / 2 ) );
-- MergeLatency := LatencyOfBitonicMerge( Size );
--
-- RETURN MAXIMUM( Sort1Latency , Sort2Latency ) + MergeLatency;
-- END IF;
-- END FUNCTION LatencyOfBitonicSort;



  FUNCTION LatencyOfBitonicSort( InSize  : INTEGER ; OutSize : INTEGER ) RETURN INTEGER IS
    VARIABLE Sort1Size , Sort2Size       : INTEGER := 0;
    VARIABLE Sort1Latency , Sort2Latency : INTEGER := 0;
    VARIABLE MergeLatency                : INTEGER := 0;
  BEGIN
    IF InSize <= 1 THEN
      RETURN 0;
    ELSE
      Sort1Size    := InSize / 2;
      Sort2Size    := InSize - Sort1Size;

      Sort1Latency := LatencyOfBitonicSort( Sort1Size , OutSize );
      Sort2Latency := LatencyOfBitonicSort( Sort2Size , OutSize );
      MergeLatency := LatencyOfBitonicMerge( MINIMUM( Sort1Size , OutSize ) + MINIMUM( Sort2Size , OutSize ) );

      RETURN MAXIMUM( Sort1Latency , Sort2Latency ) + MergeLatency;
    END IF;
  END FUNCTION LatencyOfBitonicSort;



  FUNCTION MAXIMUM( L , R : INTEGER ) RETURN INTEGER IS
  BEGIN
    IF( L > R ) THEN
      RETURN L;
    ELSE
      RETURN R;
    END IF;
  END MAXIMUM;

  FUNCTION MINIMUM( L , R : INTEGER ) RETURN INTEGER IS
  BEGIN
    IF( L > R ) THEN
      RETURN R;
    ELSE
      RETURN L;
    END IF;
  END MINIMUM;

  FUNCTION MOD_PHI( MOD_PHI : INTEGER ) RETURN INTEGER IS
  BEGIN
    RETURN( ( MOD_PHI + cTowerInPhi ) MOD cTowerInPhi );
  END MOD_PHI;

  FUNCTION OPP_ETA( ETA : INTEGER ) RETURN INTEGER IS
  BEGIN
    IF( ETA = 0 ) THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END OPP_ETA;

  PROCEDURE SET_RANDOM_SIG( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; SIGNAL RESULT : OUT SIGNED ) IS
    VARIABLE rand                          : REAL ; -- Random real-number value in range 0 to 1.0
  BEGIN

        UNIFORM( seed1 , seed2 , rand ) ; -- generate random number
        RESULT <= TO_SIGNED( INTEGER( rand * REAL( 2 ** 30 ) ) , RESULT'LENGTH );

  END SET_RANDOM_SIG;

  PROCEDURE SET_RANDOM_SIG( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; SIGNAL RESULT : OUT UNSIGNED ) IS
    VARIABLE rand                          : REAL ; -- Random real-number value in range 0 to 1.0
  BEGIN

        UNIFORM( seed1 , seed2 , rand ) ; -- generate random number
        RESULT <= TO_UNSIGNED( INTEGER( rand * REAL( 2 ** 30 ) ) , RESULT'LENGTH );

  END SET_RANDOM_SIG;

  PROCEDURE SET_RANDOM_SIG( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; SIGNAL RESULT : OUT STD_LOGIC_VECTOR ) IS
    VARIABLE rand                          : REAL ; -- Random real-number value in range 0 to 1.0
  BEGIN

        UNIFORM( seed1 , seed2 , rand ) ; -- generate random number
        RESULT <= STD_LOGIC_VECTOR( TO_UNSIGNED( INTEGER( rand * REAL( 2 ** 30 ) ) , RESULT'LENGTH ) );

  END SET_RANDOM_SIG;

  PROCEDURE SET_RANDOM_SIG( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; SIGNAL RESULT : OUT STD_LOGIC ) IS
    VARIABLE rand                          : REAL ; -- Random real-number value in range 0 to 1.0
    VARIABLE int_rand                      : INTEGER ; -- Random integer value in range 0 to 1
  BEGIN

        UNIFORM( seed1 , seed2 , rand ) ; -- generate random number
        int_rand := INTEGER( ROUND( rand ) );
        IF int_rand = 1 THEN
          RESULT <= '1';
        ELSE
          RESULT <= '0';
        END IF;

  END SET_RANDOM_SIG;

  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT SIGNED ) IS
    VARIABLE rand                          : REAL ; -- Random real-number value in range 0 to 1.0
  BEGIN

        UNIFORM( seed1 , seed2 , rand ) ; -- generate random number
        RESULT := TO_SIGNED( INTEGER( rand * REAL( 2 ** 30 ) ) , RESULT'LENGTH );

  END SET_RANDOM_VAR;

  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT UNSIGNED ) IS
    VARIABLE rand                          : REAL ; -- Random real-number value in range 0 to 1.0
  BEGIN

        UNIFORM( seed1 , seed2 , rand ) ; -- generate random number
        RESULT := TO_UNSIGNED( INTEGER( rand * REAL( 2 ** 30 ) ) , RESULT'LENGTH );

  END SET_RANDOM_VAR;

  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT STD_LOGIC_VECTOR ) IS
    VARIABLE rand                          : REAL ; -- Random real-number value in range 0 to 1.0
  BEGIN

        UNIFORM( seed1 , seed2 , rand ) ; -- generate random number
        RESULT := STD_LOGIC_VECTOR( TO_UNSIGNED( INTEGER( rand * REAL( 2 ** 30 ) ) , RESULT'LENGTH ) );

  END SET_RANDOM_VAR;

  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT STD_LOGIC ) IS
    VARIABLE rand                          : REAL ; -- Random real-number value in range 0 to 1.0
    VARIABLE int_rand                      : INTEGER ; -- Random integer value in range 0 to 1
  BEGIN

        UNIFORM( seed1 , seed2 , rand ) ; -- generate random number
        int_rand := INTEGER( ROUND( rand ) );
        IF int_rand = 1 THEN
          RESULT := '1';
        ELSE
          RESULT := '0';
        END IF;

  END SET_RANDOM_VAR;

  FUNCTION IS_IN_CIRCLE( k : INTEGER ; l : INTEGER ; Diameter : INTEGER ) RETURN BOOLEAN IS
    VARIABLE Radius        : REAL := 0.0;
  BEGIN
    Radius := REAL( Diameter ) / 2.0;
    RETURN( REAL( k ) -Radius + 0.5 ) ** 2 + ( REAL( l ) -Radius + 0.5 ) ** 2 <= Radius ** 2;
  END IS_IN_CIRCLE;


END functions;
