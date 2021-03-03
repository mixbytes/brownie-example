# Brownie Example (Token)

Демонстрирует настройку среды и тесты для простого Ethereum [стандарт ERC-20](https://eips.ethereum.org/EIPS/eip-20) 
токена, написанного на [Solidity](https://github.com/ethereum/solidity).

## Установка

### Зависимости
* [python3](https://www.python.org/downloads/release/python-368/) version 3.6 or greater, python3-dev
* [ganache-cli](https://github.com/trufflesuite/ganache-cli) - tested with version [6.11.0](https://github.com/trufflesuite/ganache-cli/releases/tag/v6.11.0)

### с помощью  [`pipx`](https://github.com/pipxproject/pipx)

Рекомендованная. Установит brownie в виртуальное окружение и сделает его доступным
 глобально, без необходимости каждый раз окружение активировать. 

Установка `pipx`:

```bash
python3 -m pip install --user pipx
python3 -m pipx ensurepath
```

Установка brownie через `pipx`:

```bash
pipx install eth-brownie
```

### с помощью [`pip`](https://pypi.org/project/pip/):

```bash
pip install eth-brownie
```

### Другие варианты установки
> [Документация по установке](https://eth-brownie.readthedocs.io/en/stable/install.html)


## Использование

В данном репозитории содержится [Базовый Шаблон](contracts/Token.sol) для токена, поверх которого можно 
написать свой собственный токен, а также тесты, покрывающие 100% стандартного ERC20 функционала.

##### Каждый проект Brownie включает в себя следующие папки:
* `contracts/`: Источники контрактов
* `interfaces/`: Источники интерфейса
* `scripts/`: Скрипты для развертывания и взаимодействия
* `tests/`: Скрипты для тестирования проекта

Следующие папки также создаются и используются внутри Brownie для управления проектом. Вы не должны редактировать или удалять файлы в этих папках.
* `build/`: Данные проекта, такие как артефакты компилятора и результаты юнит-тестов.
* `reports/`: JSON файлы отчетов для использования в [Brownie GUI](https://eth-brownie.readthedocs.io/en/latest/gui.html)

##### Brownie имеет три основных компонента, которые можно использовать в разработке:
* **Консоль** полезна для быстрого тестирования и отладки.
* **Скрипты** позволяют автоматизировать общие задачи и обрабатывать развертывания.
* **Тесты** помогают убедиться в том, что ваши контракты выполняются по назначению.

> [Документация по компонентам](https://eth-brownie.readthedocs.io/en/stable/interaction.html)

#### Базовые команды:
* Создать пустой проект brownie: `brownie init`
* Компиляция контрактов: `brownie compile`
* Открыть консоль: `brownie console`
* Выполнить тесты: `brownie test`

## Компиляция и деплой контракта

### Компиляция 

Чтобы скомпилировать все имеющиеся в папке `/contracts` контракты (даже во вложенных папках), выполните:
```bash
brownie compile
```

В данном примере там находится всего один файл [**Token.sol**](contracts/Token.sol)

> [Документация по компиляции](https://eth-brownie.readthedocs.io/en/stable/compile.html)

### Деплой

Чтобы задеплоить тестовый токен, нужна функция `deploy`:

```python
token = Token.deploy("Test Token", "TST", 18, 1e21, {'from': accounts[0]})

Transaction sent: 0x4a61edfaaa8ba55573603abd35403cf41291eca443c983f85de06e0b119da377
  Gas price: 0.0 gwei   Gas limit: 12000000
  Token.constructor confirmed - Block: 1   Gas used: 521513 (4.35%)
  Token deployed at: 0xd495633B90a237de510B4375c442C0469D3C161C
```

Данный код помещен в скрипт `scripts/deploy.py`. 

Для деплоя тестового контракта можно выполнить функцию напрямую в консоли, или вызвать этот скрипт:
```bash
brownie run deploy.py
```

Если не указывать сеть для деплоя, то контракт будет задеплоен в локальную тестовую сеть, которую поднимает 
Ganache. 

> [Документация по деплою](https://eth-brownie.readthedocs.io/en/stable/deploy.html)

### Взаимодействие с контрактом 

После выполнения команды деплоя, мы имеем контракт с начальным балансом в `1e21`, привязанный к счёту `accounts[0]`.
Убедитесь в этом, вызвав в консоли следующие команды:

```python
>>> token
<Token Contract '0xd495633B90a237de510B4375c442C0469D3C161C'>

>>> token.balanceOf(accounts[0])
1000000000000000000000

>>> token.transfer(accounts[1], 1e18, {'from': accounts[0]})
Transaction sent: 0xb94b219148501a269020158320d543946a4e7b9fac294b17164252a13dce9534
  Gas price: 0.0 gwei   Gas limit: 12000000
  Token.transfer confirmed - Block: 2   Gas used: 51668 (0.43%)

<Transaction '0xb94b219148501a269020158320d543946a4e7b9fac294b17164252a13dce9534'>
```

> [Документация по работе с аккаунтами](https://eth-brownie.readthedocs.io/en/stable/core-accounts.html)

> [Документация по работе с контактами](https://eth-brownie.readthedocs.io/en/stable/core-contracts.html)

> [Документация по взаимодействию с блокчейном](https://eth-brownie.readthedocs.io/en/stable/core-chain.html)


## Тестирование

Чтобы выполнить все тесты, выполните:

```bash
brownie test
```

Блок-тесты, входящие в эту смесь, очень стандартные и должны работать с любым 
смарт-контрактом, совместимым с ERC20. Чтобы использовать их для своего токена, достаточно изменить логику 
развертывания в функции `token` ([`tests/conftest.py::token`](tests/conftest.py)).

> [Документация по тестированию](https://eth-brownie.readthedocs.io/en/latest/tests-pytest-intro.html)

## Ресурсы

* ["Вводная стратья на русском"](https://habr.com/ru/post/509618/)
* ["Getting Started with Brownie"](https://medium.com/@iamdefinitelyahuman/getting-started-with-brownie-part-1-9b2181f4cb99)
* [Официальная документация Brownie](https://eth-brownie.readthedocs.io/en/stable/).

