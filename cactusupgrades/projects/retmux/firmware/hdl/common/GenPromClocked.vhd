--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Writing to and from files
USE STD.TEXTIO.ALL;
--! Writing to and from files
USE IEEE.STD_LOGIC_TEXTIO.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 algorithm configuration bus
USE work.FunkyMiniBus.ALL;

--! @brief An entity providing a GenPromClocked
--! @details Detailed description
ENTITY GenPromClocked IS
  GENERIC(
          FileName : STRING;
          BusName  : STRING
         );
  PORT(
        clk       : IN STD_LOGIC ; --! The algorithm clock
        AddressIn : IN STD_LOGIC_VECTOR;
        DataOut   : OUT STD_LOGIC_VECTOR;
        BusIn     : IN tFMBus;
        BusOut    : OUT tFMBus;
        BusClk    : IN STD_LOGIC := '0'
      );
END ENTITY GenPromClocked;

--! @brief Architecture definition for entity GenPromClocked
--! @details Detailed description
ARCHITECTURE behavioral OF GenPromClocked IS

  CONSTANT WidthIn  : INTEGER := AddressIn'LENGTH;
  CONSTANT WidthOut : INTEGER := DataOut'LENGTH;

  TYPE mem_type IS ARRAY( 0 TO( 2 ** WidthIn ) -1 ) OF STD_LOGIC_VECTOR( WidthOut -1 DOWNTO 0 );

  IMPURE FUNCTION InitRomFromFile( RomFileName : IN STRING ) RETURN mem_type IS
    FILE RomFile                               : TEXT;
    VARIABLE RomFileLine , Debug               : LINE;
    VARIABLE TEMP                              : CHARACTER;
    VARIABLE Value                             : STD_LOGIC_VECTOR( 19 DOWNTO 0 );
    VARIABLE ROM                               : mem_type;
  BEGIN

    IF for_synthesis THEN
      FILE_OPEN( RomFile , RomFileName , READ_MODE );
    ELSE
      FILE_OPEN( RomFile , STRING' ( "../firmware/HexROMs/" ) & RomFileName , READ_MODE );
    END IF;

    FOR i IN mem_type'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      rom( i ) := Value( WidthOut -1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    RETURN ROM;
  END FUNCTION InitRomFromFile;

  SHARED VARIABLE ROM           : mem_type := InitRomFromFile( FileName );

  ATTRIBUTE ram_style           : STRING;
  ATTRIBUTE ram_style OF ROM    : VARIABLE IS "block";

-- -------------------------------------------------------------------------------------------------------------------
-- FMBus Signals
-- -------------------------------------------------------------------------------------------------------------------
  SIGNAL FMBusAddr              : STD_LOGIC_VECTOR( WidthIn - 1 DOWNTO 0 )  := ( OTHERS => '0' );
  SIGNAL FMBusWrite , FMBusRead : STD_LOGIC_VECTOR( WidthOut - 1 DOWNTO 0 ) := ( OTHERS => '0' );

  SIGNAL FMBusWriteEnable       : STD_LOGIC                                 := '0';
  SIGNAL FMBusClock             : STD_LOGIC                                 := '0';
-- -------------------------------------------------------------------------------------------------------------------

  SIGNAL DataReg                : STD_LOGIC_VECTOR( WidthOut -1 DOWNTO 0 )  := ( OTHERS => '0' );

BEGIN

  ASSERT( WidthIn >= 11 AND WidthIn <= 13 ) REPORT "INPUT WIDTH MUST BE 11, 12 OR 13" SEVERITY FAILURE;
  ASSERT( WidthOut = 9 OR WidthOut = 18 ) REPORT "OUTPUT WIDTH MUST BE 9 OR 18" SEVERITY FAILURE;

  FMBusRamDecoderInstance : ENTITY work.FMBusRamDecoder
  GENERIC MAP(
    BusName => BusName
  )
  PORT MAP(
    BusIn     => BusIn ,
    BusOut    => BusOut ,
    BusClk    => BusClk ,
    ClkOut    => FMBusClock ,
    AddrOut   => FMBusAddr ,
    DataOut   => FMBusWrite ,
    DataIn    => FMBusRead ,
    DataValid => FMBusWriteEnable
  );

-- ConfigBus port
  PROCESS( FMBusClock )
  BEGIN
    IF RISING_EDGE( FMBusClock ) THEN
        IF( FMBusWriteEnable = '1' ) THEN
            ROM( TO_INTEGER( UNSIGNED( FMBusAddr ) ) ) := FMBusWrite;
        END IF;
        FMBusRead <= ROM( TO_INTEGER( UNSIGNED( FMBusAddr ) ) );
    END IF;
  END PROCESS;

-- LUT port
  PROCESS( clk )
  BEGIN
    IF RISING_EDGE( clk ) THEN
      DataReg <= ROM( TO_INTEGER( UNSIGNED( AddressIn ) ) );
      DataOut <= DataReg;
    END IF;
  END PROCESS;


END ARCHITECTURE behavioral;
