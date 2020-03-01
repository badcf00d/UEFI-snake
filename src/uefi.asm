; Modified from https://github.com/BrianOtto/nasm-uefi

bits 64         ; generate 64-bit code
default rel     ; default to RIP-relative addressing
section .text   ; contains the program code

%include "src/include/typedefs.asm" 
%include "src/include/print.asm"
%include "src/include/error.asm"

global _start   ; allows the linker to see this symbol

_start:
    
    ; The UEFI Firmware calls this function with 2 arguments:
    ;   Argument 1 (rcx): a pointer to the EFI_HANDLE  
    ;   Argument 2 (rdx): a pointer to the EFI_SYSTEM_TABLE    
    
    mov [ptrUEFI], rsp
    mov [imageHandle], rcx
    mov [systemTable], rdx

    mov rcx, [rdx + EFI_SYSTEM_TABLE.ConOut]                    ; ConOut is a EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL for the default console
    call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.ClearScreen]
    cmp rax, EFI_SUCCESS
    jne errorCode

    mov rcx, helloWorld
    call printString

    jmp $           ; loop forever

codesize equ $ - $$




section .data   ; contains the program data
    helloWorld      db  __utf16__ `Hello World\0`
    errorString     db  __utf16__ `\r\n\nError Code: \0`
    imageHandle     dq  0          
    systemTable     dq  0          
    ptrUEFI         dq  0

datasize equ $ - $$
