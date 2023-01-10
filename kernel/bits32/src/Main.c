#include "Types.h"
#include "TextColor.h"

void kPrintString(int iX, int iY, const char* pcString, int color);
BOOL kInitializeKernel64Area(void);
BOOL kIsMemoryEnough(void);

void Main(void) {
    kPrintString(1, 8, "C Object Processing.", YELLOW);
    kPrintString(35, 8, ">> COMPLETE <<", GREEN);

    DWORD i;
    kPrintString(1, 9, "Minimum Memory Size Check.", GRAY);
    if(kIsMemoryEnough() == FALSE) {
        kPrintString(35, 9, ">> FAIL <<", RED);
        kPrintString(1, 10, "Not Enough Memory. Require More Over 64mb Space.", RED);
        while(1);
    }
    else kPrintString(35, 9, ">> COMPLETE <<", GREEN);

    kPrintString(1, 10, "IA-32e Kernel Area Initialize.", GRAY);
    if(kInitializeKernel64Area() == FALSE) {
        kPrintString(35, 10, ">> FAIL <<", RED);
        kPrintString(1, 11, "Kernel Init Error.", RED);
        while(1);
    }
    kPrintString(35, 10, ">> COMPLETE <<", GREEN);

    while(1);
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
    pdwCurrentAddress = (DWORD*) 0X100000;

    while((DWORD) pdwCurrentAddress < 0x4000000) {
        *pdwCurrentAddress = 0x12345678;
        if( *pdwCurrentAddress != 0x12345678) return FALSE;
        pdwCurrentAddress += (0x100000 / 4);
    }
    return TRUE;
}