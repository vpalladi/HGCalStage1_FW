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


--! @brief An entity providing a PileUpEstimator
--! @details Detailed description
ENTITY PileUpEstimator IS
  GENERIC(
    vetoOffset : INTEGER := 0
  );
  PORT(
    clk            : IN STD_LOGIC := '0' ; --! The algorithm clock
    jetVetoPipeIn  : IN tComparisonPipe ;  --! A pipe of tComparison objects bringing in the jetVeto's
    strip9x3PipeIn : IN tJetPipe ;         --! A pipe of tJet objects bringing in the strip9x3's
    strip3x9PipeIn : IN tJetPipe ;         --! A pipe of tJet objects bringing in the strip3x9's
    pileUpPipeOut  : OUT tJetPipe          --! A pipe of tJet objects passing out the pileUp's
  );
END PileUpEstimator;

--! @brief Architecture definition for entity PileUpEstimator
--! @details Detailed description
ARCHITECTURE behavioral OF PileUpEstimator IS

  TYPE tRamAccessInPhi    IS ARRAY( 0 TO cTowerInPhi-1 ) OF STD_LOGIC_VECTOR( 15 DOWNTO 0 );
  TYPE tRamAccessInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tRamAccessInPhi ; -- Two halves in eta
  SIGNAL ram_out : tRamAccessInEtaPhi;

  TYPE tPileupEstimateInput         IS ARRAY( 3 DOWNTO 0 ) OF UNSIGNED( 15 DOWNTO 0 ) ; -- 18 sites around phi , 4 input values for each pileup estimate
  TYPE tPileupEstimateInputInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF tPileupEstimateInput ; -- 18 sites around phi , 4 input values for each pileup estimate
  TYPE tPileupEstimateInputInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tPileupEstimateInputInPhi ; -- Two halves in eta
  TYPE tPileupEstimateInputsPerSite IS ARRAY( 3 DOWNTO 0 ) OF tPileupEstimateInputInEtaPhi ; -- Four jet candidates per site

  SIGNAL PileupEstimateInput  : tPileupEstimateInputsPerSite := ( OTHERS => ( OTHERS => ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) ) ) );
  SIGNAL PileupEstimateInput2 : tPileupEstimateInputInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) ) );
  SIGNAL PileupEstimateInput3 : tPileupEstimateInputInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) ) );
  SIGNAL PileupEstimateInput4 : tPileupEstimateInputInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => ( OTHERS => '0' ) ) ) );

  SIGNAL PileupEstimate       : tJetInEtaPhi                 := cEmptyJetInEtaPhi;

BEGIN


  phi0                        : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    PipelineOffsetRAMInstance : ENTITY work.PipelineOffsetRAM
    GENERIC MAP(
      width => 16 ,
      depth => 6
    )
    PORT MAP(
      clk          => clk ,
      data_in_pos  => STD_LOGIC_VECTOR( strip9x3PipeIn( 0 )( 0 )( i ) .Energy ) ,
      data_in_neg  => STD_LOGIC_VECTOR( strip9x3PipeIn( 0 )( 1 )( i ) .Energy ) ,
      valid_in     => strip9x3PipeIn( 0 )( 0 )( i ) .DataValid ,
      data_out_pos => ram_out( 0 )( i ) ,
      data_out_neg => ram_out( 1 )( i )
    );
  END GENERATE phi0;




  phi      : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta    : FOR j IN 0 TO cRegionInEta-1 GENERATE
      site : FOR k IN 3 DOWNTO 0 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 9 in phi by 3 in eta
        PileupEstimateInput( k )( j )( i )( 0 ) <= ( OTHERS => '0' ) WHEN( cIncludeNullState AND NOT strip9x3PipeIn( 6 )( j )( ( 4 * i ) + k ) .DataValid ) -- [for frame 0 , an invalid object]
                                        ELSE strip9x3PipeIn( 0 )( j )( ( 4 * i ) + k ) .Energy;

-- PileupEstimateInput( k )( j )( i )( 1 ) <= ( OTHERS => '0' ) WHEN( cIncludeNullState AND NOT strip9x3PipeIn( 6 )( j )( ( 4 * i ) + k ) .DataValid ) -- [for frame 0 , an invalid object]
-- ELSE strip9x3PipeIn( 1 )( OPP_ETA( j ) )( ( 4 * i ) + k ) .Energy WHEN NOT strip9x3PipeIn( 7 )( j )( ( 4 * i ) + k ) .DataValid
-- ELSE strip9x3PipeIn( 3 )( OPP_ETA( j ) )( ( 4 * i ) + k ) .Energy WHEN NOT strip9x3PipeIn( 8 )( j )( ( 4 * i ) + k ) .DataValid
-- ELSE strip9x3PipeIn( 5 )( OPP_ETA( j ) )( ( 4 * i ) + k ) .Energy WHEN NOT strip9x3PipeIn( 9 )( j )( ( 4 * i ) + k ) .DataValid
-- ELSE strip9x3PipeIn( 7 )( OPP_ETA( j ) )( ( 4 * i ) + k ) .Energy WHEN NOT strip9x3PipeIn( 10 )( j )( ( 4 * i ) + k ) .DataValid
-- ELSE strip9x3PipeIn( 9 )( OPP_ETA( j ) )( ( 4 * i ) + k ) .Energy WHEN NOT strip9x3PipeIn( 11 )( j )( ( 4 * i ) + k ) .DataValid
-- ELSE strip9x3PipeIn( 11 )( OPP_ETA( j ) )( ( 4 * i ) + k ) .Energy WHEN NOT strip9x3PipeIn( 12 )( j )( ( 4 * i ) + k ) .DataValid
-- ELSE strip9x3PipeIn( 12 )( j )( ( 4 * i ) + k ) .Energy;

        PileupEstimateInput( k )( j )( i )( 1 ) <= UNSIGNED( ram_out( j )( ( 4 * i ) + k ) );

-- 3 in phi by 9 in eta
        PileupEstimateInput( k )( j )( i )( 2 ) <= ( OTHERS => '0' ) WHEN( cIncludeNullState AND NOT strip3x9PipeIn( 0 )( j )( ( 4 * i ) + k ) .DataValid ) -- [for frame 0 , an invalid object]
                                        ELSE strip3x9PipeIn( 0 )( j )( MOD_PHI( ( 4 * i ) + k - 6 ) ) .Energy;

        PileupEstimateInput( k )( j )( i )( 3 ) <= ( OTHERS => '0' ) WHEN( cIncludeNullState AND NOT strip3x9PipeIn( 0 )( j )( ( 4 * i ) + k ) .DataValid ) -- [for frame 0 , an invalid object]
                                        ELSE strip3x9PipeIn( 0 )( j )( MOD_PHI( ( 4 * i ) + k + 6 ) ) .Energy;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      END GENERATE site;

      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN
             IF( NOT jetVetoPipeIn( vetoOffset )( j )( ( 4 * i ) + 0 ) .Data ) THEN
            PileupEstimateInput2( j )( i ) <= PileupEstimateInput( 0 )( j )( i );
          ELSIF( NOT jetVetoPipeIn( vetoOffset )( j )( ( 4 * i ) + 1 ) .Data ) THEN
            PileupEstimateInput2( j )( i ) <= PileupEstimateInput( 1 )( j )( i );
          ELSIF( NOT jetVetoPipeIn( vetoOffset )( j )( ( 4 * i ) + 2 ) .Data ) THEN
            PileupEstimateInput2( j )( i ) <= PileupEstimateInput( 2 )( j )( i );
          ELSIF( NOT jetVetoPipeIn( vetoOffset )( j )( ( 4 * i ) + 3 ) .Data ) THEN
            PileupEstimateInput2( j )( i ) <= PileupEstimateInput( 3 )( j )( i );
          ELSE
            PileupEstimateInput2( j )( i ) <= ( OTHERS => ( OTHERS => '0' ) );
          END IF;
        END IF;
      END PROCESS;


      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN

          IF PileupEstimateInput2( j )( i )( 0 ) > PileupEstimateInput2( j )( i )( 1 ) THEN
            PileupEstimateInput3( j )( i )( 0 ) <= PileupEstimateInput2( j )( i )( 0 );
            PileupEstimateInput3( j )( i )( 1 ) <= PileupEstimateInput2( j )( i )( 1 );
          ELSE
            PileupEstimateInput3( j )( i )( 0 ) <= PileupEstimateInput2( j )( i )( 1 );
            PileupEstimateInput3( j )( i )( 1 ) <= PileupEstimateInput2( j )( i )( 0 );
          END IF;

          IF PileupEstimateInput2( j )( i )( 2 ) > PileupEstimateInput2( j )( i )( 3 ) THEN
            PileupEstimateInput3( j )( i )( 2 ) <= PileupEstimateInput2( j )( i )( 2 );
            PileupEstimateInput3( j )( i )( 3 ) <= PileupEstimateInput2( j )( i )( 3 );
          ELSE
            PileupEstimateInput3( j )( i )( 2 ) <= PileupEstimateInput2( j )( i )( 3 );
            PileupEstimateInput3( j )( i )( 3 ) <= PileupEstimateInput2( j )( i )( 2 );
          END IF;


          IF PileupEstimateInput3( j )( i )( 0 ) > PileupEstimateInput3( j )( i )( 2 ) THEN
            PileupEstimateInput4( j )( i )( 0 ) <= PileupEstimateInput3( j )( i )( 0 );
            PileupEstimateInput4( j )( i )( 1 ) <= PileupEstimateInput3( j )( i )( 2 );
          ELSE
            PileupEstimateInput4( j )( i )( 0 ) <= PileupEstimateInput3( j )( i )( 2 );
            PileupEstimateInput4( j )( i )( 1 ) <= PileupEstimateInput3( j )( i )( 0 );
          END IF;

          PileupEstimateInput4( j )( i )( 2 ) <= PileupEstimateInput3( j )( i )( 1 );
          PileupEstimateInput4( j )( i )( 3 ) <= PileupEstimateInput3( j )( i )( 3 );
        END IF;
      END PROCESS;

      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN
          IF jetVetoPipeIn( vetoOffset + 3 )( j )( ( 4 * i ) + 0 ) .DataValid THEN
            PileupEstimate( j )( i ) .Energy <= PileupEstimateInput4( j )( i )( 1 ) +
                                               PileupEstimateInput4( j )( i )( 2 ) +
                                               PileupEstimateInput4( j )( i )( 3 );
            PileupEstimate( j )( i ) .DataValid <= TRUE;
          ELSE
            PileupEstimate( j )( i ) <= cEmptyJet;
          END IF;
        END IF;
      END PROCESS;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    END GENERATE eta;
  END GENERATE phi;

  PileUpEstimatePipeInstance : ENTITY work.JetPipe
  PORT MAP(
    clk     => clk ,
    jetIn   => PileupEstimate ,
    jetPipe => pileUpPipeOut
  );

END ARCHITECTURE behavioral;
