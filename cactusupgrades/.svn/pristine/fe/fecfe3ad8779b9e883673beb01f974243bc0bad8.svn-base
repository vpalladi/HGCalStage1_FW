
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


PACKAGE tower_types IS

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

  TYPE tTower IS RECORD
    EgammaCandidate : BOOLEAN;
    HasEM           : BOOLEAN;
    HcalFeature     : BOOLEAN;
    Energy          : UNSIGNED( 8 DOWNTO 0 );
-- These are to store the estimated ECAL / HCAL components
    Ecal            : UNSIGNED( 8 DOWNTO 0 );
    Hcal            : UNSIGNED( 8 DOWNTO 0 );
    DataValid       : BOOLEAN;
  END RECORD;

  TYPE tTowerInPhi    IS ARRAY( 0 TO cTowerInPhi-1 ) OF tTower ; -- cTowerInPhi wide
  TYPE tTowerInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tTowerInPhi ; -- Two halves in eta
  TYPE tTowerPipe     IS ARRAY( NATURAL RANGE <> ) OF tTowerInEtaPhi ; -- Rough length of the pipe , since any unused cells should be synthesized away

  CONSTANT cEmptyTower         : tTower         := ( FALSE , FALSE , FALSE , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , FALSE );
  CONSTANT cEmptyTowerInPhi    : tTowerInPhi    := ( OTHERS                           => cEmptyTower );
  CONSTANT cEmptyTowerInEtaPhi : tTowerInEtaPhi := ( OTHERS                           => cEmptyTowerInPhi );

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Need to split up array into phi constituents for floor planning.
  TYPE tTowerInEta     IS ARRAY( 0 TO cRegionInEta-1 ) OF tTower ; -- Two halves in eta
  TYPE tTowerInEtaPipe IS ARRAY( NATURAL RANGE <> ) OF tTowerInEta ; -- Rough length of the pipe , since any unused cells should be synthesized away

-- Need to split up array into phi constituents for floor planning.
  CONSTANT cEmptyTowerInEta : tTowerInEta := ( OTHERS => cEmptyTower );

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------------------------------------------
-- Object that include information needed to characterize it
  TYPE tTowerFlags IS RECORD
    JetSeedThreshold     : BOOLEAN;
    ClusterSeedThreshold : BOOLEAN;
    ClusterThreshold     : BOOLEAN;
    PileUpThreshold      : BOOLEAN;
    DataValid            : BOOLEAN ; -- Indicate that incoming data is valid
  END RECORD tTowerFlags;

  TYPE tTowerFlagInPhi    IS ARRAY( 0 TO cTowerInPhi-1 ) OF tTowerFlags;
  TYPE tTowerFlagInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tTowerFlagInPhi;
  TYPE tTowerFlagsPipe    IS ARRAY( NATURAL RANGE <> ) OF tTowerFlagInEtaPhi;

  CONSTANT cEmptyTowerFlags        : tTowerFlags        := ( OTHERS => FALSE );
  CONSTANT cEmptyTowerFlagInPhi    : tTowerFlagInPhi    := ( OTHERS => cEmptyTowerFlags );
  CONSTANT cEmptyTowerFlagInEtaPhi : tTowerFlagInEtaPhi := ( OTHERS => cEmptyTowerFlagInPhi );
-- -----------------------------------------------------------------------------------------------------------------------------


END PACKAGE tower_types;
