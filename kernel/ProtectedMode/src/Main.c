#include "Types.h"                                              //헤더파일 불러오기

void Main(void) {
    DWORD i;

    kPrintString(0, 3, "Test string...");

    //보호모드 커널 영역을 초기화
    kInitializeKernel64Area();
    kPrintString(0, 4, "IA-32e Kernel Area Initialization Complete");

    while(1);
}

void kPrintString( int iX, int iY, const char* pcString) {      //예제 함수를 통한 정식 함수 정의
    CHARACTER* pstScreen = (CHARACTER*) 0xB8000;                //Types.h파일의 함수를 호출한 것이다. C에서는 참조변수의 역학을 구현할 수 없어 포인터로 접근한 것이다.
    int i;

    pstScreen += (iY * 80) + iX;                                //가로 : 80 
    for(i = 0; pcString[i] != 0; i++) pstScreen[i].bCharactor = pcString[i];                  //Types.h파일의 함수안의 bCharactor를 가르킨다.
}

//보호모드용 커널 영역을 0으로 초기화
BOOL kInitializeKernel64Area(void){
    DWORD* pdwCurrentAddress;

    //초기화를 시작할 어드레스인 0x100000(1MB)을 설정
    pdwCurrentAddress = (DWORD*) 0x100000;
    
    //마지막 어드레스인 0x600000(6MB)까지 루프롤 돌면서 4바이트씩 0으로 채움
    while( (DWORD)pdwCurrentAddress < 0x600000 ){
        *pdwCurrentAddress = 0x00;

        // 0으로 저장한 후 다시 읽었을 때 나오지 않으면 해당 어드레스를 
        // 사용하는데 문제가 생긴 것이므로 더이상 진행하지 않고 종료
        if(*pdwCurrentAddress != 0){
            return FALSE;
        }

        // 다음 어드레스로 이동
        pdwCurrentAddress++;
    }

    return TRUE;
}