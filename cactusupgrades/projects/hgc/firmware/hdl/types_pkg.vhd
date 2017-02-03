
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "mp7_data" data-types
USE work.mp7_data_types.ALL;

PACKAGE common_types IS


---- -------------------------------------------------------------------------------------------------------------------------------------------------------------
--  TYPE tWordInEta      IS ARRAY( 1 DOWNTO 0 ) OF lword;
--  TYPE tWordArray      IS ARRAY( 5 DOWNTO 0 ) OF lword;
--  TYPE tWordArrayInEta IS ARRAY( 1 DOWNTO 0 ) OF tWordArray;
--
--  CONSTANT cEmptyWordInEta      : tWordInEta      := ( OTHERS => LWORD_NULL );
--  CONSTANT cEmptyWordArray      : tWordArray      := ( OTHERS => LWORD_NULL );
--  CONSTANT cEmptyWordArrayInEta : tWordArrayInEta := ( OTHERS => ( OTHERS => LWORD_NULL ) );
---- -------------------------------------------------------------------------------------------------------------------------------------------------------------
--
---- -------------------------------------------------------------------------------------------------------------------------------------------------------------
--
  SUBTYPE tAccumulationComplete   IS BOOLEAN;
--  TYPE tAccumulationCompleteInEta IS ARRAY( 0 TO cRegionInEta-1 ) OF tAccumulationComplete ; -- Two halves in eta
--  TYPE tAccumulationCompletePipe  IS ARRAY( NATURAL RANGE <> ) OF tAccumulationCompleteInEta ; -- Rough length of the pipe , since any unused cells should be synthesized away
--
--  CONSTANT cEmptyAccumulationComplete      : tAccumulationComplete      := FALSE;
--  CONSTANT cEmptyAccumulationCompleteInEta : tAccumulationCompleteInEta := ( OTHERS => cEmptyAccumulationComplete );
--
---- -------------------------------------------------------------------------------------------------------------------------------------------------------------
--
--  TYPE tPackedLinkOffsets IS ARRAY( NATURAL RANGE <> ) OF INTEGER;
--
  TYPE tPackedLink        IS RECORD
    Data                 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
    AccumulationComplete : tAccumulationComplete;
    DataValid            : BOOLEAN;
  END RECORD;
--
  TYPE tPackedLinkInCandidates IS ARRAY( 71 DOWNTO 0 ) OF tPackedLink;
  TYPE tPackedLinkPipe         IS ARRAY( NATURAL RANGE <> ) OF tPackedLinkInCandidates;
--
--  CONSTANT cEmptyPackedLink             : tPackedLink             := ( ( OTHERS => '0' ) , cEmptyAccumulationComplete , FALSE );
--  CONSTANT cEmptyPackedLinkInCandidates : tPackedLinkInCandidates := ( OTHERS   => cEmptyPackedLink );
--
---- -------------------------------------------------------------------------------------------------------------------------------------------------------------
--
--  TYPE tComparison IS RECORD
--    Data      : BOOLEAN;
--    DataValid : BOOLEAN;
--  END RECORD;
--
--  TYPE tComparisonInPhi    IS ARRAY( 0 TO cTowerInPhi-1 ) OF tComparison ; -- cTowerInPhi wide
--  TYPE tComparisonInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tComparisonInPhi ; -- Two halves in eta
--  TYPE tComparisonPipe     IS ARRAY( NATURAL RANGE <> ) OF tComparisonInEtaPhi ; -- Rough length of the pipe , since any unused cells should be synthesized away
--
--  CONSTANT cEmptyComparison         : tComparison         := ( TRUE , FALSE );
--  CONSTANT cEmptyComparisonInPhi    : tComparisonInPhi    := ( OTHERS => cEmptyComparison );
--  CONSTANT cEmptyComparisonInEtaPhi : tComparisonInEtaPhi := ( OTHERS => cEmptyComparisonInPhi );
--
---- -------------------------------------------------------------------------------------------------------------------------------------------------------------
--
--  TYPE tMaxima IS RECORD
--    Max       : UNSIGNED( 8 DOWNTO 0 ) ; -- The maximum is a tower , not a jet!
--    Phi       : INTEGER RANGE 0 TO 8;
--    Eta       : INTEGER RANGE 0 TO 3;
--    DataValid : BOOLEAN;
--  END RECORD;
--
--  TYPE tMaximaInPhi    IS ARRAY( 0 TO cTowerInPhi-1 ) OF tMaxima ; -- cTowerInPhi wide
--  TYPE tMaximaInEtaPhi IS ARRAY( 0 TO cRegionInEta-1 ) OF tMaximaInPhi ; -- Two halves in eta
--  TYPE tMaximaPipe     IS ARRAY( NATURAL RANGE <> ) OF tMaximaInEtaPhi ; -- Rough length of the pipe , since any unused cells should be synthesized away
--
--  CONSTANT cEmptyMaxima         : tMaxima         := ( ( OTHERS => '0' ) , 0 , 0 , FALSE );
--  CONSTANT cEmptyMaximaInPhi    : tMaximaInPhi    := ( OTHERS   => cEmptyMaxima );
--  CONSTANT cEmptyMaximaInEtaPhi : tMaximaInEtaPhi := ( OTHERS   => cEmptyMaximaInPhi );
--
---- -------------------------------------------------------------------------------------------------------------------------------------------------------------
--
--  TYPE tDataOrdering IS ARRAY( NATURAL RANGE <> ) OF INTEGER;

END common_types;
