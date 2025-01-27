################################################################################
#
#  NetFPGA-10G http://www.netfpga.org
#
#  File:
#        nf10_axilite_rbs_bridge_tb.tcl
#
#  Library:
#        hw/contrib/pcores/nf10_axilite_rbs_bridge_v1_00_a
#
#  Module:
#        nf10_axilite_rbs_bridge_tb.tcl
#
#  Author:
#        Muhammad Shahbaz, Gianni Anitchi
#
#  Description:
#        Mark Grindell- A test bench to verify basic operation of the module
#
#  Copyright notice:
#        Copyright (C) 2010, 2011 The Board of Trustees of The Leland Stanford
#                                 Junior University
#
#  Licence:
#        This file is part of the NetFPGA 10G development base package.
#
#        This file is free code: you can redistribute it and/or modify it under
#        the terms of the GNU Lesser General Public License version 2.1 as
#        published by the Free Software Foundation.
#
#        This package is distributed in the hope that it will be useful, but
#        WITHOUT ANY WARRANTY; without even the implied warranty of
#        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#        Lesser General Public License for more details.
#
#        You should have received a copy of the GNU Lesser General Public
#        License along with the NetFPGA source package.  If not, see
#        http://www.gnu.org/licenses/.
#
#

run 340 ns
if {[test /testbench/dut_0/m_axis_tlast 1] & [test /testbench/dut_0/m_axis_tdata(255:0) 0d0d0d0d0c0c0c0c0b0b0b0b0a0a0a0a09090909080808080707070706060606 -radix hex]} {
  run 710 ns
  if {[test /testbench/dut_0/s_axis_tlast 1] & [test /testbench/dut_0/s_axis_tdata(31:0) 0d0d0d0d -radix hex]} {
    puts "Test Passed"
  } else {
    puts "Test Failed"
  }
} else {
  puts "Test Failed"
}
quit

