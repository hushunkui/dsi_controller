// test.v

// Generated using ACDS version 18.0 614

`timescale 1 ps / 1 ps
module test (
		input  wire [3:0] din,     //     din.export
		output wire [3:0] pad_out, // pad_out.export
		input  wire [3:0] oe       //      oe.export
	);

	altera_gpio_lite #(
		.PIN_TYPE                                 ("output"),
		.SIZE                                     (4),
		.REGISTER_MODE                            ("bypass"),
		.BUFFER_TYPE                              ("single-ended"),
		.ASYNC_MODE                               ("none"),
		.SYNC_MODE                                ("none"),
		.BUS_HOLD                                 ("false"),
		.OPEN_DRAIN_OUTPUT                        ("false"),
		.ENABLE_OE_PORT                           ("true"),
		.ENABLE_NSLEEP_PORT                       ("false"),
		.ENABLE_CLOCK_ENA_PORT                    ("false"),
		.SET_REGISTER_OUTPUTS_HIGH                ("false"),
		.INVERT_OUTPUT                            ("false"),
		.INVERT_INPUT_CLOCK                       ("false"),
		.USE_ONE_REG_TO_DRIVE_OE                  ("false"),
		.USE_DDIO_REG_TO_DRIVE_OE                 ("false"),
		.USE_ADVANCED_DDR_FEATURES                ("false"),
		.USE_ADVANCED_DDR_FEATURES_FOR_INPUT_ONLY ("false"),
		.ENABLE_OE_HALF_CYCLE_DELAY               ("true"),
		.INVERT_CLKDIV_INPUT_CLOCK                ("false"),
		.ENABLE_PHASE_INVERT_CTRL_PORT            ("false"),
		.ENABLE_HR_CLOCK                          ("false"),
		.INVERT_OUTPUT_CLOCK                      ("false"),
		.INVERT_OE_INCLOCK                        ("false"),
		.ENABLE_PHASE_DETECTOR_FOR_CK             ("false")
	) test_inst (
		.din             (din),     //     din.export
		.pad_out         (pad_out), // pad_out.export
		.oe              (oe),      //      oe.export
		.outclocken      (1'b1),    // (terminated)
		.inclock         (1'b0),    // (terminated)
		.inclocken       (1'b0),    // (terminated)
		.fr_clock        (),        // (terminated)
		.hr_clock        (),        // (terminated)
		.invert_hr_clock (1'b0),    // (terminated)
		.outclock        (1'b0),    // (terminated)
		.phy_mem_clock   (1'b0),    // (terminated)
		.mimic_clock     (),        // (terminated)
		.dout            (),        // (terminated)
		.pad_io          (),        // (terminated)
		.pad_io_b        (),        // (terminated)
		.pad_in          (4'b0000), // (terminated)
		.pad_in_b        (4'b0000), // (terminated)
		.pad_out_b       (),        // (terminated)
		.aset            (1'b0),    // (terminated)
		.aclr            (1'b0),    // (terminated)
		.sclr            (1'b0),    // (terminated)
		.nsleep          (4'b0000)  // (terminated)
	);

endmodule