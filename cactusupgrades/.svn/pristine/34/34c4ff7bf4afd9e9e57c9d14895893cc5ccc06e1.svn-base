--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common functions
USE work.functions.ALL;
--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "ring" helper functions
USE work.ring_functions.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! @brief An entity providing a GtRingSumFormatter
--! @details Detailed description
ENTITY GtRingSumFormatter IS
  PORT(
    clk                : IN STD_LOGIC := '0' ;      --! The algorithm clock
    ringSegmentPipeIn  : IN tPolarRingSegmentPipe ; --! A pipe of tPolarRingSegment objects bringing in the ringSegment's
    ringSegmentPipeOut : OUT tPolarRingSegmentPipe  --! A pipe of tPolarRingSegment objects passing out the ringSegment's
  );
END GtRingSumFormatter;

--! @brief Architecture definition for entity GtRingSumFormatter
--! @details Detailed description
ARCHITECTURE behavioral OF GtRingSumFormatter IS
  SIGNAL GtFormattedPolarRingSum : tPolarRingSegment    := cEmptyPolarRingSegment;
  SIGNAL Counter                 : INTEGER RANGE 0 TO 4 := 0;
BEGIN


  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN

      IF NOT ringSegmentPipeIn( 0 ) .DataValid THEN
        GtFormattedPolarRingSum <= cEmptyPolarRingSegment;
        Counter                 <= 0;
      ELSE
        Counter <= Counter + 1;

        IF( ringSegmentPipeIn( 0 ) .EcalMagnitude > x"FFF" ) THEN
          GtFormattedPolarRingSum.EcalMagnitude( 11 DOWNTO 0 ) <= x"FFF";
        ELSE
          GtFormattedPolarRingSum.EcalMagnitude( 11 DOWNTO 0 ) <= ringSegmentPipeIn( 0 ) .EcalMagnitude( 11 DOWNTO 0 );
        END IF;

        IF( ringSegmentPipeIn( 0 ) .ScalarMagnitude > x"FFF" ) THEN
          GtFormattedPolarRingSum.ScalarMagnitude( 11 DOWNTO 0 ) <= x"FFF";
        ELSE
          GtFormattedPolarRingSum.ScalarMagnitude( 11 DOWNTO 0 ) <= ringSegmentPipeIn( 0 ) .ScalarMagnitude( 11 DOWNTO 0 );
        END IF;

        IF Counter < 2 THEN --ET sums
          IF( ringSegmentPipeIn( 0 ) .VectorMagnitude( 31 DOWNTO 10 ) > x"FFF" ) THEN
            GtFormattedPolarRingSum.VectorMagnitude( 11 DOWNTO 0 ) <= x"FFF";
          ELSE
            GtFormattedPolarRingSum.VectorMagnitude( 11 DOWNTO 0 ) <= ringSegmentPipeIn( 0 ) .VectorMagnitude( 21 DOWNTO 10 );
          END IF;
        ELSE --HT sum
          IF( ringSegmentPipeIn( 0 ) .VectorMagnitude( 31 DOWNTO 6 ) > x"FFF" ) THEN
            GtFormattedPolarRingSum.VectorMagnitude( 11 DOWNTO 0 ) <= x"FFF";
          ELSE
            GtFormattedPolarRingSum.VectorMagnitude( 11 DOWNTO 0 ) <= ringSegmentPipeIn( 0 ) .VectorMagnitude( 17 DOWNTO 6 );
          END IF;
        END IF;

        GtFormattedPolarRingSum.VectorPhi( 7 DOWNTO 0 ) <= ringSegmentPipeIn( 0 ) .VectorPhi( 11 DOWNTO 4 );

        GtFormattedPolarRingSum.DataValid               <= TRUE;
      END IF;
    END IF;
  END PROCESS;

  PolarRingPipeInstance : ENTITY work.PolarRingPipe
  PORT MAP(
    clk           => clk ,
    PolarRingIn   => GtFormattedPolarRingSum ,
    PolarRingPipe => ringSegmentPipeOut
  );

END ARCHITECTURE behavioral;
