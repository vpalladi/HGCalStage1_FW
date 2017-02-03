--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;

--! Using the Calo-L2 "ring" helper functions
USE work.ring_functions.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;

--! @brief An entity providing a RingAccumulators
--! @details Detailed description
ENTITY RingAccumulators IS
  GENERIC(
    ObjectType : STRING := ""
  );
  PORT(
    clk                         : IN STD_LOGIC := '0' ;           --! The algorithm clock
    ringPipeIn                  : IN tRingSegmentPipe2 ;          --! A pipe of tRingSegment objects bringing in the ring's
    accumulatedRingPipeOut      : OUT tRingSegmentPipe2 ;         --! A pipe of tRingSegment objects passing out the accumulatedRing's
    confAccumulatedRingPipeOut  : OUT tRingSegmentPipe2 ;         --! A pipe of tRingSegment objects passing out the accumulatedRing's
    accumulationCompletePipeOut : OUT tAccumulationCompletePipe ; --! A pipe of tAccumulationComplete objects passing out the accumulationComplete's
    BusIn                       : IN tFMBus;
    BusOut                      : OUT tFMBus;
    BusClk                      : IN STD_LOGIC := '0'
  );
END RingAccumulators;

--! @brief Architecture definition for entity RingAccumulators
--! @details Detailed description
ARCHITECTURE behavioral OF RingAccumulators IS
  SIGNAL accumulatedRingInEta , confAccumulatedRingInEta : tRingSegmentInEta              := cEmptyRingSegmentInEta;
  SIGNAL accumulationCompleteInEta                       : tAccumulationCompleteInEta     := cEmptyAccumulationCompleteInEta;
  SIGNAL MaxEta                                          : STD_LOGIC_VECTOR( 5 DOWNTO 0 ) := ( OTHERS => '0' );
BEGIN

-- --------------------------------------------------
  EtaLimitInstance : ENTITY work.GenRegister
  GENERIC MAP(
    BusName      => ObjectType & "_MaxEta" ,
    DefaultValue => DefaultRingEtaMax ,
    Registering  => 2
  )
  PORT MAP(
    DataOut => MaxEta ,
    BusIn   => BusIn ,
    BusOut  => BusOut ,
    BusClk  => BusClk
  );
-- --------------------------------------------------

  PROCESS( clk )
    VARIABLE varAccumulatedRingInEta : tRingSegmentInEta := cEmptyRingSegmentInEta;
    TYPE tCounter IS ARRAY( 0 TO cRegionInEta ) OF INTEGER RANGE cCMScoordinateOffset TO cTowersInHalfEta;
    VARIABLE Counter : tCounter := ( OTHERS => cCMScoordinateOffset );
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN

      eta : FOR j IN 0 TO cRegionInEta-1 LOOP
        IF( NOT ringPipeIn( 0 )( j ) .DataValid ) THEN
          varAccumulatedRingInEta( j ) := cEmptyRingSegment;
          confAccumulatedRingInEta( j ) <= varAccumulatedRingInEta( j );
          accumulatedRingInEta          <= varAccumulatedRingInEta;
          Counter( j ) := cCMScoordinateOffset;
        ELSE
          varAccumulatedRingInEta( j ) .Energy     := varAccumulatedRingInEta( j ) .Energy + ringPipeIn( 0 )( j ) .Energy;
          varAccumulatedRingInEta( j ) .Ecal       := varAccumulatedRingInEta( j ) .Ecal + ringPipeIn( 0 )( j ) .Ecal;
          varAccumulatedRingInEta( j ) .xComponent := varAccumulatedRingInEta( j ) .xComponent + ringPipeIn( 0 )( j ) .xComponent;
          varAccumulatedRingInEta( j ) .yComponent := varAccumulatedRingInEta( j ) .yComponent + ringPipeIn( 0 )( j ) .yComponent;
          varAccumulatedRingInEta( j ) .towerCount := varAccumulatedRingInEta( j ) .towerCount + ringPipeIn( 0 )( j ) .towerCount;
          varAccumulatedRingInEta( j ) .DataValid  := TRUE;

          accumulatedRingInEta( j ) <= varAccumulatedRingInEta( j );

          IF counter( j ) = TO_INTEGER( UNSIGNED( MaxEta ) ) THEN
            confAccumulatedRingInEta( j ) <= varAccumulatedRingInEta( j );
          END IF;

          IF counter( j ) /= cTowersInHalfEta THEN
            counter( j ) := counter( j ) + 1;
          END IF;

        END IF;
      END LOOP eta;

    END IF;
  END PROCESS;


  eta2 : FOR j IN 0 TO cRegionInEta-1 GENERATE
    accumulationCompleteInEta( j ) <= ( ( ringPipeIn( 0 )( j ) .DataValid = FALSE ) AND( ringPipeIn( 1 )( j ) .DataValid = TRUE ) );
  END GENERATE eta2;


  RingPipeInstance : ENTITY work.RingPipe2
  PORT MAP(
    clk      => clk ,
    RingsIn  => accumulatedRingInEta ,
    RingPipe => accumulatedRingPipeOut
  );

  RingPipeInstance2 : ENTITY work.RingPipe2
  PORT MAP(
    clk      => clk ,
    RingsIn  => confAccumulatedRingInEta ,
    RingPipe => confAccumulatedRingPipeOut
  );

  AccumulationCompletePipeInstance : ENTITY work.AccumulationCompletePipe
  PORT MAP(
    clk                      => clk ,
    accumulationCompleteIn   => accumulationCompleteInEta ,
    accumulationCompletePipe => accumulationCompletePipeOut
  );

END ARCHITECTURE behavioral;
