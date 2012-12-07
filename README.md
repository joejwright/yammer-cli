A Yammer Command Line Interface
===============================

This is a simple command line interface for Yammer that can be used to quickly lookup and post new updates.

Installation
------------

    gem install yammer-cli

Usage
-----
    yammer -s consumer_token,consumer_secret (Setup oAuth parameters)

    yammer -u "Yammer from the command line is so much quicker!" (post update)

    yammer -g group_id (post update in a group)

    yammer -l (list last 20 updates)

TODO
----

* Add better options for listing previous updates.
* Seperate updates by day / hour

TIPS
----

* alias "yammer -l " in your shell to y to make sending updates quicker. When sending a yammer updates I simply type y "Heading to client meeting."
