
Вопросы: 
1. wwwdms-****-fe01. Подключение к БД BitrixCMS. Где и как это описывать?
/var/www/html/psbins.ru/bitrix/.settings.php:
  'connetions' =>
  array (
    'value' =>
    array (
      'default' =>
      array (
        'className' => '\\Bitrix\\Main\\DB\\MysqliConnection',
        'host' => 'localhost',
        'database' => 'dbpsbins',
        'login' => 'lkpsbins',
        'password' => '*******',
        'options' => 2,
      ),
    ),
    'readonly' => true,
  ),


2. информация по платёжному шлюзу внутри b2b. доступы к платёжному шлюзу берутся из этого запроса в 1С, 
"getPaymentInfo" => array(
        "method" => "getPaymentInfo",
        "scheme" => "SMP_Payment",
        "parameters" => array("DocId"=>true,"Type"=>true,"Product"=>true,"Full"=>true),
        "cache" => "0",
        "errorcode"=>"2|3",
        "postwork"=> true
),


@PakhomovMikhail 
Исходный код мобильного приложения выложили на терминалку, там же в папке лежит документация по развертыванию файл README.md
на терминалке
/nmt/obmen/

я скидывал папку с названием psps, под каким названием туда положили неизвестно)







# MkDocs

## Examples
https://anjikeesari.com/articles/mkdocs-setup/#step-5-building-and-deploying-your-site
https://realpython.com/python-project-documentation-with-mkdocs/#step-4-prepare-your-documentation-with-mkdocs
https://www.youtube.com/watch?v=0vrhKO2uwhE

## Demo
https://fastapi.tiangolo.com/alternatives/ + https://github.com/fastapi/fastapi/blob/master/docs/en/mkdocs.yml



  palette:
    - media: "(prefers-color-scheme: dark)"
      scheme: slate
      toggle:
        icon: material/brightness-4
        name: Switch to system preference
    - media: "(prefers-color-scheme: light)"
      scheme: default 
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode

<!--- ================================================================== -->


# Hugo
https://habr.com/ru/amp/publications/826474/
https://github.com/Lifailon/lifailon.github.io/tree/hugo-dark

https://dev.to/robinvanderknaap/setup-hugo-using-docker-43pm
https://github.com/jakejarvis/hugo-docker?tab=readme-ov-file

https://github.com/JingWangTW/dark-theme-editor
https://github.com/sfengyuan/edidor

## Themes
https://themes.gohugo.io/
https://themes.gohugo.io/themes/hugo-book/
https://themes.gohugo.io/themes/dark-theme-editor/



## Demo
https://jingwangtw.github.io/dark-theme-editor/posts/markdown_syntax/

## Docker / Docker-compose
https://hub.docker.com/r/klakegg/hugo/
https://hub.docker.com/r/simpledocker/hugo


<!--- ================================================================== -->


# Docusaurus

## Docs 
https://docusaurus.io/docs/installation


<!--- ================================================================== -->

# Diplodoc

## Docs
https://diplodoc.com/how-to/

https://vc.ru/dev/1207696-kak-ya-razbiralsya-s-diplodoc

https://github.com/diplodoc-platform/docs

https://vc.ru/dev/1207696-kak-ya-razbiralsya-s-diplodoc