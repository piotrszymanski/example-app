FROM dockerhub.artifactory.cphdev.deltek.com/httpd:2.4

EXPOSE 80

# Copy the application production files.
COPY ./dist/ /usr/local/apache2/htdocs

# Modify the Apache configuration for single-page apps.
RUN echo "FallbackResource /index.html" >> /usr/local/apache2/conf/httpd.conf
