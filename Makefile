deploy:
	./site rebuild && \
	git commit -am "Update `date`" && \
	git stpp _site origin gh-pages && \
	git put
