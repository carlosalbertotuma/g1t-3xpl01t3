# CVE GitHub Exploits Finder

## Descrição

O **CVE GitHub Exploits Finder** é uma ferramenta destinada a profissionais de segurança, entusiastas de hacking e equipes de Red Team. O script automatiza a busca de informações relacionadas a CVEs (Common Vulnerabilities and Exposures) e explora o GitHub para encontrar repositórios relacionados a exploits, PoCs (Proof of Concept) e vulnerabilidades. 

Esta ferramenta pode ser usada para:

- Localizar CVEs associadas a palavras-chave específicas.
- Buscar por repositórios no GitHub que contenham informações sobre exploits, PoCs e vulnerabilidades associadas a essas CVEs.
- Obter escores EPS e percentis das CVEs para avaliar a gravidade e o impacto potencial.

## Aviso Legal

Este script é fornecido "como está" e é destinado apenas para fins educacionais e de pesquisa. O uso inadequado desta ferramenta para atividades maliciosas é estritamente proibido. Qualquer uso da ferramenta para atividades ilegais é de inteira responsabilidade do usuário.

## Requisitos

- `curl`: Para realizar requisições HTTP.
- `jq`: Para processar e manipular dados JSON.
- `grep`: Para filtrar textos.
- `awk`: Para formatar a saída.
- `sort` e `uniq`: Para manipulação e organização de dados.

## Como Usar

### Passo 1: Preparação

Certifique-se de ter as dependências necessárias instaladas:

```bash
sudo apt-get install curl jq grep awk

### ScreeShot

![image](https://github.com/user-attachments/assets/0da16705-4d47-4be6-be8b-820667651870)


![image](https://github.com/user-attachments/assets/a467b9a2-7404-49a9-8534-7ff8457e6a3d)

![image](https://github.com/user-attachments/assets/b25c8149-9fd4-4006-9158-772701d7c509)

