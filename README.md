# Welcome to NGOAIDMAP

NGOAIDMAP is a website available at http://ngoaidmap.org/. It was a custom development done initially by Vizzuality (vizzuality.com) for Interaction (interaction.org). The application consist of a database of projects. Those projects get aggregated to create Sites, for example http://foodsecurity.ngoaidmap.org/ or http://haiti.ngoaidmap.org/

It is probably a very specific application to be used directly, but the ideas and code behind it might be applicable for other people needs. If you have questions on how to use contact@vizzuality.com

## Database structure 

NGOAIDMAP is a project that allows you to create websites about projects around a certain topic. For example haiti or foodsecurity. 

The database consist of 4 main tables (and many supporting tables): "projects" done by "organizations" funded by "donors" which are included in different "sites".

Take a look at the database schema at db/db_schema.pdf to get a better idea of what the project does.

## Requirements

NGOAIDMAP is a Ruby on Rails application. The dependencies are:

 * Ruby 1.8.7
 * PostgreSQL 9.2 or higher.
 * Postgis 2.X+
 * Bundler 
 * RVM

## Installation

 * ```git clone git://github.com/Nightsprout/iom.git```
 * ```cd iom```
 * follow any RVM prompts if any
 * ```bundle install```
 * edit .env file
 * ```cp .env.sample .env```
 * edit .env if necessary
 * ```npm install```
 * ```bower install```

## Database Seeding

This is a big thing to do.  It'll take some time to fully seed. Some of the tasks are large and we have to make certain concessions thanks to the old version of Ruby/Rails.  Here's the process:

Run the following commands in order as written.  Don't combine them unless already combined.  If you're running them on Heroku, make sure to run them all with a PX-sized instance.

  * rake db:drop db:create iom:postgis_init db:migrate  
  * rake iom:data:load_regions_0
  * rake iom:data:load_regions_1
  * rake iom:data:load_regions_2
  * rake db:seed
  * rake iom:data:load_vitamin

The iom:data tasks will typically take between 10 minutes and 1 hour to complete (depends on the environment).  Brace yourself appropriately for the length of time required.


### Install Errors

There seems to be a consistent error with rake db:seed in the rake db:iom_reset process.  This is probably related to Ruby 1.8.7.  If that fails, run ```rake db:seed``` separately, and then run ```rake iom:data:load_adm_levels iom:data:load_orgs iom:data:load_projects```.


