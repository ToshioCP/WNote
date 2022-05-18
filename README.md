#### 日本語の解説が英語の解説の後にあります

### What's WNote

WNote is 'Web Note'.
User is a person who has logged in the WNote.
Guest is a person who hasn't logged in it.
If you want to be a User, you need to sign up first.
Users can create and write a note.
They can read, modify, save and delete it.
Guest can read a note if its r_public switch is on.
Otherwise, Guest cannot read it.

### WNote has article and section

Notes can be grouped by the section.
Sections also can be grouped by the article.
So you can organize your notes, like a paper article.

### WNote is deployed to Heroku but it's still in development level.

WNote is in development level.

### features

- Markdown is available
- Decorated with Bootstrap
- tree structure ( user - article - section - note )
- user can login/logout/signup
- user can backup/restore his/her data.
- user can make epub data from his/her article.
- admin can delete any user except him/her.
- user can upload images
- Support Internationalization (English and Japanese)

### Installation notes

Ruby 3.1.2, Rails 7.0.3 are required.
WNote is configured to use Postgrsql as its database.
If you want to use other database, modify 'Gemfile' and 'config/database.yml'.
With Postgresql you should notice that postgresql user has to be a SUPERUSER.
Because Rails Test does't work without SUPERUSER privilege.
Everything except test works well even if you are not a postgresql SUPERUSER.

### Wnote in the internet

WNote is running on the Heroku in production mode.
(https://floating-shore-5277.herokuapp.com/)
If you want to use it, be careful because its version is still in development.
You should backup your data, against the unexpected errors.

----------

### WNoteとは？

WNoteは'Web Note（ウェブ上のメモ）'です。
ユーザとはWNoteのウェブサイトにログインした人を指します。
ゲストとはそのサイトにログインしていない人を指します。
ユーザになりたい場合は、まずサインアップ（ユーザ登録）をしてください。
ユーザはWNote上でメモを書いたり保存したりできます。
また、保存したメモを読むこともできます。
ゲストの場合は、r_publicフラグがオンになっているメモを読むことができますが、
オフになっているメモは読むことができません。

### アーティクルとセクション

メモはセクションにまとめることができます。
また、セクションはアーティクル（記事）にまとめることができます。
このようにして、紙に書かれた記事や論文のように、メモをまとめることができます。

### WNoteはHeroku上で稼働していますがまだ開発段階です

WNoteはまだ開発段階です。

### 特長

- Markdown仕様で書くことができます
- Bootstrapで体裁を整えて画面表示します
- 木構造 ( user - article - section - note )
- ユーザはログイン、ログアウト、ユーザ登録することができます
- ユーザは自身のデータをバックアップ、リストアできます
- ユーザは自身のアーティクルからepubデータを作成することができます
- 管理者（admin）は自分以外のユーザを削除することができます
- ユーザは画像をアップロードすることができます
- 国際化をサポートしています（英語と日本語）

### インストレーション

Ruby 3.1.2, Rails 7.0.3 が必要です。
WNoteは、「Ruby on Rails」とPostgresqlデータベースが必要です。
というのは、HerokuではデータベースにPostgreaqlが使われているからです。
もしも、他のデータベースを使いたい場合は、'Gemfile'と'config/database.yml'を変更してください。
Postgresqlを使う場合、そのユーザはSUPERUSERでなければなりません。
なぜなら、Ruby on RailsのテストはSUPERUSERでないと動作しないからです。
テスト以外の機能はSUPERUSERでなくてもPostgresqlはきちんと動作します。

### インターネット上のWNote

WNoteはHeroku上で「Ruby on Rails」のプロダクション・モードで動作していますが、まだ不安定です。
(https://floating-shore-5277.herokuapp.com/)
不測の事態に備えてデータをバックアップしておいてください。
