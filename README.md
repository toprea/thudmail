#Thudmail

##Overview

Thudmail aims to be a gmail-like webmail system. It is not usable yet.

It consists of:

* A Rails app providing a REST API around a message store
* an HTML+JS client app that talks to that API
* an email-loader script that can be pointed to by something like .forward or procmail



##Installing

* You'll need Rails 3.2.1.  Untested with any other versions.
* Grab the source and run 'rake db:create db:migrate' to bring up the database.
* Go into the sampledata directory and run ./import.sh to import some sample users and emails.
* Run 'rails server' to start, and hit http://localhost:3000