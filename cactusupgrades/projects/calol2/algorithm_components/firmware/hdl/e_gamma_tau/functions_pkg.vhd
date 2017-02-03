--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;
--! Using NUMERIC TYPES
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.math_real.ALL ; -- for UNIFORM , TRUNC functions

--! Using the Calo-L2 common constants
USE work.constants.ALL;
--! Using the Calo-L2 common functions
USE work.functions.ALL;

--! Using the Calo-L2 "Cluster" data-types
USE work.Cluster_types.ALL;

--! Using the Calo-L2 "tower" data-types
USE work.tower_types.ALL;
--! Using the Calo-L2 "jet" data-types
USE work.jet_types.ALL;

--! Writing to and from files
USE STD.TEXTIO.ALL;

PACKAGE Cluster_functions IS

  FUNCTION ToIsolationRegion( aTower : tTower ; UseTotalEnergy : BOOLEAN ) RETURN tIsolationRegion;
  FUNCTION ToIsolationRegion( aJet   : tJet ) RETURN tIsolationRegion;

  FUNCTION ">" ( Left , Right        : tCluster ) RETURN BOOLEAN;


END PACKAGE cluster_functions;

PACKAGE BODY cluster_functions IS

  FUNCTION ToIsolationRegion( aTower : tTower ; UseTotalEnergy : BOOLEAN ) RETURN tIsolationRegion IS
    VARIABLE ret                     : tIsolationRegion;
  BEGIN
      IF UseTotalEnergy THEN
        ret.Energy := "0000000" & aTower.Energy;
      ELSE
        ret.Energy := "0000000" & aTower.Ecal;
      END IF;
      ret.DataValid := aTower.DataValid;
      RETURN ret;
  END ToIsolationRegion;

  FUNCTION ToIsolationRegion( aJet : tJet ) RETURN tIsolationRegion IS
    VARIABLE ret                   : tIsolationRegion;
  BEGIN
      ret.Energy    := aJet.Energy;
      ret.DataValid := aJet.DataValid;
      RETURN ret;
  END ToIsolationRegion;

  FUNCTION ">" ( Left , Right : tCluster ) RETURN BOOLEAN IS
  BEGIN
-- Prioritize Valid Data
    IF( NOT Left.DataValid ) THEN
      RETURN FALSE;
    END IF;

    IF( NOT Right.DataValid ) THEN
      RETURN TRUE;
    END IF;

-- Prioritize by energy
    IF for_synthesis THEN
      RETURN( Left.Energy > Right.Energy );
    ELSE
      IF( Left.Energy /= Right.Energy ) THEN RETURN Left.Energy > Right.Energy ; END IF;
      IF( Left.EtaHalf /= Right.EtaHalf ) THEN RETURN Left.EtaHalf > Right.EtaHalf ; END IF;
      IF( Left.Eta /= Right.Eta ) THEN RETURN Left.Eta > Right.Eta ; END IF;
      IF( Left.Phi /= Right.Phi ) THEN RETURN Left.Phi > Right.Phi ; END IF;
      RETURN TRUE;
    END IF;
  END FUNCTION;

END Cluster_functions;
