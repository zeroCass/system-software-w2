#include <stdlib.h>
#include <stdio.h>


extern void carregar_na_memoria(int, int*, int, int*);

// eh assumido que o programa recebera SEMPRE args valido pela linha de comando
int main (int argc, char *argv[]) {
    // desncessario pois se assume que o usuario sabe usar o programa
    if (argc < 4 || argc > 10) {
        printf("Error: numero invalido de argumentos. {%d}\n", argc);
        return -1;
    }

    int prog_size = atoi(argv[1]);
    int arr_mem_size = argc - 2;
    int arr_mem[arr_mem_size];
    int j = 0;
    for (int i = 0; i < arr_mem_size; i++) {
        arr_mem[i] = atoi(argv[i + 2]);
    }
    arr_mem_size /= 2; // o array sera interpretado como 2d com duas colunas sempre

    int allocation_arr[8] = {0}; // declaracao do array de resultados
    carregar_na_memoria(prog_size, arr_mem, arr_mem_size, allocation_arr);

    return 0;
}
