
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

--! Writing to and from files
USE STD.TEXTIO.ALL;

PACKAGE constants IS

-- Remember to adjust UCF file...
  CONSTANT cNumberOfQuadsIn          : INTEGER := 18 ; -- Full = 18
  CONSTANT cNumberOfLinksIn          : INTEGER := cNumberOfQuadsIn * 4;


-- CONSTANT cNumberOfLinksOut : INTEGER := 0;

  CONSTANT cTowerInPhi               : INTEGER := cNumberOfQuadsIn * 4;
  CONSTANT cRegionInEta              : INTEGER := 2;
  CONSTANT cTowersInHalfEta          : INTEGER := 40;
  CONSTANT cEcalTowersInHalfEta      : INTEGER := 28;

  CONSTANT cTestbenchTowersInHalfEta : INTEGER := cTowersInHalfEta;

  CONSTANT cIncludeNullState         : BOOLEAN := TRUE;


  CONSTANT cCMScoordinateOffset      : INTEGER := 1 ; -- to go from sensible to CMS


  CONSTANT for_synthesis             : BOOLEAN := TRUE
-- pragma synthesis_off
  AND FALSE
-- pragma synthesis_on
;

-- To write to a Log File
  FILE LoggingDestination                   : TEXT OPEN write_mode IS "TestBench.OUT";
-- To write to the Console
-- alias LoggingDestination is output;

-- A few constants
  CONSTANT DefaultJetSeedThreshold          : INTEGER := 8;
  CONSTANT DefaultClusterSeedThreshold      : INTEGER := 4;
  CONSTANT DefaultClusterThreshold          : INTEGER := 2;
  CONSTANT DefaultPileUpThreshold           : INTEGER := 0;

  CONSTANT DefaultEgammaRelaxationThreshold : INTEGER := 256;

  CONSTANT DefaultEgammaTauEtaMax           : INTEGER := cEcalTowersInHalfEta;
  CONSTANT DefaultJetEtaMax                 : INTEGER := cTowersInHalfEta;

  CONSTANT DefaultRingEtaMax                : INTEGER := cEcalTowersInHalfEta;

  CONSTANT DefaultHTThreshold               : INTEGER := 60;
  CONSTANT DefaultMHTThreshold              : INTEGER := 60;


END constants;
