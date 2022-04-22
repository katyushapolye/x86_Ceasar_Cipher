global _start

section .data
 intro dw "Insira o texto abaixo{Max 512bytes}(ou no lado, se vc tiver no editor online, insira antes de começar o programa) para fazer um cifra de cesar com k=2",0x0a
 len equ $-intro
section .bss
 string resb  512
 buffer resb 1

section .text

_start:
    push intro
    push len
    call print
    
    mov esi,0x00 ;setando um contador para zero, nem sei se pode usar esse registro pra isso

    leitura:   
         mov  edx, 0x01             
         mov  ecx, buffer       
         mov  ebx, 0x00             
         mov  eax, 0x03             
         int  0x80
         mov ecx,[buffer]

         cmp  eax, 0x00             ; encerrar, pois chegou em char nulo
         jle  cifraCesar
         
         mov [string+esi],ecx ;colocando byte a byte na string + o contador
         inc esi
       

         jmp leitura              ; voltar, pois ha mais coisa em stdin





    cifraCesar:   ;x86_32 n tem funcoes, e pegar ou largar 
    mov eax,string
    cmp [string],byte 0x00
    je exit
    mov ecx,esi
    mov ebx,esi
    
    loop: ;esta lopando do final da string até o começo, cuidar dos casos especiais, como espaços e y e z
        dec ecx ;decremento em 1 no contador

        ;checa se é um espaço
        cmp [eax+ecx],byte 0x20
        je enditeration_clear ;caso seja, ir pro final dessa iteração, sem adicionar nada
        
        ;edge cases //y e z, eu n faço a minima ideia de como usar or e and com as flags, ent vou só forçar todas as comparações msm (isso incluiria empurrar e tirar do stack elas)
        cmp[eax+ecx],byte 0x79
        jb enditeration ;caso n seja os casos, ir para o fim tranquilamente
        cmp[eax+ecx],byte 0x59
        jb enditeration
        sub [eax+ecx],byte 0x1a
   
	
        	
    	enditeration:
        add [eax+ecx],byte 0x2 ;adiciona 2 ao index string+contador
        enditeration_clear:
        cmp ecx,0x00 ;checa se o contador é igual a zero
        jne loop ;volta a label loop se n for igual

    ;chamada da funcao de print
	push eax
	push ebx
	call print ;empurra no stack endereço de retorno (proxima linha)
	jmp exit

print: ;recebe 2 parametros que tão embaixo no stack (print(len,msg))
	push ebp ;empurra o valor do registro base no stack (abaixo é o endereço de ret)
	mov ebp, esp ;agora a base é o ponteiro do stack, aonde a função começa
	;argumentos são passados em baixo de ret, pois eles são empurrados antes, e como
	;ha o prolog, compensar com +8 (4bit de ebp + 4bit do endereço)
	mov ecx,[esp+0x0c] ;argumento mais baixo
	mov edx,[esp+0x08]  ;argumento acima do mais baixo
	mov eax,0x04  ;chamada padrão da funcao kernel de escrever
	mov ebx,0x01 ;escrever para stdin
	int 0x80 ;system call
	mov esp,ebp ;o valor volta ao inicial, aonde ela foi chamada, logo, tudo que estava acima delet
	pop ebp ;coloca o valor de volta ao ebp
	ret ;estoura o proximo valor (o endereço) e retorna de onde ele veio

exit:      ;Função para sair com sucesso
	mov eax, 0x01		
	mov ebx, 0x00		
	int		0x80
	
force_exit:              ;Função para abortar execução com error
	mov eax ,0x01
	mov ebx ,0x01
	int 0x80