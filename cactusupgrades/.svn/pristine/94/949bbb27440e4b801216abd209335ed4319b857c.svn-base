
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.math_real.ALL ; -- for UNIFORM , TRUNC functions

--! Writing to and from files
USE STD.TEXTIO.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;
--! Using the Calo-L2 "tower" helper functions
USE work.tower_functions.ALL;

--! Using the Calo-L2 "helper" helper functions
USE work.helper_functions.ALL;

USE work.LinkType.ALL;

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
PACKAGE TowerReference IS

  CONSTANT latency_towerFormer : INTEGER := 2;

  FILE TowerFile               : TEXT OPEN write_mode IS "IntermediateSteps/TowerPipe.txt";


  PROCEDURE TowerReference
  (
    VARIABLE reference_Links  : IN tLinkPipe;
    VARIABLE reference_Towers : INOUT tTowerPipe
  );

  PROCEDURE TowerChecker
  (
    VARIABLE clk_count        : IN INTEGER;
    CONSTANT timeout          : IN INTEGER;
-- -------------
    VARIABLE reference_Towers : IN tTowerPipe;
    SIGNAL TowerPipe          : IN tTowerPipe;
    VARIABLE retvalTowers     : INOUT tRetVal;
-- -------------
    CONSTANT debug            : IN BOOLEAN := false
-- -------------
  );


  PROCEDURE TowerDebug
  (
    VARIABLE clk_count : IN INTEGER;
    SIGNAL TowerPipe   : IN tTowerPipe;
    CONSTANT debug     : IN BOOLEAN := false
  );

  PROCEDURE TowerReport
  (
    VARIABLE retvalTowers : IN tRetVal
  );


  FUNCTION GetTower( Eta                  : INTEGER ; Phi : INTEGER ; Towers : tTowerPipe ) RETURN tTower;

  PROCEDURE OutputCandidate( VARIABLE clk : IN INTEGER ; CONSTANT latency : IN INTEGER ; SIGNAL data : IN tTowerInEtaPhi ; FILE f : TEXT );


END PACKAGE TowerReference;
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------



-- -------------------------------------------------------------------------------------------------------------------------------------------------------------
PACKAGE BODY TowerReference IS

  PROCEDURE TowerReference
  (
    VARIABLE reference_Links  : IN tLinkPipe;
    VARIABLE reference_Towers : INOUT tTowerPipe
  ) IS
    VARIABLE s : LINE;
  BEGIN
-- -----------------------------------------------------------------------------------------------------
    FOR i IN 0 TO cNumberOfLinksIn-1 LOOP
      FOR k IN 0 TO( reference_Towers'LENGTH -1 ) LOOP
        reference_Towers( k )( i MOD 2 )( 2 * ( i / 2 ) )         := ToTower( reference_Links( k )( i ) .data( 15 DOWNTO 0 ) , k );
        reference_Towers( k )( i MOD 2 )( ( 2 * ( i / 2 ) ) + 1 ) := ToTower( reference_Links( k )( i ) .data( 31 DOWNTO 16 ) , k );
      END LOOP;
    END LOOP;
-- -----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
    WRITELINE( LoggingDestination , s );

    WRITE( s , STRING' ( "          | " ) );
    FOR k IN( cTestbenchTowersInHalfEta-1 ) DOWNTO 0 LOOP
      WRITE( s , STRING' ( "+----" ) );
    END LOOP;
    WRITE( s , STRING' ( "+ +" ) );
    FOR k IN( cTestbenchTowersInHalfEta-1 ) DOWNTO 0 LOOP
      WRITE( s , STRING' ( "----+" ) );
    END LOOP;
    WRITELINE( LoggingDestination , s );

    FOR i IN 0 TO cTowerInPhi-1 LOOP

      WRITE( s , STRING' ( "PHI = " ) );
      WRITE( s , i , RIGHT , 4 );
      WRITE( s , STRING' ( "| " ) );

      FOR k IN( cTestbenchTowersInHalfEta-1 ) DOWNTO 0 LOOP
        WRITE( s , STRING' ( "|" ) );
        WRITE( s , TO_INTEGER( UNSIGNED( reference_Towers( k )( 1 )( i ) .Energy ) ) , RIGHT , 4 );
      END LOOP;

      WRITE( s , STRING' ( "| |" ) );

      FOR k IN 0 TO( cTestbenchTowersInHalfEta-1 ) LOOP
        WRITE( s , TO_INTEGER( UNSIGNED( reference_Towers( k )( 0 )( i ) .Energy ) ) , RIGHT , 4 );
        WRITE( s , STRING' ( "|" ) );
      END LOOP;

      WRITELINE( LoggingDestination , s );

      WRITE( s , STRING' ( "          | " ) );
      FOR k IN( cTestbenchTowersInHalfEta-1 ) DOWNTO 0 LOOP
        WRITE( s , STRING' ( "+----" ) );
      END LOOP;
      WRITE( s , STRING' ( "+ +" ) );
      FOR k IN( cTestbenchTowersInHalfEta-1 ) DOWNTO 0 LOOP
        WRITE( s , STRING' ( "----+" ) );
      END LOOP;
      WRITELINE( LoggingDestination , s );
    END LOOP;
-----------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
-- FOR i IN 0 TO cRegionInEta-1 LOOP
-- FOR j IN 0 TO cTestbenchTowersInHalfEta-1 LOOP
-- FOR k IN 0 TO cTowerInPhi-1 LOOP
-- IF reference_Towers( j )( i )( k ) .Energy > 0 then
-- WRITE( s , STRING' ( "TOWER : " ) );
-- WRITE( s , STRING' ( " Eta=" ) );
-- IF i = 0 then
-- WRITE( s , STRING' ( "+" ) );
-- else
-- WRITE( s , STRING' ( "-" ) );
-- end if;
--
-- WRITE( s , j + 1 , LEFT , 2 );
-- WRITE( s , STRING' ( " Phi=" ) );
-- WRITE( s , k + 1 , LEFT , 2 );
-- WRITE( s , STRING' ( " | " ) );
-- WRITE( s , STRING' ( " Energy=" ) );
-- WRITE( s , TO_INTEGER( reference_Towers( j )( i )( k ) .Energy ) );
-- WRITELINE( LoggingDestination , s );
-- end if;
-- END LOOP;
-- END LOOP;
-- END LOOP;
-- -----------------------------------------------------------------------------------------------------

  END TowerReference;


  PROCEDURE TowerChecker
  (
    VARIABLE clk_count        : IN INTEGER;
    CONSTANT timeout          : IN INTEGER;
-- -------------
    VARIABLE reference_Towers : IN tTowerPipe;
    SIGNAL TowerPipe          : IN tTowerPipe;
    VARIABLE retvalTowers     : INOUT tRetVal;
-- -------------
    CONSTANT debug            : IN BOOLEAN := false
-- -------------
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    FOR index IN 0 TO( cTestbenchTowersInHalfEta - 1 ) LOOP
      CHECK_RESULT( "Towers" , -- name
                    index , -- index
                    clk_count , -- clock counter
                    latency_towerFormer , -- expected latency
                    timeout , -- timeout
                    retvalTowers( index ) , -- return value
                    ( reference_towers( index ) = towerPipe( 0 ) ) , -- test condition
                    debug
      );
    END LOOP;
-- -----------------------------------------------------------------------------------------------------
  END TowerChecker;



 PROCEDURE TowerDebug
  (
    VARIABLE clk_count : IN INTEGER;
    SIGNAL TowerPipe   : IN tTowerPipe;
    CONSTANT debug     : IN BOOLEAN := false
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    IF debug THEN
      OutputCandidate( clk_count , latency_TowerFormer , TowerPipe( 0 ) , TowerFile );
    END IF;
-- -----------------------------------------------------------------------------------------------------
  END TowerDebug;



  PROCEDURE TowerReport
  (
    VARIABLE retvalTowers : IN tRetVal
  ) IS BEGIN
-- -----------------------------------------------------------------------------------------------------
    REPORT_RESULT( "Towers" , retvalTowers );
-- -----------------------------------------------------------------------------------------------------
  END TowerReport;



  FUNCTION GetTower( Eta : INTEGER ; Phi : INTEGER ; Towers : tTowerPipe ) RETURN tTower IS
    VARIABLE EtaSign     : INTEGER := 0;
    VARIABLE AbsEta      : INTEGER := 0;
  BEGIN
-- -----------------------------------------------------------------------------------------------------
    IF( ( Eta < -cTestbenchTowersInHalfEta ) OR( Eta >= cTestbenchTowersInHalfEta ) ) THEN
      RETURN cEmptyTower;
    END IF;

    IF( Eta >= 0 ) THEN
      EtaSign := 0;
      AbsEta  := Eta;
    ELSE
      EtaSign := 1;
      AbsEta  := ABS( Eta ) -1;
    END IF;

    RETURN towers( AbsEta )( EtaSign )( MOD_PHI( Phi ) );
-- -----------------------------------------------------------------------------------------------------
  END GetTower;


-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE OutputCandidate( VARIABLE clk : IN INTEGER ; CONSTANT latency : IN INTEGER ; SIGNAL data : IN tTowerInEtaPhi ; FILE f : TEXT ) IS
    VARIABLE s , x                        : LINE;
    VARIABLE algotime , event , frame     : INTEGER;
  BEGIN

    IF clk < 0 THEN
      WRITE( s , STRING' ( "Clock" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "AlgoClock" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Event" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Frame" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Eta-Half" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Phi" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "|" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Energy" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Ecal" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "Hcal" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "EgammaCandidate" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "HcalFeature" ) , RIGHT , 11 );
      WRITE( s , STRING' ( "DataValid" ) , RIGHT , 11 );
      WRITELINE( f , s );

    ELSE

      algotime := clk-latency-1;
      frame    := algotime MOD 54;
      event    := algotime / 54;

      FOR j IN 0 TO( cRegionInEta-1 ) LOOP
        FOR i IN 0 TO( cTowerInPhi-1 ) LOOP
          IF data( j )( i ) .Energy > 0 THEN
            WRITE( s , clk , RIGHT , 11 );
            WRITE( s , algotime , RIGHT , 11 );
            WRITE( s , event , RIGHT , 11 );
            WRITE( s , frame , RIGHT , 11 );
            WRITE( s , j , RIGHT , 11 );
            WRITE( s , i , RIGHT , 11 );
            WRITE( s , STRING' ( "|" ) , RIGHT , 11 );
            WRITE( s , TO_INTEGER( data( j )( i ) .Energy ) , RIGHT , 11 );
            WRITE( s , TO_INTEGER( data( j )( i ) .Ecal ) , RIGHT , 11 );
            WRITE( s , TO_INTEGER( data( j )( i ) .Hcal ) , RIGHT , 11 );
            WRITE( s , data( j )( i ) .EgammaCandidate , RIGHT , 11 );
            WRITE( s , data( j )( i ) .HcalFeature , RIGHT , 11 );
            WRITE( s , data( j )( i ) .DataValid , RIGHT , 11 );
            WRITELINE( f , s );
          END IF;
        END LOOP;
      END LOOP;
    END IF;
  END OutputCandidate;
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


END PACKAGE BODY TowerReference;
