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

--! @brief An entity providing a TauSecondaries
--! @details Detailed description
ENTITY TauSecondaries IS
  GENERIC(
    TauVetoOffset      : INTEGER := 0 ; -- Offset for the Tower Pipe
    ProtoClusterOffset : INTEGER := 0 -- Offset for the Tower Pipe
  );
  PORT(
    clk                   : IN STD_LOGIC := '0' ; --! The algorithm clock
    ProtoClusterPipeIn    : IN tClusterPipe ;     --! A pipe of tCluster objects bringing in the ProtoCluster's
    tauVetoPipeIn         : IN tComparisonPipe ;  --! A pipe of tComparison objects bringing in the tauVeto's
    TauSecondariesPipeOut : OUT tClusterPipe      --! A pipe of tCluster objects passing out the TauSecondaries's
  );
END ENTITY TauSecondaries;

--! @brief Architecture definition for entity TauSecondaries
--! @details Detailed description
ARCHITECTURE behavioral OF TauSecondaries IS

  TYPE tClusterSelectionInput IS ARRAY( 7 DOWNTO 0 ) OF tClusterInEtaPhi;
  SIGNAL ClusterSelectionInput : tClusterSelectionInput := ( OTHERS => cEmptyClusterInEtaPhi );

  TYPE tSelectionInput IS ARRAY( 7 DOWNTO 0 ) OF tComparisonInEtaPhi;
  SIGNAL VetoSelectionInput : tSelectionInput := ( OTHERS => cEmptyComparisonInEtaPhi );

  TYPE tSelection         IS ARRAY( 7 DOWNTO 0 ) OF BOOLEAN;
  TYPE tSelectionInPhi    IS ARRAY( 0 TO cTowerInPhi-1 ) OF tSelection;
  TYPE tSelectionInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tSelectionInPhi;
  SIGNAL ClusterSelect               : tSelectionInEtaPhi := ( OTHERS => ( OTHERS => ( OTHERS => FALSE ) ) );

  SIGNAL ClusterNorth , ClusterSouth : tClusterInEtaPhi   := cEmptyClusterInEtaPhi;
  SIGNAL TauCluster                  : tClusterInEtaPhi   := cEmptyClusterInEtaPhi;

BEGIN

  phi : FOR i IN 0 TO cTowerInPhi-1 GENERATE

      ClusterSelectionInput( 0 )( 0 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 0 )( MOD_PHI( i + 3 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 0 )( MOD_PHI( i + 3 ) );

      ClusterSelectionInput( 1 )( 0 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 0 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 1 )( OPP_ETA( 0 ) )( MOD_PHI( i + 2 ) ) WHEN NOT ProtoClusterPipeIn( ProtoClusterOffset + 2 )( 0 )( MOD_PHI( i + 2 ) ) .DataValid
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 2 )( 0 )( MOD_PHI( i + 2 ) );

      ClusterSelectionInput( 2 )( 0 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 0 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 0 )( MOD_PHI( i + 2 ) );

      ClusterSelectionInput( 3 )( 0 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 0 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 0 )( 0 )( MOD_PHI( i + 2 ) );

      ClusterSelectionInput( 4 )( 0 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 0 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 1 )( OPP_ETA( 0 ) )( MOD_PHI( i - 2 ) ) WHEN NOT ProtoClusterPipeIn( ProtoClusterOffset + 2 )( 0 )( MOD_PHI( i - 2 ) ) .DataValid
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 2 )( 0 )( MOD_PHI( i - 2 ) );

      ClusterSelectionInput( 5 )( 0 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 0 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 0 )( MOD_PHI( i - 2 ) );

      ClusterSelectionInput( 6 )( 0 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 0 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 0 )( 0 )( MOD_PHI( i - 2 ) );

      ClusterSelectionInput( 7 )( 0 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 0 )( MOD_PHI( i - 3 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 0 )( MOD_PHI( i - 3 ) );


      VetoSelectionInput( 0 )( 0 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 0 )( MOD_PHI( i + 3 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 1 )( 0 )( MOD_PHI( i + 3 ) );

      VetoSelectionInput( 1 )( 0 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 0 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 1 )( OPP_ETA( 0 ) )( MOD_PHI( i + 2 ) ) WHEN NOT TauVetoPipeIn( TauVetoOffset + 2 )( 0 )( MOD_PHI( i + 2 ) ) .DataValid
                                           ELSE TauVetoPipeIn( TauVetoOffset + 2 )( 0 )( MOD_PHI( i + 2 ) );

      VetoSelectionInput( 2 )( 0 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 0 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 1 )( 0 )( MOD_PHI( i + 2 ) );

      VetoSelectionInput( 3 )( 0 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 0 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 0 )( 0 )( MOD_PHI( i + 2 ) );

      VetoSelectionInput( 4 )( 0 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 0 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 1 )( OPP_ETA( 0 ) )( MOD_PHI( i - 2 ) ) WHEN NOT TauVetoPipeIn( TauVetoOffset + 2 )( 0 )( MOD_PHI( i - 2 ) ) .DataValid
                                           ELSE TauVetoPipeIn( TauVetoOffset + 2 )( 0 )( MOD_PHI( i - 2 ) );

      VetoSelectionInput( 5 )( 0 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 0 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 1 )( 0 )( MOD_PHI( i - 2 ) );

      VetoSelectionInput( 6 )( 0 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 0 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 0 )( 0 )( MOD_PHI( i - 2 ) );

      VetoSelectionInput( 7 )( 0 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 0 )( MOD_PHI( i - 3 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 1 )( 0 )( MOD_PHI( i - 3 ) );



      ClusterSelectionInput( 0 )( 1 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 1 )( MOD_PHI( i + 3 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 1 )( MOD_PHI( i + 3 ) );

      ClusterSelectionInput( 3 )( 1 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 1 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 1 )( OPP_ETA( 1 ) )( MOD_PHI( i + 2 ) ) WHEN NOT ProtoClusterPipeIn( ProtoClusterOffset + 2 )( 1 )( MOD_PHI( i + 2 ) ) .DataValid
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 2 )( 1 )( MOD_PHI( i + 2 ) );

      ClusterSelectionInput( 2 )( 1 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 1 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 1 )( MOD_PHI( i + 2 ) );

      ClusterSelectionInput( 1 )( 1 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 1 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 0 )( 1 )( MOD_PHI( i + 2 ) );

      ClusterSelectionInput( 6 )( 1 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 1 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 1 )( OPP_ETA( 1 ) )( MOD_PHI( i - 2 ) ) WHEN NOT ProtoClusterPipeIn( ProtoClusterOffset + 2 )( 1 )( MOD_PHI( i - 2 ) ) .DataValid
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 2 )( 1 )( MOD_PHI( i - 2 ) );

      ClusterSelectionInput( 5 )( 1 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 1 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 1 )( MOD_PHI( i - 2 ) );

      ClusterSelectionInput( 4 )( 1 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 1 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 0 )( 1 )( MOD_PHI( i - 2 ) );

      ClusterSelectionInput( 7 )( 1 )( i ) <= cEmptyCluster WHEN( cIncludeNullState AND NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 1 )( MOD_PHI( i - 3 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE ProtoClusterPipeIn( ProtoClusterOffset + 1 )( 1 )( MOD_PHI( i - 3 ) );


      VetoSelectionInput( 0 )( 1 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 1 )( MOD_PHI( i + 3 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 1 )( 1 )( MOD_PHI( i + 3 ) );

      VetoSelectionInput( 3 )( 1 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 1 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 1 )( OPP_ETA( 1 ) )( MOD_PHI( i + 2 ) ) WHEN NOT TauVetoPipeIn( TauVetoOffset + 2 )( 1 )( MOD_PHI( i + 2 ) ) .DataValid
                                           ELSE TauVetoPipeIn( TauVetoOffset + 2 )( 1 )( MOD_PHI( i + 2 ) );

      VetoSelectionInput( 2 )( 1 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 1 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 1 )( 1 )( MOD_PHI( i + 2 ) );

      VetoSelectionInput( 1 )( 1 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 1 )( MOD_PHI( i + 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 0 )( 1 )( MOD_PHI( i + 2 ) );

      VetoSelectionInput( 6 )( 1 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 1 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 1 )( OPP_ETA( 1 ) )( MOD_PHI( i - 2 ) ) WHEN NOT TauVetoPipeIn( TauVetoOffset + 2 )( 1 )( MOD_PHI( i - 2 ) ) .DataValid
                                           ELSE TauVetoPipeIn( TauVetoOffset + 2 )( 1 )( MOD_PHI( i - 2 ) );

      VetoSelectionInput( 5 )( 1 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 1 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 1 )( 1 )( MOD_PHI( i - 2 ) );

      VetoSelectionInput( 4 )( 1 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 1 )( MOD_PHI( i - 2 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 0 )( 1 )( MOD_PHI( i - 2 ) );

      VetoSelectionInput( 7 )( 1 )( i ) <= cEmptyComparison WHEN( cIncludeNullState AND NOT TauVetoPipeIn( TauVetoOffset + 1 )( 1 )( MOD_PHI( i - 3 ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                           ELSE TauVetoPipeIn( TauVetoOffset + 1 )( 1 )( MOD_PHI( i - 3 ) );



    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE

      ClusterSelect( j )( i )( 0 ) <= ClusterSelectionInput( 0 )( j )( i ) .HasSeed AND NOT VetoSelectionInput( 0 )( j )( i ) .Data;
      ClusterSelect( j )( i )( 1 ) <= ClusterSelectionInput( 1 )( j )( i ) .HasSeed AND NOT VetoSelectionInput( 1 )( j )( i ) .Data;
      ClusterSelect( j )( i )( 2 ) <= ClusterSelectionInput( 2 )( j )( i ) .HasSeed AND NOT VetoSelectionInput( 2 )( j )( i ) .Data AND ProtoClusterPipeIn( ProtoClusterOffset + 1 )( j )( i ) .TrimmingFlags( 6 ) ='0' ; -- "has NN"
      ClusterSelect( j )( i )( 3 ) <= ClusterSelectionInput( 3 )( j )( i ) .HasSeed AND NOT VetoSelectionInput( 3 )( j )( i ) .Data;
      ClusterSelect( j )( i )( 4 ) <= ClusterSelectionInput( 4 )( j )( i ) .HasSeed AND NOT VetoSelectionInput( 4 )( j )( i ) .Data;
      ClusterSelect( j )( i )( 5 ) <= ClusterSelectionInput( 5 )( j )( i ) .HasSeed AND NOT VetoSelectionInput( 5 )( j )( i ) .Data AND ProtoClusterPipeIn( ProtoClusterOffset + 1 )( j )( i ) .TrimmingFlags( 5 ) ='0' ; -- "has SS"
      ClusterSelect( j )( i )( 6 ) <= ClusterSelectionInput( 6 )( j )( i ) .HasSeed AND NOT VetoSelectionInput( 6 )( j )( i ) .Data;
      ClusterSelect( j )( i )( 7 ) <= ClusterSelectionInput( 7 )( j )( i ) .HasSeed AND NOT VetoSelectionInput( 7 )( j )( i ) .Data;

    END GENERATE eta;
  END GENERATE phi;


  phi2   : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    eta2 : FOR j IN 0 TO cRegionInEta-1 GENERATE

      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN

          IF NOT ProtoClusterPipeIn( ProtoClusterOffset + 1 )( j )( i ) .DataValid OR NOT TauVetoPipeIn( TauVetoOffset + 1 )( j )( i ) .DataValid THEN
            ClusterNorth( j )( i ) <= cEmptyCluster;
            ClusterSouth( j )( i ) <= cEmptyCluster;
          ELSE
            IF( ClusterSelect( j )( i )( 0 ) ) THEN
              ClusterNorth( j )( i )          <= ClusterSelectionInput( 0 )( j )( i );
              ClusterNorth( j )( i ) .TauSite <= 0;
            ELSIF( ClusterSelect( j )( i )( 2 ) ) THEN
              ClusterNorth( j )( i )          <= ClusterSelectionInput( 2 )( j )( i );
              ClusterNorth( j )( i ) .TauSite <= 2;
            ELSIF( ClusterSelect( j )( i )( 1 ) AND ClusterSelect( j )( i )( 3 ) ) THEN
-- 1 + ( 2 * j ) = 1 in pos Eta , 3 in negative Eta
-- 3 - ( 2 * j ) = 3 in pos Eta , 1 in negative Eta
              IF( ClusterSelectionInput( 1 + ( 2 * j ) )( j )( i ) .Energy >= ClusterSelectionInput( 3 - (2 * j ) )( j )( i ) .Energy ) THEN
                ClusterNorth( j )( i )          <= ClusterSelectionInput( 1 + ( 2 * j ) )( j )( i );
                ClusterNorth( j )( i ) .TauSite <= 1 + ( 2 * j );
              ELSE
                ClusterNorth( j )( i )          <= ClusterSelectionInput( 3 - (2 * j ) )( j )( i );
                ClusterNorth( j )( i ) .TauSite <= 3 - (2 * j );
              END IF;
            ELSIF( ClusterSelect( j )( i )( 1 ) ) THEN
              ClusterNorth( j )( i )          <= ClusterSelectionInput( 1 )( j )( i );
              ClusterNorth( j )( i ) .TauSite <= 1;
            ELSIF( ClusterSelect( j )( i )( 3 ) ) THEN
              ClusterNorth( j )( i )          <= ClusterSelectionInput( 3 )( j )( i );
              ClusterNorth( j )( i ) .TauSite <= 3;
            ELSE
              ClusterNorth( j )( i )              <= cEmptyCluster;
              ClusterNorth( j )( i ) .NoSecondary <= TRUE;
              ClusterNorth( j )( i ) .DataValid   <= TRUE;
            END IF;

            IF( ClusterSelect( j )( i )( 7 ) ) THEN
              ClusterSouth( j )( i )          <= ClusterSelectionInput( 7 )( j )( i );
              ClusterSouth( j )( i ) .TauSite <= 7;
            ELSIF( ClusterSelect( j )( i )( 5 ) ) THEN
              ClusterSouth( j )( i )          <= ClusterSelectionInput( 5 )( j )( i );
              ClusterSouth( j )( i ) .TauSite <= 5;
            ELSIF( ClusterSelect( j )( i )( 4 ) AND ClusterSelect( j )( i )( 6 ) ) THEN
-- 4 + ( 2 * j ) = 4 in pos Eta , 6 in negative Eta
-- 6 - ( 2 * j ) = 6 in pos Eta , 4 in negative Eta
              IF( ClusterSelectionInput( 4 + ( 2 * j ) )( j )( i ) .Energy >= ClusterSelectionInput( 6 - ( 2 * j ) )( j )( i ) .Energy ) THEN
                ClusterSouth( j )( i )          <= ClusterSelectionInput( 4 + ( 2 * j ) )( j )( i );
                ClusterSouth( j )( i ) .TauSite <= 4 + ( 2 * j );
              ELSE
                ClusterSouth( j )( i )          <= ClusterSelectionInput( 6 - ( 2 * j ) )( j )( i );
                ClusterSouth( j )( i ) .TauSite <= 6 - ( 2 * j );
              END IF;
            ELSIF( ClusterSelect( j )( i )( 4 ) ) THEN
              ClusterSouth( j )( i )          <= ClusterSelectionInput( 4 )( j )( i );
              ClusterSouth( j )( i ) .TauSite <= 4;
            ELSIF( ClusterSelect( j )( i )( 6 ) ) THEN
              ClusterSouth( j )( i )          <= ClusterSelectionInput( 6 )( j )( i );
              ClusterSouth( j )( i ) .TauSite <= 6;
            ELSE
              ClusterSouth( j )( i )              <= cEmptyCluster;
              ClusterSouth( j )( i ) .NoSecondary <= TRUE;
              ClusterSouth( j )( i ) .DataValid   <= TRUE;
            END IF;
          END IF;

        END IF;
      END PROCESS;
    END GENERATE eta2;
  END GENERATE phi2;

  phi3   : FOR i IN 0 TO cTowerInPhi-1 GENERATE
    eta3 : FOR j IN 0 TO cRegionInEta-1 GENERATE
      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN
          IF NOT ClusterNorth( j )( i ) .DataValid OR NOT ClusterSouth( j )( i ) .DataValid THEN
            TauCluster( j )( i ) <= cEmptyCluster;
          ELSE
            IF ClusterNorth( j )( i ) .Energy > ClusterSouth( j )( i ) .Energy THEN
              TauCluster( j )( i ) <= ClusterNorth( j )( i );
            ELSE
              TauCluster( j )( i ) <= ClusterSouth( j )( i );
            END IF;
          END IF;
        END IF;
      END PROCESS;
    END GENERATE eta3;
  END GENERATE phi3;

  ClusterPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => TauCluster ,
    ClusterPipe => TauSecondariesPipeOut
  );

END ARCHITECTURE behavioral;
