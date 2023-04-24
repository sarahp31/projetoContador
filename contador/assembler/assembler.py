import utils

assembly = 'DOIT.txt' #Arquivo de entrada de contem o assembly
destinoBIN = 'BIN.txt' #Arquivo de saída que contem o binário formatado para VHDL

with open(assembly, "r") as f: #Abre o arquivo ASM
    lines = f.readlines() #Verifica a quantidade de linhas

with open(destinoBIN, "w") as f:  #Abre o destino BIN

    cont = 0 #Cria uma variável para contagem
    par_label_linha = utils.procuraLabels(lines)
    
    for line in lines:
        # print(line)
    
        # #Verifica se a linha começa com alguns caracteres invalidos ('\n' ou ' ' ou '#')
        # if (line.startswith('\n') or line.startswith(' ') or line.startswith('#')):
        #     line = line.replace("\n", "")
        #     # print("-- Sintaxe invalida" + ' na Linha: ' + ' --> (' + line + ')') #Print apenas para debug
        
        # #Se a linha for válida para conversão, executa
        if line.startswith('#'):
            f.write('--' + line)
        if not(line.startswith('\n') or line.startswith(' ') or line.startswith('#')):
            if ':' in line:
                nome_label = line.split(':')[0]
                line = 'NOP' + ' #' + nome_label
            
            #Exemplo de linha => 1. JSR @14 #comentario1
            comentarioLine = utils.defineComentario(line).replace("\n","") #Define o comentário da linha. Ex: #comentario1
            instrucaoLine = utils.defineInstrucao(line).replace("\n","") #Define a instrução. Ex: JSR @14
            
            instrucaoLine = utils.trataMnemonico(instrucaoLine) #Trata o mnemonico. Ex(JSR @14): x"9" @14

            if '@' in instrucaoLine: #Se encontrar o caractere arroba '@' 
                instrucaoLine = utils.converteArroba(instrucaoLine, par_label_linha) #converte o número após o caractere Ex(JSR @14): x"9" x"0E"
                    
            elif '$' in instrucaoLine: #Se encontrar o caractere cifrao '$' 
                instrucaoLine = utils.converteCifrao(instrucaoLine) #converte o número após o caractere Ex(LDI $5): x"4" x"05"
            
            else: #Senão, se a instrução nao possuir nenhum imediator, ou seja, nao conter '@' ou '$'
                instrucaoLine = instrucaoLine.replace("\n", "") #Remove a quebra de linha
                instrucaoLine = instrucaoLine + '0'*9 #Acrescenta o valor x"00". Ex(RET): x"A" x"00"
                
            vhdl_line = utils.formatToVHDL(cont, instrucaoLine, comentarioLine)
                                        
            cont+=1 #Incrementa a variável de contagem, utilizada para incrementar as posições de memória no VHDL
            f.write(vhdl_line) #Escreve no arquivo BIN.txt
            
            # print(vhdl_line,end = '') #Print apenas para debug

