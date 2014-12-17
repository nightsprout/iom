

![Partners Map](http://www.partnersmap.org/dist/images/partners_horizontal.png)

# Welcome to the Partners Map

The Partners Map is an interactive, online tool that shows where organizations are working, what activities they are doing, and how to contact them for more information. Collaborators submit their data for inclusion on the map, which can then be used to identify potential partners, establish synergistic relationships, and leverage resources. Through embeddable iFrames, the Partners Map also allows partners to easily showcase their achievements.

This platform was a custom development done initially by Vizzuality (vizzuality.com) for Interaction (interaction.org). This project was forked from the original NGOAIDMAP, which can be found at https://github.com/simbiotica/iom. This fork was developed by Nightsprout (Nightsprout.com) to be used by the STH Coalition (STHCoalition.org) on PartnersMap.org.

The application consists of a database of projects. Those projects get aggregated to create Sites, for example http://foodsecurity.ngoaidmap.org/ or http://haiti.ngoaidmap.org/. The application is somewhat customized for a specific use, so care is needed when forking the map. Any contributions which help generalize the map further are welcomed.


## Database structure 

The map allows you to create sub-sites about projects around a certain topic. For example, global health, disaster relief, and so forth. 

The database consist of 4 main tables (and many supporting tables): "projects" done by "organizations" funded by "donors" which are included in different "sites". Take a look at the database schema at db/db_schema.pdf for more information.


## Requirements

The map is a Ruby on Rails application. The dependencies are:

 * Ruby 1.9.3
 * PostgreSQL 9.2 or higher.
 * Postgis 2.X+
 * Redis, Resque, running workers as appropriate
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

This is a big thing to do.  It'll take some time to fully seed. Some of the tasks are large and we have to make certain concessions thanks to the old version of Ruby/Rails. Here's the process:

Run the following commands in order as written.  Don't combine them unless already combined.  If you're running them on Heroku, make sure to run them all with a PX-sized instance.

  * rake db:drop db:create iom:postgis_init iom:tiger_init db:migrate  
  * rake iom:data:load_regions_0
  * rake iom:data:load_regions_1
  * rake iom:data:load_regions_2
  * rake db:seed
  * rake iom:data:load_vitamin

The iom:data tasks will typically take between 10 minutes and 1 hour to complete (depends on the environment).  Brace yourself appropriately for the length of time required.

## Hosting/Deploying

This project fork is modified specifically for running on Heroku.  If any issues related to the environment constraints occur, please open an Issue as appropriate.

This project is running on Rails 3.1, but the Asset Pipeline is not currently being used.  Before deploying, make sure to run ```grunt build``` and commit the compiled files to the repository.

PostGIS is only available on "Standard 0" and higher Heroku Postgres plans.  At least one Worker process must always be running.

### Contributions

Contributions and collaboration are welcome. Please contact cww@taskforce.org to share your ideas or request additional information.
