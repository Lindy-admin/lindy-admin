# lindy-admin-rails

## Development

Install Docker engine and Docker-Compose

Add these entries to your hosts file
```
127.0.0.1       *.admin.test
127.0.0.1       lindy.test
```

* Run ```develop-build.sh``` to build the docker images (go grab some chai tea)
* Run ```develop-start.sh``` to start the development environment
* Run ```develop-attach.sh``` to attach to the container that is running the Rails image (you may need to press a button before the container will respond with the terminal)

While attached to the container, you can use normal rails development. For example: you can run ```rails s``` to start a development server. The application can now be reached by typing ```admin.dev``` in your browser.

## Usage

For Members to sign up, at least one Course with at least one Ticket should be created. This can be done by:

1. going to "Courses"
2. click "New Course"
3. fill out fields and submit
4. click "New Ticket"
5. fill out fields and submit

Now new Members can register through the "Registration form example".

You can also choose to seed the database with randomly generated Members for testers. This can be done by using the rake task ```lindy:seed```.
