#include "Types.h"
#include "TextColor.h"

void kPrintString(int iX, int iY, const char* pcString, int color);
BOOL kInitializeKernel64Area(void);
BOOL kIsMemoryEnough(void);

void Main(void) {
    kPrintString(1, 8, "C Object Processing.", YELLOW);
    kPrintString(24, 8, ">> COMPLETE <<", GREEN);

    DWORD i;
    kPrintString(1, 9, "Minimum Memory Size Check.", PINK);
    if(kIsMemoryEnough() == FALSE) {
        kPrintString(31, 9, ">> FAIL <<", RED);
        kPrintString(1, 10, "Not Enough Memory. Require More Over 64mb Space.", RED_BRIGHT);
        while(1);
    }
    else kPrintString(31, 9, ">> COMPLETE <<", GREEN);

    kPrintString(0, 10, "IA-32e Kernel Area Initialize.", PINK);
    kPrintString(30, 5, ">> FAIL <<", RED);

    /*
    // IA-32e 모듸 커널 영역을 초기화
    if(kInitializeKernel64Area() == FALSE) {
        kPrintString(45, 5, "Fail", PINK);
        kPrintString(0, 6, "Kernel Area Initialization Fail~!!", PINK);
        while(1);
    }
    kPrintString(45, 5, "Pass");
    */
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