
########## Tcl recorder starts at 06/04/14 12:08:44 ##########

set version "1.7"
set proj_dir "C:/workspace/lattice/1mb_LPCmod_protect"
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
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/04/14 12:08:44 ###########


########## Tcl recorder starts at 06/04/14 12:09:44 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entityLpcMod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entityLpcMod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entityLpcMod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entityLpcMod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entityLpcMod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.sif"] {
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
	puts $rspFile "-nodal -src 1mb_lpcmod_protect.bl5 -type BLIF -presrc 1mb_lpcmod_protect.bl3 -crf 1mb_lpcmod_protect.crf -sif 1mb_lpcmod_protect.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 1mb_lpcmod_protect.lct
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

########## Tcl recorder end at 06/04/14 12:09:44 ###########


########## Tcl recorder starts at 06/04/14 12:10:02 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/04/14 12:10:02 ###########


########## Tcl recorder starts at 06/04/14 12:17:28 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src 1mb_lpcmod_protect.bl5 -type BLIF -presrc 1mb_lpcmod_protect.bl3 -crf 1mb_lpcmod_protect.crf -sif 1mb_lpcmod_protect.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 1mb_lpcmod_protect.lct
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

########## Tcl recorder end at 06/04/14 12:17:28 ###########


########## Tcl recorder starts at 06/04/14 12:17:45 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entityLpcMod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entityLpcMod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entityLpcMod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entityLpcMod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entityLpcMod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/04/14 12:17:45 ###########


########## Tcl recorder starts at 06/17/14 11:09:06 ##########

set version "1.7"
set proj_dir "C:/dev/perso/aladdin_xt_mods/1mb_LPCmod_protect"
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
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entityLpcMod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entityLpcMod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entityLpcMod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entityLpcMod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entityLpcMod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 11:09:06 ###########


########## Tcl recorder starts at 06/17/14 11:09:24 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entityLpcMod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entityLpcMod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entityLpcMod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entityLpcMod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entityLpcMod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 11:09:24 ###########


########## Tcl recorder starts at 06/17/14 20:01:35 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entityLpcMod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entityLpcMod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entityLpcMod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entityLpcMod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entityLpcMod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.sif"] {
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
	puts $rspFile "-nodal -src 1mb_lpcmod_protect.bl5 -type BLIF -presrc 1mb_lpcmod_protect.bl3 -crf 1mb_lpcmod_protect.crf -sif 1mb_lpcmod_protect.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 1mb_lpcmod_protect.lct
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

########## Tcl recorder end at 06/17/14 20:01:35 ###########


########## Tcl recorder starts at 06/17/14 20:02:03 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 20:02:03 ###########


########## Tcl recorder starts at 07/01/14 08:03:32 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/01/14 08:03:32 ###########


########## Tcl recorder starts at 07/01/14 08:03:36 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entityLpcMod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entityLpcMod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entityLpcMod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entityLpcMod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entityLpcMod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/01/14 08:03:36 ###########


########## Tcl recorder starts at 12/27/18 22:43:54 ##########

set version "1.8"
set proj_dir "D:/dev/xblast/aladdin_xt_mods/1mb_LPCmod_protect"
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
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entityLpcMod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entityLpcMod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entityLpcMod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entityLpcMod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entityLpcMod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 12/27/18 22:43:54 ###########


########## Tcl recorder starts at 07/09/19 21:37:06 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/09/19 21:37:06 ###########


########## Tcl recorder starts at 07/12/19 19:21:52 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/12/19 19:21:52 ###########


########## Tcl recorder starts at 07/12/19 19:28:30 ##########

# Commands to make the Process: 
# Optimization Constraint
# - none -
# Application to view the Process: 
# Optimization Constraint
if [catch {open opt_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file opt_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-global -lci 1mb_lpcmod_protect.lct -touch 1mb_lpcmod_protect.imp
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

########## Tcl recorder end at 07/12/19 19:28:30 ###########


########## Tcl recorder starts at 07/12/19 19:28:38 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/12/19 19:28:38 ###########


########## Tcl recorder starts at 07/12/19 19:52:30 ##########

# Commands to make the Process: 
# Optimization Constraint
# - none -
# Application to view the Process: 
# Optimization Constraint
if [catch {open opt_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file opt_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-global -lci 1mb_lpcmod_protect.lct -touch 1mb_lpcmod_protect.imp
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

########## Tcl recorder end at 07/12/19 19:52:30 ###########


########## Tcl recorder starts at 07/12/19 19:52:36 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/12/19 19:52:36 ###########


########## Tcl recorder starts at 07/23/19 21:29:15 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/23/19 21:29:15 ###########


########## Tcl recorder starts at 07/25/19 17:39:19 ##########

# Commands to make the Process: 
# Fitter Report (Text)
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 17:39:19 ###########


########## Tcl recorder starts at 07/25/19 17:40:17 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 17:40:17 ###########


########## Tcl recorder starts at 07/25/19 17:40:17 ##########

# Commands to make the Process: 
# Fitter Report (HTML)
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 17:40:17 ###########


########## Tcl recorder starts at 07/25/19 17:41:39 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 17:41:39 ###########


########## Tcl recorder starts at 07/25/19 17:41:40 ##########

# Commands to make the Process: 
# Fitter Report (HTML)
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 17:41:40 ###########


########## Tcl recorder starts at 07/25/19 17:44:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 17:44:50 ###########


########## Tcl recorder starts at 07/25/19 17:44:51 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 17:44:51 ###########


########## Tcl recorder starts at 07/25/19 18:05:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 18:05:15 ###########


########## Tcl recorder starts at 07/25/19 18:05:16 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 18:05:16 ###########


########## Tcl recorder starts at 07/25/19 18:05:52 ##########

# Commands to make the Process: 
# Fitter Report (HTML)
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 18:05:52 ###########


########## Tcl recorder starts at 07/25/19 18:06:27 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   1mb_lpcmod.vhd
#insert # End
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_protect.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_protect.rsp 1mb_lpcmod_protect.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rsp
file delete 1mb_lpcmod_protect.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: lpcmod_tb_id_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open lpcmod_tb_id.rsp w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id.rsp: $rspFile"
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
#prjInfo 1mb_lpcmod_protect.sty
#do 
#vcomSrc   1mb_lpcmod.vhd
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entity_lpcmod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>%
#youdo lpcmod_tb_id_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete lpcmod_tb_id.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 18:06:27 ###########


########## Tcl recorder starts at 07/25/19 18:06:51 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 18:06:52 ###########


########## Tcl recorder starts at 07/25/19 18:09:57 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: lpcmod_tb_id_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open lpcmod_tb_id.rsp w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id.rsp: $rspFile"
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
#prjInfo 1mb_lpcmod_protect.sty
#do 
#vcomSrc   1mb_lpcmod.vhd
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entity_lpcmod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>%
#youdo lpcmod_tb_id_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete lpcmod_tb_id.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 18:09:57 ###########


########## Tcl recorder starts at 07/25/19 18:12:19 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 18:12:19 ###########


########## Tcl recorder starts at 07/25/19 18:12:19 ##########

# Commands to make the Process: 
# Pre-Fit Equations
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blif2eqn\" 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.eq2 -use_short -err automake.err"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 18:12:19 ###########


########## Tcl recorder starts at 07/25/19 18:12:58 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   1mb_lpcmod.vhd
#insert # End
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_protect.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_protect.rsp 1mb_lpcmod_protect.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rsp
file delete 1mb_lpcmod_protect.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: lpcmod_tb_id_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open lpcmod_tb_id.rsp w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id.rsp: $rspFile"
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
#prjInfo 1mb_lpcmod_protect.sty
#do 
#vcomSrc   1mb_lpcmod.vhd
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entity_lpcmod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>%
#youdo lpcmod_tb_id_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete lpcmod_tb_id.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 18:12:58 ###########


########## Tcl recorder starts at 07/25/19 18:13:55 ##########

# Commands to make the Process: 
# Fitter Report (HTML)
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 18:13:55 ###########


########## Tcl recorder starts at 07/27/19 18:04:49 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 18:04:49 ###########


########## Tcl recorder starts at 07/27/19 18:07:10 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   1mb_lpcmod.vhd
#insert # End
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_protect.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_protect.rsp 1mb_lpcmod_protect.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rsp
file delete 1mb_lpcmod_protect.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: lpcmod_tb_id_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open lpcmod_tb_id.rsp w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id.rsp: $rspFile"
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
#prjInfo 1mb_lpcmod_protect.sty
#do 
#vcomSrc   1mb_lpcmod.vhd
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entity_lpcmod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>%
#youdo lpcmod_tb_id_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete lpcmod_tb_id.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 18:07:10 ###########


########## Tcl recorder starts at 07/27/19 18:13:49 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 18:13:49 ###########


########## Tcl recorder starts at 07/27/19 18:13:50 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 18:13:50 ###########


########## Tcl recorder starts at 07/27/19 18:30:36 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   1mb_lpcmod.vhd
#insert # End
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_protect.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_protect.rsp 1mb_lpcmod_protect.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rsp
file delete 1mb_lpcmod_protect.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: lpcmod_tb_id_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open lpcmod_tb_id.rsp w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id.rsp: $rspFile"
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
#prjInfo 1mb_lpcmod_protect.sty
#do 
#vcomSrc   1mb_lpcmod.vhd
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entity_lpcmod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>%
#youdo lpcmod_tb_id_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete lpcmod_tb_id.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 18:30:36 ###########


########## Tcl recorder starts at 07/27/19 18:40:29 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 18:40:29 ###########


########## Tcl recorder starts at 07/27/19 18:40:55 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 18:40:55 ###########


########## Tcl recorder starts at 07/27/19 18:41:16 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 18:41:16 ###########


########## Tcl recorder starts at 07/27/19 18:41:43 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 18:41:43 ###########


########## Tcl recorder starts at 07/27/19 18:41:53 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
# - none -
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 18:41:53 ###########


########## Tcl recorder starts at 07/27/19 18:42:51 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 18:42:51 ###########


########## Tcl recorder starts at 07/27/19 18:55:55 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 18:55:55 ###########


########## Tcl recorder starts at 07/28/19 00:49:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 00:49:43 ###########


########## Tcl recorder starts at 07/28/19 00:49:43 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 00:49:43 ###########


########## Tcl recorder starts at 07/28/19 13:39:12 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 13:39:12 ###########


########## Tcl recorder starts at 07/28/19 13:39:13 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 13:39:13 ###########


########## Tcl recorder starts at 07/28/19 13:39:49 ##########

# Commands to make the Process: 
# JEDEC File
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 13:39:49 ###########


########## Tcl recorder starts at 07/28/19 13:44:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 13:44:30 ###########


########## Tcl recorder starts at 07/28/19 13:44:30 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 13:44:30 ###########


########## Tcl recorder starts at 07/28/19 13:50:01 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   1mb_lpcmod.vhd
#insert # End
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_protect.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_protect.rsp 1mb_lpcmod_protect.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rsp
file delete 1mb_lpcmod_protect.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: lpcmod_tb_id_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open lpcmod_tb_id.rsp w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id.rsp: $rspFile"
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
#prjInfo 1mb_lpcmod_protect.sty
#do 
#vcomSrc   1mb_lpcmod.vhd
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entity_lpcmod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>%
#youdo lpcmod_tb_id_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete lpcmod_tb_id.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 13:50:01 ###########


########## Tcl recorder starts at 07/28/19 13:59:29 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 13:59:29 ###########


########## Tcl recorder starts at 07/28/19 13:59:30 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 13:59:30 ###########


########## Tcl recorder starts at 07/28/19 14:00:14 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 14:00:14 ###########


########## Tcl recorder starts at 07/28/19 14:00:15 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 14:00:15 ###########


########## Tcl recorder starts at 07/28/19 14:17:30 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   1mb_lpcmod.vhd
#insert # End
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_protect.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_protect.rsp 1mb_lpcmod_protect.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rsp
file delete 1mb_lpcmod_protect.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: lpcmod_tb_id_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open lpcmod_tb_id.rsp w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id.rsp: $rspFile"
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
#prjInfo 1mb_lpcmod_protect.sty
#do 
#vcomSrc   1mb_lpcmod.vhd
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entity_lpcmod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>%
#youdo lpcmod_tb_id_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete lpcmod_tb_id.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 14:17:30 ###########


########## Tcl recorder starts at 07/28/19 14:24:09 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 14:24:09 ###########


########## Tcl recorder starts at 07/28/19 14:24:10 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 14:24:10 ###########


########## Tcl recorder starts at 07/28/19 14:30:43 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 14:30:43 ###########


########## Tcl recorder starts at 07/28/19 14:30:44 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 14:30:44 ###########


########## Tcl recorder starts at 07/28/19 14:35:08 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 14:35:08 ###########


########## Tcl recorder starts at 07/28/19 14:35:09 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 14:35:09 ###########


########## Tcl recorder starts at 07/28/19 22:30:06 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 22:30:06 ###########


########## Tcl recorder starts at 07/28/19 22:31:15 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 1mb_lpcmod.vhd -o 1mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 22:31:15 ###########


########## Tcl recorder starts at 07/28/19 22:31:15 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/28/19 22:31:15 ###########


########## Tcl recorder starts at 08/10/19 15:09:56 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_protect.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 1mb_lpcmod.vhd
OUTPUT_FILE_NAME: entity_lpcmod
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
if [runCmd "\"$cpld_bin/Synpwrap\" -e entity_lpcmod -target ispmach4000b -pro "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete entity_lpcmod.cmd
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_protect -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" entity_lpcmod.bl0 -collapse none -reduce none -keepwires  -err automake.err -family"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_protect.bl2\" -omod \"1mb_lpcmod_protect\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_protect -lci 1mb_lpcmod_protect.lct -log 1mb_lpcmod_protect.imp -err automake.err -tti 1mb_lpcmod_protect.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -blifopt 1mb_lpcmod_protect.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_protect.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_protect.bl3 @1mb_lpcmod_protect.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -diofft 1mb_lpcmod_protect.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_protect.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_protect.bl4 -oxrf 1mb_lpcmod_protect.xrf -err automake.err @1mb_lpcmod_protect.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_protect.lct -dev lc4k -prefit 1mb_lpcmod_protect.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_protect.bl4 -out 1mb_lpcmod_protect.bl5 -err automake.err -log 1mb_lpcmod_protect.log -mod entity_lpcmod @1mb_lpcmod_protect.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_protect.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -nojed -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_protect.bl5 -lci 1mb_lpcmod_protect.lct -d m4s_32_30 -lco 1mb_lpcmod_protect.lco -html_rpt -fti 1mb_lpcmod_protect.fti -fmt PLA -tto 1mb_lpcmod_protect.tt4 -eqn 1mb_lpcmod_protect.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_protect.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rs1
file delete 1mb_lpcmod_protect.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_protect.bl5 -o 1mb_lpcmod_protect.tda -lci 1mb_lpcmod_protect.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_protect -if 1mb_lpcmod_protect.jed -j2s -log 1mb_lpcmod_protect.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/10/19 15:09:56 ###########


########## Tcl recorder starts at 08/13/19 21:19:23 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by All VHDL Functional Simulation Models
#insert #
#path
#do 
#vcomSrc   1mb_lpcmod.vhd
#insert # End
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_protect.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_protect.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_protect.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_protect.rsp 1mb_lpcmod_protect.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_protect.rsp
file delete 1mb_lpcmod_protect.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Functional Simulation Template: lpcmod_tb_id_vhdaf.udo.
# You may edit this file to control your simulation.
# You may specify your design unit.
# You may specify your waveforms.
add wave *
# You may specify your simulation run time.
run 1000 ns
"
	close $rspFile
}
if [catch {open lpcmod_tb_id.rsp w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id.rsp: $rspFile"
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
#prjInfo 1mb_lpcmod_protect.sty
#do 
#vcomSrc   1mb_lpcmod.vhd
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entity_lpcmod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>%
#youdo lpcmod_tb_id_vhdaf.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.fado udo.rsp"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete udo.rsp
file delete lpcmod_tb_id.rsp
# Application to view the Process: 
# Aldec VHDL Functional Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.fado
"
	close $rspFile
}
if [runCmd "\"$install_dir/active-hdl/BIN/avhdl\" -do \"lpcmod_tb_id_activehdl.do\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/13/19 21:19:23 ###########

