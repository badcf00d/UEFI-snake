getFrameBuffer:
    mov rax, [ptrSystemTable]                                           ; get the EFI_SYSTEM_TABLE
    mov rax, [rax + EFI_SYSTEM_TABLE.BootServices]                      ; get the EFI_SYSTEM_TABLE.BootServices
    mov rcx, EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID                          ; set the 1st argument to the GUID for the graphics protocol
    mov rdx, 0                                                          ; set the 2nd argument to NULL
    lea r8, [ptrInterface]                                              ; set the 3rd argument to where it should return the EFI_GRAPHICS_OUTPUT_PROTOCOL
    
    call [rax + EFI_BOOT_SERVICES.LocateProtocol]                       ; run EFI_BOOT_SERVICES.LocateProtocol
    cmp rax, EFI_SUCCESS
    jne errorCode

    mov rcx, [ptrInterface]                                             ; get the EFI_GRAPHICS_OUTPUT_PROTOCOL
    mov rcx, [rcx + EFI_GRAPHICS_OUTPUT_PROTOCOL.Mode]                  ; get the EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE
    mov rcx, [rcx + EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE.FrameBufferBase]  ; get the EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE.FrameBufferBase
    mov [ptrFrameBuffer], rcx                                           ; store the framebuffer
    
    ret