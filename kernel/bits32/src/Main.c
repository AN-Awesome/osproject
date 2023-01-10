#include "Types.h"
#include "TextColor.h"

void kPrintString(int iX, int iY, const char* pcString, int color);

void Main(void) {
    kPrintString(1, 8, "C Object Processing..", YELLOW);
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