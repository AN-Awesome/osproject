#ifndef __TYPES_H__                 //코드 맨 아랫줄에 #enif로 끝나야 한다.
#define __TYPES_H__

#define BYTE unsigned char          //변수랑 같아 전처리기로 정의가 되는 것. 
#define WORD unsigned short         //unsigned 는 자릿수가 길다. 따라서 재 정의를 하는 것.
#define DWORD unsigned int
#define QWORD unsigned long
#define BOOL unsigned char

#define TRUE 1                      //위와 마찬가지로 상수 정의를 해준 것.
#define FALSE 0
#define NULL 0

#pragma pack(push, 1)               //push                                             
typedef struct kCharactorStruct {   //구조체 시작. typedef = 우리가 타입을 임의로 정의. 비디오 모드 중 텍스트 모드 화면을 구성하는 자료구조.
    BYTE bCharactor;                
    BYTE bAttribute;
}CHARACTER;                         //CHARACTER는 kCHARACOTRSTRUCT의 대명사라고 생각. 이유는? 대명사로 이름을 짧게 만들기 위해서.
#pragma pop                         //pop

#endif                              //중복정의를 피하기 위한 메크로