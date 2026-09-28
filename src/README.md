# Source architecture

This directory is organized around the implemented video path rather than the
chronological order in which features were added.

## Active paths

```text
BT.1120 1280x1024
  |
  +-- input/Bt1120Decoder (single SAV/EAV parser)
      |
      +-- dvp/DvpFormatter + CDC ------------------------> DVP/X2000
      |
      +-- scaler/Downsample2xYuv422 (1280x1024 -> 640x512)
          -> common/VideoAsyncFifo (BT clock -> scaler clock)
          -> scaler/BicubicScaler640x512 (640x512 -> 720x576)
          -> common/VideoAsyncFifo (scaler clock -> AXI clock)
          -> overlay/VideoHorizontalFlipYuv422
          -> overlay/VideoCrosshairYuv422
          -> overlay/HyperRamMaskOverlayYuv422
          -> memory/HyperRamVideoBt656
          -> PAL/BT.656 -> output/Adv7391Top -> CVBS
```

`HyperRamMaskOverlayYuv422` is the four-window OSD compositor.  It reads up to
four mutually non-overlapping bitmaps from HyperRAM and keys them onto the
stream.  A bitmap is **1 bit per pixel**, packed MSB-first within each row
(bit 7 is the leftmost pixel) with a **compact row stride of `width/8` bytes**;
bit = 1 emits solid white `16'h80EB`, bit = 0 passes the video pixel through.
There is no alpha path.  Window size and the eight A/B base addresses are
elaboration-time parameters (`OSD0..3_WIDTH/HEIGHT/BASE_A/BASE_B`); window
position, per-route enable and per-route A/B select are runtime registers behind
`MaskControlRegs` and commit atomically.  The bitmaps live in
`0x00A0_0000-0x00BF_FFFF`, 256 KB per route per buffer.

`Bt1120Decoder` is the only active module that recognizes BT.1120 embedded
SAV/EAV timing.  It emits a canonical native-resolution stream plus decoded
coordinates.  `DvpFormatter` and `Downsample2xYuv422` consume that same stream,
so the two output branches cannot disagree about frame or line boundaries.

## Directory ownership

- `input/`: the single BT.1120 timing decoder and canonical stream source.
- `dvp/`: native-resolution 16-bit-to-8-bit DVP formatting and its CDC.
- `common/`: reusable streaming/CDC blocks.
- `scaler/`: independent downsample and bicubic scale stages.
- `overlay/`: independent flip and crosshair stages plus the four-window OSD
  compositor (1 bit/pixel bitmaps held in HyperRAM).
- `memory/`: AXI arbitration, monitoring and HyperRAM frame buffering.
- `output/`: PAL/BT.656 and ADV7391 generated output logic.
- `control/`: UART command routing, the OSD control registers and bitmap upload
  control.
- `debug/`: VIO/clock/soft-core diagnostic helpers.
- `legacy/`: inactive historical test and picture-loader modules; not listed
  as active Efinity design sources.

`top.v` directly connects every functional stage and remains the board-level
integration point; no active subsystem wrapper hides multiple stages.  The old
dual-parser front end and preprocessing wrapper remain under `legacy/` only for
comparison and are excluded from Efinity design sources.  Generated files such
as `output/Adv7391Top.v` should not be manually split or reformatted.
# Electronic zoom (0xCC)

The four source-line caches in `ElectronicZoomFrameBuffer.v` use synchronous
256-bit block-RAM reads and a reusable 32-pixel register window.  Do not change
them back to asynchronously indexed line arrays: that prevents Efinity RAM
inference and can exceed the Ti60 LUT/FF capacity during packing.

`ElectronicZoomUartController.v` clips and validates the commanded ROI.
`ElectronicZoomFrameBuffer.v` records the canonical 1280x1024 `{C,Y}` stream
in three raw HyperRAM buffers (`0x01000000`, `0x01280000`, `0x01500000`)
using 256-byte AXI bursts.  The writer/committed/reader buffers follow a
three-buffer ownership protocol so a live capture never overwrites the frame
still being read by the calculator.  Four source rows are cached and
Catmull-Rom bicubic interpolation regenerates a canonical 1280x1024 stream.
That one stream feeds both `DvpFormatter` and `Downsample2xYuv422`, so DVP
and CVBS always use the same zoomed image.  Enable/disable and geometry
changes take effect only at a full frame boundary.

The minimum ROI is 320x256. Horizontal ROI start/width are rounded to even
pixels to preserve YUV422 Cb/Cr parity. Out-of-range rectangles are clipped.
