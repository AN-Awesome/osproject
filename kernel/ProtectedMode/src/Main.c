#include "Types.h"                                              //헤더파일 불러오기

void Main(void) {
    kPrintString(0, 3, "Test string...");
    while(1);
}

void kPrintString( int iX, int iY, const char* pcString) {      //예제 함수를 통한 정식 함수 정의
    CHARACTER* pstScreen = (CHARACTER*) 0xB8000;                //Types.h파일의 함수를 호출한 것이다. C에서는 참조변수의 역학을 구현할 수 없어 포인터로 접근한 것이다.
    int i;

    pstScreen += (iY * 80) + iX;                                //가로 : 80 
    for(i = 0; pcString[i] != 0; i++) pstScreen[i].bCharactor = pcString[i];                  //Types.h파일의 함수안의 bCharactor를 가르킨다.
}