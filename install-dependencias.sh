#!/bin/bash
set -e

echo "Atualizando repositórios..."
sudo apt update -y

echo "Instalando dependências necessárias..."

# Ferramentas básicas
sudo apt install -y curl jq bsdextrautils

# (Opcional) Se quiser suporte a cores e column
sudo apt install -y moreutils

echo ""
echo "✔ Dependências instaladas com sucesso!"
echo ""
echo "Testando versões instaladas:"
echo -n "curl versão: "; curl --version | head -n1
echo -n "jq versão: "; jq --version
echo -n "column: ";      which column
echo ""
echo "Você pode agora executar o script g1t-3xpl01t3.sh normalmente."
