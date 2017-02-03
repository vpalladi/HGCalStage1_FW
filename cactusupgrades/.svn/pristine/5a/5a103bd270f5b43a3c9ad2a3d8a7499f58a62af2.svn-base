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

--! @brief An entity providing a AuxLinkPacker
--! @details Detailed description
ENTITY AuxLinkPacker IS
  GENERIC(
    PileUpEstimationOffset : INTEGER := 0
  );
  PORT(
    clk                        : IN STD_LOGIC := '0' ;          --! The algorithm clock
    PileUpEstimationPipeIn     : IN tPileUpEstimationPipe2 ;    --! A pipe of tPileUpEstimation objects bringing in the PileUpEstimation's
    accumulatedRingPipeIn      : IN tRingSegmentPipe2 ;         --! A pipe of tRingSegment objects bringing in the accumulatedRing's
    accumulationCompletePipeIn : IN tAccumulationCompletePipe ; --! A pipe of tAccumulationComplete objects bringing in the accumulationComplete's
    PackedAuxInfoPipeOut       : OUT tPackedLinkPipe            --! A pipe of tPackedLink objects passing out the PackedAuxInfo's
  );
END AuxLinkPacker;

--! @brief Architecture definition for entity AuxLinkPacker
--! @details Detailed description
ARCHITECTURE behavioral OF AuxLinkPacker IS
  SIGNAL PackedAuxInfo : tPackedLinkInCandidates := cEmptyPackedLinkInCandidates;
BEGIN

  prc                      : PROCESS( clk )
    VARIABLE Energy , Ecal : UNSIGNED( 15 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
    IF RISING_EDGE( clk ) THEN
      PackedAuxInfo( 0 ) .Data( 4 DOWNTO 0 ) <= STD_LOGIC_VECTOR( PileUpEstimationPipeIn( PileUpEstimationOffset ) .towerCount );
      PackedAuxInfo( 0 ) .DataValid          <= PileUpEstimationPipeIn( PileUpEstimationOffset ) .DataValid;

      IF accumulatedRingPipeIn( 0 )( 1 ) .towerCount2 > x"F" THEN
        PackedAuxInfo( 1 ) .Data( 3 DOWNTO 0 ) <= x"F";
      ELSE
        PackedAuxInfo( 1 ) .Data( 3 DOWNTO 0 ) <= STD_LOGIC_VECTOR( accumulatedRingPipeIn( 0 )( 1 ) .towerCount2( 3 DOWNTO 0 ) );
      END IF;

      IF accumulatedRingPipeIn( 0 )( 0 ) .towerCount2 > x"F" THEN
        PackedAuxInfo( 1 ) .Data( 11 DOWNTO 8 ) <= x"F";
      ELSE
        PackedAuxInfo( 1 ) .Data( 11 DOWNTO 8 ) <= STD_LOGIC_VECTOR( accumulatedRingPipeIn( 0 )( 0 ) .towerCount2( 3 DOWNTO 0 ) );
      END IF;

      IF accumulatedRingPipeIn( 0 )( 1 ) .towerCount > x"F" THEN
        PackedAuxInfo( 1 ) .Data( 19 DOWNTO 16 ) <= x"F";
      ELSE
        PackedAuxInfo( 1 ) .Data( 19 DOWNTO 16 ) <= STD_LOGIC_VECTOR( accumulatedRingPipeIn( 0 )( 1 ) .towerCount( 3 DOWNTO 0 ) );
      END IF;

      IF accumulatedRingPipeIn( 0 )( 0 ) .towerCount > x"F" THEN
        PackedAuxInfo( 1 ) .Data( 27 DOWNTO 24 ) <= x"F";
      ELSE
        PackedAuxInfo( 1 ) .Data( 27 DOWNTO 24 ) <= STD_LOGIC_VECTOR( accumulatedRingPipeIn( 0 )( 0 ) .towerCount( 3 DOWNTO 0 ) );
      END IF;

      PackedAuxInfo( 1 ) .AccumulationComplete <= accumulationCompletePipeIn( 0 )( 0 );
      PackedAuxInfo( 1 ) .DataValid            <= accumulatedRingPipeIn( 0 )( 0 ) .DataValid AND accumulatedRingPipeIn( 0 )( 1 ) .DataValid;

      PackedAuxInfo( 2 ) .DataValid            <= TRUE;
      PackedAuxInfo( 3 ) .DataValid            <= TRUE;
      PackedAuxInfo( 4 ) .DataValid            <= TRUE;
      PackedAuxInfo( 5 ) .DataValid            <= TRUE;
    END IF;
  END PROCESS;

  PackedLinkPipeInstance : ENTITY work.PackedLinkPipe
  PORT MAP(
    clk            => clk ,
    PackedLinkIn   => PackedAuxInfo ,
    PackedLinkPipe => PackedAuxInfoPipeOut
  );

END ARCHITECTURE behavioral;


-- ---------------------------------------------------------------------------------------------------------------------------------------------------

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

--! @brief An entity providing a AuxLinkPacker
--! @details Detailed description
ENTITY AuxLinkUnpacker IS
  PORT(
    clk                     : IN STD_LOGIC := '0' ; --! The algorithm clock
    PackedAuxInfoIn         : tWordArray   := cEmptyWordArray;
    PileUpEstimationPipeOut : OUT tPileUpEstimationPipe2 ; --! A pipe of tPileUpEstimation objects bringing in the PileUpEstimation's
    RingPipeOut             : OUT tRingSegmentPipe2        --! A pipe of tRingSegment objects bringing in the accumulatedRing's
  );
END AuxLinkUnpacker;

--! @brief Architecture definition for entity AuxLinkPacker
--! @details Detailed description
ARCHITECTURE behavioral OF AuxLinkUnpacker IS
  SIGNAL Rings            : tRingSegmentInEta := cEmptyRingSegmentInEta;
  SIGNAL PileUpEstimation : tPileUpEstimation := cEmptyPileUpEstimation ; --! A pipe of tPileUpEstimation objects bringing in the PileUpEstimation's

BEGIN

  PileUpEstimation.towerCount           <= UNSIGNED( PackedAuxInfoIn( 0 ) .Data( 4 DOWNTO 0 ) );
  PileUpEstimation.DataValid            <= PackedAuxInfoIn( 0 ) .valid = '1';

  Rings( 0 ) .towerCount( 3 DOWNTO 0 )  <= UNSIGNED( PackedAuxInfoIn( 1 ) .Data( 27 DOWNTO 24 ) );
  Rings( 0 ) .towerCount2( 3 DOWNTO 0 ) <= UNSIGNED( PackedAuxInfoIn( 1 ) .Data( 11 DOWNTO 8 ) );
  Rings( 0 ) .DataValid                 <= PackedAuxInfoIn( 1 ) .valid = '1';

  Rings( 1 ) .towerCount( 3 DOWNTO 0 )  <= UNSIGNED( PackedAuxInfoIn( 1 ) .Data( 19 DOWNTO 16 ) );
  Rings( 1 ) .towerCount2( 3 DOWNTO 0 ) <= UNSIGNED( PackedAuxInfoIn( 1 ) .Data( 3 DOWNTO 0 ) );
  Rings( 1 ) .DataValid                 <= PackedAuxInfoIn( 1 ) .valid = '1';

-- ------------------------------------------------------------------------------------
  RingPipeInstance : ENTITY work.RingPipe2
  PORT MAP(
    clk      => clk ,
    RingsIn  => Rings ,
    RingPipe => RingPipeOut
  );
-- ------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------
  PileUpEstimationPipeInstance : ENTITY work.PileUpEstimationPipe2
  PORT MAP(
    clk                  => clk ,
    PileUpEstimationIn   => PileUpEstimation ,
    PileUpEstimationPipe => PileUpEstimationPipeOut
  );
-- ------------------------------------------------------------------------------------


END ARCHITECTURE behavioral;
