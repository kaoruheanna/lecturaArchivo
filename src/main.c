#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/syscall.h>

//extern char *readFile(char *buffer, int n, FILE *stream);
extern int readFile(char *buffer, int n, int fileDescriptor);
extern void *mymalloc(size_t);
extern void myfree(void *);
int useMips();

int main(int argc, char** argv) {
	return useMips();
}


int useMips(){
	int bufIncrSize = 1;
	FILE *fp;
	fp = fopen("test-files/null.txt", "r");
	if (fp == NULL) {
        fprintf(stderr, ": nombre de archivo o comando inválido.\n");
        return (EXIT_FAILURE);
    }
    
    int fileDescriptor = fileno(fp);
    if (!fileDescriptor) {
        fprintf(stderr, ": no se pudo obtener el file descriptor \n");
        return (EXIT_FAILURE);
    }
        
    char *buffer = (char*) mymalloc(bufIncrSize);
    int i;
    for (i = 0; i < (bufIncrSize - 1); i++){
    	buffer[i] = 'a';
    }
    buffer[bufIncrSize - 1] = 0;
    
    while (readFile(buffer, bufIncrSize, fileDescriptor)) {
		printf("%s",buffer);
    }
    
    /*
    int result = readFile(buffer, bufIncrSize, fileDescriptor);
    printf("result: %d \n",result);
    printf("%s \n",buffer);
    */
    
    myfree(buffer);
    fclose(fp);
  	return (EXIT_SUCCESS);
}

