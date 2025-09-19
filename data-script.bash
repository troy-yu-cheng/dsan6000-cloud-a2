#!/usr/bin/env bash
# data-script.bash
# Reproducible analysis for NCBirths2004.csv
# AI-assisted: script and comments created with AI guidance.
# Run this script from the folder containing NCBirths2004.csv.

# Part 1: Data Exploration 
# Examine the data file NCBirths2004.csv
head NCBirths2004.csv

# Extract the column names from the data file and save them to a file called headers.txt
head -n 1 NCBirths2004.csv > headers.txt

# Part 2: Reproducible Analysis
# Check column numbers for Weight and Smoker
#   -F, : comma as field separator
#   NR==1 : process only the header row
#   NF : number of fields in the row
#   print i,$i : print column index and name
awk -F, 'NR==1{for(i=1;i<=NF;i++) print i, $i}' NCBirths2004.csv

# Median Weight – Smoker = Yes
# AI-assisted: filter rows where column 8 (Smoker) equals "Yes"
#   -F,   : use comma as field separator for CSV
#   NR>1  : skip header row
#   $8    : value of 8th column
#   print $6 : output only the 6th column (Weight)
#   sort -n  : numeric sort required to compute median
awk -F, 'NR>1 && $8=="Yes"{print $6}' NCBirths2004.csv | sort -n \
    | awk ' # AI-assisted: find median directly without temp file
        {a[NR]=$1}
        END{
            if(NR%2){print a[(NR+1)/2]} # odd count → middle value
            else {print (a[NR/2]+a[NR/2+1])/2} # even count → average of two
        }' > smoker-yes-med.txt

# Median Weight – Smoker = No
awk -F, 'NR>1 && $8=="No"{print $6}' NCBirths2004.csv | sort -n \
    | awk ' # AI-assisted: direct median calculation
        {a[NR]=$1}
        END{
            if(NR%2){print a[(NR+1)/2]}
            else {print (a[NR/2]+a[NR/2+1])/2}
        }' > smoker-no-med.txt

# Print labeled medians to STDOUT (these will land in bash-stdout.txt on final run)
echo "Median Weight - Smoker=Yes: $(cat smoker-yes-med.txt)"
echo "Median Weight - Smoker=No : $(cat smoker-no-med.txt)"

# Summary:
# In this dataset, babies born to mothers who smoke tend to have a lower median birth weight than babies born to non-smoking mothers.


# Average Weight – Alcohol = Yes
# AI-assisted: filter Alcohol=Yes, accumulate sum and count to compute average
#   -F, : comma as field separator
#   NR>1 : skip header row
#   $4   : Alcohol column
#   $6   : Weight column
#   sum+=$6; n++ : add weight to sum and increment counter
#   END{if(n) print sum/n} : after all rows, print mean
awk -F, 'NR>1 && $4=="Yes"{sum+=$6; n++} END{if(n) print sum/n}' \
    NCBirths2004.csv > alcohol-yes-avg.txt

# Average Weight – Alcohol = No
# AI-assisted: compute mean for Alcohol=No
awk -F, 'NR>1 && $4=="No"{sum+=$6; n++} END{if(n) print sum/n}' \
    NCBirths2004.csv > alcohol-no-avg.txt

# Display averages with clear labels
echo "Average Weight - Alcohol=Yes: $(cat alcohol-yes-avg.txt)"
echo "Average Weight - Alcohol=No : $(cat alcohol-no-avg.txt)"

# Summary: In this dataset, babies born to mothers who consume alcohol during pregnancy tend to have a slightly lower average birth weight than those whose mothers did not consume alcohol. 

# Part 3: Advanced Statistics
# AI-assisted: accumulate n, sum(x), and sum(x^2) for Alcohol=Yes
#   -F, : comma as field separator
#   NR>1 : skip header row
#   $4=="Yes" : filter Alcohol column
#   $6 : Weight column
#   n++ : increment count
#   sum+=$6 : accumulate weight
#   sumsq+=$6*$6 : accumulate square of weight
#   END{print n, sum, sumsq} : output three numbers
awk -F, 'NR>1 && $4=="Yes"{n++; sum+=$6; sumsq+=$6*$6} END{if(n) print n, sum, sumsq}' NCBirths2004.csv \
  | awk '{n=$1; s=$2; ss=$3; print "scale=10; sqrt( (",ss,"/",n,") - ((",s,"/",n,")^2 ) )"}' \
  | bc -l > stddev-alcohol-yes.txt

echo "Standard Deviation of Weight (Alcohol=Yes): $(cat stddev-alcohol-yes.txt)"

