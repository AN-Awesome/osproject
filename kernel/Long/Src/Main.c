// C 언어로 작성된 커널의 엔트리 포인트 파일

#include "Types.h"

// 함수 선언
void kPrintString( int iX, int iY, const char* pcString );

/**
*   아래 함수는 C 언어 커널 시작 부분
*/

void Main( void )
{
    kPrintString( 0, 10, "IA-32e 모드 전환 성공!");
    kPrintString( 0, 11, "IA-32e C 언어 커널 작동...........[PASS]");
}

/**
*   문자열을 X, Y 위치에 출력
*/
void kPrintString( int iX, iY, const char* pcString )
{
    CHARACTER* pstScreen = ( CHARACTER* ) 0xB8000;
    int i;

    // X, Y 좌표를 이용해서 문자열을 출력할 어드레스를 계산
    pstScreen += (iY * 80 ) + iX;

    // NULL이 나올 때까지 문자열 출력
    for( i = 0; pcString[ i ] != 0 ; i++)
    {
        pstScreen[ i ].bCharactor =  pcString[ i ];
    }
}