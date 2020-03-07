; Modified from https://github.com/BrianOtto/nasm-uefi

bits 64         ; generate 64-bit code
default rel     ; default to RIP-relative addressing
section .text   ; contains the program code

%include "src/include/error.asm"
%include "src/include/typedefs.asm" 
%include "src/include/print.asm"
%include "src/include/graphics.asm"

global _start   ; allows the linker to see our entry point

_start:
; This is the UEFI image entry point, the UEFI firmware calls this function with 2 arguments:
;   Argument 1 (rcx): a pointer to the EFI_HANDLE  
;   Argument 2 (rdx): a pointer to the EFI_SYSTEM_TABLE    
    
    mov [ptrUEFI], rsp
    mov [ptrImageHandle], rcx
    mov [ptrSystemTable], rdx

    mov rcx, [rdx + EFI_SYSTEM_TABLE.ConOut]                    ; ConOut is a EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL for the default console
    call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.ClearScreen]    ; Clear the default console
    cmp rax, EFI_SUCCESS
    jne errorCode

    mov rcx, helloWorld
    call printString

    call getFrameBuffer             ; get a framebuffer to draw on
    mov rax, [ptrFrameBuffer]       ; load the framebuffer into rdx
    push rax


    mov rcx, EVT_TIMER
    mov rdx, 0
    mov r8, 0
    mov r9, 0
    lea rbx, [ptrTimerEvent]
    push rbx

    mov rax, [ptrSystemTable]
    mov rax, [rax + EFI_SYSTEM_TABLE.BootServices]
    call [rax + EFI_BOOT_SERVICES.CreateEvent]

    cmp rax, EFI_SUCCESS
    jne errorCode

    pop r10

    jmp $

    mov rcx, [ptrTimerEvent]
    mov rdx, TimerPeriodic
    mov r8,  56000                         ; 56 ms (about 18 Hz) in units of 100 nanoseconds
    mov rax, [ptrSystemTable]
    mov rax, [rax + EFI_SYSTEM_TABLE.BootServices]
    call [rax + EFI_BOOT_SERVICES.SetTimer]
    cmp rax, EFI_SUCCESS
    jne errorCode


delayUntilTick:

    mov rcx, 1
    mov rdx, [ptrTimerEvent]
    mov rax, [ptrSystemTable]
    mov rax, [rax + EFI_SYSTEM_TABLE.BootServices]
    call [rax + EFI_BOOT_SERVICES.WaitForEvent]
    cmp rax, EFI_SUCCESS
    jne errorCode
    ; r8 will have a pointer to the index of the event in the events that got signaled

    pop rax
    mov [rax], dword 0xFFFF0000     ; write 32-bits to the framebuffer (A,R,G,B)
    add rax, 4
    push rax

    jmp delayUntilTick                           ; loop forever

codeSize equ $ - $$




section .data   ; contains the program data
    helloWorld      db  __utf16__ `Hello World\0`
    errorString     db  __utf16__ `\r\n\nError Code: \0`
    ptrImageHandle  dq  0          
    ptrSystemTable  dq  0          
    ptrUEFI         dq  0
    ptrFrameBuffer  dq  0
    ptrInterface    dq  0
    ptrTimerEvent   dq  0

dataSize equ $ - $$
