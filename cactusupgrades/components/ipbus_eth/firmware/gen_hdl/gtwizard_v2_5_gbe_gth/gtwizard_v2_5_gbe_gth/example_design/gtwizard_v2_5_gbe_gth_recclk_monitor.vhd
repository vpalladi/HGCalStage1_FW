--////////////////////////////////////////////////////////////////////////////////
--//   ____  ____ 
--//  /   /\/   / 
--// /___/  \  /    Vendor: Xilinx 
--// \   \   \/     Version : 2.5
--//  \   \         Application : 7 Series FPGAs Transceivers Wizard 
--//  /   /         Filename : gtwizard_v2_5_gbe_gth_recclk_monitor.vhd
--// /___/   /\     
--// \   \  /  \ 
--//  \___\/\___\ 
--//
--//
--  Description :     This module is the ppm monitor between the
--  		      GT RxRecClk and the reference clock	 
--
--                    This module will declare that the Rx RECCLK is stable if the 
--                    recovered clock is within +/-5000PPM of the reference clock.
--
-- 
--                    There are 3 counters running on local clocks for both 
--                    recovered clocks and one for the reference clock.  The
--                    COUNTER_UPPER_VALUE parameter is the width of these
--                    counters. The PPM offset is checked when these counters 
--                    roll over.
--                    
--                    There is also a counter running on the system clock.
--                    This can be running at a much lower frequency and is
--                    running on a BUFG.  
--
--                    To set the parameters correctly here is what you need to
--                    do.  Lets assume taht the reference and recovered
--                    clocks are running at 156MHz and the system clock is
--                    running at 50MHz.
--
--                    To ensure that the interval is long enough we want to
--                    to make the COUNTER_UPPER_VALUE to be reasonable.  The
--                    CLOCK_PULSES is the number of sytem clock cycles we can
--                    expect to be off based on these frequencies:
--
--                    Example: Rec Clk and Ref Clk 156MHz, System clock 50MHz
--                             PPM Offset to tolerate +/- 5000PPM
--
--                    COUNTER_UPPER_VALUE = 15 -> 2^15 counter = 32768
--                    GCLK_COUNTER_UPPER_VALUE = 15 -> 2^15 counter = 32768
--
--                    PPM OFFSET = 5000 => 32768 * 5000/1000000 = 164
--
--                    Now we are using the system clock to do the
--                    calculations, therfore we need to scale the PPM_OFFSET
--                    accordingly.
--
--                    CLOCK_PULSES = PPM_OFFSET * sysclk_freq/refclk_freq 
--                                 = 164 * 50/156 = 52
--
--                    
--                    When the counters are checked if they are off by less
--                    than 52, we can delcare that the particular RECCLK is
--                    stable. 
--
--                    All FFs that have the _meta are metastability FFs and
--                    can be ignored from a timing perspective. The following
--                    constraint can be added to the UCF to ensure that they
--                    are ignored:
--                    
--                    INST "*_meta" TNM = "METASTABILITY_FFS";
--                    TIMESPEC "TS_METASTABILITY" = FROM FFS TO "METASTABILITY_FFS" TIG;
--
--                    IMPORTANT: Please instantiate BUFH/BUFGs on REF_CLK and RX_REC_CLK0 inputs
--
-- Module gtwizard_v2_5_gbe_gth_RECCLK_MONITOR
-- Generated by Xilinx 7 Series FPGAs Transceivers Wizard
-- 
-- 
-- (c) Copyright 2010-2012 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES. 


--*******************************************************************************

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY gtwizard_v2_5_gbe_gth_RECCLK_MONITOR is
   generic(
      COUNTER_UPPER_VALUE      : integer := 20; --ppm counter. For 2^20 cntr.  
      GCLK_COUNTER_UPPER_VALUE : integer := 20; --ppm counter. For 2^20 cntr.
      CLOCK_PULSES             : integer := 5000; 
      EXAMPLE_SIMULATION       : integer := 0         --The simulation-only constructs are not used but the
                                                      --full HW-CIRCUITRY gets simulated.
                                                      --NOTE OF CARE: This can extend the necessary simulation-
                                                      --time to beyond 600 ?s (six-hundred, sic!)

      );
   port (
	GT_RST       : in std_logic;
	REF_CLK      : in std_logic; -- Please instantiate a BUFH/BUFG on this input
	RX_REC_CLK0  : in std_logic; -- Please instantiate a BUFH/BUFG on this input
	SYSTEM_CLK   : in std_logic; -- This would be your System Clock;
	PLL_LK_DET   : in std_logic; -- This signal is verified in the Rx-FSM, 
                                     -- it can be tied high as the PLL-LK has already been 
                                     -- verified in the previous state.
	RECCLK_STABLE : out std_logic;
        EXEC_RESTART  : out std_logic
	);
end ENTITY gtwizard_v2_5_gbe_gth_RECCLK_MONITOR;


ARCHITECTURE RTL of gtwizard_v2_5_gbe_gth_RECCLK_MONITOR is

--------------------------------------------------------------------------------
-- Declaration of wires/regs
--------------------------------------------------------------------------------
type FSM is (WAIT_FOR_LOCK,REFCLK_EVENT,CALC_PPM_DIFF,CHECK_SIGN,COMP_CNTR,RESTART);
signal state : FSM;


attribute syn_keep : boolean;
signal ref_clk_cnt        : std_logic_vector (COUNTER_UPPER_VALUE-1 downto  0);
signal rec_clk0_cnt       : std_logic_vector (COUNTER_UPPER_VALUE-1 downto  0) := (others => '0');
signal rec_clk0_msb       : std_logic_vector (2 downto  1);
signal ref_clk_msb        : std_logic_vector (2 downto  1);
signal rec_clk_0_msb_meta : std_logic;
attribute syn_keep of rec_clk_0_msb_meta : signal is true;
signal ref_clk_msb_meta   : std_logic;
attribute syn_keep of ref_clk_msb_meta : signal is true;

signal sys_clk_counter            : std_logic_vector (GCLK_COUNTER_UPPER_VALUE-1 downto  0);
signal rec_clk0_compare_cnt_latch : std_logic_vector (GCLK_COUNTER_UPPER_VALUE-1 downto  0);
signal ref_clk_compare_cnt_latch  : std_logic_vector (GCLK_COUNTER_UPPER_VALUE-1 downto  0);

signal g_clk_rst_meta      : std_logic;
attribute syn_keep of g_clk_rst_meta : signal is true;
signal g_clk_rst_sync      : std_logic;
signal gt_pll_locked_meta  : std_logic;
attribute syn_keep of gt_pll_locked_meta : signal  is true;
signal gt_pll_locked_sync  : std_logic;

signal reset_logic_rec0_meta : std_logic;
attribute syn_keep of reset_logic_rec0_meta : signal  is true;
signal reset_logic_rec0_sync : std_logic;
signal reset_logic_ref_meta  : std_logic;
attribute syn_keep of reset_logic_ref_meta: signal is true;
signal reset_logic_ref_sync  : std_logic;

signal rec_clk0_edge_event : std_logic;
signal ref_clk_edge_event : std_logic_vector (1 downto 0);

signal ppm0 : std_logic_vector (GCLK_COUNTER_UPPER_VALUE-1 downto  0);

signal recclk_stable0 : std_logic;
signal reset_logic : std_logic_vector (3 downto  0);
signal ref_clk_edge_rt : std_logic_vector (1 downto  0);

signal g_clk_rst : std_logic;
signal gt_pll_locked : std_logic;
signal rec_clk0_edge : std_logic;
signal ref_clk_edge : std_logic;
signal recclk_stable0_int  : std_logic := '0';


 function simulation_func return boolean is
    --This function detects at compile-time whether the design 
    --is synthesised or simulated. For Simulation the Pragma-
    --constructs below are just comments and the variable "sim"
    --is set to True.
    --For synthesis the Pragma-constructs turn off the translation
    --between the _off and _on part and hence only the value false
    --is returned for the function.
    variable sim: boolean := false;
  begin
    sim := false;
    --pragma translate_off
    sim := true;
    --pragma translate_on
    return sim;  
  end function;
  
  constant simulation: boolean := simulation_func;

--------------------------------------------------------------------------------
-- Main Logic 
--------------------------------------------------------------------------------
begin

HW_CIRCUITRY: if not simulation or (EXAMPLE_SIMULATION = 0) generate
process (RX_REC_CLK0) begin
   if rising_edge(RX_REC_CLK0) then	
     reset_logic_rec0_meta <= reset_logic(3);
     reset_logic_rec0_sync <= reset_logic_rec0_meta;
   end if;
end process;

process (RX_REC_CLK0) begin
   if rising_edge(RX_REC_CLK0) then
        if (reset_logic_rec0_sync = '1') then
	   rec_clk0_cnt <= (others => '0');
	else 
	   rec_clk0_cnt <= rec_clk0_cnt +1;
	end if;
   end if;
end process;


process (REF_CLK) begin
   if rising_edge(REF_CLK) then	
     reset_logic_ref_meta <= reset_logic(3);
     reset_logic_ref_sync <= reset_logic_ref_meta;
   end if;
end process;

process (REF_CLK) begin
   if rising_edge(REF_CLK) then
	if (reset_logic_ref_sync = '1') then
	   ref_clk_cnt <= (others => '0');
	else 
	   ref_clk_cnt <= ref_clk_cnt +1;
	end if;
   end if;
end process;


--------------------------------------------------------------------------------
-- PPM Monitor
--
--We will also need 3 counters running on a global clock, one corresponding to 
--each of the local counters.  For this example I will use a 50MHz clock, but it 
--can be anything.  We use the global clock to sample the 20th bit of the local 
--counter, it has to be sampled twice for metastability.  Whenever we detect a 
--falling edge on that signal, it means that the counter has rolled over.  We 
--use this to latch the current count value to FFs and reset the counter.  Now 
--you have the amount of time it took to count ~1M clock cycles.  In an ideal 
--world, this would be 6.7ms or 335,602 50MHz clock periods.  You would do the 
--same for the reference clock and then you could compare both counts and ensure 
--that the difference is less than 1,678 (33.55us), if its not then you know 
--you?ve exceeded your PPM limit.  All the counts could be set as parameters and 
--could easily be adjusted based on the global clock frequency and the PPM offset
--required.
--------------------------------------------------------------------------------

-- Synchronize reset to global Clock domain
process (SYSTEM_CLK) begin
   if rising_edge(SYSTEM_CLK) then	
      g_clk_rst_meta <= GT_RST;
      g_clk_rst_sync <= g_clk_rst_meta;

      gt_pll_locked_meta <= PLL_LK_DET;
      gt_pll_locked_sync <= gt_pll_locked_meta;
   end if;
end process;

g_clk_rst     <= g_clk_rst_sync;
gt_pll_locked <= gt_pll_locked_sync;


-- Main FSM
process (SYSTEM_CLK) begin
   if rising_edge(SYSTEM_CLK) then
      if (g_clk_rst = '1') then
          state     <= WAIT_FOR_LOCK;
          ppm0      <= (others => '1');
          recclk_stable0 <= '0'; 
          EXEC_RESTART  <= '0';
      else 
          EXEC_RESTART <= '0';
          case (state) is
 	     when WAIT_FOR_LOCK =>
  	        if ( (gt_pll_locked= '1')) then
		   if (ref_clk_edge_event = "01") then
		      state <= REFCLK_EVENT;
		   else 
		      state <= WAIT_FOR_LOCK;
		   end if;
		else 
		   state <= WAIT_FOR_LOCK;
	        end if;
	     when REFCLK_EVENT =>
                 if (ref_clk_edge_event = "11") then -- two reference couter periods
		    state <= CALC_PPM_DIFF;
		 else 
		    state <= REFCLK_EVENT;
		 end if;
	      when CALC_PPM_DIFF =>
	         if (rec_clk0_edge_event = '1') then
		    ppm0 <= rec_clk0_compare_cnt_latch + ref_clk_compare_cnt_latch;			
		 end if;
			 state <= CHECK_SIGN;
	      when CHECK_SIGN =>
		  --check the sign bit - if 1'b1, then convert to binary.
		  if (ppm0(GCLK_COUNTER_UPPER_VALUE-1) = '1') then
		     ppm0 <= not ppm0 + 1;
		  end if;
		  state <= COMP_CNTR;
	       when COMP_CNTR =>
	          if (ppm0 < CLOCK_PULSES) then
	             recclk_stable0 <= '1'; 
	          else
               recclk_stable0 <= '0'; 
            end if;
	          state <= RESTART;	
	       when RESTART =>
                  state <= WAIT_FOR_LOCK;
                  EXEC_RESTART <= '1';
	       when others =>
	          state     <= WAIT_FOR_LOCK;
	          ppm0      <= (others => '1');
	          recclk_stable0 <= '0';
	   end case;
       end if;
   end if;     
end process;



-- On clock roll-over, latch counter value once and event occurance.
process (SYSTEM_CLK) begin
   if rising_edge(SYSTEM_CLK) then
      if (reset_logic(3) = '1') then
	 rec_clk0_edge_event        <= '0';
	 ref_clk_edge_event         <=  "00";
	 rec_clk0_compare_cnt_latch <= (others => '0');
	 ref_clk_compare_cnt_latch  <= (others => '0');
	 ref_clk_edge_rt            <= "00";
      else 
         if ((rec_clk0_edge='1') and(rec_clk0_edge_event='0')) then 
	    rec_clk0_edge_event        <= '1';	
	    rec_clk0_compare_cnt_latch <= sys_clk_counter; 
	 end if;
	 if (ref_clk_edge='1') then
	    ref_clk_edge_event <= ref_clk_edge_event(0)&'1';
	    --only latch it the first time around
	    if (ref_clk_edge_event(0)='0') then
  	       ref_clk_compare_cnt_latch <= sys_clk_counter; 
	    end if;
            ref_clk_edge_rt <= ref_clk_edge_rt(0) &ref_clk_edge;
	    --take the 2's complement number after we latched it
	    if ((ref_clk_edge_event = "01") and (ref_clk_edge_rt= "01")) then
	       ref_clk_compare_cnt_latch <= not ref_clk_compare_cnt_latch +1;
	    end if;
         end if;
      end if;
   end if; 
end process;

-- increment clock counters'
process (SYSTEM_CLK) begin
   if rising_edge(SYSTEM_CLK) then
      if (reset_logic(3) = '1') then
         sys_clk_counter <= (others => '0');
      else 
 	 sys_clk_counter <= sys_clk_counter + 1;
      end if;
   end if;
end process;

process (SYSTEM_CLK) begin
   if rising_edge(SYSTEM_CLK) then
      if (reset_logic(3) = '1') then
           rec_clk_0_msb_meta <= '0';
           ref_clk_msb_meta   <= '0';
	   rec_clk0_msb       <= "00";
	   ref_clk_msb        <= "00";
      else -- double flop msb count bit to system clock domain
	   rec_clk_0_msb_meta <= rec_clk0_cnt(COUNTER_UPPER_VALUE-1);
	   rec_clk0_msb       <= rec_clk0_msb(1)&rec_clk_0_msb_meta;

	   ref_clk_msb_meta <= ref_clk_cnt(COUNTER_UPPER_VALUE-1);
	   ref_clk_msb      <= ref_clk_msb(1)&ref_clk_msb_meta;
      end if;
   end if;
end process;

--falling edge detect
rec_clk0_edge <= '1' when ((rec_clk0_msb(2)='1')and (rec_clk0_msb(1)='0')) else '0';
ref_clk_edge  <= '1' when ((ref_clk_msb(2)='1')and (ref_clk_msb(1)='0')) else '0';

-- Manage counter reset/restart
process (SYSTEM_CLK) begin
   if rising_edge(SYSTEM_CLK) then
      if (g_clk_rst = '1') then
 	 reset_logic <= "1111";
      else 
	 if (state = RESTART) then
	    reset_logic <= "1111";
	 else 
	    reset_logic <= reset_logic(2 downto 0) & '0';
         end if; 
      end if;
   end if;
end process;



   RECCLK_STABLE <= recclk_stable0;
  end generate;

  SIM_shortcut: if simulation and (EXAMPLE_SIMULATION = 1)generate
    --This Generate-branch is ONLY FOR SIMULATION and is not implemented in HW.
    --The whole purpose of this shortcut-branch is to avoid huge simulation-
    --times.
    process(SYSTEM_CLK)
    begin
      if rising_edge(SYSTEM_CLK) then
        if GT_RST = '1' then
          recclk_stable0_int <= '0';
        else
          recclk_stable0_int <= PLL_LK_DET;
        end if;
      end if;
    end process;
    RECCLK_STABLE <= recclk_stable0_int;
        
  end generate;



end RTL;


