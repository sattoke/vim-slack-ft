# vim-slack-ft

Slack の「マークアップでメッセージを書式設定する」モード向け Vim ファイルタイププラグイン。

Slack のメッセージ入力欄で使える独自の Markdown 風記法（以下「Slack 記法」）のシンタックスハイライト、GFM との双方向変換、テキストオブジェクトを提供します。

## Slack 記法について

Slack の環境設定で「マークアップでメッセージを書式設定する」を有効にしたときに使える記法です。[Slack API の mrkdwn](https://api.slack.com/reference/surfaces/formatting) とも一般的な Markdown（CommonMark / GFM）とも異なります。

| 要素 | Slack 記法 | GFM との差異 |
|------|-----------|-------------|
| 太字 | `*text*` | GFM は `**text**` |
| 斜体 | `_text_` | GFM は `*text*` または `_text_`（同じ） |
| 取り消し線 | `~text~` | GFM は `~~text~~` |
| リンク | `[text](URL)` | 同じ |
| 箇条書き | `- item` または `* item` | 同じ |
| 番号付きリスト | `1. item` | 同じ |
| 見出し | なし（`#` はリテラル文字として表示） | GFM は `#` `##` など |
| コード | `` `code` `` / ` ```block``` ` | 同じ |
| 引用 | `> text` | 同じ |
| 絵文字 | `:emoji_name:` | 同じ |

## 機能

### シンタックスハイライト

`.slack` 拡張子のファイルを開くと自動的に `slack` ファイルタイプが設定され、ハイライトが適用されます。

### GFM ↔ Slack 変換

バッファ全体または選択範囲を双方向変換します。

```
:GFMToSlack        " GFM → Slack 変換（バッファ全体）
:SlackToGFM        " Slack → GFM 変換（バッファ全体）
:'<,'>GFMToSlack   " 選択範囲のみ変換
:'<,'>SlackToGFM
```

変換対応表：

| GFM | Slack |
|-----|-------|
| `**bold**` | `*bold*` |
| `*italic*` | `_italic_` |
| `_italic_` | `_italic_`（変換不要、同じ記法） |
| `~~strike~~` | `~strike~` |
| `# Heading` | `# *Heading*`（`#` を残して本文を太字化） |

逆変換（Slack → GFM）では斜体は `_..._` のまま出力します。GFM は `*...*` と `_..._` の両方を斜体として扱うため、どちらも有効です。コードブロック（` ```...``` `）の内部は変換されません。

### テキストオブジェクト

| キー | 動作 |
|------|------|
| `i*` / `a*` | `*太字*` の内側 / 外側を選択 |
| `i_` / `a_` | `_斜体_` の内側 / 外側を選択 |
| `i~` / `a~` | `~取り消し線~` の内側 / 外側を選択 |

例：`ci*` でカーソル位置の太字テキストを置換、`da_` で斜体テキストをデリミタごと削除。

### ビジュアル選択の囲みマッピング

ビジュアルモードで範囲を選択してからキーを押すと、選択範囲を装飾で囲みます。

| キー | 動作 |
|------|------|
| `<leader>b` | `*...*` で囲む（太字） |
| `<leader>i` | `_..._` で囲む（斜体） |
| `<leader>s` | `~...~` で囲む（取り消し線） |

## インストール

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'sattoke/vim-slack-ft'
```

### [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{ 'sattoke/vim-slack-ft' }
```

### 手動インストール

リポジトリを Vim のランタイムパスに追加します。

```sh
git clone https://github.com/sattoke/vim-slack-ft ~/.vim/pack/plugins/start/vim-slack-ft
```

## 使い方

`.slack` 拡張子でファイルを作成すると自動的にプラグインが有効になります。

```sh
vim message.slack
```

他の拡張子のファイルに対して手動で有効にするには：

```vim
:setfiletype slack
```

## ライセンス

MIT
