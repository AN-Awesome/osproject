#include "Types.h"
#include "Page.h"
#include "ModeSwitch.h"
#include "TextColor.h"

void kPrintString(int iX, int iY, const char* pcString, int color);
BOOL kInitializeKernel64Area(void);
BOOL kIsMemoryEnough(void);

// C Object Kernel Entry Point(Main())
void Main(void) {
    //START CAPTION PRINTF
    kPrintString(1, 8, "C Object Processing.", YELLOW);
    kPrintString(35, 8, ">> COMPLETE <<", GREEN);

    // LOCAL VARIABLES
    DWORD i;
    DWORD dwEAX, dwEBX, dwECX, dwEDX;
    char vcVendorString[13] = {0, };
    
    // Checking if the current memory size is greater than the minimum requiRED_BR amount.
    kPrintString(1, 9, "Minimum Memory Size Check.", BROWN);
    if(kIsMemoryEnough() == FALSE) {
        kPrintString(35, 9, ">> FAIL <<", RED_BR);
        kPrintString(1, 10, "Not Enough Memory. Require More Over 64mb Space.", RED_BR);
        while(1);   // jmp $
    }
    else kPrintString(35, 9, ">> COMPLETE <<", GREEN);

    // IA-32e Kernel Area Init. Process
    kPrintString(1, 10, "IA-32e Kernel Area Initialize.", BROWN);
    if(kInitializeKernel64Area() == FALSE) {
        kPrintString(35, 10, ">> FAIL <<", RED_BR);
        kPrintString(1, 11, "Kernel Init Error.", RED_BR);
        while(1);   // jmp $
    }
    kPrintString(35, 10, ">> COMPLETE <<", GREEN);

    // Create Page Table for IA-32e Mode Kernel. 
    kPrintString(1, 11, "IA-32e Kernel Page Tables Init.", BROWN);
    kInitializePageTables();
    kPrintString(35, 11, ">> COMPLETE <<", GREEN);

    // Check the manufacturer information of the processor.
    kReadCPUID(0x00, &dwEAX, &dwEBX, &dwECX, &dwEDX);
    *(DWORD*) vcVendorString = dwEBX;
    *((DWORD*) vcVendorString + 1) = dwEDX;
    *((DWORD*) vcVendorString + 2) = dwECX;
    kPrintString(1, 13, "Processor Vendor String: ", BLUE_BR);
    kPrintString(26, 13, vcVendorString, RED_BR);

    // Checks if the current processor can use a 64-bit system.
    kReadCPUID(0x80000001, &dwEAX, &dwEBX, &dwECX, &dwEDX);
    kPrintString(1, 14, "64Bit System IsSupoort: ", BLUE_BR);
    if (dwEDX & (1 << 29)) kPrintString(25, 14, "Support", SKY);
    else {
        kPrintString(40, 14, "NOT SUPPORT", RED_BR);
        while(1); // jmp $
    }
    while(1); // jmp $
}

void kPrintString(int iX, int iY, const char* pcString, int color) {
    CHARACTER* pstScreen = (CHARACTER*) 0xB8000;
    pstScreen += (iY * 80) + iX;
    for (int i = 0; pcString[i] != 0; i++) {
        pstScreen[i].bCharactor = pcString[i];
        pstScreen[i].bAttribute = color;
    }
}

BOOL kInitializeKernel64Area(void) {
    DWORD* pdwCurrentAddress;
    pdwCurrentAddress = (DWORD*)0x100000;

    while((DWORD)pdwCurrentAddress < 0x600000) {
        *pdwCurrentAddress = 0x00;
        if(*pdwCurrentAddress != 0) return FALSE;
        pdwCurrentAddress++;
    }
    return TRUE;
}

BOOL kIsMemoryEnough(void) {
    DWORD* pdwCurrentAddress;
    pdwCurrentAddress = (DWORD*) 0x100000;

    while((DWORD) pdwCurrentAddress < 0x4000000) {
        *pdwCurrentAddress = 0x12345678;
        if( *pdwCurrentAddress != 0x12345678) return FALSE;
        pdwCurrentAddress += (0x100000 / 4);
    }
    return TRUE;
}