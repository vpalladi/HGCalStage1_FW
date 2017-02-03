--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;

--! Using the Calo-L2 common constants
USE work.constants.ALL;

--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;

--! @brief An entity providing a ClusterSum
--! @details Detailed description
ENTITY ClusterSum IS
  PORT(
    clk        : IN STD_LOGIC := '0' ; --! The algorithm clock
    ClusterIn1 : IN tCluster  := cEmptyCluster;
    ClusterIn2 : IN tCluster  := cEmptyCluster;
    ClusterIn3 : IN tCluster  := cEmptyCluster;
    ClusterOut : OUT tCluster := cEmptyCluster
  );
END ClusterSum;

--! @brief Architecture definition for entity ClusterSum
--! @details Detailed description
ARCHITECTURE behavioral OF ClusterSum IS
  SIGNAL ClusterTmp : tCluster := cEmptyCluster;
  SIGNAL EnergyTmp  : STD_LOGIC_VECTOR( 21 DOWNTO 0 );
BEGIN
  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF( NOT ClusterIn1.DataValid OR NOT ClusterIn2.DataValid OR NOT ClusterIn3.DataValid ) THEN
        ClusterOut <= cEmptyCluster;
      ELSE
        ClusterOut.Energy( 12 DOWNTO 0 ) <= ClusterIn1.Energy + ClusterIn2.Energy + ClusterIn3.Energy;

        ClusterOut.Phi                   <= ClusterIn2.Phi;
        ClusterOut.Eta                   <= ClusterIn2.Eta;
        ClusterOut.EtaHalf               <= ClusterIn2.EtaHalf;
        ClusterOut.LateralPosition       <= ClusterIn2.LateralPosition;
        ClusterOut.VerticalPosition      <= ClusterIn2.VerticalPosition;
        ClusterOut.EgammaCandidate       <= ClusterIn2.EgammaCandidate;
        ClusterOut.HasEM                 <= ClusterIn2.HasEM ; --ClusterIn1.HasEM OR ClusterIn2.HasEM OR ClusterIn3.HasEM;
        ClusterOut.HasSeed               <= ClusterIn2.HasSeed;
        ClusterOut.Isolated              <= ClusterIn2.Isolated;
        ClusterOut.NoSecondary           <= ClusterIn1.NoSecondary;
        ClusterOut.TauSite               <= ClusterIn2.TauSite;
        ClusterOut.TrimmingFlags         <= ClusterIn2.TrimmingFlags;
        ClusterOut.ShapeFlags            <= ClusterIn2.ShapeFlags;
        ClusterOut.DataValid             <= TRUE;
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

--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;

--! @brief An entity providing a ClusterSum2
--! @details Detailed description
ENTITY ClusterSum2 IS
  PORT(
    clk        : IN STD_LOGIC := '0' ; --! The algorithm clock
    ClusterIn1 : IN tCluster  := cEmptyCluster;
    ClusterIn2 : IN tCluster  := cEmptyCluster;
    ClusterOut : OUT tCluster := cEmptyCluster
  );
END ClusterSum2;

--! @brief Architecture definition for entity ClusterSum2
--! @details Detailed description
ARCHITECTURE behavioral OF ClusterSum2 IS
  SIGNAL ClusterTmp          : tCluster := cEmptyCluster;
  SIGNAL EnergyTmp , EcalTmp : STD_LOGIC_VECTOR( 21 DOWNTO 0 );
BEGIN
  PROCESS( clk )
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      IF( NOT ClusterIn1.DataValid OR NOT ClusterIn2.DataValid ) THEN
        ClusterOut <= cEmptyCluster;
      ELSE
        ClusterOut.Energy( 12 DOWNTO 0 ) <= ClusterIn1.Energy + ClusterIn2.Energy;

        ClusterOut.Phi                   <= ClusterIn2.Phi;
        ClusterOut.Eta                   <= ClusterIn2.Eta;
        ClusterOut.EtaHalf               <= ClusterIn2.EtaHalf;
        ClusterOut.LateralPosition       <= ClusterIn2.LateralPosition;
        ClusterOut.VerticalPosition      <= ClusterIn2.VerticalPosition;
        ClusterOut.EgammaCandidate       <= ClusterIn2.EgammaCandidate;
        ClusterOut.HasEM                 <= ClusterIn2.HasEM ; --ClusterIn1.HasEM OR ClusterIn2.HasEM;
        ClusterOut.HasSeed               <= ClusterIn2.HasSeed;
        ClusterOut.Isolated              <= ClusterIn2.Isolated;
        ClusterOut.NoSecondary           <= ClusterIn1.NoSecondary;
        ClusterOut.TauSite               <= ClusterIn2.TauSite;
        ClusterOut.TrimmingFlags         <= ClusterIn2.TrimmingFlags;

        ClusterOut.DataValid             <= TRUE;
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE behavioral;
