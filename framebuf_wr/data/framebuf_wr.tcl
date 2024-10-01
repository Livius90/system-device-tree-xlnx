#
# (C) Copyright 2018-2022 Xilinx, Inc.
# (C) Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
    proc framebuf_wr_generate {drv_handle} {
        set node [get_node $drv_handle]
        set dts_file [set_drv_def_dts $drv_handle]
        if {$node == 0} {
                return
        }
        pldt append $node compatible "\ \, \"xlnx,axi-frmbuf-wr-v2.2\""
        set ip [hsi::get_cells -hier $drv_handle]
        set_drv_conf_prop $drv_handle C_S_AXI_CTRL_ADDR_WIDTH xlnx,s-axi-ctrl-addr-width $node
        set_drv_conf_prop $drv_handle C_S_AXI_CTRL_DATA_WIDTH xlnx,s-axi-ctrl-data-width $node
        set vid_formats ""
        set has_bgr8 [hsi get_property CONFIG.HAS_BGR8 [hsi::get_cells -hier $drv_handle]]
        if {$has_bgr8 == 1} {
                append vid_formats " " "rgb888"
        }
        set has_rgb8 [hsi get_property CONFIG.HAS_RGB8 [hsi::get_cells -hier $drv_handle]]
        if {$has_rgb8 == 1} {
                append vid_formats " " "bgr888"
        }
        set has_rgbx8 [hsi get_property CONFIG.HAS_RGBX8 [hsi::get_cells -hier $drv_handle]]
        if {$has_rgbx8 == 1} {
                append vid_formats " " "xbgr8888"
        }
        set has_bgrx8 [hsi get_property CONFIG.HAS_BGRX8 [hsi::get_cells -hier $drv_handle]]
        if {$has_bgrx8 == 1} {
                append vid_formats " " "xrgb8888"
        }
        set has_bgrx10 [hsi get_property CONFIG.HAS_RGBX10 [hsi::get_cells -hier $drv_handle]]
        if {$has_bgrx10 == 1} {
                append vid_formats " " "xbgr2101010"
        }
        set has_uyvy8 [hsi get_property CONFIG.HAS_UYVY8 [hsi::get_cells -hier $drv_handle]]
        if {$has_uyvy8 == 1} {
                append vid_formats " " "uyvy"
        }
        set has_y8 [hsi get_property CONFIG.HAS_Y8 [hsi::get_cells -hier $drv_handle]]
        if {$has_y8 == 1} {
                append vid_formats " " "y8"
        }
        set has_y10 [hsi get_property CONFIG.HAS_Y10 [hsi::get_cells -hier $drv_handle]]
        if {$has_y10 == 1} {
                append vid_formats " " "y10"
        }
        set has_yuv8 [hsi get_property CONFIG.HAS_YUV8 [hsi::get_cells -hier $drv_handle]]
        if {$has_yuv8 == 1} {
                append vid_formats " " "vuy888"
        }
        set has_yuvx8 [hsi get_property CONFIG.HAS_YUVX8 [hsi::get_cells -hier $drv_handle]]
        if {$has_yuvx8 == 1} {
                append vid_formats " " "xvuy8888"
        }
        set has_yuvx10 [hsi get_property CONFIG.HAS_YUVX10 [hsi::get_cells -hier $drv_handle]]
        if {$has_yuvx10 == 1} {
                append vid_formats " " "yuvx2101010"
        }
        set has_yuyv8 [hsi get_property CONFIG.HAS_YUYV8 [hsi::get_cells -hier $drv_handle]]
        if {$has_yuyv8 == 1} {
                append vid_formats " " "yuyv"
        }
        set has_y_uv8_420 [hsi get_property CONFIG.HAS_Y_UV8_420 [hsi::get_cells -hier $drv_handle]]
        if {$has_y_uv8_420 == 1} {
                append vid_formats " " "nv12"
        }
        set has_y_uv8 [hsi get_property CONFIG.HAS_Y_UV8 [hsi::get_cells -hier $drv_handle]]
        if {$has_y_uv8 == 1} {
                append vid_formats " " "nv16"
        }
        set has_y_uv10 [hsi get_property CONFIG.HAS_Y_UV10 [hsi::get_cells -hier $drv_handle]]
        if {$has_y_uv10 == 1} {
                append vid_formats " " "xv20"
        }
        set has_y_uv10_420 [hsi get_property CONFIG.HAS_Y_UV10_420 [hsi::get_cells -hier $drv_handle]]
        if {$has_y_uv10_420 == 1} {
                append vid_formats " " "xv15"
        }
            set has_y_u_v8 [hsi get_property CONFIG.HAS_Y_U_V8 [hsi::get_cells -hier $drv_handle]]
            if {$has_y_u_v8 == 1} {
                    append vid_formats " " "y_u_v8"
            }
        if {![string match $vid_formats ""]} {
                add_prop "${node}" "xlnx,vid-formats" $vid_formats stringlist $dts_file
        }
        set samples_per_clk [hsi get_property CONFIG.SAMPLES_PER_CLOCK [hsi::get_cells -hier $drv_handle]]
        add_prop "$node" "xlnx,pixels-per-clock" $samples_per_clk int $dts_file 
        set dma_align [expr $samples_per_clk * 8]
        add_prop "$node" "xlnx,dma-align" $dma_align int $dts_file
        set has_interlaced [hsi get_property CONFIG.HAS_INTERLACED [hsi::get_cells -hier $drv_handle]]
        if {$has_interlaced == 1} {
                add_prop "$node" "xlnx,fid" boolean $dts_file
        }
        set dma_addr_width [hsi get_property CONFIG.AXIMM_ADDR_WIDTH [hsi::get_cells -hier $drv_handle]]
        add_prop "$node" "xlnx,dma-addr-width" $dma_addr_width int $dts_file
        add_prop "$node" "#dma-cells" 1 int $dts_file
        set max_data_width [hsi get_property CONFIG.MAX_DATA_WIDTH [hsi::get_cells -hier $drv_handle]]
        add_prop "$node" "xlnx,video-width" $max_data_width int $dts_file
        set max_rows [hsi get_property CONFIG.MAX_ROWS [hsi::get_cells -hier $drv_handle]]
        add_prop "$node" "xlnx,max-height" $max_rows int $dts_file
        set max_cols [hsi get_property CONFIG.MAX_COLS [hsi::get_cells -hier $drv_handle]]
        add_prop "$node" "xlnx,max-width" $max_cols int $dts_file

	framebuf_wr_gen_gpio_reset $drv_handle $node $dts_file

        set frmbuf_inips [get_connected_stream_ip [hsi::get_cells -hier $drv_handle] "s_axis_video"]
        foreach inip $frmbuf_inips {
                if {[string match -nocase [hsi get_property IP_NAME $inip] "v_mix"] } {
                        set ports_node [create_node -n "ports" -l frmbuf_wr_ports$drv_handle -p $node -d $dts_file]
                        add_prop "$ports_node" "#address-cells" 1 int $dts_file
                        add_prop "$ports_node" "#size-cells" 0 int $dts_file
                        set port0_node [create_node -n "port" -l frmbuf_wr$drv_handle -u 0 -p $ports_node -d $dts_file]
                        add_prop "$port0_node" "reg" 0 int $dts_file
                        set frmbuf_crtc [create_node -n "endpoint" -l v_frmbuf_wr$drv_handle -p $port0_node -d $dts_file]
                        add_prop "$frmbuf_crtc" "remote-endpoint" "mixer_out$inip" reference $dts_file
                } elseif {[string match -nocase [hsi get_property IP_NAME $inip] "ISPPipeline_accel"] } {
                        framebuf_wr_gen_frmbuf_node $inip $drv_handle $dts_file
                }
        }

    }

proc framebuf_wr_gen_frmbuf_node {ip drv_handle dts_file} {
        set proctype [get_hw_family]
        set bus_node [detect_bus_name $drv_handle]
        set vcap [create_node -n "vcap_$drv_handle" -p $bus_node -d $dts_file]
        add_prop $vcap "compatible" "xlnx,video" string $dts_file
        add_prop $vcap "dmas" "$ip 0" reference $dts_file
        add_prop $vcap "dma-names" "port0" string $dts_file
        set vcap_ports_node [create_node -n "ports" -l vcap_ports$drv_handle -p $vcap -d $dts_file]
        add_prop "$vcap_ports_node" "#address-cells" 1 int $dts_file
        add_prop "$vcap_ports_node" "#size-cells" 0 int $dts_file
        if {$proctype == "zynq"} {
                #Workaround for issue (TBF)
                set vcap_port_node [create_node -n "port" -l vcap_port$drv_handle -p $vcap_ports_node -d $dts_file]
        } else {
                set vcap_port_node [create_node -n "port" -l vcap_port$drv_handle -u 0 -p $vcap_ports_node -d $dts_file]
        }
        add_prop "$vcap_port_node" "reg" 0 int $dts_file
        add_prop "$vcap_port_node" "direction" input string $dts_file
        set vcap_in_node [create_node -n "endpoint" -l $drv_handle$ip -p $vcap_port_node -d $dts_file]
        add_prop "$vcap_in_node" "remote-endpoint" $ip$drv_handle reference $dts_file
}


    proc framebuf_wr_gen_gpio_reset {drv_handle node dts_file} {
	set pins [get_source_pins [hsi get_pins -of_objects [hsi get_cells -hier [hsi get_cells -hier $drv_handle]] "ap_rst_n"]]
	foreach pin $pins {
		set sink_periph [hsi get_cells -of_objects $pin]
		if {[llength $sink_periph]} {
			set sink_ip [hsi get_property IP_NAME $sink_periph]
			if {[string match -nocase $sink_ip "xlslice"]} {
				set gpio [hsi get_property CONFIG.DIN_FROM $sink_periph]
				set pins [hsi get_pins -of_objects [hsi get_nets -of_objects [hsi get_pins -of_objects $sink_periph "Din"]]]
				foreach pin $pins {
					set periph [hsi get_cells -of_objects $pin]
					if {[llength $periph]} {
						set ip [hsi get_property IP_NAME $periph]
						if { $ip in { "versal_cips" "ps_wizard" }} {
							# As versal has only bank0 for MIOs
							set gpio [expr $gpio + 26]
							add_prop "$node" "reset-gpios" "gpio0 $gpio 1" reference $dts_file
							break
						}
						if {[string match -nocase $ip "zynq_ultra_ps_e"]} {
							set gpio [expr $gpio + 78]
							add_prop "$node" "reset-gpios" "gpio $gpio 1" reference $dts_file
							break
						}
						if {[string match -nocase $ip "axi_gpio"]} {
							add_prop "$node" "reset-gpios" "$periph $gpio 1" reference $dts_file
						}
					} else {
						dtg_warning "$drv_handle peripheral is NULL for the $pin $periph"
					}
				}
			}
		} else {
			dtg_warning "$drv_handle peripheral is NULL for the $pin $sink_periph"
		}
	}
}
