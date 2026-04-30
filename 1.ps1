# Инициализация
git init

# Привязка репозитория
# Если удаленный репозиторий уже добавлен, выполнение просто пойдет дальше
git remote add origin https://github.com/sanyaleks2012-lab/ClassicGO.git 2>$null

# Индексация и коммит
git add .
git commit -m "Update ClassicGO files"

# Установка главной ветки
git branch -M main

# Заливка на сервер (принудительно)
git push -u origin main -f