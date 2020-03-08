deploy:
	./site rebuild && \
	git commit -am "Update `date`" && \
	git put && \
	deploy.sh
