#include <efi.h>
#include <efilib.h>

EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    // Inicializa la librería GNU-EFI
    InitializeLib(ImageHandle, SystemTable);
    
    Print(L"Iniciando analisis de seguridad...\r\n");
    
    // Inyección de un software breakpoint (INT3)
    unsigned char code[] = { 0xCC };
    
    if ((unsigned char)code[0] == (unsigned char)0xCC) {
        Print(L"Breakpoint estatico alcanzado.\r\n");
    }
    
    return EFI_SUCCESS;
}