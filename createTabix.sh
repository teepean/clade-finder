#SET PARAMS FROM CONFIG
CFG_FILE=config.txt
CFG_CONTENT=$(cat $CFG_FILE | sed -r '/[^=]+=[^=]+/!d' | sed -r 's/\s+=\s/=/g')
eval "$CFG_CONTENT"

PATH=$PATH:$pythonPath:$htslibPath

createTabixTSV_py="$pythonScriptsDir${pathSeparator}createTreeInTabix.py"
findCladeJSON_py="$pythonScriptsDir${pathSeparator}findCladeJSON.py"
cladeSNPs="$workingDir${pathSeparator}cladeSNPs"
SNPclades="$workingDir${pathSeparator}SNPclades"
positionMarkers="$workingDir${pathSeparator}positionMarkers"

rm $workingDir${pathSeparator}*

python3 "$createTabixTSV_py" "$treeFile" "$hg19markerPositionsTSV" "$hg38markerPositionsTSV" "$cladeSNPs" "$SNPclades" "$positionMarkers" "$productsFile" "$toIgnoreFile"
sort "$cladeSNPs" "-k1,1" "-k2n" | "bgzip" > "$cladeSNPs.bgz"
tabix "-s" "1" "-b" "2" "-e" "3" "$cladeSNPs.bgz"
sort "$SNPclades" "-k1,1" "-k2n" | "bgzip" > "$SNPclades.bgz"
tabix "-s" "1" "-b" "2" "-e" "3" "$SNPclades.bgz"
sort "$positionMarkers" "-k1,1" "-k2n" | "bgzip" > "$positionMarkers.bgz"
tabix "-s" "1" "-b" "2" "-e" "3" "$positionMarkers.bgz"

python3 "$findCladeJSON_py" "$cladeSNPs.bgz" "$SNPclades.bgz" "PH1080+, Z1043+, Z1297+, M12+, M241+, L283+, Z1825+, CTS11760-, Z8429-" "phyloeq,downstream,products,score,panels" "$snpPanelConfigPath"