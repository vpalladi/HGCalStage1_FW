


-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;


--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;
--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! @brief An entity providing a BitonicSortClusterPipes
--! @details Detailed description
ENTITY BitonicSortClusterPipes IS
  GENERIC(
    Size : INTEGER := 0
  );
  PORT(
    clk                   : IN STD_LOGIC := '0' ; --! The algorithm clock
    filteredClusterPipeIn : IN tClusterPipe ;     --! A pipe of tCluster objects bringing in the filteredCluster's
    sortedClusterPipeOut  : OUT tClusterPipe      --! A pipe of tCluster objects passing out the sortedCluster's
  );
END BitonicSortClusterPipes;
-- ----------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;


--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;
--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! @brief An entity providing a AccumulatingBitonicSortClusterPipes
--! @details Detailed description
ENTITY AccumulatingBitonicSortClusterPipes IS
  GENERIC(
    Size : INTEGER := 0
  );
  PORT(
    clk                             : IN STD_LOGIC := '0' ;         --! The algorithm clock
    sortedClusterPipeIn             : IN tClusterPipe ;             --! A pipe of tCluster objects bringing in the sortedCluster's
    accumulatedSortedClusterPipeOut : OUT tClusterPipe ;            --! A pipe of tCluster objects passing out the accumulatedSortedCluster's
    accumulationCompletePipeOut     : OUT tAccumulationCompletePipe --! A pipe of tAccumulationComplete objects passing out the accumulationComplete's
  );
END AccumulatingBitonicSortClusterPipes;
-- ----------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;


--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;
--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! @brief An entity providing a FinalBitonicSortClusterPipes
--! @details Detailed description
ENTITY FinalBitonicSortClusterPipes IS
  GENERIC(
    Size : INTEGER := 6
  );
  PORT(
    clk            : IN STD_LOGIC := '0' ;                                                             --! The algorithm clock
    ClusterPipeIn  : IN tClusterPipe ;                                                                 --! A pipe of tCluster objects bringing in the Cluster's
    ClusterPipeOut : OUT tClusterPipe -- Just a convenient container , all Clusters will be in "eta-0" --! A pipe of tCluster objects passing out the Cluster's
  );
END FinalBitonicSortClusterPipes;
-- ----------------------------------------------------------------------------------------------------



-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;


--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! @brief An entity providing a BitonicSortClusters
--! @details Detailed description
ENTITY BitonicSortClusters IS
  GENERIC(
    InSize  : INTEGER := 0;
    OutSize : INTEGER := 0;
    D       : BOOLEAN := true -- sort direction
  );
  PORT(
    C : IN STD_LOGIC ; -- clock
    I : IN tClusterInPhi( 0 TO InSize-1 )   := ( OTHERS => cEmptyCluster );
    O : OUT tClusterInPhi( 0 TO OutSize-1 ) := ( OTHERS => cEmptyCluster )
  );
END BitonicSortClusters;
-- ----------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;


--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;
--! Using the Calo-L2 "Cluster" helper functions
USE work.Cluster_functions.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! @brief An entity providing a BitonicMergeClusters
--! @details Detailed description
ENTITY BitonicMergeClusters IS
  GENERIC(
    Size : INTEGER := 0;
    D    : BOOLEAN := true
  );
  PORT(
    C : IN STD_LOGIC ; -- clock
    I : IN tClusterInPhi( 0 TO Size-1 )  := ( OTHERS => cEmptyCluster );
    O : OUT tClusterInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyCluster )
  );
END BitonicMergeClusters;
-- ----------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;
--! Using the Calo-L2 "Cluster" helper functions
USE work.Cluster_functions.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! @brief An entity providing a ClusterSortAccumulator
--! @details Detailed description
ENTITY ClusterSortAccumulator IS
  GENERIC(
    Size  : INTEGER := 0;
    Delay : INTEGER := 0
  );
  PORT(
    C  : IN STD_LOGIC ; -- clock
    I  : IN tClusterInPhi( 0 TO Size-1 )  := ( OTHERS => cEmptyCluster );
    O0 : OUT tCluster                     := cEmptyCluster;
    O1 : OUT tClusterInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyCluster )
  );
END ClusterSortAccumulator;
-- ----------------------------------------------------------------------------------------------------



-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;


--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;
--! Using the Calo-L2 "Cluster" helper functions
USE work.Cluster_functions.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! @brief An entity providing a AccumulatingBitonicSortClusters
--! @details Detailed description
ENTITY AccumulatingBitonicSortClusters IS
  GENERIC(
    Size : INTEGER := 0;
    D    : BOOLEAN := true
  );
  PORT(
    C : IN STD_LOGIC ; -- clock
    I : IN tClusterInPhi( 0 TO Size-1 )  := ( OTHERS => cEmptyCluster );
    O : OUT tClusterInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyCluster );
    Q : OUT BOOLEAN                      := FALSE
  );
END AccumulatingBitonicSortClusters;
-- ----------------------------------------------------------------------------------------------------

--

-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity BitonicSortClusterPipes
--! @details Detailed description
ARCHITECTURE behavioral OF BitonicSortClusterPipes IS
  SIGNAL sortedClusterInEtaPhi : tClusterInEtaPhi := cEmptyClusterInEtaPhi;
BEGIN
  eta                           : FOR j IN 0 TO cRegionInEta-1 GENERATE
    BitonicSortClustersInstance : ENTITY work.BitonicSortClusters
      GENERIC MAP(
        InSize  => ( cTowerInPhi / 4 ) ,
        OutSize => Size ,
        D       => false
      )
      PORT MAP(
        C => clk ,
        I => filteredClusterPipeIn( 0 )( j )( 0 TO( cTowerInPhi / 4 ) -1 ) ,
        O => sortedClusterInEtaPhi( j )( 0 TO Size-1 )
      );
  END GENERATE eta;

  SortedClusterPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => sortedClusterInEtaPhi ,
    ClusterPipe => sortedClusterPipeOut
  );

END ARCHITECTURE behavioral ; -- BitonicSortClusterPipes
-- ----------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity AccumulatingBitonicSortClusterPipes
--! @details Detailed description
ARCHITECTURE behavioral OF AccumulatingBitonicSortClusterPipes IS
  SIGNAL accumulatedSortedClusterInEtaPhi : tClusterInEtaPhi           := cEmptyClusterInEtaPhi;
  SIGNAL accumulationCompleteInEta        : tAccumulationCompleteInEta := cEmptyAccumulationCompleteInEta;
BEGIN
  eta                                       : FOR j IN 0 TO cRegionInEta-1 GENERATE
    AccumulatingBitonicSortClustersInstance : ENTITY work.AccumulatingBitonicSortClusters
    GENERIC MAP(
      Size => Size ,
      D    => false
    )
    PORT MAP(
      C => clk ,
      I => sortedClusterPipeIn( 0 )( j )( 0 TO Size-1 ) ,
      O => accumulatedSortedClusterInEtaPhi( j )( 0 TO Size-1 ) ,
      Q => accumulationCompleteInEta( j )
    );
  END GENERATE eta;

  AccumulationCompletePipeInstance : ENTITY work.AccumulationCompletePipe
  PORT MAP(
    clk                      => clk ,
    accumulationCompleteIn   => accumulationCompleteInEta ,
    accumulationCompletePipe => accumulationCompletePipeOut
  );

  AccumulatedSortedClusterPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => accumulatedSortedClusterInEtaPhi ,
    ClusterPipe => accumulatedSortedClusterPipeOut
  );

END ARCHITECTURE behavioral ; -- AccumulatingBitonicSortClusterPipes
-- ----------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity FinalBitonicSortClusterPipes
--! @details Detailed description
ARCHITECTURE behavioral OF FinalBitonicSortClusterPipes IS
  SIGNAL T1 : tClusterInPhi( 0 TO( 2 * Size ) -1 ) := ( OTHERS => cEmptyCluster );
  SIGNAL T2 : tClusterInPhi( 0 TO( 2 * Size ) -1 ) := ( OTHERS => cEmptyCluster );
  SIGNAL T3 : tClusterInEtaPhi                     := cEmptyClusterInEtaPhi;

BEGIN

  G1 : FOR x IN Size-1 DOWNTO 0 GENERATE
    T1( Size + x ) <= ClusterPipeIn( 0 )( 0 )( x ) WHEN ClusterPipeIn( 0 )( 0 )( x ) .DataValid ELSE cEmptyCluster;
    T1( x )        <= ClusterPipeIn( 0 )( 1 )( ( Size-1 ) - x ) WHEN ClusterPipeIn( 0 )( 1 )( ( Size-1 ) - x ) .DataValid ELSE cEmptyCluster;
  END GENERATE G1;

  M : ENTITY work.BitonicMergeClusters
  GENERIC MAP(
    Size => 2 * Size ,
    D    => false
  )
  PORT MAP(
    C => clk ,
    I => T1 ,
    O => T2
  );

  T3( 0 )( 0 TO( 2 * Size ) -1 ) <= T2;

  SortedClusterPipeInstance : ENTITY work.ClusterPipe
  PORT MAP(
    clk         => clk ,
    ClusterIn   => T3 ,
    ClusterPipe => ClusterPipeOut
  );

END ARCHITECTURE behavioral ; -- BitonicSortClusterPipes
-- ----------------------------------------------------------------------------------------------------





-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity BitonicSortClusters
--! @details Detailed description
ARCHITECTURE behavioral OF BitonicSortClusters IS
  CONSTANT LowerInSize      : INTEGER := InSize / 2;
  CONSTANT UpperInSize      : INTEGER := InSize - LowerInSize ; -- UpperSize >= LowerSize

  CONSTANT LowerOutSize     : INTEGER := MINIMUM( OutSize , LowerInSize );
  CONSTANT UpperOutSize     : INTEGER := MINIMUM( OutSize , UpperInSize );

  CONSTANT LowerSortLatency : INTEGER := LatencyOfBitonicSort( LowerInSize , LowerOutSize );
  CONSTANT UpperSortLatency : INTEGER := LatencyOfBitonicSort( UpperInSize , UpperOutSize );

  CONSTANT PipeLength       : INTEGER := MAXIMUM( UpperSortLatency-LowerSortLatency , 2 );

  TYPE tOffsetPipe IS ARRAY( NATURAL RANGE <> ) OF tClusterInPhi( 0 TO LowerOutSize + UpperOutSize-1 );
  SIGNAL T1 : tOffsetPipe( PipeLength DOWNTO 0 )                  := ( OTHERS => ( OTHERS => cEmptyCluster ) );
  SIGNAL T2 : tClusterInPhi( 0 TO LowerOutSize + UpperOutSize-1 ) := ( OTHERS => cEmptyCluster );
  SIGNAL T3 : tClusterInPhi( 0 TO LowerOutSize + UpperOutSize-1 ) := ( OTHERS => cEmptyCluster );

  COMPONENT BitonicSortClusters IS
    GENERIC(
      InSize  : INTEGER := 0;
      OutSize : INTEGER := 0;
      D       : BOOLEAN := false -- sort direction
    );
    PORT(
      C : IN STD_LOGIC ; -- clock
      I : IN tClusterInPhi( 0 TO InSize-1 )   := ( OTHERS => cEmptyCluster );
      O : OUT tClusterInPhi( 0 TO OutSize-1 ) := ( OTHERS => cEmptyCluster )
    );
  END COMPONENT BitonicSortClusters;

  COMPONENT BitonicMergeClusters IS
    GENERIC(
      Size : INTEGER := 0;
      D    : BOOLEAN := false -- sort direction
    );
    PORT(
      C : IN STD_LOGIC ; -- clock
      I : IN tClusterInPhi( 0 TO Size-1 )  := ( OTHERS => cEmptyCluster );
      O : OUT tClusterInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyCluster )
    );
  END COMPONENT BitonicMergeClusters;

BEGIN

-- If size is 1 , just pass through
  G1 : IF InSize <= 1 GENERATE
    O            <= I;
  END GENERATE G1;

-- If size is greater than 1 , sort lower "half" and upper "half" separately and then merge
  G2   : IF InSize > 1 GENERATE

    S1 : BitonicSortClusters
    GENERIC MAP(
      InSize  => LowerInSize ,
      OutSize => LowerOutSize ,
      D       => NOT D
    )
    PORT MAP(
      C => C ,
      I => I( 0 TO LowerInSize-1 ) ,
      O => T1( 0 )( 0 TO LowerOutSize-1 )
    );

-- Just needs to be long enough - anything unused will be synthesized away....
    G21 : FOR x IN PipeLength DOWNTO 1 GENERATE
      T1( x ) <= T1( x-1 ) WHEN RISING_EDGE( C );
    END GENERATE G21;

    T2( 0 TO LowerOutSize-1 ) <= T1( UpperSortLatency-LowerSortLatency )( 0 TO LowerOutSize-1 );

    S2 : BitonicSortClusters
    GENERIC MAP(
      InSize  => UpperInSize ,
      OutSize => UpperOutSize ,
      D       => D
    )
    PORT MAP(
      C => C ,
      I => I( LowerInSize TO InSize-1 ) ,
      O => T2( LowerOutSize TO LowerOutSize + UpperOutSize-1 )
    );

    M : BitonicMergeClusters
    GENERIC MAP(
      Size => LowerOutSize + UpperOutSize ,
      D    => D
    )
    PORT MAP(
      C => C ,
      I => T2 ,
      O => T3
    );

    G22 : IF NOT D GENERATE
      O( 0 TO OutSize-1 ) <= T3( 0 TO OutSize-1 );
    END GENERATE G22;

    G23 : IF D GENERATE
      O( 0 TO OutSize-1 ) <= T3( LowerOutSize + UpperOutSize-OutSize TO LowerOutSize + UpperOutSize-1 );
    END GENERATE G23;


  END GENERATE G2;

END ARCHITECTURE behavioral ; -- BitonicSortClusters
-- ----------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity BitonicMergeClusters
--! @details Detailed description
ARCHITECTURE behavioral OF BitonicMergeClusters IS
  SIGNAL T1                  : tClusterInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyCluster );
  SIGNAL T2                  : tClusterInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyCluster );

  CONSTANT LowerSize         : INTEGER                      := PowerOf2LessThan( Size ) ; -- LowerSize >= Size / 2
  CONSTANT UpperSize         : INTEGER                      := Size - LowerSize ; -- UpperSize < LowerSize

  CONSTANT LowerMergeLatency : INTEGER                      := LatencyOfBitonicMerge( LowerSize );
  CONSTANT UpperMergeLatency : INTEGER                      := LatencyOfBitonicMerge( UpperSize );

  CONSTANT PipeLength        : INTEGER                      := MAXIMUM( LowerMergeLatency-UpperMergeLatency , 2 );

  TYPE tOffsetPipe IS ARRAY( NATURAL RANGE <> ) OF tClusterInPhi( LowerSize TO Size-1 );
  SIGNAL T3 : tOffsetPipe( PipeLength DOWNTO 0 ) := ( OTHERS => ( OTHERS => cEmptyCluster ) );

  COMPONENT BitonicMergeClusters IS
    GENERIC(
      Size : INTEGER := 0;
      D    : BOOLEAN := false -- sort direction
    );
    PORT(
      C : IN STD_LOGIC ; -- clock
      I : IN tClusterInPhi( 0 TO Size-1 )  := ( OTHERS => cEmptyCluster );
      O : OUT tClusterInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyCluster )
    );
  END COMPONENT BitonicMergeClusters;

BEGIN

  G1 : IF Size <= 1 GENERATE
    O          <= I;
  END GENERATE G1;

  G2    : IF Size > 1 GENERATE

    G21 : FOR x IN 0 TO UpperSize-1 GENERATE
      PROCESS( C )
      BEGIN
        IF( RISING_EDGE( C ) ) THEN
          IF( ( I( x ) > I( x + LowerSize ) ) = D ) THEN
            T1( x )             <= I( x + LowerSize );
            T1( x + LowerSize ) <= I( x );
          ELSE
            T1( x )             <= I( x );
            T1( x + LowerSize ) <= I( x + LowerSize );
          END IF;
-- T1( x ) .DataValid <= I( x ) .DataValid AND I( x + LowerSize ) .DataValid;
-- T1( x + LowerSize ) .DataValid <= I( x ) .DataValid AND I( x + LowerSize ) .DataValid;
        END IF;
      END PROCESS;
    END GENERATE G21;

    G22 : IF LowerSize > UpperSize GENERATE
      T1( UpperSize TO LowerSize-1 ) <= I( UpperSize TO LowerSize-1 ) WHEN RISING_EDGE( C );
    END GENERATE G22;

    M1 : BitonicMergeClusters
      GENERIC MAP(
        Size => LowerSize ,
        D    => D
      )
      PORT MAP(
        C => C ,
        I => T1( 0 TO LowerSize-1 ) ,
        O => T2( 0 TO LowerSize-1 )
      );

    M2 : BitonicMergeClusters
      GENERIC MAP(
        Size => UpperSize ,
        D    => D
      )
      PORT MAP(
        C => C ,
        I => T1( LowerSize TO Size-1 ) ,
        O => T3( 0 )( LowerSize TO Size-1 )
      );

-- Just needs to be long enough - anything unused will be synthesized away....
    G23 : FOR x IN PipeLength DOWNTO 1 GENERATE
      T3( x ) <= T3( x-1 ) WHEN RISING_EDGE( C );
    END GENERATE G23;

    O( 0 TO LowerSize-1 )    <= T2( 0 TO LowerSize-1 );
    O( LowerSize TO Size-1 ) <= T3( LowerMergeLatency-UpperMergeLatency )( LowerSize TO Size-1 );

  END GENERATE G2;

END ARCHITECTURE behavioral ; -- BitonicMergeClusters
-- ----------------------------------------------------------------------------------------------------



-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity ClusterSortAccumulator
--! @details Detailed description
ARCHITECTURE behavioral OF ClusterSortAccumulator IS
-- I : IN tClusterInPhi( Size-1 DOWNTO 0 ) := ( OTHERS => cEmptyCluster );
-- O0 : OUT tCluster := cEmptyCluster;
-- O1 : OUT tClusterInPhi( Size-1 DOWNTO 0 ) := ( OTHERS => cEmptyCluster )

  SIGNAL T0 : tClusterInPhi( 0 TO SIZE ) := ( OTHERS => cEmptyCluster );
  TYPE tComparisonArray1d IS ARRAY( 0 TO SIZE ) OF BOOLEAN;
  SIGNAL C0 : tComparisonArray1d := ( OTHERS => FALSE );

  TYPE tOffsetPipe IS ARRAY( Delay DOWNTO 0 ) OF tCluster;
  SIGNAL T1 : tOffsetPipe := ( OTHERS => cEmptyCluster );

BEGIN

  PROCESS( C )
    VARIABLE x : INTEGER RANGE 0 TO Size := 0;
  BEGIN

    IF( FALLING_EDGE( C ) ) THEN
      L1 : FOR x IN 0 TO Size-1 LOOP
        C0( x ) <= I( x ) > T0( 0 ) ; -- previous accumulation is less than new list entry @ x
      END LOOP;
    END IF;

    IF( RISING_EDGE( C ) ) THEN
      IF NOT I( 0 ) .DataValid THEN
        T0 <= ( OTHERS => cEmptyCluster );
      ELSE
        IF C0( 0 ) THEN -- previous accumulation is less than new list entry @ 0 ,
          T0( 0 ) <= I( 0 ) ; -- so new list entry takes the top spot
        ELSE -- previous accumulation is greater than or equal to new list entry @ 0
          T0( 0 ) <= T0( 0 ) ; -- so previous accumulation retains the top spot
        END IF;

        L2 : FOR x IN 1 TO Size-1 LOOP
          IF C0( x ) THEN -- previous accumulation is less than new list entry @ x ,
            T0( x ) <= I( x ) ; -- so new list entry maintains its position
          ELSIF C0( x-1 ) THEN -- previous accumulation is greater than or equal to new list enty @ x but less than the entry above ,
            T0( x ) <= T0( 0 ) ; -- so insert previous accumulation here
          ELSE -- previous accumulation is greater than or equal to new list enty @ x and also greater than or equal to the entry above
            T0( x ) <= I( x-1 ) ; -- so output is shunted down one position
          END IF;
        END LOOP;

      END IF;

    END IF;
  END PROCESS;

  T1( 0 ) <= T0( 0 );
  G : FOR x IN Delay DOWNTO 1 GENERATE
    T1( x ) <= T1( x-1 ) WHEN RISING_EDGE( C );
  END GENERATE G;


  O0                <= T1( Delay );
  O1( 0 TO Size-1 ) <= T0( 1 TO Size );

END ARCHITECTURE behavioral ; -- ClusterSortAccumulator
-- ----------------------------------------------------------------------------------------------------




-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity AccumulatingBitonicSortClusters
--! @details Detailed description
ARCHITECTURE behavioral OF AccumulatingBitonicSortClusters IS
  TYPE tSortPipe IS ARRAY( 0 TO Size ) OF tClusterInPhi( 0 TO Size - 1 );

  SIGNAL K  : tSortPipe                             := ( OTHERS => ( OTHERS => cEmptyCluster ) );
  SIGNAL DV : STD_LOGIC_VECTOR( Size + 1 DOWNTO 0 ) := ( OTHERS => '0' );
BEGIN

  K( 0 ) <= I WHEN RISING_EDGE( C );

  G1                               : FOR x IN 0 TO Size-1 GENERATE
    ClusterSortAccumulatorInstance : ENTITY work.ClusterSortAccumulator
    GENERIC MAP(
      Size  => Size ,
      Delay => Size - x
    )
    PORT MAP(
      C  => C ,
      I  => K( x ) ,
      O0 => O( x ) ,
      O1 => K( x + 1 )
    );
  END GENERATE G1;

  PROCESS( C )
  BEGIN
    IF RISING_EDGE( C ) THEN
      DV( Size + 1 DOWNTO 0 ) <= DV( Size DOWNTO 0 ) & TO_STD_LOGIC( I( 0 ) .DataValid ) ; -- Input is sorted , so if any data is valid , I( 0 ) will be
    END IF;
  END PROCESS;

  Q <= ( DV( Size + 1 ) = '1' AND DV( Size ) = '0' );


END ARCHITECTURE behavioral ; -- AccumulatingBitonicSortClusters
