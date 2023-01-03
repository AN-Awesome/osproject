# 빌드를 수행할 목록
all: ImageBuilder.exe

#ImageBuilder 빌드
ImageBuilder.exe: ImageBuilder.c
	gcc -o $@ $<

#소스 파일을 제외한 나머지 파일 정리
Clean:
	rm -f ImageBuilder.exe