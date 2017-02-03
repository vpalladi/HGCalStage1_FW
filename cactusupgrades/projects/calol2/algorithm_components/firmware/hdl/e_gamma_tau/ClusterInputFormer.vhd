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

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "cluster" helper functions
USE work.cluster_functions.ALL;

--! @brief An entity providing a ClusterInputFormer
--! @details Detailed description
ENTITY ClusterInputFormer IS
  GENERIC(
    TowerPipeOffset  : INTEGER := 0 ; -- Offset for the Tower Pipe
    EgammaVetoOffset : INTEGER := 0 -- Offset for the E / gamma Veto Pipe
  );
  PORT(
    clk                 : IN STD_LOGIC := '0' ; --! The algorithm clock
    TowerPipeIn         : IN tTowerPipe ;       --! A pipe of tTower objects bringing in the Tower's
    egamma9x3vetoPipeIn : IN tComparisonPipe ;  --! A pipe of tComparison objects bringing in the egamma9x3veto's
    ClusterInputPipeOut : OUT tClusterInputPipe --! A pipe of tClusterInput objects passing out the ClusterInput's
  );
END ENTITY ClusterInputFormer;


--! @brief Architecture definition for entity ClusterInputFormer
--! @details Detailed description
ARCHITECTURE behavioral OF ClusterInputFormer IS

  TYPE tClusterInputPerSite IS ARRAY( 3 DOWNTO 0 ) OF tClusterInputInEtaPhi ; -- Two halves in eta

  SIGNAL ClusterInput , ClusterInputClk : tClusterInputPerSite  := ( OTHERS => cEmptyClusterInputInEtaPhi );
  SIGNAL ClusterInput2                  : tClusterInputInEtaPhi := cEmptyClusterInputInEtaPhi;

BEGIN

  phi    : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    site : FOR k IN 3 DOWNTO 0 GENERATE

      ClusterInput( k )( 0 )( i ) .Centre <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k + 0 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k + 0 ) );

      ClusterInput( k )( 0 )( i ) .R1N <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k + 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k + 1 ) );

      ClusterInput( k )( 0 )( i ) .R1NW <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k + 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( OPP_ETA( 0 ) )( MOD_PHI( ( 4 * i ) + k + 1 ) ) WHEN NOT TowerPipeIn( towerPipeOffset + 1 )( 0 )( MOD_PHI( ( 4 * i ) + k + 1 ) ) .DataValid
                                         ELSE TowerPipeIn( towerPipeOffset + 1 )( 0 )( MOD_PHI( ( 4 * i ) + k + 1 ) );

      ClusterInput( k )( 0 )( i ) .R1W <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k + 0 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( OPP_ETA( 0 ) )( MOD_PHI( ( 4 * i ) + k + 0 ) ) WHEN NOT TowerPipeIn( towerPipeOffset + 1 )( 0 )( MOD_PHI( ( 4 * i ) + k + 0 ) ) .DataValid
                                         ELSE TowerPipeIn( towerPipeOffset + 1 )( 0 )( MOD_PHI( ( 4 * i ) + k + 0 ) );

      ClusterInput( k )( 0 )( i ) .R1SW <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k - 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( OPP_ETA( 0 ) )( MOD_PHI( ( 4 * i ) + k - 1 ) ) WHEN NOT TowerPipeIn( towerPipeOffset + 1 )( 0 )( MOD_PHI( ( 4 * i ) + k - 1 ) ) .DataValid
                                         ELSE TowerPipeIn( towerPipeOffset + 1 )( 0 )( MOD_PHI( ( 4 * i ) + k - 1 ) );

      ClusterInput( k )( 0 )( i ) .R1S <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k - 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k - 1 ) );

      ClusterInput( k )( 0 )( i ) .R1SE <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k - 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset-1 )( 0 )( MOD_PHI( ( 4 * i ) + k - 1 ) );

      ClusterInput( k )( 0 )( i ) .R1E <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k + 0 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset-1 )( 0 )( MOD_PHI( ( 4 * i ) + k + 0 ) );

      ClusterInput( k )( 0 )( i ) .R1NE <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k + 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset-1 )( 0 )( MOD_PHI( ( 4 * i ) + k + 1 ) );


      ClusterInput( k )( 0 )( i ) .R2N <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k + 2 ) );

      ClusterInput( k )( 0 )( i ) .R2S <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k - 2 ) );



      ClusterInput( k )( 0 )( i ) .R2NW <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( OPP_ETA( 0 ) )( MOD_PHI( ( 4 * i ) + k + 2 ) ) WHEN NOT TowerPipeIn( towerPipeOffset + 1 )( 0 )( MOD_PHI( ( 4 * i ) + k + 2 ) ) .DataValid
                                         ELSE TowerPipeIn( towerPipeOffset + 1 )( 0 )( MOD_PHI( ( 4 * i ) + k + 2 ) );

      ClusterInput( k )( 0 )( i ) .R2NE <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset-1 )( 0 )( MOD_PHI( ( 4 * i ) + k + 2 ) );

      ClusterInput( k )( 0 )( i ) .R2SW <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( OPP_ETA( 0 ) )( MOD_PHI( ( 4 * i ) + k - 2 ) ) WHEN NOT TowerPipeIn( towerPipeOffset + 1 )( 0 )( MOD_PHI( ( 4 * i ) + k - 2 ) ) .DataValid
                                         ELSE TowerPipeIn( towerPipeOffset + 1 )( 0 )( MOD_PHI( ( 4 * i ) + k - 2 ) );

      ClusterInput( k )( 0 )( i ) .R2SE <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset-1 )( 0 )( MOD_PHI( ( 4 * i ) + k - 2 ) );




      ClusterInput( k )( 1 )( i ) .Centre <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k + 0 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k + 0 ) );

      ClusterInput( k )( 1 )( i ) .R1N <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k + 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k + 1 ) );

      ClusterInput( k )( 1 )( i ) .R1NE <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k + 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( OPP_ETA( 1 ) )( MOD_PHI( ( 4 * i ) + k + 1 ) ) WHEN NOT TowerPipeIn( towerPipeOffset + 1 )( 1 )( MOD_PHI( ( 4 * i ) + k + 1 ) ) .DataValid
                                         ELSE TowerPipeIn( towerPipeOffset + 1 )( 1 )( MOD_PHI( ( 4 * i ) + k + 1 ) );

      ClusterInput( k )( 1 )( i ) .R1E <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k + 0 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( OPP_ETA( 1 ) )( MOD_PHI( ( 4 * i ) + k + 0 ) ) WHEN NOT TowerPipeIn( towerPipeOffset + 1 )( 1 )( MOD_PHI( ( 4 * i ) + k + 0 ) ) .DataValid
                                         ELSE TowerPipeIn( towerPipeOffset + 1 )( 1 )( MOD_PHI( ( 4 * i ) + k + 0 ) );

      ClusterInput( k )( 1 )( i ) .R1SE <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k - 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( OPP_ETA( 1 ) )( MOD_PHI( ( 4 * i ) + k - 1 ) ) WHEN NOT TowerPipeIn( towerPipeOffset + 1 )( 1 )( MOD_PHI( ( 4 * i ) + k - 1 ) ) .DataValid
                                         ELSE TowerPipeIn( towerPipeOffset + 1 )( 1 )( MOD_PHI( ( 4 * i ) + k - 1 ) );

      ClusterInput( k )( 1 )( i ) .R1S <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k - 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k - 1 ) );

      ClusterInput( k )( 1 )( i ) .R1SW <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k - 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset-1 )( 1 )( MOD_PHI( ( 4 * i ) + k - 1 ) );

      ClusterInput( k )( 1 )( i ) .R1W <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k + 0 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset-1 )( 1 )( MOD_PHI( ( 4 * i ) + k + 0 ) );

      ClusterInput( k )( 1 )( i ) .R1NW <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k + 1 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset-1 )( 1 )( MOD_PHI( ( 4 * i ) + k + 1 ) );

      ClusterInput( k )( 1 )( i ) .R2N <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k + 2 ) );

      ClusterInput( k )( 1 )( i ) .R2S <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k - 2 ) );


      ClusterInput( k )( 1 )( i ) .R2NE <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( OPP_ETA( 1 ) )( MOD_PHI( ( 4 * i ) + k + 2 ) ) WHEN NOT TowerPipeIn( towerPipeOffset + 1 )( 1 )( MOD_PHI( ( 4 * i ) + k + 2 ) ) .DataValid
                                         ELSE TowerPipeIn( towerPipeOffset + 1 )( 1 )( MOD_PHI( ( 4 * i ) + k + 2 ) );

      ClusterInput( k )( 1 )( i ) .R2NW <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset-1 )( 1 )( MOD_PHI( ( 4 * i ) + k + 2 ) );

      ClusterInput( k )( 1 )( i ) .R2SE <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset )( OPP_ETA( 1 ) )( MOD_PHI( ( 4 * i ) + k - 2 ) ) WHEN NOT TowerPipeIn( towerPipeOffset + 1 )( 1 )( MOD_PHI( ( 4 * i ) + k - 2 ) ) .DataValid
                                         ELSE TowerPipeIn( towerPipeOffset + 1 )( 1 )( MOD_PHI( ( 4 * i ) + k - 2 ) );

      ClusterInput( k )( 1 )( i ) .R2SW <= cEmptyTower WHEN( cIncludeNullState AND NOT TowerPipeIn( towerPipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                         ELSE TowerPipeIn( towerPipeOffset-1 )( 1 )( MOD_PHI( ( 4 * i ) + k - 2 ) );

    END GENERATE site;
  END GENERATE phi;

  ClusterInputClk <= ClusterInput WHEN RISING_EDGE( clk );

  phi2   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta2 : FOR j IN 0 TO cRegionInEta-1 GENERATE
      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN

          IF( NOT ClusterInputClk( 0 )( j )( i ) .Centre.DataValid ) THEN -- OR NOT egamma9x3vetoPipeIn( EgammaVetoOffset )( j )( ( 4 * i ) + 0 ) .DataValid ) THEN -- + 1
            ClusterInput2( j )( i ) <= cEmptyClusterInput;
          ELSE
            IF( NOT egamma9x3vetoPipeIn( EgammaVetoOffset )( j )( ( 4 * i ) + 0 ) .Data ) THEN
              ClusterInput2( j )( i ) <= ClusterInputClk( 0 )( j )( i );
            ELSIF( NOT egamma9x3vetoPipeIn( EgammaVetoOffset )( j )( ( 4 * i ) + 1 ) .Data ) THEN
              ClusterInput2( j )( i ) <= ClusterInputClk( 1 )( j )( i );
            ELSIF( NOT egamma9x3vetoPipeIn( EgammaVetoOffset )( j )( ( 4 * i ) + 2 ) .Data ) THEN
              ClusterInput2( j )( i ) <= ClusterInputClk( 2 )( j )( i );
            ELSIF( NOT egamma9x3vetoPipeIn( EgammaVetoOffset )( j )( ( 4 * i ) + 3 ) .Data ) THEN
              ClusterInput2( j )( i ) <= ClusterInputClk( 3 )( j )( i );
            ELSE
              ClusterInput2( j )( i )                   <= cEmptyClusterInput;
              ClusterInput2( j )( i ) .Centre.DataValid <= TRUE;
              ClusterInput2( j )( i ) .R1NW.DataValid   <= TRUE;
              ClusterInput2( j )( i ) .R1N.DataValid    <= TRUE;
              ClusterInput2( j )( i ) .R1NE.DataValid   <= TRUE;
              ClusterInput2( j )( i ) .R1E.DataValid    <= TRUE;
              ClusterInput2( j )( i ) .R1SE.DataValid   <= TRUE;
              ClusterInput2( j )( i ) .R1S.DataValid    <= TRUE;
              ClusterInput2( j )( i ) .R1SW.DataValid   <= TRUE;
              ClusterInput2( j )( i ) .R1W.DataValid    <= TRUE;
              ClusterInput2( j )( i ) .R2N.DataValid    <= TRUE;
              ClusterInput2( j )( i ) .R2S.DataValid    <= TRUE;

              ClusterInput2( j )( i ) .R2NW.DataValid   <= TRUE;
              ClusterInput2( j )( i ) .R2NE.DataValid   <= TRUE;
              ClusterInput2( j )( i ) .R2SW.DataValid   <= TRUE;
              ClusterInput2( j )( i ) .R2SE.DataValid   <= TRUE;

            END IF;

          END IF;
        END IF;
      END PROCESS;
    END GENERATE eta2;
  END GENERATE phi2;

  ClusterInputPipeInstance : ENTITY work.ClusterInputPipe
  PORT MAP(
    clk              => clk ,
    ClusterInputIn   => ClusterInput2 ,
    ClusterInputPipe => ClusterInputPipeOut
  );

END ARCHITECTURE behavioral;
