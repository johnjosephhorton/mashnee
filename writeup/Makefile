data = ../data/data.csv

params =

params += parameters_name.tex
parameters_name.tex: $(data) ../analysis/params_get_name.R
	cd ../analysis && Rscript params_get_name.R 

plots =

plots += plots/square_feet.pdf 
plots/square_feet.pdf: ../analysis/plot_square_feet.R $(data)
	cd ../analysis && Rscript plot_square_feet.R

plots += plots/price.pdf 
plots/price.pdf: ../analysis/plot_price.R $(data)
	cd ../analysis && Rscript plot_price.R

plots += plots/price_versus_square_feet.pdf 
plots/price_versus_square_feet.pdf: ../analysis/plot_price_versus_square_feet.R $(data)
	cd ../analysis && Rscript plot_price_versus_square_feet.R

plots += plots/bedroom_bathroom.pdf 
plots/bedroom_bathroom.pdf: ../analysis/plot_bedroom_bathroom.R $(data)
	cd ../analysis && Rscript plot_bedroom_bathroom.R

report.pdf: report.tex $(plots) $(params)
	pdflatex report.tex
	pdflatex report.tex

