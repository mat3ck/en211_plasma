# 
# Synthesis run script generated by Vivado
# 

namespace eval rt {
    variable rc
}
set rt::rc [catch {
  uplevel #0 {
    set ::env(BUILTIN_SYNTH) true
    source $::env(HRT_TCL_PATH)/rtSynthPrep.tcl
    rt::HARTNDb_resetJobStats
    rt::HARTNDb_resetSystemStats
    rt::HARTNDb_startSystemStats
    rt::HARTNDb_startJobStats
    set rt::cmdEcho 0
    rt::set_parameter writeXmsg true
    rt::set_parameter enableParallelHelperSpawn true
    set ::env(RT_TMP) "./.Xil/Vivado-22234-luxembourg/realtime/tmp"
    if { [ info exists ::env(RT_TMP) ] } {
      file delete -force $::env(RT_TMP)
      file mkdir $::env(RT_TMP)
    }

    rt::delete_design

    set rt::partid xc7a100tcsg324-1
    source $::env(HRT_TCL_PATH)/rtSynthParallelPrep.tcl

    set rt::multiChipSynthesisFlow false
    source $::env(SYNTH_COMMON)/common_vhdl.tcl
    set rt::defaultWorkLibName xil_defaultlib

    set rt::useElabCache false
    if {$rt::useElabCache == false} {
      rt::read_vhdl -lib xil_defaultlib {
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/alu.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/bus_mux.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/cam_pkg.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/comb_alu_1.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/control.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/conversion.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/dma_engine.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/mem_ctrl.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/memory_64k.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/mlite_cpu.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/mlite_pack.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/mult.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/pc_next.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/pipeline.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/plasma.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/ram_boot.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/reg_bank.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/sequ_alu_1.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/shifter.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/top_plasma.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/txt_util.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/vga_bitmap_160x100.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/vga_ctrl.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/vgd_bitmap_640x480.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/stop_counter.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/lfsr.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/ClkDiv_66_67kHz.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/ClkDiv_5Hz.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/spiCtrl.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/spiMode0.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/PmodJSTK.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/uart.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/buttons.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/pmodoledrgb_bitmap.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/pmodoledrgb_charmap.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/pmodoledrgb_nibblemap.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/pmodoledrgb_sigplot.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/pmodoledrgb_terminal.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/ctrl_SL.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/ctrl_7seg.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/trans_hexto7seg.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/mux_7seg.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/mod_7seg.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/PLASMA/i2c.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/coproc_1.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/coproc_2.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/coproc_3.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/coproc_4.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_1.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_2.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_3.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_4.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_5.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_6.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_7.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_8.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_9.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_10.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_11.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_12.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_13.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_14.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_15.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_16.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_17.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_18.vhd
      /net/e/vdubreuil/Desktop/EN211/plasma_pmod/HDL/CUSTOM/pgcd/function_19.vhd
    }
      rt::filesetChecksum
    }
    rt::set_parameter usePostFindUniquification false
    set rt::top top_plasma
    rt::set_parameter enableIncremental true
    set rt::reportTiming false
    rt::set_parameter elaborateOnly true
    rt::set_parameter elaborateRtl true
    rt::set_parameter eliminateRedundantBitOperator false
    rt::set_parameter elaborateRtlOnlyFlow false
    rt::set_parameter writeBlackboxInterface true
    rt::set_parameter merge_flipflops true
    rt::set_parameter srlDepthThreshold 3
    rt::set_parameter rstSrlDepthThreshold 4
# MODE: 
    rt::set_parameter webTalkPath {}
    rt::set_parameter enableSplitFlowPath "./.Xil/Vivado-22234-luxembourg/"
    set ok_to_delete_rt_tmp true 
    if { [rt::get_parameter parallelDebug] } { 
       set ok_to_delete_rt_tmp false 
    } 
    if {$rt::useElabCache == false} {
        set oldMIITMVal [rt::get_parameter maxInputIncreaseToMerge]; rt::set_parameter maxInputIncreaseToMerge 1000
        set oldCDPCRL [rt::get_parameter createDfgPartConstrRecurLimit]; rt::set_parameter createDfgPartConstrRecurLimit 1
        $rt::db readXRFFile
      rt::run_rtlelab -param {
  { eUart 1'b1 }
  { eButtons 1'b1 }
  { eRGBOLED 1'b1 }
  { eSwitchLED 1'b1 }
  { eSevenSegments 1'b1 }
  { eI2C 1'b1 }
  { eCoproc 1'b1 }
  { eVGA 1'b0 }
  { eLFSR 1'b1 }
  { eJOYSTICK 1'b1 }
} -module $rt::top
        rt::set_parameter maxInputIncreaseToMerge $oldMIITMVal
        rt::set_parameter createDfgPartConstrRecurLimit $oldCDPCRL
    }

    set rt::flowresult [ source $::env(SYNTH_COMMON)/flow.tcl ]
    rt::HARTNDb_stopJobStats
    if { $rt::flowresult == 1 } { return -code error }


    if { [ info exists ::env(RT_TMP) ] } {
      if { [info exists ok_to_delete_rt_tmp] && $ok_to_delete_rt_tmp } { 
        file delete -force $::env(RT_TMP)
      }
    }

    source $::env(HRT_TCL_PATH)/rtSynthCleanup.tcl
  } ; #end uplevel
} rt::result]

if { $rt::rc } {
  $rt::db resetHdlParse
  set hsKey [rt::get_parameter helper_shm_key] 
  if { $hsKey != "" && [info exists ::env(BUILTIN_SYNTH)] && [rt::get_parameter enableParallelHelperSpawn] } { 
     $rt::db killSynthHelper $hsKey
  } 
  source $::env(HRT_TCL_PATH)/rtSynthCleanup.tcl
  return -code "error" $rt::result
}
