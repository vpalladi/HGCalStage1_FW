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

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! @brief An entity providing a MaximaFinder3x3
--! @details Detailed description
ENTITY MaximaFinder3x3 IS
  GENERIC(
    Offset : INTEGER := 0
  );
  PORT(
    clk                  : IN STD_LOGIC := '0' ; --! The algorithm clock
    towerPipeIn          : IN tTowerPipe ;       --! A pipe of tTower objects bringing in the tower's
    maxima3x3PipeOut     : OUT tMaximaPipe ;     --! A pipe of tMaxima objects passing out the maxima3x3's
    MaximaFlag3x3PipeOut : OUT tComparisonPipe   --! A pipe of tComparison objects passing out the MaximaFlag3x3's
  );
END MaximaFinder3x3;

--! @brief Architecture definition for entity MaximaFinder3x3
--! @details Detailed description
ARCHITECTURE behavioral OF MaximaFinder3x3 IS

  TYPE tSelectionInPhi    IS ARRAY( 0 TO cTowerInPhi-1 ) OF INTEGER RANGE 0 TO 2 ; -- cTowerInPhi wide
  TYPE tSelectionInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tSelectionInPhi ; -- Two halves in eta

-- ------------------------------------------------------------------------------
-- comparisons for convenience
  SIGNAL comparisonPhiPlus1InEtaPhi , comparisonPhiPlus2InEtaPhi         : tComparisonInEtaPhi;
-- 3x1 maxima and pipe
  SIGNAL maxima3x1InEtaPhi                                               : tMaximaInEtaPhi           := cEmptyMaximaInEtaPhi;
  SIGNAL maxima3x1PipeInt                                                : tMaximaPipe( 2 DOWNTO 0 ) := ( OTHERS => cEmptyMaximaInEtaPhi );
-- ------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------
-- inputs and input pipe
  SIGNAL maxima3x3Input1 , maxima3x3Input2 , maxima3x3Input3             : tMaximaInEtaPhi           := cEmptyMaximaInEtaPhi;
  SIGNAL maxima3x3Input1Pipe , maxima3x3Input2Pipe , maxima3x3Input3Pipe : tMaximaPipe( 7 DOWNTO 0 ) := ( OTHERS => cEmptyMaximaInEtaPhi );

-- comparisons for convenience
  SIGNAL CltAInEtaPhi , BltAInEtaPhi , CltBInEtaPhi                      : tComparisonInEtaPhi       := cEmptyComparisonInEtaPhi;
  SIGNAL CeqAInEtaPhi , BeqAInEtaPhi , CeqBInEtaPhi                      : tComparisonInEtaPhi       := cEmptyComparisonInEtaPhi;
  SIGNAL CAphiInEtaPhi , BAphiInEtaPhi , CBphiInEtaPhi                   : tComparisonInEtaPhi       := cEmptyComparisonInEtaPhi;

-- mux control signal
  SIGNAL selection3x3                                                    : tSelectionInEtaPhi;

-- 3x3 maxima and pipe
  SIGNAL maxima3x3InEtaPhi                                               : tMaximaInEtaPhi     := cEmptyMaximaInEtaPhi;

-- 3x3 maxima flag which will be output
  SIGNAL maximaflag3x3InEtaPhi                                           : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;
-- ------------------------------------------------------------------------------


-- -- ------------------------------------------------------------------------------

BEGIN

  phi   : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      PROCESS( clk )
      BEGIN

        IF( RISING_EDGE( clk ) ) THEN

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Perform the comparisons for the 3x1 region
-- We are using this as a tool of convenience , DataValid handled by the select function
            comparisonPhiPlus1InEtaPhi( j )( i ) .Data <= ( UNSIGNED( towerPipeIn( 0 )( j )( i ) .Energy ) > UNSIGNED( towerPipeIn( 0 )( j )( MOD_PHI( i + 1 ) ) .Energy ) );
            comparisonPhiPlus2InEtaPhi( j )( i ) .Data <= ( UNSIGNED( towerPipeIn( 0 )( j )( i ) .Energy ) > UNSIGNED( towerPipeIn( 0 )( j )( MOD_PHI( i + 2 ) ) .Energy ) );
-- End of the comparisons for the 3x1 region
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          IF( NOT towerPipeIn( 1 )( j )( MOD_PHI( i + 0 ) ) .DataValid
           OR NOT towerPipeIn( 1 )( j )( MOD_PHI( i + 1 ) ) .DataValid
           OR NOT towerPipeIn( 1 )( j )( MOD_PHI( i + 2 ) ) .DataValid ) THEN
            maxima3x1InEtaPhi( j )( i ) <= cEmptyMaxima;
          ELSE
-- Select the maxima for the 3x1 region
            IF( comparisonPhiPlus2InEtaPhi( j )( i ) .Data AND comparisonPhiPlus1InEtaPhi( j )( i ) .Data ) THEN
-- Sel = 0
              maxima3x1InEtaPhi( j )( i ) .Eta <= 0;
              maxima3x1InEtaPhi( j )( i ) .Phi <= 0;
              maxima3x1InEtaPhi( j )( i ) .Max <= UNSIGNED( towerPipeIn( 1 )( j )( MOD_PHI( i + 0 ) ) .Energy );
            ELSIF( ( comparisonPhiPlus1InEtaPhi( j )( MOD_PHI( i + 1 ) ) .Data ) AND NOT( comparisonPhiPlus1InEtaPhi( j )( i ) .Data ) ) THEN
-- Sel = 1
              maxima3x1InEtaPhi( j )( i ) .Eta <= 0;
              maxima3x1InEtaPhi( j )( i ) .Phi <= 1;
              maxima3x1InEtaPhi( j )( i ) .Max <= UNSIGNED( towerPipeIn( 1 )( j )( MOD_PHI( i + 1 ) ) .Energy );
            ELSE
-- Sel = 2
              maxima3x1InEtaPhi( j )( i ) .Eta <= 0;
              maxima3x1InEtaPhi( j )( i ) .Phi <= 2;
              maxima3x1InEtaPhi( j )( i ) .Max <= UNSIGNED( towerPipeIn( 1 )( j )( MOD_PHI( i + 2 ) ) .Energy );
            END IF;
            maxima3x1InEtaPhi( j )( i ) .DataValid <= TRUE;
-- End of select the maxima for the 3x1 region
          END IF;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Perform the comparisons for the 3x3 region
-- We are using this as a tool of convenience , DataValid handled by the select function
            CltAInEtaPhi( j )( i ) .Data  <= ( maxima3x3Input3( j )( i ) .Max < maxima3x3Input1( j )( i ) .Max );
            BltAInEtaPhi( j )( i ) .Data  <= ( maxima3x3Input2( j )( i ) .Max < maxima3x3Input1( j )( i ) .Max );
            CltBInEtaPhi( j )( i ) .Data  <= ( maxima3x3Input3( j )( i ) .Max < maxima3x3Input2( j )( i ) .Max );
            CeqAInEtaPhi( j )( i ) .Data  <= ( maxima3x3Input3( j )( i ) .Max = maxima3x3Input1( j )( i ) .Max );
            BeqAInEtaPhi( j )( i ) .Data  <= ( maxima3x3Input2( j )( i ) .Max = maxima3x3Input1( j )( i ) .Max );
            CeqBInEtaPhi( j )( i ) .Data  <= ( maxima3x3Input3( j )( i ) .Max = maxima3x3Input2( j )( i ) .Max );
            CAphiInEtaPhi( j )( i ) .Data <= ( ( maxima3x3Input1( j )( i ) .Phi + 0 ) > ( maxima3x3Input3( j )( i ) .Phi + 2 ) ) ; -- Can obviously be optimized...
            BAphiInEtaPhi( j )( i ) .Data <= ( ( maxima3x3Input1( j )( i ) .Phi + 0 ) > ( maxima3x3Input2( j )( i ) .Phi + 1 ) ) ; -- Can obviously be optimized...
            CBphiInEtaPhi( j )( i ) .Data <= ( ( maxima3x3Input2( j )( i ) .Phi + 1 ) > ( maxima3x3Input3( j )( i ) .Phi + 2 ) ) ; -- Can obviously be optimized...
-- End of the comparisons for the 3x3 region
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- IF( NOT maxima3x3Input1Pipe( 1 )( j )( i ) .DataValid OR NOT maxima3x3Input2Pipe( 1 )( j )( i ) .DataValid OR NOT maxima3x3Input3Pipe( 1 )( j )( i ) .DataValid ) THEN
-- comparison9x9InEtaPhi( j )( i ) <= cEmptyComparison;
-- ELSE
-- Select the maxima for the 3x3 region
-- Use the VARIABLE "selection3x3" to make it easier to read...
          IF( CltAInEtaPhi( j )( i ) .Data AND BltAInEtaPhi( j )( i ) .Data ) THEN
            selection3x3( j )( i ) <= 0;
          ELSIF( NOT( BltAInEtaPhi( j )( i ) .Data OR BeqAInEtaPhi( j )( i ) .Data ) AND CltBInEtaPhi( j )( i ) .Data ) THEN
            selection3x3( j )( i ) <= 1;
          ELSIF( NOT( CltBInEtaPhi( j )( i ) .Data OR CeqBInEtaPhi( j )( i ) .Data ) AND NOT( CltAInEtaPhi( j )( i ) .Data OR CeqAInEtaPhi( j )( i ) .Data ) ) THEN
            selection3x3( j )( i ) <= 2;
          ELSIF( CltAInEtaPhi( j )( i ) .Data AND BeqAInEtaPhi( j )( i ) .Data ) THEN
            IF( BAphiInEtaPhi( j )( i ) .Data ) THEN
              selection3x3( j )( i ) <= 0;
            ELSE
              selection3x3( j )( i ) <= 1;
            END IF;
          ELSIF( NOT( BltAInEtaPhi( j )( i ) .Data OR BeqAInEtaPhi( j )( i ) .Data ) AND CeqBInEtaPhi( j )( i ) .Data ) THEN
            IF( CBphiInEtaPhi( j )( i ) .Data ) THEN
              selection3x3( j )( i ) <= 1;
            ELSE
              selection3x3( j )( i ) <= 2;
            END IF;
          ELSIF( NOT( CltBInEtaPhi( j )( i ) .Data OR CeqBInEtaPhi( j )( i ) .Data ) AND CeqAInEtaPhi( j )( i ) .Data ) THEN
            IF( CAphiInEtaPhi( j )( i ) .Data ) THEN
              selection3x3( j )( i ) <= 0;
            ELSE
              selection3x3( j )( i ) <= 2;
            END IF;
          ELSE
            IF( BAphiInEtaPhi( j )( i ) .Data AND CAphiInEtaPhi( j )( i ) .Data ) THEN
              selection3x3( j )( i ) <= 0;
            ELSIF( CBphiInEtaPhi( j )( i ) .Data ) THEN
              selection3x3( j )( i ) <= 1;
            ELSE
              selection3x3( j )( i ) <= 2;
            END IF;
          END IF;
-- End of select the maxima for the 3x3 region
-- END IF;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--IF( NOT maxima3x3Input2Pipe( 2 )( j )( i ) .DataValid ) THEN
-- maxima3x3InEtaPhi( j )( i ) <= cEmptyMaxima;
--ELSE
            IF( selection3x3( j )( i ) = 0 ) THEN
              maxima3x3InEtaPhi( j )( i ) .Max <= maxima3x3Input1Pipe( 2 )( j )( i ) .Max;
              maxima3x3InEtaPhi( j )( i ) .Phi <= maxima3x3Input1Pipe( 2 )( j )( i ) .Phi;
              maxima3x3InEtaPhi( j )( i ) .Eta <= 0;
            ELSIF( selection3x3( j )( i ) = 1 ) THEN
              maxima3x3InEtaPhi( j )( i ) .Max <= maxima3x3Input2Pipe( 2 )( j )( i ) .Max;
              maxima3x3InEtaPhi( j )( i ) .Phi <= maxima3x3Input2Pipe( 2 )( j )( i ) .Phi;
              maxima3x3InEtaPhi( j )( i ) .Eta <= 1;
            ELSE
              maxima3x3InEtaPhi( j )( i ) .Max <= maxima3x3Input3Pipe( 2 )( j )( i ) .Max;
              maxima3x3InEtaPhi( j )( i ) .Phi <= maxima3x3Input3Pipe( 2 )( j )( i ) .Phi;
              maxima3x3InEtaPhi( j )( i ) .Eta <= 2;
            END IF;
            maxima3x3InEtaPhi( j )( i ) .DataValid <= maxima3x3Input2Pipe( 2 )( j )( i ) .DataValid ; --TRUE;
--END IF;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- When getting rid of the JetCentreOffset constant , the choice was to
-- swap the inputs from + 1 , + 2 to -1 , + 1 and change the logic accordingly <<< OR >>> just add the phi offset here.
-- I chose the latter
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          IF( NOT maxima3x3InEtaPhi( j )( i ) .DataValid ) THEN
            maximaflag3x3InEtaPhi( j )( MOD_PHI( i + 1 ) ) <= cEmptyComparison;
          ELSE
-- Final comparison for the 3x3 region
            maximaflag3x3InEtaPhi( j )( MOD_PHI( i + 1 ) ) .Data      <= ( ( maxima3x3InEtaPhi( j )( i ) .Eta /= 1 ) OR( maxima3x3InEtaPhi( j )( i ) .Phi /= 1 ) );
            maximaflag3x3InEtaPhi( j )( MOD_PHI( i + 1 ) ) .DataValid <= TRUE;
-- End of final comparison for the 3x3 region
          END IF;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        END IF;
      END PROCESS;
    END GENERATE eta;
  END GENERATE phi;


  inputs_phi : FOR i IN 0 TO cTowerInPhi-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Inputs for 3x3
    maxima3x3Input1( 0 )( i ) <= -- cEmptyMaxima WHEN( cIncludeNullState AND NOT maxima3x1PipeInt( Offset + 1 )( 0 )( i ) .DataValid ) ELSE -- [for frame 0 , an invalid object]
                            maxima3x1PipeInt( Offset + 1 )( OPP_ETA( 0 ) )( i ) WHEN NOT maxima3x1PipeInt( Offset + 2 )( 0 )( i ) .DataValid -- most negative( in eta + view )
                            ELSE maxima3x1PipeInt( Offset + 2 )( 0 )( i );

    maxima3x3Input2( 0 )( i ) <= cEmptyMaxima WHEN( cIncludeNullState AND NOT maxima3x1PipeInt( Offset + 1 )( 0 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                            ELSE maxima3x1PipeInt( Offset + 1 )( 0 )( i ) ; -- central

    maxima3x3Input3( 0 )( i ) <= cEmptyMaxima WHEN( cIncludeNullState AND NOT maxima3x1PipeInt( Offset + 1 )( 0 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                            ELSE maxima3x1PipeInt( Offset + 0 )( 0 )( i ) ; -- most positive( in eta + view )

    maxima3x3Input1( 1 )( i ) <= cEmptyMaxima WHEN( cIncludeNullState AND NOT maxima3x1PipeInt( Offset + 1 )( 1 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                            ELSE maxima3x1PipeInt( Offset + 0 )( 1 )( i ) ; -- most positive( in eta - view ) = most negative( in eta + view )

    maxima3x3Input2( 1 )( i ) <= cEmptyMaxima WHEN( cIncludeNullState AND NOT maxima3x1PipeInt( Offset + 1 )( 1 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                            ELSE maxima3x1PipeInt( Offset + 1 )( 1 )( i ) ; -- central

    maxima3x3Input3( 1 )( i ) <= -- cEmptyMaxima WHEN( cIncludeNullState AND NOT maxima3x1PipeInt( Offset + 1 )( 1 )( i ) .DataValid ) ELSE -- [for frame 0 , an invalid object]
                            maxima3x1PipeInt( Offset + 1 )( OPP_ETA( 1 ) )( i ) WHEN NOT maxima3x1PipeInt( Offset + 2 )( 1 )( i ) .DataValid -- most negative( in eta - view ) = most positive( in eta + view )
                            ELSE maxima3x1PipeInt( Offset + 2 )( 1 )( i );
-- End of inputs for 3x3
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  END GENERATE inputs_phi;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  maxima3x1PipeInstance : ENTITY work.MaximaPipe
  PORT MAP(
    clk        => clk ,
    MaximaIn   => maxima3x1InEtaPhi ,
    MaximaPipe => maxima3x1PipeInt
  );

  maxima3x3PipeInstance : ENTITY work.MaximaPipe
  PORT MAP(
    clk        => clk ,
    MaximaIn   => maxima3x3InEtaPhi ,
    MaximaPipe => maxima3x3PipeOut
  );

  maxima3x3Input1PipeInstance : ENTITY work.MaximaPipe
  PORT MAP(
    clk        => clk ,
    MaximaIn   => maxima3x3Input1 ,
    MaximaPipe => maxima3x3Input1Pipe
  );

  maxima3x3Input2PipeInstance : ENTITY work.MaximaPipe
  PORT MAP(
    clk        => clk ,
    MaximaIn   => maxima3x3Input2 ,
    MaximaPipe => maxima3x3Input2Pipe
  );

  maxima3x3Input3PipeInstance : ENTITY work.MaximaPipe
  PORT MAP(
    clk        => clk ,
    MaximaIn   => maxima3x3Input3 ,
    MaximaPipe => maxima3x3Input3Pipe
  );

  MaximaFlag3x3PipeInstance : ENTITY work.ComparisonPipe
  PORT MAP(
    clk            => clk ,
    ComparisonIn   => maximaflag3x3InEtaPhi ,
    ComparisonPipe => MaximaFlag3x3PipeOut
  );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

END ARCHITECTURE behavioral;
