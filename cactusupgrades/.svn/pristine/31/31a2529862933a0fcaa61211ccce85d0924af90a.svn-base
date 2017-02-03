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

--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;

--! @brief An entity providing a JetCalibration
--! @details Detailed description
ENTITY JetCalibration IS
  GENERIC(
    PileupEstimationOffset : INTEGER := 0
  );
  PORT(
    clk                    : IN STD_LOGIC := '0' ;      --! The algorithm clock
    JetPipeIn              : IN tJetPipe ;              --! A pipe of tJet objects bringing in the Jet's
    PileupEstimationPipeIn : IN tPileupEstimationPipe ; --! A pipe of tPileupEstimation objects bringing in the PileupEstimation's
    CalibratedJetPipeOut   : OUT tJetPipe ;             --! A pipe of tJet objects passing out the CalibratedJet's
    BusIn                  : IN tFMBus;
    BusOut                 : OUT tFMBus;
    BusClk                 : IN STD_LOGIC := '0'
  );
END ENTITY JetCalibration;


--! @brief Architecture definition for entity JetCalibration
--! @details Detailed description
ARCHITECTURE behavioral OF JetCalibration IS

  TYPE tVectorInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF STD_LOGIC_VECTOR( 36 DOWNTO 0 );
  TYPE tVectorInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tVectorInPhi;

  SIGNAL JetEnergy , JetEnergyCompressed             : tVectorInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL JetEtaPlusEnergy                            : tVectorInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL JetCalibrationLutOut                        : tVectorInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL JetMultiplier , JetOffset                   : tVectorInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL JetEnergyUncalibrated , JetEnergyCalibrated : tVectorInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) );
  SIGNAL Jet                                         : tJetInEtaPhi    := cEmptyJetInEtaPhi;

BEGIN

  phi   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE

-- ----------------------------------------------------------------------
      JetEnergy( j )( i )( 7 DOWNTO 0 ) <= "11111111" WHEN( JetPipeIn( 0 )( j )( i ) .Energy >= x"200" ) ELSE STD_LOGIC_VECTOR( JetPipeIn( 0 )( j )( i ) .Energy( 8 DOWNTO 1 ) );

      JetEnergyCompressionLutInstance : ENTITY work.GenRomClocked
      GENERIC MAP(
        FileName => "K_EnergyCompression_8to4.mif"
      )
      PORT MAP
      (
        clk       => Clk ,
        AddressIn => JetEnergy( j )( i )( 7 DOWNTO 0 ) ,
        DataOut   => JetEnergyCompressed( j )( i )( 3 DOWNTO 0 )
      );
-- ----------------------------------------------------------------------
    END GENERATE eta;
  END GENERATE phi;


  phi2           : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta2         : FOR j IN 0 TO cRegionInEta-1 GENERATE
      CONSTANT x : INTEGER := BusOut'LOW + ( 2 * i ) + j;
      SUBTYPE L IS NATURAL RANGE x + 0 TO x + 0;
    BEGIN
-- ----------------------------------------------------------------------
      JetEtaPlusEnergy( j )( i )( 7 DOWNTO 0 ) <= STD_LOGIC_VECTOR( PileupEstimationPipeIn( PileupEstimationOffset )( j )( i ) .CompressedEta4j ) & JetEnergyCompressed( j )( i )( 3 DOWNTO 0 );

      JetCalibrationLutInstance : ENTITY work.GenPromClocked
      GENERIC MAP(
        FileName => "L_JetCalibration_11to18.mif" ,
        BusName  => "L_" & INTEGER'IMAGE( i ) & "_" & INTEGER'IMAGE( j )
      )
      PORT MAP(
        clk       => clk ,
        AddressIn => JetEtaPlusEnergy( j )( i )( 10 DOWNTO 0 ) ,
        DataOut   => JetCalibrationLutOut( j )( i )( 17 DOWNTO 0 ) ,
        BusIn     => BusIn( L ) ,
        BusOut    => BusOut( L ) ,
        BusClk    => BusClk
      );
-- ----------------------------------------------------------------------
    END GENERATE eta2;
  END GENERATE phi2;


  phi3   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta3 : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ----------------------------------------------------------------------
      JetEnergyUncalibrated( j )( i )( 15 DOWNTO 0 ) <= STD_LOGIC_VECTOR( JetPipeIn( 3 )( j )( i ) .Energy( 15 DOWNTO 0 ) );
      JetMultiplier( j )( i )( 9 DOWNTO 0 )          <= JetCalibrationLutOut( j )( i )( 9 DOWNTO 0 );
      JetOffset( j )( i )( 16 DOWNTO 9 )             <= JetCalibrationLutOut( j )( i )( 17 DOWNTO 10 );

      JetEnergyCorrectionMultiplierInstance : ENTITY work.CalibrationDSP
      PORT MAP(
        clk => Clk ,
        a   => JetEnergyUncalibrated( j )( i )( 24 DOWNTO 0 ) ,
        b   => JetMultiplier( j )( i )( 10 DOWNTO 0 ) ,
        c   => JetOffset( j )( i )( 16 DOWNTO 0 ) ,
        p   => JetEnergyCalibrated( j )( i )
      );
-- ----------------------------------------------------------------------
    END GENERATE eta3;
  END GENERATE phi3;


  phi4   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta4 : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ----------------------------------------------------------------------
      PROCESS( Clk )
      BEGIN
        IF RISING_EDGE( Clk ) THEN
          IF NOT JetPipeIn( 4 )( j )( i ) .DataValid THEN -- Error in data transfer
            Jet( j )( i ) <= cEmptyJet;
          ELSE
            Jet( j )( i ) <= JetPipeIn( 4 )( j )( i );
            IF TO_INTEGER( SIGNED( JetEnergyCalibrated( j )( i )( 36 DOWNTO 9 ) ) ) < 0 THEN
              Jet( j )( i ) .Energy <= ( OTHERS => '0' );
            ELSIF TO_INTEGER( SIGNED( JetEnergyCalibrated( j )( i )( 36 DOWNTO 9 ) ) ) > 65535 THEN
              Jet( j )( i ) .Energy <= ( OTHERS => '1' );
            ELSE
              Jet( j )( i ) .Energy <= UNSIGNED( JetEnergyCalibrated( j )( i )( 24 DOWNTO 9 ) );
            END IF;
          END IF;
        END IF;
      END PROCESS;
-- ----------------------------------------------------------------------
    END GENERATE eta4;
  END GENERATE phi4;


  JetPipeInstance : ENTITY work.JetPipe
  PORT MAP(
    clk     => clk ,
    JetIn   => Jet ,
    JetPipe => CalibratedJetPipeOut
  );

END ARCHITECTURE behavioral;
