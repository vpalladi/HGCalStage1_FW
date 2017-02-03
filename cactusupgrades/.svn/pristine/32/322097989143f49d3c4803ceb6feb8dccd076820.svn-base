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

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;


--! @brief An entity providing a ClusterPileupEstimation
--! @details Detailed description
ENTITY ClusterPileupEstimation IS
  PORT(
    clk                      : IN STD_LOGIC := '0' ;       --! The algorithm clock
    AccumulatedRingPipeIn    : IN tRingSegmentPipe2 ;      --! A pipe of tRingSegment objects bringing in the AccumulatedRing's
    PileupEstimationPipeOut  : OUT tPileupEstimationPipe ; --! A pipe of tPileupEstimation objects passing out the PileupEstimation's
    PileupEstimationPipe2Out : OUT tPileupEstimationPipe2
  );
END ENTITY ClusterPileupEstimation;


--! @brief Architecture definition for entity ClusterPileupEstimation
--! @details Detailed description
ARCHITECTURE behavioral OF ClusterPileupEstimation IS

  SIGNAL EtaCounter                                        : INTEGER RANGE 0 TO cTowersInHalfEta := cCMScoordinateOffset;
  SIGNAL Eta                                               : STD_LOGIC_VECTOR( 5 DOWNTO 0 )      := ( OTHERS => '0' );
  SIGNAL EtaCompressed2                                    : STD_LOGIC_VECTOR( 1 DOWNTO 0 )      := ( OTHERS => '0' );
  SIGNAL EtaCompressed4a , EtaCompressed4j                 : STD_LOGIC_VECTOR( 3 DOWNTO 0 )      := ( OTHERS => '0' );
  SIGNAL NonZeroCount                                      : STD_LOGIC_VECTOR( 9 DOWNTO 0 )      := ( OTHERS => '0' );
  SIGNAL NonZeroCountCompressed                            : STD_LOGIC_VECTOR( 4 DOWNTO 0 )      := ( OTHERS => '0' );
  SIGNAL PileupEstimation                                  : tPileupEstimation                   := cEmptyPileupEstimation;
  SIGNAL PileupEstimationFanout1 , PileupEstimationFanout2 : tPileupEstimationInEtaPhi           := cEmptyPileupEstimationInEtaPhi;

BEGIN

  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF( AccumulatedRingPipeIn( 3 )( 0 ) .DataValid AND NOT AccumulatedRingPipeIn( 4 )( 0 ) .DataValid ) THEN
        NonZeroCount <= STD_LOGIC_VECTOR( AccumulatedRingPipeIn( 0 )( 0 ) .towerCount( 9 DOWNTO 0 ) + AccumulatedRingPipeIn( 0 )( 1 ) .towerCount( 9 DOWNTO 0 ) );
      END IF;

      IF( NOT AccumulatedRingPipeIn( 4 )( 0 ) .DataValid ) THEN
        EtaCounter <= cCMScoordinateOffset;
      ELSE
        IF EtaCounter /= cTowersInHalfEta THEN
          EtaCounter <= EtaCounter + 1;
        END IF;
      END IF;

    END IF;
  END PROCESS;


-- ----------------------------------------------------------------------
  NttCompressionLutInstance : ENTITY work.GenRomClocked
  GENERIC MAP(
    FileName => "E_NttCompression_10to5.mif" -- File with content of rom
  )
  PORT MAP(
    clk       => clk ,
    AddressIn => NonZeroCount ,
    DataOut   => NonZeroCountCompressed
  );
-- ----------------------------------------------------------------------

Eta <= STD_LOGIC_VECTOR( TO_UNSIGNED( EtaCounter , 6 ) );

-- ----------------------------------------------------------------------
  ClusterEtaCompressionLutInstance : ENTITY work.GenRomClocked
  GENERIC MAP(
    FileName => "A_EtaCompression_5to4.mif"
  )
  PORT MAP(
    clk       => clk ,
    AddressIn => Eta( 4 DOWNTO 0 ) ,
    DataOut   => EtaCompressed4a
  );
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
  ClusterEtaCompressionLutInstance2 : ENTITY work.GenRomClocked
  GENERIC MAP(
    FileName => "G_EtaCompression_5to2.mif"
  )
  PORT MAP(
    clk       => clk ,
    AddressIn => Eta( 4 DOWNTO 0 ) ,
    DataOut   => EtaCompressed2
  );
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
  ClusterEtaCompressionLutInstance3 : ENTITY work.GenRomClocked
  GENERIC MAP(
    FileName => "J_EtaCompression_6to4.mif"
  )
  PORT MAP(
    clk       => clk ,
    AddressIn => Eta ,
    DataOut   => EtaCompressed4j
  );
-- ----------------------------------------------------------------------

  PileupEstimation.CompressedEta4a <= UNSIGNED( EtaCompressed4a );
  PileupEstimation.CompressedEta4j <= UNSIGNED( EtaCompressed4j );
  PileupEstimation.CompressedEta2  <= UNSIGNED( EtaCompressed2 );
  PileupEstimation.towerCount      <= UNSIGNED( NonZeroCountCompressed );
  PileupEstimation.DataValid       <= AccumulatedRingPipeIn( 5 )( 0 ) .DataValid;


-- Stage the fanout in two layers of 1-to-6 fanout.
  phi : FOR i IN 5 DOWNTO 0 GENERATE
    PileupEstimationFanout1( 0 )( i ) <= PileupEstimation WHEN RISING_EDGE( clk );
    phi2   : FOR j IN 2 DOWNTO 0 GENERATE
      eta2 : FOR k IN 0 TO cRegionInEta-1 GENERATE
        PileupEstimationFanout2( k )( ( 3 * i ) + j ) <= PileupEstimationFanout1( 0 )( i ) WHEN RISING_EDGE( clk );
      END GENERATE eta2;
    END GENERATE phi2;
  END GENERATE phi;

  PileupEstimationPipeInstance : ENTITY work.PileupEstimationPipe
  PORT MAP(
    clk                  => clk ,
    PileupEstimationIn   => PileupEstimationFanout2 ,
    PileupEstimationPipe => PileupEstimationPipeOut
  );

  PileupEstimationPipe2Instance : ENTITY work.PileupEstimationPipe2
  PORT MAP(
    clk                  => clk ,
    PileupEstimationIn   => PileupEstimation ,
    PileupEstimationPipe => PileupEstimationPipe2Out
  );

END ARCHITECTURE behavioral;
