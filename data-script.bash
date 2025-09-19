#!/usr/bin/env bash
DATA="NCBirths2004.csv"

# ---------- Median Weight by Smoking Status ----------
# Function: compute median for a filter condition ($1 = column number, $2 = value, $3 = output file)
median_calc () {
    # Filter -> extract weight -> sort -> compute median
    awk -F, -v col="$1" -v val="$2" '$col==val {print $6}' "$DATA" \
      | sort -n > tmp_weights.txt
    count=$(wc -l < tmp_weights.txt)
    if (( count % 2 == 1 )); then
        mid=$(( (count + 1) / 2 ))
        sed -n "${mid}p" tmp_weights.txt
    else
        mid=$(( count / 2 ))
        w1=$(sed -n "${mid}p" tmp_weights.txt)
        w2=$(sed -n "$((mid + 1))p" tmp_weights.txt)
        echo "scale=2; ($w1 + $w2)/2" | bc
    fi
}

echo "Calculating median Weight by Smoker status..."
median_calc 8 "Yes" > smoker-yes-med.txt
median_calc 8 "No"  > smoker-no-med.txt

echo "Median Weight - Smoker=Yes: $(cat smoker-yes-med.txt)"
echo "Median Weight - Smoker=No : $(cat smoker-no-med.txt)"

# Babies of mothers who smoke tend to have a slightly lower median weight.

# ---------- Average Weight by Alcohol Use ----------
echo "Calculating average Weight by Alcohol use..."
awk -F, '$4=="Yes"{sum+=$6; n++} END {if(n>0) print sum/n}' "$DATA" > alcohol-yes-avg.txt
awk -F, '$4=="No" {sum+=$6; n++} END {if(n>0) print sum/n}' "$DATA" > alcohol-no-avg.txt

echo "Average Weight - Alcohol=Yes: $(cat alcohol-yes-avg.txt)"
echo "Average Weight - Alcohol=No : $(cat alcohol-no-avg.txt)"
