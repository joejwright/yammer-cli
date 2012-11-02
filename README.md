A Yammer Command Line Interface
===============================

This is a simple command line interface for Yammer that can be used to quickly lookup and post new updates.

Usage
-----
    yammer -s (Setup oAuth parameters)

    yammer -u "Yammer from the command line is so much quicker!" (post update)

    yammer -l (list last 20 updates)

Right now you'll have to manually configure your OAuth token and secret in the source code.

TODO
----

* Add better options for listing previous updates.
* Seperate updates by day / hour

TIPS
----

* alias "yammer -l " in your shell to y to make sending updates quicker. When sending a yammer updates I simply type y "Heading to client meeting."
