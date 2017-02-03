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

--! Using the Calo-L2 "jet" helper functions
USE work.jet_functions.ALL;
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;

--! @brief An entity providing a GtJetFormatter
--! @details Detailed description
ENTITY GtJetFormatter IS
  PORT(
    clk        : IN STD_LOGIC := '0' ;   --! The algorithm clock
    jetPipeIn  : IN tJetPipe ;           --! A pipe of tJet objects bringing in the jet's
    jetPipeOut : OUT tGtFormattedJetPipe --! A pipe of tGtFormattedJet objects passing out the jet's
  );
END GtJetFormatter;

--! @brief Architecture definition for entity GtJetFormatter
--! @details Detailed description
ARCHITECTURE behavioral OF GtJetFormatter IS
  SIGNAL GtFormattedJets : tGtFormattedJets := cEmptyGtFormattedJets;

  TYPE tVectorInCandidates IS ARRAY( 11 DOWNTO 0 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );
  SIGNAL LocalEtaIn , GtEtaOut : tVectorInCandidates := ( OTHERS => ( OTHERS => '0' ) );
  SIGNAL LocalPhiIn , GtPhiOut : tVectorInCandidates := ( OTHERS => ( OTHERS => '0' ) );

BEGIN

  candidates : FOR i IN 11 DOWNTO 0 GENERATE

    LocalEtaIn( i )( 8 DOWNTO 0 ) <= STD_LOGIC_VECTOR( TO_UNSIGNED( JetPipeIn( 0 )( 0 )( i ) .EtaHalf , 1 ) )
                                  & STD_LOGIC_VECTOR( TO_UNSIGNED( JetPipeIn( 0 )( 0 )( i ) .Eta , 6 ) )
                                  & "10" ; -- Sub-position = "centre"

    EtaLutInstance : ENTITY work.GenRomClocked
    GENERIC MAP(
      FileName => "Y_localEtaToGT_9to8.mif"
    )
    PORT MAP(
      clk       => clk ,
      AddressIn => LocalEtaIn( i )( 8 DOWNTO 0 ) ,
      DataOut   => GtEtaOut( i )( 7 DOWNTO 0 )
    );

    GtFormattedJets( i ) .Eta     <= SIGNED( GtEtaOut( i )( 7 DOWNTO 0 ) );

    LocalPhiIn( i )( 8 DOWNTO 0 ) <= STD_LOGIC_VECTOR( TO_UNSIGNED( JetPipeIn( 0 )( 0 )( i ) .Phi , 7 ) )
                                   & "10" ; -- Sub-position = "centre"

    PhiLutInstance : ENTITY work.GenRomClocked
    GENERIC MAP(
      FileName => "Z_localPhiToGT_9to8.mif"
    )
    PORT MAP(
      clk       => clk ,
      AddressIn => LocalPhiIn( i )( 8 DOWNTO 0 ) ,
      DataOut   => GtPhiOut( i )( 7 DOWNTO 0 )
    );

    GtFormattedJets( i ) .Phi <= UNSIGNED( GtPhiOut( i )( 7 DOWNTO 0 ) );


    PROCESS( clk )
    BEGIN
      IF( RISING_EDGE( clk ) ) THEN

        IF( jetPipeIn( 0 )( 0 )( i ) .Energy > x"07FF" ) THEN
          GtFormattedJets( i ) .Energy <= ( OTHERS => '1' );
        ELSE
          GtFormattedJets( i ) .Energy <= jetPipeIn( 0 )( 0 )( i ) .Energy( 10 DOWNTO 0 );
        END IF;

        GtFormattedJets( i ) .DataValid <= jetPipeIn( 0 )( 0 )( i ) .DataValid;

      END IF;
    END PROCESS;

  END GENERATE;

  JetPipeInstance : ENTITY work.FormattedJetPipe
  PORT MAP(
    clk     => clk ,
    jetIn   => GtFormattedJets ,
    jetPipe => jetPipeOut
  );

END ARCHITECTURE behavioral;
