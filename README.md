Ruby GitHub Pull Request Email Bot
==================================

What is it?
-----------

Just like the original inspiration for this
([samwho/GitHub-Pull-Request-Email-Bot](https://github.com/samwho/GitHub-Pull-Request-Email-Bot)),
this is a script to send email to a specified address every time a
repository recieves a pull request.

Unlike the original, however, this can be configured to work with
multiple repositories.

How do I get it up and running?
-------------------------------

Make sure you have the following gems installed:

  * HTTParty
  * Mustache
  * Pony

Should be as simple as running `gem install httparty mustache pony`.

Copy `config.sample.yaml` to `config.yaml`, and edit to taste.

Take a look at the templates in `templates`, and modify to suit your
needs.  Possibly copying to new directories, moddifying on a
per-repository basis, depending on how you setup your `config.yaml`.

Change directories into where you have the `pull-request-bot` script,
along with `config.yaml`, and run it with `./pull-request-bot`.  You
can also specify the path to the `config.yaml` by invoking
`pull-request-bot` with the `-c` or `--config` flag
(`./pull-request-bot -c /path/to/config.yaml`).

The script will keep track of which pull requests it's seen in the
state directory that was configured in `config.yaml` (this defaults to
`./state`).

Is there anything I can do to help?
-----------------------------------

Absolutely!  Let me know about any bugs you find or feature requests
you have in the
[issue tracker](https://github.com/jhelwig/Ruby-GitHub-Pull-Request-Email-Bot/issues).
Send any changes you have code for in a pull request, using `git
format-patch` and `git send-email`, via a URL to a git repository and
a branch name, or any of the many ways to get someone your commits in
git.

I'm usually on the [Freenode IRC network](http://freenode.net/) as
`jhelwig`.  Feel free to swing by `#pdxhackathon` to say "Hi", get
some help, or whatever.  If I don't respond right away, don't worry.
If you stick around, I'll eventually notice the IRC activity, and get
back to you.
