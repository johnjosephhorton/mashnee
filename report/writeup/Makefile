data = ../data/data.csv

params =

params += parameters_name.tex
parameters_name.tex: $(data) ../analysis/params_get_name.R
	cd ../analysis && Rscript params_get_name.R 


tables =

tables += tables/comps.tex
tables/comps.tex: ../analysis/table_comps.R
	cd ../analysis && Rscript table_comps.R

plots =

plots += plots/map.pdf 
plots/map.pdf: ../analysis/plot_map.R $(data)
	cd ../analysis && Rscript plot_map.R

plots += plots/hist.pdf 
plots/hist.pdf: ../analysis/plot_hist.R $(data)
	cd ../analysis && Rscript plot_hist.R


plots += plots/square_feet.pdf 
plots/square_feet.pdf: ../analysis/plot_square_feet.R $(data)
	cd ../analysis && Rscript plot_square_feet.R

plots += plots/age.pdf 
plots/age.pdf: ../analysis/plot_age.R $(data)
	cd ../analysis && Rscript plot_age.R

plots += plots/lot_size.pdf 
plots/lot_size.pdf: ../analysis/plot_lot_size.R $(data)
	cd ../analysis && Rscript plot_lot_size.R

plots += plots/price.pdf 
plots/price.pdf: ../analysis/plot_price.R $(data)
	cd ../analysis && Rscript plot_price.R

plots += plots/price_versus_square_feet.pdf 
plots/price_versus_square_feet.pdf: ../analysis/plot_price_versus_square_feet.R $(data)
	cd ../analysis && Rscript plot_price_versus_square_feet.R

plots += plots/bedroom_bathroom.pdf 
plots/bedroom_bathroom.pdf: ../analysis/plot_bedroom_bathroom.R $(data)
	cd ../analysis && Rscript plot_bedroom_bathroom.R

plots += plots/baths_versus_bedrooms.pdf 
plots/baths_versus_bedrooms.pdf: ../analysis/plot_baths_versus_bedrooms.R $(data)
	cd ../analysis && Rscript plot_baths_versus_bedrooms.R

plots += plots/ecdf.pdf 
plots/ecdf.pdf: ../analysis/plot_ecdf.R $(data)
	cd ../analysis && Rscript plot_ecdf.R

plots += plots/bootstrap_price_predictions.pdf 
plots/bootstrap_price_predictions.pdf: ../analysis/plot_bootstrap_price_predictions.R $(data)
	cd ../analysis && Rscript plot_bootstrap_price_predictions.R

plots += plots/predictive_model.pdf 
plots/predictive_model.pdf: ../analysis/plot_predictive_model.R $(data)
	cd ../analysis && Rscript plot_predictive_model.R




report.pdf: report.tex $(plots) $(params) $(tables)
	pdflatex report.tex
	pdflatex report.tex

