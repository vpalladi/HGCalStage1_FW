-- top_decl
--
-- Defines constants for the whole device
--
-- Dave Newbold, June 2014

library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.mp7_top_decl.all;

package top_decl is
	
	constant ALGO_REV: std_logic_vector(31 downto 0) := X"00010000";
	constant BUILDSYS_BUILD_TIME: std_logic_vector(31 downto 0) := X"00000000"; -- To be overwritten at build time
	constant BUILDSYS_BLAME_HASH: std_logic_vector(31 downto 0) := X"00000000"; -- To be overwritten at build time
	  
	constant LHC_BUNCH_COUNT: integer := 3564;
	constant LB_ADDR_WIDTH: integer := 10;
	constant DR_ADDR_WIDTH: integer := 9;
	constant RO_CHUNKS: integer := 4;
	constant CLOCK_RATIO: integer := 6;
	constant CLOCK_AUX_RATIO: clock_ratio_array_t := (2, 4, 6);
	constant PAYLOAD_LATENCY: integer := 2;
	constant DAQ_N_BANKS: integer := 4; -- Number of readout banks
	constant DAQ_TRIGGER_MODES: integer := 2; -- Number of trigger modes for readout
	constant DAQ_N_CAP_CTRLS: integer := 4; -- Number of capture controls per trigger mode
	constant ZS_ENABLED: boolean := FALSE;
	
-- mgt -> chk -> buf -> fmt -> (algo) -> (fmt) -> buf -> chk -> mgt

	constant REGION_CONF: region_conf_array_t := (
		0 => (gth_10g, u_crc32, buf, no_fmt, buf, u_crc32, gth_10g, 0, 0) -- 0
	);

end top_decl;

