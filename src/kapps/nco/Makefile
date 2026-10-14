# nco ? NC on Plan JT multibank (scaffold).
# Pack: bin/nco.com + bin/nco/codeB_XX.bin
#
# Bank roles: 01 UI | 02 panel | 03 fileops | 04 cold+menu | 05 CDFS
BANKS := 01 02 03 04 05
OVL_SYMS := bdosputs printf strncpy strncat memcpy ?STRCMP_L11 ?STRCHR_L11 \
	OS_GETMAINPAGES OS_GETAPPMAINPAGES OS_NEWPAGE OS_DELPAGE OS_SETPG8000 OS_SETPGC000 OS_SETXY OS_SETCOLOR OS_CLS OS_GETTIME \
	OS_GETKEY OS_CHDIR OS_CHDRV OS_GETPATH OS_SETSYSDRV OS_OPENHANDLE OS_CLOSEHANDLE \
	OS_READHANDLE OS_WRITEHANDLE OS_CREATEHANDLE OS_GETFILESIZE OS_GETFILETIME OS_SEEKHANDLE OS_SETFILETIME OS_GETFILINFO OS_OPENDIR OS_READDIR \
	OS_DELETE OS_RENAME OS_MKDIR OS_NEWAPP OS_RUNAPP OS_WAITPID OS_DROPAPP YIELD OS_GETCONFIG \
	g_cd_sec g_cd_sec_lba g_cd_root_lba g_cd_root_size g_cd_dir_lba g_cd_dir_size g_cd_dir_off g_cd_mounted \
	g_cd_joliet g_cd_at_root g_cd_tmpname \
	g_cd_stat g_cd_cmd g_cd_head g_cd_cylhi g_cd_cyllo g_cd_datlo g_cd_dathi g_cd_channel g_cd_ports_ok \
	g_cd_file_open g_cd_file_path g_cd_file_lba g_cd_file_size \
	g_ini_enable_cd_mount botMenuCd nc_path_is_cd nc_panel_is_cd nc_cd_path_parent \
	g_ui_cd_ro g_ui_cd_nodir g_ui_cd_noview \
	mb_cdfs_present mb_cdfs_opendir mb_cdfs_readdir mb_cdfs_read \
	panel_request_unique_page menu_close_and_redraw menu_apply_choice panel_fmt_size panel_fmt_size10 panel_fmt_size_brief \
	draw_panel_frame draw_panel_background draw_panel_footer draw_bottom_info \
	mb_panel_chdir_only mb_read_panel_dir_at mb_redraw_panels_full m_panel_chdir_only m_read_panel_dir_at m_panels_remap_bank_window m_redraw_panels_full \
	m_panels_redraw_both m_draw_panel m_panel_sort_notice_show m_run_restore_ui \
	m_run_save_cwd m_run_restore_cwd m_run_restore_session_bank m_run_resident_page \
	m_run_active_panel m_run_build_cmdline m_run_action_view m_run_action_edit m_run_action_selected \
	m_cmd_clear m_cmd_begin m_cmd_handle_key m_cmd_fill_bottom_snap m_cmd_execute \
	mb_read_panel_dir_at mb_draw_panel mb_panels_remap_bank_window mb_panels_reload_both \
	mb_panels_paint_both mb_panels_draw_all mb_switch_file_page mb_panel_menu_apply \
	mb_action_view mb_action_edit mb_run_selected_file mb_nvext_load mb_nvext_find_handler \
	mb_ui_dialog_input \
	panel_files_scroll_up panel_files_scroll_down \
	g_cmd_active g_cmd_len g_cmd_cursor g_cmd_line g_nvext_size g_ncext_off g_ncext_size \
	g_run_handler g_nvext_io g_ui_nv_ext g_ui_select g_ui_deselect g_ui_mask g_mark_mask \
	nco_vram_span nco_vram_begin nco_vram_text nco_vram_attr_begin nco_vram_attr nco_vram_end \
	nco_vx nco_vy nco_vn nco_va nco_vp g_stat_line
# --------------------------------------------------------------------

OUTDIR  := bin
BANKDIR := $(OUTDIR)/nco
BIN		:= $(OUTDIR)/nc.com
INSTDIR :=
# BDOS like nc: no os_initstdio; HIDEFROMPARENT + SETGFX first.
CONSOLE := BDOS

SRCC	:= main.c mb_core.c bank_call.c nco_data.c nco_root.c
SRCH	:= mb_inc.h mb_plug.h mb_banks.h bank_jt.h nc_inc.h nc_plug.h nc_panel.h nc_colors.h mb_req.h
SRCA	:= force_helpers.asm nco_vram.asm
XCLFILE	:= lnk.xcl
XCL_OVL	:= lnk_ovl.xcl

include ../iarlib/iar.mk

MBOVL		:= $(TOOL)/mbovl.exe
ROOT_HASH	:= $(OBJ)/root_fp.txt
REL_BIN		:= $(ROOTDIR)/release/bin
REL_BANK	:= $(REL_BIN)/nco
FIRST_BANK	:= $(firstword $(BANKS))
BANK_BINS	:= $(foreach b,$(BANKS),$(BANKDIR)/codeB_$(b).bin)

all: mb_banks.h oslib $(BIN) $(BANK_BINS) check-addrs install
	@echo nco: $(BIN) + $(BANKDIR)/*.bin  (banks: $(BANKS))

$(OUTDIR) $(BANKDIR) $(REL_BIN) $(REL_BANK) $(OBJ):
	$(MKDIR) -p $@

mb_banks.h: Makefile $(MBOVL)
	$(MBOVL) gen-h $(words $(BANKS)) $@

# Per-bank JT: bank_jt.asm / bank_jt2..bank_jt4.asm
$(OBJ)/bank_jt01.r01: bank_jt.asm | $(OBJ)
	$(AZ80) -uu -S -v0 -O$(OBJ)/ -I$(OSSDK) bank_jt.asm
	$(CP) $(OBJ)/bank_jt.r01 $@

$(OBJ)/bank_jt02.r01: bank_jt2.asm | $(OBJ)
	$(AZ80) -uu -S -v0 -O$(OBJ)/ -I$(OSSDK) bank_jt2.asm
	$(CP) $(OBJ)/bank_jt2.r01 $@

$(OBJ)/bank_jt03.r01: bank_jt3.asm | $(OBJ)
	$(AZ80) -uu -S -v0 -O$(OBJ)/ -I$(OSSDK) bank_jt3.asm
	$(CP) $(OBJ)/bank_jt3.r01 $@

$(OBJ)/bank_jt04.r01: bank_jt4.asm | $(OBJ)
	$(AZ80) -uu -S -v0 -O$(OBJ)/ -I$(OSSDK) bank_jt4.asm
	$(CP) $(OBJ)/bank_jt4.r01 $@

$(OBJ)/bank_jt05.r01: bank_jt5.asm | $(OBJ)
	$(AZ80) -uu -S -v0 -O$(OBJ)/ -I$(OSSDK) bank_jt5.asm
	$(CP) $(OBJ)/bank_jt5.r01 $@

define BANK_template
$$(OBJ)/codebank_$(1).r01: codebank_$(1).c $$(SRCH) $$(LIBH) | $$(OBJ)
	$$(ICCZ80) -C -v0 -ml -s7 -S -uu -e -K -gA -O$$(OBJ)/ -L$$(OBJ)/ -A$$(OBJ)/ -I$$(IARINC) -I$$(LIBDIR) codebank_$(1).c
	powershell -NoProfile -Command "(Get-Content -Raw '$$(OBJ)/codebank_$(1).s01') -replace 'RSEG[ \t]+CSTR\b','RSEG CSTR_RESIDENT' -replace 'RSEG[ \t]+CCSTR\b','RSEG CCSTR_RESIDENT' -replace 'RSEG[ \t]+CONST\b','RSEG CONST_RESIDENT' | Set-Content -NoNewline '$$(OBJ)/codebank_$(1)_b.s01'"
	@powershell -NoProfile -Command "if (Select-String -Path '$$(OBJ)/codebank_$(1)_b.s01' -Pattern 'RSEG[ \t]+(IDATA0|UDATA0|DATA0|CONST|CSTR)\b' -Quiet) { Write-Error 'BANK emits low DATA/CONST/CSTR'; exit 1 }"
	$$(AZ80) -uu -S -v0 -O$$(OBJ)/ -I$$(OSSDK) $$(OBJ)/codebank_$(1)_b.s01
	$$(CP) $$(OBJ)/codebank_$(1)_b.r01 $$(OBJ)/codebank_$(1).r01

# Keep symbol: bank_jt / bank_jt2 / bank_jt3 / bank_jt4
JT_KEEP_$(1) := bank_jt$(if $(filter 01,$(1)),,$(patsubst 0%,%,$(1)))

ifeq ($(1),01)
$$(OBJ)/mb_ovl$(1).com: $$(LIBDIR)iar.lib $$(OBJC) $$(OBJA) $$(OBJ)/bank_jt$(1).r01 $$(OBJ)/codebank_$(1).r01 $$(XCL_OVL) | $$(OBJ)
	$$(XLINK) $$(LNK_CONS) -gbank_jt -gforce_helpers $$(OBJC) $$(OBJA) $$(OBJ)/bank_jt$(1).r01 $$(OBJ)/codebank_$(1).r01 -FRAW-BINARY -S -o $$@ -l $$(OBJ)/cout_ovl$(1).html -xehinms -Z\(CODE\)DBGMON=FFFF-FFFF $$(LIBDIR)iar.lib -C $$(IARLIB) -f $$(XCL_OVL)
else
$$(OBJ)/mb_ovl$(1).com: $$(LIBDIR)iar.lib $$(OBJC) $$(OBJA) $$(OBJ)/bank_jt$(1).r01 $$(OBJ)/codebank_$(1).r01 $$(XCL_OVL) | $$(OBJ)
	$$(XLINK) $$(LNK_CONS) -g$$(JT_KEEP_$(1)) -gforce_helpers $$(OBJC) $$(OBJA) $$(OBJ)/bank_jt$(1).r01 $$(OBJ)/codebank_$(1).r01 -FRAW-BINARY -S -o $$@ -l $$(OBJ)/cout_ovl$(1).html -xehinms -Z\(CODE\)DBGMON=FFFF-FFFF $$(LIBDIR)iar.lib -C $$(IARLIB) -f $$(XCL_OVL)
endif

$$(BANKDIR)/codeB_$(1).bin: $$(OBJ)/mb_ovl$(1).com $$(MBOVL) | $$(BANKDIR)
ifeq ($(1),$$(FIRST_BANK))
	$$(RM) $$(ROOT_HASH)
endif
	$$(MBOVL) extract $$< $$@ --root-hash $$(ROOT_HASH)
endef

$(foreach b,$(BANKS),$(eval $(call BANK_template,$(b))))

PREV_BIN :=
$(foreach b,$(BANKS),\
	$(if $(PREV_BIN),$(eval $(BANKDIR)/codeB_$(b).bin: $(PREV_BIN)))\
	$(eval PREV_BIN := $(BANKDIR)/codeB_$(b).bin))

$(BIN): $(LIBDIR)iar.lib $(OBJC) $(OBJA) lnk.xcl mb_banks.h | $(OBJ) $(OUTDIR)
	$(XLINK) $(LNK_CONS) -gforce_helpers $(OBJC) $(OBJA) $(LINK_OPTIONS) $(LIBDIR)iar.lib -C $(IARLIB) -f $(XCLFILE)

check-addrs: $(BIN) $(BANK_BINS) $(MBOVL)
	$(foreach b,$(BANKS),$(MBOVL) check $(OBJ)/cout.html $(OBJ)/cout_ovl$(b).html $(OVL_SYMS) &&) echo check-addrs OK

install: $(BIN) $(BANK_BINS) | $(REL_BIN) $(REL_BANK)
	$(CP) $(BIN) $(REL_BIN)/
	$(foreach b,$(BANKS),$(CP) $(BANKDIR)/codeB_$(b).bin $(REL_BANK)/ &&) echo install OK

clean:
	$(RM) $(OBJ) $(OUTDIR) $(ROOT_HASH) mb_banks.h
