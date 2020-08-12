#
# (C) Copyright 2018 Xilinx, Inc.
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

namespace eval hdmi_tx_ss {
proc generate {drv_handle} {
#	set node [gen_peripheral_nodes $drv_handle]
	set node [get_node $drv_handle]
	if {$node == 0} {
		return
	}
#	set compatible [get_comp_str $drv_handle]
#	set compatible [append compatible " " "xlnx,v-hdmi-tx-ss-3.1"]
#	set_drv_prop $drv_handle compatible "$compatible" stringlist
	pldt append $node compatible "\ \, \"xlnx,v-hdmi-tx-ss-3.1\""
}
}
