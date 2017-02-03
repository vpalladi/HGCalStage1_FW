--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;

--! Using the Calo-L2 "ring" helper functions
USE work.ring_functions.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;
--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;


--! @brief An entity providing a RingCalibration
--! @details Detailed description
ENTITY RingCalibration IS
  GENERIC(
    ringPipeOffset : INTEGER := 0
  );
  PORT(
    clk                    : IN STD_LOGIC := '0' ;       --! The algorithm clock
    ringPipeIn             : IN tRingSegmentPipe2 ;      --! A pipe of tRingSegment objects bringing in the ring's
    PileupEstimationPipeIn : IN tPileupEstimationPipe2 ; --! A pipe of tPileupEstimation objects bringing in the PileupEstimation's
    ringPipeOut            : OUT tRingSegmentPipe2 ;     --! A pipe of tRingSegment objects passing out the ring's
    BusIn                  : IN tFMBus;
    BusOut                 : OUT tFMBus;
    BusClk                 : IN STD_LOGIC := '0'
  );
END RingCalibration;

--! @brief Architecture definition for entity RingCalibration
--! @details Detailed description
ARCHITECTURE behavioral OF RingCalibration IS

  SIGNAL CalibratedRingInEta : tRingSegmentInEta                                          := cEmptyRingSegmentInEta;

  SIGNAL EtaCounter          : INTEGER RANGE 0 TO cTowersInHalfEta + cCMScoordinateOffset := cCMScoordinateOffset;

  TYPE tVectorInEta IS ARRAY( 0 TO cRegionInEta-1 ) OF STD_LOGIC_VECTOR( 36 DOWNTO 0 );

  SIGNAL ScalarLutInput , XLutInput , YLutInput                                    : tVectorInEta := ( OTHERS => ( OTHERS => '0' ) );
  SIGNAL XLutOutput , YLutOutput , ScalarLutOutput , EcalLutOutput                 : tVectorInEta := ( OTHERS => ( OTHERS => '0' ) );

  SIGNAL XMultiplier , YMultiplier , ScalarMultiplier , EcalMultiplier             : tVectorInEta := ( OTHERS => ( OTHERS => '0' ) );
  SIGNAL XEnergy , YEnergy , ScalarEnergy , EcalEnergy                             : tVectorInEta := ( OTHERS => ( OTHERS => '0' ) );
  SIGNAL XOffset , YOffset , ScalarOffset , EcalOffset                             : tVectorInEta := ( OTHERS => ( OTHERS => '0' ) );

  SIGNAL XDSPcalibrated , YDSPcalibrated , ScalarDSPcalibrated , EcalDSPcalibrated : tVectorInEta := ( OTHERS => ( OTHERS => '0' ) );

BEGIN

  prc : PROCESS( clk )
  BEGIN
    IF RISING_EDGE( clk ) THEN
      IF( NOT PileupEstimationPipeIn( 0 ) .DataValid ) THEN
        EtaCounter <= cCMScoordinateOffset;
      ELSE
        EtaCounter <= EtaCounter + 1;
      END IF;
    END IF;
  END PROCESS;

  eta          : FOR j IN 0 TO cRegionInEta-1 GENERATE
    CONSTANT x : INTEGER := BusOut'LOW + ( 4 * j );
    SUBTYPE MX IS NATURAL RANGE x + 0 TO x + 0;
    SUBTYPE MY IS NATURAL RANGE x + 1 TO x + 1;
    SUBTYPE MS IS NATURAL RANGE x + 2 TO x + 2;
    SUBTYPE ME IS NATURAL RANGE x + 3 TO x + 3;
  BEGIN

-- ----------------------------------------------------------------------
    XLutInput( j )( 10 )         <= '1' WHEN ringPipeIn( ringPipeOffset + 0 )( j ) .xComponent < 0 ELSE '0';
    XLutInput( j )( 9 DOWNTO 0 ) <= STD_LOGIC_VECTOR( PileupEstimationPipeIn( 0 ) .towerCount ) &
                                    STD_LOGIC_VECTOR( TO_UNSIGNED( EtaCounter , 5 ) );

    XLutInstance : ENTITY work.GenPromClocked
    GENERIC MAP(
      FileName => "M_ETMETX_11to18.mif" ,
      BusName  => "MX_" & INTEGER'IMAGE( j )
    )
    PORT MAP(
      clk       => clk ,
      AddressIn => XLutInput( j )( 10 DOWNTO 0 ) ,
      DataOut   => XLutOutput( j )( 17 DOWNTO 0 ) ,
      BusIn     => BusIn( MX ) ,
      BusOut    => BusOut( MX ) ,
      BusClk    => BusClk
    );

-- ( 24 downto 0 ) are valid data
    XEnergy( j )( 24 DOWNTO 0 )    <= STD_LOGIC_VECTOR( ringPipeIn( ringPipeOffset + 2 )( j ) .xComponent( 24 DOWNTO 0 ) );
    XMultiplier( j )( 9 DOWNTO 0 ) <= XLutOutput( j )( 9 DOWNTO 0 );
    XOffset( j )( 16 DOWNTO 9 )    <= XLutOutput( j )( 17 DOWNTO 10 );


    XDSPInstance : ENTITY work.CalibrationDSP
    PORT MAP(
      clk => clk ,
      a   => XEnergy( j )( 24 DOWNTO 0 ) ,
      b   => XMultiplier( j )( 10 DOWNTO 0 ) ,
      c   => XOffset( j )( 16 DOWNTO 0 ) ,
      p   => XDSPcalibrated( j )
    );

    CalibratedRingInEta( j ) .xComponent <= TO_SIGNED( TO_INTEGER( SIGNED( XDSPcalibrated( j )( 36 DOWNTO 9 ) ) ) , 32 );
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
    YLutInput( j )( 10 )                 <= '1' WHEN ringPipeIn( ringPipeOffset + 0 )( j ) .xComponent < 0 ELSE '0';
    YLutInput( j )( 9 DOWNTO 0 )         <= STD_LOGIC_VECTOR( PileupEstimationPipeIn( 0 ) .towerCount ) &
                                    STD_LOGIC_VECTOR( TO_UNSIGNED( EtaCounter , 5 ) );


    YLutInstance : ENTITY work.GenPromClocked
    GENERIC MAP(
      FileName => "M_ETMETY_11to18.mif" ,
      BusName  => "MY_" & INTEGER'IMAGE( j )
    )
    PORT MAP(
      clk       => clk ,
      AddressIn => YLutInput( j )( 10 DOWNTO 0 ) ,
      DataOut   => YLutOutput( j )( 17 DOWNTO 0 ) ,
      BusIn     => BusIn( MY ) ,
      BusOut    => BusOut( MY ) ,
      BusClk    => BusClk
    );

-- ( 24 downto 0 ) are valid data
    YEnergy( j )( 24 DOWNTO 0 )    <= STD_LOGIC_VECTOR( ringPipeIn( ringPipeOffset + 2 )( j ) .yComponent( 24 DOWNTO 0 ) );
    YMultiplier( j )( 9 DOWNTO 0 ) <= YLutOutput( j )( 9 DOWNTO 0 );
    YOffset( j )( 16 DOWNTO 9 )    <= YLutOutput( j )( 17 DOWNTO 10 );

    YDSPInstance : ENTITY work.CalibrationDSP
    PORT MAP(
      clk => clk ,
      a   => YEnergy( j )( 24 DOWNTO 0 ) ,
      b   => YMultiplier( j )( 10 DOWNTO 0 ) ,
      c   => YOffset( j )( 16 DOWNTO 0 ) ,
      p   => YDSPcalibrated( j )
    );

    CalibratedRingInEta( j ) .yComponent <= TO_SIGNED( TO_INTEGER( SIGNED( YDSPcalibrated( j )( 36 DOWNTO 9 ) ) ) , 32 );
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
    ScalarLutInput( j )( 9 DOWNTO 0 )    <= STD_LOGIC_VECTOR( PileupEstimationPipeIn( 0 ) .towerCount ) &
                                    STD_LOGIC_VECTOR( TO_UNSIGNED( EtaCounter , 5 ) );

    ScalarLutInstance : ENTITY work.GenPromClocked
    GENERIC MAP(
      FileName => "M_ETMET_11to18.mif" ,
      BusName  => "MS_" & INTEGER'IMAGE( j )
    )
    PORT MAP(
      clk       => clk ,
      AddressIn => ScalarLutInput( j )( 10 DOWNTO 0 ) ,
      DataOut   => ScalarLutOutput( j )( 17 DOWNTO 0 ) ,
      BusIn     => BusIn( MS ) ,
      BusOut    => BusOut( MS ) ,
      BusClk    => BusClk
    );

    ScalarEnergy( j )( 24 DOWNTO 0 )    <= "00" & STD_LOGIC_VECTOR( ringPipeIn( ringPipeOffset + 2 )( j ) .energy );
    ScalarMultiplier( j )( 9 DOWNTO 0 ) <= ScalarLutOutput( j )( 9 DOWNTO 0 );
    ScalarOffset( j )( 16 DOWNTO 9 )    <= ScalarLutOutput( j )( 17 DOWNTO 10 );

    ScalarDSPInstance : ENTITY work.CalibrationDSP
    PORT MAP(
      clk => clk ,
      a   => ScalarEnergy( j )( 24 DOWNTO 0 ) ,
      b   => ScalarMultiplier( j )( 10 DOWNTO 0 ) ,
      c   => ScalarOffset( j )( 16 DOWNTO 0 ) ,
      p   => ScalarDSPcalibrated( j )
    );

    CalibratedRingInEta( j ) .energy <= ( OTHERS => '0' ) WHEN TO_INTEGER( SIGNED( ScalarDSPcalibrated( j )( 36 DOWNTO 9 ) ) ) < 0
                                   ELSE( OTHERS  => '1' ) WHEN TO_INTEGER( SIGNED( ScalarDSPcalibrated( j )( 36 DOWNTO 9 ) ) ) > 8388607
                                   ELSE UNSIGNED( ScalarDSPcalibrated( j )( 31 DOWNTO 9 ) );
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
    ecalLutInstance : ENTITY work.GenPromClocked
    GENERIC MAP(
      FileName => "M_ETMETecal_11to18.mif" ,
      BusName  => "ME_" & INTEGER'IMAGE( j )
    )
    PORT MAP(
      clk       => clk ,
      AddressIn => scalarLutInput( j )( 10 DOWNTO 0 ) ,
      DataOut   => ecalLutOutput( j )( 17 DOWNTO 0 ) ,
      BusIn     => BusIn( ME ) ,
      BusOut    => BusOut( ME ) ,
      BusClk    => BusClk
    );

    ecalEnergy( j )( 24 DOWNTO 0 )    <= "00" & STD_LOGIC_VECTOR( ringPipeIn( ringPipeOffset + 2 )( j ) .ecal );
    ecalMultiplier( j )( 9 DOWNTO 0 ) <= ecalLutOutput( j )( 9 DOWNTO 0 );
    ecalOffset( j )( 16 DOWNTO 9 )    <= ecalLutOutput( j )( 17 DOWNTO 10 );

    ecalDSPInstance : ENTITY work.CalibrationDSP
    PORT MAP(
      clk => clk ,
      a   => ecalEnergy( j )( 24 DOWNTO 0 ) ,
      b   => ecalMultiplier( j )( 10 DOWNTO 0 ) ,
      c   => ecalOffset( j )( 16 DOWNTO 0 ) ,
      p   => ecalDSPcalibrated( j )
    );


    CalibratedRingInEta( j ) .ecal <= ( OTHERS => '0' ) WHEN TO_INTEGER( SIGNED( ecalDSPcalibrated( j )( 36 DOWNTO 9 ) ) ) < 0
                                 ELSE( OTHERS  => '1' ) WHEN TO_INTEGER( SIGNED( ecalDSPcalibrated( j )( 36 DOWNTO 9 ) ) ) > 8388607
                                 ELSE UNSIGNED( ecalDSPcalibrated( j )( 31 DOWNTO 9 ) );
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
    CalibratedRingInEta( j ) .towerCount <= ringPipeIn( ringPipeOffset + 3 )( j ) .towerCount;
    CalibratedRingInEta( j ) .DataValid  <= ringPipeIn( ringPipeOffset + 3 )( j ) .DataValid;
-- ----------------------------------------------------------------------

  END GENERATE;

  RingPipeInstance : ENTITY work.RingPipe2
  PORT MAP(
    clk      => clk ,
    RingsIn  => CalibratedRingInEta ,
    RingPipe => ringPipeOut
  );

END ARCHITECTURE behavioral;
