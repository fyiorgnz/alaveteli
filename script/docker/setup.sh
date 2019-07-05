#!/bin/bash
cd /opt/alaveteli

if [ -d /opt/alaveteli/lib/acts_as_xapian/xapiandbs ]
then
  rm -rf /opt/alaveteli/lib/acts_as_xapian/xapiandbs
fi

mkdir /opt/alaveteli/lib/acts_as_xapian/xapiandbs

if [ ! -d "$XAPIAN_MOUNT_PATH"/"$RAILS_ENV" ]
then
  echo "making $XAPIAN_MOUNT_PATH/$RAILS_ENV"
  mkdir -p "$XAPIAN_MOUNT_PATH"/"$RAILS_ENV"
fi

echo "linking $XAPIAN_MOUNT_PATH/$RAILS_ENV/ to /opt/alaveteli/lib/acts_as_xapian/xapiandbs/$RAILS_ENV/"
ln -s "$XAPIAN_MOUNT_PATH"/"$RAILS_ENV"/ /opt/alaveteli/lib/acts_as_xapian/xapiandbs/"$RAILS_ENV"

/opt/alaveteli/script/docker/buildconf.rb

# Check for Database
while :
do
  echo "Checking Alaveteli DB exists..."
  psql $DATABASE_URL --command="SELECT version();" >/dev/null 2>&1
  retval=$?
  if [ $retval -eq 0 ]
  then
    break
  fi
  # If not sidekiq instance, create database
  if [ -z "$SIDEKIQ" ]
  then
    bundle exec rake db:create
    break
  fi
  echo "DB doesn't exist, waiting 60s for creation..."
  sleep 60
done

# Different start up for rails instance
if [ -z "$SIDEKIQ" ]
then
  # Rails instance, execute DB migration and assets
  bundle exec rake db:migrate
  bundle exec rake db:holding_pen
  bundle exec rake themes:install
  bundle exec rake assets:precompile

  rsync -a --delete-delay /opt/alaveteli/public/ /data/alaveteli/public

  chown -R $(whoami) /data

  bundle exec unicorn_rails -c ./config/unicorn.rb
  #/usr/bin/supervisord -c /etc/supervisor/supervisor-rails.conf
else
  # Wait until any migrations are complete
  bundle exec rake db:wait_for_migration
  bundle exec rake themes:install

  chown -R $(whoami) /data

  /usr/bin/supervisord -c /etc/supervisor/supervisor-sidekiq.conf
fi
