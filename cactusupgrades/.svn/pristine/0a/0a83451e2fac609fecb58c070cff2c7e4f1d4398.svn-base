
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

PACKAGE jet_types IS

-- If ISE or VIVADO actually supported VHDL-2008 , then I would USE unconstrained records here , as it is
-- STD_LOGIC_VECTORs are big enough to hold the sum of 128 tower objects( 9-bits ) .
-- We can , therefore , safely USE the same object for 9x9 jets

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

  TYPE tJet IS RECORD
    Energy      : UNSIGNED( 15 DOWNTO 0 );
    Ecal        : UNSIGNED( 15 DOWNTO 0 );
    Phi         : INTEGER RANGE 0 TO cTowerInPhi;
    Eta         : INTEGER RANGE 0 TO cTowersInHalfEta;
    EtaHalf     : INTEGER RANGE 0 TO 1;
    LargePileUp : BOOLEAN;
    DataValid   : BOOLEAN;
  END RECORD;

  TYPE tJetInPhi    IS ARRAY( NATURAL RANGE <> ) OF tJet ; -- cTowerInPhi / 4 wide
  TYPE tJetInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tJetInPhi( 0 TO cTowerInPhi-1 ) ; -- Two halves in eta
  TYPE tJetPipe     IS ARRAY( NATURAL RANGE <> ) OF tJetInEtaPhi ; -- Rough length of the pipe , since any unused cells should be synthesized away

  CONSTANT cEmptyJet         : tJet         := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , 0 , 0 , 0 , FALSE , FALSE );
  CONSTANT cEmptyJetInEtaPhi : tJetInEtaPhi := ( OTHERS   => ( OTHERS => cEmptyJet ) );

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

  TYPE tGtFormattedJet IS RECORD
    Energy    : UNSIGNED( 10 DOWNTO 0 );
    Phi       : UNSIGNED( 7 DOWNTO 0 );
    Eta       : SIGNED( 7 DOWNTO 0 );
    DataValid : BOOLEAN;
  END RECORD;

  TYPE tGtFormattedJets    IS ARRAY( 11 DOWNTO 0 ) OF tGtFormattedJet;
  TYPE tGtFormattedJetPipe IS ARRAY( NATURAL RANGE <> ) OF tGtFormattedJets ; -- Rough length of the pipe , since any unused cells should be synthesized away

  CONSTANT cEmptyGtFormattedJet  : tGtFormattedJet  := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , FALSE );
  CONSTANT cEmptyGtFormattedJets : tGtFormattedJets := ( OTHERS   => cEmptyGtFormattedJet );

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

END PACKAGE jet_types;
