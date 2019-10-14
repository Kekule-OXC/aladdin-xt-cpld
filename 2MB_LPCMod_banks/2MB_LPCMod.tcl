
########## Tcl recorder starts at 06/16/14 11:27:25 ##########

set version "1.7"
set proj_dir "C:/dev/perso/lattice/2MB_LPCMod"
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
if [runCmd "\"$cpld_bin/vhd2jhd\" 2mb_lpcmod.vhd -o 2mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 11:27:25 ###########


########## Tcl recorder starts at 06/16/14 11:32:01 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 2mb_lpcmod.vhd -o 2mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 11:32:01 ###########


########## Tcl recorder starts at 06/16/14 11:32:21 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entityLpcMod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 11:32:21 ###########


########## Tcl recorder starts at 06/16/14 11:32:51 ##########

# Commands to make the Process: 
# Optimization Constraint
# - none -
# Application to view the Process: 
# Optimization Constraint
if [catch {open opt_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file opt_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-global -lci 2mb_lpcmod.lct -touch 2mb_lpcmod.imp
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

########## Tcl recorder end at 06/16/14 11:32:51 ###########


########## Tcl recorder starts at 06/16/14 11:33:13 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entityLpcMod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.sif"] {
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
	puts $rspFile "-nodal -src 2mb_lpcmod.bl5 -type BLIF -presrc 2mb_lpcmod.bl3 -crf 2mb_lpcmod.crf -sif 2mb_lpcmod.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 2mb_lpcmod.lct
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

########## Tcl recorder end at 06/16/14 11:33:13 ###########


########## Tcl recorder starts at 06/16/14 11:35:29 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 11:35:29 ###########


########## Tcl recorder starts at 06/16/14 11:36:16 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.sif"] {
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
	puts $rspFile "-nodal -src 2mb_lpcmod.bl5 -type BLIF -presrc 2mb_lpcmod.bl3 -crf 2mb_lpcmod.crf -sif 2mb_lpcmod.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 2mb_lpcmod.lct
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

########## Tcl recorder end at 06/16/14 11:36:16 ###########


########## Tcl recorder starts at 06/16/14 11:38:15 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 11:38:15 ###########


########## Tcl recorder starts at 06/16/14 11:46:40 ##########

# Commands to make the Process: 
# JEDEC File
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 11:46:40 ###########


########## Tcl recorder starts at 06/16/14 11:46:48 ##########

# Commands to make the Process: 
# Post-Fit Re-Compile
# - none -
# Application to view the Process: 
# Post-Fit Re-Compile
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src 2mb_lpcmod.bl5 -type BLIF -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 2mb_lpcmod.lct -prc 2mb_lpcmod.lco -log 2mb_lpcmod.log -touch 2mb_lpcmod.fti
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

########## Tcl recorder end at 06/16/14 11:46:48 ###########


########## Tcl recorder starts at 06/16/14 11:46:55 ##########

# Commands to make the Process: 
# Post-Fit Pinouts
# - none -
# Application to view the Process: 
# Post-Fit Pinouts
if [catch {open lattice_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file lattice_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-src 2mb_lpcmod.tt4 -type PLA -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -postfit -lci 2mb_lpcmod.lco
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

########## Tcl recorder end at 06/16/14 11:46:55 ###########


########## Tcl recorder starts at 06/16/14 11:47:06 ##########

# Commands to make the Process: 
# Fitter Report (Text)
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 11:47:06 ###########


########## Tcl recorder starts at 06/16/14 16:57:40 ##########

set version "1.7"
set proj_dir "C:/dev/perso/lattice/2MB_LPCMod_banks"
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
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entityLpcMod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/16/14 16:57:40 ###########


########## Tcl recorder starts at 06/17/14 11:10:13 ##########

set version "1.7"
set proj_dir "C:/dev/perso/aladdin_xt_mods/2MB_LPCMod_banks"
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
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entityLpcMod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 11:10:13 ###########


########## Tcl recorder starts at 06/17/14 11:10:40 ##########

# Commands to make the Process: 
# Constraint Editor
if [runCmd "\"$cpld_bin/blifstat\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.sif"] {
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
	puts $rspFile "-nodal -src 2mb_lpcmod.bl5 -type BLIF -presrc 2mb_lpcmod.bl3 -crf 2mb_lpcmod.crf -sif 2mb_lpcmod.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 2mb_lpcmod.lct
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

########## Tcl recorder end at 06/17/14 11:10:40 ###########


########## Tcl recorder starts at 06/17/14 18:31:38 ##########

# Commands to make the Process: 
# Constraint Editor
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entityLpcMod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/blifstat\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.sif"] {
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
	puts $rspFile "-nodal -src 2mb_lpcmod.bl5 -type BLIF -presrc 2mb_lpcmod.bl3 -crf 2mb_lpcmod.crf -sif 2mb_lpcmod.sif -devfile \"$install_dir/ispcpld/dat/lc4k/m4s_32_30.dev\" -lci 2mb_lpcmod.lct
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

########## Tcl recorder end at 06/17/14 18:31:38 ###########


########## Tcl recorder starts at 06/17/14 18:32:12 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 18:32:12 ###########


########## Tcl recorder starts at 06/17/14 18:32:20 ##########

# Commands to make the Process: 
# Aldec VHDL Timing Simulation
if [catch {open 2mb_lpcmod.rss w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rss: $rspFile"
} else {
	puts $rspFile "-i \"2mb_lpcmod.tt4\" -lib \"$install_dir/ispcpld/dat/lc4k\" -strategy top -sdfmdl \"$install_dir/ispcpld/dat/sdf.mdl\" -simmdl \"$install_dir/ispcpld/dat/sim.mdl\" -pla \"2mb_lpcmod.tt4\" -lci \"2mb_lpcmod.lct\" -prj \"2mb_lpcmod\" -dir \"$proj_dir\" -err automake.err -log \"2mb_lpcmod.nrp\" -exf \"entityLpcMod.exf\"  -netlist vhdl
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/sdf\" \"@2mb_lpcmod.rss\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rss
if [catch {open 2mb_lpcmod.rsp w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rsp: $rspFile"
} else {
	puts $rspFile "#insert -- NOTE: Do not edit this file.
#insert -- Auto generated by Post-Route VHDL Simulation Models
#insert --
#insert -- End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 2mb_lpcmod.rsp 2mb_lpcmod.vtd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rsp
if [catch {open 2mb_lpcmod.rsp w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rsp: $rspFile"
} else {
	puts $rspFile "#simulator Aldec
#insert # NOTE: Do not edit this file.
#insert # Auto generated by Post-Route VHDL Simulation Models
#insert #
#insert # End
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/chipsim\" 2mb_lpcmod.rsp 2mb_lpcmod.vatd none"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rsp
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
#do 2mb_lpcmod.vatd
#vcom 2mb_lpcmod.vho
#vcom lpcmod_tb_id.vhd
#stimulus vhdl entityLpcMod lpcmod_tb_id.vhd
#insert vsim +access +r %<StimModule>% -sdfmax %<SimInst>%=2mb_lpcmod.sdf
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

########## Tcl recorder end at 06/17/14 18:32:20 ###########


########## Tcl recorder starts at 06/17/14 20:02:38 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entityLpcMod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 06/17/14 20:02:38 ###########


########## Tcl recorder starts at 07/01/14 08:04:30 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 2mb_lpcmod.vhd -o 2mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/01/14 08:04:30 ###########


########## Tcl recorder starts at 07/01/14 08:04:33 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entityLpcMod.cmd w} rspFile] {
	puts stderr "Cannot create response file entityLpcMod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entityLpcMod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/01/14 08:04:33 ###########


########## Tcl recorder starts at 12/27/18 22:44:45 ##########

set version "1.8"
set proj_dir "D:/dev/xblast/aladdin_xt_mods/2MB_LPCMod_banks"
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
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entityLpcMod
WORKING_PATH: \"$proj_dir\"
MODULE: entityLpcMod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entityLpcMod.edi -out entityLpcMod.bl0 -err automake.err -log entityLpcMod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entityLpcMod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entityLpcMod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entityLpcMod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 12/27/18 22:44:45 ###########


########## Tcl recorder starts at 07/09/19 23:07:24 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entity_lpcmod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/09/19 23:07:24 ###########


########## Tcl recorder starts at 07/09/19 23:08:50 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 2mb_lpcmod.vhd -o 2mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/09/19 23:08:50 ###########


########## Tcl recorder starts at 07/09/19 23:08:51 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entity_lpcmod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/09/19 23:08:51 ###########


########## Tcl recorder starts at 07/09/19 23:13:47 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 2mb_lpcmod.vhd -o 2mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/09/19 23:13:47 ###########


########## Tcl recorder starts at 07/09/19 23:13:48 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entity_lpcmod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/09/19 23:13:48 ###########


########## Tcl recorder starts at 07/09/19 23:15:05 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 2mb_lpcmod.vhd -o 2mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/09/19 23:15:05 ###########


########## Tcl recorder starts at 07/09/19 23:15:06 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entity_lpcmod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/09/19 23:15:06 ###########


########## Tcl recorder starts at 07/09/19 23:15:27 ##########

# Commands to make the Process: 
# Hierarchy
if [runCmd "\"$cpld_bin/vhd2jhd\" 2mb_lpcmod.vhd -o 2mb_lpcmod.jhd -m \"$install_dir/ispcpld/generic/lib/vhd/location.map\" -p \"$install_dir/ispcpld/generic/lib\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/09/19 23:15:27 ###########


########## Tcl recorder starts at 07/09/19 23:15:28 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entity_lpcmod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/09/19 23:15:28 ###########


########## Tcl recorder starts at 07/12/19 19:53:14 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entity_lpcmod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/12/19 19:53:14 ###########


########## Tcl recorder starts at 07/12/19 19:53:51 ##########

# Commands to make the Process: 
# Optimization Constraint
# - none -
# Application to view the Process: 
# Optimization Constraint
if [catch {open opt_cmd.rs2 w} rspFile] {
	puts stderr "Cannot create response file opt_cmd.rs2: $rspFile"
} else {
	puts $rspFile "-global -lci 2mb_lpcmod.lct -touch 2mb_lpcmod.imp
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

########## Tcl recorder end at 07/12/19 19:53:51 ###########


########## Tcl recorder starts at 07/12/19 19:53:57 ##########

# Commands to make the Process: 
# Fit Design
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entity_lpcmod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/12/19 19:53:57 ###########


########## Tcl recorder starts at 07/23/19 21:30:06 ##########

# Commands to make the Process: 
# Fit Design
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entity_lpcmod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 07/23/19 21:30:06 ###########


########## Tcl recorder starts at 08/10/19 13:58:19 ##########

# Commands to make the Process: 
# JEDEC File
if [catch {open entity_lpcmod.cmd w} rspFile] {
	puts stderr "Cannot create response file entity_lpcmod.cmd: $rspFile"
} else {
	puts $rspFile "STYFILENAME: 2mb_lpcmod.sty
PROJECT: entity_lpcmod
WORKING_PATH: \"$proj_dir\"
MODULE: entity_lpcmod
VHDL_FILE_LIST: 2mb_lpcmod.vhd
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
if [runCmd "\"$cpld_bin/edif2blf\" -edf entity_lpcmod.edi -out entity_lpcmod.bl0 -err automake.err -log entity_lpcmod.log -prj 2mb_lpcmod -lib \"$install_dir/ispcpld/dat/mach.edn\" -net_Vcc VCC -net_GND GND -nbx -dse -tlw -cvt YES -xor"] {
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
if [runCmd "\"$cpld_bin/mblflink\" \"entity_lpcmod.bl1\" -o \"2mb_lpcmod.bl2\" -omod \"2mb_lpcmod\"  -err \"automake.err\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/impsrc\"  -prj 2mb_lpcmod -lci 2mb_lpcmod.lct -log 2mb_lpcmod.imp -err automake.err -tti 2mb_lpcmod.bl2 -dir $proj_dir"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -blifopt 2mb_lpcmod.b2_"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mblifopt\" 2mb_lpcmod.bl2 -sweep -mergefb -err automake.err -o 2mb_lpcmod.bl3 @2mb_lpcmod.b2_ "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -diofft 2mb_lpcmod.d0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/mdiofft\" 2mb_lpcmod.bl3 -family AMDMACH -idev van -o 2mb_lpcmod.bl4 -oxrf 2mb_lpcmod.xrf -err automake.err @2mb_lpcmod.d0 "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/abelvci\" -vci 2mb_lpcmod.lct -dev lc4k -prefit 2mb_lpcmod.l0"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/prefit\" -blif -inp 2mb_lpcmod.bl4 -out 2mb_lpcmod.bl5 -err automake.err -log 2mb_lpcmod.log -mod entity_lpcmod @2mb_lpcmod.l0  -sc"] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [catch {open 2mb_lpcmod.rs1 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs1: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -nojed -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [catch {open 2mb_lpcmod.rs2 w} rspFile] {
	puts stderr "Cannot create response file 2mb_lpcmod.rs2: $rspFile"
} else {
	puts $rspFile "-i 2mb_lpcmod.bl5 -lci 2mb_lpcmod.lct -d m4s_32_30 -lco 2mb_lpcmod.lco -html_rpt -fti 2mb_lpcmod.fti -fmt PLA -tto 2mb_lpcmod.tt4 -eqn 2mb_lpcmod.eq3 -tmv NoInput.tmv
-rpt_num 1
"
	close $rspFile
}
if [runCmd "\"$cpld_bin/lpf4k\" \"@2mb_lpcmod.rs2\""] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
file delete 2mb_lpcmod.rs1
file delete 2mb_lpcmod.rs2
if [runCmd "\"$cpld_bin/tda\" -i 2mb_lpcmod.bl5 -o 2mb_lpcmod.tda -lci 2mb_lpcmod.lct -dev m4s_32_30 -family lc4k -mod entity_lpcmod -ovec NoInput.tmv -err tda.err "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}
if [runCmd "\"$cpld_bin/synsvf\" -exe \"$install_dir/ispvmsystem/ispufw\" -prj 2mb_lpcmod -if 2mb_lpcmod.jed -j2s -log 2mb_lpcmod.svl "] {
	return
} else {
	vwait done
	if [checkResult $done] {
		return
	}
}

########## Tcl recorder end at 08/10/19 13:58:19 ###########

