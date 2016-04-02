# Iijmio::CLI

CLI tools for [iijmio API](https://api.iijmio.jp).

## Installation

```
$ gem install "iijmio-cli"
```

## Usage

設定

```
$ iijmio config

--------------------------------------------------------------------------------
- iijmio-cli configuration setup
--------------------------------------------------------------------------------
Please input your IIJmio developer ID (default: '5XKr784JyAXAAfAWCbI').
[ENTER]
Please input your IIJmio username (default: '').
xxxx # NOTE: NOT mail address.
Please input your IIJmio password (default: '').
[ENTER]

... Completed !!
```

認証

```
$ iijmio auth

Please input your IIJmio password.

... Completed !!
```

クーポン切り替え（１分間に１回まで）

```
$ iijmio ls
+ Family Share (ServiceCode: hddxxxxxxxx)
 - クーポン残量: xx.xx [GB]
+ SIMs
 + ID: hdoxxxxxxxx
  - TEL: xxx-xxxx-xxxx
  - クーポン: 無効

$ iijmio switch lte hdoxxxxxxxx # NOTE: クーポンを有効にする

$ iijmio ls
+ Family Share (ServiceCode: hddxxxxxxxx)
 - クーポン残量: xx.xx [GB]
+ SIMs
 + ID: hdo24188760
  - TEL: xxx-xxxx-xxxx
  - クーポン: 有効

$ iijmio switch low hdoxxxxxxxx # NOTE: クーポンを無効にする

$ iijmio ls
+ Family Share (ServiceCode: hddxxxxxxxx)
 - クーポン残量: xx.xx [GB]
+ SIMs
 + ID: hdoxxxxxxxx
  - TEL: xxx-xxxx-xxxx
  - クーポン: 無効
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
