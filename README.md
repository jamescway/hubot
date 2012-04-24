HomeRun's Hubot
==============

It's already running *in the cloud* (Heroku). Just `gem install heroku` in whatever ruby you want, and after telling someone that you want to be able to push to the heroku repository for this hubot you should be able to make changes and push them up. No biggie. - Jose

**Pro Tip**: you can deploy a branch to heroku. Say you are working on something risky or more complicated, you might want to
throw a branch out there so you can easily back it out if it doesn't work. 

To do this, create your local branch and hack and commit as usual. When you are ready, push your branch
onto heroku's master branch like so `git push heroku <my_branch>:master` to test it out in campfire. If something blows up after that, simply `git push heroku` to deploy master to heroku again.