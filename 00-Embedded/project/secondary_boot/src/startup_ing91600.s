;/**************************************************************************//**
; * @file     startup_ARMCM3.s
; * @brief    CMSIS Core Device Startup File for
; *           ARMCM3 Device Series
; * @version  V1.08
; * @date     03. February 2012
; *
; * @note
; * Copyright (C) 2012 ARM Limited. All rights reserved.
; *
; * @par
; * ARM Limited (ARM) is supplying this software for use with Cortex-M 
; * processor based microcontrollers.  This file can be freely distributed 
; * within development tools that are supporting such ARM based processors. 
; *
; * @par
; * THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
; * OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
; * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
; * ARM SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR
; * CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
; *
; ******************************************************************************/
;/*
;//-------- <<< Use Configuration Wizard in Context Menu >>> ------------------
;*/

Stack_Size      EQU     0x00000400

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp
                EXPORT  __initial_sp


                EXPORT  __heap_base
                EXPORT  __heap_limit
                
Heap_Size       EQU     0

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit

                PRESERVE8
                THUMB

; Vector Table Mapped to Address 0 at Reset

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors

__Vectors       DCD     __initial_sp              ; Top of Stack
                DCD     Reset_Handler             ; Reset Handler
                
__Vectors_End

__Vectors_Size  EQU     __Vectors_End - __Vectors


                AREA    |.text|, CODE, READONLY


; Reset Handler

Reset_Handler   PROC
                EXPORT  Reset_Handler
				IMPORT  do_fota

                ; 检查 FOTA 标准位
				LDR     R0, =0x02002000 - 4
				LDR     R0, [R0]
				LDR     R1, =0x5A5A5A5A
				CMP     R0, R1
				BEQ		START_FOTA

                ; 正常启动
				LDR     R0, =0x02003000
				LDR		R0, [R0]		; R0 = vector address
				LDR		R1, [R0, #0x0]
				MSR     MSP, R1
				LDR		R1, [R0, #0x4]
				BX		R1

START_FOTA
				LDR  	R0, =do_fota
				BX      R0

                ENDP

                ALIGN

main            PROC
                EXPORT  main
                ENDP
                
                ALIGN

                END
