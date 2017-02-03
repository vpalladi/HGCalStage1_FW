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

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! @brief An entity providing a RingSumLinkPacker
--! @details Detailed description
ENTITY RingSumLinkPacker IS
  PORT(
    clk                        : IN STD_LOGIC := '0' ;          --! The algorithm clock
    accumulatedRingPipeIn      : IN tRingSegmentPipe2 ;         --! A pipe of tRingSegment objects bringing in the accumulatedRing's
    confAccumulatedRingPipeIn  : IN tRingSegmentPipe2 ;         --! A pipe of tRingSegment objects bringing in the accumulatedRing's
    accumulationCompletePipeIn : IN tAccumulationCompletePipe ; --! A pipe of tAccumulationComplete objects bringing in the accumulationComplete's
    PackedRingSumPipeOut       : OUT tPackedLinkPipe            --! A pipe of tPackedLink objects passing out the PackedRingSum's
  );
END RingSumLinkPacker;

--! @brief Architecture definition for entity RingSumLinkPacker
--! @details Detailed description
ARCHITECTURE behavioral OF RingSumLinkPacker IS
  SIGNAL Rings : tPackedLinkInCandidates := cEmptyPackedLinkInCandidates;
BEGIN
  eta                        : FOR j IN 0 TO cRegionInEta-1 GENERATE

    prc                      : PROCESS( clk )
      VARIABLE Energy , Ecal : UNSIGNED( 15 DOWNTO 0 ) := ( OTHERS => '0' );
      VARIABLE Counter       : INTEGER RANGE 0 TO 2    := 2;
      VARIABLE Source        : tRingSegment            := cEmptyRingSegment;
    BEGIN
      IF RISING_EDGE( clk ) THEN

        IF accumulationCompletePipeIn( 0 )( j ) THEN
          Counter := 0;
        END IF;

        IF Counter = 0 THEN
          Source  := accumulatedRingPipeIn( 0 )( j );
          Counter := Counter + 1;
        ELSIF Counter = 1 THEN
          Source  := confAccumulatedRingPipeIn( 1 )( j );
          Counter := Counter + 1;
        ELSE
          Source := cEmptyRingSegment;
        END IF;

        IF( Source .Energy > x"FFFF" ) THEN
          Energy := x"FFFF";
        ELSE
          Energy := Source .Energy( 15 DOWNTO 0 );
        END IF;

        IF( Source .Ecal > x"FFFF" ) THEN
          Ecal := x"FFFF";
        ELSE
          Ecal := Source .Ecal( 15 DOWNTO 0 );
        END IF;

        Rings( ( 3 * j ) + 0 ) .Data      <= STD_LOGIC_VECTOR( Ecal & Energy );
        Rings( ( 3 * j ) + 1 ) .Data      <= STD_LOGIC_VECTOR( Source .xComponent );
        Rings( ( 3 * j ) + 2 ) .Data      <= STD_LOGIC_VECTOR( Source .yComponent );

--Rings( ( 3 * j ) + 0 ) .AccumulationComplete <= accumulationCompletePipeIn( 0 )( j );
--Rings( ( 3 * j ) + 1 ) .AccumulationComplete <= accumulationCompletePipeIn( 0 )( j );
--Rings( ( 3 * j ) + 2 ) .AccumulationComplete <= accumulationCompletePipeIn( 0 )( j );

        Rings( ( 3 * j ) + 0 ) .DataValid <= Source .DataValid;
        Rings( ( 3 * j ) + 1 ) .DataValid <= Source .DataValid;
        Rings( ( 3 * j ) + 2 ) .DataValid <= Source .DataValid;
      END IF;
    END PROCESS;

  END GENERATE eta;

  PackedLinkPipeInstance : ENTITY work.PackedLinkPipe
  PORT MAP(
    clk            => clk ,
    PackedLinkIn   => Rings ,
    PackedLinkPipe => PackedRingSumPipeOut
  );

END ARCHITECTURE behavioral;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;


--! @brief An entity providing a RingLinkPacker
--! @details Detailed description
ENTITY RingSumLinkUnpacker IS
  PORT(
    clk           : IN STD_LOGIC    := '0' ; --! The algorithm clock
    PackedRingsIn : tWordArrayInEta := cEmptyWordArrayInEta;
    RingPipeOut   : OUT tRingSegmentPipe2 --! A pipe of tRing objects bringing in the accumulatedSortedRing's
  );
END RingSumLinkUnpacker;

--! @brief Architecture definition for entity RingLinkPacker
--! @details Detailed description
ARCHITECTURE behavioral OF RingSumLinkUnpacker IS
  SIGNAL Rings : tRingSegmentInEta := cEmptyRingSegmentInEta;
BEGIN

-- ------------------------------------------------------------------------------------
  eta_half : FOR j IN 0 TO 1 GENERATE
    Rings( j ) .Energy( 15 DOWNTO 0 ) <= UNSIGNED( PackedRingsIn( j )( 0 ) .data( 15 DOWNTO 0 ) );
    Rings( j ) .Ecal( 15 DOWNTO 0 )   <= UNSIGNED( PackedRingsIn( j )( 0 ) .data( 31 DOWNTO 16 ) );
    Rings( j ) .xComponent            <= SIGNED( PackedRingsIn( j )( 1 ) .data( 31 DOWNTO 0 ) );
    Rings( j ) .yComponent            <= SIGNED( PackedRingsIn( j )( 2 ) .data( 31 DOWNTO 0 ) );
    Rings( j ) .DataValid             <= PackedRingsIn( j )( 0 ) .valid = '1';
  END GENERATE eta_half;
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  RingPipeInstance : ENTITY work.RingPipe2
  PORT MAP(
    clk      => clk ,
    RingsIn  => Rings ,
    RingPipe => RingPipeOut
  );
-- ------------------------------------------------------------------------------------
END ARCHITECTURE behavioral;


-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;

--! @brief An entity providing a DemuxRingSumLinkPacker
--! @details Detailed description
ENTITY DemuxRingSumLinkPacker IS
  GENERIC(
    AuxInfoOffset  : INTEGER := 0;
    MinBiasEtaHalf : INTEGER := 0
  );
  PORT(
    clk                    : IN STD_LOGIC := '0' ;       --! The algorithm clock
    polarRingPipeIn        : IN tPolarRingSegmentPipe ;  --! A pipe of tPolarRingSegment objects bringing in the polarRing's
--
    PileUpEstimationPipeIn : IN tPileUpEstimationPipe2 ; --! A pipe of tPileUpEstimation objects bringing in the PileUpEstimation's
    MinBiasPipeIn          : IN tRingSegmentPipe2 ;      --! A pipe of tRingSegment objects bringing in the accumulatedRing's
--
    PackedRingSumPipeOut   : OUT tPackedLinkPipe         --! A pipe of tPackedLink objects passing out the PackedRingSum's
  );
END DemuxRingSumLinkPacker;

--! @brief Architecture definition for entity DemuxRingSumLinkPacker
--! @details Detailed description
ARCHITECTURE behavioral OF DemuxRingSumLinkPacker IS
  SIGNAL Rings            : tPackedLinkInCandidates := cEmptyPackedLinkInCandidates;
  SIGNAL COUNTER          : INTEGER RANGE 0 TO 4    := 0;
  SIGNAL Offset , EtaHalf : INTEGER                 := 0;
BEGIN

  PRC : PROCESS( clk )
  BEGIN
    IF RISING_EDGE( clk ) THEN
      IF NOT polarRingPipeIn( 0 ) .DataValid THEN
        COUNTER <= 0;
      ELSE
        COUNTER <= COUNTER + 1;
      END IF;
    END IF;
  END PROCESS;

  Rings( 0 ) .Data( 11 DOWNTO 0 )  <= STD_LOGIC_VECTOR( polarRingPipeIn( 0 ) .ScalarMagnitude( 11 DOWNTO 0 ) );
  Rings( 1 ) .Data( 19 DOWNTO 0 )  <= STD_LOGIC_VECTOR( polarRingPipeIn( 0 ) .VectorPhi( 7 DOWNTO 0 ) ) & STD_LOGIC_VECTOR( polarRingPipeIn( 0 ) .VectorMagnitude( 11 DOWNTO 0 ) );

  Rings( 0 ) .Data( 23 DOWNTO 12 ) <= STD_LOGIC_VECTOR( polarRingPipeIn( 0 ) .EcalMagnitude( 11 DOWNTO 0 ) );

  Offset                           <= AuxInfoOffset + COUNTER;
  EtaHalf                          <= 0 WHEN( COUNTER < 2 ) ELSE 1;

  Rings( 0 ) .Data( 31 DOWNTO 28 ) <= STD_LOGIC_VECTOR( MinBiasPipeIn( Offset )( EtaHalf ) .towerCount( 3 DOWNTO 0 ) );
  Rings( 1 ) .Data( 31 DOWNTO 28 ) <= STD_LOGIC_VECTOR( MinBiasPipeIn( Offset )( EtaHalf ) .towerCount2( 3 DOWNTO 0 ) );

  Rings( 0 ) .DataValid            <= polarRingPipeIn( 0 ) .DataValid;
  Rings( 1 ) .DataValid            <= polarRingPipeIn( 0 ) .DataValid;

  PackedLinkPipeInstance : ENTITY work.PackedLinkPipe
  PORT MAP(
    clk            => clk ,
    PackedLinkIn   => Rings ,
    PackedLinkPipe => PackedRingSumPipeOut
  );

END ARCHITECTURE behavioral;
