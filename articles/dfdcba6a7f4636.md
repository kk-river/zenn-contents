---
title: "Microsoft.Extensions.Configuration.Jsonで読み込んだ設定値にPrefixを付与する"
emoji: "🗒️"
type: "tech"
topics:
  - "csharp"
  - "json"
  - "config"
published: true
published_at: "2023-12-10 21:13"
---

この投稿は[C# Advent Calendar 2023](https://qiita.com/advent-calendar/2023/csharplang) 10日目の記事です。

Microsoft.Extensions、便利ですよね。
設定ファイルの読み込みには`Microsoft.Extensions.Configuration`が利用できますが、今回はそれに関する小ネタです。

# 動機
設定ファイルを用途別に分けてほしい、といった要件が多々あります。
DBへの接続情報などを含んだファイル、メッセージ用のファイル、色に関するファイル、etc...

jsonはこんな感じ。
https://github.com/kk-river/Articles/blob/main/src/AdventCalender2023/configs.json
https://github.com/kk-river/Articles/blob/main/src/AdventCalender2023/messages.json

まとめて書いたら以下のような感じでしょうか
:::details 長いので折り畳み
```json
{
  "configs": {
    "database": { 
      "host": "host.feature1.jp",
      "user": "user_for_feature1",
      "password": "password_for_feature1",
      "database": "database_for_feature1"
    }
  },
  "messages": {
    "database": {
        "commandTimeout": "Command failed with timeout.",
        "unknownHost": "Unknown host."
    }
  }
}
```
:::

素直に読み込むには以下のように書けば良いです。
```cs: 素直に読み込む
IConfiguration configuration = new ConfigurationBuilder()
    .AddJsonFile("messages.json", false, false)
    .AddJsonFile("configs.json", false, false)
    .Build();
```

読み込んだ値を表示してみると、以下のようになります。
![](https://storage.googleapis.com/zenn-user-upload/4de4d9b6cd30-20231210.png)

どれがどれだかよく分かりませんね。

今回は発生していませんが、名前がバッティングすると**エラーにならず**そのまま値が消滅します。^[「環境に応じた設定値を上書き読み込みできる」というM.E.Cの仕様によるものだと思います]
防止するためには単純に、キー全体でバッティングしていないかをチェックする必要があります。
私なら重複していても見落とします。~~ヨシ！~~

# Prefixをつける
こんなのと、
https://github.com/kk-river/Articles/blob/main/src/AdventCalender2023/PrefixJsonConfigurationProvider.cs

こんなのを準備して、
https://github.com/kk-river/Articles/blob/main/src/AdventCalender2023/PrefixJsonConfigurationSource.cs

それらを用いて読み込みます。
```cs:prefixを付けて読み込む
IConfiguration configuration = new ConfigurationBuilder()
    .Add(new PrefixJsonConfigurationSource() { Path = "messages.json", Prefix = "messages", ReloadOnChange = true, })
    .Add(new PrefixJsonConfigurationSource() { Path = "configs.json", Prefix = "configs", ReloadOnChange = true, })
    .Build();
```

やったね！
![](https://storage.googleapis.com/zenn-user-upload/d4c2be83d74d-20231210.png)