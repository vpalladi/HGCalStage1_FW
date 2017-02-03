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

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;


--! @brief An entity providing a ProtoClusterFilter
--! @details Detailed description
ENTITY ProtoClusterFilter IS
  GENERIC(
    ProtoClusterOffset : INTEGER := 0;
    ObjectType         : STRING
  );
  PORT(
    clk                         : IN STD_LOGIC := '0' ; --! The algorithm clock
    ProtoClusterPipeIn          : IN tClusterPipe ;     --! A pipe of tCluster objects bringing in the ProtoCluster's
    Veto9x3PipeIn               : IN tComparisonPipe ;  --! A pipe of tComparison objects bringing in the Veto9x3's
    FilteredProtoClusterPipeOut : OUT tClusterPipe ;    --! A pipe of tCluster objects passing out the FilteredProtoCluster's
    BusIn                       : IN tFMBus;
    BusOut                      : OUT tFMBus;
    BusClk                      : IN STD_LOGIC := '0'
  );
END ProtoClusterFilter;

--! @brief Architecture definition for entity ProtoClusterFilter
--! @details Detailed description
ARCHITECTURE behavioral OF ProtoClusterFilter IS
  SIGNAL FilteredProtoCluster : tClusterInEtaPhi := cEmptyClusterInEtaPhi;

  TYPE tEtaCounterInPhi    IS ARRAY( 0 TO( cTowerInPhi / 2 ) -1 ) OF INTEGER RANGE 0 TO cTowersInHalfEta ; -- cTowerInPhi / 4 wide
  TYPE tEtaCounterInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tEtaCounterInPhi ; -- Two halves in eta
  SIGNAL EtaCounter : tEtaCounterInEtaPhi            := ( OTHERS => ( OTHERS => cCMScoordinateOffset ) );

  SIGNAL EtaLimit   : STD_LOGIC_VECTOR( 5 DOWNTO 0 ) := ( OTHERS => '0' );

BEGIN

-- --------------------------------------------------
  ClusterEtaLimitInstance : ENTITY work.GenRegister
  GENERIC MAP(
    BusName      => ObjectType & "EtaMax" ,
    DefaultValue => DefaultEgammaTauEtaMax ,
    Registering  => 2
  )
  PORT MAP(
    DataOut => EtaLimit ,
    BusIn   => BusIn ,
    BusOut  => BusOut ,
    BusClk  => BusClk
  );
-- --------------------------------------------------

  phi   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN

          IF( NOT ProtoClusterPipeIn( ProtoClusterOffset )( j )( ( 4 * i ) + 0 ) .DataValid ) THEN -- OR NOT Veto9x3PipeIn( 0 )( j )( ( 4 * i ) + 0 ) .DataValid ) THEN
            EtaCounter( j )( i )           <= cCMScoordinateOffset;
            FilteredProtoCluster( j )( i ) <= cEmptyCluster;
          ELSE
            EtaCounter( j )( i ) <= EtaCounter( j )( i ) + 1;

            IF( EtaCounter( j )( i ) >= cEcalTowersInHalfEta + cCMScoordinateOffset ) THEN
              FilteredProtoCluster( j )( i ) <= cEmptyCluster;
            ELSIF( EtaCounter( j )( i ) >= TO_INTEGER( UNSIGNED( EtaLimit ) ) + cCMScoordinateOffset ) THEN
              FilteredProtoCluster( j )( i )            <= cEmptyCluster;
              FilteredProtoCluster( j )( i ) .Eta       <= EtaCounter( j )( i );
              FilteredProtoCluster( j )( i ) .DataValid <= TRUE;
            ELSIF( NOT Veto9x3PipeIn( 0 )( j )( ( 4 * i ) + 0 ) .Data ) THEN
              FilteredProtoCluster( j )( i )      <= ProtoClusterPipeIn( ProtoClusterOffset )( j )( MOD_PHI( ( 4 * i ) + 0 ) );
              FilteredProtoCluster( j )( i ) .Eta <= EtaCounter( j )( i );
              FilteredProtoCluster( j )( i ) .Phi <= MOD_PHI( ( 4 * i ) + 0 ) + cCMScoordinateOffset;
            ELSIF( NOT Veto9x3PipeIn( 0 )( j )( ( 4 * i ) + 1 ) .Data ) THEN
              FilteredProtoCluster( j )( i )      <= ProtoClusterPipeIn( ProtoClusterOffset )( j )( MOD_PHI( ( 4 * i ) + 1 ) );
              FilteredProtoCluster( j )( i ) .Eta <= EtaCounter( j )( i );
              FilteredProtoCluster( j )( i ) .Phi <= MOD_PHI( ( 4 * i ) + 1 ) + cCMScoordinateOffset;
            ELSIF( NOT Veto9x3PipeIn( 0 )( j )( ( 4 * i ) + 2 ) .Data ) THEN
              FilteredProtoCluster( j )( i )      <= ProtoClusterPipeIn( ProtoClusterOffset )( j )( MOD_PHI( ( 4 * i ) + 2 ) );
              FilteredProtoCluster( j )( i ) .Eta <= EtaCounter( j )( i );
              FilteredProtoCluster( j )( i ) .Phi <= MOD_PHI( ( 4 * i ) + 2 ) + cCMScoordinateOffset;
            ELSIF( NOT Veto9x3PipeIn( 0 )( j )( ( 4 * i ) + 3 ) .Data ) THEN
              FilteredProtoCluster( j )( i )      <= ProtoClusterPipeIn( ProtoClusterOffset )( j )( MOD_PHI( ( 4 * i ) + 3 ) );
              FilteredProtoCluster( j )( i ) .Eta <= EtaCounter( j )( i );
              FilteredProtoCluster( j )( i ) .Phi <= MOD_PHI( ( 4 * i ) + 3 ) + cCMScoordinateOffset;
            ELSE
              FilteredProtoCluster( j )( i )            <= cEmptyCluster;
              FilteredProtoCluster( j )( i ) .Eta       <= EtaCounter( j )( i );
              FilteredProtoCluster( j )( i ) .DataValid <= TRUE;
            END IF;

          END IF;
        END IF;
      END PROCESS;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    END GENERATE eta;
  END GENERATE phi;

  ClusterPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    clusterIn   => FilteredProtoCluster ,
    clusterPipe => FilteredProtoClusterPipeOut
  );

END ARCHITECTURE behavioral;
