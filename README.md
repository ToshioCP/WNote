#### 日本語の解説が英語の解説の後にあります

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
- Decolated with Bootstrap
- tree structure ( user - article - section - note )
- user can login/logout/signup
- user can backup/restore his or her data.
- user can make epub data from his/her article.
- admin can delete any user except him/her.

### Installation notes

WNote runs on Heroku in production mode.
(https://floating-shore-5277.herokuapp.com/)
You need to use Postgresql database for the rails application on Heroku.
So, WNote is configured to use Postgrsql as its database.
If you want to use other database ( for example Mysql ), modify 'Gemfile', 'config/database.yml'.
With Postgresql you should notice that postgresql user has to be SUPERUSER.
Because Rails Test does't work by no SUPERUSER.
Everything without test works well even if you are not SUPERUSER of Postgresql.

----------

### WNoteとは？

WNoteは'Web Note（ウェブ上のノート）'です。
ユーザとはWNoteのウェブサイトにログインした人を指します。
ゲストとはそのサイトにログインしていない人を指します。
ユーザになりたい場合は、まずサインアップ（ユーザ登録）をしてください。
ユーザはWNote上でノートを書いたり保存したりできます。
また、保存したノートを読むこともできます。
ゲストの場合は、r_publicフラグがオンになっているノートを読むことができますが、
オフになっているノートは読むことができません。

### articleとsection

ノートはセクションにまとめることができます。
また、セクションはアーティクル（記事）にまとめることができます。
そこで、紙に書かれた記事や論文にょうに、ノートをまとめることができます。

### WNoteはHeroku上で稼働していますがまだ開発段階です

WNoteはまだ開発段階です。
まだ十分な能力を持っているとはいえません。

### 特長

- Markdown仕様で書くことができます
- Bootstrapで体裁を整えて画面表示します
- 木構造 ( user - article - section - note )
- ユーザはログイン、ログアウト、ユーザ登録することができます
- ユーザは自身のデータをバックアップ、リストアできます
- ユーザは自身のアーティクルからepubデータを作成することができます
- 管理者（admin）は自分以外のユーザを削除することができます

### インストレーション

WNoteはHeroku上で「Ruby on Rails」のプロダクション・モードで動作しています。
(https://floating-shore-5277.herokuapp.com/)
WNoteは、「Ruby on Rails」とPostgresqlデータベースが必要です。
というのは、HerokuではデータベースにPostgreaqlが使われているからです。
もしも、他のデータベース（例えばMySql）を使いたい場合は、'Gemfile'と'config/database.yml'をそれに合うように変更してください。
Postgresqlを使う場合、そのユーザはSUPERUSERでなければなりません。
なぜなら、Ruby on RailsのテストはSUPERUSERでないと動作しないからです。
テスト以外の機能はSUPERUSERでなくてもPostgresqlはきちんと動作します。
