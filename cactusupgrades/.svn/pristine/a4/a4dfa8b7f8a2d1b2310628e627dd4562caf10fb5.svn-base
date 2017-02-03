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
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;
--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;


--! @brief An entity providing a EgammaCalibration
--! @details Detailed description
ENTITY EgammaCalibration IS
  GENERIC(
    PileupEstimationOffset : INTEGER := 0
  );
  PORT(
    clk                     : IN STD_LOGIC := '0' ;      --! The algorithm clock
    EgammaPipeIn            : IN tClusterPipe ;          --! A pipe of tCluster objects bringing in the Egamma's
    IsolationRegionPipeIn   : IN tIsolationRegionPipe ;  --! A pipe of tIsolationRegion objects bringing in the IsolationRegion's
    PileupEstimationPipeIn  : IN tPileupEstimationPipe ; --! A pipe of tPileupEstimation objects bringing in the PileupEstimation's
    CalibratedEgammaPipeOut : OUT tClusterPipe ;         --! A pipe of tCluster objects passing out the CalibratedEgamma's
    BusIn                   : IN tFMBus;
    BusOut                  : OUT tFMBus;
    BusClk                  : IN STD_LOGIC := '0'
  );
END ENTITY EgammaCalibration;


--! @brief Architecture definition for entity EgammaCalibration
--! @details Detailed description
ARCHITECTURE behavioral OF EgammaCalibration IS

  TYPE tVectorInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF STD_LOGIC_VECTOR( 36 DOWNTO 0 );
  TYPE tVectorInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tVectorInPhi;

  SIGNAL EgammaEnergy , EgammaEnergyCompressed                : tVectorInEtaPhi                 := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );

  SIGNAL EgammaEtaPlusFlagPlusEnergy                          : tVectorInEtaPhi                 := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL EgammaEtaPlusEnergyPlusNtt                           : tVectorInEtaPhi                 := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL EgammaIsolationLutOut                                : tVectorInEtaPhi                 := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );

  SIGNAL EgammaCalibrationLutOut , EgammaCalibrationLutOutClk : tVectorInEtaPhi                 := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL EgammaMultiplier , EgammaOffset                      : tVectorInEtaPhi                 := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );

  SIGNAL EgammaEnergyUncalibrated , EgammaEnergyCalibrated    : tVectorInEtaPhi                 := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );

  SIGNAL EgammaRelaxationThreshold                            : STD_LOGIC_VECTOR( 11 DOWNTO 0 ) := ( OTHERS => '0' );

  SIGNAL Egamma                                               : tClusterInEtaPhi                := cEmptyClusterInEtaPhi;
  SIGNAL IsolationFlag                                        : tComparisonInEtaPhi             := cEmptyComparisonInEtaPhi;

BEGIN

  phi   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ----------------------------------------------------------------------
      EgammaEnergy( j )( i )( 7 DOWNTO 0 ) <= "11111111" WHEN( EgammaPipeIn( 0 )( j )( i ) .Energy >= x"100" ) ELSE STD_LOGIC_VECTOR( EgammaPipeIn( 0 )( j )( i ) .Energy( 7 DOWNTO 0 ) );

      EgammaEnergyCompressionLutInstance : ENTITY work.GenRomClocked
      GENERIC MAP(
        FileName => "B_EnergyCompression_8to4.mif"
      )
      PORT MAP
      (
        clk       => Clk ,
        AddressIn => EgammaEnergy( j )( i )( 7 DOWNTO 0 ) ,
        DataOut   => EgammaEnergyCompressed( j )( i )( 3 DOWNTO 0 )
      );
-- ----------------------------------------------------------------------
    END GENERATE eta;
  END GENERATE phi;


-- ----------------------------------------------------------------------
  RelaxationCutThresh : ENTITY work.GenRegister
  GENERIC MAP(
    BusName      => "EgRelaxThr" ,
    DefaultValue => DefaultEgammaRelaxationThreshold ,
    Registering  => 2
  )
  PORT MAP(
    DataOut => EgammaRelaxationThreshold ,
    BusIn   => BusIn( BusOut'LOW TO BusOut'LOW ) ,
    BusOut  => BusOut( BusOut'LOW TO BusOut'LOW ) ,
    BusClk  => BusClk
  );
-- ----------------------------------------------------------------------


  phi2           : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta2         : FOR j IN 0 TO cRegionInEta-1 GENERATE
      CONSTANT x : INTEGER := ( BusOut'LOW + 1 ) + ( 4 * i ) + ( 2 * j );
      SUBTYPE C IS NATURAL RANGE x + 0 TO x + 0;
      SUBTYPE D IS NATURAL RANGE x + 1 TO x + 1;
    BEGIN

-- ----------------------------------------------------------------------
      EgammaEtaPlusFlagPlusEnergy( j )( i )( 11 DOWNTO 0 ) <= STD_LOGIC_VECTOR( PileupEstimationPipeIn( PileupEstimationOffset )( j )( i ) .CompressedEta4a ) & EgammaEnergyCompressed( j )( i )( 3 DOWNTO 0 ) & EgammaPipeIn( 1 )( j )( i ) .ShapeFlags( 3 DOWNTO 0 );

      EgammaCalibrationLutInstance : ENTITY work.GenPromClocked
      GENERIC MAP(
        FileName => "C_EgammaCalibration_12to18.mif" ,
        BusName  => "C_" & INTEGER'IMAGE( i ) & "_" & INTEGER'IMAGE( j )
      )
      PORT MAP(
        clk       => clk ,
        AddressIn => EgammaEtaPlusFlagPlusEnergy( j )( i )( 11 DOWNTO 0 ) ,
        DataOut   => EgammaCalibrationLutOut( j )( i )( 17 DOWNTO 0 ) ,
        BusIn     => BusIn( C ) ,
        BusOut    => BusOut( C ) ,
        BusClk    => BusClk
      );
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
      EgammaEtaPlusEnergyPlusNtt( j )( i )( 12 DOWNTO 0 ) <= STD_LOGIC_VECTOR( PileupEstimationPipeIn( PileupEstimationOffset )( j )( i ) .CompressedEta4a ) & EgammaEnergyCompressed( j )( i )( 3 DOWNTO 0 ) & STD_LOGIC_VECTOR( PileupEstimationPipeIn( PileupEstimationOffset )( j )( i ) .towerCount );

      EgammaIsolationLutInstance : ENTITY work.GenPromClocked
      GENERIC MAP(
        FileName => "D_EgammaIsolation_13to9.mif" ,
        BusName  => "D_" & INTEGER'IMAGE( i ) & "_" & INTEGER'IMAGE( j )
      )
      PORT MAP(
        clk       => clk ,
        AddressIn => EgammaEtaPlusEnergyPlusNtt( j )( i )( 12 DOWNTO 0 ) ,
        DataOut   => EgammaIsolationLutOut( j )( i )( 8 DOWNTO 0 ) ,
        BusIn     => BusIn( D ) ,
        BusOut    => BusOut( D ) ,
        BusClk    => BusClk
      );
-- ----------------------------------------------------------------------
    END GENERATE eta2;
  END GENERATE phi2;



  phi3   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta3 : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ----------------------------------------------------------------------
      EgammaEnergyUncalibrated( j )( i )( 12 DOWNTO 0 ) <= STD_LOGIC_VECTOR( EgammaPipeIn( 3 )( j )( i ) .Energy );

      EgammaMultiplier( j )( i )( 8 DOWNTO 0 )          <= EgammaCalibrationLutOut( j )( i )( 8 DOWNTO 0 );
      EgammaOffset( j )( i )( 15 DOWNTO 8 )             <= EgammaCalibrationLutOut( j )( i )( 17 DOWNTO 10 );
      EgammaOffset( j )( i )( 16 )                      <= EgammaCalibrationLutOut( j )( i )( 17 ) ; -- Copy the sign bit

      EgammaEnergyCorrectionMultiplierInstance : ENTITY work.CalibrationDSP
      PORT MAP(
        clk => Clk ,
        a   => EgammaEnergyUncalibrated( j )( i )( 24 DOWNTO 0 ) ,
        b   => EgammaMultiplier( j )( i )( 10 DOWNTO 0 ) ,
        c   => EgammaOffset( j )( i )( 16 DOWNTO 0 ) ,
        p   => EgammaEnergyCalibrated( j )( i )
      );
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
      PROCESS( Clk )
      BEGIN
        IF RISING_EDGE( Clk ) THEN
--IF NOT IsolationRegionPipeIn( 2 )( j )( i ) .DataValid THEN
-- IsolationFlag( j )( i ) <= cEmptyComparison;
--ELSE
            IsolationFlag( j )( i ) .Data      <= ( IsolationRegionPipeIn( 2 )( j )( i ) .Energy < UNSIGNED( EgammaIsolationLutOut( j )( i )( 7 DOWNTO 0 ) ) )
                                               OR (EgammaIsolationLutOut( j )( i )( 8 ) = '1' );
            IsolationFlag( j )( i ) .DataValid <= TRUE;
--END IF;
        END IF;
      END PROCESS;
-- ----------------------------------------------------------------------

    END GENERATE eta3;
  END GENERATE phi3;
  EgammaCalibrationLutOutClk <= EgammaCalibrationLutOut WHEN RISING_EDGE( Clk );


  phi4   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta4 : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ----------------------------------------------------------------------
      PROCESS( Clk )
      BEGIN
        IF RISING_EDGE( Clk ) THEN
          IF NOT EgammaPipeIn( 4 )( j )( i ) .DataValid THEN -- Error in data transfer
            Egamma( j )( i ) <= cEmptyCluster;
          ELSE
            Egamma( j )( i )           <= EgammaPipeIn( 4 )( j )( i );
            Egamma( j )( i ) .Isolated <= IsolationFlag( j )( i ) .Data;

            IF( EgammaCalibrationLutOutClk( j )( i )( 9 ) = '1' ) AND
                ( EgammaPipeIn( 4 )( j )( i ) .EgammaCandidate OR
                  TO_INTEGER( SIGNED( EgammaEnergyCalibrated( j )( i )( 19 DOWNTO 8 ) ) ) >= TO_INTEGER( SIGNED( EgammaRelaxationThreshold ) ) ) THEN --Shape cut , Ecal FG cut and E / H cut
              IF TO_INTEGER( SIGNED( EgammaEnergyCalibrated( j )( i )( 36 DOWNTO 8 ) ) ) < 0 THEN
                Egamma( j )( i ) .Energy( 11 DOWNTO 0 ) <= ( OTHERS => '0' );
              ELSIF TO_INTEGER( SIGNED( EgammaEnergyCalibrated( j )( i )( 36 DOWNTO 8 ) ) ) > 4095 THEN
                Egamma( j )( i ) .Energy( 11 DOWNTO 0 ) <= ( OTHERS => '1' );
              ELSE
                Egamma( j )( i ) .Energy( 11 DOWNTO 0 ) <= UNSIGNED( EgammaEnergyCalibrated( j )( i )( 19 DOWNTO 8 ) );
              END IF;
            ELSE
              Egamma( j )( i ) .Energy <= ( OTHERS => '0' );
            END IF;

          END IF;
        END IF;
      END PROCESS;
-- ----------------------------------------------------------------------
    END GENERATE eta4;
  END GENERATE phi4;

  EgammaPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => Egamma ,
    ClusterPipe => CalibratedEgammaPipeOut
  );

END ARCHITECTURE behavioral;
