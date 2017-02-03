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

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;

--! Using the Calo-L2 "jet" helper functions
USE work.jet_functions.ALL;
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;
--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;

--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;


--! @brief An entity providing a JetFormer
--! @details Detailed description
ENTITY JetFormer IS
  GENERIC(
    vetoOffset      : INTEGER := 0;
    thresholdOffset : INTEGER := 0
  );
  PORT(
    clk                   : IN STD_LOGIC := '0' ; --! The algorithm clock
    jetVetoPipeIn         : IN tComparisonPipe ;  --! A pipe of tComparison objects bringing in the jetVeto's
    strip3x9PipeIn        : IN tJetPipe ;         --! A pipe of tJet objects bringing in the strip3x9's
    TowerThresholdsPipeIn : IN tTowerFlagsPipe ;  --! A pipe of tTowerFlags objects bringing in the TowerThresholds's
    filteredJetPipeOut    : OUT tJetPipe ;        --! A pipe of tJet objects passing out the filteredJet's
    BusIn                 : IN tFMBus;
    BusOut                : OUT tFMBus;
    BusClk                : IN STD_LOGIC := '0'
  );
END JetFormer;

--! @brief Architecture definition for entity JetFormer
--! @details Detailed description
ARCHITECTURE behavioral OF JetFormer IS

  TYPE tJetsInputs        IS ARRAY( 2 DOWNTO 0 ) OF tJet;
  TYPE tJetsInputInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF tJetsInputs;
  TYPE tJetsInputInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tJetsInputInPhi;
  TYPE tJetsInputsPerSite IS ARRAY( 3 DOWNTO 0 ) OF tJetsInputInEtaPhi;

  SIGNAL JetSumInput     : tJetsInputsPerSite := ( OTHERS => ( OTHERS => ( OTHERS => ( OTHERS => cEmptyJet ) ) ) );
  SIGNAL JetSumInput2    : tJetsInputInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => cEmptyJet ) ) );

  SIGNAL jets9x9InEtaPhi : tJetInEtaPhi       := cEmptyJetInEtaPhi;

  TYPE tEtaCounterInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF INTEGER RANGE 0 TO cTowersInHalfEta + cCMScoordinateOffset ; -- cTowerInPhi / 4 wide
  TYPE tEtaCounterInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tEtaCounterInPhi ; -- Two halves in eta
  SIGNAL EtaCounter           : tEtaCounterInEtaPhi            := ( OTHERS => ( OTHERS => cCMScoordinateOffset ) );

  SIGNAL filteredJetInEtaPhi  : tJetInEtaPhi                   := cEmptyJetInEtaPhi;
  SIGNAL filteredJetInEtaPhi2 : tJetInEtaPhi                   := cEmptyJetInEtaPhi;

  SIGNAL EtaLimit             : STD_LOGIC_VECTOR( 5 DOWNTO 0 ) := ( OTHERS => '0' );

BEGIN

-- --------------------------------------------------
  JetEtaLimitInstance : ENTITY work.GenRegister
  GENERIC MAP(
    BusName      => "JetEtaMax" ,
    DefaultValue => DefaultJetEtaMax ,
    Registering  => 2
  )
  PORT MAP(
    DataOut => EtaLimit ,
    BusIn   => BusIn ,
    BusOut  => BusOut ,
    BusClk  => BusClk
  );
-- --------------------------------------------------

  phi      : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta    : FOR j IN 0 TO cRegionInEta-1 GENERATE
      site : FOR k IN 3 DOWNTO 0 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        JetSumInput( k )( j )( i )( 0 ) <= strip3x9PipeIn( 0 )( j )( MOD_PHI( ( 4 * i ) + k - 3 ) );
        JetSumInput( k )( j )( i )( 1 ) <= strip3x9PipeIn( 0 )( j )( MOD_PHI( ( 4 * i ) + k + 0 ) );
        JetSumInput( k )( j )( i )( 2 ) <= strip3x9PipeIn( 0 )( j )( MOD_PHI( ( 4 * i ) + k + 3 ) );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      END GENERATE site;

      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN

--IF( NOT strip3x9PipeIn( 0 )( j )( ( 4 * i ) + 0 ) .DataValid OR NOT jetVetoPipeIn( vetoOffset )( j )( ( 4 * i ) + 0 ) .DataValid ) THEN -- + 1
-- EtaCounter( j )( i ) <= cCMScoordinateOffset;
--ELSE
-- EtaCounter( j )( i ) <= EtaCounter( j )( i ) + 1;
--END IF;

          IF cIncludeNullState AND NOT jetVetoPipeIn( vetoOffset )( j )( ( 4 * i ) + 0 ) .DataValid THEN
            JetSumInput2( j )( i )              <= ( OTHERS => cEmptyJet );
            filteredJetInEtaPhi2( j )( i ) .Phi <= 0;
            filteredJetInEtaPhi2( j )( i ) .Eta <= 0;
            EtaCounter( j )( i )                <= cCMScoordinateOffset;
          ELSE
            EtaCounter( j )( i ) <= EtaCounter( j )( i ) + 1;

            IF( EtaCounter( j )( i ) >= TO_INTEGER( UNSIGNED( EtaLimit ) ) + cCMScoordinateOffset ) THEN
              JetSumInput2( j )( i )              <= ( OTHERS => cEmptyJet );
              filteredJetInEtaPhi2( j )( i ) .Phi <= 0;
              filteredJetInEtaPhi2( j )( i ) .Eta <= EtaCounter( j )( i );
            ELSIF( NOT jetVetoPipeIn( vetoOffset )( j )( ( 4 * i ) + 0 ) .Data AND TowerThresholdsPipeIn( thresholdOffset )( j )( ( 4 * i ) + 0 ) .JetSeedThreshold ) THEN -- + 1
              JetSumInput2( j )( i )              <= JetSumInput( 0 )( j )( i );
              filteredJetInEtaPhi2( j )( i ) .Phi <= MOD_PHI( ( 4 * i ) + 0 ) + cCMScoordinateOffset;
              filteredJetInEtaPhi2( j )( i ) .Eta <= EtaCounter( j )( i );
            ELSIF( NOT jetVetoPipeIn( vetoOffset )( j )( ( 4 * i ) + 1 ) .Data AND TowerThresholdsPipeIn( thresholdOffset )( j )( ( 4 * i ) + 1 ) .JetSeedThreshold ) THEN -- + 1
              JetSumInput2( j )( i )              <= JetSumInput( 1 )( j )( i );
              filteredJetInEtaPhi2( j )( i ) .Phi <= MOD_PHI( ( 4 * i ) + 1 ) + cCMScoordinateOffset;
              filteredJetInEtaPhi2( j )( i ) .Eta <= EtaCounter( j )( i );
            ELSIF( NOT jetVetoPipeIn( vetoOffset )( j )( ( 4 * i ) + 2 ) .Data AND TowerThresholdsPipeIn( thresholdOffset )( j )( ( 4 * i ) + 2 ) .JetSeedThreshold ) THEN -- + 1
              JetSumInput2( j )( i )              <= JetSumInput( 2 )( j )( i );
              filteredJetInEtaPhi2( j )( i ) .Phi <= MOD_PHI( ( 4 * i ) + 2 ) + cCMScoordinateOffset;
              filteredJetInEtaPhi2( j )( i ) .Eta <= EtaCounter( j )( i );
            ELSIF( NOT jetVetoPipeIn( vetoOffset )( j )( ( 4 * i ) + 3 ) .Data AND TowerThresholdsPipeIn( thresholdOffset )( j )( ( 4 * i ) + 3 ) .JetSeedThreshold ) THEN -- + 1
              JetSumInput2( j )( i )              <= JetSumInput( 3 )( j )( i );
              filteredJetInEtaPhi2( j )( i ) .Phi <= MOD_PHI( ( 4 * i ) + 3 ) + cCMScoordinateOffset;
              filteredJetInEtaPhi2( j )( i ) .Eta <= EtaCounter( j )( i );
            ELSE
              JetSumInput2( j )( i )              <= ( OTHERS => cEmptyJet );
              filteredJetInEtaPhi2( j )( i ) .Phi <= 0;
              filteredJetInEtaPhi2( j )( i ) .Eta <= EtaCounter( j )( i );
            END IF;

            JetSumInput2( j )( i )( 0 ) .DataValid <= JetSumInput( 0 )( j )( i )( 0 ) .DataValid;
            JetSumInput2( j )( i )( 1 ) .DataValid <= JetSumInput( 0 )( j )( i )( 1 ) .DataValid;
            JetSumInput2( j )( i )( 2 ) .DataValid <= JetSumInput( 0 )( j )( i )( 2 ) .DataValid;
          END IF;

        END IF;
      END PROCESS;

      Sum9x9Instance : ENTITY work.JetSum
      PORT MAP(
        clk    => clk ,
        jetIn1 => JetSumInput2( j )( i )( 0 ) ,
        jetIn2 => JetSumInput2( j )( i )( 1 ) ,
        jetIn3 => JetSumInput2( j )( i )( 2 ) ,
        jetOut => jets9x9InEtaPhi( j )( i )
      );

      filteredJetInEtaPhi( j )( i ) .Energy    <= jets9x9InEtaPhi( j )( i ) .Energy;
      filteredJetInEtaPhi( j )( i ) .DataValid <= jets9x9InEtaPhi( j )( i ) .DataValid;
      filteredJetInEtaPhi( j )( i ) .Phi       <= filteredJetInEtaPhi2( j )( i ) .Phi WHEN RISING_EDGE( clk );
      filteredJetInEtaPhi( j )( i ) .Eta       <= filteredJetInEtaPhi2( j )( i ) .Eta WHEN RISING_EDGE( clk );

    END GENERATE eta;
  END GENERATE phi;

  JetPipeInstance : ENTITY work.JetPipe
  PORT MAP(
    clk     => clk ,
    jetIn   => filteredJetInEtaPhi ,
    jetPipe => filteredJetPipeOut
  );

END ARCHITECTURE behavioral;
