#!/bin/bash

banner()
{

echo -e "\e[1;34m"
echo '          d888  888                                 d888           '
echo '         d8888  888                                d8888           '
echo '           888  888                                  888           '
echo ' .d88b.    888  888888                 888  888      888           '
echo 'd88P"88b   888  888                    888  888      888           '
echo '888  888   888  888                    Y88  88P      888           '
echo 'Y88b 888   888  Y88b.                   Y8bd8P d8b   888           '
echo ' "Y88888 8888888 "Y888                   Y88P  Y8P 8888888          '
echo '     888                                                            '
echo 'Y8b d88P                                                            '
echo ' "Y88P"                                                             '
echo ' .d8888b.                    888  .d8888b.   d888  888    .d8888b.  '
echo 'd88P  Y88b                   888 d88P  Y88b d8888  888   d88P  Y88b '
echo '     .d88P                   888 888    888   888  888        .d88P '
echo '    8888"  888  888 88888b.  888 888    888   888  888888    8888"  '
echo '     "Y8b.  Y8bd8P  888 "88b 888 888    888   888  888        "Y8b. '
echo '888    888   X88K   888  888 888 888    888   888  888   888    888 '
echo 'Y88b  d88P .d8""8b. 888 d88P 888 Y88b  d88P   888  Y88b. Y88b  d88P '
echo ' "Y8888P"  888  888 88888P"  888  "Y8888P"  8888888 "Y888 "Y8888P"  '
echo '                    888                                             '
echo '                    888                                             '
echo '                    888                                             '
echo -e "\e[0m"
echo -e "\e[1;31mBy Carlos Tuma - bl4dsc4n\e[0m"
echo ""
}

banner


if [ "$#" -ne 1 ]; then
  echo "Uso: $0 <palavra-chave>"
  exit 1
fi

keyword=$(echo "$1" | tr '[:upper:]' '[:lower:]')

filter_terms=("cve" "exploit" "poc" "vulnerability" "rce" "lfi" "rfi" "xss" "sqli" "zero-day" "payload")

fetch_repos() {
  local query="$1"
  local search_query="$query+$keyword"
  local response=$(curl -s "https://api.github.com/search/repositories?q=$search_query")

  # Verifica se a resposta é nula ou não contém itens
  if [ "$(echo "$response" | jq -r '.items // empty')" == "" ]; then
    echo -e "\e[1;32mNenhum resultado para: $search_query\e[0m"
    return
  fi

  # Extrai URLs e descrições dos repositórios
  echo "$response" | jq -r '
    .items[] | 
    {
      url: .html_url,
      description: (.description // "")
    } | 
    "\(.url) \(.description)"
  '
}

all_repos=""

for term in "${filter_terms[@]}"; do
  echo -e "\e[1;32mPesquisando por: $term+$keyword\e[0m"
  all_repos+=$(fetch_repos "$term")
done

echo "$all_repos" | grep -i -E "$(IFS=\|; echo "${filter_terms[*]}")" | awk '{print $1}' | sort -u
