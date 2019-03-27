REM
REM   TEST_ETH.IDE - command file
REM   Created: Mon Sep 18 09:52:49 2017
 
IF EXIST "TEST_ETH.MCE" DEL "TEST_ETH.MCE" 
IF EXIST "TEST_ETH.HEX" DEL "TEST_ETH.HEX" 
IF EXIST "TEST_ETH.ELF" DEL "TEST_ETH.ELF" 
"C:\Program Files\Phyton CodeMaster-ARM\2_40_00\CMC-ARM\Bin\MCAARM.EXE" @startup_core_cm0.{1}
"C:\Program Files\Phyton CodeMaster-ARM\2_40_00\CMC-ARM\Bin\MCCARM.EXE" @EthFunc.{1}
"C:\Program Files\Phyton CodeMaster-ARM\2_40_00\CMC-ARM\Bin\MCLINK.EXE" @TEST_ETH.(1)
