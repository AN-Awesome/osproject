char* SCREEN = (char*) 0xB8000;

for (int i = 0; i < 80 * 25 * 2; +=2) {
    SCREEN[i] = 0;
    SCREEN[i+1] = 0x0F;
}