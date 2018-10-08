FROM ruby:2.3.1 as rubybase

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND noninteractive

# Update
RUN apt-get update && apt-get upgrade -y

# Install required packages
RUN apt-get -y install supervisor ca-certificates git postgresql-client build-essential catdoc elinks \
 gettext ghostscript gnuplot-nox imagemagick unzip \
 libicu-dev libmagic-dev libmagickwand-dev libmagickcore-dev libpq-dev libxml2-dev libxslt1-dev links \
 sqlite3 lockfile-progs mutt pdftk poppler-utils \
 postgresql-client tnef unrtf uuid-dev wkhtmltopdf wv xapian-tools

FROM rubybase

ENV RAILS_ENV production

# Clone develop branch
COPY Gemfile Gemfile.lock /opt/alaveteli/
WORKDIR /opt/alaveteli/
RUN bundle install --without development debug test --deployment --retry=10 --clean

COPY . /opt/alaveteli/

# Add yaml configuration which take environment variables
COPY script/docker/database.yml config/database.yml
COPY script/docker/general.yml config/general.yml

RUN mkdir -p cache

CMD ./script/docker/setup.sh
