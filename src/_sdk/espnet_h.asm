; Extra ESPNET calls (not in the WIZNET set).
; DEFINE ESPNET + include sys_h.asm already maps OS_NETSOCKET / OS_ACCEPT /
; OS_WIZNETREAD / OS_WIZNETWRITE / OS_ESPINIT.
; include "../_sdk/espnet.asm" in the binary.

        ifndef OS_ESPINFO_DEFINED
        define OS_ESPINFO_DEFINED

        macro OS_ESPINFO
        call esp_info
        endm
        macro OS_ESPDNSRESOLVE
        call esp_dns
        endm
        macro OS_ESPWIFI_SCAN
        call esp_wifi_scan
        endm
        macro OS_ESPWIFI_CONNECT
        call esp_wifi_connect
        endm
        macro OS_ESPWIFI_DISC
        call esp_wifi_disc
        endm
        macro OS_ESPWIFI_STATUS
        call esp_wifi_status
        endm
        macro OS_ESPECHO
        call esp_echo
        endm
        endif
