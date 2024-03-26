# Get the directory of the script
DIR="$(dirname "$(readlink -f "$0")")"

source $DIR/common.sh

if [ -z "$NUM_THREADS" ]; then
  NUM_THREADS="$(nproc)"
fi

url="https://packages.fedoraproject.org"
fullurl="$url/index-static.html"
selector="p#prefix > a"

# Download the HTML content
html=$(curl -s "$fullurl")

hrefs=$(echo "$html" | pup "$selector" attr{href})

scrape_url() {
  subpage_html=$(curl -s "$1")
  result=$(echo "$subpage_html" | pup "li > a" text{})
  echo "$result"
  source common.sh
  debug "Load successfully page: $1"       #show-if-used: DEBUG
}

# for href in $hrefs; do      
#   scrape_url "$url/$href"    
# done                          
export -f scrape_url
echo "$hrefs" | xargs -n 1 -P $NUM_THREADS -I {} bash -c "scrape_url $url/{}"

