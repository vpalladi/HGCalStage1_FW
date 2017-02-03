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

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;


--! @brief An entity providing a LinksOut
--! @details Detailed description
ENTITY LinksOut IS
  GENERIC(
    EtMetOffset  : INTEGER := 0;
    HtMhtOffset  : INTEGER := 0;
    JetOffset    : INTEGER := 0;
    EgammaOffset : INTEGER := 0;
    TauOffset    : INTEGER := 0;
    AuxOffset    : tPackedLinkOffsets
  );
  PORT(
    clk                  : IN STD_LOGIC := '0' ; --! The algorithm clock
    PackedETandMETPipeIn : IN tPackedLinkPipe ;  --! A pipe of tPackedLink objects bringing in the PackedETandMET's
    PackedHTandMHTPipeIn : IN tPackedLinkPipe ;  --! A pipe of tPackedLink objects bringing in the PackedHTandMHT's
    PackedJetPipeIn      : IN tPackedLinkPipe ;  --! A pipe of tPackedLink objects bringing in the PackedJet's
    PackedEgammaPipeIn   : IN tPackedLinkPipe ;  --! A pipe of tPackedLink objects bringing in the PackedEgamma's
    PackedTauPipeIn      : IN tPackedLinkPipe ;  --! A pipe of tPackedLink objects bringing in the PackedTau's
    PackedAuxPipeIn      : IN tPackedLinkPipe ;  --! A pipe of tPackedLink objects bringing in the PackedAux's
    linksOut             : OUT ldata( cNumberOfLinksIn-1 DOWNTO 0 ) := ( OTHERS => LWORD_NULL )
  );
END LinksOut;

--! @brief Architecture definition for entity LinksOut
--! @details Detailed description
ARCHITECTURE behavioral OF LinksOut IS
  SIGNAL links                                   : ldata( cNumberOfLinksIn-1 DOWNTO 0 ) := ( OTHERS => ( ( OTHERS => '0' ) , '0' , '0' , '1' ) );
  SIGNAL PackedETandMETPipe , PackedHTandMHTPipe : tPackedLinkPipe( 0 DOWNTO 0 )        := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL PackedEgammaPipe1 , PackedEgammaPipe2   : tPackedLinkPipe( 0 DOWNTO 0 )        := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL PackedTauPipe1 , PackedTauPipe2         : tPackedLinkPipe( 0 DOWNTO 0 )        := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL PackedJetPipe1 , PackedJetPipe2         : tPackedLinkPipe( 0 DOWNTO 0 )        := ( OTHERS => cEmptyPackedLinkInCandidates );
  SIGNAL PackedAuxPipe                           : tPackedLinkPipe( 0 DOWNTO 0 )        := ( OTHERS => cEmptyPackedLinkInCandidates );

  TYPE tLinkMapping IS ARRAY( 0 TO 5 ) OF INTEGER RANGE 0 TO cNumberOfLinksIn-1;
  CONSTANT LinkMapping    : tLinkMapping                  := ( 61 , 60 , 63 , 62 , 65 , 64 );

  CONSTANT NumberOfFrames : INTEGER                       := 11;

  CONSTANT EtMetOffsets1  : tPackedLinkOffsets( 0 TO 5 )  := ( OTHERS => ( EtMetOffset ) );
  CONSTANT HtMhtOffsets1  : tPackedLinkOffsets( 0 TO 5 )  := ( OTHERS => ( HtMhtOffset ) );
  CONSTANT JetOffsets1    : tPackedLinkOffsets( 0 TO 11 ) := ( OTHERS => ( JetOffset ) );
  CONSTANT JetOffsets2    : tPackedLinkOffsets( 0 TO 11 ) := ( OTHERS => ( JetOffset + 1 ) );
  CONSTANT EgammaOffsets1 : tPackedLinkOffsets( 0 TO 11 ) := ( OTHERS => ( EgammaOffset ) );
  CONSTANT EgammaOffsets2 : tPackedLinkOffsets( 0 TO 11 ) := ( OTHERS => ( EgammaOffset + 1 ) );
  CONSTANT TauOffsets1    : tPackedLinkOffsets( 0 TO 11 ) := ( OTHERS => ( TauOffset ) );
  CONSTANT TauOffsets2    : tPackedLinkOffsets( 0 TO 11 ) := ( OTHERS => ( TauOffset + 1 ) );

BEGIN

  ETandMETfifoInstance : ENTITY work.PackedLinkFifo
  GENERIC MAP(
    Offsets => EtMetOffsets1
  )
  PORT MAP(
    clk               => clk ,
    PackedLinkPipeIn  => PackedETandMETPipeIn ,
    PackedLinkPipeOut => PackedETandMETPipe
  );

  HTandMHTfifoInstance : ENTITY work.PackedLinkFifo
  GENERIC MAP(
    Offsets => HtMhtOffsets1
  )
  PORT MAP(
    clk               => clk ,
    PackedLinkPipeIn  => PackedHTandMHTPipeIn ,
    PackedLinkPipeOut => PackedHTandMHTPipe
  );

  JetFifoInstance1 : ENTITY work.PackedLinkFifo
  GENERIC MAP(
    Offsets => JetOffsets1
  )
  PORT MAP(
    clk               => clk ,
    PackedLinkPipeIn  => PackedJetPipeIn ,
    PackedLinkPipeOut => PackedJetPipe1
  );

  JetFifoInstance2 : ENTITY work.PackedLinkFifo
  GENERIC MAP(
    Offsets => JetOffsets2
  )
  PORT MAP(
    clk               => clk ,
    PackedLinkPipeIn  => PackedJetPipeIn ,
    PackedLinkPipeOut => PackedJetPipe2
  );

  EgammaFifoInstance1 : ENTITY work.PackedLinkFifo
  GENERIC MAP(
    Offsets => EgammaOffsets1
  )
  PORT MAP(
    clk               => clk ,
    PackedLinkPipeIn  => PackedEgammaPipeIn ,
    PackedLinkPipeOut => PackedEgammaPipe1
  );

  EgammaFifoInstance2 : ENTITY work.PackedLinkFifo
  GENERIC MAP(
    Offsets => EgammaOffsets2
  )
  PORT MAP(
    clk               => clk ,
    PackedLinkPipeIn  => PackedEgammaPipeIn ,
    PackedLinkPipeOut => PackedEgammaPipe2
  );

  TauFifoInstance1 : ENTITY work.PackedLinkFifo
  GENERIC MAP(
    Offsets => TauOffsets1
  )
  PORT MAP(
    clk               => clk ,
    PackedLinkPipeIn  => PackedTauPipeIn ,
    PackedLinkPipeOut => PackedTauPipe1
  );

  TauFifoInstance2 : ENTITY work.PackedLinkFifo
  GENERIC MAP(
    Offsets => TauOffsets2
  )
  PORT MAP(
    clk               => clk ,
    PackedLinkPipeIn  => PackedTauPipeIn ,
    PackedLinkPipeOut => PackedTauPipe2
  );

  AuxFifoInstance : ENTITY work.PackedLinkFifo
  GENERIC MAP(
    Offsets => AuxOffset
  )
  PORT MAP(
    clk               => clk ,
    PackedLinkPipeIn  => PackedAuxPipeIn ,
    PackedLinkPipeOut => PackedAuxPipe
  );


  prc                : PROCESS( clk )
    VARIABLE COUNTER : INTEGER RANGE 0 TO NumberOfFrames := NumberOfFrames;
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN

      IF( PackedETandMETPipe( 0 )( 0 ) .DataValid AND counter = NumberOfFrames ) THEN
        COUNTER := 0;
      END IF;

      FOR i IN 0 TO 2 LOOP

        links( LinkMapping( i ) ) .data      <= ( OTHERS => '0' );
        links( LinkMapping( i ) ) .valid     <= '0';

        links( LinkMapping( i + 3 ) ) .data  <= ( OTHERS => '0' );
        links( LinkMapping( i + 3 ) ) .valid <= '0';

        CASE COUNTER IS
          WHEN 0 | 1 =>
            links( LinkMapping( i ) ) .data      <= PackedETandMETPipe( 0 )( i ) .Data;
            links( LinkMapping( i ) ) .valid     <= TO_STD_LOGIC( PackedETandMETPipe( 0 )( i ) .DataValid );

            links( LinkMapping( i + 3 ) ) .data  <= PackedETandMETPipe( 0 )( i + 3 ) .Data;
            links( LinkMapping( i + 3 ) ) .valid <= TO_STD_LOGIC( PackedETandMETPipe( 0 )( i + 3 ) .DataValid );

          WHEN 2 | 3 =>
            links( LinkMapping( i ) ) .data      <= PackedHTandMHTPipe( 0 )( i ) .Data;
            links( LinkMapping( i ) ) .valid     <= TO_STD_LOGIC( PackedHTandMHTPipe( 0 )( i ) .DataValid );

            links( LinkMapping( i + 3 ) ) .data  <= PackedHTandMHTPipe( 0 )( i + 3 ) .Data;
            links( LinkMapping( i + 3 ) ) .valid <= TO_STD_LOGIC( PackedHTandMHTPipe( 0 )( i + 3 ) .DataValid );

          WHEN 4 =>
            links( LinkMapping( i ) ) .data      <= PackedEgammaPipe1( 0 )( i ) .Data;
            links( LinkMapping( i ) ) .valid     <= TO_STD_LOGIC( PackedEgammaPipe1( 0 )( i ) .DataValid );

            links( LinkMapping( i + 3 ) ) .data  <= PackedEgammaPipe1( 0 )( i + 6 ) .Data;
            links( LinkMapping( i + 3 ) ) .valid <= TO_STD_LOGIC( PackedEgammaPipe1( 0 )( i + 6 ) .DataValid );

          WHEN 5 =>
            links( LinkMapping( i ) ) .data      <= PackedEgammaPipe2( 0 )( i + 3 ) .Data;
            links( LinkMapping( i ) ) .valid     <= TO_STD_LOGIC( PackedEgammaPipe2( 0 )( i + 3 ) .DataValid );

            links( LinkMapping( i + 3 ) ) .data  <= PackedEgammaPipe2( 0 )( i + 9 ) .Data;
            links( LinkMapping( i + 3 ) ) .valid <= TO_STD_LOGIC( PackedEgammaPipe2( 0 )( i + 9 ) .DataValid );

          WHEN 6 =>
            links( LinkMapping( i ) ) .data      <= PackedTauPipe1( 0 )( i ) .Data;
            links( LinkMapping( i ) ) .valid     <= TO_STD_LOGIC( PackedTauPipe1( 0 )( i ) .DataValid );

            links( LinkMapping( i + 3 ) ) .data  <= PackedTauPipe1( 0 )( i + 6 ) .Data;
            links( LinkMapping( i + 3 ) ) .valid <= TO_STD_LOGIC( PackedTauPipe1( 0 )( i + 6 ) .DataValid );

          WHEN 7 =>
            links( LinkMapping( i ) ) .data      <= PackedTauPipe2( 0 )( i + 3 ) .Data;
            links( LinkMapping( i ) ) .valid     <= TO_STD_LOGIC( PackedTauPipe2( 0 )( i + 3 ) .DataValid );

            links( LinkMapping( i + 3 ) ) .data  <= PackedTauPipe2( 0 )( i + 9 ) .Data;
            links( LinkMapping( i + 3 ) ) .valid <= TO_STD_LOGIC( PackedTauPipe2( 0 )( i + 9 ) .DataValid );

          WHEN 8 =>
            links( LinkMapping( i ) ) .data      <= PackedJetPipe1( 0 )( i ) .Data;
            links( LinkMapping( i ) ) .valid     <= TO_STD_LOGIC( PackedJetPipe1( 0 )( i ) .DataValid );

            links( LinkMapping( i + 3 ) ) .data  <= PackedJetPipe1( 0 )( i + 6 ) .Data;
            links( LinkMapping( i + 3 ) ) .valid <= TO_STD_LOGIC( PackedJetPipe1( 0 )( i + 6 ) .DataValid );

          WHEN 9 =>
            links( LinkMapping( i ) ) .data      <= PackedJetPipe2( 0 )( i + 3 ) .Data;
            links( LinkMapping( i ) ) .valid     <= TO_STD_LOGIC( PackedJetPipe2( 0 )( i + 3 ) .DataValid );

            links( LinkMapping( i + 3 ) ) .data  <= PackedJetPipe2( 0 )( i + 9 ) .Data;
            links( LinkMapping( i + 3 ) ) .valid <= TO_STD_LOGIC( PackedJetPipe2( 0 )( i + 9 ) .DataValid );

          WHEN 10 =>
            links( LinkMapping( i ) ) .data      <= PackedAuxPipe( 0 )( i ) .Data;
            links( LinkMapping( i ) ) .valid     <= TO_STD_LOGIC( PackedAuxPipe( 0 )( i ) .DataValid );

            links( LinkMapping( i + 3 ) ) .data  <= PackedAuxPipe( 0 )( i + 3 ) .Data;
            links( LinkMapping( i + 3 ) ) .valid <= TO_STD_LOGIC( PackedAuxPipe( 0 )( i + 3 ) .DataValid );

          WHEN OTHERS =>
-- -- Do NOTHING
        END CASE;

      END LOOP;

      IF( COUNTER < NumberOfFrames ) THEN
        COUNTER := COUNTER + 1;
      END IF;

    END IF;
  END PROCESS;


  linksOut <= links;

END ARCHITECTURE behavioral;
