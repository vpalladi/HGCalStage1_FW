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

--! @brief An entity providing a Sum3x3Former
--! @details Detailed description
ENTITY Sum3x3Former IS
  GENERIC(
    offset : INTEGER := 0
  );
  PORT(
    clk           : IN STD_LOGIC := '0' ; --! The algorithm clock
    towerPipeIn   : IN tTowerPipe ;       --! A pipe of tTower objects bringing in the tower's
    sum3x3PipeOut : OUT tJetPipe          --! A pipe of tJet objects passing out the sum3x3's
  );
END Sum3x3Former;

--! @brief Architecture definition for entity Sum3x3Former
--! @details Detailed description
ARCHITECTURE behavioral OF Sum3x3Former IS

  SIGNAL sum3x1InEtaPhi                             : tJetInEtaPhi           := cEmptyJetInEtaPhi;
  SIGNAL sum3x1PipeInt                              : tJetPipe( 2 DOWNTO 0 ) := ( OTHERS => cEmptyJetInEtaPhi );

  SIGNAL sum3x3Input1 , sum3x3Input2 , sum3x3Input3 : tJetInEtaPhi           := cEmptyJetInEtaPhi;
  SIGNAL sum3x3InEtaPhi                             : tJetInEtaPhi           := cEmptyJetInEtaPhi;

BEGIN

  phi                : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    eta              : FOR j IN 0 TO cRegionInEta-1 GENERATE

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 3 in phi by 1 in eta
      Sum3x1Instance : ENTITY work.JetSum
      PORT MAP(
        clk    => clk ,
        jetIn1 => ToJet( towerPipeIn( offset )( j )( MOD_PHI( i - 1 ) ) ) , -- was 0
        jetIn2 => ToJet( towerPipeIn( offset )( j )( MOD_PHI( i + 0 ) ) ) , -- was 0
        jetIn3 => ToJet( towerPipeIn( offset )( j )( MOD_PHI( i + 1 ) ) ) , -- was 0
        jetOut => sum3x1InEtaPhi( j )( i )
      );

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    sum3x3Input1( j )( i ) <= cEmptyJet WHEN( cIncludeNullState AND NOT sum3x1PipeInt( 1 )( j )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE sum3x1PipeInt( 0 )( j )( i );

    sum3x3Input2( j )( i ) <= cEmptyJet WHEN( cIncludeNullState AND NOT sum3x1PipeInt( 1 )( j )( i ) .DataValid ) -- [for frame 0 , an invalid object]
                          ELSE sum3x1PipeInt( 1 )( j )( i );

    sum3x3Input3( j )( i ) <= --cEmptyJet WHEN( cIncludeNullState AND NOT sum3x1PipeInt( 1 )( j )( i ) .DataValid ) ELSE -- [for frame 0 , an invalid object]
                          sum3x1PipeInt( 1 )( OPP_ETA( j ) )( i ) WHEN NOT sum3x1PipeInt( 2 )( j )( i ) .DataValid
                          ELSE sum3x1PipeInt( 2 )( j )( i );

    Sum3x3Instance : ENTITY work.JetSum
    PORT MAP(
      clk    => clk ,
      jetIn1 => sum3x3Input3( j )( i ) ,
      jetIn2 => sum3x3Input2( j )( i ) ,
      jetIn3 => sum3x3Input1( j )( i ) ,
      jetOut => sum3x3InEtaPhi( j )( i )
    );

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    END GENERATE eta;
  END GENERATE phi;

  sum3x1PipeInstance : ENTITY work.JetPipe
  PORT MAP(
    clk     => clk ,
    jetIn   => sum3x1InEtaPhi ,
    jetPipe => sum3x1PipeInt
  );

  Sum3x3PipeInstance : ENTITY work.JetPipe
  PORT MAP(
    clk     => clk ,
    jetIn   => sum3x3InEtaPhi ,
    jetPipe => sum3x3PipeOut
  );

END ARCHITECTURE behavioral;
