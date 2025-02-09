 #!/bin/bash

# Definir cores
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"
magenta="\033[0;35m"
cyan="\033[0;36m"
red="\033[0;31m"
reset="\033[0m"



banner(){

                                                                                                
echo ' @@@@@@@@    @@@  @@@@@@@     @@@@@@@@  @@@  @@@  @@@@@@@   @@@        @@@@@@     @@@  @@@@@@@  '
echo '@@@@@@@@@   @@@@  @@@@@@@     @@@@@@@@  @@@  @@@  @@@@@@@@  @@@       @@@@@@@@   @@@@  @@@@@@@  '
echo '!@@        @@@!!    @@!       @@!       @@!  !@@  @@!  @@@  @@!       @@!  @@@  @@@!!    @@!    '
echo '!@!          !@!    !@!       !@!       !@!  @!!  !@!  @!@  !@!       !@!  @!@    !@!    !@!    '
echo '!@! @!@!@    @!@    @!!       @!!!:!     !@@!@!   @!@@!@!   @!!       @!@  !@!    @!@    @!!    '
echo '!!! !!@!!    !@!    !!!       !!!!!:      @!!!    !!@!!!    !!!       !@!  !!!    !@!    !!!    '
echo ':!!   !!:    !!:    !!:       !!:        !: :!!   !!:       !!:       !!:  !!!    !!:    !!:    '
echo ':!:   !::    :!:    :!:       :!:       :!:  !:!  :!:        :!:      :!:  !:!    :!:    :!:    '
echo ' ::: ::::    :::     ::        :: ::::   ::  :::   ::        :: ::::  ::::: ::    :::     ::    '
echo ' :: :: :      ::     :        : :: ::    :   ::    :        : :: : :   : :  :      ::     :     '
echo 
echo '  _   _     _   _   _   _   _   _   _   _  '
echo ' / \ / \   / \ / \ / \ / \ / \ / \ / \ / \ '
echo '( b | y ) ( b | l | 4 | d | s | c | 4 | n )'
echo ' \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ '  "version 2.0"                                                                                                

}

mododeuso(){

    echo "Funções disponíveis:"
    echo -e "${yellow}-a <palavra-chave>${reset} : Buscar e comparar CVEs"
    echo -e "${yellow}-b <palavra-chave>${reset} : Buscar e processar escores EPS"
    echo -e "${yellow}-c <palavra-chave> <anos>${reset} : Buscar e filtrar CVEs por anos"
    echo -e "${yellow}-d <palavra-chave> <anos>${reset} : Buscar CVEs no GitHub"
    echo ""

}




retry_request() {
  local url="$1"
  local attempts=5
  local wait_time=10
  local attempt=0
  while [ $attempt -lt $attempts ]; do
    response=$(curl -s "$url")
    if echo "$response" | grep -q "API rate limit exceeded"; then
      echo "API rate limit exceeded. Waiting $wait_time seconds before retrying..."
      sleep $wait_time
      ((attempt++))
    else
      echo "$response"
      return
    fi
  done
  echo "Failed to get a valid response after $attempts attempts."
  exit 1
}



fetch_and_compare_cves() {
  local keyword=$1
  local cve_url="https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=${keyword}"
  local cve_file="${keyword}_cves.txt"

  echo "Buscando CVEs relacionadas à palavra-chave: $keyword"
  local response=$(retry_request "$cve_url")
  local new_cves=$(echo "$response" | jq -r '.vulnerabilities[].cve.id' | grep -o 'CVE-[0-9]\{4\}-[0-9]\+' | sort -u)
  
  if [[ -f "$cve_file" ]]; then
    echo "Arquivo $cve_file encontrado. Comparando CVEs..."
    local existing_cves=$(cat "$cve_file")
    local new_entries=$(comm -13 <(echo "$existing_cves") <(echo "$new_cves"))

    if [[ -n "$new_entries" ]]; then
      echo -e "\033[1;32mNOVAS CVEs encontradas:\033[0m"
      echo "$new_entries"
      echo "$new_cves" > "$cve_file"
      echo "CVEs atualizadas salvas em $cve_file"
    else
      echo "Nenhuma nova CVE encontrada. O arquivo está atualizado."
    fi
  else
    echo "Arquivo $cve_file não encontrado. Criando e salvando novas CVEs..."
    echo "$new_cves" > "$cve_file"
    echo "CVEs localizadas salvas em $cve_file"
  fi

  
  echo -e "\nConteúdo do arquivo $cve_file:"
}


fetch_and_process_eps() {
  local keyword=$1
  local cve_file="${keyword}_cves.txt"
  local eps_filtro=$2

  
  if [[ ! -f "$cve_file" || ! -s "$cve_file" ]]; then
    echo -e "\033[0;33mArquivo $cve_file não encontrado ou vazio\033[0m"
    fetch_and_compare_cves "$keyword"
  fi

  local cve_ids=$(cat "$cve_file" | tr '\n' ' ')
  local cve_ids_array=($cve_ids)
  local total_cves=${#cve_ids_array[@]}
  local chunk_size=100

  
  local eps_file="${keyword}_eps.txt"
  local sorted_eps_file="${keyword}_sorted_eps.txt"
  local colored_eps_file="${keyword}_colored_eps.txt"
  

  
  > "$eps_file"
  > "$sorted_eps_file"
  > "$colored_eps_file"

  
  for (( i=0; i<$total_cves; i+=chunk_size )); do
    chunk="${cve_ids_array[@]:i:chunk_size}"
    echo "Buscando scores EPS das CVEs..." 
    local eps_url="https://api.first.org/data/v1/epss?cve=$(echo "$chunk" | tr ' ' ',')"
    local response=$(retry_request "$eps_url")

    
    echo "$response" | jq -r '
      .data[] |
      [.cve, (.epss | tonumber | (. * 100 | tostring | .[0:5])), (.percentile | tonumber | (. * 100 | tostring | .[0:5])), .date] |
      @tsv' >> "$eps_file"

    
    sleep 3
  done

  
  sort -k2,2nr "$eps_file" | awk '{print $1 "\t" $2}' >> "$sorted_eps_file"

  
  awk '
  BEGIN {
    # Definir cores
    green="\033[0;32m"
    yellow="\033[0;33m"
    blue="\033[0;34m"
    magenta="\033[0;35m"
    cyan="\033[0;36m"
    red="\033[0;31m"
    reset="\033[0m"
  }
  {
    eps=$2
    # Definir cor com base no valor do EPS
    if (eps > 90) color=red   # Verde
    else if (eps >= 80) color=yellow # Amarelo
    else if (eps >= 70) color=blue # Azul
    else if (eps >= 50) color=magenta # Magenta
    else if (eps >= 30) color=cyan # Ciano
    else color=green   # Vermelho

    # Aplicar cor ao EPS e CVE
    printf "%s%-20s %s%-10s%s\n", color, $1, color, $2, reset
  }' "$sorted_eps_file" > "$colored_eps_file"
  
}



funcao_c() {
    local keyword=$1
    shift
    local years=("$@")

    
    curl -s "https://services.nvd.nist.gov/rest/json/cves/2.0?keywordSearch=${keyword}" | jq -r '
      .vulnerabilities[] |
      {
        id: .cve.id,
        description: .cve.descriptions[0].value,
        cvss_v3_base_score: (
          if .cve.metrics.cvssMetricV31 then
            .cve.metrics.cvssMetricV31[0].cvssData.baseScore // "N/A"
          elif .cve.metrics.cvssMetricV30 then
            .cve.metrics.cvssMetricV30[0].cvssData.baseScore // "N/A"
          else
            "N/A"
          end
        ),
        cvss_v3_severity: (
          if .cve.metrics.cvssMetricV31 then
            .cve.metrics.cvssMetricV31[0].cvssData.baseSeverity // "N/A"
          elif .cve.metrics.cvssMetricV30 then
            .cve.metrics.cvssMetricV30[0].cvssData.baseSeverity // "N/A"
          else
            "N/A"
          end
        ),
        cvss_v2_base_score: (
          if .cve.metrics.cvssMetricV2 then
            .cve.metrics.cvssMetricV2[0].cvssData.baseScore // "N/A"
          else
            "N/A"
          end
        ),
        cvss_v2_severity: (
          if .cve.metrics.cvssMetricV2 then
            .cve.metrics.cvssMetricV2[0].baseSeverity // "N/A"
          else
            "N/A"
          end
        ),
        cwe: (
          if .cve.weaknesses then
            .cve.weaknesses[0].description[0].value // "NVD-CWE-Other"
          else
            "NVD-CWE-Other"
          end
        ),
        year: (.cve.id | match("[0-9]{4}") | .string)
      } |
      {
        id: .id,
        description: .description,
        cvss_v3_base_score: .cvss_v3_base_score,
        cvss_v3_severity: .cvss_v3_severity,
        cvss_v2_base_score: .cvss_v2_base_score,
        cvss_v2_severity: .cvss_v2_severity,
        cwe: .cwe,
        year: .year
      }
    ' | jq -s '.' > results.json
}

filter_and_color() {
    local years=("$@")

    if [ ${#years[@]} -eq 0 ]; then
        
        cat results.json | jq -r '
          .[] | {
            id: .id,
            description: .description,
            cvss_v3_base_score: .cvss_v3_base_score,
            cvss_v3_severity: .cvss_v3_severity,
            cvss_v2_base_score: .cvss_v2_base_score,
            cvss_v2_severity: .cvss_v2_severity,
            cwe: .cwe
          } |
          "\(.id)\nDescription: \(.description)\nCVSS v3 Base Score: \(.cvss_v3_base_score)\nCVSS v3 Severity: \(.cvss_v3_severity)\nCVSS v2 Base Score: \(.cvss_v2_base_score)\nCVSS v2 Severity: \(.cvss_v2_severity)\nCWE: \(.cwe)\n"
        ' | awk '
          BEGIN { RS="\n\n"; ORS="\n\n" }
          /^[^CVE]/ { next }
          {
            # Colorir as partes específicas
            gsub(/^(CVE-[0-9\-]+.*)$/, "\033[1;32m&\033[0m")  # Verde para toda a linha com CVE
            gsub(/Description: /, "\033[1;34mDescription: \033[0m")  # Azul para Description
            gsub(/CVSS v3 Base Score: /, "\033[1;35mCVSS v3 Base Score: \033[0m")  # Magenta para CVSS v3 Base Score
            gsub(/CVSS v3 Severity: /, "\033[1;36mCVSS v3 Severity: \033[0m")  # Ciano para CVSS v3 Severity
            gsub(/CVSS v2 Base Score: /, "\033[1;35mCVSS v2 Base Score: \033[0m")  # Magenta para CVSS v2 Base Score
            gsub(/CVSS v2 Severity: /, "\033[1;36mCVSS v2 Severity: \033[0m")  # Ciano para CVSS v2 Severity
            gsub(/CWE:/, "\033[1;33mCWE:\033[0m")  # Amarelo para CWE:
            gsub(/NVD-CWE-Other/, "\033[1;33mNVD-CWE-Other\033[0m")  # Amarelo para NVD-CWE-Other
            print
          }
        '
    else
        
        cat results.json | jq -r --argjson years "$(echo "${years[@]}" | jq -R '[split(" ")[] | select(length > 0)]')" '
          .[] | select(.year as $y | $years | index($y)) |
          {
            id: .id,
            description: .description,
            cvss_v3_base_score: .cvss_v3_base_score,
            cvss_v3_severity: .cvss_v3_severity,
            cvss_v2_base_score: .cvss_v2_base_score,
            cvss_v2_severity: .cvss_v2_severity,
            cwe: .cwe
          } |
          "\(.id)\nDescription: \(.description)\nCVSS v3 Base Score: \(.cvss_v3_base_score)\nCVSS v3 Severity: \(.cvss_v3_severity)\nCVSS v2 Base Score: \(.cvss_v2_base_score)\nCVSS v2 Severity: \(.cvss_v2_severity)\nCWE: \(.cwe)\n"
        ' | awk '
          BEGIN { RS="\n\n"; ORS="\n\n" }
          /^[^CVE]/ { next }
          {
            # Colorir as partes específicas
            gsub(/^(CVE-[0-9\-]+.*)$/, "\033[1;32m&\033[0m")  # Verde para toda a linha com CVE
            gsub(/Description: /, "\033[1;34mDescription: \033[0m")  # Azul para Description
            gsub(/CVSS v3 Base Score: /, "\033[1;35mCVSS v3 Base Score: \033[0m")  # Magenta para CVSS v3 Base Score
            gsub(/CVSS v3 Severity: /, "\033[1;36mCVSS v3 Severity: \033[0m")  # Ciano para CVSS v3 Severity
            gsub(/CVSS v2 Base Score: /, "\033[1;35mCVSS v2 Base Score: \033[0m")  # Magenta para CVSS v2 Base Score
            gsub(/CVSS v2 Severity: /, "\033[1;36mCVSS v2 Severity: \033[0m")  # Ciano para CVSS v2 Severity
            gsub(/CWE:/, "\033[1;33mCWE:\033[0m")  # Amarelo para CWE:
            gsub(/NVD-CWE-Other/, "\033[1;33mNVD-CWE-Other\033[0m")  # Amarelo para NVD-CWE-Other
            print
          }
        '
    fi
}

funcao_d() {
    local keyword=$1
    local github_results_file="${keyword}_github_results.txt"
    shift
    local years=($@)
    local cve_file="${keyword}_cves.txt"
    
    
    if [[ ! -f "$cve_file" || ! -s "$cve_file" ]]; then
        echo -e "\033[0;33mArquivo $cve_file não encontrado ou vazio\033[0m"
        fetch_and_compare_cves "$keyword"
    fi
   
    > "$github_results_file"
    
       
    if [ ${#years[@]} -eq 0 ]; then
        
        echo "Nenhum ano fornecido. Buscando todas as CVEs..."
        
        
        local cve_file="${keyword}_cves.txt"
        local cve_ids=$(cat "$cve_file")
       
        process_cves "$cve_ids" "$github_results_file"
    else
        
        echo "Anos fornecidos: ${years[@]}. Buscando CVEs desses anos..."
                
        local cve_file="${keyword}_cves.txt"
        > resultado2.txt
        for i in ${years[@]}; do cat $cve_file | grep -E $i; done >> resultado2.txt
        echo $keyword >> resultado2.txt
        local cve_ids=$(cat resultado2.txt)       
        
        process_cves "$cve_ids" "$github_results_file"
    fi

    echo -e "\nResultados da pesquisa no GitHub salvos em $github_results_file"
    echo -e "\nConteúdo do arquivo $github_results_file:"
    cat "$github_results_file" | sort -u
}

process_cves() {
    local cve_ids=$1
    local github_results_file=$2
    local filter_terms=("exploit" "poc" "pentest" "hack")
    
    
    for term in "${filter_terms[@]}"; do
        while IFS= read -r cve; do
            query="${term}+${cve}"
            echo "Pesquisando por: $query"
            local query_url="https://api.github.com/search/repositories?q=${query// /%20}"
            local response=$(retry_request "$query_url")
            
            echo "$response" | jq -r '.items[] | "\(.full_name) - \(.html_url)"' >> "$github_results_file"
            echo "Pesquisa $query - Finalizada OK"
            
            sleep 10
        done <<< "$cve_ids"
    done

    while IFS= read -r cve; do
        query="${cve}"
        echo "Pesquisando por: $query"
        local query_url="https://api.github.com/search/repositories?q=${query// /%20}"
        local response=$(retry_request "$query_url")
       
        echo "$response" | jq -r '.items[] | "\(.full_name) - \(.html_url)"' >> "$github_results_file"
        echo "Pesquisa $query - Finalizada OK"
        
        sleep 10
    done <<< "$cve_ids"
}



if [ $# -eq 0 ]; then
    banner
    mododeuso
    exit 1

elif [[ "$1" != "-a" && "$1" != "-b" && "$1" != "-c" && "$1" != "-d"  && "$1" != "-h" ]]; then
    banner
    mododeuso
    exit 1
elif [ -z "$2" ]; then
    banner
    mododeuso
    exit 1    
fi





while getopts ":a:b:c:d:h:" opt; do
  case ${opt} in
    a )
      keyword=$2
      fetch_and_compare_cves "$keyword"
      a=$(cat "${keyword}_cves.txt" | wc -l)
      echo -e "\nForam localizadas: $a CVE"
      cat "${keyword}_cves.txt" | column

      ;;
    b )
      keyword=$2
      fetch_and_process_eps "$keyword"
      if [[ "$3" =~ ^[0-9]+$ ]]; then
          
          head -n "$3" "${keyword}_colored_eps.txt" | column
      else
          
          echo -e "\033[0;32mCVE\t\t EPS Score \033[0m"
          cat "${keyword}_colored_eps.txt" | column
      fi
      
      ;;
    c )
      shift
      keyword=$1
      shift
      years=("$@")

      if [ ${#years[@]} -eq 0 ]; then
          echo "Nenhum ano fornecido. Exibindo todas as CVEs."
          funcao_c "$keyword"
          filter_and_color
      else
          echo "Anos fornecidos: ${years[@]}"
          funcao_c "$keyword" "${years[@]}"
          filter_and_color "${years[@]}"
      fi
      
      ;;
    d )
      shift
      keyword=$1
      shift  
      years=("$@")  

      if [ ${#years[@]} -eq 0 ]; then
         funcao_d "$keyword"
      else
      
         funcao_d "$keyword" "${years[@]}"
      fi
      ;;
    h )
      banner
      mododeuso
      ;;
    \? )
      banner
      mododeuso
      
      exit 1
      ;;
  esac
done
