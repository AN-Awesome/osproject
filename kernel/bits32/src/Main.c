#include "Types.h"
#include "TextColor.h"

void kPrintString(int iX, int iY, const char* pcString, int color);
BOOL kInitializeKernel64Area(void);
BOOL kIsMemoryEnough(void);

void Main(void) {
    kPrintString(1, 8, "C Object Processing..........[Pass]", YELLOW);

    DWORD i;

    kPrintString(0, 4, "Minimum Memory Size Check..........[     ]", YELLOW);
    if(kIsMemoryEnough() == FALSE) {
        kPrintString(45, 4, "Fail");
        kPrintString(0, 5, "Not Enought Memory~!! FS64 OS Requires Over 64Mbyte Memory~!!");
        while(1);
    }
    else {
        kPrintString(45, 4, "Pass");
    }

    // IA-32e 모듸 커널 영역을 초기화
    kPrintString(0, 5, "IA-32e Kernel Area Initialize..........[     ]");
    if(kInitializeKernel64Area() == FALSE) {
        kPrintString(45, 5, "Fail");
        kPrintString(0, 6, "Kernel Area Initialization Fail~!!");
        while(1);
    }

    kPrintString(45, 5, "Pass");

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