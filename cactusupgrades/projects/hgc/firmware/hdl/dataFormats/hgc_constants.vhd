
library IEEE;
use IEEE.STD_LOGIC_1164.all;


package hgc_constants is
  
  constant nWafersInPanel                   : natural := 6;
  constant numberOfTriggerCellsPerEdge_high : natural := 5;
  constant numberOfTriggerCellsPerEdge_low  : natural := 4;

  -- data format 32b
  --     28   24   20   16   12    8    4    0 
  -- v 0000 0000 0000 000e eeee eeew wwrr rccc
  --  0-2 col(c) 3-5 row(r) 6-8 wafer(w) 9-16 energy(e)
  -- v valid

  constant ENERGY_OFFSET : natural := 9;
  constant ENERGY_WIDTH  : natural := 8;
  constant WAFER_OFFSET  : natural := 6;
  constant WAFER_WIDTH   : natural := 3;
  constant ROW_OFFSET    : natural := 3;
  constant ROW_WIDTH     : natural := 3;
  constant COL_OFFSET    : natural := 0;
  constant COL_WIDTH     : natural := 3;

  constant FOR_SYNTHESIS : boolean := true
  --pragma synthesis_off
  and false
  --pragma synthesis_on
  ;

  
end hgc_constants;
