#
# (C) Copyright 2017 Xilinx, Inc.
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

namespace eval sdfec {
proc generate {drv_handle} {
	set node [get_node $drv_handle]
	set dts_file [set_drv_def_dts $drv_handle]
	set compatible [get_comp_str $drv_handle]
	set_drv_prop $drv_handle compatible "$compatible" stringlist
	set ldpc_decode [get_property CONFIG.LDPC_Decode [hsi::get_cells -hier $drv_handle]]
	set ldpc_encode [get_property CONFIG.LDPC_Encode [hsi::get_cells -hier $drv_handle]]
	set turbo_decode [get_property CONFIG.Turbo_Decode [hsi::get_cells -hier $drv_handle]]
	if {[string match -nocase $turbo_decode "true"]} {
		set sdfec_code "turbo"
	} else {
		set sdfec_code "ldpc"
	}
	set_drv_property $drv_handle xlnx,sdfec-code $sdfec_code string
	set sdfec_dout_words [get_property CONFIG.C_S_DOUT_WORDS_MODE [hsi::get_cells -hier $drv_handle]]
	set sdfec_dout_width [get_property CONFIG.DOUT_Lanes [hsi::get_cells -hier $drv_handle]]
	set sdfec_din_words [get_property CONFIG.C_S_DIN_WORDS_MODE [hsi::get_cells -hier $drv_handle]]
	set sdfec_din_width [get_property CONFIG.DIN_Lanes [hsi::get_cells -hier $drv_handle]]
	set_drv_property $drv_handle xlnx,sdfec-dout-words $sdfec_dout_words int
	set_drv_property $drv_handle xlnx,sdfec-dout-width $sdfec_dout_width int
	set_drv_property $drv_handle xlnx,sdfec-din-words  $sdfec_din_words int
	set_drv_property $drv_handle xlnx,sdfec-din-width  $sdfec_din_width int
}
}
