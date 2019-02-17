
tnvcmds
        db key_redraw
        db Enter
        db cs0 ;backspace
        db cs5 ;left
        db cs8 ;right
        db cs6 ;down
        db cs7 ;up
        db csSpace
        db csss
	db '!'
	db '@'
	db '#'
	db '$'
        db '0'
        db '1'
        db '2'
        db '3'
        db '4'
        db '5'
        db '6'
        db '7'
        db '8'
        db '9'
        db ' '
        db cs3
        db cs4
        db '%'
        db '*'
        db Home
        db End
nnvcmds=$-tnvcmds       
        dw editcmd_End
        dw editcmd_Home
        dw editcmd_invfiles
        dw editcmd_ss5
        dw editcmd_pageDown
        dw editcmd_pageUp
	dw editcmd_space
        dw editcmd_9
        dw editcmd_8
        dw editcmd_7
        dw editcmd_6
        dw editcmd_5
        dw editcmd_4
        dw editcmd_3
        dw editcmd_2
        dw editcmd_1
	dw editcmd_0
        dw editcmd_ss4
        dw editcmd_ss3
        dw editcmd_ss2
        dw editcmd_ss1
        dw editcmd_tab
        dw editcmd_quit
        dw editcmd_up
        dw editcmd_down
        dw editcmd_right
        dw editcmd_left
        dw editcmd_backspace
        dw editcmd_enter
        dw editcmd_reprintall_keepcursor
     
        