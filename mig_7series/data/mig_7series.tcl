#
# (C) Copyright 2014-2022 Xilinx, Inc.
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

proc mig_7series_generate {drv_handle} {
        global apu_proc_ip
        set apu_proc_found 0
        set baseaddr [get_baseaddr $drv_handle no_prefix]
        set memory_node [create_node -n "memory" -l "${drv_handle}_memory" -u $baseaddr -p root -d "system-top.dts"]
        set slave [hsi::get_cells -hier ${drv_handle}]

        # TODO: need to take main_memory value as user input. (as done in DTG)
        set drv_ip [get_ip_property $drv_handle IP_NAME]
        set proclist [hsi::get_cells -hier -filter {IP_TYPE==PROCESSOR}]
        foreach procc $proclist {
                set proc_ip_name [get_ip_property $procc IP_NAME]
                if { $proc_ip_name == $apu_proc_ip} {
                        if {$apu_proc_found == 1} {
                                continue
                        }
                        set apu_proc_found 1
                }

                set ip_mem_handles [hsi::get_mem_ranges $slave]
                set firstelement [lindex $ip_mem_handles 0]
                set index [lsearch [hsi::get_mem_ranges -of_objects $procc] [hsi::get_cells -hier $firstelement]]
                if {$index == "-1"} {
                        continue
                }

                foreach bank ${ip_mem_handles} {
                        set index [lsearch -start $index [hsi::get_mem_ranges -of_objects $procc] [hsi::get_cells -hier $bank]]
                        set base [hsi get_property BASE_VALUE [lindex [hsi::get_mem_ranges -of_objects $procc] $index]]
                        set high [hsi get_property HIGH_VALUE [lindex [hsi::get_mem_ranges -of_objects $procc] $index]]

                        set dts_file "system-top.dts"
                        set proctype [get_hw_family]
                        set size [format 0x%x [expr {${high} - ${base} + 1}]]
                        # Check the 32-bit cell size boundary address (i.e. 0XFFFFFFFF (4GB)).
                        # Adding 1 to it when start address is 0 will lead to overflow.
                        if {[string length [string trimleft $high "0x"]] == 8 && [string length [string trimleft $size "0x"]] > 8} {
                                set size [format 0x%x [expr {${high} - ${base}}]]
                        }

                        if {[is_zynqmp_platform $proctype] || [string match -nocase $proctype "versal"]} {
                                if {[regexp -nocase {0x([0-9a-f]{9})} "$base" match]} {
                                        set temp $base
                                        set temp [string trimleft [string trimleft $temp 0] x]
                                        set len [string length $temp]
                                        set rem [expr {${len} - 8}]
                                        set high_base "0x[string range $temp $rem $len]"
                                        set low_base "0x[string range $temp 0 [expr {${rem} - 1}]]"
                                        set low_base [format 0x%08x $low_base]
                                        if {[regexp -nocase {0x([0-9a-f]{9})} "$size" match]} {
                                                set temp $size
                                                set temp [string trimleft [string trimleft $temp 0] x]
                                                set len [string length $temp]
                                                set rem [expr {${len} - 8}]
                                                set high_size "0x[string range $temp $rem $len]"
                                                set low_size  "0x[string range $temp 0 [expr {${rem} - 1}]]"
                                                set low_size [format 0x%08x $low_size]
                                                set reg "$low_base $high_base $low_size $high_size"
                                        } else {
                                                set reg "$low_base $high_base 0x0 $size"
                                        }
                                } else {
                                        set reg "0x0 $base 0x0 $size"
                                }
                        } else {
                                set reg "$base $size"
                        }
                       if {[string match -nocase [hsi get_property IP_NAME $procc] "psu_cortexr5"] || [string match -nocase [hsi get_property IP_NAME $procc] "psv_cortexr5"]} {
                                set_memmap "${drv_handle}_memory" r5 $reg
                        }
                        if {[string match -nocase [hsi get_property IP_NAME $procc] "psu_cortexa53"] || [string match -nocase [hsi get_property IP_NAME $procc] "psv_cortexa72"]} {
                                set_memmap "${drv_handle}_memory" a53 $reg
                        }
                        if {[string match -nocase [hsi get_property IP_NAME $procc] "psu_pmu"]} {
                                set_memmap "${drv_handle}_memory" pmu $reg
                        }
                        if {[string match -nocase [hsi get_property IP_NAME $procc] "psv_pmc"]} {
                                set_memmap "${drv_handle}_memory" pmc $reg
                        }
                        if {[string match -nocase [hsi get_property IP_NAME $procc] "psv_psm"]} {
                                set_memmap "${drv_handle}_memory" psm $reg
                        }
                        if {[string match -nocase [hsi get_property IP_NAME $procc] "microblaze"]} {
                                set_memmap "${drv_handle}_memory" $procc "0x0 $base 0x0 $size"
                        }
                    }
                add_prop "${memory_node}" "reg" $reg hexlist "system-top.dts" 1
                set dev_type memory
                add_prop "${memory_node}" "device_type" $dev_type string "system-top.dts" 1

        }

        set slave [hsi::get_cells -hier ${drv_handle}]
        set proctype [hsi get_property IP_TYPE $slave]
        set vlnv [split [hsi get_property VLNV $slave] ":"]
        set name [lindex $vlnv 2]
        set ver [lindex $vlnv 3]
        set comp_prop "xlnx,${name}-${ver}"
        regsub -all {_} $comp_prop {-} comp_prop
        add_prop "${memory_node}" "compatible" $comp_prop string "system-top.dts"
}