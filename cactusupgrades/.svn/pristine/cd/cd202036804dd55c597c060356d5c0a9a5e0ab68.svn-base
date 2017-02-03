
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

PACKAGE preprocessor_types IS

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

  TYPE tOSLBtower IS RECORD
    ET        : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
    Isolation : STD_LOGIC;
  END RECORD;

-- THE oSLB USES A MORONIC SPECIFICATION , INDEXING ARRAYS FROM 1 , NOT 0...

  TYPE tOSLBtowers IS ARRAY( 8 DOWNTO 1 ) OF tOSLBtower;
  TYPE tHamming    IS ARRAY( 4 DOWNTO 1 ) OF STD_LOGIC_VECTOR( 4 DOWNTO 0 );
  TYPE tFlag       IS ARRAY( 4 DOWNTO 1 ) OF STD_LOGIC;


  TYPE tOSLBregion IS RECORD
    Tower        : tOSLBtowers;
    Hamming      : tHamming;
    HammingError : tFlag;
    BC0          : tFlag;
    DataValid    : BOOLEAN;
  END RECORD;


  CONSTANT cEmptyOSLBtower  : tOSLBtower  := ( ( OTHERS => '0' ) , '0' );
  CONSTANT cEmptyOSLBregion : tOSLBregion := ( ( OTHERS => cEmptyOSLBtower ) , ( OTHERS => ( OTHERS => '0' ) ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , FALSE );

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

  TYPE tEcalTower IS RECORD
    ET           : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
    Isolation    : STD_LOGIC;
    BC0          : BOOLEAN;
    BC0_Error    : BOOLEAN;
    HammingError : BOOLEAN;
    DataValid    : BOOLEAN;
  END RECORD;



  TYPE tEcalTowerInPhi           IS ARRAY( cPrepro0 TO cTowerInPhi-1 ) OF tEcalTower ; -- cPreprocTowerInPhi wide
  TYPE tEcalTowerInEtaPhi        IS ARRAY( cPreprocTowerInEta-1 DOWNTO 0 ) OF tEcalTowerInPhi ; -- cPreprocTowerInEta long
  TYPE tEcalTowersInRegionEtaPhi IS ARRAY( cPrepro0 TO cRegionInEta-1 ) OF tEcalTowerInEtaPhi ; -- Two halves in eta

  CONSTANT cEmptyEcalTower                : tEcalTower                := ( ( OTHERS => '0' ) , '0' , FALSE , FALSE , FALSE , FALSE );
  CONSTANT cEmptyEcalTowerInPhi           : tEcalTowerInPhi           := ( OTHERS   => cEmptyEcalTower );
  CONSTANT cEmptyEcalTowerInEtaPhi        : tEcalTowerInEtaPhi        := ( OTHERS   => cEmptyEcalTowerInPhi );
  CONSTANT cEmptyEcalTowersInRegionEtaPhi : tEcalTowersInRegionEtaPhi := ( OTHERS   => cEmptyEcalTowerInEtaPhi );

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

  TYPE tUHTRtower IS RECORD
    ET    : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
    Flags : STD_LOGIC_VECTOR( 5 DOWNTO 0 ) ; -- HF uses two bits , HB / HE uses six bits
  END RECORD;

-- THE uHTR USES A MORONIC SPECIFICATION , INDEXING ARRAYS FROM A-H IN THE HB / HE
-- AND , QUITE SENSIBLY , TOWER NUMBERING 30-[40 / 41] in the HF...
  TYPE tUHTRtowers IS ARRAY( 10 DOWNTO 0 ) OF tUHTRtower;

  TYPE tUHTRregion IS RECORD
    Tower     : tUHTRtowers;
    CRC       : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
    CRCError  : BOOLEAN;
    BC0       : BOOLEAN;
    DataValid : BOOLEAN;
  END RECORD;


  CONSTANT cEmptyUHTRtower  : tUHTRtower  := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) );
  CONSTANT cEmptyUHTRregion : tUHTRregion := ( ( OTHERS => cEmptyUHTRtower ) , ( OTHERS => '0' ) , FALSE , FALSE , FALSE );

-- -------------------------------------------------------------------------------------------------------------------------------------------------------------

END PACKAGE preprocessor_types;
