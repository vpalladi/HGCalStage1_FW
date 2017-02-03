
-- ------------------------------------------------------------------------------------------------------------------
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

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "jet" helper functions
USE work.jet_functions.ALL;

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "cluster" helper functions
USE work.cluster_functions.ALL;


--! @brief An entity providing a IsolationRegion9x6Former
--! @details Detailed description
ENTITY IsolationRegion9x6Former IS
  GENERIC(
    strip9x3PipeOffset     : INTEGER := 0 ; -- Offset for the strip 9x3 Pipe
    veto9x3PipeOffset      : INTEGER := 0 ; -- Offset for the strip 9x3 Pipe
    ProtoclusterPipeOffset : INTEGER := 0
  );
  PORT(
    clk                 : IN STD_LOGIC := '0' ;    --! The algorithm clock
    strip9x3PipeIn      : IN tJetPipe ;            --! A pipe of tJet objects bringing in the strip9x3's
    egammaVetoPipeIn    : IN tComparisonPipe ;     --! A pipe of tComparison objects bringing in the egammaVeto's
    ProtoClusterPipeIn  : IN tClusterPipe ;        --! A pipe of tCluster objects bringing in the ProtoCluster's
    Isolation9x6PipeOut : OUT tIsolationRegionPipe --! A pipe of tIsolationRegion objects passing out the Isolation9x6's
  );
END ENTITY IsolationRegion9x6Former;


--! @brief Architecture definition for entity IsolationRegion9x6Former
--! @details Detailed description
ARCHITECTURE behavioral OF IsolationRegion9x6Former IS

  TYPE tSumInputs IS RECORD
    West : tIsolationRegion;
    East : tIsolationRegion;
  END RECORD tSumInputs;

  TYPE tSumInputInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF tSumInputs ; -- Two halves in eta
  TYPE tSumInputInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tSumInputInPhi ; -- Two halves in eta
  TYPE tSumInputsPerSite IS ARRAY( 3 DOWNTO 0 ) OF tSumInputInEtaPhi ; -- Two halves in eta

  SIGNAL WestSumInput , EastSumInput   : tSumInputsPerSite        := ( OTHERS => ( OTHERS => ( OTHERS => ( OTHERS => cEmptyIsolationRegion ) ) ) );
  SIGNAL WestSumInput2 , EastSumInput2 : tSumInputInEtaPhi        := ( OTHERS => ( OTHERS => ( OTHERS => cEmptyIsolationRegion ) ) );
  SIGNAL SumInput                      : tSumInputInEtaPhi        := ( OTHERS => ( OTHERS => ( OTHERS => cEmptyIsolationRegion ) ) );

  SIGNAL IsolationRegion               : tIsolationRegionInEtaPhi := cEmptyIsolationRegionInEtaPhi;

BEGIN

  phi    : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    site : FOR k IN 3 DOWNTO 0 GENERATE

      WestSumInput( k )( 0 )( i ) .West <= cEmptyIsolationRegion WHEN( cIncludeNullState AND NOT strip9x3PipeIn( strip9x3PipeOffset + 2 )( 0 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset + 1 )( OPP_ETA( 0 ) )( MOD_PHI( ( 4 * i ) + k ) ) ) WHEN NOT strip9x3PipeIn( strip9x3PipeOffset + 3 )( 0 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset + 3 )( OPP_ETA( 0 ) )( MOD_PHI( ( 4 * i ) + k ) ) ) WHEN NOT strip9x3PipeIn( strip9x3PipeOffset + 4 )( 0 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset + 4 )( 0 )( MOD_PHI( ( 4 * i ) + k ) ) );

      WestSumInput( k )( 0 )( i ) .East <= cEmptyIsolationRegion WHEN( cIncludeNullState AND NOT strip9x3PipeIn( strip9x3PipeOffset + 2 )( 0 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset + 1 )( 0 )( MOD_PHI( ( 4 * i ) + k ) ) );


      EastSumInput( k )( 0 )( i ) .West <= cEmptyIsolationRegion WHEN( cIncludeNullState AND NOT strip9x3PipeIn( strip9x3PipeOffset + 2 )( 0 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset + 2 )( OPP_ETA( 0 ) )( MOD_PHI( ( 4 * i ) + k ) ) ) WHEN NOT strip9x3PipeIn( strip9x3PipeOffset + 3 )( 0 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset + 3 )( 0 )( MOD_PHI( ( 4 * i ) + k ) ) );

      EastSumInput( k )( 0 )( i ) .East <= cEmptyIsolationRegion WHEN( cIncludeNullState AND NOT strip9x3PipeIn( strip9x3PipeOffset + 2 )( 0 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset )( 0 )( MOD_PHI( ( 4 * i ) + k ) ) );


      EastSumInput( k )( 1 )( i ) .West <= cEmptyIsolationRegion WHEN( cIncludeNullState AND NOT strip9x3PipeIn( strip9x3PipeOffset + 2 )( 1 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset + 1 )( 1 )( MOD_PHI( ( 4 * i ) + k ) ) );

      EastSumInput( k )( 1 )( i ) .East <= cEmptyIsolationRegion WHEN( cIncludeNullState AND NOT strip9x3PipeIn( strip9x3PipeOffset + 2 )( 1 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset + 1 )( OPP_ETA( 1 ) )( MOD_PHI( ( 4 * i ) + k ) ) ) WHEN NOT strip9x3PipeIn( strip9x3PipeOffset + 3 )( 1 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset + 3 )( OPP_ETA( 1 ) )( MOD_PHI( ( 4 * i ) + k ) ) ) WHEN NOT strip9x3PipeIn( strip9x3PipeOffset + 4 )( 1 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset + 4 )( 1 )( MOD_PHI( ( 4 * i ) + k ) ) );


      WestSumInput( k )( 1 )( i ) .West <= cEmptyIsolationRegion WHEN( cIncludeNullState AND NOT strip9x3PipeIn( strip9x3PipeOffset + 2 )( 1 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset )( 1 )( MOD_PHI( ( 4 * i ) + k ) ) );

      WestSumInput( k )( 1 )( i ) .East <= cEmptyIsolationRegion WHEN( cIncludeNullState AND NOT strip9x3PipeIn( strip9x3PipeOffset + 2 )( 1 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid ) -- [for frame 0 , an invalid object]
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset + 2 )( OPP_ETA( 1 ) )( MOD_PHI( ( 4 * i ) + k ) ) ) WHEN NOT strip9x3PipeIn( strip9x3PipeOffset + 3 )( 1 )( MOD_PHI( ( 4 * i ) + k ) ) .DataValid
                                  ELSE ToIsolationRegion( strip9x3PipeIn( strip9x3PipeOffset + 3 )( 1 )( MOD_PHI( ( 4 * i ) + k ) ) );
    END GENERATE site;
  END GENERATE phi;


  phi2   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta2 : FOR j IN 0 TO cRegionInEta-1 GENERATE
      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN

          IF( NOT EastSumInput( 0 )( j )( i ) .East.DataValid OR NOT WestSumInput( 0 )( j )( i ) .West.DataValid ) THEN -- OR NOT egammaVetoPipeIn( veto9x3PipeOffset )( j )( ( 4 * i ) + 0 ) .DataValid ) THEN -- + 1
            WestSumInput2( j )( i ) <= ( OTHERS => cEmptyIsolationRegion );
            EastSumInput2( j )( i ) <= ( OTHERS => cEmptyIsolationRegion );
          ELSE
               IF( NOT egammaVetoPipeIn( veto9x3PipeOffset )( j )( ( 4 * i ) + 0 ) .Data ) THEN
              WestSumInput2( j )( i ) <= WestSumInput( 0 )( j )( i );
              EastSumInput2( j )( i ) <= EastSumInput( 0 )( j )( i );
            ELSIF( NOT egammaVetoPipeIn( veto9x3PipeOffset )( j )( ( 4 * i ) + 1 ) .Data ) THEN
              WestSumInput2( j )( i ) <= WestSumInput( 1 )( j )( i );
              EastSumInput2( j )( i ) <= EastSumInput( 1 )( j )( i );
            ELSIF( NOT egammaVetoPipeIn( veto9x3PipeOffset )( j )( ( 4 * i ) + 2 ) .Data ) THEN
              WestSumInput2( j )( i ) <= WestSumInput( 2 )( j )( i );
              EastSumInput2( j )( i ) <= EastSumInput( 2 )( j )( i );
            ELSIF( NOT egammaVetoPipeIn( veto9x3PipeOffset )( j )( ( 4 * i ) + 3 ) .Data ) THEN
              WestSumInput2( j )( i ) <= WestSumInput( 3 )( j )( i );
              EastSumInput2( j )( i ) <= EastSumInput( 3 )( j )( i );
            ELSE
              WestSumInput2( j )( i )                 <= ( OTHERS => cEmptyIsolationRegion );
              WestSumInput2( j )( i ) .West.DataValid <= TRUE;
              WestSumInput2( j )( i ) .East.DataValid <= TRUE;

              EastSumInput2( j )( i )                 <= ( OTHERS => cEmptyIsolationRegion );
              EastSumInput2( j )( i ) .West.DataValid <= TRUE;
              EastSumInput2( j )( i ) .East.DataValid <= TRUE;
            END IF;
          END IF;

        END IF;
      END PROCESS;
    END GENERATE eta2;
  END GENERATE phi2;


  phi3   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta3 : FOR j IN 0 TO cRegionInEta-1 GENERATE
      SumInput( j )( i ) <= WestSumInput2( j )( i ) WHEN ProtoClusterPipeIn( ProtoclusterPipeOffset )( j )( i ) .LateralPosition = west
                       ELSE EastSumInput2( j )( i );

      SumInstance : ENTITY work.IsolationSum2
      PORT MAP(
        Clk          => Clk ,
        IsolationIn1 => SumInput( j )( i ) .East ,
        IsolationIn2 => SumInput( j )( i ) .West ,
        IsolationOut => IsolationRegion( j )( i )
      );

    END GENERATE eta3;
  END GENERATE phi3;

  IsolationPipeInstance : ENTITY work.IsolationPipe
  PORT MAP(
    clk           => clk ,
    IsolationIn   => IsolationRegion ,
    IsolationPipe => Isolation9x6PipeOut
  );

END ARCHITECTURE behavioral;
-- ------------------------------------------------------------------------------------------------------------------



-- ------------------------------------------------------------------------------------------------------------------
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

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "cluster" helper functions
USE work.cluster_functions.ALL;


--! @brief An entity providing a IsolationRegion5x2Former
--! @details Detailed description
ENTITY IsolationRegion5x2Former IS
  GENERIC(
    ProtoClusterPipeOffset : INTEGER := 0
  );
  PORT(
    clk                 : IN STD_LOGIC := '0' ;    --! The algorithm clock
    ProtoClusterPipeIn  : IN tClusterPipe ;        --! A pipe of tCluster objects bringing in the ProtoCluster's
    ClusterInputPipeIn  : IN tClusterInputPipe ;   --! A pipe of tClusterInput objects bringing in the ClusterInput's
    Isolation5x2PipeOut : OUT tIsolationRegionPipe --! A pipe of tIsolationRegion objects passing out the Isolation5x2's
  );
END ENTITY IsolationRegion5x2Former;


--! @brief Architecture definition for entity IsolationRegion5x2Former
--! @details Detailed description
ARCHITECTURE behavioral OF IsolationRegion5x2Former IS

  TYPE tSumInputs IS RECORD
    R2N      : tIsolationRegion;
    R1N      : tIsolationRegion;
    Centre   : tIsolationRegion;
    R1S      : tIsolationRegion;
    R2S      : tIsolationRegion;

    R2NWorNE : tIsolationRegion;
    R1NWorNE : tIsolationRegion;
    R1WorE   : tIsolationRegion;
    R1SWorSE : tIsolationRegion;
    R2SWorSE : tIsolationRegion;
  END RECORD tSumInputs;

  TYPE tSumInputInPhi    IS ARRAY( 0 TO( cTowerInPhi / 4 ) -1 ) OF tSumInputs ; -- Two halves in eta
  TYPE tSumInputInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tSumInputInPhi ; -- Two halves in eta

  SIGNAL SumInput , SumInput2 , SumInput3 : tSumInputInEtaPhi        := ( OTHERS => ( OTHERS => ( OTHERS => cEmptyIsolationRegion ) ) );

  SIGNAL IsolationRegion                  : tIsolationRegionInEtaPhi := cEmptyIsolationRegionInEtaPhi;

BEGIN

  phi : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    SumInput( 0 )( i ) .R2N      <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R2N , false );
    SumInput( 0 )( i ) .R1N      <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R1N , true );
    SumInput( 0 )( i ) .Centre   <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .Centre , true );
    SumInput( 0 )( i ) .R1S      <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R1S , false );
    SumInput( 0 )( i ) .R2S      <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R2S , false );

    SumInput( 0 )( i ) .R2NWorNE <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R2NW , false ) WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( 0 )( i ) .LateralPosition = WEST
                              ELSE ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R2NE , false );
    SumInput( 0 )( i ) .R1NWorNE <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R1NW , false ) WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( 0 )( i ) .LateralPosition = WEST
                              ELSE ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R1NE , false );
    SumInput( 0 )( i ) .R1WorE <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R1W , false ) WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( 0 )( i ) .LateralPosition = WEST
                              ELSE ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R1E , false );
    SumInput( 0 )( i ) .R1SWorSE <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R1SW , false ) WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( 0 )( i ) .LateralPosition = WEST
                              ELSE ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R1SE , false );
    SumInput( 0 )( i ) .R2SWorSE <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R2SW , false ) WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( 0 )( i ) .LateralPosition = WEST
                              ELSE ToIsolationRegion( ClusterInputPipeIn( 0 )( 0 )( i ) .R2SE , false );

    SumInput( 1 )( i ) .R2N      <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R2N , false );
    SumInput( 1 )( i ) .R1N      <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R1N , false );
    SumInput( 1 )( i ) .Centre   <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .Centre , true );
    SumInput( 1 )( i ) .R1S      <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R1S , true );
    SumInput( 1 )( i ) .R2S      <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R2S , false );

    SumInput( 1 )( i ) .R2NWorNE <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R2NW , false ) WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( 1 )( i ) .LateralPosition = WEST
                              ELSE ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R2NE , false );
    SumInput( 1 )( i ) .R1NWorNE <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R1NW , false ) WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( 1 )( i ) .LateralPosition = WEST
                              ELSE ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R1NE , false );
    SumInput( 1 )( i ) .R1WorE <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R1W , false ) WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( 1 )( i ) .LateralPosition = WEST
                              ELSE ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R1E , false );
    SumInput( 1 )( i ) .R1SWorSE <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R1SW , false ) WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( 1 )( i ) .LateralPosition = WEST
                              ELSE ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R1SE , false );
    SumInput( 1 )( i ) .R2SWorSE <= ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R2SW , false ) WHEN ProtoClusterPipeIn( ProtoClusterPipeOffset )( 1 )( i ) .LateralPosition = WEST
                              ELSE ToIsolationRegion( ClusterInputPipeIn( 0 )( 1 )( i ) .R2SE , false );

  END GENERATE phi;

  phi2                      : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta2                    : FOR j IN 0 TO cRegionInEta-1 GENERATE

      CentralSum3x1Instance : ENTITY work.IsolationSum
      PORT MAP(
        Clk          => Clk ,
        IsolationIn1 => SumInput( j )( i ) .R1N ,
        IsolationIn2 => SumInput( j )( i ) .Centre ,
        IsolationIn3 => SumInput( j )( i ) .R1S ,
        IsolationOut => SumInput2( j )( i ) .Centre
      );

      SideSum3x1Instance : ENTITY work.IsolationSum
      PORT MAP(
        Clk          => Clk ,
        IsolationIn1 => SumInput( j )( i ) .R1NWorNE ,
        IsolationIn2 => SumInput( j )( i ) .R1WorE ,
        IsolationIn3 => SumInput( j )( i ) .R1SWorSE ,
        IsolationOut => SumInput2( j )( i ) .R1WorE
      );

      SumInput2( j )( i ) .R2N      <= SumInput( j )( i ) .R2N WHEN RISING_EDGE( clk );
      SumInput2( j )( i ) .R2S      <= SumInput( j )( i ) .R2S WHEN RISING_EDGE( clk );
      SumInput2( j )( i ) .R2NWorNE <= SumInput( j )( i ) .R2NWorNE WHEN RISING_EDGE( clk );
      SumInput2( j )( i ) .R2SWorSE <= SumInput( j )( i ) .R2SWorSE WHEN RISING_EDGE( clk );


      CentralSum5x1Instance : ENTITY work.IsolationSum
      PORT MAP(
        Clk          => Clk ,
        IsolationIn1 => SumInput2( j )( i ) .R2N ,
        IsolationIn2 => SumInput2( j )( i ) .Centre ,
        IsolationIn3 => SumInput2( j )( i ) .R2S ,
        IsolationOut => SumInput3( j )( i ) .Centre
      );

      SideSum5x1Instance : ENTITY work.IsolationSum
      PORT MAP(
        Clk          => Clk ,
        IsolationIn1 => SumInput2( j )( i ) .R2NWorNE ,
        IsolationIn2 => SumInput2( j )( i ) .R1WorE ,
        IsolationIn3 => SumInput2( j )( i ) .R2SWorSE ,
        IsolationOut => SumInput3( j )( i ) .R1WorE
      );

      FinalSum5x2Instance : ENTITY work.IsolationSum2
      PORT MAP(
        Clk          => Clk ,
        IsolationIn1 => SumInput3( j )( i ) .Centre ,
        IsolationIn2 => SumInput3( j )( i ) .R1WorE ,
        IsolationOut => IsolationRegion( j )( i )
      );
    END GENERATE eta2;
  END GENERATE phi2;


  IsolationPipeInstance : ENTITY work.IsolationPipe
  PORT MAP(
    clk           => clk ,
    IsolationIn   => IsolationRegion ,
    IsolationPipe => Isolation5x2PipeOut
  );

END ARCHITECTURE behavioral;
-- ------------------------------------------------------------------------------------------------------------------




-- ------------------------------------------------------------------------------------------------------------------
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

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "cluster" helper functions
USE work.cluster_functions.ALL;


--! @brief An entity providing a EgammaIsolationRegionFormer
--! @details Detailed description
ENTITY EgammaIsolationRegionFormer IS
  PORT(
    clk                : IN STD_LOGIC := '0' ;     --! The algorithm clock
    Isolation9x6PipeIn : IN tIsolationRegionPipe ; --! A pipe of tIsolationRegion objects bringing in the Isolation9x6's
    Isolation5x2PipeIn : IN tIsolationRegionPipe ; --! A pipe of tIsolationRegion objects bringing in the Isolation5x2's
    IsolationPipeOut   : OUT tIsolationRegionPipe  --! A pipe of tIsolationRegion objects passing out the Isolation's
  );
END ENTITY EgammaIsolationRegionFormer;


--! @brief Architecture definition for entity EgammaIsolationRegionFormer
--! @details Detailed description
ARCHITECTURE behavioral OF EgammaIsolationRegionFormer IS
  SIGNAL IsolationRegion : tIsolationRegionInEtaPhi := cEmptyIsolationRegionInEtaPhi;
BEGIN

  phi                                   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta                                 : FOR j IN 0 TO cRegionInEta-1 GENERATE

      IsolationFinalSubtractionInstance : ENTITY work.IsolationFinalSubtraction
      PORT MAP(
        Clk          => Clk ,
        Sum9x6In     => Isolation9x6PipeIn( 0 )( j )( i ) ,
        Sum5x2In     => Isolation5x2PipeIn( 0 )( j )( i ) ,
        IsolationOut => IsolationRegion( j )( i )
      );
    END GENERATE eta;
  END GENERATE phi;

  IsolationPipeInstance : ENTITY work.IsolationPipe
  PORT MAP(
    clk           => clk ,
    IsolationIn   => IsolationRegion ,
    IsolationPipe => IsolationPipeOut
  );

END ARCHITECTURE behavioral;
-- ------------------------------------------------------------------------------------------------------------------




-- ------------------------------------------------------------------------------------------------------------------
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

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;
--! Using the Calo-L2 "cluster" helper functions
USE work.cluster_functions.ALL;


--! @brief An entity providing a TauIsolationRegionFormer
--! @details Detailed description
ENTITY TauIsolationRegionFormer IS
  PORT(
    clk                : IN STD_LOGIC := '0' ;     --! The algorithm clock
    Isolation9x6PipeIn : IN tIsolationRegionPipe ; --! A pipe of tIsolationRegion objects bringing in the Isolation9x6's
    FinalTauPipeIn     : IN tClusterPipe ;         --! A pipe of tCluster objects bringing in the FinalTau's
    IsolationPipeOut   : OUT tIsolationRegionPipe  --! A pipe of tIsolationRegion objects passing out the Isolation's
  );
END ENTITY TauIsolationRegionFormer;


--! @brief Architecture definition for entity TauIsolationRegionFormer
--! @details Detailed description
ARCHITECTURE behavioral OF TauIsolationRegionFormer IS
  SIGNAL TauRegion       : tIsolationRegionInEtaPhi := cEmptyIsolationRegionInEtaPhi;
  SIGNAL IsolationRegion : tIsolationRegionInEtaPhi := cEmptyIsolationRegionInEtaPhi;
BEGIN

  phi   : FOR i IN 0 TO( cTowerInPhi / 4 ) -1 GENERATE
    eta : FOR j IN 0 TO cRegionInEta-1 GENERATE

      TauRegion( j )( i ) .Energy( 12 DOWNTO 0 ) <= FinalTauPipeIn( 0 )( j )( i ) .Energy( 12 DOWNTO 0 );
      TauRegion( j )( i ) .DataValid             <= FinalTauPipeIn( 0 )( j )( i ) .DataValid;

      IsolationFinalSubtractionInstance : ENTITY work.IsolationFinalSubtraction
      PORT MAP(
        Clk          => Clk ,
        Sum9x6In     => Isolation9x6PipeIn( 1 )( j )( i ) ,
        Sum5x2In     => TauRegion( j )( i ) ,
        IsolationOut => IsolationRegion( j )( i )
      );
    END GENERATE eta;
  END GENERATE phi;

  IsolationPipeInstance : ENTITY work.IsolationPipe
  PORT MAP(
    clk           => clk ,
    IsolationIn   => IsolationRegion ,
    IsolationPipe => IsolationPipeOut
  );

END ARCHITECTURE behavioral;
