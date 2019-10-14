
########## Tcl recorder starts at 01/24/17 17:51:20 ##########

set version "2.0"
set proj_dir "D:/dev/xblast/LCDCheapie"
cd $proj_dir

# Get directory paths
set pver $version
regsub -all {\.} $pver {_} pver
set lscfile "lsc_"
append lscfile $pver ".ini"
set lsvini_dir [lindex [array get env LSC_INI_PATH] 1]
set lsvini_path [file join $lsvini_dir $lscfile]
if {[catch {set fid [open $lsvini_path]} msg]} {
	 puts "File Open Error: $lsvini_path"
	 return false
} else {set data [read $fid]; close $fid }
foreach line [split $data '\n'] { 
	set lline [string tolower $line]
	set lline [string trim $lline]
	if {[string compare $lline "\[paths\]"] == 0} { set path 1; continue}
	if {$path && [regexp {^\[} $lline]} {set path 0; break}
	if {$path && [regexp {^bin} $lline]} {set cpld_bin $line; continue}
	if {$path && [regexp {^fpgapath} $lline]} {set fpga_dir $line; continue}
	if {$path && [regexp {^fpgabinpath} $lline]} {set fpga_bin $line}}

set cpld_bin [string range $cpld_bin [expr [string first "=" $cpld_bin]+1] end]
regsub -all "\"" $cpld_bin "" cpld_bin
set cpld_bin [file join $cpld_bin]
set install_dir [string range $cpld_bin 0 [expr [string first "ispcpld" $cpld_bin]-2]]
regsub -all "\"" $install_dir "" install_dir
set install_dir [file join $install_dir]
set fpga_dir [string range $fpga_dir [expr [string first "=" $fpga_dir]+1] end]
regsub -all "\"" $fpga_dir "" fpga_dir
set fpga_dir [file join $fpga_dir]
set fpga_bin [string range $fpga_bin [expr [string first "=" $fpga_bin]+1] end]
regsub -all "\"" $fpga_bin "" fpga_bin
set fpga_bin [file join $fpga_bin]

if {[string match "*$fpga_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$fpga_bin;$env(PATH)" }

if {[string match "*$cpld_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$cpld_bin;$env(PATH)" }

lappend auto_path [file join $install_dir "ispcpld" "tcltk" "lib" "ispwidget" "runproc"]
package require runcmd

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 17:51:20 ###########


########## Tcl recorder starts at 01/24/17 17:51:31 ##########

# Commands to make the Process: 
# Synplify Synthesize VHDL File
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd

########## Tcl recorder end at 01/24/17 17:51:31 ###########


########## Tcl recorder starts at 01/24/17 17:52:38 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 17:52:38 ###########


########## Tcl recorder starts at 01/24/17 17:52:41 ##########

# Commands to make the Process: 
# Synplify Synthesize VHDL File
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd

########## Tcl recorder end at 01/24/17 17:52:41 ###########


########## Tcl recorder starts at 01/24/17 17:53:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 17:53:47 ###########


########## Tcl recorder starts at 01/24/17 17:53:49 ##########

# Commands to make the Process: 
# Synplify Synthesize VHDL File
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd

########## Tcl recorder end at 01/24/17 17:53:49 ###########


########## Tcl recorder starts at 01/24/17 17:54:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 17:54:40 ###########


########## Tcl recorder starts at 01/24/17 17:54:42 ##########

# Commands to make the Process: 
# Synplify Synthesize VHDL File
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd

########## Tcl recorder end at 01/24/17 17:54:42 ###########


########## Tcl recorder starts at 01/24/17 17:58:25 ##########

# Commands to make the Process: 
# Compile EDIF File
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 17:58:25 ###########


########## Tcl recorder starts at 01/24/17 18:17:51 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i lcdcheapie.bl5 -o lcdcheapie.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src lcdcheapie.bl5 -type BLIF -presrc lcdcheapie.bl3 -crf lcdcheapie.crf -sif lcdcheapie.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci lcdcheapie.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:17:51 ###########


########## Tcl recorder starts at 01/24/17 18:53:22 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:53:22 ###########


########## Tcl recorder starts at 01/24/17 18:53:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:53:41 ###########


########## Tcl recorder starts at 01/24/17 18:53:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:53:58 ###########


########## Tcl recorder starts at 01/24/17 18:54:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:54:04 ###########


########## Tcl recorder starts at 01/24/17 18:54:10 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:54:10 ###########


########## Tcl recorder starts at 01/24/17 18:54:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:54:27 ###########


########## Tcl recorder starts at 01/24/17 18:55:18 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:55:18 ###########


########## Tcl recorder starts at 01/24/17 18:55:40 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:55:40 ###########


########## Tcl recorder starts at 01/24/17 18:56:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:56:12 ###########


########## Tcl recorder starts at 01/24/17 18:56:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:56:34 ###########


########## Tcl recorder starts at 01/24/17 18:56:41 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:56:41 ###########


########## Tcl recorder starts at 01/24/17 18:59:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:59:09 ###########


########## Tcl recorder starts at 01/24/17 18:59:11 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:59:11 ###########


########## Tcl recorder starts at 01/24/17 18:59:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:59:19 ###########


########## Tcl recorder starts at 01/24/17 18:59:52 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 18:59:52 ###########


########## Tcl recorder starts at 01/24/17 19:00:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:00:00 ###########


########## Tcl recorder starts at 01/24/17 19:00:20 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:00:20 ###########


########## Tcl recorder starts at 01/24/17 19:00:23 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:00:23 ###########


########## Tcl recorder starts at 01/24/17 19:01:00 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:01:00 ###########


########## Tcl recorder starts at 01/24/17 19:01:03 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:01:03 ###########


########## Tcl recorder starts at 01/24/17 19:01:58 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:01:58 ###########


########## Tcl recorder starts at 01/24/17 19:02:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:02:15 ###########


########## Tcl recorder starts at 01/24/17 19:02:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:02:36 ###########


########## Tcl recorder starts at 01/24/17 19:02:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:02:41 ###########


########## Tcl recorder starts at 01/24/17 19:02:51 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:02:51 ###########


########## Tcl recorder starts at 01/24/17 19:03:06 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:03:06 ###########


########## Tcl recorder starts at 01/24/17 19:03:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:03:09 ###########


########## Tcl recorder starts at 01/24/17 19:04:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:04:17 ###########


########## Tcl recorder starts at 01/24/17 19:04:19 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:04:19 ###########


########## Tcl recorder starts at 01/24/17 19:07:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:07:08 ###########


########## Tcl recorder starts at 01/24/17 19:07:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:07:14 ###########


########## Tcl recorder starts at 01/24/17 19:07:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:07:17 ###########


########## Tcl recorder starts at 01/24/17 19:07:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:07:26 ###########


########## Tcl recorder starts at 01/24/17 19:07:41 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:07:41 ###########


########## Tcl recorder starts at 01/24/17 19:07:45 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:07:45 ###########


########## Tcl recorder starts at 01/24/17 19:07:49 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:07:49 ###########


########## Tcl recorder starts at 01/24/17 19:09:26 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i lcdcheapie.bl5 -o lcdcheapie.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src lcdcheapie.bl5 -type BLIF -presrc lcdcheapie.bl3 -crf lcdcheapie.crf -sif lcdcheapie.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci lcdcheapie.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:09:26 ###########


########## Tcl recorder starts at 01/24/17 19:09:45 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:09:45 ###########


########## Tcl recorder starts at 01/24/17 19:45:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:45:12 ###########


########## Tcl recorder starts at 01/24/17 19:45:57 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:45:57 ###########


########## Tcl recorder starts at 01/24/17 19:52:26 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:52:26 ###########


########## Tcl recorder starts at 01/24/17 19:52:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:52:30 ###########


########## Tcl recorder starts at 01/24/17 19:59:33 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:59:33 ###########


########## Tcl recorder starts at 01/24/17 19:59:43 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 19:59:43 ###########


########## Tcl recorder starts at 01/24/17 20:00:43 ##########

# Commands to make the Process: 
# Fitter Report (HTML)
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 20:00:43 ###########


########## Tcl recorder starts at 01/24/17 20:12:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 20:12:34 ###########


########## Tcl recorder starts at 01/24/17 20:12:46 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 20:12:46 ###########


########## Tcl recorder starts at 01/24/17 20:29:42 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/24/17 20:29:42 ###########


########## Tcl recorder starts at 01/25/17 21:37:22 ##########

set version "2.0"
set proj_dir "D:/dev/xblast/aladdin_xt_mods/LCDCheapie"
cd $proj_dir

# Get directory paths
set pver $version
regsub -all {\.} $pver {_} pver
set lscfile "lsc_"
append lscfile $pver ".ini"
set lsvini_dir [lindex [array get env LSC_INI_PATH] 1]
set lsvini_path [file join $lsvini_dir $lscfile]
if {[catch {set fid [open $lsvini_path]} msg]} {
	 puts "File Open Error: $lsvini_path"
	 return false
} else {set data [read $fid]; close $fid }
foreach line [split $data '\n'] { 
	set lline [string tolower $line]
	set lline [string trim $lline]
	if {[string compare $lline "\[paths\]"] == 0} { set path 1; continue}
	if {$path && [regexp {^\[} $lline]} {set path 0; break}
	if {$path && [regexp {^bin} $lline]} {set cpld_bin $line; continue}
	if {$path && [regexp {^fpgapath} $lline]} {set fpga_dir $line; continue}
	if {$path && [regexp {^fpgabinpath} $lline]} {set fpga_bin $line}}

set cpld_bin [string range $cpld_bin [expr [string first "=" $cpld_bin]+1] end]
regsub -all "\"" $cpld_bin "" cpld_bin
set cpld_bin [file join $cpld_bin]
set install_dir [string range $cpld_bin 0 [expr [string first "ispcpld" $cpld_bin]-2]]
regsub -all "\"" $install_dir "" install_dir
set install_dir [file join $install_dir]
set fpga_dir [string range $fpga_dir [expr [string first "=" $fpga_dir]+1] end]
regsub -all "\"" $fpga_dir "" fpga_dir
set fpga_dir [file join $fpga_dir]
set fpga_bin [string range $fpga_bin [expr [string first "=" $fpga_bin]+1] end]
regsub -all "\"" $fpga_bin "" fpga_bin
set fpga_bin [file join $fpga_bin]

if {[string match "*$fpga_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$fpga_bin;$env(PATH)" }

if {[string match "*$cpld_bin;*" $env(PATH)] == 0 } {
   set env(PATH) "$cpld_bin;$env(PATH)" }

lappend auto_path [file join $install_dir "ispcpld" "tcltk" "lib" "ispwidget" "runproc"]
package require runcmd

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/17 21:37:22 ###########


########## Tcl recorder starts at 01/25/17 21:37:22 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/17 21:37:22 ###########


########## Tcl recorder starts at 01/25/17 21:38:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/17 21:38:19 ###########


########## Tcl recorder starts at 01/25/17 21:38:26 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/17 21:38:26 ###########


########## Tcl recorder starts at 01/25/17 21:39:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/17 21:39:14 ###########


########## Tcl recorder starts at 01/25/17 21:39:17 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/25/17 21:39:17 ###########


########## Tcl recorder starts at 01/26/17 17:20:17 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdCheapie testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 17:20:17 ###########


########## Tcl recorder starts at 01/26/17 17:35:27 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   lcd_cheapie.vhd
#insert # End
"
	close $rspFile
}
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lcdcheapie.rsp lcdcheapie.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rsp
file delete lcdcheapie.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdCheapie testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 17:35:27 ###########


########## Tcl recorder starts at 01/26/17 20:23:11 ##########

# Commands to make the Process: 
# Synplify Synthesize VHDL File
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd

########## Tcl recorder end at 01/26/17 20:23:11 ###########


########## Tcl recorder starts at 01/26/17 20:23:56 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rss w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rss: $rspFile"
} else {
	puts $rspFile "-i \"lcdcheapie.tt4\" -lib \"$install_dir/ispcpld/dat/lc4k\" -strategy top -sdfmdl \"$install_dir/ispcpld/dat/sdf.mdl\" -simmdl \"$install_dir/ispcpld/dat/sim.mdl\" -pla \"lcdcheapie.tt4\" -lci \"lcdcheapie.lct\" -prj \"lcdcheapie\" -dir \"$proj_dir\" -err automake.err -log \"lcdcheapie.nrp\" -exf \"lcdCheapie.exf\"  -netlist vhdl
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/sdf\" \"@lcdcheapie.rss\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rss
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lcdcheapie.rsp lcdcheapie.vtd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rsp
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Models
#insert #
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lcdcheapie.rsp lcdcheapie.vatd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: testbench_vhda.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do lcdcheapie.vatd
#vcom lcdcheapie.vho
#vcom testbench.vhd
#stimulus vhdl lcdCheapie testbench.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=lcdcheapie.sdf
#youdo testbench_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.tado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Timing Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.tado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 20:23:56 ###########


########## Tcl recorder starts at 01/26/17 20:27:37 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 20:27:37 ###########


########## Tcl recorder starts at 01/26/17 20:40:11 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdCheapie testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 20:40:11 ###########


########## Tcl recorder starts at 01/26/17 20:41:55 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 20:41:55 ###########


########## Tcl recorder starts at 01/26/17 20:43:59 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 20:44:00 ###########


########## Tcl recorder starts at 01/26/17 20:45:34 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 20:45:34 ###########


########## Tcl recorder starts at 01/26/17 21:08:55 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 21:08:55 ###########


########## Tcl recorder starts at 01/26/17 21:27:01 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   lcd_cheapie.vhd
#insert # End
"
	close $rspFile
}
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lcdcheapie.rsp lcdcheapie.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rsp
file delete lcdcheapie.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdCheapie testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 21:27:01 ###########


########## Tcl recorder starts at 01/26/17 21:43:59 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdCheapie testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 21:43:59 ###########


########## Tcl recorder starts at 01/26/17 21:48:14 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdCheapie testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 21:48:14 ###########


########## Tcl recorder starts at 01/26/17 21:50:46 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 21:50:46 ###########


########## Tcl recorder starts at 01/26/17 21:50:47 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i lcdcheapie.bl5 -o lcdcheapie.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src lcdcheapie.bl5 -type BLIF -presrc lcdcheapie.bl3 -crf lcdcheapie.crf -sif lcdcheapie.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci lcdcheapie.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 21:50:47 ###########


########## Tcl recorder starts at 01/26/17 21:52:02 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 21:52:02 ###########


########## Tcl recorder starts at 01/26/17 21:59:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 21:59:30 ###########


########## Tcl recorder starts at 01/26/17 21:59:31 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 21:59:31 ###########


########## Tcl recorder starts at 01/26/17 22:00:36 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:00:36 ###########


########## Tcl recorder starts at 01/26/17 22:00:36 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:00:36 ###########


########## Tcl recorder starts at 01/26/17 22:01:14 ##########

# Commands to make the Process: 
# Fitter Report (HTML)
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:01:14 ###########


########## Tcl recorder starts at 01/26/17 22:07:34 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:07:34 ###########


########## Tcl recorder starts at 01/26/17 22:07:35 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:07:35 ###########


########## Tcl recorder starts at 01/26/17 22:09:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:09:09 ###########


########## Tcl recorder starts at 01/26/17 22:09:10 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:09:10 ###########


########## Tcl recorder starts at 01/26/17 22:10:04 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:10:04 ###########


########## Tcl recorder starts at 01/26/17 22:10:05 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:10:05 ###########


########## Tcl recorder starts at 01/26/17 22:10:59 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:11:00 ###########


########## Tcl recorder starts at 01/26/17 22:11:01 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:11:01 ###########


########## Tcl recorder starts at 01/26/17 22:36:31 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:36:31 ###########


########## Tcl recorder starts at 01/26/17 22:36:32 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:36:32 ###########


########## Tcl recorder starts at 01/26/17 22:37:12 ##########

# Commands to make the Process: 
# Fitter Report (HTML)
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:37:12 ###########


########## Tcl recorder starts at 01/26/17 22:38:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:38:12 ###########


########## Tcl recorder starts at 01/26/17 22:38:13 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:38:13 ###########


########## Tcl recorder starts at 01/26/17 22:39:11 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   lcd_cheapie.vhd
#insert # End
"
	close $rspFile
}
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lcdcheapie.rsp lcdcheapie.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rsp
file delete lcdcheapie.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdCheapie testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 01/26/17 22:39:11 ###########


########## Tcl recorder starts at 12/27/18 22:46:46 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 12/27/18 22:46:46 ###########


########## Tcl recorder starts at 07/23/19 21:31:58 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdCheapie.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdCheapie.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdCheapie
WORKING_PATH: \"$proj_dir\"
MODULE: lcdCheapie
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdCheapie
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdCheapie -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdCheapie.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdCheapie.edi -out lcdCheapie.bl0 -err automake.err -log lcdCheapie.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdCheapie.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdCheapie.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdCheapie @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdCheapie -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/23/19 21:31:58 ###########


########## Tcl recorder starts at 07/31/19 21:05:14 ##########

# Commands to make the Process: 
# Pre-Fit Equations
if [catch {open lcdcheapie_entity.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie_entity.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdcheapie_entity
WORKING_PATH: \"$proj_dir\"
MODULE: lcdcheapie_entity
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdcheapie_entity
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdcheapie_entity -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie_entity.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdcheapie_entity.edi -out lcdcheapie_entity.bl0 -err automake.err -log lcdcheapie_entity.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie_entity.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdcheapie_entity.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdcheapie_entity @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" lcdcheapie.bl5 -o lcdcheapie.eq2 -use_short -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/31/19 21:05:14 ###########


########## Tcl recorder starts at 07/31/19 21:08:35 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/31/19 21:08:35 ###########


########## Tcl recorder starts at 07/31/19 21:08:36 ##########

# Commands to make the Process: 
# Pre-Fit Equations
if [catch {open lcdcheapie_entity.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie_entity.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdcheapie_entity
WORKING_PATH: \"$proj_dir\"
MODULE: lcdcheapie_entity
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdcheapie_entity
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdcheapie_entity -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie_entity.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdcheapie_entity.edi -out lcdcheapie_entity.bl0 -err automake.err -log lcdcheapie_entity.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie_entity.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdcheapie_entity.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdcheapie_entity @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" lcdcheapie.bl5 -o lcdcheapie.eq2 -use_short -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/31/19 21:08:36 ###########


########## Tcl recorder starts at 07/31/19 21:09:44 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/31/19 21:09:44 ###########


########## Tcl recorder starts at 07/31/19 21:09:48 ##########

# Commands to make the Process: 
# Pre-Fit Equations
if [catch {open lcdcheapie_entity.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie_entity.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdcheapie_entity
WORKING_PATH: \"$proj_dir\"
MODULE: lcdcheapie_entity
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdcheapie_entity
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdcheapie_entity -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie_entity.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdcheapie_entity.edi -out lcdcheapie_entity.bl0 -err automake.err -log lcdcheapie_entity.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie_entity.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdcheapie_entity.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdcheapie_entity @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" lcdcheapie.bl5 -o lcdcheapie.eq2 -use_short -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/31/19 21:09:48 ###########


########## Tcl recorder starts at 07/31/19 21:13:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/31/19 21:13:01 ###########


########## Tcl recorder starts at 07/31/19 21:13:01 ##########

# Commands to make the Process: 
# Pre-Fit Equations
if [catch {open lcdcheapie_entity.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie_entity.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdcheapie_entity
WORKING_PATH: \"$proj_dir\"
MODULE: lcdcheapie_entity
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdcheapie_entity
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdcheapie_entity -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie_entity.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdcheapie_entity.edi -out lcdcheapie_entity.bl0 -err automake.err -log lcdcheapie_entity.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie_entity.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdcheapie_entity.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdcheapie_entity @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" lcdcheapie.bl5 -o lcdcheapie.eq2 -use_short -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/31/19 21:13:01 ###########


########## Tcl recorder starts at 07/31/19 21:14:54 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/31/19 21:14:54 ###########


########## Tcl recorder starts at 07/31/19 21:14:55 ##########

# Commands to make the Process: 
# Pre-Fit Equations
if [catch {open lcdcheapie_entity.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie_entity.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdcheapie_entity
WORKING_PATH: \"$proj_dir\"
MODULE: lcdcheapie_entity
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdcheapie_entity
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdcheapie_entity -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie_entity.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdcheapie_entity.edi -out lcdcheapie_entity.bl0 -err automake.err -log lcdcheapie_entity.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie_entity.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdcheapie_entity.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdcheapie_entity @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" lcdcheapie.bl5 -o lcdcheapie.eq2 -use_short -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/31/19 21:14:55 ###########


########## Tcl recorder starts at 08/05/19 20:33:18 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdcheapie_entity.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie_entity.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdcheapie_entity
WORKING_PATH: \"$proj_dir\"
MODULE: lcdcheapie_entity
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdcheapie_entity
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdcheapie_entity -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie_entity.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdcheapie_entity.edi -out lcdcheapie_entity.bl0 -err automake.err -log lcdcheapie_entity.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie_entity.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdcheapie_entity.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdcheapie_entity @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdcheapie_entity -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/05/19 20:33:18 ###########


########## Tcl recorder starts at 08/05/19 20:50:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/05/19 20:50:47 ###########


########## Tcl recorder starts at 08/05/19 20:50:48 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdcheapie_entity.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie_entity.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdcheapie_entity
WORKING_PATH: \"$proj_dir\"
MODULE: lcdcheapie_entity
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdcheapie_entity
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdcheapie_entity -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie_entity.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdcheapie_entity.edi -out lcdcheapie_entity.bl0 -err automake.err -log lcdcheapie_entity.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie_entity.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdcheapie_entity.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdcheapie_entity @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdcheapie_entity -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/05/19 20:50:48 ###########


########## Tcl recorder starts at 08/05/19 20:57:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/05/19 20:57:30 ###########


########## Tcl recorder starts at 08/05/19 20:57:30 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdcheapie_entity.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie_entity.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdcheapie_entity
WORKING_PATH: \"$proj_dir\"
MODULE: lcdcheapie_entity
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdcheapie_entity
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdcheapie_entity -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie_entity.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdcheapie_entity.edi -out lcdcheapie_entity.bl0 -err automake.err -log lcdcheapie_entity.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie_entity.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdcheapie_entity.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdcheapie_entity @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdcheapie_entity -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/05/19 20:57:30 ###########


########## Tcl recorder starts at 08/05/19 20:58:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/05/19 20:58:39 ###########


########## Tcl recorder starts at 08/05/19 20:58:39 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdcheapie_entity.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie_entity.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdcheapie_entity
WORKING_PATH: \"$proj_dir\"
MODULE: lcdcheapie_entity
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdcheapie_entity
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdcheapie_entity -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie_entity.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdcheapie_entity.edi -out lcdcheapie_entity.bl0 -err automake.err -log lcdcheapie_entity.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie_entity.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdcheapie_entity.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdcheapie_entity @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdcheapie_entity -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/05/19 20:58:39 ###########


########## Tcl recorder starts at 08/05/19 20:59:27 ##########

# Commands to make the Process: 
# Optimization Constraint
# - none -
# Application to view the Process: 
# Optimization Constraint
if [catch {open opt_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file opt_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-global -lci lcdcheapie.lct -touch lcdcheapie.imp
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/optedit\" @opt_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/05/19 20:59:27 ###########


########## Tcl recorder starts at 08/05/19 21:21:38 ##########

# Commands to make the Process: 
# Optimization Constraint
# - none -
# Application to view the Process: 
# Optimization Constraint
if [catch {open opt_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file opt_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-global -lci lcdcheapie.lct -touch lcdcheapie.imp
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/optedit\" @opt_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/05/19 21:21:38 ###########


########## Tcl recorder starts at 08/05/19 21:21:47 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdcheapie_entity @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdcheapie_entity -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/05/19 21:21:47 ###########


########## Tcl recorder starts at 08/05/19 21:56:57 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   lcd_cheapie.vhd
#insert # End
"
	close $rspFile
}
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lcdcheapie.rsp lcdcheapie.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rsp
file delete lcdcheapie.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdcheapie_entity testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/05/19 21:56:57 ###########


########## Tcl recorder starts at 08/05/19 21:57:59 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdcheapie_entity testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/05/19 21:57:59 ###########


########## Tcl recorder starts at 08/05/19 21:58:18 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdcheapie_entity testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/05/19 21:58:18 ###########


########## Tcl recorder starts at 08/13/19 21:25:54 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open lcdcheapie_entity.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie_entity.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdcheapie_entity
WORKING_PATH: \"$proj_dir\"
MODULE: lcdcheapie_entity
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdcheapie_entity
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdcheapie_entity -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie_entity.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdcheapie_entity.edi -out lcdcheapie_entity.bl0 -err automake.err -log lcdcheapie_entity.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie_entity.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdcheapie_entity.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdcheapie_entity @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i lcdcheapie.bl5 -o lcdcheapie.sif"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src lcdcheapie.bl5 -type BLIF -presrc lcdcheapie.bl3 -crf lcdcheapie.crf -sif lcdcheapie.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci lcdcheapie.lct
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lciedit\" @lattice_cmd.rs2"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/13/19 21:25:54 ###########


########## Tcl recorder starts at 08/13/19 21:30:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdcheapie_entity -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/13/19 21:30:09 ###########


########## Tcl recorder starts at 08/13/19 21:30:20 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   lcd_cheapie.vhd
#insert # End
"
	close $rspFile
}
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lcdcheapie.rsp lcdcheapie.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rsp
file delete lcdcheapie.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdcheapie_entity testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/13/19 21:30:20 ###########


########## Tcl recorder starts at 08/13/19 21:31:04 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdcheapie_entity testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/13/19 21:31:04 ###########


########## Tcl recorder starts at 08/13/19 21:31:51 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/13/19 21:31:51 ###########


########## Tcl recorder starts at 08/18/19 21:08:57 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   lcd_cheapie.vhd
#insert # End
"
	close $rspFile
}
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lcdcheapie.rsp lcdcheapie.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rsp
file delete lcdcheapie.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdcheapie_entity testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/18/19 21:08:57 ###########


########## Tcl recorder starts at 08/18/19 22:24:47 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   lcd_cheapie.vhd
#insert # End
"
	close $rspFile
}
if [catch {open lcdcheapie.rsp w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lcdcheapie.rsp lcdcheapie.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rsp
file delete lcdcheapie.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdcheapie_entity testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/18/19 22:24:47 ###########


########## Tcl recorder starts at 08/18/19 23:14:36 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: testbench_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open testbench.rsp w} rspFile] {
	puts stderr "Cannot create response file testbench.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by VHDL Functional Simulation Models
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo lcdcheapie.sty
#do 
#vcomSrc   lcd_cheapie.vhd
#vcom testbench.vhd
#stimulus vhdl lcdcheapie_entity testbench.vhd
#insert vsim +access +r %<StimModule>%
#youdo testbench_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" testbench.rsp testbench.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete testbench.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open testbench_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file testbench_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl testbench.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"testbench_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/18/19 23:14:36 ###########


########## Tcl recorder starts at 08/18/19 23:16:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" lcd_cheapie.vhd -o lcd_cheapie.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/18/19 23:16:29 ###########


########## Tcl recorder starts at 08/18/19 23:16:30 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open lcdcheapie_entity.cmd w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie_entity.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: lcdcheapie.sty
PROJECT: lcdcheapie_entity
WORKING_PATH: \"$proj_dir\"
MODULE: lcdcheapie_entity
VHDL_FILE_LIST: lcd_cheapie.vhd
OUTPUT_FILE_NAME: lcdcheapie_entity
SUFFIX_NAME: edi
FREQUENCY:  200
FANIN_LIMIT:  20
DISABLE_IO_INSERTION: false
MAX_TERMS_PER_MACROCELL:  16
MAP_LOGIC: false
SYMBOLIC_FSM_COMPILER: true
NUM_CRITICAL_PATHS:   3
AUTO_CONSTRAIN_IO: true
NUM_STARTEND_POINTS:   0
AREADELAY:  0
WRITE_PRF: true
RESOURCE_SHARING: true
COMPILER_COMPATIBLE: true
DEFAULT_ENUM_ENCODING: default
ARRANGE_VHDL_FILES: true
synthesis_onoff_pragma: false
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/Synpwrap\" -e lcdcheapie_entity -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie_entity.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf lcdcheapie_entity.edi -out lcdcheapie_entity.bl0 -err automake.err -log lcdcheapie_entity.log -prj lcdcheapie -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie_entity.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"lcdcheapie_entity.bl1\" -o \"lcdcheapie.bl2\" -omod \"lcdcheapie\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj lcdcheapie -lci lcdcheapie.lct -log lcdcheapie.imp -err automake.err -tti lcdcheapie.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -blifopt lcdcheapie.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" lcdcheapie.bl2 -sweep -mergefb -err automake.err -o lcdcheapie.bl3 @lcdcheapie.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -diofft lcdcheapie.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" lcdcheapie.bl3 -family AMDMACH -idev van -o lcdcheapie.bl4 -oxrf lcdcheapie.xrf -err automake.err @lcdcheapie.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci lcdcheapie.lct -dev lc4k -prefit lcdcheapie.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp lcdcheapie.bl4 -out lcdcheapie.bl5 -err automake.err -log lcdcheapie.log -mod lcdcheapie_entity @lcdcheapie.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open lcdcheapie.rs1 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs1: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -nojed -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open lcdcheapie.rs2 w} rspFile] {
	puts stderr "Cannot create response file lcdcheapie.rs2: $rspFile"
} else {
	puts $rspFile "-i lcdcheapie.bl5 -lci lcdcheapie.lct -d m4s_32_30 -lco lcdcheapie.lco -html_rpt -fti lcdcheapie.fti -fmt PLA -tto lcdcheapie.tt4 -eqn lcdcheapie.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@lcdcheapie.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete lcdcheapie.rs1
file delete lcdcheapie.rs2
if [runCmd "\"$cpld_bin/tda\" -i lcdcheapie.bl5 -o lcdcheapie.tda -lci lcdcheapie.lct -dev m4s_32_30 -family lc4k -mod lcdcheapie_entity -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj lcdcheapie -if lcdcheapie.jed -j2s -log lcdcheapie.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/18/19 23:16:30 ###########

