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

--! @brief An entity providing a StripFormer
--! @details Detailed description
ENTITY StripFormer IS
  GENERIC(
    sum3x9Offset : INTEGER := 0;
    sum9x3Offset : INTEGER := 0
  );
  PORT(
    clk           : IN STD_LOGIC := '0' ; --! The algorithm clock
    sum3x3PipeIn  : IN tJetPipe ;         --! A pipe of tJet objects bringing in the sum3x3's
    sum9x3PipeOut : OUT tJetPipe ;        --! A pipe of tJet objects passing out the sum9x3's
    sum3x9PipeOut : OUT tJetPipe          --! A pipe of tJet objects passing out the sum3x9's
  );
END StripFormer;

--! @brief Architecture definition for entity StripFormer
--! @details Detailed description
ARCHITECTURE behavioral OF StripFormer IS

  SIGNAL sum9x3InEtaPhi                             : tJetInEtaPhi := cEmptyJetInEtaPhi;
  SIGNAL sum3x9Input1 , sum3x9Input2 , sum3x9Input3 : tJetInEtaPhi := cEmptyJetInEtaPhi;
  SIGNAL sum3x9InEtaPhi                             : tJetInEtaPhi := cEmptyJetInEtaPhi;


BEGIN

  phi                  : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    eta                : FOR j IN 0 TO cRegionInEta-1 GENERATE

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 9 in phi by 3 in eta

      Strip9x3Instance : ENTITY work.JetSum
      PORT MAP(
        clk    => clk ,
        jetIn1 => sum3x3PipeIn( sum9x3Offset )( j )( MOD_PHI( i - 3 ) ) , -- + 1
        jetIn2 => sum3x3PipeIn( sum9x3Offset )( j )( MOD_PHI( i + 0 ) ) , -- + 1
        jetIn3 => sum3x3PipeIn( sum9x3Offset )( j )( MOD_PHI( i + 3 ) ) , -- + 1
        jetOut => sum9x3InEtaPhi( j )( i )
      );

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3 in phi by 9 in eta
      sum3x9Input1( j )( i ) <= cEmptyJet WHEN( cIncludeNullState AND NOT sum3x3PipeIn( sum3x9Offset + 3 )( j )( i ) .DataValid ) -- [for frame 0 , an invalid object] -- + 1
                            ELSE sum3x3PipeIn( sum3x9Offset + 0 )( j )( i ) ; -- + 1

      sum3x9Input2( j )( i ) <= cEmptyJet WHEN( cIncludeNullState AND NOT sum3x3PipeIn( sum3x9Offset + 3 )( j )( i ) .DataValid ) -- [for frame 0 , an invalid object] -- + 1
                            ELSE sum3x3PipeIn( sum3x9Offset + 3 )( j )( i ) ; -- + 1

      sum3x9Input3( j )( i ) <= cEmptyJet WHEN( cIncludeNullState AND NOT sum3x3PipeIn( sum3x9Offset + 3 )( j )( i ) .DataValid ) -- [for frame 0 , an invalid object] -- + 1
                            ELSE sum3x3PipeIn( sum3x9Offset + 1 )( OPP_ETA( j ) )( i ) WHEN NOT sum3x3PipeIn( sum3x9Offset + 4 )( j )( i ) .DataValid -- + 1
                            ELSE sum3x3PipeIn( sum3x9Offset + 3 )( OPP_ETA( j ) )( i ) WHEN NOT sum3x3PipeIn( sum3x9Offset + 5 )( j )( i ) .DataValid -- + 1
                            ELSE sum3x3PipeIn( sum3x9Offset + 5 )( OPP_ETA( j ) )( i ) WHEN NOT sum3x3PipeIn( sum3x9Offset + 6 )( j )( i ) .DataValid -- + 1
                            ELSE sum3x3PipeIn( sum3x9Offset + 6 )( j )( i ) ; -- + 1

      Strip3x9Instance : ENTITY work.JetSum
      PORT MAP(
        clk    => clk ,
        jetIn1 => sum3x9Input3( j )( i ) ,
        jetIn2 => sum3x9Input2( j )( i ) ,
        jetIn3 => sum3x9Input1( j )( i ) ,
        jetOut => sum3x9InEtaPhi( j )( i )
      );

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    END GENERATE eta;
  END GENERATE phi;

  Strip9x3PipeInstance : ENTITY work.JetPipe
  PORT MAP(
    clk     => clk ,
    jetIn   => sum9x3InEtaPhi ,
    jetPipe => sum9x3PipeOut
  );

  Strip3x9PipeInstance : ENTITY work.JetPipe
  PORT MAP(
    clk     => clk ,
    jetIn   => sum3x9InEtaPhi ,
    jetPipe => sum3x9PipeOut
  );

END ARCHITECTURE behavioral;
