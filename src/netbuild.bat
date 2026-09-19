@echo on
setlocal
set "makeall=1"
cd /d "%~dp0"
:: --- —борка ядра (папка kernel) ---
pushd kernel
call build_kernel_atm2_esp.bat
call build_kernel_evo_esp.bat
popd
:: --- —борка ѕриложений (папка kapps) ---
pushd kapps\atelnet      & call build.bat & popd
pushd kapps\calendar     & call build.bat & popd
pushd kapps\enet         & call build.bat & popd
pushd kapps\espcfg       & call build.bat & popd
pushd kapps\getpic       & call build.bat & popd
pushd kapps\girc         & call build.bat & popd
pushd kapps\gopher       & call build.bat & popd
pushd kapps\svnesp       & call build.bat & popd
pushd kapps\time2        & call build.bat & popd
pushd kapps\updater      & call build.bat & popd
pushd kapps\zifi         & call build.bat & popd
pushd kapps\zxart-radio  & call build.bat & popd
pushd kapps\zxdb         & call build.bat & popd
pushd scrnet             & call build.bat & popd
endlocal