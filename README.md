# Mysql resource cookbook

Manage mysql databases, users and grants from chef.


## Requirements

- Chef 12.19
- Network accessible package repositories

## Plateform support

- Debian jessie (8) only tested

## Usage

### Installation

Place a dependency on the mysql cookbook in your cookbook's metadata.rb

```
depends 'mysql-resources', '~> 0.1.0'
```

### Recipe

Then in a recipe.

#### Mysql database

```
mysql_database 'somedb' do
  host 'localhost'
  admin_user 'root'
  admin_password 'password'
end
```

#### Mysql user

```
mysql_user 'someuser@%' do
  host 'localhost'
  password 'userpass'
  admin_user 'root'
  admin_password 'password'
end
```

#### Mysql grant

```
mysql_grant 'someuser@%' do
  host 'localhost'
  right 'all'
  on 'somedb.*'
  admin_user 'root'
  admin_password 'password'
end
```

## Contribute

Open to contributions on [github](https://github.com/marcmillien/mysql-resources-chef-cookbook).
