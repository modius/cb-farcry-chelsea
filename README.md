# Chelsea Boots

CloudBees install for FarCry CMS sample project Chelsea Boots.

```
Stack: Cloudbees (Tomcat 6 or 7), Railo (v4.1.2.005 final), mySQL
Core: FarCry 7.0 (core)
Plugins: FarCry CMS (plugin-farcrycms)
Project: Chelsea Boots (project-chelsea)
```

## Installation

### Cloudbees SDK

Download and install [Cloudbees tool chain for your operating system](http://wiki.cloudbees.com/bin/view/RUN/BeesSDK)

If you are on OSX, I recommend Homebrew

```brew install cloudbees-sdk```


### Create CloudBees App

Create a location for your CloudBees app. It can be anywhere really but it's a good idea to create a home like ```CloudBees``` to house your applications.

Create a basic Tomcat Cloudbees app and switch into the directory. The default application template is a simple Tomcat 6 container -- this is fine. We're using an app name of ```chelsea``` just to be consistent with the project naming, but it could be anything.

```
cd ~/CloudBees
bees create chelsea
cd ~/CloudBees/chelsea
```


### Clone/Fork Chelsea Repo

Delete the default ```./webapp``` folder and all its contents. We'll replace this with the repo your about to clone/fork. Clone the **CloudBees Chelsea Project** into the ```webapp``` folder.  Make sure the folder name is ```webapp``` -- it can't be anything else.

```
rm -rf webapp
git clone https://github.com/modius/cb-farcry-chelsea.git webapp
```

Check to see that the application is correctly installed by starting up the app from within the root of the Cloudbees installation.

```
cd ~/CloudBees/chelsea
bees run
```

Browse to **http://localhost:8080/farcry/index.cfm** -- you should see an installation screen (with an error!).

Browse to **http://localhost:8080/railo-context/admin/web.cfm** -- we're going to login to the Railo admin and set up some datasources for our project. The password for both server and web admin is ```chelsea```.


## TODO

Set up instructions for s3 bucket:

- io.domainname.com.au
- with ./live
- set up config for old and new
- migrate images

Set up mySQL db in Cloudbees:

- unique name: farcryio-projectname
- usr: as per db / pwd: as per db + 123

Datasource:

- local: projectname-local (mysql)
- cb: projectname
- add switch to farcryConstructor.cfm
- use regular datasource connection to ec2 instance
- test locally/remotely

