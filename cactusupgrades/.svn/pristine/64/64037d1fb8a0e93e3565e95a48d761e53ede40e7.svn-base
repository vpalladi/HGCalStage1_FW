--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.math_real.ALL ; -- for UNIFORM , TRUNC functions

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;
--! Using the Calo-L2 "ring" helper functions
USE work.ring_functions.ALL;


--! @brief An entity providing a FinalSumAndCoordinateConversion
--! @details Detailed description
ENTITY FinalSumAndCoordinateConversion IS
  GENERIC(
    bitshift : INTEGER := 0
  );
  PORT(
    clk              : IN STD_LOGIC := '0' ;     --! The algorithm clock
    ringPipeIn       : IN tRingSegmentPipe2 ;    --! A pipe of tRingSegment objects bringing in the ring's
    polarRingPipeOut : OUT tPolarRingSegmentPipe --! A pipe of tPolarRingSegment objects passing out the polarRing's
  );
END FinalSumAndCoordinateConversion;

--! @brief Architecture definition for entity FinalSumAndCoordinateConversion
--! @details Detailed description
ARCHITECTURE behavioral OF FinalSumAndCoordinateConversion IS

  CONSTANT n         : INTEGER := 8;

  CONSTANT phi_bits  : INTEGER := 12;
  CONSTANT phi_scale : INTEGER := 144 * 16;

  CONSTANT hyp_bits  : INTEGER := 17;
  CONSTANT hyp_scale : INTEGER := ( 2 ** hyp_bits );


  TYPE tCordic IS RECORD
    ecal      : UNSIGNED( 16 DOWNTO 0 );
    scalar    : UNSIGNED( 16 DOWNTO 0 );
    x         : SIGNED( 31 DOWNTO 0 );
    y         : SIGNED( 31 DOWNTO 0 );
    phi       : UNSIGNED( phi_bits-1 DOWNTO 0 );
    sign      : BOOLEAN;
    DataValid : BOOLEAN;
  END RECORD;

  CONSTANT cEmptyCordic : tCordic := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , FALSE , FALSE );

  TYPE tCordicSteps IS ARRAY( n + 1 DOWNTO 0 ) OF tCordic ; -- Number of steps used by the CORDIC
  SIGNAL CordicSteps      : tCordicSteps                    := ( OTHERS => cEmptyCordic );
  SIGNAL CartesianRingSum : tRingSegment                    := cEmptyRingSegment;
  SIGNAL PolarRingSum     : tPolarRingSegment               := cEmptyPolarRingSegment;
  SIGNAL MultOut          : STD_LOGIC_VECTOR( 63 DOWNTO 0 ) := ( OTHERS => '0' );

BEGIN


  FinalSumInstance : ENTITY work.RingSegmentSum
  PORT MAP(
    clk            => clk ,
    ringSegmentIn1 => ringPipeIn( 0 )( 0 ) ,
    ringSegmentIn2 => ringPipeIn( 0 )( 1 ) ,
    ringSegmentOut => CartesianRingSum
  );

--For ET / MET , data shifted by 10
--For HT / MHT , data shifted by 6

  PROCESS( clk )
    VARIABLE x_neg , y_neg : BOOLEAN;
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF NOT CartesianRingSum .DataValid THEN
        CordicSteps( 0 ) <= cEmptyCordic;
      ELSE
        x_neg := ( CartesianRingSum .xComponent < 0 );
        y_neg := ( CartesianRingSum .yComponent < 0 );

        IF( NOT x_neg AND NOT y_neg ) THEN
          CordicSteps( 0 ) .phi  <= TO_UNSIGNED( phi_scale / 2 , phi_bits );
          CordicSteps( 0 ) .sign <= True;
          CordicSteps( 0 ) .x    <= CartesianRingSum .xComponent;
          CordicSteps( 0 ) .y    <= CartesianRingSum .yComponent;
        ELSIF( x_neg AND NOT y_neg ) THEN
          CordicSteps( 0 ) .phi  <= TO_UNSIGNED( phi_scale , phi_bits );
          CordicSteps( 0 ) .sign <= False;
          CordicSteps( 0 ) .x    <= -CartesianRingSum .xComponent;
          CordicSteps( 0 ) .y    <= CartesianRingSum .yComponent;
        ELSIF( x_neg AND y_neg ) THEN
          CordicSteps( 0 ) .phi  <= TO_UNSIGNED( 0 , phi_bits );
          CordicSteps( 0 ) .sign <= True;
          CordicSteps( 0 ) .x    <= -CartesianRingSum .xComponent;
          CordicSteps( 0 ) .y    <= -CartesianRingSum .yComponent;
        ELSE
          CordicSteps( 0 ) .phi  <= TO_UNSIGNED( phi_scale / 2 , phi_bits );
          CordicSteps( 0 ) .sign <= False;
          CordicSteps( 0 ) .x    <= CartesianRingSum .xComponent;
          CordicSteps( 0 ) .y    <= -CartesianRingSum .yComponent;
        END IF;
        CordicSteps( 0 ) .scalar( 15 DOWNTO 0 ) <= CartesianRingSum .Energy( 15 DOWNTO 0 );
        CordicSteps( 0 ) .ecal( 15 DOWNTO 0 )   <= CartesianRingSum .Ecal( 15 DOWNTO 0 );
        CordicSteps( 0 ) .DataValid             <= TRUE;
      END IF;
    END IF;
  END PROCESS;


  steps : FOR i IN 1 TO n GENERATE
    PROCESS( clk )
      VARIABLE y_neg : BOOLEAN;
    BEGIN
      IF( RISING_EDGE( clk ) ) THEN
        IF NOT CordicSteps( i-1 ) .DataValid THEN
          CordicSteps( i ) <= cEmptyCordic;
        ELSE
          y_neg := ( CordicSteps( i-1 ) .y < 0 );

          IF y_neg THEN
            CordicSteps( i ) .x <= CordicSteps( i-1 ) .x - SHIFT_RIGHT( CordicSteps( i-1 ) .y , i-1 );
            CordicSteps( i ) .y <= CordicSteps( i-1 ) .y + SHIFT_RIGHT( CordicSteps( i-1 ) .x , i-1 );
          ELSE
            CordicSteps( i ) .x <= CordicSteps( i-1 ) .x + SHIFT_RIGHT( CordicSteps( i-1 ) .y , i-1 );
            CordicSteps( i ) .y <= CordicSteps( i-1 ) .y - SHIFT_RIGHT( CordicSteps( i-1 ) .x , i-1 );
          END IF;

          IF y_neg = CordicSteps( i-1 ) .sign THEN
            CordicSteps( i ) .phi <= CordicSteps( i-1 ) .phi - TO_UNSIGNED( CordicRotation( i-1 , phi_scale ) , phi_bits );
          ELSE
            CordicSteps( i ) .phi <= CordicSteps( i-1 ) .phi + TO_UNSIGNED( CordicRotation( i-1 , phi_scale ) , phi_bits );
          END IF;

          CordicSteps( i ) .sign      <= CordicSteps( i-1 ) .sign;
          CordicSteps( i ) .scalar    <= CordicSteps( i-1 ) .scalar;
          CordicSteps( i ) .ecal      <= CordicSteps( i-1 ) .ecal;
          CordicSteps( i ) .DataValid <= CordicSteps( i-1 ) .DataValid;

        END IF;
      END IF;
    END PROCESS;
  END GENERATE steps;

  CordicSteps( n + 1 ) <= CordicSteps( n ) WHEN RISING_EDGE( clk );

  HypoteneuseScaling : ENTITY work.CordicRenormalizationDSP
  PORT MAP(
    clk => clk ,
    a   => STD_LOGIC_VECTOR( CordicSteps( n + 1 ) .x ) ,
    b   => STD_LOGIC_VECTOR( TO_UNSIGNED( CordicRenormalization( n , hyp_scale ) , hyp_bits ) ) ,
    p   => MultOut( 48 DOWNTO 0 )
  );

  PolarRingSum .VectorPhi       <= CordicSteps( n + 1 ) .phi WHEN RISING_EDGE( clk );
  PolarRingSum .ScalarMagnitude <= CordicSteps( n + 1 ) .scalar WHEN RISING_EDGE( clk );
  PolarRingSum .EcalMagnitude   <= CordicSteps( n + 1 ) .ecal WHEN RISING_EDGE( clk );
  PolarRingSum .DataValid       <= CordicSteps( n + 1 ) .DataValid WHEN RISING_EDGE( clk );
  PolarRingSum .VectorMagnitude <= UNSIGNED( MultOut( 31 + hyp_bits + bitshift DOWNTO hyp_bits + bitshift ) );


  PolarRingPipeInstance : ENTITY work.PolarRingPipe
  PORT MAP(
    clk           => clk ,
    PolarRingIn   => PolarRingSum ,
    PolarRingPipe => polarRingPipeOut
  );

END ARCHITECTURE behavioral;
