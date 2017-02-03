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

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;

--! @brief An entity providing a DemuxLinksOut
--! @details Detailed description
ENTITY DemuxLinksOut IS
  GENERIC(
--EtMetOffset : INTEGER := 0;
--EtMetNoHFOffset : INTEGER := 0;
--HtMhtOffset : INTEGER := 0;
--HtMhtNoHFOffset : INTEGER := 0;
    JetOffset    : INTEGER := 0;
    EgammaOffset : INTEGER := 0;
    TauOffset    : INTEGER := 0
  );
  PORT(
    clk                 : IN STD_LOGIC := '0' ; --! The algorithm clock
--PackedRingSumPipeIn : IN tPackedLinkPipe ; --! A pipe of tPackedLink objects bringing in the PackedHTandMHT's
--PackedRingSumPipeIn : IN tPackedLinkPipe ; --! A pipe of tPackedLink objects bringing in the PackedHTandMHT's
--PackedRingSumPipeIn : IN tPackedLinkPipe ; --! A pipe of tPackedLink objects bringing in the PackedETandMET's
--PackedRingSumPipeIn : IN tPackedLinkPipe ; --! A pipe of tPackedLink objects bringing in the PackedETandMETNoHF's
    PackedRingSumPipeIn : IN tPackedLinkPipe ;  --! A pipe of tPackedLink objects bringing in the PackedETandMETNoHF's
    PackedJetPipeIn     : IN tPackedLinkPipe ;  --! A pipe of tPackedLink objects bringing in the PackedJet's
    PackedEgammaPipeIn  : IN tPackedLinkPipe ;  --! A pipe of tPackedLink objects bringing in the PackedEgamma's
    PackedTauPipeIn     : IN tPackedLinkPipe ;  --! A pipe of tPackedLink objects bringing in the PackedTau's
    linksOut            : OUT ldata( cNumberOfLinksIn-1 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );
    BusIn               : IN tFMBus;
    BusOut              : OUT tFMBus;
    BusClk              : IN STD_LOGIC := '0'
  );
END DemuxLinksOut;

--! @brief Architecture definition for entity DemuxLinksOut
--! @details Detailed description
ARCHITECTURE behavioral OF DemuxLinksOut IS
  SIGNAL links                                                                                                : ldata( cNumberOfLinksIn-1 DOWNTO 0 ) := ( OTHERS => ( ( OTHERS => '0' ) , '0' , '0' , '0' ) );

  SIGNAL Esum , Jet1 , Jet2 , Egamma1 , Egamma2 , Tau1 , Tau2 , Resvd                                         : STD_LOGIC_VECTOR( 31 DOWNTO 0 )      := ( OTHERS => '0' );
  SIGNAL EsumValid , Jet1Valid , Jet2Valid , Egamma1Valid , Egamma2Valid , Tau1Valid , Tau2Valid , ResvdValid : STD_LOGIC                            := '0';

  CONSTANT EgammaBaseChannel1                                                                                 : INTEGER                              := 4;
  CONSTANT EgammaBaseChannel2                                                                                 : INTEGER                              := 5;
  CONSTANT JetBaseChannel1                                                                                    : INTEGER                              := 6;
  CONSTANT JetBaseChannel2                                                                                    : INTEGER                              := 7;
  CONSTANT TauBaseChannel1                                                                                    : INTEGER                              := 8;
  CONSTANT TauBaseChannel2                                                                                    : INTEGER                              := 9;
  CONSTANT EsumBaseChannel                                                                                    : INTEGER                              := 10;
  CONSTANT ResvdBaseChannel                                                                                   : INTEGER                              := 11;

  CONSTANT CopiesToGlobalTrigger                                                                              : INTEGER                              := 4 ; -- Min 1 , Max 24

  SIGNAL EtMetOffset , HtMhtOffset                                                                            : INTEGER                              := 0;
  SIGNAL NoHfEtMetOffset , NoHfHtMhtOffset                                                                    : INTEGER                              := 0;

BEGIN


--EtMetOffset <= 1 WHEN UseNoHF ELSE 2;
--HtMhtOffset <= 0 WHEN UseNoHF ELSE 1;

    NoHfEtMetOffset <= 1;
    NoHfHtMhtOffset <= 0;

    EtMetOffset     <= 2;
    HtMhtOffset     <= 1;


    PRC                : PROCESS( clk )
      VARIABLE COUNTER : INTEGER RANGE 0 TO 6 := 0;
    BEGIN
      IF( RISING_EDGE( clk ) ) THEN

        IF PackedJetPipeIn( 1 )( 0 ) .DataValid THEN
          COUNTER := 0;
        END IF;

        CASE COUNTER IS
          WHEN 0 =>
            Esum      <= PackedRingSumPipeIn( NoHfEtMetOffset )( 0 ) .Data;
            EsumValid <= TO_STD_LOGIC( PackedRingSumPipeIn( NoHfEtMetOffset )( 0 ) .DataValid );
          WHEN 1 =>
            Esum      <= PackedRingSumPipeIn( NoHfHtMhtOffset )( 0 ) .Data;
            EsumValid <= TO_STD_LOGIC( PackedRingSumPipeIn( NoHfHtMhtOffset )( 0 ) .DataValid );
          WHEN 2 =>
            Esum      <= PackedRingSumPipeIn( NoHfEtMetOffset + 2 )( 1 ) .Data;
            EsumValid <= TO_STD_LOGIC( PackedRingSumPipeIn( NoHfEtMetOffset + 2 )( 1 ) .DataValid );
          WHEN 3 =>
            Esum      <= PackedRingSumPipeIn( NoHfHtMhtOffset + 2 )( 1 ) .Data;
            EsumValid <= TO_STD_LOGIC( PackedRingSumPipeIn( NoHfHtMhtOffset + 2 )( 1 ) .DataValid );
          WHEN 4 =>
            Esum      <= PackedRingSumPipeIn( EtMetOffset + 4 )( 1 ) .Data;
            EsumValid <= TO_STD_LOGIC( PackedRingSumPipeIn( EtMetOffset + 4 )( 1 ) .DataValid );
          WHEN 5 =>
            Esum      <= PackedRingSumPipeIn( HtMhtOffset + 4 )( 1 ) .Data;
            EsumValid <= TO_STD_LOGIC( PackedRingSumPipeIn( HtMhtOffset + 4 )( 1 ) .DataValid );
          WHEN OTHERS =>
            Esum      <= ( OTHERS => '0' );
            EsumValid <= '0';
        END CASE;

        IF( COUNTER < 6 ) THEN
          Jet1         <= PackedJetPipeIn( JetOffset + COUNTER )( COUNTER ) .Data;
          Jet1Valid    <= TO_STD_LOGIC( PackedJetPipeIn( JetOffset + COUNTER )( COUNTER ) .DataValid );
          Jet2         <= PackedJetPipeIn( JetOffset + COUNTER )( COUNTER + 6 ) .Data;
          Jet2Valid    <= TO_STD_LOGIC( PackedJetPipeIn( JetOffset + COUNTER )( COUNTER + 6 ) .DataValid );

          Egamma1      <= PackedEgammaPipeIn( EgammaOffset + COUNTER )( COUNTER ) .Data;
          Egamma1Valid <= TO_STD_LOGIC( PackedEgammaPipeIn( EgammaOffset + COUNTER )( COUNTER ) .DataValid );
          Egamma2      <= PackedEgammaPipeIn( EgammaOffset + COUNTER )( COUNTER + 6 ) .Data;
          Egamma2Valid <= TO_STD_LOGIC( PackedEgammaPipeIn( EgammaOffset + COUNTER )( COUNTER + 6 ) .DataValid );

          Tau1         <= PackedTauPipeIn( TauOffset + COUNTER )( COUNTER ) .Data;
          Tau1Valid    <= TO_STD_LOGIC( PackedTauPipeIn( TauOffset + COUNTER )( COUNTER ) .DataValid );
          Tau2         <= PackedTauPipeIn( TauOffset + COUNTER )( COUNTER + 6 ) .Data;
          Tau2Valid    <= TO_STD_LOGIC( PackedTauPipeIn( TauOffset + COUNTER )( COUNTER + 6 ) .DataValid );

          COUNTER := COUNTER + 1;
        ELSE
          Jet1         <= ( OTHERS => '0' );
          Jet1Valid    <= '0';
          Jet2         <= ( OTHERS => '0' );
          Jet2Valid    <= '0';

          Egamma1      <= ( OTHERS => '0' );
          Egamma1Valid <= '0';
          Egamma2      <= ( OTHERS => '0' );
          Egamma2Valid <= '0';

          Tau1         <= ( OTHERS => '0' );
          Tau1Valid    <= '0';
          Tau2         <= ( OTHERS => '0' );
          Tau2Valid    <= '0';
        END IF;

      END IF;
    END PROCESS;

    copies : FOR j IN 0 TO CopiesToGlobalTrigger-1 GENERATE
      links( EgammaBaseChannel1 + ( 8 * j ) ) .data   <= Egamma1;
      links( EgammaBaseChannel1 + ( 8 * j ) ) .valid  <= Egamma1Valid;
      links( EgammaBaseChannel1 + ( 8 * j ) ) .strobe <= '1';

      links( EgammaBaseChannel2 + ( 8 * j ) ) .data   <= Egamma2;
      links( EgammaBaseChannel2 + ( 8 * j ) ) .valid  <= Egamma2Valid;
      links( EgammaBaseChannel2 + ( 8 * j ) ) .strobe <= '1';

      links( JetBaseChannel1 + ( 8 * j ) ) .data      <= Jet1;
      links( JetBaseChannel1 + ( 8 * j ) ) .valid     <= Jet1Valid;
      links( JetBaseChannel1 + ( 8 * j ) ) .strobe    <= '1';

      links( JetBaseChannel2 + ( 8 * j ) ) .data      <= Jet2;
      links( JetBaseChannel2 + ( 8 * j ) ) .valid     <= Jet2Valid;
      links( JetBaseChannel2 + ( 8 * j ) ) .strobe    <= '1';

      links( TauBaseChannel1 + ( 8 * j ) ) .data      <= Tau1;
      links( TauBaseChannel1 + ( 8 * j ) ) .valid     <= Tau1Valid;
      links( TauBaseChannel1 + ( 8 * j ) ) .strobe    <= '1';

      links( TauBaseChannel2 + ( 8 * j ) ) .data      <= Tau2;
      links( TauBaseChannel2 + ( 8 * j ) ) .valid     <= Tau2Valid;
      links( TauBaseChannel2 + ( 8 * j ) ) .strobe    <= '1';

      links( EsumBaseChannel + ( 8 * j ) ) .data      <= Esum;
      links( EsumBaseChannel + ( 8 * j ) ) .valid     <= EsumValid;
      links( EsumBaseChannel + ( 8 * j ) ) .strobe    <= '1';

      links( ResvdBaseChannel + ( 8 * j ) ) .data     <= Resvd;
      links( ResvdBaseChannel + ( 8 * j ) ) .valid    <= ResvdValid;
      links( ResvdBaseChannel + ( 8 * j ) ) .strobe   <= '1';
    END GENERATE;

  linksOut <= links;

END ARCHITECTURE behavioral;
