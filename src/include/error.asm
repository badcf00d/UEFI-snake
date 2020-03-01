; contains functions for lower level stuff

errorCode:
    push rax                    ; save the error code for the UEFI

    mov rcx, errorString        ; set rcx (argument 1) to the error string
    call printString            ; print the error string
    call printNumber            ; print the number at the head of the stack
    
    pop rax                     ; restore the error code
    jmp errorHandler
    
errorHandler:
%ifdef return_uefi
    mov rsp, [ptrUEFI]
    ret
%else
    jmp $
%endif
