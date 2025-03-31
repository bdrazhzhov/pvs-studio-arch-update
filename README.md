# PVS-Studio Arch Update

Это репозиторий содержит конфигурацию docker-образа для создания и
обновления пакета PVS-Studio для Arch Linux x86_64.
Этот образ помогает поддерживать этот пакет в актуальном состоянии.

## Использование

1.  Склонируйте репозиторий.
2.  Передите в диркторию `pvs-studio-arch-update`.
3.  Выполните `docker buildx build -t pvs-studio-arch-update .`

Проверить работу образа можно выполнив команду:

```bash
docker run --rm -it -v <local-artefacts-dir>:/tmp/output -v <local-repository-dir>:/tmp/repo pvs-studio-arch-update:latest
```

тут:

- `<local-artefacts-dir>` — это директория, в которой будет собираться пакет.
    В ней так же будет хранится информация, необходимая для проверки обновлений,
    и все собранные ранее пакеты
- `<local-repository-dir>` — путь к директории, в которой наодится локальный
    пользовательский репозиторий Arch Linux. Предполагается, что БД пакетов
    имеет название `custom`.

Результирующий пакет будет иметь имя `pvs-studio-local`.

## Лицензия

[BSD](LICENCE)
