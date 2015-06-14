#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/syscall.h>

extern int readFile(char *buffer, int n, int fileDescriptor);
extern void *mymalloc(size_t);
extern void myfree(void *);
int useMips(char* fileName);

int main(int argc, char** argv) {

	if (argc < 2) { //no tengo archivo de entrada, uso standard input
		printf("%s \n","falta archivo a imprimir");
	    return (EXIT_SUCCESS);
	}

	printf("abro archivo %s \n",argv[1]);
	return useMips(argv[1]);
}


int useMips(char* fileName){
	int bufIncrSize = 10;
	FILE *fp;
	fp = fopen(fileName, "r");
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
    
    printf("buff incr size: %d \n",bufIncrSize);

    readFile(buffer, bufIncrSize, fileDescriptor);
    printf("%s",buffer);
//    while (readFile(buffer, bufIncrSize, fileDescriptor)) {
//    	printf("\n %s \n","imprimo linea");
//		printf("%s",buffer);
//    }
    
    /*
    int result = readFile(buffer, bufIncrSize, fileDescriptor);
    printf("result: %d \n",result);
    printf("%s \n",buffer);
    */
    
    myfree(buffer);
    fclose(fp);
  	return (EXIT_SUCCESS);
}

