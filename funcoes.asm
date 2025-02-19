section .data
prompt_msg1 db 'Endereco Inicial: '
prompt_msg1_size EQU $-prompt_msg1
prompt_msg2 db ', Endereco Final: '
prompt_msg2_size EQU $-prompt_msg2
prompt_msg3 db 'Nao ha espaco suficiente para alocar programa.'
prompt_msg3_size EQU $-prompt_msg3
newline db 0ah 


section .bss
i_var resd 1                    ; 4bytes int
; 12 bytes para string, inteiro de tamanho 10, onde o espaco 11 é o '0'
;e o primeiro espaço [0] ira conter o ponteiro para o inicio da string
string_buffer resb 12           

; Define variáveis locais
%define prog_size dword [ebp - 4]   
%define mem_arr dword [ebp - 8]
%define mem_arr_size dword [ebp - 12]
%define allocation_arr dword [ebp - 16]



section .text
checar_memoria_disponivel:
    enter 20, 0              ; aloca espaço para 5 variáveis locais

    ; Carrega os argumentos da função
    mov eax, [ebp + 8]      ; prog_size
    mov ebx, [ebp + 12]     ; array pointer
    mov ecx, [ebp + 16]     ; array size
    mov edx, [ebp + 20]     ; Result array pointer (allocation_arr)


    ; Inicializa variáveis locais
    mov prog_size, eax
    mov mem_arr, ebx
    mov mem_arr_size, ecx
    mov allocation_arr, edx
    %define total_free_space [ebp - 20]
    

    ; Inicialização de variáveis
    mov dword [i_var], 0
    ;mov eax, prog_size
    ;mov dword [to_allocate], eax
    mov dword total_free_space, 0

    ; Loop para processar o array
    mov ecx, mem_arr
    loop_check:
        mov eax, [i_var]
        shl eax, 1                  ; eax = i * 2 (colum_size)

        ; Carrega o endereço e o espaço livre
        mov edx, [ecx + eax * 4]    ; edx = array[i * 2] (endereço)
        mov ebx, [ecx + eax * 4 + 4] ; ebx = array[i * 2 + 1] (espaço livre)

        ; verifica se o espaço livre eh grande o suficiente para comportoar o programa
        cmp ebx, prog_size
        jae found_single_fit            ;se espaço livre >= prog_size, pula

        ;soma ao total de espaço livre
        add dword total_free_space, ebx
       
       
        ; Incrementa o índice
        inc dword [i_var]           ; i++
        mov eax, mem_arr_size
        cmp dword [i_var], eax
        jb loop_check                   ; pula se i < mem_arr_size

    loop_check_fim:
    ; verifica se o total de espaço livre eh suficiente
    mov eax, total_free_space
    cmp eax, prog_size
    jb insufficient_space           ; se total espaço < prog_size, retorna -1
    
    ; se total espaço é suficiente e nenhum espaço sozinho é suficiente, retorn 0
    mov eax, 1
    jmp fim_checar_memoria_disponivel

    found_single_fit:
        mov eax, allocation_arr
        mov [eax], edx                              ; sufficient_pair[0] = endereço inicial
        mov ebx, prog_size                          ; ebx = prog_size (prog_size aqui sempre eh menor ou igual a free_space)        
        add ebx, [eax]                              ; ebx = endereco incial + ebx
        sub ebx, 1                                  ; ebx = endereco inicial + ebx - 1 (offset)
        mov [eax + 4], ebx                          ; sufficinet_pair[1] = endereco final
        mov eax, 0                            ; retorno eax = 0
        jmp fim_checar_memoria_disponivel
    insufficient_space:
        mov eax, -1         ;retorna -1 em eax

fim_checar_memoria_disponivel:

    leave
    ret 16





global carregar_na_memoria
carregar_na_memoria:
    enter 24, 0              ; salva esp e ebp e aloca 6 espaços para varaivel

    ; salva registradores
    push ebx
    push ecx
    push edx
    push esi

    ; carrega os argumentos da função
    mov eax, [ebp + 8]      ; prog_size
    mov ebx, [ebp + 12]     ; array pointer
    mov ecx, [ebp + 16]     ; array size
    mov edx, [ebp + 20]     ; result array pointer (allocation_arr)

    ; definição variáveis locais
    mov prog_size, eax
    mov mem_arr, ebx
    mov mem_arr_size, ecx
    mov allocation_arr, edx

    push edx                ;result array pointer (allocation_arr)
    push ecx                ;array size
    push ebx                ;array pointer
    push eax                ;prog_size
    call checar_memoria_disponivel
    ;RETURN IN EAX

     ; verifica o retorno da funcção
    cmp eax, -1
    je fim                  ;se retornou -1, espaco fornecido insuficiente
    cmp eax, 0
    je fim_par                 ;retornou 0, usar sufficient_pair array (end_address,free_space)
    
    ;Se retronou 1, entao o programa cabe nos endereços fornecido, mas não apenas em uma
    ;continua a execução desta função


    ; inicialização de variáveis
    %define allocation_arr_size [ebp - 20]
    %define to_allocate [ebp - 24]
    mov dword [i_var], 0
    mov dword allocation_arr_size, 0
    mov eax, prog_size
    mov dword to_allocate, eax

    ; Ponteiro para o array de resultados
    mov esi, allocation_arr

    ; loop para processar o array
    mov ecx, mem_arr
    loop_i:
        mov eax, [i_var]            ; eax = i
        shl eax, 1                  ; eax = i * 2 (colum_size)

        ; Carrega o endereço e o espaço livre
        mov edx, [ecx + eax * 4]    ; edx = array[i * 2] (endereço)
        mov ebx, [ecx + eax * 4 + 4] ; ebx = array[i * 2 + 1] (espaço livre)

        ; Verifica se to_allocate <= 0
        cmp dword to_allocate, 0
        jle loop_i_fim              ; sai do loop se to_allocate <= 0

        ; Compara to_allocate com o espaço livre
        cmp to_allocate, ebx
        jae if_greater
        ; Se to_allocate < espaço livre
        mov eax, to_allocate       ; eax = to_allocate
        sub dword to_allocate, ebx ; to_allocate -= espaço livre
        jmp store_allocated
        if_greater:
        ; Se to_allocate >= espaço livre
        mov eax, ebx                ; eax = espaço livre
        sub dword to_allocate, ebx ; to_allocate -= espaço livre
        store_allocated:
        ; Armazena o endereço e o espaço alocado no array de resultados
        mov [esi], edx              ; allocated_arr[0] = endereço incial
        add eax, edx                ; eax = espaco alocado + endereco incial
        sub eax, 1                 ; eax = espaco alocado + endereco incial - 1(offset)
        mov [esi + 4], eax          ; allocated_arr[1] = espaço alocado
        add esi, 8                  ; avança para a próxima posição
        add dword allocation_arr_size, 1 ;size do arr de result +=1

        ; Incrementa o índice
        inc dword [i_var]           ; i++
        mov eax, mem_arr_size
        cmp dword [i_var], eax
        jb loop_i                   ; pula se i < mem_arr_size

    loop_i_fim:
    ; preenche o valor de eax como sendo 1, ou seja, o programa foi alocado em diferentes partes de memoria
    ; o array allocated_array contem os endrecos e espacos usados e o allocated_arr_size contem o temnho do array
    mov eax, 1
    mov ecx, allocation_arr_size
    jmp fim

    fim_par:
        ; configura o tamanho do array para 1
        mov ecx, 1

    fim:
    mov ebx, allocation_arr
    push ecx                    ; ecx = allocation_arr_size
    push ebx                    ; array pointer result
    push eax                    ; codigo de resultado = -1, 0 e 1
    call output_resultado

    ; Restaura registradores
    pop esi
    pop edx
    pop ecx
    pop ebx

    leave       ;restuara o estado original da pilha (esp,ebp)
    ret 16



;função para mostrar o resultado
; Input0: recebe o argumento em eax, na qual pode ser:
; -1 -> o valor -1, indicando que nao há espaço suficiente para o programa
; 0 -> indica que deve se usar o array allocation_arr, idicando que o programa coube inteiro em um espaco apenas
; 1 -> indica que deve ser usar o array allocation_arr, mostrando o espaco usado em cada endereco
; Input1: usa o valor armazenado em allocation_arr_size (indica o tamanho do array allocation_arr)
output_resultado:
    enter 8,0                           ; cria frame de pilha e aloca espaco para 2 variaveis locais
    pusha                               ; salva todos os registradores
    
    mov eax, [ebp + 8]                  ; codigo em eax
    mov ebx, [ebp + 12]                 ; ebx = pointer para array de resultado
    mov ecx, [ebp + 16]                 ; ecx = tamano do array de resultados
    
    ; Verifica se o espaco eh insuficiente
    cmp eax, -1                         ; eax == -1?
    je insufficient_output_resultado    ;se eax -1, pula para mostrar msg de espaco insuficiente

    %define allocation_arr dword [ebp - 4]   
    %define allocation_arr_size dword [ebp - 8]
    mov allocation_arr, ebx
    mov allocation_arr_size, ecx
    

    output_resultado_def:
    ;definicao variaveis locais
    mov dword [i_var], 0                ; zera o contador
    mov esi, allocation_arr             ; esi = pointer para array de resultado

    loop_output_resultado:
        mov ecx, [i_var]

        ; printa 'Endereco: '
        mov eax, prompt_msg1
        mov ebx, prompt_msg1_size
        push ebx
        push eax
        call my_printf

        mov eax, ecx
        shl eax, 1
        mov eax, [esi + eax * 4]      ; edx = array[i * 2] (endereço)
        push eax
        call int_to_string

        mov eax, string_buffer      ; primeira posicao é um ponteiro para ponteiro
        mov eax, [eax]              ;armazena o ponteiro para o inicio da string
        mov ebx, 12
        push ebx
        push eax
        call my_printf

        mov eax, prompt_msg2
        mov ebx, prompt_msg2_size
        push ebx
        push eax
        call my_printf

        mov eax, ecx
        shl eax, 1
        mov eax, [esi + eax * 4 + 4]      ; edx = array[i * 2 + 1] (endereço)
        push eax
        call int_to_string

        mov eax, string_buffer      ; primeira posicao é um ponteiro para ponteiro
        mov eax, [eax]              ;armazena o ponteiro para o inicio da string
        mov ebx, 12
        push ebx
        push eax
        call my_printf

        mov eax, newline
        mov ebx, 1
        push ebx
        push eax
        call my_printf

        ; Incrementa o índice
        inc dword [i_var]           ; i++
        mov eax, allocation_arr_size
        cmp dword [i_var], eax
        jb loop_output_resultado                   ; pula se i < mem_arr_size
    loopfim_output_resultado:
        jmp fim_output_resultado

    ; Se o espaço é insuficiente, printa mensagem e logo em seguida printa \n
    insufficient_output_resultado:
        mov eax, prompt_msg3
        mov ebx, prompt_msg3_size
        push ebx
        push eax
        call my_printf

        mov eax, newline
        mov ebx, 1
        push ebx
        push eax
        call my_printf

fim_output_resultado:
    popa
    leave
    ret 12

; Funcao que converte um inteiro para string
; Input: eax = inteiro para converter (10 digit max)
; Output: string_buffer = interger convertido
; OBS: a string eh preechinda do ultimo endereço (desconsierando o \0) para o começo.
;Dessa forma, é preciso armazenar o endereço do inicio da string. Esse ponteiro sempre é
; armazenado no primeiro endereço string_buffer[0]
int_to_string:
    enter 0,0
    pusha                        ; Salva todos os registradores
    
    mov eax, [ebp + 8]           ; eax = inteiro para converter
    mov edi, string_buffer + 11  ; edi = ponteiro para o fim da string
    mov byte [edi], 0            ;null-terminate para terminar string
    dec edi                      ; move ponteiro para o final da string
    mov ebx, 10                  ; dividor 10

convert_loop:
    xor edx, edx                 ; limpa edx
    div ebx                      ; Divide eax por 10, resultado em eax, resto em edx; eax /= ebx
    add dl, '0'                  ; converte o resto para ASCII (+'0x30')
    mov [edi], dl                ; armazena o caractere convertido
    dec edi                      ; move o ponteiro para o proxima posicao a ser preenchida
    test eax, eax                ; verifica se eax = 0
    jnz convert_loop             ; se aex != 0, continua loop

    ; ajusta ponteiro para o começo da string
    inc edi                      
    mov [string_buffer], edi     ; armzena ponteiro para string na primeira posicao do array
    
    popa                         ; restaura reg
    leave
    ret 4


;função que printa algo no stdout padrao (monitor)
;recebe dois args: 1-ponteiro para o que quer se printar, 2-tamanho da string
my_printf:
    enter 0,0
    pusha

    mov ecx, [ebp + 8]      ; ecx = ponteiro da string a ser printada
    mov edx, [ebp + 12]     ; edx = tamanho da string

    mov eax, 4              ; system call id = 4, escrever em arquivo
    mov ebx, 1              ; argumento para escrever no stdout
    int 80h

    popa
    leave
    ret 8