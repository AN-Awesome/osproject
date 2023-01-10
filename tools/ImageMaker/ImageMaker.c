#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/uio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>

#define BYTESOFSECTOR 512

int AdjustInSectorSize(int iFd, int iSourceSize);
void WriteKernelInformation(int iTargetFd, int iKernelSectorCout);
int CopyFile(int iSourceFd, int iTargetFd);

int main(int argc, char* argv[]) {
	int iSourceFd;
	int iTargetFd;
	int iBootLoaderSize;
	int iKernelSectorCount;
	int iSourceSize;

	// CHECK PARAM_ARGUMENTS
	if(argc < 3) {
		fprintf(stderr, "[ERROR] ImageMaker BootLoader.bin kernel32.bin Kernel64.bin\n");
		exit(-1);
	}

	// Create Disk Image File(Disk.img)
	if((iTargetFd = open("Disk.img", O_RDWR | O_CREAT | O_TRUNC | S_IREAD | S_IWRITE)) == -1) {
		fprintf(stderr, "[ERROR] Disk.img open fail.\n");
		exit(-1);
	}

	// Processing Boot Loader(16 Bit REAL MODE) _ COPY TO DISK IMAGE FILE
	printf("[INFO] Copy boot loader to image file\n");
	if((iSourceFd = open (argv[ 1 ], O_RDONLY)) == -1) {
		fprintf(stderr, "[ERROR] %s open fail\n", argv[1]);
		exit(-1);
	}

	iSourceSize = CopyFile(iSourceFd, iTargetFd);
	close(iSourceFd);

	// Fill the rest with 0x00 to match the file size to the sector size of 512 bytes
	iBootLoaderSize = AdjustInSectorSize(iTargetFd, iSourceSize);
	printf("[INFO] %s size = [%d] and sector count = [%d]\n", argv[ 1 ], iSourceSize, iBootLoaderSize);

	// Processing 32 Bit Protected Mode Kernel _ COPY TO DISK IMAGE FILE
	printf("[INFO] Copy protected mode kernel to image file\n");
	if((iSourceFd = open( argv[ 2 ], O_RDONLY)) == -1) {
		fprintf(stderr, "[ERROR] %s open fail\n", argv[2]);
		exit(-1);
	}

	iSourceSize = CopyFile(iSourceFd, iTargetFd);
	close(iSourceFd);

	// Fill the rest with 0x00 to match the file size to the sector size of 512 bytes
	iKernelSectorCount = AdjustInSectorSize(iTargetFd, iSourceSize);
	printf("[INFO] %s size = [%d] and sector count = [%d]\n", argv[2], iSourceSize, iKernelSectorCount);

	// Update kernel information in disk image
	printf("[INFO] Start to write kernel infomation\n");
	// Information about the kernel is put in from the 5th byte of the boot sector.
	WriteKernelInformation(iTargetFd, iKernelSectorCount);
	printf("[INFO] Image file create complete\n");

	close(iTargetFd);
	return 0;
}
// Fill with 0x00 from the current position to the multiple of 512 bytes
int AdjustInSectorSize(int iFd, int iSourceSize) {
	int i;
	int iAdjustSizeToSector;
	char cCh;
	int iSectorCount;

	iAdjustSizeToSector = iSourceSize % BYTESOFSECTOR;
	cCh = 0x00;

	if(iAdjustSizeToSector != 0) {
		iAdjustSizeToSector = 512 - iAdjustSizeToSector;
		printf("[INFO] File size [%lu] and fill [%u] byte\n", iSourceSize, iAdjustSizeToSector);
		for(i = 0; i < iAdjustSizeToSector; i++) write(iFd, &cCh, 1);
	} else printf("[INFO] File size is aligned 512 byte\n");

	// Restore the number of sectors.
	iSectorCount = (iSourceSize + iAdjustSizeToSector) / BYTESOFSECTOR;
	return iSectorCount;
}

// Inject information about the kernel into the bootloader
void WriteKernelInformation(int iTargetFd, int iKernelSectorCount) {
	unsigned short usData;
	long lPosition;

	// The location 5 bytes away from the start of the file indicates the total number of sectors in the kernel.
	lPosition = lseek(iTargetFd, (off_t)5, SEEK_SET);
	if( lPosition == -1) {
		fprintf(stderr, "lseek fail. Return value = %d, errno = %d, %d\n", lPosition, errno, SEEK_SET);
		exit( -1 );
	}

	usData = (unsigned short) iKernelSectorCount;
	write(iTargetFd, &usData, 2);

	printf("[INFO] Total sector count of execpt boot loader [%d]\n", iKernelSectorCount);
}


// Copies the contents of the source file (Source FD) to the target file (Target FD) and returns the size.
int CopyFile(int iSourceFd, int iTargetFd) {
	int iSourceFileSize;
	int iRead;
	int iWrite;
	char vcBuffer[ BYTESOFSECTOR ];

	iSourceFileSize = 0;
	while(1) {
		iRead = read(iSourceFd, vcBuffer, sizeof(vcBuffer));
		iWrite = write(iTargetFd, vcBuffer, iRead);

		if(iRead != iWrite) {
			fprintf(stderr, "[ERROR] iRead != iWrite... \n");
			exit(-1);
		}
		iSourceFileSize += iRead;

		if(iRead != sizeof(vcBuffer)) break;
	}
	return iSourceFileSize;
}