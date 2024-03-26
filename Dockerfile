FROM drupal:10
RUN apt-get update && apt-get install -y \
	vim \
	net-tools \
	wget \
	git \
        default-mysql-client \
        && \
	apt-get clean && \
    	rm -rf /var/lib/apt/lists/* 
RUN echo "set mouse=v" >> /etc/vim/vimrc
ADD drupal-vhost.conf ./
COPY drupal-vhost.conf /etc/apache2/sites-enabled/000-default.conf
RUN sed -i '/^Listen/s/$/ \nListen 8080/' /etc/apache2/ports.conf
RUN echo "ErrorLog /dev/stderr" >> /etc/apache2/apache2.conf \
    && echo "CustomLog /dev/stdout combined" >> /etc/apache2/apache2.conf
RUN cat /etc/apache2/ports.conf
RUN mkdir -p drush
RUN ls -l	
#RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/latest/download/drush.phar
#RUN mv drush.phar drush
#RUN chmod +x drush
#RUN mv drush /usr/local/bin/drush
#RUN drush init -y
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV PATH = "${PATH}:/root/.composer/vendor/bin"
RUN composer require drush/drush
#RUN cat ./config/install_params.yaml
#RUN chmod u+w ./web/sites/default/settings.php
#RUN drush site-install standard --config=/config/install_params.yaml  --yes
#RUN cat ./web/sites/default/settings.php
