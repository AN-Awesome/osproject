# 빌드를 수행할 목록
all: imgbuild_

#ImageBuilder 빌드
imgbuild_: ./ImageBuilder/ImageBuilder.c
	gcc -o $@ $<

#소스 파일을 제외한 나머지 파일 정리
clean:
	rm -f ImageBuilder.exe