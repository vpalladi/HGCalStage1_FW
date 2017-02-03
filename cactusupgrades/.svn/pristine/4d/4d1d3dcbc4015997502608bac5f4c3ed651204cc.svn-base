--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;

--! @brief An entity providing a IsolationSum
--! @details Detailed description
ENTITY IsolationSum IS
  PORT(
    clk          : IN STD_LOGIC         := '0' ; --! The algorithm clock
    IsolationIn1 : IN tIsolationRegion  := cEmptyIsolationRegion;
    IsolationIn2 : IN tIsolationRegion  := cEmptyIsolationRegion;
    IsolationIn3 : IN tIsolationRegion  := cEmptyIsolationRegion;
    IsolationOut : OUT tIsolationRegion := cEmptyIsolationRegion
  );
END IsolationSum;

--! @brief Architecture definition for entity IsolationSum
--! @details Detailed description
ARCHITECTURE behavioral OF IsolationSum IS
BEGIN
  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF( NOT IsolationIn1.DataValid OR NOT IsolationIn2.DataValid OR NOT IsolationIn3.DataValid ) THEN
        IsolationOut <= cEmptyIsolationRegion;
      ELSE
        IsolationOut.Energy( 15 DOWNTO 0 ) <= IsolationIn1.Energy + IsolationIn2.Energy + IsolationIn3.Energy;
        IsolationOut.DataValid             <= TRUE;
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE behavioral;

-- ----------------------------------------------------------------------------------------------

--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;

--! @brief An entity providing a IsolationSum2
--! @details Detailed description
ENTITY IsolationSum2 IS
  PORT(
    clk          : IN STD_LOGIC         := '0' ; --! The algorithm clock
    IsolationIn1 : IN tIsolationRegion  := cEmptyIsolationRegion;
    IsolationIn2 : IN tIsolationRegion  := cEmptyIsolationRegion;
    IsolationOut : OUT tIsolationRegion := cEmptyIsolationRegion
  );
END IsolationSum2;

--! @brief Architecture definition for entity IsolationSum2
--! @details Detailed description
ARCHITECTURE behavioral OF IsolationSum2 IS
BEGIN
  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF( NOT IsolationIn1.DataValid OR NOT IsolationIn2.DataValid ) THEN
        IsolationOut <= cEmptyIsolationRegion;
      ELSE
        IsolationOut.Energy( 15 DOWNTO 0 ) <= IsolationIn1.Energy + IsolationIn2.Energy;
        IsolationOut.DataValid             <= TRUE;
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE behavioral;

-- ----------------------------------------------------------------------------------------------

--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "cluster" data-types
USE work.cluster_types.ALL;

--! @brief An entity providing a IsolationFinalSubtraction
--! @details Detailed description
ENTITY IsolationFinalSubtraction IS
  PORT(
    clk          : IN STD_LOGIC         := '0' ; --! The algorithm clock
    Sum9x6In     : IN tIsolationRegion  := cEmptyIsolationRegion;
    Sum5x2In     : IN tIsolationRegion  := cEmptyIsolationRegion;
    IsolationOut : OUT tIsolationRegion := cEmptyIsolationRegion
  );
END IsolationFinalSubtraction;

--! @brief Architecture definition for entity IsolationFinalSubtraction
--! @details Detailed description
ARCHITECTURE behavioral OF IsolationFinalSubtraction IS
BEGIN
  PROCESS( clk )
    VARIABLE Temp : INTEGER := 0;
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF( NOT Sum9x6In.DataValid OR NOT Sum5x2In.DataValid ) THEN
        IsolationOut <= cEmptyIsolationRegion;
      ELSE
        Temp := TO_INTEGER( Sum9x6In.Energy ) - TO_INTEGER( Sum5x2In.Energy );
        IF( Temp < 0 ) THEN
            IsolationOut.Energy( 15 DOWNTO 0 ) <= ( OTHERS => '0' );
        ELSE
            IsolationOut.Energy( 15 DOWNTO 0 ) <= TO_UNSIGNED( Temp , 16 );
        END IF;
        IsolationOut.DataValid <= TRUE;
      END IF;
    END IF;
  END PROCESS;

-- ----------------------------------------------------------------------------------------------

END ARCHITECTURE behavioral;
