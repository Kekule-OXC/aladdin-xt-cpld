
########## Tcl recorder starts at 06/04/14 12:05:04 ##########

set version "1.7"
set proj_dir "C:/workspace/lattice/1MB_LPCmod_banks"
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

########## Tcl recorder end at 06/04/14 12:05:04 ###########


########## Tcl recorder starts at 06/04/14 12:05:10 ##########

# Commands to make the Process: 
# Optimization Constraint
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
# Application to view the Process: 
# Optimization Constraint
if [catch {open opt_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file opt_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-global -lci 1mb_lpcmod_banks.lct -touch 1mb_lpcmod_banks.imp
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

########## Tcl recorder end at 06/04/14 12:05:10 ###########


########## Tcl recorder starts at 06/04/14 12:05:30 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.sif"] {
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
	puts $rspFile "-nodal -src 1mb_lpcmod_banks.bl5 -type BLIF -presrc 1mb_lpcmod_banks.bl3 -crf 1mb_lpcmod_banks.crf -sif 1mb_lpcmod_banks.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 1mb_lpcmod_banks.lct
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

########## Tcl recorder end at 06/04/14 12:05:30 ###########


########## Tcl recorder starts at 06/04/14 12:12:30 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/04/14 12:12:30 ###########


########## Tcl recorder starts at 06/04/14 12:14:39 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.sif"] {
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
	puts $rspFile "-nodal -src 1mb_lpcmod_banks.bl5 -type BLIF -presrc 1mb_lpcmod_banks.bl3 -crf 1mb_lpcmod_banks.crf -sif 1mb_lpcmod_banks.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 1mb_lpcmod_banks.lct
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

########## Tcl recorder end at 06/04/14 12:14:39 ###########


########## Tcl recorder starts at 06/04/14 12:14:46 ##########

# Commands to make the Process: 
# Optimization Constraint
# - none -
# Application to view the Process: 
# Optimization Constraint
if [catch {open opt_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file opt_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-global -lci 1mb_lpcmod_banks.lct -touch 1mb_lpcmod_banks.imp
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

########## Tcl recorder end at 06/04/14 12:14:46 ###########


########## Tcl recorder starts at 06/04/14 12:14:51 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src 1mb_lpcmod_banks.bl5 -type BLIF -presrc 1mb_lpcmod_banks.bl3 -crf 1mb_lpcmod_banks.crf -sif 1mb_lpcmod_banks.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 1mb_lpcmod_banks.lct
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

########## Tcl recorder end at 06/04/14 12:14:51 ###########


########## Tcl recorder starts at 06/04/14 12:15:01 ##########

# Commands to make the Process: 
# JEDEC File
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/04/14 12:15:01 ###########


########## Tcl recorder starts at 06/04/14 12:15:25 ##########

# Commands to make the Process: 
# Constraint Editor
# - none -
# Application to view the Process: 
# Constraint Editor
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-nodal -src 1mb_lpcmod_banks.bl5 -type BLIF -presrc 1mb_lpcmod_banks.bl3 -crf 1mb_lpcmod_banks.crf -sif 1mb_lpcmod_banks.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 1mb_lpcmod_banks.lct
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

########## Tcl recorder end at 06/04/14 12:15:25 ###########


########## Tcl recorder starts at 06/04/14 12:16:12 ##########

# Commands to make the Process: 
# JEDEC File
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/04/14 12:16:12 ###########


########## Tcl recorder starts at 06/04/14 12:16:26 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/04/14 12:16:26 ###########


########## Tcl recorder starts at 06/17/14 10:39:45 ##########

set version "1.7"
set proj_dir "C:/dev/perso/aladdin_xt_mods/1MB_LPCmod_banks"
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
# Aldec VHDL Timing Simulation
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rss w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rss: $rspFile"
} else {
	puts $rspFile "-i \"1mb_lpcmod_banks.tt4\" -lib \"$install_dir/ispcpld/dat/lc4k\" -strategy top -sdfmdl \"$install_dir/ispcpld/dat/sdf.mdl\" -simmdl \"$install_dir/ispcpld/dat/sim.mdl\" -pla \"1mb_lpcmod_banks.tt4\" -lci \"1mb_lpcmod_banks.lct\" -prj \"1mb_lpcmod_banks\" -dir \"$proj_dir\" -err automake.err -log \"1mb_lpcmod_banks.nrp\" -exf \"entityLpcMod.exf\"  -netlist vhdl
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/sdf\" \"@1mb_lpcmod_banks.rss\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rss
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vtd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Models
#insert #
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vatd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: lpcmod_tb_id_vhda.udo.
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
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do 1mb_lpcmod_banks.vatd
#vcom 1mb_lpcmod_banks.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entityLpcMod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=1mb_lpcmod_banks.sdf
#youdo lpcmod_tb_id_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.tado udo.rsp"] {
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
# Aldec VHDL Timing Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.tado
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

########## Tcl recorder end at 06/17/14 10:39:45 ###########


########## Tcl recorder starts at 06/17/14 10:41:29 ##########

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

########## Tcl recorder end at 06/17/14 10:41:29 ###########


########## Tcl recorder starts at 06/17/14 10:41:35 ##########

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

########## Tcl recorder end at 06/17/14 10:41:35 ###########


########## Tcl recorder starts at 06/17/14 10:41:42 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rss w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rss: $rspFile"
} else {
	puts $rspFile "-i \"1mb_lpcmod_banks.tt4\" -lib \"$install_dir/ispcpld/dat/lc4k\" -strategy top -sdfmdl \"$install_dir/ispcpld/dat/sdf.mdl\" -simmdl \"$install_dir/ispcpld/dat/sim.mdl\" -pla \"1mb_lpcmod_banks.tt4\" -lci \"1mb_lpcmod_banks.lct\" -prj \"1mb_lpcmod_banks\" -dir \"$proj_dir\" -err automake.err -log \"1mb_lpcmod_banks.nrp\" -exf \"entityLpcMod.exf\"  -netlist vhdl
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/sdf\" \"@1mb_lpcmod_banks.rss\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rss
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vtd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Models
#insert #
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vatd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: lpcmod_tb_id_vhda.udo.
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
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do 1mb_lpcmod_banks.vatd
#vcom 1mb_lpcmod_banks.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entityLpcMod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=1mb_lpcmod_banks.sdf
#youdo lpcmod_tb_id_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.tado udo.rsp"] {
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
# Aldec VHDL Timing Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.tado
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

########## Tcl recorder end at 06/17/14 10:41:42 ###########


########## Tcl recorder starts at 06/17/14 10:44:53 ##########

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

########## Tcl recorder end at 06/17/14 10:44:53 ###########


########## Tcl recorder starts at 06/17/14 10:45:07 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 10:45:07 ###########


########## Tcl recorder starts at 06/17/14 10:45:41 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open 1mb_lpcmod_banks.rss w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rss: $rspFile"
} else {
	puts $rspFile "-i \"1mb_lpcmod_banks.tt4\" -lib \"$install_dir/ispcpld/dat/lc4k\" -strategy top -sdfmdl \"$install_dir/ispcpld/dat/sdf.mdl\" -simmdl \"$install_dir/ispcpld/dat/sim.mdl\" -pla \"1mb_lpcmod_banks.tt4\" -lci \"1mb_lpcmod_banks.lct\" -prj \"1mb_lpcmod_banks\" -dir \"$proj_dir\" -err automake.err -log \"1mb_lpcmod_banks.nrp\" -exf \"entityLpcMod.exf\"  -netlist vhdl
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/sdf\" \"@1mb_lpcmod_banks.rss\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rss
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vtd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Models
#insert #
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vatd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: lpcmod_tb_id_vhda.udo.
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
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do 1mb_lpcmod_banks.vatd
#vcom 1mb_lpcmod_banks.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entityLpcMod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=1mb_lpcmod_banks.sdf
#youdo lpcmod_tb_id_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.tado udo.rsp"] {
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
# Aldec VHDL Timing Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.tado
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

########## Tcl recorder end at 06/17/14 10:45:41 ###########


########## Tcl recorder starts at 06/17/14 10:46:52 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: lpcmod_tb_id_vhda.udo.
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
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do 1mb_lpcmod_banks.vatd
#vcom 1mb_lpcmod_banks.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entityLpcMod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=1mb_lpcmod_banks.sdf
#youdo lpcmod_tb_id_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.tado udo.rsp"] {
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
# Aldec VHDL Timing Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.tado
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

########## Tcl recorder end at 06/17/14 10:46:52 ###########


########## Tcl recorder starts at 06/17/14 10:50:57 ##########

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

########## Tcl recorder end at 06/17/14 10:50:57 ###########


########## Tcl recorder starts at 06/17/14 10:51:03 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 10:51:03 ###########


########## Tcl recorder starts at 06/17/14 10:52:35 ##########

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

########## Tcl recorder end at 06/17/14 10:52:35 ###########


########## Tcl recorder starts at 06/17/14 10:52:44 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 10:52:44 ###########


########## Tcl recorder starts at 06/17/14 10:53:02 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open 1mb_lpcmod_banks.rss w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rss: $rspFile"
} else {
	puts $rspFile "-i \"1mb_lpcmod_banks.tt4\" -lib \"$install_dir/ispcpld/dat/lc4k\" -strategy top -sdfmdl \"$install_dir/ispcpld/dat/sdf.mdl\" -simmdl \"$install_dir/ispcpld/dat/sim.mdl\" -pla \"1mb_lpcmod_banks.tt4\" -lci \"1mb_lpcmod_banks.lct\" -prj \"1mb_lpcmod_banks\" -dir \"$proj_dir\" -err automake.err -log \"1mb_lpcmod_banks.nrp\" -exf \"entityLpcMod.exf\"  -netlist vhdl
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/sdf\" \"@1mb_lpcmod_banks.rss\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rss
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vtd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Models
#insert #
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vatd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: lpcmod_tb_id_vhda.udo.
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
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do 1mb_lpcmod_banks.vatd
#vcom 1mb_lpcmod_banks.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entityLpcMod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=1mb_lpcmod_banks.sdf
#youdo lpcmod_tb_id_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.tado udo.rsp"] {
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
# Aldec VHDL Timing Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.tado
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

########## Tcl recorder end at 06/17/14 10:53:02 ###########


########## Tcl recorder starts at 06/17/14 10:57:16 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: lpcmod_tb_id_vhda.udo.
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
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do 1mb_lpcmod_banks.vatd
#vcom 1mb_lpcmod_banks.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entityLpcMod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=1mb_lpcmod_banks.sdf
#youdo lpcmod_tb_id_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.tado udo.rsp"] {
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
# Aldec VHDL Timing Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.tado
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

########## Tcl recorder end at 06/17/14 10:57:16 ###########


########## Tcl recorder starts at 06/17/14 10:58:15 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: lpcmod_tb_id_vhda.udo.
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
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do 1mb_lpcmod_banks.vatd
#vcom 1mb_lpcmod_banks.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entityLpcMod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=1mb_lpcmod_banks.sdf
#youdo lpcmod_tb_id_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.tado udo.rsp"] {
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
# Aldec VHDL Timing Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.tado
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

########## Tcl recorder end at 06/17/14 10:58:15 ###########


########## Tcl recorder starts at 06/17/14 10:59:50 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.sif"] {
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
	puts $rspFile "-nodal -src 1mb_lpcmod_banks.bl5 -type BLIF -presrc 1mb_lpcmod_banks.bl3 -crf 1mb_lpcmod_banks.crf -sif 1mb_lpcmod_banks.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 1mb_lpcmod_banks.lct
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

########## Tcl recorder end at 06/17/14 10:59:50 ###########


########## Tcl recorder starts at 06/17/14 11:00:02 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 11:00:02 ###########


########## Tcl recorder starts at 06/17/14 11:02:20 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rss w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rss: $rspFile"
} else {
	puts $rspFile "-i \"1mb_lpcmod_banks.tt4\" -lib \"$install_dir/ispcpld/dat/lc4k\" -strategy top -sdfmdl \"$install_dir/ispcpld/dat/sdf.mdl\" -simmdl \"$install_dir/ispcpld/dat/sim.mdl\" -pla \"1mb_lpcmod_banks.tt4\" -lci \"1mb_lpcmod_banks.lct\" -prj \"1mb_lpcmod_banks\" -dir \"$proj_dir\" -err automake.err -log \"1mb_lpcmod_banks.nrp\" -exf \"entityLpcMod.exf\"  -netlist vhdl
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/sdf\" \"@1mb_lpcmod_banks.rss\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rss
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vtd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: lpcmod_tb_id_vhda.udo.
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
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do 1mb_lpcmod_banks.vatd
#vcom 1mb_lpcmod_banks.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entityLpcMod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=1mb_lpcmod_banks.sdf
#youdo lpcmod_tb_id_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.tado udo.rsp"] {
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
# Aldec VHDL Timing Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.tado
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

########## Tcl recorder end at 06/17/14 11:02:20 ###########


########## Tcl recorder starts at 06/17/14 18:11:29 ##########

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

########## Tcl recorder end at 06/17/14 18:11:29 ###########


########## Tcl recorder starts at 06/17/14 18:12:06 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rss w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rss: $rspFile"
} else {
	puts $rspFile "-i \"1mb_lpcmod_banks.tt4\" -lib \"$install_dir/ispcpld/dat/lc4k\" -strategy top -sdfmdl \"$install_dir/ispcpld/dat/sdf.mdl\" -simmdl \"$install_dir/ispcpld/dat/sim.mdl\" -pla \"1mb_lpcmod_banks.tt4\" -lci \"1mb_lpcmod_banks.lct\" -prj \"1mb_lpcmod_banks\" -dir \"$proj_dir\" -err automake.err -log \"1mb_lpcmod_banks.nrp\" -exf \"entityLpcMod.exf\"  -netlist vhdl
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/sdf\" \"@1mb_lpcmod_banks.rss\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rss
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vtd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Models
#insert #
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vatd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: lpcmod_tb_id_vhda.udo.
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
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do 1mb_lpcmod_banks.vatd
#vcom 1mb_lpcmod_banks.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entityLpcMod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=1mb_lpcmod_banks.sdf
#youdo lpcmod_tb_id_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.tado udo.rsp"] {
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
# Aldec VHDL Timing Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.tado
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

########## Tcl recorder end at 06/17/14 18:12:06 ###########


########## Tcl recorder starts at 06/17/14 18:19:49 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.sif"] {
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
	puts $rspFile "-nodal -src 1mb_lpcmod_banks.bl5 -type BLIF -presrc 1mb_lpcmod_banks.bl3 -crf 1mb_lpcmod_banks.crf -sif 1mb_lpcmod_banks.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 1mb_lpcmod_banks.lct
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

########## Tcl recorder end at 06/17/14 18:19:49 ###########


########## Tcl recorder starts at 06/17/14 18:21:12 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rss w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rss: $rspFile"
} else {
	puts $rspFile "-i \"1mb_lpcmod_banks.tt4\" -lib \"$install_dir/ispcpld/dat/lc4k\" -strategy top -sdfmdl \"$install_dir/ispcpld/dat/sdf.mdl\" -simmdl \"$install_dir/ispcpld/dat/sim.mdl\" -pla \"1mb_lpcmod_banks.tt4\" -lci \"1mb_lpcmod_banks.lct\" -prj \"1mb_lpcmod_banks\" -dir \"$proj_dir\" -err automake.err -log \"1mb_lpcmod_banks.nrp\" -exf \"entityLpcMod.exf\"  -netlist vhdl
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/sdf\" \"@1mb_lpcmod_banks.rss\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rss
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: lpcmod_tb_id_vhda.udo.
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
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do 1mb_lpcmod_banks.vatd
#vcom 1mb_lpcmod_banks.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entityLpcMod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=1mb_lpcmod_banks.sdf
#youdo lpcmod_tb_id_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.tado udo.rsp"] {
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
# Aldec VHDL Timing Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.tado
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

########## Tcl recorder end at 06/17/14 18:21:12 ###########


########## Tcl recorder starts at 06/17/14 18:23:00 ##########

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

########## Tcl recorder end at 06/17/14 18:23:00 ###########


########## Tcl recorder starts at 06/17/14 18:23:10 ##########

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

########## Tcl recorder end at 06/17/14 18:23:10 ###########


########## Tcl recorder starts at 06/17/14 18:23:22 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rss w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rss: $rspFile"
} else {
	puts $rspFile "-i \"1mb_lpcmod_banks.tt4\" -lib \"$install_dir/ispcpld/dat/lc4k\" -strategy top -sdfmdl \"$install_dir/ispcpld/dat/sdf.mdl\" -simmdl \"$install_dir/ispcpld/dat/sim.mdl\" -pla \"1mb_lpcmod_banks.tt4\" -lci \"1mb_lpcmod_banks.lct\" -prj \"1mb_lpcmod_banks\" -dir \"$proj_dir\" -err automake.err -log \"1mb_lpcmod_banks.nrp\" -exf \"entityLpcMod.exf\"  -netlist vhdl
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/sdf\" \"@1mb_lpcmod_banks.rss\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rss
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vtd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Models
#insert #
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vatd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: lpcmod_tb_id_vhda.udo.
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
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do 1mb_lpcmod_banks.vatd
#vcom 1mb_lpcmod_banks.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entityLpcMod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=1mb_lpcmod_banks.sdf
#youdo lpcmod_tb_id_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.tado udo.rsp"] {
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
# Aldec VHDL Timing Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.tado
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

########## Tcl recorder end at 06/17/14 18:23:22 ###########


########## Tcl recorder starts at 06/17/14 18:24:17 ##########

# Commands to make the Process: 
# JEDEC File
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 18:24:17 ###########


########## Tcl recorder starts at 06/17/14 18:29:55 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.sif"] {
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
	puts $rspFile "-nodal -src 1mb_lpcmod_banks.bl5 -type BLIF -presrc 1mb_lpcmod_banks.bl3 -crf 1mb_lpcmod_banks.crf -sif 1mb_lpcmod_banks.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 1mb_lpcmod_banks.lct
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

########## Tcl recorder end at 06/17/14 18:29:55 ###########


########## Tcl recorder starts at 06/17/14 18:30:58 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 18:30:58 ###########


########## Tcl recorder starts at 06/17/14 20:00:49 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 20:00:49 ###########


########## Tcl recorder starts at 07/01/14 08:02:20 ##########

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

########## Tcl recorder end at 07/01/14 08:02:20 ###########


########## Tcl recorder starts at 07/01/14 08:02:36 ##########

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

########## Tcl recorder end at 07/01/14 08:02:36 ###########


########## Tcl recorder starts at 07/01/14 08:02:42 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/01/14 08:02:42 ###########


########## Tcl recorder starts at 12/27/18 22:43:03 ##########

set version "1.8"
set proj_dir "D:/dev/xblast/aladdin_xt_mods/1MB_LPCmod_banks"
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
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entityLpcMod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 12/27/18 22:43:03 ###########


########## Tcl recorder starts at 07/07/19 17:45:00 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/07/19 17:45:00 ###########


########## Tcl recorder starts at 07/07/19 17:57:16 ##########

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

########## Tcl recorder end at 07/07/19 17:57:16 ###########


########## Tcl recorder starts at 07/07/19 17:57:20 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/07/19 17:57:20 ###########


########## Tcl recorder starts at 07/07/19 18:17:41 ##########

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

########## Tcl recorder end at 07/07/19 18:17:42 ###########


########## Tcl recorder starts at 07/07/19 18:17:43 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/07/19 18:17:43 ###########


########## Tcl recorder starts at 07/07/19 18:20:26 ##########

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

########## Tcl recorder end at 07/07/19 18:20:26 ###########


########## Tcl recorder starts at 07/07/19 18:20:51 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/07/19 18:20:51 ###########


########## Tcl recorder starts at 07/07/19 18:45:38 ##########

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

########## Tcl recorder end at 07/07/19 18:45:38 ###########


########## Tcl recorder starts at 07/07/19 18:45:51 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/07/19 18:45:51 ###########


########## Tcl recorder starts at 07/08/19 20:16:10 ##########

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

########## Tcl recorder end at 07/08/19 20:16:10 ###########


########## Tcl recorder starts at 07/08/19 20:16:10 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/19 20:16:10 ###########


########## Tcl recorder starts at 07/08/19 20:18:56 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.sif"] {
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
	puts $rspFile "-nodal -src 1mb_lpcmod_banks.bl5 -type BLIF -presrc 1mb_lpcmod_banks.bl3 -crf 1mb_lpcmod_banks.crf -sif 1mb_lpcmod_banks.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 1mb_lpcmod_banks.lct
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

########## Tcl recorder end at 07/08/19 20:18:56 ###########


########## Tcl recorder starts at 07/08/19 20:19:18 ##########

# Commands to make the Process: 
# Optimization Constraint
# - none -
# Application to view the Process: 
# Optimization Constraint
if [catch {open opt_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file opt_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-global -lci 1mb_lpcmod_banks.lct -touch 1mb_lpcmod_banks.imp
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

########## Tcl recorder end at 07/08/19 20:19:18 ###########


########## Tcl recorder starts at 07/08/19 20:26:29 ##########

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

########## Tcl recorder end at 07/08/19 20:26:29 ###########


########## Tcl recorder starts at 07/08/19 20:26:30 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/19 20:26:30 ###########


########## Tcl recorder starts at 07/08/19 20:28:30 ##########

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

########## Tcl recorder end at 07/08/19 20:28:30 ###########


########## Tcl recorder starts at 07/08/19 20:28:31 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/19 20:28:31 ###########


########## Tcl recorder starts at 07/08/19 21:07:03 ##########

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

########## Tcl recorder end at 07/08/19 21:07:03 ###########


########## Tcl recorder starts at 07/08/19 21:07:03 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/08/19 21:07:03 ###########


########## Tcl recorder starts at 07/12/19 19:25:37 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/12/19 19:25:38 ###########


########## Tcl recorder starts at 07/12/19 19:26:47 ##########

# Commands to make the Process: 
# Optimization Constraint
# - none -
# Application to view the Process: 
# Optimization Constraint
if [catch {open opt_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file opt_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-global -lci 1mb_lpcmod_banks.lct -touch 1mb_lpcmod_banks.imp
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

########## Tcl recorder end at 07/12/19 19:26:47 ###########


########## Tcl recorder starts at 07/12/19 19:26:55 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/12/19 19:26:55 ###########


########## Tcl recorder starts at 07/22/19 20:14:52 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
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
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_banks.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
file delete 1mb_lpcmod_banks.rsp
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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/22/19 20:14:52 ###########


########## Tcl recorder starts at 07/22/19 20:15:13 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/22/19 20:15:13 ###########


########## Tcl recorder starts at 07/22/19 20:20:44 ##########

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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/22/19 20:20:44 ###########


########## Tcl recorder starts at 07/22/19 20:21:31 ##########

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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/22/19 20:21:32 ###########


########## Tcl recorder starts at 07/22/19 20:22:53 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
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
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_banks.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
file delete 1mb_lpcmod_banks.rsp
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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/22/19 20:22:53 ###########


########## Tcl recorder starts at 07/22/19 20:29:43 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
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
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_banks.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
file delete 1mb_lpcmod_banks.rsp
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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/22/19 20:29:43 ###########


########## Tcl recorder starts at 07/22/19 20:33:52 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
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
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_banks.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
file delete 1mb_lpcmod_banks.rsp
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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/22/19 20:33:52 ###########


########## Tcl recorder starts at 07/22/19 20:34:54 ##########

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

########## Tcl recorder end at 07/22/19 20:34:54 ###########


########## Tcl recorder starts at 07/22/19 20:37:59 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
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
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_banks.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
file delete 1mb_lpcmod_banks.rsp
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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/22/19 20:37:59 ###########


########## Tcl recorder starts at 07/22/19 21:03:49 ##########

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

########## Tcl recorder end at 07/22/19 21:03:49 ###########


########## Tcl recorder starts at 07/22/19 21:39:18 ##########

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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/22/19 21:39:18 ###########


########## Tcl recorder starts at 07/22/19 21:47:40 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
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
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_banks.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
file delete 1mb_lpcmod_banks.rsp
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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/22/19 21:47:40 ###########


########## Tcl recorder starts at 07/22/19 21:50:52 ##########

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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/22/19 21:50:52 ###########


########## Tcl recorder starts at 07/22/19 22:12:05 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
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
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_banks.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
file delete 1mb_lpcmod_banks.rsp
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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/22/19 22:12:05 ###########


########## Tcl recorder starts at 07/25/19 16:13:33 ##########

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

########## Tcl recorder end at 07/25/19 16:13:33 ###########


########## Tcl recorder starts at 07/25/19 16:13:34 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 16:13:34 ###########


########## Tcl recorder starts at 07/25/19 16:14:29 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
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
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_banks.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
file delete 1mb_lpcmod_banks.rsp
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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/25/19 16:14:29 ###########


########## Tcl recorder starts at 07/25/19 16:17:10 ##########

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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/25/19 16:17:10 ###########


########## Tcl recorder starts at 07/25/19 16:19:50 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
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
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_banks.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
file delete 1mb_lpcmod_banks.rsp
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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/25/19 16:19:50 ###########


########## Tcl recorder starts at 07/25/19 16:20:22 ##########

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

########## Tcl recorder end at 07/25/19 16:20:22 ###########


########## Tcl recorder starts at 07/25/19 16:20:24 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rss w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rss: $rspFile"
} else {
	puts $rspFile "-i \"1mb_lpcmod_banks.tt4\" -lib \"$install_dir/ispcpld/dat/lc4k\" -strategy top -sdfmdl \"$install_dir/ispcpld/dat/sdf.mdl\" -simmdl \"$install_dir/ispcpld/dat/sim.mdl\" -pla \"1mb_lpcmod_banks.tt4\" -lci \"1mb_lpcmod_banks.lct\" -prj \"1mb_lpcmod_banks\" -dir \"$proj_dir\" -err automake.err -log \"1mb_lpcmod_banks.nrp\" -exf \"entity_lpcmod.exf\"  -netlist vhdl
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/sdf\" \"@1mb_lpcmod_banks.rss\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rss
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vtd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Models
#insert #
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vatd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: lpcmod_tb_id_vhda.udo.
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
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do 1mb_lpcmod_banks.vatd
#vcom 1mb_lpcmod_banks.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entity_lpcmod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=1mb_lpcmod_banks.sdf
#youdo lpcmod_tb_id_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.tado udo.rsp"] {
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
# Aldec VHDL Timing Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.tado
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

########## Tcl recorder end at 07/25/19 16:20:24 ###########


########## Tcl recorder starts at 07/25/19 16:21:12 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open 1mb_lpcmod_banks.rss w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rss: $rspFile"
} else {
	puts $rspFile "-i \"1mb_lpcmod_banks.tt4\" -lib \"$install_dir/ispcpld/dat/lc4k\" -strategy top -sdfmdl \"$install_dir/ispcpld/dat/sdf.mdl\" -simmdl \"$install_dir/ispcpld/dat/sim.mdl\" -pla \"1mb_lpcmod_banks.tt4\" -lci \"1mb_lpcmod_banks.lct\" -prj \"1mb_lpcmod_banks\" -dir \"$proj_dir\" -err automake.err -log \"1mb_lpcmod_banks.nrp\" -exf \"entity_lpcmod.exf\"  -netlist vhdl
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/sdf\" \"@1mb_lpcmod_banks.rss\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rss
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vtd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Models
#insert #
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vatd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
if [catch {open udo.rsp w} rspFile] {
	puts stderr "Cannot create response file udo.rsp: $rspFile"
} else {
	puts $rspFile "# ispDesignExpert VHDL Timing Simulation Template: lpcmod_tb_id_vhda.udo.
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
#insert # Auto generated by Post-Route VHDL Simulation Model
#insert #
#insert design create work .
#insert design open work
#insert adel -all
#path
#do 
#do 1mb_lpcmod_banks.vatd
#vcom 1mb_lpcmod_banks.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entity_lpcmod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=1mb_lpcmod_banks.sdf
#youdo lpcmod_tb_id_vhda.udo
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" lpcmod_tb_id.rsp lpcmod_tb_id.tado udo.rsp"] {
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
# Aldec VHDL Timing Simulation
if [catch {open lpcmod_tb_id_activehdl.do w} rspFile] {
	puts stderr "Cannot create response file lpcmod_tb_id_activehdl.do: $rspFile"
} else {
	puts $rspFile "set SIM_WORKING_FOLDER .
do -tcl lpcmod_tb_id.tado
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

########## Tcl recorder end at 07/25/19 16:21:12 ###########


########## Tcl recorder starts at 07/25/19 16:21:16 ##########

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

########## Tcl recorder end at 07/25/19 16:21:16 ###########


########## Tcl recorder starts at 07/25/19 16:29:26 ##########

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

########## Tcl recorder end at 07/25/19 16:29:26 ###########


########## Tcl recorder starts at 07/25/19 16:34:14 ##########

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

########## Tcl recorder end at 07/25/19 16:34:14 ###########


########## Tcl recorder starts at 07/25/19 16:40:25 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
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
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_banks.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
file delete 1mb_lpcmod_banks.rsp
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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/25/19 16:40:25 ###########


########## Tcl recorder starts at 07/25/19 16:41:21 ##########

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

########## Tcl recorder end at 07/25/19 16:41:21 ###########


########## Tcl recorder starts at 07/25/19 16:41:21 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 16:41:21 ###########


########## Tcl recorder starts at 07/25/19 16:44:17 ##########

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

########## Tcl recorder end at 07/25/19 16:44:17 ###########


########## Tcl recorder starts at 07/25/19 16:53:53 ##########

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

########## Tcl recorder end at 07/25/19 16:53:53 ###########


########## Tcl recorder starts at 07/25/19 16:53:53 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/25/19 16:53:53 ###########


########## Tcl recorder starts at 07/27/19 17:51:00 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 17:51:00 ###########


########## Tcl recorder starts at 07/27/19 18:01:26 ##########

# Commands to make the Process: 
# Aldec VHDL Functional Simulation
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
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
if [catch {open 1mb_lpcmod_banks.rsp w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rsp: $rspFile"
} else {
	puts $rspFile "#insert source {$cpld_bin/chipsim_cmd.tcl}
#prjInfo 1mb_lpcmod_banks.sty
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 1mb_lpcmod_banks.rsp 1mb_lpcmod_banks.vafd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rsp
file delete 1mb_lpcmod_banks.rsp
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
#prjInfo 1mb_lpcmod_banks.sty
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

########## Tcl recorder end at 07/27/19 18:01:26 ###########


########## Tcl recorder starts at 07/27/19 18:03:29 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/27/19 18:03:29 ###########


########## Tcl recorder starts at 08/10/19 12:28:38 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 1mb_lpcmod_banks.sty
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 1mb_lpcmod_banks -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"1mb_lpcmod_banks.bl2\" -omod \"1mb_lpcmod_banks\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 1mb_lpcmod_banks -lci 1mb_lpcmod_banks.lct -log 1mb_lpcmod_banks.imp -err automake.err -tti 1mb_lpcmod_banks.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -blifopt 1mb_lpcmod_banks.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 1mb_lpcmod_banks.bl2 -sweep -mergefb -err automake.err -o 1mb_lpcmod_banks.bl3 @1mb_lpcmod_banks.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -diofft 1mb_lpcmod_banks.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 1mb_lpcmod_banks.bl3 -family AMDMACH -idev van -o 1mb_lpcmod_banks.bl4 -oxrf 1mb_lpcmod_banks.xrf -err automake.err @1mb_lpcmod_banks.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 1mb_lpcmod_banks.lct -dev lc4k -prefit 1mb_lpcmod_banks.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 1mb_lpcmod_banks.bl4 -out 1mb_lpcmod_banks.bl5 -err automake.err -log 1mb_lpcmod_banks.log -mod entity_lpcmod @1mb_lpcmod_banks.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 1mb_lpcmod_banks.rs1 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs1: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -nojed -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 1mb_lpcmod_banks.rs2 w} rspFile] {
	puts stderr "Cannot create response file 1mb_lpcmod_banks.rs2: $rspFile"
} else {
	puts $rspFile "-i 1mb_lpcmod_banks.bl5 -lci 1mb_lpcmod_banks.lct -d m4s_32_30 -lco 1mb_lpcmod_banks.lco -html_rpt -fti 1mb_lpcmod_banks.fti -fmt PLA -tto 1mb_lpcmod_banks.tt4 -eqn 1mb_lpcmod_banks.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@1mb_lpcmod_banks.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 1mb_lpcmod_banks.rs1
file delete 1mb_lpcmod_banks.rs2
if [runCmd "\"$cpld_bin/tda\" -i 1mb_lpcmod_banks.bl5 -o 1mb_lpcmod_banks.tda -lci 1mb_lpcmod_banks.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 1mb_lpcmod_banks -if 1mb_lpcmod_banks.jed -j2s -log 1mb_lpcmod_banks.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/10/19 12:28:38 ###########

