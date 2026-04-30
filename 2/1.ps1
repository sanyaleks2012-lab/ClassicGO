# Переходим на уровень выше перед выполнением команд
cd ..

git rm --cached 2

# Инициализация (если еще не сделана)
git init

# Привязка репозитория (ошибки игнорируем, если уже добавлен)
git remote add origin https://github.com/sanyaleks2012-lab/ClassicGO.git 2>$null

# Индексация всех файлов в родительской папке
git add .

# Коммит
git commit -m "Update from parent directory"

# Ветка main
git branch -M main

# Пуш
git push -u origin main -f

# Возвращаемся обратно в исходную папку (необязательно, но полезно)
cd $PSScriptRoot