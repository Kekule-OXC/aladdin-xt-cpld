# Aladdin XT CPLD mods

This package contains HDL projects to program the Aladdin XT PLUS2 clone devices.

You will require Lattice ISPLever Classic software suite (version 2.0 at the time of writing) to generate programming files.
Constraint files included in each projects interface the Aladdin XT PLUS2 PCB exclusively.
All designs require the use of internal pullups of the LC4032V CPLD to operate properly.

Projects:

**1MB_LPCmod_banks**
    
    Support 1MB SST49LF080A device and split in 2 * 512KB flash banks with the help of a switch connected between pad H0 and ground.
    Optional device disable feature on long power button press by linking the BT pad to the front panel power button.
    If not interfacing front panel power button, device is always active.
    
**1MB_LPCmod_OSSupport**
    
    Support 1MB SST49LF080A device and gives support to XBlast OS to manage user flash banks. Split in 1 * 512KB and 1 * 256KB user banks. 
    Last 256KB bank is reserved for XBlast OS.
    
**1mb_LPCmod_protect**
    
    Support 1MB SST49LF080A device and gives a single 1MB flash bank. Optional switch connected between pad H0 and ground can disable writing support.
    Without any switch, write support is always enabled.
    Optional device disable feature on long power button press by linking the BT pad to the front panel power button.
    If not interfacing front panel power button, device is always active.

**256KB_LPCmod_protect**
    
    Support 256KB SST49LF020 and SST49LF020A devices and gives a single 256KB flash bank. Optional switch connected between pad H0 and ground can disable writing support.
    Without any switch, write support is always enabled.
    Optional device disable feature on long power button press by linking the BT pad to the front panel power button.
    If not interfacing front panel power button, device is always active.

**2MB_LPCMod_banks**
    
    PROTOTYPE! Might not work as intended.
    Support 2MB SST49LF160C device and split in 2 * 1MB flash banks with the help of a switch connected between pad H0 and ground.
    Optional device disable feature on long power button press by linking the BT pad to the front panel power button.
    If not interfacing front panel power button, device is always active.

**LCDCheapie**
    
    UNTESTED. Might not even work as it is. Might not work in the presence of other LPC slave devices.
    Replace modchip feature by a "LPC to character LCD" bridge. Flash chip on the target device will need to be completely removed.
    Use pads previously interfacing the flash chip to connect character LCD signal lines.
    Software backlight brightness support with PWM generation.
    Usage of potentiometer for contrast adjustment is necessary.


Other files include images of JTAG interface on board and a table of pin mappings between the LC4032V CPLD, Flash chip and LPC interface.

Have fun.