# Esthe Search

エステサロン検索・レビュー分析アプリケーション

## 概要

Esthe Searchは、Google Places APIとHotpepper APIを活用してエステサロンを検索し、AI（DeepSeek）によるレビュー分析機能を提供するWebアプリケーションです。

**本番環境**: [www.search.com](https://www.search.com) (Heroku + お名前ドットコム独自ドメイン)

## 主な機能

- **エステサロン検索**: Google Places APIとHotpepper APIを使用したサロン検索
- **レビュー分析**: DeepSeek AIによる口コミの自動分析と要約
- **ユーザー機能**: Deviseによる認証、お気に入り機能、コメント機能
- **レスポンシブデザイン**: モバイル対応のUI

## 技術スタック

### バックエンド
- **Ruby**: 3.1.2
- **Rails**: 7.1.5
- **データベース**: 
  - 本番環境: PostgreSQL
  - 開発・テスト環境: SQLite3
- **認証**: Devise
- **ページネーション**: Kaminari
- **HTTP クライアント**: Faraday, HTTParty

### フロントエンド
- **JavaScript**: Stimulus (Hotwire)
- **CSS**: Sprockets (Rails Asset Pipeline)
- **UI**: Bootstrap (推測)

### 外部API連携
- **Google Places API**: サロン検索とレビュー取得
- **Hotpepper API**: サロン情報の補完
- **DeepSeek API**: AI によるレビュー分析

### インフラ・デプロイ
- **Docker**: コンテナ化対応
- **Heroku**: 本番環境デプロイ
- **独自ドメイン**: お名前ドットコム (www.search.com)
- **環境変数管理**: dotenv-rails

### 開発・テスト
- **テストフレームワーク**: Capybara, Selenium WebDriver
- **デバッグ**: debug gem, web-console
- **コード品質**: error_highlight

## セットアップ

### 前提条件
- Ruby 3.1.2
- Node.js (yarn)
- PostgreSQL (本番環境)
- SQLite3 (開発環境)

### 環境変数の設定
以下の環境変数を設定してください：

```bash
# Google Places API
GOOGLE_PLACES_API_KEY=your_google_places_api_key

# Hotpepper API
HOTPEPPER_API_KEY=your_hotpepper_api_key

# DeepSeek API
DEEPSEEK_API_KEY=your_deepseek_api_key

# Rails
RAILS_MASTER_KEY=your_rails_master_key
```

### インストール手順

1. リポジトリのクローン
```bash
git clone <repository-url>
cd esthe
```

2. 依存関係のインストール
```bash
bundle install
yarn install
```

3. データベースのセットアップ
```bash
rails db:create
rails db:migrate
```

4. サーバーの起動
```bash
rails server
```

## アーキテクチャ

### サービス層
- `ShopApiService`: Google Places APIとの連携
- `HotpepperService`: Hotpepper APIとの連携
- `DeepseekApiService`: AI分析機能

### 主要なモデル
- `Shop`: サロン情報
- `User`: ユーザー管理（Devise）
- `Like`: お気に入り機能
- `ShopComment`: コメント機能

## デプロイ

### 本番環境
- **URL**: [www.search.com](https://www.search.com)
- **ホスティング**: Heroku
- **ドメイン**: お名前ドットコムで取得した独自ドメイン

### Herokuデプロイ手順
```bash
# Heroku CLIでデプロイ
git push heroku main

# 環境変数の設定
heroku config:set GOOGLE_PLACES_API_KEY=your_key
heroku config:set HOTPEPPER_API_KEY=your_key
heroku config:set DEEPSEEK_API_KEY=your_key

# 独自ドメインの設定（お名前ドットコム）
heroku domains:add www.search.com
```

### Docker
```bash
# イメージのビルド
docker build -t esthe-search .

# コンテナの実行
docker run -p 3000:3000 esthe-search
```

## ライセンス

このプロジェクトのライセンス情報については、プロジェクトオーナーにお問い合わせください。

## 貢献

プルリクエストやイシューの報告を歓迎します。貢献する前に、既存のイシューを確認してください。

## 連絡先

プロジェクトに関する質問やサポートが必要な場合は、プロジェクトのイシューページでお問い合わせください。
