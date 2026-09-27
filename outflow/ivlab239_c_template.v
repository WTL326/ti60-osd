
// Efinity Top-level template
// Version: 2026.1.132.4.5
// Date: 2026-09-22 21:57

// Copyright (C) 2013 - 2026 Efinix Inc. All rights reserved.

// This file may be used as a starting point for Efinity synthesis top-level target.
// The port list here matches what is expected by Efinity constraint files generated
// by the Efinity Interface Designer.

// To use this:
//     #1)  Save this file with a different name to a different directory, where source files are kept.
//              Example: you may wish to save as ivlab239_c.v
//     #2)  Add the newly saved file into Efinity project as design file
//     #3)  Edit the top level entity in Efinity project to:  ivlab239_c
//     #4)  Insert design content.


module ivlab239_c
(
  (* syn_peri_port = 0 *) input DEBUG_UART_RX,
  (* syn_peri_port = 0 *) input UART_FPGA_TX,
  (* syn_peri_port = 0 *) input UART_ST_FR,
  (* syn_peri_port = 0 *) input hbramClk_pll_locked,
  (* syn_peri_port = 0 *) input pll_bt1120_locked,
  (* syn_peri_port = 0 *) input adv_ctrl_clk,
  (* syn_peri_port = 0 *) input clk_da,
  (* syn_peri_port = 0 *) input clk50M,
  (* syn_peri_port = 0 *) input hbramClk,
  (* syn_peri_port = 0 *) input hbramClk_cal,
  (* syn_peri_port = 0 *) input clk,
  (* syn_peri_port = 0 *) input clk_dvp,
  (* syn_peri_port = 0 *) input pll_bt1120_fb,
  (* syn_peri_port = 0 *) input clk_scaler,
  (* syn_peri_port = 0 *) input hbramClk_cal_2,
  (* syn_peri_port = 0 *) input bt1120_clk,
  (* syn_peri_port = 0 *) input pll_hbram_ref_fb,
  (* syn_peri_port = 0 *) input hbramClk90,
  (* syn_peri_port = 0 *) input hbram_ref,
  (* syn_peri_port = 0 *) input intosc_clkout,
  (* syn_peri_port = 0 *) input jtag_inst1_CAPTURE,
  (* syn_peri_port = 0 *) input jtag_inst1_DRCK,
  (* syn_peri_port = 0 *) input jtag_inst1_RESET,
  (* syn_peri_port = 0 *) input jtag_inst1_RUNTEST,
  (* syn_peri_port = 0 *) input jtag_inst1_SEL,
  (* syn_peri_port = 0 *) input jtag_inst1_SHIFT,
  (* syn_peri_port = 0 *) input jtag_inst1_TCK,
  (* syn_peri_port = 0 *) input jtag_inst1_TDI,
  (* syn_peri_port = 0 *) input jtag_inst1_TMS,
  (* syn_peri_port = 0 *) input jtag_inst1_UPDATE,
  (* syn_peri_port = 0 *) input jtag_inst2_autodbg_CAPTURE__,
  (* syn_peri_port = 0 *) input jtag_inst2_autodbg_DRCK__,
  (* syn_peri_port = 0 *) input jtag_inst2_autodbg_RESET__,
  (* syn_peri_port = 0 *) input jtag_inst2_autodbg_RUNTEST__,
  (* syn_peri_port = 0 *) input jtag_inst2_autodbg_SEL__,
  (* syn_peri_port = 0 *) input jtag_inst2_autodbg_SHIFT__,
  (* syn_peri_port = 0 *) input jtag_inst2_autodbg_TCK__,
  (* syn_peri_port = 0 *) input jtag_inst2_autodbg_TDI__,
  (* syn_peri_port = 0 *) input jtag_inst2_autodbg_TMS__,
  (* syn_peri_port = 0 *) input jtag_inst2_autodbg_UPDATE__,
  (* syn_peri_port = 0 *) input CFG_D0_IN,
  (* syn_peri_port = 0 *) input CFG_D1_IN,
  (* syn_peri_port = 0 *) input CFG_D2_IN,
  (* syn_peri_port = 0 *) input CFG_D3_IN,
  (* syn_peri_port = 0 *) input DA_SCL_IN,
  (* syn_peri_port = 0 *) input DA_SDA_IN,
  (* syn_peri_port = 0 *) input [15:0] bt1120_data,
  (* syn_peri_port = 0 *) input [15:0] hbc_dq_IN_HI,
  (* syn_peri_port = 0 *) input [15:0] hbc_dq_IN_LO,
  (* syn_peri_port = 0 *) input [15:0] hbc_dq_2_IN_HI,
  (* syn_peri_port = 0 *) input [15:0] hbc_dq_2_IN_LO,
  (* syn_peri_port = 0 *) input [1:0] hbc_rwds_IN_HI,
  (* syn_peri_port = 0 *) input [1:0] hbc_rwds_IN_LO,
  (* syn_peri_port = 0 *) input [1:0] hbc_rwds_2_IN_HI,
  (* syn_peri_port = 0 *) input [1:0] hbc_rwds_2_IN_LO,
  (* syn_peri_port = 0 *) input my_pll_pin,
  (* syn_peri_port = 0 *) output DEBUG_UART_TX,
  (* syn_peri_port = 0 *) output UART_FPGA_RX,
  (* syn_peri_port = 0 *) output UART_SR_FT,
  (* syn_peri_port = 0 *) output hbramClk_pll_rstn,
  (* syn_peri_port = 0 *) output [2:0] hbc_cal_SHIFT,
  (* syn_peri_port = 0 *) output hbc_cal_SHIFT_ENA,
  (* syn_peri_port = 0 *) output [4:0] hbc_cal_SHIFT_SEL,
  (* syn_peri_port = 0 *) output sysClk_pll_rstn,
  (* syn_peri_port = 0 *) output jtag_inst1_TDO,
  (* syn_peri_port = 0 *) output jtag_inst2_autodbg_TDO__,
  (* syn_peri_port = 0 *) output CFG_D0_OUT,
  (* syn_peri_port = 0 *) output CFG_D0_OE,
  (* syn_peri_port = 0 *) output CFG_D1_OUT,
  (* syn_peri_port = 0 *) output CFG_D1_OE,
  (* syn_peri_port = 0 *) output CFG_D2_OUT,
  (* syn_peri_port = 0 *) output CFG_D2_OE,
  (* syn_peri_port = 0 *) output CFG_D3_OUT,
  (* syn_peri_port = 0 *) output CFG_D3_OE,
  (* syn_peri_port = 0 *) output CFG_DCLK,
  (* syn_peri_port = 0 *) output CFG_nCSO,
  (* syn_peri_port = 0 *) output DA_HS,
  (* syn_peri_port = 0 *) output [7:0] DA_P,
  (* syn_peri_port = 0 *) output DA_RST,
  (* syn_peri_port = 0 *) output DA_SCL_OUT,
  (* syn_peri_port = 0 *) output DA_SCL_OE,
  (* syn_peri_port = 0 *) output DA_SDA_OUT,
  (* syn_peri_port = 0 *) output DA_SDA_OE,
  (* syn_peri_port = 0 *) output DA_VS,
  (* syn_peri_port = 0 *) output [7:0] dvp_data,
  (* syn_peri_port = 0 *) output dvp_hs,
  (* syn_peri_port = 0 *) output dvp_vs,
  (* syn_peri_port = 0 *) output hbc_cal_pass,
  (* syn_peri_port = 0 *) output hbc_ck_n_HI,
  (* syn_peri_port = 0 *) output hbc_ck_n_LO,
  (* syn_peri_port = 0 *) output hbc_ck_n_2_HI,
  (* syn_peri_port = 0 *) output hbc_ck_n_2_LO,
  (* syn_peri_port = 0 *) output hbc_ck_p_HI,
  (* syn_peri_port = 0 *) output hbc_ck_p_LO,
  (* syn_peri_port = 0 *) output hbc_ck_p_2_HI,
  (* syn_peri_port = 0 *) output hbc_ck_p_2_LO,
  (* syn_peri_port = 0 *) output hbc_cs_n,
  (* syn_peri_port = 0 *) output hbc_cs_n_2,
  (* syn_peri_port = 0 *) output [15:0] hbc_dq_OUT_HI,
  (* syn_peri_port = 0 *) output [15:0] hbc_dq_OUT_LO,
  (* syn_peri_port = 0 *) output [15:0] hbc_dq_OE,
  (* syn_peri_port = 0 *) output [15:0] hbc_dq_2_OUT_HI,
  (* syn_peri_port = 0 *) output [15:0] hbc_dq_2_OUT_LO,
  (* syn_peri_port = 0 *) output [15:0] hbc_dq_2_OE,
  (* syn_peri_port = 0 *) output hbc_rst_n,
  (* syn_peri_port = 0 *) output hbc_rst_n_2,
  (* syn_peri_port = 0 *) output [1:0] hbc_rwds_OUT_HI,
  (* syn_peri_port = 0 *) output [1:0] hbc_rwds_OUT_LO,
  (* syn_peri_port = 0 *) output [1:0] hbc_rwds_OE,
  (* syn_peri_port = 0 *) output [1:0] hbc_rwds_2_OUT_HI,
  (* syn_peri_port = 0 *) output [1:0] hbc_rwds_2_OUT_LO,
  (* syn_peri_port = 0 *) output [1:0] hbc_rwds_2_OE,
  (* syn_peri_port = 0 *) output intosc_en
);


endmodule

