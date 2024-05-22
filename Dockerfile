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
		
#RUN sed -i '/memory_limit = 128M/memory_limit = 256M/' /usr/local/etc/php/php.ini-development   
#/usr/local/etc/php/php.ini-production
		
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
RUN apt-get update
RUN apt-get install -y libicu-dev
RUN docker-php-ext-install intl
RUN docker-php-ext-install mysqli
# No prompt for compile assets
RUN composer config 'extra.compile-mode' all
# required for Civi > 5.30
RUN composer config 'extra.enable-patching' true
RUN composer config --no-plugins allow-plugins.civicrm/civicrm-asset-plugin true
RUN composer config --no-plugins allow-plugins.cweagans/composer-patches true
RUN composer config --no-plugins allow-plugins.civicrm/composer-downloads-plugin true
RUN composer config --no-plugins allow-plugins.civicrm/composer-compile-plugin true
# sudo -u circleinteractive $COMPOSER config --no-plugins allow-plugins.civicrm/civicrm-asset-plugin true
# sudo -u circleinteractive $COMPOSER config --no-plugins allow-plugins.cweagans/composer-patches true
# sudo -u circleinteractive $COMPOSER config --no-plugins allow-plugins.civicrm/composer-downloads-plugin true
# sudo -u circleinteractive $COMPOSER config --no-plugins allow-plugins.civicrm/composer-compile-plugin true
RUN composer require civicrm/civicrm-core:5.69.2 \
    && composer require civicrm/civicrm-packages:5.69.2 \
    && composer require civicrm/civicrm-drupal-8:5.69.2 \
	&& composer require civicrm/civicrm-asset-plugin:^1.1 \
	&& composer require drupal/civicrm_entity:^4.0@alpha \
	&& composer require drupal/webform_civicrm:^6.2 \
	&& composer require drupal/civicrm_drush
    # && composer install --no-dev --prefer-source -n
RUN composer require civicrm/cli-tools
#RUN cat ./config/install_params.yaml
#RUN chmod u+w ./web/sites/default/settings.php
#RUN drush site-install standard --config=/config/install_params.yaml  --yes
#RUN cat ./web/sites/default/settings.php
