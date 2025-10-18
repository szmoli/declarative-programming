file=$(basename $1 .md)
# echo $file
pandoc --pdf-engine=pdflatex $1 -o export/${file}.pdf
