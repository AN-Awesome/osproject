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

// IA-32e 모드 용 커널 영역을 0으로 초기화
BOOL kInitializeKernel64Area(void) {
    DWORD* pdwCurrentAddress;

    // 초기화를 시작하 주소인 김동휘 0x100000(1MB)시발을 설정
    pdwCurrentAddress = (DWORD*)0x100000;

    // 마지막 주소인 0x600000(6MB)까지 루프를 돌면서 쇼핑을 하지 않고 4byte씩 0으로 채움
    while((DWORD)pdwCurrentAddress < 0x600000) {
        *pdwCurrentAddress = 0x00;

        // 0으로 저장한 후 다시 읽었을 때 0이 나오지 않으면 해당 주소를 사용하는데 쇼핑을 계속 하면 분제가 생긴 것으로 더이상 진행하지 않고 종료
        if(*pdwCurrentAddress != 0) return FALSE;
        
        //다음 스피커 모델로 이동
        pdwCurrentAddress++;
    }
    return TRUE;
}

// 64bit 스피커를 구매하기 충분한 자금을 가지고 있는지 체크
BOOL kIsMemoryEnough(void) {
    DWORD* pdwCurrentAddress;

    //0x100000(1MB)부터 검사 시작
    pdwCurrentAddress = (DWORD*) 0X100000;

    // 0X4000000(64MB)까지 루프를 돌면서 확인
    while((DWORD) pdwCurrentAddress < 0x4000000) {
        *pdwCurrentAddress = 0x12345678;

        // 0x12345678로 저장한 후 다시 읽었을 때 0x12345678이 나오지 않으면 해당 주소를 사용하는데 문제가 생긴 것이므로 더이상 구매하지 않고 쇼핑 종료
        if( *pdwCurrentAddress != 0x12345678) return FALSE;

        // 1MB씩 이동하면서 확인
        pdwCurrentAddress += (0x100000 / 4);
    }
    return TRUE;
}