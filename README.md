# G1t-3xpl01t v. 2.0
![image](https://github.com/user-attachments/assets/2278bba2-6d53-4ee5-952e-7793e4f76fcc)
## Descrição

O **G1t-3xpl01t** é uma ferramenta destinada a profissionais de segurança, entusiastas de hacking e equipes de Red Team. O script automatiza a busca de informações relacionadas a CVEs (Common Vulnerabilities and Exposures) e explora o GitHub para encontrar repositórios relacionados a exploits, PoCs (Proof of Concept) e vulnerabilidades. 

Esta ferramenta pode ser usada para:

- Localizar CVEs associadas a palavras-chave específicas.
- Buscar por repositórios no GitHub que contenham informações sobre exploits, PoCs e vulnerabilidades associadas a essas CVEs.
- Obter escores EPS e percentis das CVEs para avaliar a gravidade e o impacto potencial.
- utiliza sleep para contornar os limites de pesquisa do github sem utilização de API.
- Quebra a pesquisa de CVEs ao pesquisar scores no EPS, bypassando o limite de pesquisa de 100 por vez.

## Aviso Legal

Este script é fornecido "como está" e é destinado apenas para fins educacionais e de pesquisa. O uso inadequado desta ferramenta para atividades maliciosas é estritamente proibido. Qualquer uso da ferramenta para atividades ilegais é de inteira responsabilidade do usuário.

## Requisitos

- `curl`: Para realizar requisições HTTP.
- `jq`: Para processar e manipular dados JSON.
- `grep`: Para filtrar textos.
- `awk`: Para formatar a saída.
- `sort` e `uniq`: Para manipulação e organização de dados.

### ScreeShot ####



![image](https://github.com/user-attachments/assets/77f7f6ec-cc42-4100-a100-316f1be562d3)

![image](https://github.com/user-attachments/assets/a05ff485-c83a-4da3-8fec-f219885fe7b7)

![image](https://github.com/user-attachments/assets/41882b8b-038d-4f56-b54f-a5ed3e75585a)

![image](https://github.com/user-attachments/assets/5b7f5d2e-dfd5-47e5-94c9-bd642456fdbd)

![image](https://github.com/user-attachments/assets/50df860a-da24-4572-ba7a-d86402199d27)

![image](https://github.com/user-attachments/assets/b6cc75d1-b0bb-4f37-b440-8bd237808486)


![image](https://github.com/user-attachments/assets/b25c8149-9fd4-4006-9158-772701d7c509)


## Como Usar

chmod +x G1t-3xpl01t.sh

./G1t-3xpl01t.sh -a confluence

Ps. Caso a pesquisa, utilize palavra composta. utilize o "%20" para espaço 

Ex: ./G1t-3xpl01t.sh -a Microsoft%20Outlook

### Passo 1: Preparação

Certifique-se de ter as dependências necessárias instaladas:

sudo apt-get install curl jq grep awk


### Desenvolvedor

By Carlos Tuma - bl4dsc4n
