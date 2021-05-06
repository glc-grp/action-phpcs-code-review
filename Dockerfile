FROM php:8.0.3-apache
LABEL "com.github.actions.icon"="check-circle"
LABEL "com.github.actions.color"="green"
LABEL "com.github.actions.name"="PHPCS Code Review"
LABEL "com.github.actions.description"="This will run phpcs on PRs"

RUN echo "tzdata tzdata/Areas select Asia" | debconf-set-selections && \
echo "tzdata tzdata/Zones/Asia select Kolkata" | debconf-set-selections

RUN set -eux
RUN apt-get update
RUN apt-get install -y git vim libzip-dev cowsay gosu jq python python-pip rsync sudo tree zip unzip wget curl
RUN pip install shyaml; \
	rm -rf /var/lib/apt/lists/*; \
	# verify that the binary works
	gosu nobody true
RUN docker-php-ext-install mysqli pdo pdo_mysql zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN useradd -m -s /bin/bash rtbot

RUN wget https://raw.githubusercontent.com/glc-grp/action-phpcs-code-review/master/tools-init.sh -O tools-init.sh && \
	bash tools-init.sh && \
	rm -f tools-init.sh

ENV VAULT_VERSION 1.4.3

# Setup Vault
RUN wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
        unzip vault_${VAULT_VERSION}_linux_amd64.zip && \
        rm vault_${VAULT_VERSION}_linux_amd64.zip && \
        mv vault /usr/local/bin/vault

COPY entrypoint.sh main.sh /usr/local/bin/

RUN cp /usr/local/bin/php /usr/bin
RUN chmod +x /usr/local/bin/*.sh
RUN composer global require emielmolenaar/phpcs-laravel
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
