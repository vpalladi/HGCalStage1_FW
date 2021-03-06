//*****************************************************************************
// (c) Copyright 2008 - 2013 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor                : Xilinx
// \   \   \/     Version               : %version
//  \   \         Application           : MIG
//  /   /         Filename              : qdr_rld_of_pre_fifo.v
// /___/   /\     Date Last Modified    : $date$
// \   \  /  \    Date Created          : Feb 08 2011
//  \___\/\___\
//
//Device            : 7 Series
//Design Name       : QDRII+ SRAM / RLDRAM II SDRAM
//Purpose           : Extends the depth of a PHASER OUT_FIFO up to 4 entries
//Reference         :
//Revision History  :
//*****************************************************************************

/******************************************************************************
**$Id: qdr_rld_of_pre_fifo.v,v 1.1 2011/06/02 08:35:07 mishra Exp $
**$Date: 2011/06/02 08:35:07 $
**$Author: mishra $
**$Revision: 1.1 $
**$Source: /devl/xcs/repo/env/Databases/ip/src2/O/mig_7series_v1_3/data/dlib/7series/ddr3_sdram/verilog/rtl/phy/qdr_rld_of_pre_fifo.v,v $
******************************************************************************/

`timescale 1 ps / 1 ps

module mig_7series_v1_8_qdr_rld_of_pre_fifo #
  (
   parameter TCQ   = 100,             // clk->out delay (sim only)
   parameter DEPTH = 4,               // # of entries
   parameter WIDTH = 32               // data bus width
   )
  (
   input              clk,            // clock
   input              rst,            // synchronous reset
   input              full_in,        // FULL flag from OUT_FIFO
   input              wr_en_in,       // write enable from controller
   input [WIDTH-1:0]  d_in,           // write data from controller
   output             wr_en_out,      // write enable to OUT_FIFO
   output [WIDTH-1:0] d_out           // write data to OUT_FIFO
   );
  
  // # of bits used to represent read/write pointers
  localparam PTR_BITS 
             = (DEPTH == 2) ? 1 : 
               ((DEPTH == 3) || (DEPTH == 4)) ? 2 : 
               (((DEPTH == 5) || (DEPTH == 6) || 
                 (DEPTH == 7) || (DEPTH == 8)) ? 3 : 'bx);

  integer i;
  
  reg [WIDTH-1:0]    mem[0:DEPTH-1] /* synthesis syn_ramstyle = "registers" */;
(* keep = "true", max_fanout = 3 *)   reg [2:0]          my_empty;
(* keep = "true", max_fanout = 3 *)   reg [1:0]          my_full;
(* keep = "true", max_fanout = 10 *)  reg [PTR_BITS-1:0] rd_ptr;
  // synthesis attribute MAX_FANOUT of rd_ptr is 10; 
(* keep = "true", max_fanout = 10 *)  reg [PTR_BITS-1:0] wr_ptr;
  // synthesis attribute MAX_FANOUT of wr_ptr is 10; 
  wire [PTR_BITS-1:0] nxt_rd_ptr;
  wire [PTR_BITS-1:0] nxt_wr_ptr;
  wire [WIDTH-1:0] mem_out;
  wire wr_en;

  assign d_out = my_empty[0] ? d_in : mem_out;
  assign wr_en_out = !full_in && (!my_empty[1] || wr_en_in);
  assign wr_en = wr_en_in & ((!my_empty[2] & !full_in)|(!my_full[1] & full_in));

  always @ (posedge clk)
    if (wr_en)
      mem[wr_ptr] <= #TCQ d_in;

  assign mem_out = mem [rd_ptr];

  assign nxt_rd_ptr = (rd_ptr + 1'b1)%DEPTH;

  always @ (posedge clk)
  begin
    if (rst)
      rd_ptr <= 'b0;
    else if ((!my_empty[2]) & (!full_in))
      rd_ptr <= nxt_rd_ptr;
  end

  always @ (posedge clk)
  begin
    if (rst)
      my_empty <= 3'b111;
    else if (my_empty[2] & !my_full[1] & full_in & wr_en_in)
      my_empty <= 3'b000;
    else if (!my_empty[2] & !my_full[1] & !full_in & !wr_en_in) begin
      my_empty[0] <= (nxt_rd_ptr == wr_ptr);
      my_empty[1] <= (nxt_rd_ptr == wr_ptr);
      my_empty[2] <= (nxt_rd_ptr == wr_ptr);
    end
  end

  assign nxt_wr_ptr = (wr_ptr + 1'b1)%DEPTH;

  always @ (posedge clk)
  begin
    if (rst)
      wr_ptr <= 'b0;
    else if ((wr_en_in) & ((!my_empty[2] & !full_in) | (!my_full[1] & full_in)))
      wr_ptr <= nxt_wr_ptr;
  end

  always @ (posedge clk)
  begin
    if (rst)
      my_full <= 2'b00;
    else if (!my_empty[2] & my_full[0] & !full_in & !wr_en_in)
      my_full <= 2'b00;
    else if (!my_empty[2] & !my_full[0] & full_in & wr_en_in) begin
      my_full[0] <= (nxt_wr_ptr == rd_ptr);
      my_full[1] <= (nxt_wr_ptr == rd_ptr);
    end
  end

endmodule
