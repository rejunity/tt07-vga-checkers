/*
 * Copyright (c) 2024 ReJ aka Renaldas Zioma
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_rejunity_vga(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  reg [9:0] counter;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );
  
  wire [9:0] moving_x = pix_x + counter*16;
  wire [9:0] moving_y = pix_y + counter*2;

  wire [9:0] moving_x2 = pix_x + counter*7;
  wire [9:0] moving_y2 = pix_y + counter + counter/2;

  wire [9:0] moving_x3 = pix_x + counter*4;
  wire [9:0] moving_y3 = pix_y + counter/2;

  wire [9:0] moving_x4 = pix_x + counter*2;
  wire [9:0] moving_y4 = pix_y + counter/4;

  wire [9:0] moving_x5 = pix_x + counter/2;
  wire [9:0] moving_y5 = pix_y + counter/6;

  wire a = moving_x[8] ^ moving_y[8];
  wire b = moving_x2[7] ^ moving_y2[7];
  wire c = moving_x3[6] ^ moving_y3[6];
  wire d = moving_x4[5] ^ moving_y4[5];
  wire e = moving_x5[4] ^ moving_y5[4];

  // wire x = a | b | c | d | e;

  // assign {R, G, B} = 
  //     video_active ? 
  //       (a ? 6'b11_11_01 :
  //         (b ? 6'b11_10_01 : 
  //           (c ? 6'b11_01_00 : 
  //             (d ? 6'b10_00_00 : 6'b00_00_00)))) : 6'b00_00_00;

  assign {R, G, B} = 
      video_active ? 
        // (a ? (pix_y[0] ^ pix_x[0] ? 6'b11_11_11 : 6'b00_00_00) :
        ((a & (pix_y[1] ^ pix_x[0])) ? 6'b11_10_10 :
          (b & (~pix_y[0] ^ pix_x[1]) ? 6'b11_01_01 : 
            (c ? 6'b10_00_00 : 
              (d ? 6'b01_00_00 :
                (e & (pix_y[1] ^ pix_x[0]) ? 6'b01_00_00 : 6'b00_00_00))))) : 6'b00_00_00;

  // assign {R, G, B} = 
  //     video_active ? 
  //       // (a ? (pix_y[0] ^ pix_x[0] ? 6'b11_11_11 : 6'b00_00_00) :
  //       ((a & (pix_y[1] ^ pix_x[0])) ? 6'b11_11_11 :
  //         (b & (~pix_y[0] ^ pix_x[1]) ? 6'b11_10_10 : 
  //           (c ? 6'b10_00_00 : 
  //             (d ? 6'b01_00_00 :
  //               (e ? 6'b01_00_00 : 6'b00_00_00))))) : 6'b00_00_00;


  // assign {R, G, B} = 
  //     video_active ? 
  //       // (a ? (pix_y[0] ^ pix_x[0] ? 6'b11_11_11 : 6'b00_00_00) :
  //       ((a & (pix_y[1] ^ pix_x[0])) ? 6'b11_11_11 :
  //         (b & (~pix_y[0] ^ pix_x[1]) ? 6'b11_10_10 : 
  //           (c ? 6'b10_00_00 : 
  //             (d ? 6'b01_00_00 : 6'b00_00_00)))) : 6'b00_00_00;


  // assign {R, G, B} = 
  //     video_active ? 
  //       // (a ? (pix_y[0] ^ pix_x[0] ? 6'b11_11_11 : 6'b00_00_00) :
  //       ((a & (pix_y[0] ^ pix_x[0])) ? 6'b11_11_11 :
  //         (b ? 6'b11_00_01 : 
  //           (c ? 6'b10_00_00 : 
  //             (d ? 6'b01_00_00 : 6'b00_00_00)))) : 6'b00_00_00;


    // video_active ? 
    //   a ? 6'b11_11_00 : 6'b00_00_00;
  

  // assign R = video_active ? {moving_x[6], moving_y[6]} : 2'b00;
  // assign R = video_active ? x * 2'b11 : 2'b00;
  // assign G = 2'b00;//video_active ? {moving_x[6], pix_y[2]} : 2'b00;
  // assign B = 2'b00;//video_active ? {moving_x[7], pix_y[5]} : 2'b00;
  
  always @(posedge vsync) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end
  
endmodule
