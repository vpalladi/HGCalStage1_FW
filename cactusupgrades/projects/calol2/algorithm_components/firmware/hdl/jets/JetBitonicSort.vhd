


-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;


--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;
--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! @brief An entity providing a BitonicSortJetPipes
--! @details Detailed description
ENTITY BitonicSortJetPipes IS
  GENERIC(
    Size : INTEGER := 0
  );
  PORT(
    clk               : IN STD_LOGIC := '0' ; --! The algorithm clock
    filteredJetPipeIn : IN tJetPipe ;         --! A pipe of tJet objects bringing in the filteredJet's
    sortedJetPipeOut  : OUT tJetPipe          --! A pipe of tJet objects passing out the sortedJet's
  );
END BitonicSortJetPipes;
-- ----------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;


--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;
--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! @brief An entity providing a AccumulatingBitonicSortJetPipes
--! @details Detailed description
ENTITY AccumulatingBitonicSortJetPipes IS
  GENERIC(
    Size : INTEGER := 0
  );
  PORT(
    clk                         : IN STD_LOGIC := '0' ;         --! The algorithm clock
    sortedJetPipeIn             : IN tJetPipe ;                 --! A pipe of tJet objects bringing in the sortedJet's
    accumulatedSortedJetPipeOut : OUT tJetPipe ;                --! A pipe of tJet objects passing out the accumulatedSortedJet's
    accumulationCompletePipeOut : OUT tAccumulationCompletePipe --! A pipe of tAccumulationComplete objects passing out the accumulationComplete's
  );
END AccumulatingBitonicSortJetPipes;
-- ----------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;


--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;
--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! @brief An entity providing a FinalBitonicSortJetPipes
--! @details Detailed description
ENTITY FinalBitonicSortJetPipes IS
  GENERIC(
    Size : INTEGER := 6
  );
  PORT(
    clk        : IN STD_LOGIC := '0' ;                                                     --! The algorithm clock
    JetPipeIn  : IN tJetPipe ;                                                             --! A pipe of tJet objects bringing in the Jet's
    JetPipeOut : OUT tJetPipe -- Just a convenient container , all jets will be in "eta-0" --! A pipe of tJet objects passing out the Jet's
  );
END FinalBitonicSortJetPipes;
-- ----------------------------------------------------------------------------------------------------



-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;


--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! @brief An entity providing a BitonicSortJets
--! @details Detailed description
ENTITY BitonicSortJets IS
  GENERIC(
    InSize  : INTEGER := 0;
    OutSize : INTEGER := 0;
    D       : BOOLEAN := true -- sort direction
  );
  PORT(
    C : IN STD_LOGIC ; -- clock
    I : IN tJetInPhi( 0 TO InSize-1 )   := ( OTHERS => cEmptyJet );
    O : OUT tJetInPhi( 0 TO OutSize-1 ) := ( OTHERS => cEmptyJet )
  );
END BitonicSortJets;
-- ----------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;


--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "jet" helper functions
USE work.jet_functions.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! @brief An entity providing a BitonicMergeJets
--! @details Detailed description
ENTITY BitonicMergeJets IS
  GENERIC(
    Size : INTEGER := 0;
    D    : BOOLEAN := true
  );
  PORT(
    C : IN STD_LOGIC ; -- clock
    I : IN tJetInPhi( 0 TO Size-1 )  := ( OTHERS => cEmptyJet );
    O : OUT tJetInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyJet )
  );
END BitonicMergeJets;
-- ----------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "jet" helper functions
USE work.jet_functions.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! @brief An entity providing a JetSortAccumulator
--! @details Detailed description
ENTITY JetSortAccumulator IS
  GENERIC(
    Size  : INTEGER := 0;
    Delay : INTEGER := 0
  );
  PORT(
    C  : IN STD_LOGIC ; -- clock
    I  : IN tJetInPhi( 0 TO Size-1 )  := ( OTHERS => cEmptyJet );
    O0 : OUT tJet                     := cEmptyJet;
    O1 : OUT tJetInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyJet )
  );
END JetSortAccumulator;
-- ----------------------------------------------------------------------------------------------------



-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;


--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "jet" helper functions
USE work.jet_functions.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! @brief An entity providing a AccumulatingBitonicSortJets
--! @details Detailed description
ENTITY AccumulatingBitonicSortJets IS
  GENERIC(
    Size : INTEGER := 0;
    D    : BOOLEAN := true
  );
  PORT(
    C : IN STD_LOGIC ; -- clock
    I : IN tJetInPhi( 0 TO Size-1 )  := ( OTHERS => cEmptyJet );
    O : OUT tJetInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyJet );
    Q : OUT BOOLEAN                  := FALSE
  );
END AccumulatingBitonicSortJets;
-- ----------------------------------------------------------------------------------------------------

--

-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity BitonicSortJetPipes
--! @details Detailed description
ARCHITECTURE behavioral OF BitonicSortJetPipes IS
  SIGNAL sortedJetInEtaPhi : tJetInEtaPhi := cEmptyJetInEtaPhi;
BEGIN
  eta                       : FOR j IN 0 TO cRegionInEta-1 GENERATE
    BitonicSortJetsInstance : ENTITY work.BitonicSortJets
      GENERIC MAP(
        InSize  => ( cTowerInPhi / 4 ) ,
        OutSize => Size ,
        D       => false
      )
      PORT MAP(
        C => clk ,
        I => filteredJetPipeIn( 0 )( j )( 0 TO( cTowerInPhi / 4 ) -1 ) ,
        O => sortedJetInEtaPhi( j )( 0 TO Size-1 )
      );
  END GENERATE eta;

  SortedJetPipeInstance : ENTITY work.JetPipe
  PORT MAP(
    clk     => clk ,
    jetIn   => sortedJetInEtaPhi ,
    jetPipe => sortedJetPipeOut
  );

END ARCHITECTURE behavioral ; -- BitonicSortJetPipes
-- ----------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity AccumulatingBitonicSortJetPipes
--! @details Detailed description
ARCHITECTURE behavioral OF AccumulatingBitonicSortJetPipes IS
  SIGNAL accumulatedSortedJetInEtaPhi : tJetInEtaPhi               := cEmptyJetInEtaPhi;
  SIGNAL accumulationCompleteInEta    : tAccumulationCompleteInEta := cEmptyAccumulationCompleteInEta;
BEGIN
  eta                                   : FOR j IN 0 TO cRegionInEta-1 GENERATE
    AccumulatingBitonicSortJetsInstance : ENTITY work.AccumulatingBitonicSortJets
    GENERIC MAP(
      Size => Size ,
      D    => false
    )
    PORT MAP(
      C => clk ,
      I => sortedJetPipeIn( 0 )( j )( 0 TO Size-1 ) ,
      O => accumulatedSortedJetInEtaPhi( j )( 0 TO Size-1 ) ,
      Q => accumulationCompleteInEta( j )
    );
  END GENERATE eta;

  AccumulationCompletePipeInstance : ENTITY work.AccumulationCompletePipe
  PORT MAP(
    clk                      => clk ,
    accumulationCompleteIn   => accumulationCompleteInEta ,
    accumulationCompletePipe => accumulationCompletePipeOut
  );

  AccumulatedSortedJetPipeInstance : ENTITY work.JetPipe
  PORT MAP(
    clk     => clk ,
    jetIn   => accumulatedSortedJetInEtaPhi ,
    jetPipe => accumulatedSortedJetPipeOut
  );

END ARCHITECTURE behavioral ; -- AccumulatingBitonicSortJetPipes
-- ----------------------------------------------------------------------------------------------------


-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity FinalBitonicSortJetPipes
--! @details Detailed description
ARCHITECTURE behavioral OF FinalBitonicSortJetPipes IS
  SIGNAL T1 : tJetInPhi( 0 TO( 2 * Size ) -1 ) := ( OTHERS => cEmptyJet );
  SIGNAL T2 : tJetInPhi( 0 TO( 2 * Size ) -1 ) := ( OTHERS => cEmptyJet );
  SIGNAL T3 : tJetInEtaPhi                     := cEmptyJetInEtaPhi;

BEGIN

  G1 : FOR x IN Size-1 DOWNTO 0 GENERATE
    T1( Size + x ) <= JetPipeIn( 0 )( 0 )( x ) WHEN JetPipeIn( 0 )( 0 )( x ) .DataValid ELSE cEmptyJet;
    T1( x )        <= JetPipeIn( 0 )( 1 )( ( Size-1 ) - x ) WHEN JetPipeIn( 0 )( 1 )( ( Size-1 ) - x ) .DataValid ELSE cEmptyJet;
  END GENERATE G1;

  M : ENTITY work.BitonicMergeJets
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

  SortedJetPipeInstance : ENTITY work.JetPipe
  PORT MAP(
    clk     => clk ,
    jetIn   => T3 ,
    jetPipe => JetPipeOut
  );

END ARCHITECTURE behavioral ; -- BitonicSortJetPipes
-- ----------------------------------------------------------------------------------------------------





-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity BitonicSortJets
--! @details Detailed description
ARCHITECTURE behavioral OF BitonicSortJets IS
  CONSTANT LowerInSize      : INTEGER := InSize / 2;
  CONSTANT UpperInSize      : INTEGER := InSize - LowerInSize ; -- UpperSize >= LowerSize

  CONSTANT LowerOutSize     : INTEGER := MINIMUM( OutSize , LowerInSize );
  CONSTANT UpperOutSize     : INTEGER := MINIMUM( OutSize , UpperInSize );

  CONSTANT LowerSortLatency : INTEGER := LatencyOfBitonicSort( LowerInSize , LowerOutSize );
  CONSTANT UpperSortLatency : INTEGER := LatencyOfBitonicSort( UpperInSize , UpperOutSize );

  CONSTANT PipeLength       : INTEGER := MAXIMUM( UpperSortLatency-LowerSortLatency , 2 );

  TYPE tOffsetPipe IS ARRAY( NATURAL RANGE <> ) OF tJetInPhi( 0 TO LowerOutSize + UpperOutSize-1 );
  SIGNAL T1 : tOffsetPipe( PipeLength DOWNTO 0 )              := ( OTHERS => ( OTHERS => cEmptyJet ) );
  SIGNAL T2 : tJetInPhi( 0 TO LowerOutSize + UpperOutSize-1 ) := ( OTHERS => cEmptyJet );
  SIGNAL T3 : tJetInPhi( 0 TO LowerOutSize + UpperOutSize-1 ) := ( OTHERS => cEmptyJet );

  COMPONENT BitonicSortJets IS
    GENERIC(
      InSize  : INTEGER := 0;
      OutSize : INTEGER := 0;
      D       : BOOLEAN := false -- sort direction
    );
    PORT(
      C : IN STD_LOGIC ; -- clock
      I : IN tJetInPhi( 0 TO InSize-1 )   := ( OTHERS => cEmptyJet );
      O : OUT tJetInPhi( 0 TO OutSize-1 ) := ( OTHERS => cEmptyJet )
    );
  END COMPONENT BitonicSortJets;

  COMPONENT BitonicMergeJets IS
    GENERIC(
      Size : INTEGER := 0;
      D    : BOOLEAN := false -- sort direction
    );
    PORT(
      C : IN STD_LOGIC ; -- clock
      I : IN tJetInPhi( 0 TO Size-1 )  := ( OTHERS => cEmptyJet );
      O : OUT tJetInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyJet )
    );
  END COMPONENT BitonicMergeJets;

BEGIN

-- If size is 1 , just pass through
  G1 : IF InSize <= 1 GENERATE
    O            <= I;
  END GENERATE G1;

-- If size is greater than 1 , sort lower "half" and upper "half" separately and then merge
  G2   : IF InSize > 1 GENERATE

    S1 : BitonicSortJets
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

    S2 : BitonicSortJets
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

    M : BitonicMergeJets
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

END ARCHITECTURE behavioral ; -- BitonicSortJets
-- ----------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity BitonicMergeJets
--! @details Detailed description
ARCHITECTURE behavioral OF BitonicMergeJets IS
  SIGNAL T1                  : tJetInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyJet );
  SIGNAL T2                  : tJetInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyJet );

  CONSTANT LowerSize         : INTEGER                  := PowerOf2LessThan( Size ) ; -- LowerSize >= Size / 2
  CONSTANT UpperSize         : INTEGER                  := Size - LowerSize ; -- UpperSize < LowerSize

  CONSTANT LowerMergeLatency : INTEGER                  := LatencyOfBitonicMerge( LowerSize );
  CONSTANT UpperMergeLatency : INTEGER                  := LatencyOfBitonicMerge( UpperSize );

  CONSTANT PipeLength        : INTEGER                  := MAXIMUM( LowerMergeLatency-UpperMergeLatency , 2 );

  TYPE tOffsetPipe IS ARRAY( NATURAL RANGE <> ) OF tJetInPhi( LowerSize TO Size-1 );
  SIGNAL T3 : tOffsetPipe( PipeLength DOWNTO 0 ) := ( OTHERS => ( OTHERS => cEmptyJet ) );

  COMPONENT BitonicMergeJets IS
    GENERIC(
      Size : INTEGER := 0;
      D    : BOOLEAN := false -- sort direction
    );
    PORT(
      C : IN STD_LOGIC ; -- clock
      I : IN tJetInPhi( 0 TO Size-1 )  := ( OTHERS => cEmptyJet );
      O : OUT tJetInPhi( 0 TO Size-1 ) := ( OTHERS => cEmptyJet )
    );
  END COMPONENT BitonicMergeJets;

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

    M1 : BitonicMergeJets
      GENERIC MAP(
        Size => LowerSize ,
        D    => D
      )
      PORT MAP(
        C => C ,
        I => T1( 0 TO LowerSize-1 ) ,
        O => T2( 0 TO LowerSize-1 )
      );

    M2 : BitonicMergeJets
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

END ARCHITECTURE behavioral ; -- BitonicMergeJets
-- ----------------------------------------------------------------------------------------------------



-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity JetSortAccumulator
--! @details Detailed description
ARCHITECTURE behavioral OF JetSortAccumulator IS
-- I : IN tJetInPhi( Size-1 DOWNTO 0 ) := ( OTHERS => cEmptyJet );
-- O0 : OUT tJet := cEmptyJet;
-- O1 : OUT tJetInPhi( Size-1 DOWNTO 0 ) := ( OTHERS => cEmptyJet )

  SIGNAL T0 : tJetInPhi( 0 TO SIZE ) := ( OTHERS => cEmptyJet );
  TYPE tComparisonArray1d IS ARRAY( 0 TO SIZE ) OF BOOLEAN;
  SIGNAL C0 : tComparisonArray1d := ( OTHERS => FALSE );

  TYPE tOffsetPipe IS ARRAY( Delay DOWNTO 0 ) OF tJet;
  SIGNAL T1 : tOffsetPipe := ( OTHERS => cEmptyJet );

BEGIN

  PROCESS( C )
--VARIABLE x : INTEGER RANGE 0 TO Size := 0;
  BEGIN

    IF( FALLING_EDGE( C ) ) THEN
      L1 : FOR x IN 0 TO Size-1 LOOP
        C0( x ) <= I( x ) > T0( 0 ) ; -- previous accumulation is less than new list entry @ x
      END LOOP;
    END IF;

    IF( RISING_EDGE( C ) ) THEN
      IF NOT I( 0 ) .DataValid THEN
        T0 <= ( OTHERS => cEmptyJet );
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

END ARCHITECTURE behavioral ; -- JetSortAccumulator
-- ----------------------------------------------------------------------------------------------------




-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity AccumulatingBitonicSortJets
--! @details Detailed description
ARCHITECTURE behavioral OF AccumulatingBitonicSortJets IS
  TYPE tSortPipe IS ARRAY( 0 TO Size ) OF tJetInPhi( 0 TO Size - 1 );

  SIGNAL K  : tSortPipe                             := ( OTHERS => ( OTHERS => cEmptyJet ) );
  SIGNAL DV : STD_LOGIC_VECTOR( Size + 1 DOWNTO 0 ) := ( OTHERS => '0' );
BEGIN

  K( 0 ) <= I WHEN RISING_EDGE( C );

  G1                           : FOR x IN 0 TO Size-1 GENERATE
    JetSortAccumulatorInstance : ENTITY work.JetSortAccumulator
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


END ARCHITECTURE behavioral ; -- AccumulatingBitonicSortJets
