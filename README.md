Using JWT (JASON Web Tokens) in Ruby
------------------------------------

*Tech stack Used
  -Ruby
  -Sinatra
  -Rackup
  -HTML 5.0

*rubygems
 -Sinatra
 -jwt
 -JSON

This is an attempt to use the ruby-jwt-rackup package on github to encode and decode
jwt. The example on github does not clearly explain all the intermediary steps and hence
this attempt.

Steps to run the from the terminal

> Projects folder> git clone git@github.com:phipax/ruby-jwt-rackup.git
> Projects folder> cd ruby-jwt-rackup
> Projects folder> bundle install
> Projects folder> JWT_SECRET='yoursecret' JWT_ISSUER='your-issuer-info' rackup

> open localhost:9292 for the landing page.

#Login using one of the below user ids & password
  > tomd: 'abc',
  > mark: 'therockshow',
  > trav: 'whatsmyageagain'
