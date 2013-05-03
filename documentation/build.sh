echo "Removing the old .html file"
rm article.html
echo "Building a new html from source"
asciidoc -b html5 -a icons -a toc2 -a theme=flask article.txt
echo "Copying new to server"
scp article.html skrieder@datasys.cs.iit.edu:/home/skrieder/public_html