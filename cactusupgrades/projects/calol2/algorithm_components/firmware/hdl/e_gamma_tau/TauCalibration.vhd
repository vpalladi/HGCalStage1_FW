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

--! @brief An entity providing a TauCalibration
--! @details Detailed description
ENTITY TauCalibration IS
  GENERIC(
    PileupEstimationOffset : INTEGER := 0
  );
  PORT(
    clk                    : IN STD_LOGIC := '0' ;      --! The algorithm clock
    TauPipeIn              : IN tClusterPipe ;          --! A pipe of tCluster objects bringing in the Tau's
    IsolationRegionPipeIn  : IN tIsolationRegionPipe ;  --! A pipe of tIsolationRegion objects bringing in the IsolationRegion's
    PileupEstimationPipeIn : IN tPileupEstimationPipe ; --! A pipe of tPileupEstimation objects bringing in the PileupEstimation's
    CalibratedTauPipeOut   : OUT tClusterPipe ;         --! A pipe of tCluster objects passing out the CalibratedTau's
    BusIn                  : IN tFMBus;
    BusOut                 : OUT tFMBus;
    BusClk                 : IN STD_LOGIC := '0'
  );
END ENTITY TauCalibration;


--! @brief Architecture definition for entity TauCalibration
--! @details Detailed description
ARCHITECTURE behavioral OF TauCalibration IS

  TYPE tVectorInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF STD_LOGIC_VECTOR( 36 DOWNTO 0 );
  TYPE tVectorInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tVectorInPhi;

  SIGNAL TauEnergy , TauEnergyCompressed             : tVectorInEtaPhi     := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL TauEtaPlusEnergyPlusFlags                   : tVectorInEtaPhi     := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL TauEtaPlusEnergyPlusNtt                     : tVectorInEtaPhi     := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL TauCalibrationLutOut                        : tVectorInEtaPhi     := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL TauMultiplier , TauOffset                   : tVectorInEtaPhi     := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );

  SIGNAL TauIsolationLutOut , TauIsolationLutOut2    : tVectorInEtaPhi     := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL TauEnergyUncalibrated , TauEnergyCalibrated : tVectorInEtaPhi     := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL Tau                                         : tClusterInEtaPhi    := cEmptyClusterInEtaPhi;
  SIGNAL IsolationFlag , IsolationFlag2              : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;

BEGIN

  phi   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE

-- ----------------------------------------------------------------------
      TauEnergy( j )( i )( 7 DOWNTO 0 ) <= "11111111" WHEN( TauPipeIn( 0 )( j )( i ) .Energy >= x"100" ) ELSE STD_LOGIC_VECTOR( TauPipeIn( 0 )( j )( i ) .Energy( 7 DOWNTO 0 ) );

      TauEnergyCompressionLutInstance : ENTITY work.GenRomClocked
      GENERIC MAP(
        FileName => "F_TauEnergyCompression_8to5.mif"
      )
      PORT MAP
      (
        clk       => Clk ,
        AddressIn => TauEnergy( j )( i )( 7 DOWNTO 0 ) ,
        DataOut   => TauEnergyCompressed( j )( i )( 4 DOWNTO 0 )
      );
-- ----------------------------------------------------------------------
    END GENERATE eta;
  END GENERATE phi;


  phi2           : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta2         : FOR j IN 0 TO cRegionInEta-1 GENERATE
      CONSTANT x : INTEGER := BusOut'LOW + ( 6 * i ) + ( 3 * j );
      SUBTYPE I1 IS NATURAL RANGE x + 0 TO x + 0;
      SUBTYPE H1 IS NATURAL RANGE x + 1 TO x + 1;
      SUBTYPE H2 IS NATURAL RANGE x + 2 TO x + 2;
    BEGIN

-- ----------------------------------------------------------------------
      TauEtaPlusEnergyPlusFlags( j )( i )( 8 DOWNTO 0 ) <= STD_LOGIC_VECTOR( PileupEstimationPipeIn( PileupEstimationOffset )( j )( i ) .CompressedEta2 ) & TauEnergyCompressed( j )( i )( 4 DOWNTO 0 ) & TO_STD_LOGIC( TauPipeIn( 1 )( j )( i ) .HasEM ) & TO_STD_LOGIC( NOT TauPipeIn( 1 )( j )( i ) .NoSecondary );

      TauCalibrationLutInstance : ENTITY work.GenPromClocked
      GENERIC MAP(
        FileName => "I_TauCalibration_11to18.mif" ,
        BusName  => "I_" & INTEGER'IMAGE( i ) & "_" & INTEGER'IMAGE( j )
      )
      PORT MAP(
        clk       => clk ,
        AddressIn => TauEtaPlusEnergyPlusFlags( j )( i )( 10 DOWNTO 0 ) ,
        DataOut   => TauCalibrationLutOut( j )( i )( 17 DOWNTO 0 ) ,
        BusIn     => BusIn( I1 ) ,
        BusOut    => BusOut( I1 ) ,
        BusClk    => BusClk
      );
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
      TauEtaPlusEnergyPlusNtt( j )( i )( 11 DOWNTO 0 ) <= STD_LOGIC_VECTOR( PileupEstimationPipeIn( PileupEstimationOffset )( j )( i ) .CompressedEta2 ) & TauEnergyCompressed( j )( i )( 4 DOWNTO 0 ) & STD_LOGIC_VECTOR( PileupEstimationPipeIn( PileupEstimationOffset )( j )( i ) .towerCount );

      TauIsolationLutInstance : ENTITY work.GenPromClocked
      GENERIC MAP(
        FileName => "H_TauIsolation1_12to9.mif" ,
        BusName  => "H1_" & INTEGER'IMAGE( i ) & "_" & INTEGER'IMAGE( j )
      )
      PORT MAP(
        clk       => clk ,
        AddressIn => TauEtaPlusEnergyPlusNtt( j )( i )( 11 DOWNTO 0 ) ,
        DataOut   => TauIsolationLutOut( j )( i )( 8 DOWNTO 0 ) ,
        BusIn     => BusIn( H1 ) ,
        BusOut    => BusOut( H1 ) ,
      BusClk      => BusClk
      );

      TauIsolationLutInstance2 : ENTITY work.GenPromClocked
      GENERIC MAP(
        FileName => "H_TauIsolation2_12to9.mif" ,
        BusName  => "H2_" & INTEGER'IMAGE( i ) & "_" & INTEGER'IMAGE( j )
      )
      PORT MAP(
        clk       => clk ,
        AddressIn => TauEtaPlusEnergyPlusNtt( j )( i )( 11 DOWNTO 0 ) ,
        DataOut   => TauIsolationLutOut2( j )( i )( 8 DOWNTO 0 ) ,
        BusIn     => BusIn( H2 ) ,
        BusOut    => BusOut( H2 ) ,
      BusClk      => BusClk
      );
-- ----------------------------------------------------------------------
    END GENERATE eta2;
  END GENERATE phi2;


  phi3   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta3 : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ----------------------------------------------------------------------
      TauEnergyUncalibrated( j )( i )( 12 DOWNTO 0 ) <= STD_LOGIC_VECTOR( TauPipeIn( 3 )( j )( i ) .Energy );
      TauMultiplier( j )( i )( 9 DOWNTO 0 )          <= TauCalibrationLutOut( j )( i )( 9 DOWNTO 0 );
      TauOffset( j )( i )( 16 DOWNTO 9 )             <= TauCalibrationLutOut( j )( i )( 17 DOWNTO 10 );

      TauEnergyCorrectionMultiplierInstance : ENTITY work.CalibrationDSP
      PORT MAP(
        clk => Clk ,
        a   => TauEnergyUncalibrated( j )( i )( 24 DOWNTO 0 ) ,
        b   => TauMultiplier( j )( i )( 10 DOWNTO 0 ) ,
        c   => TauOffset( j )( i )( 16 DOWNTO 0 ) ,
        p   => TauEnergyCalibrated( j )( i )
      );

-- ----------------------------------------------------------------------
      PROCESS( Clk )
      BEGIN
        IF RISING_EDGE( Clk ) THEN
--IF NOT IsolationRegionPipeIn( 2 )( j )( i ) .DataValid THEN
-- IsolationFlag( j )( i ) <= cEmptyComparison;
-- IsolationFlag2( j )( i ) <= cEmptyComparison;
--ELSE
            IsolationFlag( j )( i ) .Data       <= ( IsolationRegionPipeIn( 2 )( j )( i ) .Energy < UNSIGNED( TauIsolationLutOut( j )( i )( 7 DOWNTO 0 ) ) )
                                                OR ( TauIsolationLutOut( j )( i )( 8 ) = '1' );
            IsolationFlag( j )( i ) .DataValid  <= TRUE;

            IsolationFlag2( j )( i ) .Data      <= ( IsolationRegionPipeIn( 2 )( j )( i ) .Energy < UNSIGNED( TauIsolationLutOut2( j )( i )( 7 DOWNTO 0 ) ) )
                                                OR ( TauIsolationLutOut2( j )( i )( 8 ) = '1' );
            IsolationFlag2( j )( i ) .DataValid <= TRUE;
--END IF;
        END IF;
      END PROCESS;
-- ----------------------------------------------------------------------
    END GENERATE eta3;
  END GENERATE phi3;


  phi4   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta4 : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ----------------------------------------------------------------------
      PROCESS( Clk )
      BEGIN
        IF RISING_EDGE( Clk ) THEN
          IF NOT TauPipeIn( 4 )( j )( i ) .DataValid THEN -- Error in data transfer
            Tau( j )( i ) <= cEmptyCluster;
          ELSE
            Tau( j )( i )            <= TauPipeIn( 4 )( j )( i );
            Tau( j )( i ) .Isolated  <= IsolationFlag( j )( i ) .Data;
            Tau( j )( i ) .Isolated2 <= IsolationFlag2( j )( i ) .Data;

            IF TO_INTEGER( SIGNED( TauEnergyCalibrated( j )( i )( 36 DOWNTO 9 ) ) ) < 0 THEN
              Tau( j )( i ) .Energy( 11 DOWNTO 0 ) <= ( OTHERS => '0' );
            ELSIF TO_INTEGER( SIGNED( TauEnergyCalibrated( j )( i )( 36 DOWNTO 9 ) ) ) > 4095 THEN
              Tau( j )( i ) .Energy( 11 DOWNTO 0 ) <= ( OTHERS => '1' );
            ELSE
              Tau( j )( i ) .Energy( 11 DOWNTO 0 ) <= UNSIGNED( TauEnergyCalibrated( j )( i )( 20 DOWNTO 9 ) );
            END IF;

          END IF;
        END IF;
      END PROCESS;
-- ----------------------------------------------------------------------
    END GENERATE eta4;
  END GENERATE phi4;


  TauPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => Tau ,
    ClusterPipe => CalibratedTauPipeOut
  );

END ARCHITECTURE behavioral;
