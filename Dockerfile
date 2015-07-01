FROM ruby
MAINTAINER caleb.tutty@nzherald.co.nz

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive
ENV RAILS_ENV production

# Update
RUN apt-get update && apt-get upgrade -y

# Install required packages
RUN apt-get -y install supervisor ca-certificates git postgresql-client build-essential catdoc elinks \
 gettext ghostscript gnuplot-nox imagemagick unzip \
 libicu-dev libmagic-dev libmagickwand-dev libmagickcore-dev libpq-dev libxml2-dev libxslt1-dev links \
 sqlite3 lockfile-progs mutt pdftk poppler-utils \
 postgresql-client tnef unrtf uuid-dev wkhtmltopdf wv xapian-tools

# Clone develop branch
RUN mkdir /opt/alaveteli
ADD . /opt/alaveteli
WORKDIR /opt/alaveteli

# Add yaml configuration which take environment variables
RUN rm config/database.yml
RUN rm config/general.yml
RUN rm config/newrelic.yml

RUN cp script/docker/database.yml config/database.yml
RUN cp script/docker/general.yml config/general.yml
RUN cp script/docker/newrelic.yml config/newrelic.yml

RUN mkdir -p cache

RUN git submodule init && git submodule update
# Due to some firewalls blocking git://
RUN git config --global url."https://".insteadOf git://

RUN bundle install --without development debug test --deployment --retry=10

CMD ./script/docker/setup.sh
