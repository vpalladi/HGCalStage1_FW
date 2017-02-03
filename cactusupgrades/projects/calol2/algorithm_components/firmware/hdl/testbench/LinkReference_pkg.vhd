
--! Using the IEEE Library
LIBRARY IEEE;

--! Writing to and from files
USE IEEE.STD_LOGIC_TEXTIO.ALL;
--! Writing to and from files
USE STD.TEXTIO.ALL;

--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.math_real.ALL ; -- for UNIFORM , TRUNC functions

--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

USE work.LinkType.ALL;
--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

--! Using the Calo-L2 "helper" helper functions
USE work.helper_functions.ALL;

--! Using the Calo-L2 "common" data-types
USE work.common_types.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;
--! Using the Calo-L2 "tower" helper functions
USE work.tower_functions.ALL;

--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;
--! Using the Calo-L2 "ring" data-types
USE work.ring_types.ALL;
--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;

--! Using the Calo-L2 "Jet" testbench suite
USE work.JetReference.ALL;
--! Using the Calo-L2 "Ringsum" testbench suite
USE work.RingsumReference.ALL;
--! Using the Calo-L2 "Cluster" testbench suite
USE work.ClusterReference.ALL;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
PACKAGE LinkReference IS
  CONSTANT latency_LinkFormer   : INTEGER := 2;
  CONSTANT latency_mpLinkOut    : INTEGER := cTestBenchTowersInHalfEta + 41;
  CONSTANT latency_demuxLinkOut : INTEGER := latency_gtFormattedJets + 2;

  PROCEDURE SourceLinkData
  (
    VARIABLE reference_Links : INOUT tLinkPipe
  );

  
  TYPE tCurrentReadState IS( Uninitialized , Gap , Header , Payload , Finished );

  PROCEDURE SourceLinkDataFile( FileName                : IN STRING;
                                StartFrameInclAnyHeader : IN INTEGER;
                                GapLength               : IN INTEGER;
                                HeaderLength            : IN INTEGER;
                                PayloadLength           : IN INTEGER;
                                DebugMessages           : IN BOOLEAN := TRUE;
                                reference_Links         : INOUT tLinkPipe
                              );




  PROCEDURE LinkReference
  (
    VARIABLE reference_JetPackedLink               : IN tPackedLinkPipe;
    VARIABLE reference_EgammaPackedLink            : IN tPackedLinkPipe;
    VARIABLE reference_TauPackedLink               : IN tPackedLinkPipe;
    VARIABLE reference_ETandMETPackedLink          : IN tPackedLinkPipe;
    VARIABLE reference_HTandMHTPackedLink          : IN tPackedLinkPipe;
    VARIABLE reference_AuxInfoPackedLink           : IN tPackedLinkPipe;
    VARIABLE reference_mpLinkOut                   : INOUT tLinkPipe;
    VARIABLE reference_DemuxETandMETPackedLink     : IN tPackedLinkPipe;
    VARIABLE reference_DemuxETandMETNoHFPackedLink : IN tPackedLinkPipe;
    VARIABLE reference_DemuxHTandMHTPackedLink     : IN tPackedLinkPipe;
    VARIABLE reference_DemuxHTandMHTNoHFPackedLink : IN tPackedLinkPipe;
    VARIABLE reference_demuxJetPackedLink          : IN tPackedLinkPipe;
    VARIABLE reference_DemuxEgammaPackedLink       : IN tPackedLinkPipe;
    VARIABLE reference_DemuxTauPackedLink          : IN tPackedLinkPipe;
    VARIABLE reference_demuxLinkOut                : INOUT tLinkPipe
  );



  PROCEDURE LinkChecker
  (
    VARIABLE clk_count              : IN INTEGER;
    CONSTANT timeout                : IN INTEGER;
-- -------------
    VARIABLE reference_mpLinkOut    : IN tLinkPipe;
    SIGNAL mpLinkOut                : IN ldata;
    VARIABLE retvalMpLinkOut        : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxLinkOut : IN tLinkPipe;
    SIGNAL demuxLinkOut             : IN ldata;
    VARIABLE retvalDemuxLinkOut     : INOUT tRetVal;
-- -------------
    CONSTANT debug                  : IN BOOLEAN := false
-- -------------
  );


  PROCEDURE LinkReport
  (
    VARIABLE retvalMpLinkOut    : IN tRetVal;
    VARIABLE retvalDemuxLinkOut : IN tRetVal
  );


  PROCEDURE LinkStimulus
  (
    VARIABLE clk_count       : IN INTEGER;
-- -------------
    VARIABLE reference_Links : IN tLinkPipe;
    SIGNAL links_in          : OUT ldata( cNumberOfLinksIn-1 DOWNTO 0 )
-- -------------
  );

END PACKAGE LinkReference;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------



-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
PACKAGE BODY LinkReference IS

  PROCEDURE SourceLinkData
  (
    VARIABLE reference_Links : INOUT tLinkPipe
  ) IS
    VARIABLE seed1 , seed2    : POSITIVE                                         := 12121121 ; -- Seed values for random generator

    VARIABLE reference_Towers : tTowerPipe( reference_Links'LENGTH -1 DOWNTO 0 ) := ( OTHERS => cEmptyTowerInEtaPhi );
    CONSTANT eta              : INTEGER                                          := 13;
    CONSTANT phi              : INTEGER                                          := 10;

  BEGIN
-- -----------------------------------------------------------------------------------------------------

  IF TRUE THEN
    FOR i IN cNumberOfLinksIn-1 DOWNTO 0 LOOP
      FOR k IN 0 TO( reference_Links'LENGTH -1 ) LOOP
        SET_RANDOM_VAR( seed1 , seed2 , reference_Links( k )( i ) .data );
        reference_Links( k )( i ) .valid := '1';
      END LOOP;
    END LOOP;

  ELSE
-- Surrounding Towers
-- FOR i IN 8 DOWNTO 0 LOOP
-- FOR j IN 8 DOWNTO 0 LOOP
-- SET_RANDOM_VAR( seed1 , seed2 , reference_Towers( eta-4 + j )( 0 )( phi-4 + i ) .Energy );
-- reference_Towers( eta-4 + j )( 0 )( phi-4 + i ) .Energy( 8 ) := '0';
-- END LOOP;
-- END LOOP;

-- -- Pileup region
-- FOR i IN 8 DOWNTO 0 LOOP
-- FOR j IN 2 DOWNTO 0 LOOP
-- SET_RANDOM_VAR( seed1 , seed2 , reference_Towers( eta-j-5 )( 0 )( phi + i-4 ) .Energy ) ; -- Left
-- reference_Towers( eta-j-5 )( 0 )( phi + i-4 ) .Energy( 8 downto 6 ) := "000" ; -- Left
-- IF eta + j + 5 < cTestbenchTowersInHalfEta THEN
-- SET_RANDOM_VAR( seed1 , seed2 , reference_Towers( eta + j + 5 )( 0 )( phi + i-4 ) .Energy ) ; -- Right
-- reference_Towers( eta + j + 5 )( 0 )( phi + i-4 ) .Energy( 8 downto 6 ) := "000" ; -- Right
-- END IF;
-- SET_RANDOM_VAR( seed1 , seed2 , reference_Towers( eta + i-4 )( 0 )( phi + j + 5 ) .Energy ) ; -- Up
-- reference_Towers( eta + i-4 )( 0 )( phi + j + 5 ) .Energy( 8 downto 6 ) := "000" ; -- Up
-- SET_RANDOM_VAR( seed1 , seed2 , reference_Towers( eta + i-4 )( 0 )( phi-j-5 ) .Energy ) ; -- Down
-- reference_Towers( eta + i-4 )( 0 )( phi-j-5 ) .Energy( 8 downto 6 ) := "000" ; -- Down
-- END LOOP;
-- END LOOP;
--

-- reference_Towers( 0 )( 1 )( 71 ) .Energy := to_unsigned( 1 , 9 );
-- reference_Towers( 0 )( 1 )( 1 ) .Energy := to_unsigned( 3 , 9 );
--
-- reference_Towers( 0 )( 0 )( 71 ) .Energy := to_unsigned( 4 , 9 );
--reference_Towers( 0 )( 0 )( 0 ) .Energy := TO_UNSIGNED( 100 , 9 );
--reference_Towers( 0 )( 0 )( 17 ) .Energy := TO_UNSIGNED( 100 , 9 );
-- reference_Towers( 0 )( 0 )( 1 ) .Energy := to_unsigned( 5 , 9 );
--
-- reference_Towers( 1 )( 0 )( 71 ) .Energy := to_unsigned( 1 , 9 );
-- reference_Towers( 1 )( 0 )( 1 ) .Energy := to_unsigned( 3 , 9 );
--
--
-- reference_Towers( 1 )( 0 )( 0 ) .Energy := to_unsigned( 1 , 9 );
-- reference_Towers( 2 )( 0 )( 0 ) .Energy := to_unsigned( 2 , 9 );
-- reference_Towers( 3 )( 0 )( 0 ) .Energy := to_unsigned( 3 , 9 );
-- reference_Towers( 4 )( 0 )( 0 ) .Energy := to_unsigned( 4 , 9 );
-- reference_Towers( 5 )( 0 )( 0 ) .Energy := to_unsigned( 5 , 9 );
-- reference_Towers( 6 )( 0 )( 0 ) .Energy := to_unsigned( 6 , 9 );
--reference_Towers( 7 )( 0 )( 0 ) .Energy := TO_UNSIGNED( 7 , 9 );
--
-- reference_Towers( 0 )( 1 )( 0 ) .Energy := to_unsigned( 11 , 9 );
-- reference_Towers( 1 )( 1 )( 0 ) .Energy := to_unsigned( 12 , 9 );
-- reference_Towers( 2 )( 1 )( 0 ) .Energy := to_unsigned( 13 , 9 );
-- reference_Towers( 3 )( 1 )( 0 ) .Energy := to_unsigned( 14 , 9 );
-- reference_Towers( 4 )( 1 )( 0 ) .Energy := to_unsigned( 15 , 9 );
-- reference_Towers( 5 )( 1 )( 0 ) .Energy := to_unsigned( 16 , 9 );
--reference_Towers( 6 )( 1 )( 0 ) .Energy := TO_UNSIGNED( 17 , 9 );

-- reference_Towers( 1 )( 0 )( 71 ) .Energy := to_unsigned( 6 , 9 );
-- reference_Towers( 1 )( 0 )( 0 ) .Energy := to_unsigned( 7 , 9 );
-- reference_Towers( 1 )( 0 )( 1 ) .Energy := to_unsigned( 8 , 9 );

-- Data Valid Flags

  FOR phi IN 0 TO( cTowerInPhi ) -1 LOOP
    FOR eta_half IN 0 TO cRegionInEta-1 LOOP
      FOR eta IN 0 TO( cTestBenchTowersInHalfEta - 1 ) LOOP
        reference_Towers( eta )( eta_half )( phi ) .Energy := TO_UNSIGNED( cTestBenchTowersInHalfEta - eta , 9 );
      END LOOP;
    END LOOP;
  END LOOP;

    FOR i IN 0 TO cNumberOfLinksIn-1 LOOP
      FOR k IN 0 TO( reference_Links'LENGTH -1 ) LOOP
        reference_Links( k )( i ) .data( 15 DOWNTO 0 )  := FromTower( reference_Towers( k )( i MOD 2 )( 2 * ( i / 2 ) ) );
        reference_Links( k )( i ) .data( 31 DOWNTO 16 ) := FromTower( reference_Towers( k )( i MOD 2 )( ( 2 * ( i / 2 ) ) + 1 ) );
--reference_Links( k )( i ) .data := ( reference_Links( k )( i ) .data AND x"EFFFEFFF" ) OR x"0A000800" ; -- SPOOF ECAL / HCAL FLAGS
        reference_Links( k )( i ) .valid                := '1';
      END LOOP;
    END LOOP;
  END IF;

-- -----------------------------------------------------------------------------------------------------
  END SourceLinkData;



-- ----------------------------------------------------------
  PROCEDURE SourceLinkDataFile( FileName                : IN STRING;
                                StartFrameInclAnyHeader : IN INTEGER;
                                GapLength               : IN INTEGER;
                                HeaderLength            : IN INTEGER;
                                PayloadLength           : IN INTEGER;
                                DebugMessages           : IN BOOLEAN := TRUE;
                                reference_Links         : INOUT tLinkPipe
                              ) IS
    VARIABLE L , DEBUG        : LINE;
        FILE InFile           : TEXT;
    VARIABLE CurrentReadState : tCurrentReadState := Uninitialized;
    VARIABLE Counter , Frame  : INTEGER           := 0;

-- ----------------------------------------------------------
  PROCEDURE READ( L           : INOUT LINE ; VALUE : OUT lword ) IS
    VARIABLE TEMP             : CHARACTER;
  BEGIN
    READ( L , TEMP );
    READ( L , VALUE.valid );
    READ( L , TEMP );
    HREAD( L , VALUE.data );
  END PROCEDURE READ;
-- ----------------------------------------------------------

-- ----------------------------------------------------------
  PROCEDURE READ( L : INOUT LINE ; VALUE : OUT ldata( 71 DOWNTO 0 ) ) IS
    VARIABLE S      : STRING( 1 TO 12 );
  BEGIN
    READ( L , S ) ; -- "Frame XXXX : "
    FOR i IN 0 TO 71 LOOP
      READ( L , VALUE( i ) );
    END LOOP;
  END PROCEDURE READ;
-- ----------------------------------------------------------

-- ----------------------------------------------------------
  PROCEDURE WRITE( L : INOUT LINE ; VALUE : IN lword := LWORD_NULL ) IS
    VARIABLE TEMP    : CHARACTER;
  BEGIN
    WRITE( L , VALUE.valid );
    WRITE( L , STRING' ( "v" ) );
    HWRITE( L , VALUE.data );
  END PROCEDURE WRITE;
-- ----------------------------------------------------------

-- ----------------------------------------------------------
  PROCEDURE WRITE( L : INOUT LINE ; VALUE : IN ldata( 71 DOWNTO 0 ) := ( OTHERS => LWORD_NULL ) ) IS
  BEGIN
    FOR i IN 0 TO 71 LOOP
      WRITE( L , STRING' ( " " ) );
      WRITE( L , VALUE( i ) );
    END LOOP;
  END PROCEDURE WRITE;
-- ----------------------------------------------------------


  BEGIN
    FILE_OPEN( InFile , FileName , READ_MODE );

-- Debug
    IF DebugMessages THEN
      WRITE( DEBUG , STRING' ( "UNINITIALIZED : " ) );
      WRITE( DEBUG , Counter );
      WRITELINE( OUTPUT , DEBUG );
    END IF;
-- Open File
-- Strip Headers
    FOR i IN 0 TO 2 LOOP
      READLINE( InFile , L );
      WRITELINE( OUTPUT , DEBUG );
    END LOOP;
-- Strip LinkData pre-header
    FOR i IN 0 TO StartFrameInclAnyHeader-1 LOOP
      READLINE( InFile , L );
      WRITELINE( OUTPUT , DEBUG );
    END LOOP;
-- We are changing state
    IF HeaderLength /= 0 THEN
      CurrentReadState := Header;
    ELSE
      CurrentReadState := Payload;
    END IF;
    Counter := 0;

    inf_loop : LOOP
      READLINE( InFile , L );

      IF endfile( InFile ) OR Frame >= reference_Links'LENGTH THEN
        RETURN;
      END IF;

      CASE CurrentReadState IS
-- ----------------------------------------------
        WHEN Gap =>
-- Debug
          IF DebugMessages THEN
            WRITE( DEBUG , STRING' ( "GAP : " ) );
            WRITE( DEBUG , Counter );
            WRITELINE( OUTPUT , DEBUG );
          END IF;
-- We will return empty LinkData
          IF Counter = ( GapLength-1 ) THEN
-- We are changing state
            IF HeaderLength /= 0 THEN
              CurrentReadState := Header;
            ELSE
              CurrentReadState := Payload;
            END IF;
            Counter := 0;
          ELSE
            Counter := Counter + 1;
          END IF;
-- ----------------------------------------------
        WHEN Header =>
-- Debug
          IF DebugMessages THEN
            WRITE( DEBUG , STRING' ( "HEADER : " ) );
            WRITE( DEBUG , Counter );
            WRITELINE( OUTPUT , DEBUG );
          END IF;
          IF Counter = ( HeaderLength-1 ) THEN
-- We are changing state
            CurrentReadState := Payload;
            Counter          := 0;
          ELSE
            Counter := Counter + 1;
          END IF;
-- ----------------------------------------------
        WHEN Payload =>
          READ( L , reference_Links( frame ) );
-- Debug
          IF DebugMessages THEN
            WRITE( DEBUG , STRING' ( "PAYLOAD : " ) );
            WRITE( DEBUG , Counter );
            WRITE( DEBUG , STRING' ( " : " ) );
            WRITE( DEBUG , reference_Links( frame ) );
            WRITELINE( OUTPUT , DEBUG );
          END IF;
          IF Counter = ( PayloadLength-1 ) THEN
-- We are changing state
            CurrentReadState := Gap;
            Counter          := 0;
          ELSE
            Counter := Counter + 1;
          END IF;
-- ----------------------------------------------
        WHEN OTHERS =>
          WRITE( DEBUG , STRING' ( "SOMETHING HAS GONE WRONG" ) );
          WRITELINE( OUTPUT , DEBUG );
-- ----------------------------------------------
      END CASE;

      Frame := Frame + 1;

    END LOOP;
  END PROCEDURE SourceLinkDataFile;
-- ----------------------------------------------------------





  PROCEDURE LinkReference
  (
    VARIABLE reference_JetPackedLink               : IN tPackedLinkPipe;
    VARIABLE reference_EgammaPackedLink            : IN tPackedLinkPipe;
    VARIABLE reference_TauPackedLink               : IN tPackedLinkPipe;
    VARIABLE reference_ETandMETPackedLink          : IN tPackedLinkPipe;
    VARIABLE reference_HTandMHTPackedLink          : IN tPackedLinkPipe;
    VARIABLE reference_AuxInfoPackedLink           : IN tPackedLinkPipe;
    VARIABLE reference_mpLinkOut                   : INOUT tLinkPipe;
    VARIABLE reference_DemuxETandMETPackedLink     : IN tPackedLinkPipe;
    VARIABLE reference_DemuxETandMETNoHFPackedLink : IN tPackedLinkPipe;
    VARIABLE reference_DemuxHTandMHTPackedLink     : IN tPackedLinkPipe;
    VARIABLE reference_DemuxHTandMHTNoHFPackedLink : IN tPackedLinkPipe;
    VARIABLE reference_demuxJetPackedLink          : IN tPackedLinkPipe;
    VARIABLE reference_DemuxEgammaPackedLink       : IN tPackedLinkPipe;
    VARIABLE reference_DemuxTauPackedLink          : IN tPackedLinkPipe;
    VARIABLE reference_demuxLinkOut                : INOUT tLinkPipe
  ) IS

  TYPE tLinkMapping IS ARRAY( 0 TO 5 ) OF INTEGER RANGE 0 TO cNumberOfLinksIn-1;
  CONSTANT LinkMapping : tLinkMapping := ( 61 , 60 , 63 , 62 , 65 , 64 );

  BEGIN
-- -----------------------------------------------------------------------------------------------------
    FOR eta_half IN 0 TO( cRegionInEta-1 ) LOOP
      FOR index IN 0 TO 2 LOOP
        reference_mpLinkOut( 0 )( LinkMapping( ( 3 * eta_half ) + index ) ) .data := reference_ETandMETPackedLink( 0 )( ( 3 * eta_half ) + index ) .Data;
        reference_mpLinkOut( 1 )( LinkMapping( ( 3 * eta_half ) + index ) ) .data := reference_ETandMETPackedLink( 1 )( ( 3 * eta_half ) + index ) .Data;
        reference_mpLinkOut( 2 )( LinkMapping( ( 3 * eta_half ) + index ) ) .data := reference_HTandMHTPackedLink( 0 )( ( 3 * eta_half ) + index ) .Data;
        reference_mpLinkOut( 3 )( LinkMapping( ( 3 * eta_half ) + index ) ) .data := reference_HTandMHTPackedLink( 1 )( ( 3 * eta_half ) + index ) .Data;

        FOR cycle IN 0 TO 1 LOOP
          reference_mpLinkOut( 4 + cycle )( LinkMapping( ( 3 * eta_half ) + index ) ) .data := reference_EgammaPackedLink( reference_EgammaPackedLink'LENGTH -1 )( ( 6 * eta_half ) + ( 3 * cycle ) + index ) .Data;
          reference_mpLinkOut( 6 + cycle )( LinkMapping( ( 3 * eta_half ) + index ) ) .data := reference_TauPackedLink( reference_TauPackedLink'LENGTH -1 )( ( 6 * eta_half ) + ( 3 * cycle ) + index ) .Data;
          reference_mpLinkOut( 8 + cycle )( LinkMapping( ( 3 * eta_half ) + index ) ) .data := reference_JetPackedLink( reference_JetPackedLink'LENGTH -1 )( ( 6 * eta_half ) + ( 3 * cycle ) + index ) .Data;
        END LOOP;
      END LOOP;
    END LOOP;

-- aux
    reference_mpLinkOut( 10 )( LinkMapping( 0 ) ) .data := reference_AuxInfoPackedLink( reference_AuxInfoPackedLink'LENGTH -1 )( 0 ) .Data;
    reference_mpLinkOut( 10 )( LinkMapping( 1 ) ) .data := reference_AuxInfoPackedLink( reference_AuxInfoPackedLink'LENGTH -1 )( 1 ) .Data;

    FOR frame IN 0 TO 10 LOOP
      FOR link IN 0 TO 5 LOOP
        reference_mpLinkOut( frame )( LinkMapping( link ) ) .valid := '1';
      END LOOP;

      FOR link IN 71 DOWNTO 0 LOOP
        reference_mpLinkOut( frame )( link ) .strobe := '1';
      END LOOP;

    END LOOP;


-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------------------
    FOR j IN 0 TO 3 LOOP
      reference_demuxLinkOut( 0 )( 10 + ( 8 * j ) ) .data  := reference_DemuxETandMETNoHFPackedLink( 0 )( 0 ) .Data;
      reference_demuxLinkOut( 1 )( 10 + ( 8 * j ) ) .data  := reference_DemuxHTandMHTNoHFPackedLink( 0 )( 0 ) .Data;
      reference_demuxLinkOut( 2 )( 10 + ( 8 * j ) ) .data  := reference_DemuxETandMETNoHFPackedLink( 0 )( 1 ) .Data;
      reference_demuxLinkOut( 3 )( 10 + ( 8 * j ) ) .data  := reference_DemuxHTandMHTNoHFPackedLink( 0 )( 1 ) .Data;
      reference_demuxLinkOut( 4 )( 10 + ( 8 * j ) ) .data  := reference_DemuxETandMETPackedLink( 0 )( 1 ) .Data;
      reference_demuxLinkOut( 5 )( 10 + ( 8 * j ) ) .data  := reference_DemuxHTandMHTPackedLink( 0 )( 1 ) .Data;

      reference_demuxLinkOut( 0 )( 10 + ( 8 * j ) ) .valid := '1';
      reference_demuxLinkOut( 1 )( 10 + ( 8 * j ) ) .valid := '1';
      reference_demuxLinkOut( 2 )( 10 + ( 8 * j ) ) .valid := '1';
      reference_demuxLinkOut( 3 )( 10 + ( 8 * j ) ) .valid := '1';
      reference_demuxLinkOut( 4 )( 10 + ( 8 * j ) ) .valid := '1';
      reference_demuxLinkOut( 5 )( 10 + ( 8 * j ) ) .valid := '1';


      FOR frame IN 0 TO 5 LOOP
        reference_demuxLinkOut( frame )( 4 + ( 8 * j ) ) .data    := reference_demuxEgammaPackedLink( 0 )( frame ) .Data;
        reference_demuxLinkOut( frame )( 4 + ( 8 * j ) ) .valid   := '1';
        reference_demuxLinkOut( frame )( 4 + ( 8 * j ) ) .strobe  := '1';
        reference_demuxLinkOut( frame )( 5 + ( 8 * j ) ) .data    := reference_demuxEgammaPackedLink( 0 )( frame + 6 ) .Data;
        reference_demuxLinkOut( frame )( 5 + ( 8 * j ) ) .valid   := '1';
        reference_demuxLinkOut( frame )( 5 + ( 8 * j ) ) .strobe  := '1';

        reference_demuxLinkOut( frame )( 6 + ( 8 * j ) ) .data    := reference_demuxJetPackedLink( 0 )( frame ) .Data;
        reference_demuxLinkOut( frame )( 6 + ( 8 * j ) ) .valid   := '1';
        reference_demuxLinkOut( frame )( 6 + ( 8 * j ) ) .strobe  := '1';
        reference_demuxLinkOut( frame )( 7 + ( 8 * j ) ) .data    := reference_demuxJetPackedLink( 0 )( frame + 6 ) .Data;
        reference_demuxLinkOut( frame )( 7 + ( 8 * j ) ) .valid   := '1';
        reference_demuxLinkOut( frame )( 7 + ( 8 * j ) ) .strobe  := '1';

        reference_demuxLinkOut( frame )( 8 + ( 8 * j ) ) .data    := reference_demuxTauPackedLink( 0 )( frame ) .Data;
        reference_demuxLinkOut( frame )( 8 + ( 8 * j ) ) .valid   := '1';
        reference_demuxLinkOut( frame )( 8 + ( 8 * j ) ) .strobe  := '1';
        reference_demuxLinkOut( frame )( 9 + ( 8 * j ) ) .data    := reference_demuxTauPackedLink( 0 )( frame + 6 ) .Data;
        reference_demuxLinkOut( frame )( 9 + ( 8 * j ) ) .valid   := '1';
        reference_demuxLinkOut( frame )( 9 + ( 8 * j ) ) .strobe  := '1';

        reference_demuxLinkOut( frame )( 10 + ( 8 * j ) ) .strobe := '1';
        reference_demuxLinkOut( frame )( 11 + ( 8 * j ) ) .strobe := '1';
      END LOOP;
    END LOOP;      
-- -----------------------------------------------------------------------------------------------------

  END LinkReference;


  PROCEDURE LinkChecker
  (
    VARIABLE clk_count              : IN INTEGER;
    CONSTANT timeout                : IN INTEGER;
-- -------------
    VARIABLE reference_mpLinkOut    : IN tLinkPipe;
    SIGNAL mpLinkOut                : IN ldata;
    VARIABLE retvalMpLinkOut        : INOUT tRetVal;
-- -------------
    VARIABLE reference_demuxLinkOut : IN tLinkPipe;
    SIGNAL demuxLinkOut             : IN ldata;
    VARIABLE retvalDemuxLinkOut     : INOUT tRetVal;
-- -------------
    CONSTANT debug                  : IN BOOLEAN := false
-- -------------
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_mpLinkOut'LENGTH - 1 ) LOOP
      CHECK_RESULT( "MP Links OUT" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_mpLinkOut , -- expected latency
                    timeout , -- timeout
                    retvalMpLinkOut( index ) , -- return value
                    ( reference_mpLinkOut( index ) = mpLinkOut ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( reference_demuxLinkOut'LENGTH - 1 ) LOOP
      CHECK_RESULT( "DEMUX Links OUT" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_demuxLinkOut , -- expected latency
                    timeout , -- timeout
                    retvalDemuxLinkOut( index ) , -- return value
                    ( reference_demuxLinkOut( index ) = demuxLinkOut ) , -- test condition
             debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------
  END LinkChecker;



  PROCEDURE LinkReport
  (
    VARIABLE retvalMpLinkOut    : IN tRetVal;
    VARIABLE retvalDemuxLinkOut : IN tRetVal
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    REPORT_RESULT( "MP link OUT" , retvalMpLinkOut );
    REPORT_RESULT( "Demux link OUT( REMEMBER - 'FAILURE' NOT NECESSARILY FAILURE ) " , retvalDemuxLinkOut );
-- -----------------------------------------------------------------------------------------------------
  END LinkReport;



  PROCEDURE LinkStimulus
  (
    VARIABLE clk_count       : IN INTEGER;
-- -------------
    VARIABLE reference_Links : IN tLinkPipe;
    SIGNAL links_in          : OUT ldata( cNumberOfLinksIn-1 DOWNTO 0 )
-- -------------
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
      IF( clk_count >= 0 AND clk_count < reference_Links'LENGTH ) THEN
        links_in <= reference_Links( clk_count );
      ELSE
        links_in <= ( OTHERS => LWORD_NULL );
      END IF;
-- -----------------------------------------------------------------------------------------------------
  END LinkStimulus;

END PACKAGE BODY LinkReference;
