head -n 1 NCBirths2004.csv

# AI-assisted: filter + select + numeric sort for median
awk -F, 'NR>1 && $8=="Yes"{print $6}' NCBirths2004.csv | sort -n > w_smoker_yes.txt
