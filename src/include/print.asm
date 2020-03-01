; Contains functions for printing data


printNumber:
    mov rax, [rsp + 8]          ; skip over the return pointer
    mov r12, rsp                ; save the stack pointer, r12 is considered non-volatile
    push __utf16__ `\r\n\0`     ; carriage return, new line, null terminator
printNumberLoop:
    xor rdx, rdx                ; zero out RDX, it is used as the high word in the division
    mov rcx, 10                 ; set divisor
    div rcx                     ; divides RAX by RCX, quotient in RAX, remainder in RDX
    add dx, 0x30                ; convert to ASCII character
    push dx                     ; push to stack

    cmp rax, 0                  ; have we finished the number?
    jnz printNumberLoop         ; loop again if we haven't

    mov rcx, rsp                ; rcx (argument 1) is a pointer to a string to print
    call printString            ; print the string
    mov rsp, r12                ; restore the stack pointer
    ret                         ; return

printString:
    mov rdx, rcx                                                ; set the 2nd argument to the passed in string
    mov rcx, [ptrSystemTable]                                      ; get the EFI_SYSTEM_TABLE
    mov rcx, [rcx + EFI_SYSTEM_TABLE.ConOut]                    ; set the 1st argument to EFI_SYSTEM_TABLE.ConOut
    
    call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.OutputString]
    
    cmp rax, EFI_SUCCESS
    jne errorCode
    ret
