# Software Básico - Trabalho 2

O objetivo deste trabalho é construir um emulador de um carregador usando Assembly Intel x86.
A especificação pode ser encontrada em `/docs`.

## Requisitos para rodar o programa

- Ter o **nasm** instalado.
- Possuir as bibliotecas do GCC em 32 bits:
  ```sh
  sudo apt install gcc-multilib g++-multilib
  ```
- O programa deve ser executado exclusivamente no Linux.
  - **OBS:** O programa foi desenvolvido utilizando **Ubuntu 24.04.1 LTS** no **WSL 2.0**.

## Como rodar

1. Compile o arquivo de funções Assembly:
   ```sh
   nasm -f elf32 funcoes.asm -o funcoes.o
   ```
2. Compile o programa principal com o GCC:
   ```sh
   gcc -m32 -o carregador.out carregador.c funcoes.o
   ```
3. Execute o programa com os argumentos necessários:
   ```sh
   ./carregador.out [prog_size] [end0] [end0_freespace]
   ```
   
   **OBS:** O programa aceita entre **3 a 9 argumentos numéricos**, exatamente na seguinte ordem:
   
   | Índice | Argumento | Exemplo |
   |---------|-----------|----------|
   | 0       | Tamanho do programa a ser carregado | `1000` |
   | 1       | Endereço 0 | `300` |
   | 2       | Espaço livre no endereço 0 | `500` |
   | ...     | ... | ... |
   | 7       | Endereço 3 | `1200` |
   | 8       | Espaço livre no endereço 3 | `5000` |

## Exemplos

### Inputs:

1. ```sh
   ./carregador.out 1250 300 460 1000 500 800 500
   ```
2. ```sh
   ./carregador.out 1000 300 100 1000 2500 800 500
   ```
3. ```sh
   ./carregador.out 10000 300 100 1000 2500 800 500 1200 5000
   ```

### Outputs esperados:

1. ```
   Endereco Inicial: 300, Endereco Final: 759
   Endereco Inicial: 1000, Endereco Final: 1499
   Endereco Inicial: 800, Endereco Final: 1089
   ```
2. ```
   Endereco Inicial: 1000, Endereco Final: 1999
   ```
3. ```
   Nao ha espaco suficiente para alocar programa.
   ```

