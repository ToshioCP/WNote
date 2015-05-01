### What's WNote

WNote is 'Web Note'.
User is a person who has logged in to this site.
Guest is a person who hasn't logged in to this site.
If you want to be a User, you need to sign up first.
User can write anything in WNote and save it.
User can read any note you saved.
Guest can read notes which r_public switch is on.
Guest cannot read notes which r_public switch is off.

### WNote has article and section

Notes can be grouped by the section.
sections also can be grouped by the article.
So you can organize your notes, like a paper article.

### WNote is deployed to Heroku but it's still in development level.

WNote is in development level.
It doesn't have enough power, yet.

### features

- Markdown is available
- designed with Bootstrap
- tree structure ( article - section - note )
- user login/logout/signup system
### Installation notes

WNote runs on Heroku in production mode.
You need to use Postgresql database for the rails application on Heroku.
So, WNote is configured to use Postgrsql as its database.
If you want to use other database ( for example Mysql ), modify 'Gemfile', 'config/database.yml'.
With Postgresql you should notice that postgresql user has to be SUPERUSER.
Because Rails Test does't work by no SUPERUSER.
It's OK everything without test even if you are not SUPERUSER of Postgresql.
Someone said it's a bug of Active Record (but I don't know it's true or not).

### TODO list

- admin ( superuser )
- backup/reset/restore
