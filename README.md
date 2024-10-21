# Laravel Serverless

Deploy your Laravel App to AWS Lambda with [Terraform](https://www.terraform.io/) or [OpenTofu](https://opentofu.org/).

## Use Terraform and Bref Runtime to Run PHP Application in AWS Lambda

AWS Lambda does not natively support PHP. But we can use [Bref](https://bref.sh/) to run PHP application in AWS Lambda.

In Bref official document, Bref use [Serverless](https://www.serverless.com/) to provision the AWS resource, but in detailed, Serverless actually uses AWS CloudFormation to deploy resources behind the scenes.

This project use [cf2tf](https://github.com/DontShaveTheYak/cf2tf) to convert the CloudFormation template to Terraform HCL. After the conversion, I made some changes to make it work.

> I prefer Terraform to Serverless.

## Packaged Your Laravel Application Before Deploying

Before upload your Laravel application, you need to install dependencies and remove unnecessary files (like `.git` or `node_modules`).

```bash
git clone YOUR_LARAVEL_REPO_URL laravel-app

cd laravel-app

# install composer dependencies
composer install --prefer-dist --optimize-autoloader --no-dev
php artisan optimize
# don't cache your config! bref will use environment variables in aws lambda
php artisan config:clear

# remove unnecessary files
rm -rf .git
rm -rf node_modules
rm -rf tests
rm -rf storage

# zip the laravel application
zip -r "laravel-app.zip" .
```

Then you can upload `laravel-app.zip` to AWS Lambda.

## Lambda Can't Store Static Assets

If you have static assets, like javascript files or css files.
You should upload this files to AWS S3 after you bundled them.

```bash
cd laravel-app

npm install
npm run build

# upload assets to aws s3
aws s3 sync public s3://YOUR_ASSET_AWS_BUCKET_NAME
```

Then you should set `ASSET_URL` to AWS S3 bucket public url.
