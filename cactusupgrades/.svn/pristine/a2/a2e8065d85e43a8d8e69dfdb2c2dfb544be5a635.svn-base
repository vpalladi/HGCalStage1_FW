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

--! @brief An entity providing a MaximaFinder9x9
--! @details Detailed description
ENTITY MaximaFinder9x9 IS
  GENERIC(
    Offset : INTEGER := 0
  );
  PORT(
    clk                  : IN STD_LOGIC := '0' ; --! The algorithm clock
    Maxima9x3PipeIn      : IN tMaximaPipe ;      --! A pipe of tMaxima objects bringing in the Maxima9x3's
    MaximaFlag9x9PipeOut : OUT tComparisonPipe   --! A pipe of tComparison objects passing out the MaximaFlag9x9's
  );
END MaximaFinder9x9;

--! @brief Architecture definition for entity MaximaFinder9x9
--! @details Detailed description
ARCHITECTURE behavioral OF MaximaFinder9x9 IS

-- ------------------------------------------------------------------------------
-- inputs
  SIGNAL maxima9x9Input1 , maxima9x9Input2 , maxima9x9Input3 : tMaximaInEtaPhi     := cEmptyMaximaInEtaPhi;

-- comparisons for convenience
  SIGNAL Comp9x9DataValidInEtaPhi                            : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;
  SIGNAL Comp9x9CentreEtaInEtaPhi                            : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;
  SIGNAL Comp9x9CentrePhiInEtaPhi                            : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;
  SIGNAL Comp9x9_1Gt2_InEtaPhi                               : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;
  SIGNAL Comp9x9_1Eq2_InEtaPhi                               : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;
  SIGNAL Comp9x9_3Gt2_InEtaPhi                               : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;
  SIGNAL Comp9x9_3Eq2_InEtaPhi                               : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;
  SIGNAL Comp9x9_1EtaPhiPosInEtaPhi                          : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;
  SIGNAL Comp9x9_3EtaPhiPosInEtaPhi                          : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;

-- 9x9 maxima flag which will be output
  SIGNAL maximaflag9x9InEtaPhi                               : tComparisonInEtaPhi := cEmptyComparisonInEtaPhi;
-- ------------------------------------------------------------------------------


-- -- ------------------------------------------------------------------------------

BEGIN


  inputs_phi : FOR i IN 0 TO cTowerInPhi-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    maxima9x9Input1( 0 )( i ) <= cEmptyMaxima WHEN( cIncludeNullState AND NOT maxima9x3PipeIn( Offset + 3 )( 0 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE maxima9x3PipeIn( Offset + 1 )( 1 )( i ) WHEN NOT maxima9x3PipeIn( Offset + 4 )( 0 )( i ) .DataValid -- most negative( in eta + view )
                          ELSE maxima9x3PipeIn( Offset + 3 )( 1 )( i ) WHEN NOT maxima9x3PipeIn( Offset + 5 )( 0 )( i ) .DataValid
                          ELSE maxima9x3PipeIn( Offset + 5 )( 1 )( i ) WHEN NOT maxima9x3PipeIn( Offset + 6 )( 0 )( i ) .DataValid
                          ELSE maxima9x3PipeIn( Offset + 6 )( 0 )( i );

    maxima9x9Input2( 0 )( i ) <= cEmptyMaxima WHEN( cIncludeNullState AND NOT maxima9x3PipeIn( Offset + 3 )( 0 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE maxima9x3PipeIn( Offset + 3 )( 0 )( i ) ; -- central

    maxima9x9Input3( 0 )( i ) <= cEmptyMaxima WHEN( cIncludeNullState AND NOT maxima9x3PipeIn( Offset + 3 )( 0 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE maxima9x3PipeIn( Offset + 0 )( 0 )( i ) ; -- most positive( in eta + view )

    maxima9x9Input1( 1 )( i ) <= cEmptyMaxima WHEN( cIncludeNullState AND NOT maxima9x3PipeIn( Offset + 3 )( 1 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE maxima9x3PipeIn( Offset + 0 )( 1 )( i ) ; -- most positive( in eta - view ) = most negative( in eta + view )

    maxima9x9Input2( 1 )( i ) <= cEmptyMaxima WHEN( cIncludeNullState AND NOT maxima9x3PipeIn( Offset + 3 )( 1 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE maxima9x3PipeIn( Offset + 3 )( 1 )( i ) ; -- central

    maxima9x9Input3( 1 )( i ) <= cEmptyMaxima WHEN( cIncludeNullState AND NOT maxima9x3PipeIn( Offset + 3 )( 1 )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE maxima9x3PipeIn( Offset + 1 )( 0 )( i ) WHEN NOT maxima9x3PipeIn( Offset + 4 )( 1 )( i ) .DataValid -- most negative( in eta - view ) = most positive( in eta + view )
                          ELSE maxima9x3PipeIn( Offset + 3 )( 0 )( i ) WHEN NOT maxima9x3PipeIn( Offset + 5 )( 1 )( i ) .DataValid
                          ELSE maxima9x3PipeIn( Offset + 5 )( 0 )( i ) WHEN NOT maxima9x3PipeIn( Offset + 6 )( 1 )( i ) .DataValid
                          ELSE maxima9x3PipeIn( Offset + 6 )( 1 )( i );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  END GENERATE inputs_phi;

  phi   : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      PROCESS( clk )
      BEGIN

        IF( RISING_EDGE( clk ) ) THEN

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          Comp9x9DataValidInEtaPhi( j )( i ) .Data   <= ( NOT maxima9x9Input2( j )( i ) .DataValid );
          Comp9x9CentreEtaInEtaPhi( j )( i ) .Data   <= ( maxima9x9Input2( j )( i ) .Eta /= 1 );
          Comp9x9CentrePhiInEtaPhi( j )( i ) .Data   <= ( maxima9x9Input2( j )( i ) .Phi /= 4 );
          Comp9x9_1Gt2_InEtaPhi( j )( i ) .Data      <= ( maxima9x9Input1( j )( i ) .Max > maxima9x9Input2( j )( i ) .Max );
          Comp9x9_1Eq2_InEtaPhi( j )( i ) .Data      <= ( maxima9x9Input1( j )( i ) .Max = maxima9x9Input2( j )( i ) .Max );
          Comp9x9_3Gt2_InEtaPhi( j )( i ) .Data      <= ( maxima9x9Input3( j )( i ) .Max > maxima9x9Input2( j )( i ) .Max );
          Comp9x9_3Eq2_InEtaPhi( j )( i ) .Data      <= ( maxima9x9Input3( j )( i ) .Max = maxima9x9Input2( j )( i ) .Max );
          Comp9x9_1EtaPhiPosInEtaPhi( j )( i ) .Data <= ( maxima9x9Input1( j )( i ) .Eta + maxima9x9Input1( j )( i ) .Phi > 8 );
          Comp9x9_3EtaPhiPosInEtaPhi( j )( i ) .Data <= ( maxima9x9Input3( j )( i ) .Eta + maxima9x9Input3( j )( i ) .Phi >= 2 );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- When getting rid of the JetCentreOffset constant , the choice was to
-- swap the inputs from + 3 , + 6 to -3 , + 3 and change the logic accordingly <<< OR >>> just add the phi offset here.
-- I chose the latter
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
          IF Comp9x9DataValidInEtaPhi( j )( i ) .Data THEN
            maximaflag9x9InEtaPhi( j )( MOD_PHI( i + 4 ) ) <= cEmptyComparison;
          ELSE
-- Final comparison for the 9x9 region
            IF( Comp9x9CentreEtaInEtaPhi( j )( i ) .Data OR Comp9x9CentrePhiInEtaPhi( j )( i ) .Data )
            OR Comp9x9_1Gt2_InEtaPhi( j )( i ) .Data
            OR Comp9x9_3Gt2_InEtaPhi( j )( i ) .Data
            OR( Comp9x9_1Eq2_InEtaPhi( j )( i ) .Data AND Comp9x9_1EtaPhiPosInEtaPhi( j )( i ) .Data )
            OR( Comp9x9_3Eq2_InEtaPhi( j )( i ) .Data AND Comp9x9_3EtaPhiPosInEtaPhi( j )( i ) .Data ) THEN
              maximaflag9x9InEtaPhi( j )( MOD_PHI( i + 4 ) ) .Data <= TRUE;
            ELSE
              maximaflag9x9InEtaPhi( j )( MOD_PHI( i + 4 ) ) .Data <= FALSE;
            END IF;

            maximaflag9x9InEtaPhi( j )( MOD_PHI( i + 4 ) ) .DataValid <= TRUE;
-- End of final comparison for the 9x9 region
          END IF;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        END IF;
      END PROCESS;
    END GENERATE eta;
  END GENERATE phi;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  MaximaFlag9x9PipeInstance : ENTITY work.ComparisonPipe
  PORT MAP(
    clk            => clk ,
    ComparisonIn   => maximaflag9x9InEtaPhi ,
    ComparisonPipe => MaximaFlag9x9PipeOut
  );
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

END ARCHITECTURE behavioral;
